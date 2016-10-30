import Chisel._
import math._

class AdderTree extends Module {
    val io = new Bundle {
        val write_enable = Bool(INPUT)
        val Sum = UInt(OUTPUT, 10)
		val v_1 = UInt(INPUT, width=20)
		val v_2 = UInt(INPUT, width=20)
		val v_3 = UInt(INPUT, width=20)
		val v_4 = UInt(INPUT, width=20)
    }

	val memory = Mem(UInt(width=196), 4)
	when (io.write_enable) {
		memory(0) := UInt(io.v_1)
		memory(2) := UInt(io.v_2)
		memory(3) := UInt(io.v_3)
		memory(1) := UInt(io.v_4)
	} .otherwise {
		memory(0):= UInt(io.v_1)
		memory(2):= UInt(io.v_2)
		memory(1):= UInt(io.v_3)
		memory(3):= UInt(io.v_4)
	}
	
	//io.readData := memory(io.rw_addr)
    val I = Reg( next = PopCount( memory(0) ))
	val J = Reg( next = PopCount( memory(1) ))
	val K = Reg( next = PopCount( memory(2) ))
	val L = Reg( next = PopCount( memory(3) ))

	val IJ = I + J
	val KL = K + L

	val Result = Reg( next = IJ + KL )
    io.Sum := Result
}

class TreeTest(c: AdderTree) extends Tester(c) {
    poke(c.io.write_enable, true)
	poke(c.io.v_1, 41235)
	poke(c.io.v_2, 11111)
	poke(c.io.v_3, 51234)
	poke(c.io.v_4, 12352)
    step(1)
    peek(c.io.Sum)
    step(1)
    peek(c.io.Sum)
    step(1)
    peek(c.io.Sum)
    step(1)
    peek(c.io.Sum)
    //expect(c.io.Sum, 5)
}

object StupidMain {
    def main(args: Array[String]): Unit = {
        val gen_args =
        //Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
        Array("--backend", "v", "--targetDir", "verilog")
        //Array("--backend", "dot", "--targetDir", "dot")
        chiselMainTest(
            gen_args, 
            () => Module(new AdderTree())) { c => new TreeTest(c) }
    }
}


