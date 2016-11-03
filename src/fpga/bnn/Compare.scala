package SudoKu.bnn

import Chisel._
import math._

class Compare(layer: Int, neuron: Int) extends Module {
    val io = new Bundle {
        val sum = UInt(INPUT, width=8)
		val neuron_value = Bool(OUTPUT)
    }


	val t = Array( Array(UInt(4), UInt(2), UInt(6)), Array(UInt(5), UInt(2), UInt(6)) )
	val memory = Vec( t(layer) )
	val output = Mux( io.sum >= memory(neuron), Bool(true), Bool(false))
	val output_register = Reg(next = output)
	io.neuron_value := output_register
}

class CompareTest(c: Compare) extends Tester(c) {
    poke(c.io.sum, 4)
    //peek(c.io.neuron_value)
	step(1)
    peek(c.io.neuron_value)
    expect(c.io.neuron_value, false)

	poke(c.io.sum, 6)
	step(1)
    expect(c.io.neuron_value, true)

	poke(c.io.sum, 5)
	step(1)
    expect(c.io.neuron_value, true)
}

object StupidMain {
    def main(args: Array[String]): Unit = {
        val gen_args =
        Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
        //Array("--backend", "v", "--targetDir", "verilog")
        //Array("--backend", "dot", "--targetDir", "dot")
        chiselMainTest(
            gen_args, 
            () => Module(new Compare(1, 0))) { c => new CompareTest(c) }
    }
}


