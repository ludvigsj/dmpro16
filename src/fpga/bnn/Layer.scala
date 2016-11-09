package SudoKu.bnn

import Chisel._
import Array._

class Layer(layer: Int, input_count: Int, neuron_count: Int) extends Module {
  val io = new Bundle {
    val input = Bits(INPUT, width=1)
    val enable = Bool(INPUT)
    val output = Bits(OUTPUT, width=neuron_count)
    val layer_done = Bool(OUTPUT)
}

  val counter = Reg(init=UInt(0,9))
  val done_counter = Reg(init=UInt(0,9))
  when(io.enable){
    counter := counter + UInt(1)
  }//.otherwise {
  //  counter := UInt(0)
  //}

  val last_input = Bool(Mux(Bool(counter>=UInt(neuron_count)), Bool(true), Bool(false)))

  val out_vec = Vec.fill(neuron_count){UInt(0, width=1)}.toBits
  var neurons:Array[Neuron] = ofDim[Neuron](neuron_count)
  for (neuron <- 0 until neuron_count) {
    neurons(neuron) = Module( new Neuron(layer, neuron) )
    neurons(neuron).io.input := io.input
    neurons(neuron).io.enable := io.enable
    neurons(neuron).io.last_input := last_input
    //out_vec(neuron) := neurons(neuron).io.output
    out_vec(neuron_count-1-neuron) := neurons(neuron).io.output
  }
  io.output := out_vec
  //io.layer_done := neurons(0).io.done

  when(last_input){
    counter := UInt(0)
  }
  when(counter === UInt(input_count)-UInt(2)) {
    io.layer_done := Bool(true)
  }.otherwise{
    io.layer_done := Bool(false)
  }

}

class LayerTest(c: Layer) extends Tester(c) {
  // STEP 1 -> 1
  poke(c.io.enable, false)
  step(1)
  expect(c.counter, 0)
  // STEP 1 -> 2
  poke(c.io.input, 0)
  poke(c.io.enable, true)
  step(1)
  expect(c.neurons(1).io.input, 0)
  expect(c.counter, 1)
  expect(c.neurons(1).io.last_input, false)
  expect(c.neurons(1).accumulator, 0)
  expect(c.neurons(1).outstore, 0)
  expect(c.neurons(1).io.output, 0)
  // STEP 1 -> 3
  poke(c.io.input, 1)
  step(1)
  expect(c.neurons(1).io.input, 1)
  expect(c.counter, 2)
  expect(c.neurons(1).io.last_input, false)
  expect(c.neurons(1).accumulator, 1)
  expect(c.io.layer_done, false)
  expect(c.neurons(1).outstore, 0)
  expect(c.neurons(1).io.output, 0)
  // STEP 1 -> 4
  poke(c.io.input, 0)
  step(1)
  expect(c.neurons(1).io.input, 0)
  expect(c.counter, 3)
  expect(c.neurons(1).io.last_input, true)
  expect(c.neurons(1).accumulator, 2)
  expect(c.neurons(1).outstore, 0)
  expect(c.neurons(1).io.output, 1)
  expect(c.io.layer_done, true)
  // STEP 1 -> 5
  step(1)
  //expect(c.neurons(1).io.enable, false)
  expect(c.neurons(1).io.last_input, false)
  expect(c.counter, 0)
  expect(c.neurons(1).accumulator, 0)
  expect(c.neurons(1).io.last_input, false)
  expect(c.io.layer_done, false)
  expect(c.neurons(1).outstore, 1)
  expect(c.neurons(1).io.output, 1)
  // STEP 1 -> 6
  poke(c.io.enable, false)
  step(1)
  expect(c.neurons(1).io.last_input, false)
  expect(c.counter, 0)
  expect(c.io.layer_done, false)
  expect(c.io.output, 3)
  expect(c.neurons(1).outstore, 1)
  expect(c.neurons(1).io.output, 1)
}

object layer {
  def main(args: Array[String]): Unit = {
    val gen_args =
    Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
    //Array("--backend", "v", "--targetDir", "verilog")
    //Array("--backend", "dot", "--targetDir", "dot")
    chiselMainTest(
      gen_args,
      () => Module(new Layer(0, 3, 3))) { c => new LayerTest(c) }
      //() => Module(new Layer(0, 256))) { c => new LayerTest(c) }
  }
}

