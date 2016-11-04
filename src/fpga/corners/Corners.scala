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
    val enable = UInt(INPUT, width = 1)
    val done = UInt(OUTPUT, width = 1)
    val adr = UInt(OUTPUT, width = 20)
  }

  val x, y, firstx, firsty, secondy2,secondx2= Reg(init=UInt(0, width = 16));
  val secondx1, secondy1 = Reg(init=UInt(999, width = 16));
  val first = Reg(init=Bool(false));
  val x0temp, y0temp, x1temp, y1temp = Reg(init=UInt(0, width = 16));

  val done = Reg(init=UInt(0, width = 1));

  io.done := done;
  io.adr := y * 639.U + x;

  io.x0 := x0temp;
  io.y0 := y0temp;
  io.x1 := x1temp;
  io.y1 := y1temp;

  when(io.enable === 1.U){
    when(x === 639.U){
      y := y + 1.U;
      x := 0.U;
    }.otherwise{
      x := x + 1.U
    }
  }.otherwise{
    x := 0.U;
    y := 0.U;

    done := 0.U;
    first := Bool(false);
    secondx1 := 999.U;
    secondx2 := 0.U;
  }

  when(y === 479.U){
    when(x === 639.U){
      done := 1.U;
    }
  }


  when(io.pxin === UInt(1)){
    when(!first){
      firstx := x;
      firsty := y;
      secondx1 := x;
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

}

class CornersModuleTests(c: CornersModule) extends Tester(c) {
  val photo = ImageIO.read(new File("../../../test_images/sudoku2_right_40deg.bmp"));
  var x,y : Int = 0;
  var done : Boolean = false;

  poke(c.io.enable,1);

  while(!done){
    if((new Color(photo.getRGB(x, y))).getGreen() >= 128){
      poke(c.io.pxin, 1);
    }else{
      poke(c.io.pxin, 0);
    }
    step(1)

    if(x == 639){
      y = y + 1;
      x = 0;
    }else{
      x = x + 1;
    }

    if(peek(c.io.done) == 1) {
      done = true;
    }
  }

  /*for (y <- 0 until 480)
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
  }*/

  expect(c.io.done, 1)
  expect(c.io.x0, 392)
  expect(c.io.y0, 60)
  expect(c.io.x1, 592)
  expect(c.io.y1, 226)



}

object corners {
  def main(args: Array[String]): Unit = {
    chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
       () => Module(new CornersModule())){c => new CornersModuleTests(c)}
  }
}
