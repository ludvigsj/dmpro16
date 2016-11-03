import Chisel._
import math._

object PopCountWithReg {
// This function is for now the same as PopCount.
// It should insert registers somewhere in the generated tree.
	val r = Reg(UInt(width=10))
	def apply(in: Iterable[Bool]): UInt = {
		if (in.size == 0) {
			UInt(0)
		} else if (in.size == 1) {
			in.head
		} else {
			apply(in.slice(0, in.size/2)) + Cat(UInt(0), apply(in.slice(in.size/2, in.size)))
		}

	}
	def apply(in: Bits): UInt = apply((0 until in.getWidth).map(in(_)))
}

class AdderTree extends Module {
    val io = new Bundle {
        val write_enable = Bool(INPUT)
        val Sum = UInt(OUTPUT, width=10)
		val v_1 = UInt(INPUT, width=64)
    }

	//val memory = Vec.fill(12){ UInt(width=64) }
	val memory = Mem(UInt(width=64), 12)
	val index = Reg(init= UInt(0, width=5))
	var bitmem = Cat(memory(0),memory(1),memory(2),memory(3),memory(4),memory(5),memory(6),memory(7),memory(8),memory(9),memory(10),memory(11))
	when (io.write_enable) {
		when (index <= UInt(11)) {
		  index := index + UInt(1)
		 } .otherwise {
			index := UInt(0)
		 }
		memory(index) := UInt(io.v_1)
		bitmem = Cat(memory(0),memory(1),memory(2),memory(3),memory(4),memory(5),memory(6),memory(7),memory(8),memory(9),memory(10),memory(11))
	}
	
	//io.readData := memory(io.rw_addr)

	//val Result = Reg( next = PopCountWithReg( bitmem ))
    //io.Sum := Result
	io.Sum := Reg( next = PopCount( bitmem ))
}

class TreeTest(c: AdderTree) extends Tester(c) {
    poke(c.io.write_enable, true)
	poke(c.io.v_1, 41235)
    step(1)
	poke(c.io.v_1, 32658)
    peek(c.io.Sum)
    step(1)
	poke(c.io.v_1, 97325)
    peek(c.io.Sum)
    step(1)
	poke(c.io.v_1, 31852)
    peek(c.io.Sum)
    step(1)
	poke(c.io.v_1, 43181)
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


