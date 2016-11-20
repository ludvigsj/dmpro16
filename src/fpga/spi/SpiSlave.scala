package SudoKu

import Chisel._
import scala.language.reflectiveCalls

class SpiSlave extends Module {

	private def fallingedge(x: Bool) = !x && Reg(next = x)
	private def risingedge(x: Bool) = x && !Reg(next = x)

	val io = new Bundle {
		val cs = UInt(INPUT, 1)
		val clk = UInt(INPUT, 1)
		val mosi = UInt(INPUT, 1)
		val miso = UInt(OUTPUT, 1)
		val wake = Bool(OUTPUT)
		val bnn_read = Bool(OUTPUT)
		val bnn_data = UInt(INPUT, 10)
		val bnn_empty = Bool(INPUT)
	}

	val reg = Module(new SpiShiftRegister())
	reg.io.in := io.mosi
	io.miso := reg.io.out

	val n = Reg(init=UInt(0, 3))
	val read = Reg(init=Bool(false))

	when(Bool(io.cs))
	{
		io.bnn_read := Bool(false)
		when(fallingedge(Bool(io.clk)))
		{
			when(n === UInt(7))
			{
				io.bnn_read := Bool(true)
				read := Bool(true)
				n := UInt(0)
			}
			.otherwise
			{
				reg.io.shift := Bool(true)
				n := n + UInt(1)
				read := Bool(false)
			}
		}
	}
	.otherwise
	{
		reg.io.shift := Bool(false)
		io.bnn_read := Bool(false)
		read := Bool(false)
	}

	when(read)
	{
		reg.io.set := Bool(true)
		read := Bool(false)
	}
	.otherwise
	{
		reg.io.set := Bool(false)
	}

	when(fallingedge(io.bnn_empty))
	{
		read := Bool(true)
		io.bnn_read := Bool(true)
	}
	.otherwise
	{
		io.bnn_read := Bool(false)
	}

	when(!io.bnn_empty)
	{
		io.wake := Bool(true)
	}
	.otherwise
	{
		io.wake := Bool(false)
	}

	when(io.bnn_data === UInt(1))
	{
		reg.io.value := UInt(1)
	}
	.elsewhen(io.bnn_data === UInt(2))
	{
		reg.io.value := UInt(2)
	}
	.elsewhen(io.bnn_data === UInt(4))
	{
		reg.io.value := UInt(3)
	}
	.elsewhen(io.bnn_data === UInt(8))
	{
		reg.io.value := UInt(4)
	}
	.elsewhen(io.bnn_data === UInt(16))
	{
		reg.io.value := UInt(5)
	}
	.elsewhen(io.bnn_data === UInt(32))
	{
		reg.io.value := UInt(6)
	}
	.elsewhen(io.bnn_data === UInt(64))
	{
		reg.io.value := UInt(7)
	}
	.elsewhen(io.bnn_data === UInt(128))
	{
		reg.io.value := UInt(8)
	}
	.elsewhen(io.bnn_data === UInt(256))
	{
		reg.io.value := UInt(9)
	}
	.otherwise
	{
		reg.io.value := UInt(0)
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

/*
object spiSlave {
	def main(args: Array[String]): Unit = {
		chiselMain(args, () => Module(new SpiSlave()))
	}
}
*/
