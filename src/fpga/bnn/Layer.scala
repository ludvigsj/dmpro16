package SudoKu.bnn

import Chisel._
import Array._
import Math._

class Layer(layer: Int, input_count: Int, neuron_count: Int, layerweights: Array[String]) extends Module {
  val io = new Bundle {
    val input = Bits(INPUT, width=1)
    val enable = Bool(INPUT)
    val reset = Bool(INPUT)
    val output = Bits(OUTPUT, width=neuron_count)
    val layer_done = Bool(OUTPUT)

    val w_out = Bits(OUTPUT, width=neuron_count)
    val last_input = Bool(OUTPUT)
    val neuron_input = Bits(OUTPUT, width=1)
}

  val log2 = (x: Int) => (log10(x)/log10(2)).ceil.toInt
  //val counter = Reg(init=UInt(0,10))
  val counter = Reg(init=UInt(0,log2(input_count)))
  when(io.enable){
    counter := counter + UInt(1)
  }
  val delayed_location = Reg(next=counter)
  val count_signal = delayed_location
  val delayed_input = Reg(next=UInt(io.input))
  io.neuron_input := delayed_input
  io.last_input := Bool(Mux(Bool(counter>=UInt(input_count)), Bool(true), Bool(false)))

  //val alw: Array[Array[String]] = Weights.getW()
  //val lw: Array[String] = alw(layer)
  //val lw = Weights.getWforLayer(layer)
  //print(lw(0))
  val weights = Vec( layerweights(layer).trim.map(Bits(_)) )
  
  val current_weights = Reg( next=weights(count_signal) )
  io.w_out := current_weights
  //val current_weights = Reg( next=weights(delayed_location) )
  //val current_weights = Reg( next=weights(counter) )

  val out_vec = Vec.fill(neuron_count){UInt(0, width=1)}.toBits
  //var neurons:Array[Neuron] = ofDim[Neuron](neuron_count)
  //var regs = Vec.fill(neuron_count){ Reg(init=UInt(0, width=log2(input_count))) }
  val neurons = Vec.tabulate(neuron_count) {
      i: Int => Module(new Neuron(layer, i, log2(input_count))).io
  }
  for (neuron <- 0 until neuron_count) {
    //neurons(neuron) = Module( new Neuron(layer, neuron, log2(input_count)) )
    neurons(neuron).enable := io.enable
    neurons(neuron).reset := io.reset
    neurons(neuron).last_input := io.last_input

    //regs(neuron) := UInt(neuron)
    //neurons(neuron).io.input := io.input
    neurons(neuron).input := io.neuron_input
    //val w = Reg(next=current_weights(regs(neuron)))
    neurons(neuron).weight := io.w_out(neuron)
    //neurons(neuron).io.weight := current_weights(neuron)
    //neurons(neuron).io.weight_location := count_signal
    //neurons(neuron).io.weight_location := delayed_location

    out_vec(neuron) := neurons(neuron).output
  }
  io.output := out_vec
  io.layer_done := neurons(0).done

  // The first layer runs always, and has no time to reset to 0
  if (layer == 0) {
    when(io.last_input){
      counter := UInt(1)
    }
  } else {
    when(io.last_input){
      counter := UInt(0)
    }
  }
}

class LayerTest(c: Layer) extends Tester(c) {
  // STEP 1 -> 1
  poke(c.io.enable, false)
  step(1)
  //peek(c.neurons(0).threshold)
  expect(c.counter, 0)
  // STEP 1 -> 2
  poke(c.io.input, 0)
  poke(c.io.enable, true)
  step(1)
  expect(c.neurons(1).input, 0)
  expect(c.counter, 1)
  expect(c.neurons(1).last_input, false)
  //expect(c.neurons(1).accumulator, 0)
  //expect(c.neurons(1).outstore, 0)
  expect(c.neurons(1).output, 0)
  // STEP 1 -> 3
  poke(c.io.input, 1)
  step(1)
  expect(c.neurons(1).input, 1)
  expect(c.counter, 2)
  expect(c.neurons(1).last_input, false)
  //expect(c.neurons(1).accumulator, 1)
  expect(c.io.layer_done, false)
  //expect(c.neurons(1).outstore, 0)
  expect(c.neurons(1).output, 0)
  // STEP 1 -> 4
  poke(c.io.input, 0)
  step(1)
  expect(c.neurons(1).input, 0)
  expect(c.counter, 3)
  expect(c.neurons(1).last_input, true)
  //expect(c.neurons(1).accumulator, 2)
  //expect(c.neurons(1).outstore, 0)
  expect(c.neurons(1).output, 1)
  expect(c.io.layer_done, true)
  // STEP 1 -> 5
  step(1)
  //expect(c.neurons(1).enable, false)
  expect(c.neurons(1).last_input, false)
  expect(c.counter, 0)
  //expect(c.neurons(1).accumulator, 0)
  expect(c.neurons(1).last_input, false)
  expect(c.io.layer_done, false)
  //expect(c.neurons(1).outstore, 1)
  expect(c.neurons(1).output, 1)
  // STEP 1 -> 6
  poke(c.io.enable, false)
  step(1)
  expect(c.neurons(1).last_input, false)
  expect(c.counter, 0)
  expect(c.io.layer_done, false)
  expect(c.io.output, 3)
  //expect(c.neurons(1).outstore, 1)
  expect(c.neurons(1).output, 1)
}

object layer {
  def main(args: Array[String]): Unit = {
    val gen_args =
    Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
    //Array("--backend", "v", "--targetDir", "verilog")
    //Array("--backend", "dot", "--targetDir", "dot")
    val w = Weights.getW()
    chiselMainTest(
      gen_args,
      () => Module(new Layer(0, 3, 3, w(3) ))) { c => new LayerTest(c) }
      //() => Module(new Layer(0, 256))) { c => new LayerTest(c) }
  }
}

