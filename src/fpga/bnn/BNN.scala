package SudoKu.bnn

import Chisel._
import Array._

class BNN(num_layers: Int, layers_input: List[Int], layers_output: List[Int]) extends Module {
  val io = new Bundle {
    val input = Bool(INPUT)
    val reset = Bool(INPUT)
    val enable = Bool(INPUT)
    val output = Bits(OUTPUT, width=10)
  }

  var layers:Array[Layer] = ofDim(layer_config("layers"))
  for (layer <- 0 until num_layers) {
    layers(layer) = Module( new Layer(layer, layers_output(layer)) )
    if(layer == 0) {
      layers(layer).io.input := io.input
    } else {
      layers(layer).io.input := layers(layer).io.output
    }
  }
  io.output := layers.last.io.output
}

class BNNTest(bnn: BNN) extends Tester(bnn) {
  step(1)
}

object bnn {
	def main(args: Array[String]): Unit = {
    case class Bnn_config()
		val gen_args =
		  //Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
		  Array("--backend", "v", "--targetDir", "verilog")
		  //Array("--backend", "dot", "--targetDir", "dot")
		chiselMainTest(
			gen_args,
      () => Module(new BNN(4,
                           List(784, 256, 256, 256),
                           List(256, 256, 256, 10))
                     { c => new LayerTest(c) }
      )
    )
	}
}
