package SudoKu

import Chisel._

/*
Computes address of source image bit which is to be put at specific destination
image bit address, given the coordinates x0, x1, y0 and y1
*/
class SliceCrop(padding: Int) extends Module {
    val io = new Bundle {
        val dest_addr = UInt(INPUT, 32)
        val x = UInt(OUTPUT, 16)
        val y = UInt(OUTPUT, 16)
    }

    val sliceNum = UInt()
    val sliceX = UInt()
    val sliceY = UInt()

    sliceNum := io.dest_addr / UInt(784) // 784 = 28*28
    sliceY := (io.dest_addr / UInt(28)) % UInt(28)
    sliceX := io.dest_addr % UInt(28)

    val destX = UInt()
    val destY = UInt()

    io.x := UInt(28+(padding*2))*(sliceNum % UInt(9)) + sliceX + UInt(padding)
    io.y := UInt(28+(padding*2))*(sliceNum / UInt(9)) + sliceY + UInt(padding)

}

class SliceCropTests(c: SliceCrop) extends Tester(c) {
    poke(c.io.dest_addr, 0)
    step(1)
    expect(c.io.x, 0)
    expect(c.io.y, 0)

    poke(c.io.dest_addr, 26)
    step(1)
    expect(c.io.x, 26)
    expect(c.io.y, 0)

    poke(c.io.dest_addr, (28*13) + 23)
    step(1)
    expect(c.io.x, 23)
    expect(c.io.y, 13)

    poke(c.io.dest_addr, (784*3) + (28*7) + 15)
    step(1)
    expect(c.io.x, 28*3 + 15)
    expect(c.io.y, 7)

    poke(c.io.dest_addr, (784*10) + (28*3) + 18)
    step(1)
    expect(c.io.x, 28 + 18)
    expect(c.io.y, 28 + 3)
}

object sliceCrop {
    def main(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
            () => Module(new SliceCrop(0))){c => new SliceCropTests(c)}
    }
}
