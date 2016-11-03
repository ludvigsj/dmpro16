#!/bin/bash

topdir=../
(find -L "${topdir}/verilog" -name '*.v' | xargs -n1 -I{} echo "vhdl work" {})
