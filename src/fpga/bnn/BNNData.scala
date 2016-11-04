package SudoKu.bnn

import Chisel._

object Thresholds {
	// Thresholds.t[layer][neuron]
	val t = 
	Array(
		Array(UInt(425), UInt(125), UInt(485)),
		Array(UInt(245), UInt(155), UInt(123)),
		Array(UInt(678), UInt(545), UInt(448))
	)
}

object Weights {
	// Weights.w[layer][neuron][synapse]
	val w = 
	Array(
		Array(
			Array(Bool(true), Bool(false), Bool(false)),
			Array(Bool(true), Bool(true), Bool(false)),
			Array(Bool(false), Bool(true), Bool(false))
		),
		Array(
			Array(Bool(true), Bool(false), Bool(false)),
			Array(Bool(true), Bool(true), Bool(false)),
			Array(Bool(false), Bool(true), Bool(false))
		),
		Array(
			Array(Bool(true), Bool(false), Bool(false)),
			Array(Bool(true), Bool(true), Bool(false)),
			Array(Bool(false), Bool(true), Bool(false))
		)
	)
}
