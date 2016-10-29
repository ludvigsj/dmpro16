import Chisel._
import math._

class AdderTree extends Module {
    val io = new Bundle {
        val A = UInt(INPUT, 784)
        val Sum = UInt(OUTPUT, 10)
    }

    val AllBits = io.A
    io.Sum := PopCount(AllBits)
}

class TreeTest(c: AdderTree) extends Tester(c) {
    poke(c.io.A, 874)
    step(1)
    peek(c.io.Sum)
    //expect(c.io.Sum, 5)
}

object StupidMain {
    def main(args: Array[String]): Unit = {
        val gen_args =
        //Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
        //Array("--backend", "v", "--targetDir", "verilog")
        Array("--backend", "dot", "--targetDir", "dot")
        chiselMainTest(
            gen_args, 
            () => Module(new AdderTree())) { c => new TreeTest(c) }
    }
}


