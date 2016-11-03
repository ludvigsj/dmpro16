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
  }

  val x, y, left, right, firstx, firsty, secondx2, secondy2 = Reg(init=UInt(0, width = 16));
  val secondx1, secondy1 = Reg(init=UInt(999, width = 16));
  val first = Reg(init=Bool(false));
  val x0temp, y0temp, x1temp, y1temp = Reg(init=UInt(0, width = 16));

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
      when(x < secondx1){
        secondx1 := x;
        secondy1 := y;
      }.elsewhen(x > secondx2){
        secondx2 := x;
        secondy2 := y;
      }
    }
  }

  when(secondy2 < secondy1){
    when(secondx2 < firstx){
      x0temp := firstx;
      y0temp := firsty;
      x1temp := secondx2;
      y1temp := secondy2;
    }.otherwise{
      x0temp := firstx;
      y0temp := firsty;
      x1temp := secondx2;
      y1temp:= secondy2;
    }
  }.otherwise{
    when(secondx1 <= firstx){
      x0temp := firstx;
      y0temp := firsty;
      x1temp := secondx1;
      y1temp := secondy1;
    }.otherwise{
      x0temp := firstx;
      y0temp := firsty;
      x1temp := secondx1;
      y1temp := secondy1;
    }

  }

  io.x0 := x0temp;
  io.y0 := y0temp;
  io.x1 := x1temp;
  io.y1 := y1temp;

}

class CornersModuleTests(c: CornersModule) extends Tester(c) {
  val photo = ImageIO.read(new File("../../test_images/sudoku2_middle.bmp"));
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
  expect(c.io.x0, 180)
  expect(c.io.y0, 108)
  expect(c.io.x1, 439)
  expect(c.io.y1, 108)



}

object corners {
  def main(args: Array[String]): Unit = {
    chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
       () => Module(new CornersModule())){c => new CornersModuleTests(c)}
  }
}
