#/bin/bash

topdir=../bnn
(find -L "${topdir}/verilog" -name '*.v' | xargs -n1 -I{} echo "v work" {})
