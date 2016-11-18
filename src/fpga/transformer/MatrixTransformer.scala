package SudoKu

import Chisel._

/*
Computes sequential source addresses in slice order when enable is high
*/
class MatrixTransformer(padding: Int) extends Module {
    val io = new Bundle {
        val src_addr = UInt(OUTPUT, 20)
        val x0 = UInt(INPUT, 16)
        val x1 = UInt(INPUT, 16)
        val y0 = UInt(INPUT, 16)
        val y1 = UInt(INPUT, 16)
        val dest_addr = UInt(INPUT, 20)
    }

    val at = Module(new AddrTrans(padding))

    at.io.x0 := io.x0
    at.io.x1 := io.x1
    at.io.y0 := io.y0
    at.io.y1 := io.y1

    at.io.dest_addr := io.dest_addr

    io.src_addr := at.io.src_addr
}

class MatrixTransformerTests(c: MatrixTransformer) extends Tester(c) {
    poke(c.io.x0, 0)
    poke(c.io.y0, 0)
    poke(c.io.x1, 126)
    poke(c.io.y1, 0)
    var i = 0;
    for(n <- 0 until 81){
        for(y <- 0 until 28){
            for(x <- 0 until 28){
                expect(c.io.src_addr, (x/2 + 14*(n%9) + 640*(y/2) + 640*14*(n/9)))
                i += 1;
                poke(c.io.dest_addr, i)
                step(1)
            }
        }
    }
}

object matrixTransformer {
    def main(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
            () => Module(new MatrixTransformer(0))){c => new MatrixTransformerTests(c)}
    }
}
