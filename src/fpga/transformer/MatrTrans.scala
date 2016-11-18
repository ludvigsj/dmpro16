package SudoKu

import Chisel._

/*
Computes address of source image bit which is to be put at specific destination
image bit address, given the coordinates x0, x1, y0 and y1
*/
class MatrTrans extends Module {
    val io = new Bundle {
        val srcX = UInt(OUTPUT, 16)
        val srcY = UInt(OUTPUT, 16)

        val dstX = UInt(INPUT, 16)
        val dstY = UInt(INPUT, 16)

        val x0 = UInt(INPUT, 16)
        val x1 = UInt(INPUT, 16)
        val y0 = UInt(INPUT, 16)
        val y1 = UInt(INPUT, 16)
    }


    io.srcX := (((io.x1-io.x0)*io.dstX).zext - ((io.y1-io.y0)*io.dstY).zext)/SInt(252) + io.x0
    io.srcY := (((io.y1-io.y0)*io.dstX).zext + ((io.x1-io.x0)*io.dstY).zext)/SInt(252) + io.y0
}

class MatrTransTests(c: MatrTrans) extends Tester(c) {
    poke(c.io.x0, 0)
    poke(c.io.y0, 0)
    poke(c.io.x1, 252)
    poke(c.io.y1, 0)

    poke(c.io.dstX, 0)
    poke(c.io.dstY, 0)
    step(1)
    expect(c.io.srcX, 0)
    expect(c.io.srcY, 0)
    
    poke(c.io.x0, 0)
    poke(c.io.y0, 0)
    poke(c.io.x1, 126)
    poke(c.io.y1, 0)

    poke(c.io.dstX, 14)
    poke(c.io.dstY, 72)
    step(1)
    expect(c.io.srcX, 7)
    expect(c.io.srcY, 36)
}

object matrTrans {
    def schschmain(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
            () => Module(new MatrTrans())){c => new MatrTransTests(c)}
    }
}
