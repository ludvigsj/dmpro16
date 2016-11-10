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
	}

	val reg = Module(new SpiShiftRegister())
	reg.io.value := UInt(6, 8)
	reg.io.in := io.mosi
	io.miso := reg.io.out

	when(Bool(io.cs))
	{
		reg.io.set := Bool(false)
		when(fallingedge(Bool(io.clk)))
		{
			reg.io.shift := Bool(true)
		}
	}
	.otherwise
	{
		reg.io.shift := Bool(false)
		reg.io.set := Bool(true)
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
