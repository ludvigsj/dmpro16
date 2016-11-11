package SudoKu

import Chisel._

/*
Transforms camera pixels to BNN pixels
*/
class Transformer(padding: Int) extends Module {
    val io = new Bundle {
        val px_camera = UInt(INPUT, 1)
        val enable = Bool(INPUT)
        val done = Bool(OUTPUT)
        val px_out = UInt(OUTPUT, 1)
    }

    val matrix = Module(new MatrixTransformer(padding))
    val cam = Module(new CameraController())
    val imgmem = Module(new ImgMem())
    val corner = Module(new CornersModule())

    cam.io.enable := io.enable
    corner.io.enable := cam.io.done
    matrix.io.enable := corner.io.done
    io.done := matrix.io.done

    val mux1 = Mux(cam.io.done, corner.io.adr, cam.io.addr)
    imgmem.io.addr := Mux(corner.io.done, matrix.io.src_addr, mux1)

    cam.io.in := io.px_camera

    imgmem.io.in := cam.io.data
    imgmem.io.wen := cam.io.write && !cam.io.done

    corner.io.pxin := imgmem.io.out

    matrix.io.x0 := corner.io.x0
    matrix.io.y0 := corner.io.y0
    matrix.io.x1 := corner.io.x1
    matrix.io.y1 := corner.io.y1

    when(corner.io.done){
        io.px_out := imgmem.io.out
    } .otherwise {
        io.px_out := UInt(0)
    }
}

/* Bra modul ass */
class CameraController extends Module {
    val io = new Bundle {
        val done = Bool(OUTPUT)
        val data = UInt(OUTPUT, 1)
        val enable = Bool(INPUT)
        val addr = UInt(OUTPUT, 20)
        val write = Bool(OUTPUT)
        val in = UInt(INPUT, 1)
    }

    val current_addr = Reg(init=UInt(0, 20))
    val en = Bool()
    en := io.enable && (current_addr < UInt(640*480, width=20))
    io.data := io.in
    io.done := Bool(false)

    when (en){
        io.addr := current_addr
        io.write := Bool(true)
        current_addr := current_addr + UInt(1)
    } .otherwise {
        io.addr := UInt(0)
        io.write := Bool(false)
    }
    when (current_addr >= UInt(640*480, width=20)){
        io.done := Bool(true)
    }
}

class TransformerTests(c: Transformer) extends Tester(c) {

}

object transformer {
    def main(args: Array[String]): Unit = {
        //chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
        chiselMainTest(Array[String]("--backend", "v", "--targetDir", "verilog"),
            () => Module(new Transformer(0))){c => new TransformerTests(c)}
    }
}
