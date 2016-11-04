package SudoKu

import Chisel._

/*
Transforms camera pixels to BNN pixels
*/
class Transformer(padding: Int) extends Module {
    val io = new Bundle {
        val enable = Bool(INPUT)
        val done = Bool(OUTPUT)
    }

    val matrix = MatrixTransformer(padding)
    val cam = CameraController()
    val imgmem = ImgMem()
    val corner = CornerFinder()

    cam.io.enable := io.enable
    corner.io.enable := cam.io.done
    matrix.io.enable := corner.io.done
    io.done := matrix.io.done

    val mux1 = Mux(cam.io.done, corner.io.addr, cam.io.addr)
    imgmem.io.addr := Mux(corner.io.done, matrix.io.src_addr, mux1)

    imgmem.io.in := cam.io.data
    imgmem.io.wen := cam.io.write && !cam.io.done

    corner.io.pixel := imgmem.io.out

    matrix.io.x0 := corner.io.x0
    matrix.io.y0 := corner.io.y0
    matrix.io.x1 := corner.io.x1
    matrix.io.y1 := corner.io.y1
}

class CameraController extends BlackBox {
    val io = new Bundle {
        val done = Bool(OUTPUT)
        val data = UInt(OUTPUT, 1)
        val enable = Bool(INPUT)
        val addr = UInt(OUTPUT, 20)
        val write = Bool(OUTPUT)
    }
}

class TransformerTests(c: Transformer) extends Tester(c) {

}

object transformer {
    def main(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
            () => Module(new Transformer(0))){c => new TransformerTests(c)}
    }
}
