package SudoKu.bnn

import Chisel._

object Thresholds {
  // Thresholds.t[layer][neuron]
  val t =
  Array(
    Array(UInt(1), UInt(2), UInt(3)),
    Array(UInt(2), UInt(1), UInt(3)),
    Array(UInt(3), UInt(4), UInt(0))
  )
}

object Weights {
  // Weights.w[layer][neuron][synapse]
  val w =
  Array(
    Array(
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(1),Bits(1),Bits(0))
    ),
    Array(
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(1),Bits(1),Bits(0))
    ),
    Array(
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(1),Bits(1),Bits(0))
    )
  )
}
