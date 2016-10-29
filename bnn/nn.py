import cPickle
import gzip
import numpy as np

# load ANN data
nn_data = np.load("3-layer.npz")

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

# original dataset is 0-255, this one uses floats
with gzip.open('mnist.pkl.gz', 'rb') as f:
  _, _, test_set = cPickle.load(f)
# test_set[0] is the image vector
# test_set[1] is the expected output
total_images = 10000 # test_set contains 10000 images
correct_images = 0

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

def do_batchnorm(xnorsum, threshold):
    if xnorsum >= threshold:
        return 1
    else:
        return 0
do_batchnorm = np.vectorize(do_batchnorm, otypes=[np.int])

def compute_layer(previous_activation, weights, threshold):
    return do_batchnorm( xnorsum(previous_activation, weights), threshold )

def apply_growth(weights, growth):
    for w in range(weights.shape[0]):
        for value in range(weights.shape[1]):
            weights[w][value] = xnor(weights[w][value], growth[w])

apply_growth(nn_first_synapses, g1)
apply_growth(nn_second_synapses, g2)
apply_growth(nn_third_synapses, g3)
apply_growth(nn_out_synapses, g4)

for test_image in range(total_images):
    image_vector = np.empty(784, dtype=int)
    for i in range(784):
        if test_set[0][test_image][i] >= 0.6: # colors are not linear
            image_vector[i] = 1
        else:
            image_vector[i] = 0

    layer_1 = compute_layer(image_vector, nn_first_synapses, threshold1)
    layer_2 = compute_layer(layer_1, nn_second_synapses, threshold2)
    layer_3 = compute_layer(layer_2, nn_third_synapses, threshold3)
    layer_4 = compute_layer(layer_3, nn_out_synapses, threshold4)

    output_from_nn = np.argmax(layer_4)
    correct_output = test_set[1][test_image]
    if output_from_nn == correct_output:
        correct_images += 1
    if (test_image%100 == 99):
        print("{}/{} correct images".format(correct_images, test_image+1))

