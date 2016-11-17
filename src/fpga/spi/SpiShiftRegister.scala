// See LICENSE.txt for license details.
package SudoKu

import Chisel._


class SpiShiftRegister extends Module {
  val io = new Bundle {
    val in    = UInt(INPUT, 1)
    val shift = Bool(INPUT)
	val value = UInt(INPUT, 8)
	val set   = Bool(INPUT)
    val out   = UInt(OUTPUT, 1)
  }
  val r0 = Reg(UInt())
  val r1 = Reg(UInt())
  val r2 = Reg(UInt())
  val r3 = Reg(UInt())
  val r4 = Reg(UInt())
  val r5 = Reg(UInt())
  val r6 = Reg(UInt())
  val r7 = Reg(UInt())
  when(reset) {
    r0 := UInt(0, 1)
    r1 := UInt(0, 1)
    r2 := UInt(0, 1)
    r3 := UInt(0, 1)
    r4 := UInt(0, 1)
    r5 := UInt(0, 1)
    r6 := UInt(0, 1)
    r7 := UInt(0, 1)
  } .elsewhen(io.shift) {
    r0 := io.in
    r1 := r0
    r2 := r1
    r3 := r2
    r4 := r3
    r5 := r4
    r6 := r5
    r7 := r6
  }
  .elsewhen (io.set)
  {
	r0 := io.value(0)
	r1 := io.value(1)
	r2 := io.value(2)
	r3 := io.value(3)
	r4 := io.value(4)
	r5 := io.value(5)
	r6 := io.value(6)
	r7 := io.value(7)
  }
  io.out := r7
}
