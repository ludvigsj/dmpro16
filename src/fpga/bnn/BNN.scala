package SudoKu.bnn

import Chisel._
import Array._

class BNN(num_layers: Int, layers_input: List[Int], layers_output: List[Int]) extends Module {
  val io = new Bundle {
    val trans_data = Bits(INPUT, width=1) // input
    val trans_empty = Bool(INPUT) // not enable
    val trans_read = Bool(OUTPUT) // delayed data

    val spi_data = Bits(OUTPUT, width=10) // output
    val spi_write = Bool(OUTPUT) // done
    val spi_full = Bool(INPUT) // ignore
  }

  var layers:Array[Layer] = ofDim(num_layers)
  var enable_regs = Vec.fill(num_layers){ Reg(init=Bool(false)) }
  var counters = Vec.fill(num_layers){ Reg(init=UInt(0, width=10)) }
  for (layer <- 0 until num_layers) {
    layers(layer) = Module( new Layer(layer, layers_input(layer), layers_output(layer)) )
    if(layer == 0) {
      layers(layer).io.input := io.trans_data // one more cycle delayed than we assume
      layers(layer).io.enable := ~io.trans_empty // assume continuous data
    } else {
      layers(layer).io.input := layers(layer-1).io.output(counters(layer))

      when (layers(layer).io.enable) {
        counters(layer) := counters(layer) + UInt(1)
      }.otherwise {
        counters(layer) := UInt(0)
      }
      when (layers(layer-1).io.layer_done) {
        layers(layer).io.enable := Bool(true)
        layers(layer).io.reset := Bool(true)
      }.elsewhen (counters(layer) < UInt(layers_input(layer)) & (counters(layer)>UInt(0))) {
        layers(layer).io.enable := Bool(true)
        layers(layer).io.reset := Bool(false)
      }.otherwise {
        layers(layer).io.enable := Bool(false)
        layers(layer).io.reset := Bool(false)
      }
    }
  }
  io.trans_read := Bool(true)
  io.spi_data := layers(num_layers-1).io.output
  io.spi_write := layers(num_layers-1).io.layer_done
}

class BNNTest(bnn: BNN, num_layers: Int) extends Tester(bnn, _base=10) {
  def printLayerOutput() {
    val l = 0
    val n = 0
    //peek(bnn.layers(l).counter)
    //peek(bnn.layers(layer).io.input)
    //peek(bnn.layers(layer).io.output)
    //peek(bnn.layers(layer).io.enable)
    peek(bnn.layers(l).neurons(n).io.input)
    peek(bnn.layers(l).neurons(n).io.weight)
    peek(bnn.layers(l).neurons(n).accumulator)
    //println(~(bnn.layers(l).neurons(n).io.weight ^ bnn.layers(l).neurons(n).io.input))
    //peek(bnn.layers(l).neurons(n).threshold)
    //peek(bnn.layers(l).neurons(n).accumulator)
    //peek(bnn.layers(l).neurons(n).io.output)
    peek(bnn.layers(l).neurons(n).io.done)
    //peek(bnn.layers(l).count_signal)
    //peek(bnn.layers(l).current_weights)
  }

  def readCSV(filename:String) : Array[Int] = {
    var rows:Array[Int] = Array.empty
    val source = io.Source.fromFile(filename)
    for (line <- source.getLines) {
      val row:Array[Int] = line.split(",").map(_.trim).map(_.toInt)//.map(x => Bits(x))
      rows = row
    }
    rows
  }
  val inputs = readCSV("./test_values.csv")

  val split = 784
  val total = 784 // 784
  //peek(bnn.layers(0).current_weights)

  poke(bnn.io.trans_empty, false)
  for (i <- 0 until total-split) {
    poke(bnn.io.trans_data, inputs(i))
    step(1)
  }
  for (i <- total-split until total) {
    poke(bnn.io.trans_data, inputs(i))
    printLayerOutput()
    step(1)
  }
  poke(bnn.io.trans_empty, true)

  printLayerOutput()
  step(1)
  printLayerOutput()
  step(1)
  printLayerOutput()
  peek(bnn.layers(0).io.output)
  peek(bnn.layers(0).weightsC(0))
  step(10000)
  peek(bnn.io.spi_data)
  //printLayerOutput()

}

object bnn {
  def main(args: Array[String]): Unit = {
    val gen_args =
      Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
      //Array("--backend", "v", "--targetDir", "verilog")
      //Array("--backend", "dot", "--targetDir", "dot")
      chiselMainTest(
        gen_args,
                       // num_layers, input_size, output_size
          //() => Module(new BNN(3, List(4, 3, 3), List(3, 3, 3))))
          () => Module(new BNN(4, List(784, 256, 256, 256), List(256, 256, 256, 10))))
            { c => new BNNTest(c, 4) }
  }
}
