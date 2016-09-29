import numpy as np
import matplotlib.pyplot as plt

allparams = np.load("2-layer.npz")

nof_neurons = 1024
#nof_neurons = 30
nof_synapses = 784
nof_synapses = 15
neuron = 8
synapse_used = 0

red_neurons = []
red_neuron_outputs = []
blue_neurons = []
blue_neuron_outputs = []

sign = lambda x: -1 if x < 0 else 1 if x > 0 else 0
#neuron_list = [0, 11, 3, 1]
#neuron_list = [3]

for neuron in range(nof_neurons):
#for neuron in neuron_list:
 for synapse_used in range(nof_synapses):
  beta = allparams["arr_2"][neuron]
  inv_stddev = allparams["arr_3"][neuron]
  mean = allparams["arr_4"][neuron]
#  mean = 0
  gamma = allparams["arr_5"][neuron]
  binary_synapses = sign( allparams["arr_0"][synapse_used][neuron] )
  # binary_synapses = allparams["arr_0"][synapse_used][neuron]
  binary_weights = 1 # bias values can be ignored

  binary_stuff = binary_weights * binary_synapses
  batchnorm = lambda x: gamma * (x - mean) * inv_stddev + beta
  neuron_output = sign( batchnorm(binary_stuff) )
  # neuron_output = ( batchnorm(binary_stuff) )
  
  #synapse_used = synapse_used + neuron * nof_synapses
  if binary_stuff < 0:
     # blue_neurons.append(neuron)
      blue_neurons.append(synapse_used)
      blue_neuron_outputs.append(neuron_output)
  else:
      # red_neurons.append(neuron)
      red_neurons.append(synapse_used)
      red_neuron_outputs.append(neuron_output)

  
# plot binary stuff versus neuron output
# x-axis neuron number
# y-axis neuron output
# color different depending on binary_stuff

#plt.plot(np.array(neuron_number), np.array(neuron_outputs), 'o', c=np.array(colors))
#plt.plot(neuron_number, neuron_outputs, 'o', c=colors)
plt.plot(blue_neurons, blue_neuron_outputs, 'bo', red_neurons, red_neuron_outputs, 'ro')
plt.show()


