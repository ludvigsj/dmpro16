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
	slave.io.bnn_empty := Bool(false)

	val first = UInt(256, 10)
	val second = UInt(1, 10)
	val third = UInt(64, 10)
	val fourth = UInt(16, 10)
	val n = UInt(0)

	when(slave.io.bnn_read)
	{
		when(n === UInt(0))
		{
			slave.io.bnn_data := first
		}
		when(n === UInt(1))
		{
			slave.io.bnn_data := second
		}
		when(n === UInt(2))
		{
			slave.io.bnn_data := third
		}
		when(n === UInt(3))
		{
			slave.io.bnn_data := fourth
		}
		n := (n + UInt(1)) % UInt(4)
	}


}
