import cPickle
import gzip
import numpy as np

def binsign(x):
    return 1 if x>0 else 0
binsign = np.vectorize(binsign, otypes=[np.int])

def xnor(a,b):
    return np.logical_not(np.logical_xor(a,b))

def xnorsum(v,w):
    result = np.empty(w.shape[0])
    for i in range(w.shape[0]):
        result[i] = np.sum(xnor(v,w[i]))
    return result

# load ANN data
nn_data = np.load("2-layer.npz")

# Make synapses binary
nn_first_synapses = binsign(nn_data["arr_0"]).astype(int)
nn_second_synapses = binsign(nn_data["arr_6"]).astype(int)
nn_out_synapses = binsign(nn_data["arr_12"]).astype(int)
# and easier to work with
nn_first_synapses = np.swapaxes(nn_first_synapses,0,1)
nn_second_synapses = np.swapaxes(nn_second_synapses,0,1)
nn_out_synapses = np.swapaxes(nn_out_synapses,0,1)

# original dataset is 0-255, this one uses floats
with gzip.open('mnist.pkl.gz', 'rb') as f:
  _, _, test_set = cPickle.load(f)
# test_set[0] is the image vector
# test_set[1] is the expected output
total_images = 10000 # test_set contains 10000 images
correct_images = 0

def compute_layer(previous_activation, weights, beta, gamma, mean, inv_stddev):
    #activation = np.dot(previous_activation, weights)
    activation = xnorsum(previous_activation, weights)
    activation_with_mean = (activation*2)-previous_activation.shape[0] - mean
    #current_layer_output = np.sign((gamma * activation_with_mean * inv_stddev) +
    #        beta).astype(int)
    current_layer_output = binsign((gamma * activation_with_mean * inv_stddev) +
            beta).astype(int)

    return current_layer_output

for test_image in range(total_images):
    image_vector = np.empty(784, dtype=int)
    for i in range(784):
        if test_set[0][test_image][i] > 0.6: # colors are not linear
            image_vector[i] = 1
        else:
            image_vector[i] = 0
    
    # compute first hidden layer (1024) 
    layer_1 = compute_layer(image_vector,
            nn_first_synapses,
            nn_data["arr_2"],
            nn_data["arr_3"],
            nn_data["arr_4"],
            nn_data["arr_5"])

    # compute second hidden layer (128)
    layer_2 = compute_layer(layer_1,
            nn_second_synapses,
            nn_data["arr_8"],
            nn_data["arr_9"],
            nn_data["arr_10"],
            nn_data["arr_11"])

    # compute output layer (10)
    layer_3 = compute_layer(layer_2,
            nn_out_synapses,
            nn_data["arr_14"],
            nn_data["arr_15"],
            nn_data["arr_16"],
            nn_data["arr_17"])

    output_from_nn = np.argmax(layer_3)
    correct_output = test_set[1][test_image]
    if output_from_nn == correct_output:
        correct_images += 1
    if (test_image%100 == 99):
        print("{}/{} correct images".format(correct_images, test_image+1))

