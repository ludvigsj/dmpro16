package SudoKu.bnn

import Chisel._
import Array._

class Layer(layer: Int, neuron_count: Int) extends Module {
	val io = new Bundle {
		val input = Bits(INPUT, width=1)
		val reset = Bool(INPUT)
		val enable = Bool(INPUT)
		val output = Bits(OUTPUT, width=neuron_count)
		val done = Bool(OUTPUT)
	}

	val counter = Reg(init=UInt(0,9))
	when(io.enable){
		counter := counter + UInt(1)
	}.otherwise {
		counter := UInt(0)
	}

	val last_input = Mux(Bool(counter==UInt(neuron_count)), Bool(true), Bool(false))

	val out_vec = Vec.fill(neuron_count){UInt(0, width=1)}.toBits
	var neurons:Array[Neuron] = ofDim[Neuron](neuron_count)
	for (neuron <- 0 until neuron_count) {
		neurons(neuron) = Module( new Neuron(layer, neuron) )
		neurons(neuron).io.input := io.input
		neurons(neuron).io.enable := io.enable
		neurons(neuron).io.last_input := last_input
		out_vec(neuron) := neurons(neuron).io.output
	}
	io.output := out_vec
}

class LayerTest(c: Layer) extends Tester(c) {
	step(1)
}

object layer {
	def main(args: Array[String]): Unit = {
		val gen_args =
		//Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
		Array("--backend", "v", "--targetDir", "verilog")
		//Array("--backend", "dot", "--targetDir", "dot")
		chiselMainTest(
			gen_args,
			() => Module(new Layer(0, 3))) { c => new LayerTest(c) }
			//() => Module(new Layer(0, 256))) { c => new LayerTest(c) }
	}
}

