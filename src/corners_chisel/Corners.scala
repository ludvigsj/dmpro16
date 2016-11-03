import Chisel._

import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import java.io.File
import java.awt.Color

class CornersModule extends Module {
  val io = new Bundle {
    val pxin = UInt(INPUT, width = 16)
    val x0= UInt(OUTPUT, width = 16)
    val x1= UInt(OUTPUT, width = 16)
    val y0= UInt(OUTPUT, width = 16)
    val y1= UInt(OUTPUT, width = 16)
    val x = UInt(OUTPUT, width = 16)
    val y = UInt(OUTPUT, width = 16)
  }

  val x = Reg(init=UInt(0, width = 16));
  val y = Reg(init=UInt(0, width = 16));
  val left, right, firstx, firsty = Reg(init=UInt(0, width = 16));
  val secondx, secondy = Reg(init=UInt(999, width = 16));
  val first = Reg(init=Bool(false));

  when(x === 639.U){
    y := y + 1.U;
    x := 0.U;
  }.otherwise{
    x := x + 1.U
  }

  when(io.pxin === UInt(1)){
    when(!first){
      firstx := x;
      firsty := y;
      first := Bool(true);
    }.otherwise{
      when(x < secondx){
        secondx := x;
        secondy := y;
      }
    }
  }

  io.x0 := firstx;
  io.y0 := firsty;
  io.x1 := secondx;
  io.y1 := secondy;

  io.x := x;
  io.y := y;

}

class CornersModuleTests(c: CornersModule) extends Tester(c) {
  val photo = ImageIO.read(new File("../../test_images/sudoku2_left_-39deg.bmp"));

  for (y <- 0 until 480)
  {
    for (x <- 0 until 640)
    {
      if((new Color(photo.getRGB(x, y))).getGreen() >= 128){
        poke(c.io.pxin, 1);
      }else{
        poke(c.io.pxin, 0);
      }
      step(1)
    }
  }

  expect(c.io.x0, 228)
  expect(c.io.y0, 44)

  expect(c.io.x1, 27)
  expect(c.io.y1, 207)


}

object corners {
  def main(args: Array[String]): Unit = {
    chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
       () => Module(new CornersModule())){c => new CornersModuleTests(c)}
  }
}
