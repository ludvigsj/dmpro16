package SudoKu

import Chisel._

/*
Memory unit for storing a 640 by 480 1-bit image

Author: Ludvig S. Jordet <ludvig.jordet@gmail.com>
Date: 2016-11-03
*/
class ImgMem() extends Module {
    val io = new Bundle {
        val addr = UInt(INPUT, 20)
        
        val out = UInt(OUTPUT, 1)
        val in = UInt(INPUT, 1)
        
        val wen = Bool(INPUT)
    }

    val out_reg = Reg(init = UInt(0, width=1))
    val mem = Mem(n=(640*480), out=UInt(width=1), seqRead=true) // Storing a VGA-sized bw image
    io.out := out_reg

    when(io.wen){
        mem(io.addr) := io.in
    } .otherwise {
        out_reg := mem(io.addr)
    }
}

class ImgMemTests(c: ImgMem) extends Tester(c) {
    poke(c.io.wen, true)    
    poke(c.io.addr, 0x12)
    poke(c.io.in, 1)
    step(1)
    poke(c.io.addr, 0xBC)
    poke(c.io.addr, 0)
    step(1)
    poke(c.io.wen, false)
    poke(c.io.addr, 0x12)
    step(1)
    expect(c.io.out, 1)
    poke(c.io.addr, 0xBC)
    step(1)
    expect(c.io.out, 0)
}

object imgMem {
    def main(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
            () => Module(new ImgMem())){c => new ImgMemTests(c)}
    }
}
