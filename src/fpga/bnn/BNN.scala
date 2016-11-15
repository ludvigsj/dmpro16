package SudoKu.bnn

import Chisel._
import Array._

class BNN(num_layers: Int, layers_input: List[Int], layers_output: List[Int], w: Array[Array[String]]) extends Module {
  def readCSV(filename:String) : String = {
    var rows:String = ""
    val source = scala.io.Source.fromFile(filename)
    for (line <- source.getLines) {
      //val row:String = line.trim
      rows = rows + line
    }
    //rows.map(x => Bits(x))
    return rows
  }

  def getW(): Array[String] = {
      return Array( readCSV("./weights0.csv"), readCSV("./weights1.csv"), readCSV("./weights2.csv"), readCSV("./weights3.csv"), readCSV("./weights0.csv"))
  }

 def getWforLayer(i: Int): String = {
     val ww = getW()
     return ww(i)
 }

  val io= new Bundle {
    val input = Bits(INPUT, width=1)
    val enable = Bool(INPUT)
    val output = Bits(OUTPUT, width=10)
    val done = Bool(OUTPUT)
  }

  //var layers:Array[Layer] = ofDim(num_layers)

  /*val layers = Vec.tabulate(num_layers) {
      i: Int => Module(new Layer(i, layers_input(i), layers_output(i), getWforLayer(i))).io
  }*/

  val layers = Range(0, num_layers).map(
    i => Module( new Layer(i, layers_input(i), layers_output(i), getW())).io
  )

  val enable_regs = Vec.fill(num_layers){ Reg(init=Bool(false)) }
  val counters = Vec.fill(num_layers){ Reg(init=UInt(0, width=10)) }
  for (layer <- 0 until num_layers) {
    //layers(layer) = Module( 
      //new Layer(layer, layers_input(layer), layers_output(layer), weights(layer)) 
   // )
    if(layer == 0) {
      layers(layer).input := io.input

      when (counters(layer) >= UInt(layers_input(layer))){
        counters(layer) := UInt(0) // may need to be 1
        layers(layer).reset := Bool(true)
      }.otherwise {
        counters(layer) := counters(layer) + UInt(1)
        layers(layer).reset := Bool(false)
      }

      layers(layer).enable := io.enable
    } else {
      layers(layer).input := layers(layer-1).output(counters(layer))

      when (layers(layer).enable) {
        counters(layer) := counters(layer) + UInt(1)
      }.otherwise {
        counters(layer) := UInt(0)
      }
      when (layers(layer-1).layer_done) {
        layers(layer).enable := Bool(true)
        layers(layer).reset := Bool(true)
      }.elsewhen (counters(layer) < UInt(layers_input(layer)) & (counters(layer)>UInt(0))) {
        layers(layer).enable := Bool(true)
        layers(layer).reset := Bool(false)
      }.otherwise {
        layers(layer).enable := Bool(false)
        layers(layer).reset := Bool(false)
      }
    }
  }
 io.output := layers(num_layers-1).output
}

class BNNTest(bnn: BNN, num_layers: Int) extends Tester(bnn, _base=10) {
  def printLayerOutput() {
    for (layer <- 0 until num_layers) {
      peek(bnn.layers(layer).input)
      peek(bnn.layers(layer).output)
      peek(bnn.layers(layer).enable)
    }
  }
  //val layer0_output = Array(0,0,0,0,5,5,5,5,3,3,3,3,3,3,3,3)
  //val layer1_output = Array(0,0,0,0,0,0,0,2,2,2,2,6,6,6,6,6)
  //val layer2_output = Array(0,0,0,0,0,0,0,0,0,0,2,2,2,2,6,6)
  //val input = Array(1,0,0,0,1,0,1,1)

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

  def printSometimes() {
    for (layer <- 0 until num_layers) {
      if (bnn.layers(layer).layer_done == 1) {
        peek(bnn.layers(layer).output)
      }
    }
  }

  poke(bnn.io.enable, true)
  for (i <- 0 until 784) {
    poke(bnn.io.input, inputs(i))
    printSometimes()
    step(1)
  }
  poke(bnn.io.enable, false)
  for (i <- 0 until 10) {
    step(1)
    printSometimes()
  }
  step(1500)
  printLayerOutput()

}

object bnnmain {
  def main(args: Array[String]): Unit = {
    val gen_args =
      Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
      //Array("--backend", "v", "--targetDir", "verilog")
      //Array("--backend", "dot", "--targetDir", "dot")
      val w = Weights.getW()
      chiselMainTest(
        gen_args,
                       // num_layers, input_size, output_size
          //() => Module(new BNN(3, List(4, 3, 3), List(3, 3, 3))))
          () => Module(new BNN(4, List(784, 256, 256, 256), List(256, 256, 256, 10), w)
          ))
            { c => new BNNTest(c, 4) }
  }
}
