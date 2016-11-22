package SudoKu.bnn

import Chisel._
import Array._

object isVerilog {
  def apply(): Boolean = {
    if(Driver.backend != null) {
      return (Driver.backend.getClass().getSimpleName() == "VerilogBackend")
    }
    else {return false}
  }
}


class Layer(layer: Int, input_count: Int, neuron_count: Int) extends Module {
  val io = new Bundle {
    val input = Bits(INPUT, width=1)
    val enable = Bool(INPUT)
    val reset = Bool(INPUT)
    val output = Bits(OUTPUT, width=neuron_count)
    val layer_done = Bool(OUTPUT)
}

  val counter = Reg(init=UInt(0,10))
  when(io.enable){
    counter := counter + UInt(1)
  }
  //val delayed_location = Reg(next=counter)
  val count_signal = counter
  val delayed_input = Reg(next=io.input)
  val last_input = Bool(Mux(Bool(count_signal>=UInt(input_count)), Bool(true), Bool(false)))
  val delayed_last = Reg(next=last_input)
  val delayed_enable = Reg(next=io.enable)
  val delayed_reset = Reg(next=io.reset)

  val weightsC = Vec.tabulate(input_count) { i => Reg(init=Weights.w(layer)(i) ) }
  val weightsV = Vec.tabulate(input_count) { i => Weights.w(layer)(i) }

  def getCurW(): Bits = {
    if (isVerilog()) {
      Reg( next=weightsV(count_signal) )
    } else {
      Reg( next=weightsC(count_signal) )
    }
  }

  val current_weights = getCurW()

  val out_vec = Vec.fill(neuron_count){UInt(0, width=1)}.toBits
  var neurons:Array[Neuron] = ofDim[Neuron](neuron_count)
  for (neuron <- 0 until neuron_count) {
    neurons(neuron) = Module( new Neuron(layer, neuron) )
    neurons(neuron).io.enable := delayed_enable
    neurons(neuron).io.reset := delayed_reset
    neurons(neuron).io.last_input:= delayed_last
    //neurons(neuron).io.input := delayed_delayed_input
    //neurons(neuron).io.input := ddd_input
    neurons(neuron).io.input := delayed_input
    neurons(neuron).io.weight := current_weights(neuron_count-1-neuron)

    out_vec(neuron) := neurons(neuron).io.output
  }
  io.output := out_vec.toBits
  io.layer_done := neurons(0).io.done

  // The first layer runs always, and has no time to reset to 0
  when (io.layer_done) {
    counter := UInt(0)
  }
}

class LayerTest(c: Layer) extends Tester(c) {
  // STEP 1 -> 1
  poke(c.io.enable, false)
  step(1)
  peek(c.neurons(0).threshold)
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
