package SudoKu

import Chisel._

class SpiSlave extends Module {

	private def fallingedge(x: Bool) = !x && Reg(next = x)
	private def risingedge(x: Bool) = x && !Reg(next = x)

	val io = new Bundle {
		val cs = UInt(INPUT, 1)
		val clk = UInt(INPUT, 1)
		val mosi = UInt(INPUT, 1)
		val miso = UInt(OUTPUT, 1)
		val bnn_read = Bool(OUTPUT)
		val bnn_data = UInt(INPUT, 10)
		val bnn_empty = Bool(INPUT)
	}

	val reg = Module(new SpiShiftRegister())
	reg.io.value := UInt(0, 8)
	reg.io.in := io.mosi
	io.miso := reg.io.out

	when(Bool(io.cs))
	{
		reg.io.set := Bool(false)
		io.bnn_read := Bool(false)
		when(fallingedge(Bool(io.clk)))
		{
			reg.io.shift := Bool(true)
		}
	}
	.otherwise
	{
		reg.io.shift := Bool(false)
		reg.io.set := Bool(true)
		io.bnn_read := Bool(true)
	}

	when(io.bnn_data === UInt(1))
	{
		reg.io.value := UInt(1)
	}
	when(io.bnn_data === UInt(2))
	{
		reg.io.value := UInt(2)
	}
	when(io.bnn_data === UInt(4))
	{
		reg.io.value := UInt(3)
	}
	when(io.bnn_data === UInt(8))
	{
		reg.io.value := UInt(4)
	}
	when(io.bnn_data === UInt(16))
	{
		reg.io.value := UInt(5)
	}
	when(io.bnn_data === UInt(32))
	{
		reg.io.value := UInt(6)
	}
	when(io.bnn_data === UInt(64))
	{
		reg.io.value := UInt(7)
	}
	when(io.bnn_data === UInt(128))
	{
		reg.io.value := UInt(8)
	}
	when(io.bnn_data === UInt(256))
	{
		reg.io.value := UInt(9)
	}

}

class SpiSlaveTests(c: SpiSlave) extends Tester(c) {
	poke(c.io.mosi, 0)

	poke(c.io.clk, 1)
	step(1)
	poke(c.io.clk, 0)
	step(1)

	poke(c.io.cs, 1)
	step(3)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 0)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 0)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 0)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 1)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 1)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 1)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 1)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 0)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 0)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 0)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 0)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 0)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 0)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 0)

	poke(c.io.clk, 1)
	step(2)
	expect(c.io.miso, 0)
	poke(c.io.clk, 0)
	step(2)
	expect(c.io.miso, 0)

}


//object spiSlave {
	//def main(args: Array[String]): Unit = {
		//chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
			//() => Module(new SpiSlave())) {c => new SpiSlaveTests(c)}
	//}
//}

object spiSlave {
	def main(args: Array[String]): Unit = {
		chiselMain(args, () => Module(new SpiSlave()))
	}
}
