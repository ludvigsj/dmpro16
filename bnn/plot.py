import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

allparams = np.load("2-layer.npz")

nof_neurons = 1024
nof_neurons = 14
nof_synapses = 784
#nof_synapses = 15

red_neurons = []
red_neuron_outputs = []
blue_neurons = []
blue_neuron_outputs = []
neurons = []
neuron_outputs = []

def binsign(x):
    return 1 if x>0 else -1
binsign = np.vectorize(binsign, otypes=[np.int])

nn_first_synapses = binsign(allparams["arr_0"]).astype(int)
nn_second_synapses = binsign(allparams["arr_6"]).astype(int)
nn_out_synapses = binsign(allparams["arr_12"]).astype(int)

sign = lambda x: -1 if x < 0 else 1 if x > 0 else 0

for neuron in range(nof_neurons):
  neurons = []
  neuron_outputs = []
  #for activation in range(-784, 784, 2):
  for activation in range(0, 784, 1):
    beta = allparams["arr_2"][neuron]
    inv_stddev = allparams["arr_3"][neuron]
    mean = allparams["arr_4"][neuron]
    gamma = allparams["arr_5"][neuron]

    batchnorm = lambda x: gamma * ((x*2)-784 - mean) * inv_stddev + beta
    neurons.append(activation)
    neuron_outputs.append( batchnorm(activation) )
   
    #red_neuron_outputs.append(neuron_output)
    #blue_neuron_outputs.append(neg_neuron_output)
    #red_neurons.append(binary_stuff)
    #blue_neurons.append(neg_input)
    #neurons.append(neuron)
    
    #synapse_used = synapse_used + neuron * nof_synapses
    #if binary_stuff <= 0:
    #  blue_neurons.append(neuron)
      #blue_neurons.append(synapse_used)
    #  blue_neuron_outputs.append(neuron_output)
    #else:
    #  red_neurons.append(neuron)
      #red_neurons.append(synapse_used)
    #  red_neuron_outputs.append(neuron_output)

  
  plt.figure(neuron)
#plt.plot(np.array(neuron_number), np.array(neuron_outputs), 'o', c=np.array(colors))
  plt.plot(neurons, neuron_outputs, '-')
#plt.plot(neurons, blue_neurons, 'bs', neurons, blue_neuron_outputs, 'bo', neurons, red_neurons, 'rs', neurons, red_neuron_outputs, 'ro')
#plt.plot(blue_neurons, blue_neuron_outputs, 'bo', red_neurons, red_neuron_outputs, 'ro')
#plt.show()
  filename = "plot2/" + str(neuron) + ".png"
  plt.savefig(filename, bbox_inches='tight')
  print(filename)
  plt.close()
