package SudoKu.bnn

import Chisel._

object Thresholds {
  // Thresholds.t[layer][neuron]
  val t =
  Array(
    Array(UInt(1), UInt(2), UInt(1)),
    Array(UInt(2), UInt(1), UInt(1)),
    Array(UInt(3), UInt(1), UInt(3))
  )
}

object Weights {
  // Weights.w[layer][neuron][synapse]
  val w =
  Array(
    Array(
      Array(Bits(0),Bits(0),Bits(0),Bits(0)),
      Array(Bits(0),Bits(0),Bits(1),Bits(1)),
      Array(Bits(0),Bits(1),Bits(0),Bits(0))
    ),
    Array(
      Array(Bits(0),Bits(0),Bits(0)),
      Array(Bits(0),Bits(1),Bits(1)),
      Array(Bits(0),Bits(1),Bits(0))
    ),
    Array(
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(0),Bits(1),Bits(0)),
      Array(Bits(0),Bits(1),Bits(1))
    )
  )
}
