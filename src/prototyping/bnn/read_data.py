import numpy as np
import operator

#ap2 = np.load("2-layer.npz")
ap2 = np.load("3-layer.npz")

sorted_list = []
d = {}
for l in ap2.keys():
    k = ""
    hijack = l[4:]
    print "Here is hijack", hijack
    if len(hijack) < 2:
        k = "arr_"+"0"+hijack
        print "Here is k",k
    else:
        k = str(l)

    d[k] = ap2[l]
    sorted_list.append((k, ap2[l]))

sorted_list = sorted(sorted_list, key=operator.itemgetter(0))

for t in sorted_list:
    print t[0], t[1]



for key in ap2.keys():
    shape = ap2[key].shape

    # assume length 1 or 2
    if len( shape ) == 2:
        vmax = max(ap2[key][0])
        vmin = min(ap2[key][0])
        shapestr = str(shape)
    else:
        vmax = max(ap2[key])
        vmin = min(ap2[key])
        shapestr = str(shape) +  "\t"

    if vmax > 1.0:
        smax = 'FALSE'
    else:
        smax = 'TRUE '

    if vmin < -1.0:
        smin = 'FALSE'
    else:
        smin = 'TRUE '

    print(key + '\t' + shapestr +  "\t" + str(smin) +"\t" + str(smax) )
