import cPickle
import gzip
import numpy as np

def softmax(x):
    """Compute softmax values for each sets of scores in x."""
    return np.exp(x) / np.sum(np.exp(x), axis=0)

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

# load ANN data
nn_data = np.load("2-layer.npz")
# Make synapses binary
nn_first_synapses = np.sign(nn_data["arr_0"]).astype(int)
print(nn_first_synapses)
nn_second_synapses = np.sign(nn_data["arr_6"]).astype(int)
print(nn_second_synapses)
nn_out_synapses = np.sign(nn_data["arr_12"]).astype(int)
print(nn_out_synapses)

# load image
# original dataset is 0-255, this one uses floats
with gzip.open('mnist.pkl.gz', 'rb') as f:
  _, _, test_set = cPickle.load(f)
# test_set[0] is the image vector
# test_set[1] is the expected output
# test_set contains 10000 images
total_images = 10000
correct_images = 0

def compute_layer(previous_activation, weights, beta, gamma, mean, inv_stddev):
    activation = np.dot(previous_activation, weights)
    
    activation_with_mean = activation - mean
    first_layer_output = np.sign((gamma * activation_with_mean * inv_stddev) +
            beta).astype(int)

    return first_layer_output

for test_image in range(total_images):
    image_vector = test_set[0][test_image]
    for i in range(784):
        if image_vector[i] > 0.6: # colors are not linear
            image_vector[i] = 1
        else:
            image_vector[i] = -1
    
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
        print("{}/{} correct images".format(correct_images, test_image+1))
