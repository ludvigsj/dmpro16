package SudoKu.bnn

import Chisel._
import Weights._

class Neuron(layer: Int, neuron: Int) extends Module {
    val io = new Bundle {
        val input = Bool(INPUT)
		val enable = Bool(INPUT)
        val last_input = Bool(INPUT)
        val output = Bool(OUTPUT)
		val sum_out = UInt(OUTPUT, width=9)
    }
    
    val weights = Vec( Weights.w(layer)(neuron) )
    val accumulator = Reg(init=UInt(0, width=9))

	val weight_location = RegEnable(Mux(io.last_input, UInt(0), weight_location+UInt(1)) ,io.enable)


	io.sum_out := accumulator

	val compare = Module( new Compare(layer, neuron) )
	compare.io.sum := io.sum_out
    //val outstore = Reg(next = compare.io.neuron_value)
    val outstore = RegEnable(compare.io.neuron_value, io.last_input)

}

class NeuronTest(c: Neuron) extends Tester(c) {
   step(1) 
}

object neuron {
    def main(args: Array[String]): Unit = {
        val gen_args =
        Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
        //Array("--backend", "v", "--targetDir", "verilog")
        //Array("--backend", "dot", "--targetDir", "dot")
        chiselMainTest(
            gen_args, 
            () => Module(new Neuron(0, 1))) { c => new NeuronTest(c) }
    }
}


