package SudoKu

import Chisel._

/*
Computes address of source image bit which is to be put at specific destination
image bit address, given the coordinates x0, x1, y0 and y1
*/
class AddrTrans(padding: Int) extends Module {
    val io = new Bundle {
        val dest_addr = UInt(INPUT, 32)
        val src_addr = UInt(OUTPUT, 20)
        val x0 = UInt(INPUT, 16)
        val x1 = UInt(INPUT, 16)
        val y0 = UInt(INPUT, 16)
        val y1 = UInt(INPUT, 16)
    }

    val sc = Module(new SliceCrop(padding))
    val mt = Module(new MatrTrans())

    sc.io.dest_addr := io.dest_addr

    mt.io.x0 := io.x0
    mt.io.x1 := io.x1
    mt.io.y0 := io.y0
    mt.io.y1 := io.y1

    mt.io.dstX := sc.io.x
    mt.io.dstY := sc.io.y

    io.src_addr := (UInt(640) * mt.io.srcY) + mt.io.srcX
}

class AddrTransTests(c: AddrTrans) extends Tester(c) {
    poke(c.io.x0, 0)
    poke(c.io.y0, 0)
    poke(c.io.x1, 252)
    poke(c.io.y1, 0)

    poke(c.io.dest_addr, 0)
    step(1)
    expect(c.io.src_addr, 0)

    poke(c.io.x0, 0)
    poke(c.io.y0, 0)
    poke(c.io.x1, 252)
    poke(c.io.y1, 0)

    poke(c.io.dest_addr, 784+28+10)
    step(1)
    expect(c.io.src_addr, 640+28+10)
}

object addrTrans {
    def main(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
            () => Module(new AddrTrans(0))){c => new AddrTransTests(c)}
    }
}
