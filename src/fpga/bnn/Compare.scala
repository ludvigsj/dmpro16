package SudoKu.bnn

import Chisel._
import math._
import Thresholds._

class Compare(layer: Int, neuron: Int) extends Module {
    val io = new Bundle {
        val sum = UInt(INPUT, width=8)
		val neuron_value = Bool(OUTPUT)
    }


	//val threshold = Vec( Thresholds.t(layer)(neuron) )(0)
	val threshold = Thresholds.t(layer)(neuron)
	val output = Mux( io.sum >= threshold, Bool(true), Bool(false))
	val output_register = Reg(next = output)
	io.neuron_value := output_register
}

class CompareTest(c: Compare) extends Tester(c) {
    poke(c.io.sum, 244)
	step(1)
    expect(c.io.neuron_value, false)

	poke(c.io.sum, 245)
	step(1)
    expect(c.io.neuron_value, true)

	poke(c.io.sum, 246)
	step(1)
    expect(c.io.neuron_value, true)
}

object Comparison {
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


