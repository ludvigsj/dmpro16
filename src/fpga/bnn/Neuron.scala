package SudoKu.bnn

import Chisel._
import Weights._

class Neuron(layer: Int, neuron: Int) extends Module {
  val io = new Bundle {
    val input = Bits(INPUT, width=1)
    val enable = Bool(INPUT)
    val last_input = Bool(INPUT)
    val weight_location = UInt(INPUT, width=9)
    val output = Bits(OUTPUT, width=1)
    val done = Bool(OUTPUT)
  }

  val weights = Vec( Weights.w(layer)(neuron) )
  val accumulator = Reg(init=UInt(0, width=9))
  val synapse = ~(weights(io.weight_location) ^ io.input)
  io.done := io.last_input
  when(io.enable) {
    when(io.weight_location === UInt(0)) {
      accumulator := synapse
    }.otherwise {
      accumulator := accumulator+synapse
    }
  }

  val threshold = Thresholds.t(layer)(neuron)
  val result = Mux( accumulator >= threshold, Bool(true), Bool(false))

  // We need a delay to pass the tests in NeuronTest. This delay is not
  // needed when we test a system with multiple neurons, because 
  // Chisel does some optimizations.
  // val delay_last = Reg(next=io.last_input)
  // val outstore = RegEnable(result, io.delayed_last_input)

  val outstore = RegEnable(result, io.last_input)

  when(io.last_input) {
    accumulator := UInt(0)
  }

  io.output := Mux( io.last_input, result, outstore )
}

class NeuronTest(c: Neuron) extends Tester(c) {
  // These expects are written with the assumption that BNN Data has not
  // changed
  poke(c.io.input, 0)
  poke(c.io.enable, true)
  poke(c.io.last_input, false)
  step(1)
  peek(c.io.weight_location)
  peek(c.outstore)
  expect(c.io.output, 0)
  expect(c.accumulator, 0)

  poke(c.io.input, 1)
  poke(c.io.enable, true)
  poke(c.io.last_input, false)
  step(1)
  expect(c.outstore, 0)
  expect(c.io.output, 0)
  expect(c.accumulator, 1)

  poke(c.io.input, 0)
  poke(c.io.enable, true)
  poke(c.io.last_input, true)
  step(1)
  expect(c.outstore, 0)
  expect(c.io.output, 1)
  expect(c.accumulator, 2)

  poke(c.io.enable, false)
  poke(c.io.last_input, false)
  step(1)
  expect(c.outstore, 1)
  expect(c.io.output, 1)
  expect(c.accumulator, 0)

  step(1)
  expect(c.accumulator, 0)
  expect(c.io.output, 1)
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


