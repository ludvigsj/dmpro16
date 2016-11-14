import cPickle
import gzip
import numpy as np

# load ANN data
nn_data = np.load("../../prototyping/bnn/3-layer.npz")

def binsign(x):
    return 1 if x>0 else 0
binsign = np.vectorize(binsign, otypes=[np.int])

# Make synapses binary
nn_first_synapses = binsign(nn_data["arr_0"]).astype(int)
nn_second_synapses = binsign(nn_data["arr_6"]).astype(int)
nn_third_synapses = binsign(nn_data["arr_12"]).astype(int)
nn_out_synapses = binsign(nn_data["arr_18"]).astype(int)
# and easier to work with
nn_first_synapses = np.swapaxes(nn_first_synapses,0,1)
nn_second_synapses = np.swapaxes(nn_second_synapses,0,1)
nn_third_synapses = np.swapaxes(nn_third_synapses,0,1)
nn_out_synapses = np.swapaxes(nn_out_synapses,0,1)

def find_threshold_and_growth(beta, gamma, mean, inv_stddev, previous_activation_shape):
    multiplier = gamma*inv_stddev
    batchnorm_array = (0.5 * (mean + previous_activation_shape -
                          beta/(multiplier) )).astype(int)
    def is_growing(a):
        if a > 0:
            return 1
        else:
            return 0
    is_growing = np.vectorize(is_growing, otypes=[np.int])
    growth = is_growing(multiplier)
    return batchnorm_array, growth

threshold1, g1 = find_threshold_and_growth(nn_data["arr_2"], nn_data["arr_3"],
                                           nn_data["arr_4"], nn_data["arr_5"],
                                           784)
threshold2, g2 = find_threshold_and_growth(nn_data["arr_8"], nn_data["arr_9"],
                                           nn_data["arr_10"], nn_data["arr_11"],
                                           threshold1.shape[0])
threshold3, g3 = find_threshold_and_growth(nn_data["arr_14"], nn_data["arr_15"],
                                           nn_data["arr_16"], nn_data["arr_17"],
                                           threshold2.shape[0])
threshold4, g4 = find_threshold_and_growth(nn_data["arr_20"], nn_data["arr_21"],
                                           nn_data["arr_22"], nn_data["arr_23"],
                                           threshold2.shape[0])

def xnor(a,b):
    return np.logical_not(np.logical_xor(a,b))

def xnorsum(v,w):
    result = np.empty(w.shape[0])
    for i in range(w.shape[0]):
        result[i] = np.sum(xnor(v,w[i]))
    return result

def apply_growth(weights, growth):
    for w in range(weights.shape[0]):
        for value in range(weights.shape[1]):
            weights[w][value] = xnor(weights[w][value], growth[w])

apply_growth(nn_first_synapses, g1)
apply_growth(nn_second_synapses, g2)
apply_growth(nn_third_synapses, g3)
apply_growth(nn_out_synapses, g4)


thresholds_string = ""
for thresholds in [threshold1, threshold2, threshold3, threshold4]:
    for t in range(thresholds.shape[0]):
        if (t != thresholds.shape[0]-1):
            thresholds_string += str(thresholds[t]) + ','
        else:
            thresholds_string += str(thresholds[t])
    thresholds_string += "\n"

with open('thresholds.csv', 'w') as thresholds_file:
    thresholds_file.write(thresholds_string)


nn_first_synapses = np.swapaxes(nn_first_synapses,0,1)
nn_second_synapses = np.swapaxes(nn_second_synapses,0,1)
nn_third_synapses = np.swapaxes(nn_third_synapses,0,1)
nn_out_synapses = np.swapaxes(nn_out_synapses,0,1)

for weights in [nn_first_synapses, nn_second_synapses, nn_third_synapses, nn_out_synapses]:
    w_string = ''
    for s in range(weights.shape[0]):
        for n in range(weights.shape[1]):
            if (n != weights.shape[1]-1):
                w_string += str(weights[s][n]) + ','
            else:
                w_string += str(weights[s][n])
        #if (neuron != weights.shape[0]-1):
        w_string += '\n'
    if weights is nn_first_synapses:
        filename = 'weights0.csv'
    elif weights is nn_second_synapses:
        filename = 'weights1.csv'
    elif weights is nn_third_synapses:
        filename = 'weights2.csv'
    elif weights is nn_out_synapses:
        filename = 'weights3.csv'
    else:
        print('Something went wrong')
    with open(filename, 'w') as w_file:
        w_file.write(w_string)

