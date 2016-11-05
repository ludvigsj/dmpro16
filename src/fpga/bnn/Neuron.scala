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
	val weight_location = Reg(init=UInt(0, width=9))
	val synapse = ~(weights(weight_location) ^ io.input)
	when(io.enable) {
		weight_location := Mux(io.last_input, UInt(0), weight_location+UInt(1)) 
		accumulator := accumulator+synapse
	}.otherwise {
		accumulator := UInt(0)
	}
	
	io.sum_out := accumulator
	val compare = Module( new Compare(layer, neuron) )
	compare.io.sum := io.sum_out

	// We need a delay to make sure outstore updates at the right time
	val delay_last = Reg(next=io.last_input)
    val outstore = RegEnable(compare.io.neuron_value, delay_last)
	io.output := outstore
}

class NeuronTest(c: Neuron) extends Tester(c) {
   // These expects are written with the assumption that BNN Data has not
   // changed
   poke(c.io.input, false)
   poke(c.io.enable, true)
   poke(c.io.last_input, false)
   step(1)
   peek(c.io.sum_out)
   peek(c.weight_location)
   peek(c.outstore)
   peek(c.io.last_input)
   peek(c.compare.io.neuron_value)
   expect(c.io.output,false)
   expect(c.accumulator, 0)

   poke(c.io.input, true)
   poke(c.io.enable, true)
   poke(c.io.last_input, false)
   step(1)
   expect(c.io.output,false)
   expect(c.accumulator, 1)

   poke(c.io.input, false)
   poke(c.io.enable, true)
   poke(c.io.last_input, true)
   step(1)
   expect(c.io.output, false)
   expect(c.accumulator, 2)

   poke(c.io.enable, false)
   poke(c.io.last_input, false)
   step(1)
   expect(c.io.output, true)
   expect(c.accumulator, 0)

   step(1)
   expect(c.accumulator, 0)
   expect(c.io.output, true)
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


