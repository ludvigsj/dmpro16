package SudoKu

import Chisel._
import java.nio.file.{Files, Paths}
import java.io.FileOutputStream
import scala.collection.mutable.ArrayBuffer

/*
Transforms camera pixels to BNN pixels
*/
class Transformer(padding: Int) extends Module {
    val io = new Bundle {
        val cam_read  = Bool(OUTPUT)
        val cam_data  = UInt(INPUT, 1)
        val cam_empty = Bool(INPUT)

        val bnn_write = Bool(OUTPUT)
        val bnn_data  = UInt(OUTPUT, 1)
        val bnn_full  = Bool(INPUT)
    }

    val matrix = Module(new MatrixTransformer(padding))
    val imgmem = Module(new ImgMem())
    val corner = Module(new CornersModule())

    val pixel = Reg(init=UInt(0, width=20))
    val loaded = Reg(init=Bool(false))

    corner.io.enable := loaded

    val mux1 = Mux(loaded, corner.io.adr, pixel)
    imgmem.io.addr := Mux(corner.io.done, matrix.io.src_addr, mux1)
    imgmem.io.wen := Bool(false)

    val reading = Reg(init=Bool(false))

    when(!loaded && !io.cam_empty){
        reading := Bool(true)
        io.cam_read := Bool(true)
    } .otherwise {
        reading := Bool(false)
        io.cam_read := Bool(false)
    }

    when(reading){
        imgmem.io.wen := Bool(true)
        pixel := pixel + UInt(1)
    } .otherwise {
        imgmem.io.wen := Bool(false)
    }

    when(reading && pixel >= UInt(307200)){
        loaded := Bool(true)
    }

    imgmem.io.in := io.cam_data

    corner.io.pxin := imgmem.io.out

    matrix.io.x0 := corner.io.x0
    matrix.io.y0 := corner.io.y0
    matrix.io.x1 := corner.io.x1
    matrix.io.y1 := corner.io.y1
    //matrix.io.x0 := UInt(166)
    //matrix.io.y0 := UInt(78)
    //matrix.io.x1 := UInt(425)
    //matrix.io.y1 := UInt(100)

    val writing = Reg(init=Bool(false))
    val done = Reg(init=Bool(false))

    when(corner.io.done){
        writing := Bool(true)
        pixel := UInt(0)
    }

    matrix.io.dest_addr := pixel
    io.bnn_data := imgmem.io.out

    when(writing && !io.bnn_full && !done){
        io.bnn_write := Bool(true)
        pixel := pixel + UInt(1)
    } .otherwise {
        io.bnn_write := Bool(false)
    }

    when(writing && pixel >= UInt(63504)){
        done := Bool(true)
    }
}

class TransformerTests(c: Transformer) extends Tester(c) {
    poke(c.io.cam_empty, false)
    poke(c.io.bnn_full, false)
    var f = 0
    var i = 0
    for(f <- 0 until 1){
        val byteArray = Files.readAllBytes(Paths.get("../../../test_images/foto7.gray"))
        var outBytes = ArrayBuffer[Byte]()
        for(i <- 0 until byteArray.length){
            poke(c.io.cam_data, if ((byteArray(i) & 0xff) < 32) 0 else 1)
            //outBytes += (if((byteArray(i) & 0xff) < 32) 0.toByte else 255.toByte)
            step(1)
            expect(c.pixel, i)
        }
        while(peek(c.io.bnn_write) == 0){
            step(1)
        }

        expect(c.corner.io.done, 1)
        expect(c.corner.io.x0, 106)
        expect(c.corner.io.y0, 103)
        expect(c.corner.io.x1, 443)
        expect(c.corner.io.y1, 29)
        while(peek(c.io.bnn_write) == 1){
            outBytes += (if (peek(c.io.bnn_data) == 1) 255.toByte else 0.toByte)
            step(1)
        }
        //for(i <- 0 until outBytes.length){
            //if(outBytes(i) != 0) println(outBytes(i))
        //}
        val fos = new FileOutputStream("output.gray")
        fos.write(outBytes.toArray)
        fos.close()
    }
}

object transformer {
    def main(args: Array[String]): Unit = {
        chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
        //chiselMainTest(Array[String]("--backend", "v", "--targetDir", "verilog"),
            () => Module(new Transformer(0))){c => new TransformerTests(c)}
    }
}
