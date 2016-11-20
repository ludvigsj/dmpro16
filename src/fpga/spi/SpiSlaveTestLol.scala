package SudoKu

import Chisel._

class SpiSlaveTestLol extends Module {
	val io = new Bundle {
		val cs = UInt(INPUT, 1)
		val clk = UInt(INPUT, 1)
		val mosi = UInt(INPUT, 1)
		val miso = UInt(OUTPUT, 1)
		val wake = Bool(OUTPUT)
	}

	val slave = Module(new SpiSlave())

	slave.io.cs := io.cs
	slave.io.clk := io.clk
	slave.io.mosi := io.mosi
	io.miso := slave.io.miso
	io.wake := slave.io.wake
	slave.io.bnn_empty := Bool(true)

	val first = UInt(256, 10)
	val second = UInt(1, 10)
	val third = UInt(64, 10)
	val fourth = UInt(16, 10)
	val n = Reg(init=UInt(0))
	val started = Reg(init=Bool(false))

	when(!started)
	{
		started := Bool(true)
		slave.io.bnn_empty := Bool(false)
	}
	when(slave.io.bnn_read)
	{
		n := (n + UInt(1)) % UInt(4)
	}

	when(n === UInt(0))
	{
		slave.io.bnn_data := first
	}
	.elsewhen(n === UInt(1))
	{
		slave.io.bnn_data := second
	}
	.elsewhen(n === UInt(2))
	{
		slave.io.bnn_data := third
	}
	.elsewhen(n === UInt(3))
	{
		slave.io.bnn_data := fourth
	}
	.otherwise
	{
		slave.io.bnn_data := UInt(0)
	}


}
object spiTest {
	def main(args: Array[String]): Unit = {
		chiselMain(args, () => Module(new SpiSlaveTestLol()))
	}
}
