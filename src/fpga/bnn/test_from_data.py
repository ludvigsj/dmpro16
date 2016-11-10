# -*- coding: utf-8 -*-
from __future__ import print_function
import cPickle
import gzip
import numpy as np

# load ANN data
nn_data = np.load("../../prototyping/bnn/3-layer.npz")

def binsign(x):
    return 1 if x>0 else 0
binsign = np.vectorize(binsign, otypes=[np.int])

# original dataset is 0-255, this one uses floats
with gzip.open('../../prototyping/bnn/mnist.pkl.gz', 'rb') as f:
  _, _, test_set = cPickle.load(f)
# test_set[0] is the image vector
# test_set[1] is the expected output

test_file = open('test_values.csv', 'w')

for test_image in range(1):
    test_image = 3
    image_vector = np.empty(784, dtype=int)
    for i in range(784):
        if test_set[0][test_image][i] >= 0.6:
            if i != 783:
                #image_vector[i] = 1
                test_file.write('1,')
            else:
                test_file.write('1')
        else:
            if i != 783:
                #image_vector[i] = 0
                test_file.write('0,')
            else:
                test_file.write('0')
test_file.close()
    #image_array = np.reshape(image_vector, (28,28))
    #for i in range(28):
    #    for j in range(28):
    #        if image_array[i][j] == 1:
    #            test_file.write('1,')
    #        else:
    #            test_file.write('0,')
    #print('poke(bnn.io.enable, false)')
    #print('step(2000)')
    #print('peek(bnn.io.output)')
    #        print("{}/{} correct images".format(correct_images, test_image+1))
    #print("This is supposed to be an ", test_set[1][test_image])
