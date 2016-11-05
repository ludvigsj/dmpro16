import Chisel._

import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import java.io.File
import java.awt.Color

class CornersModule extends Module {
  // x0, y0 always outputs left corner. x1, y1 always outputs right corner.

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

  val x, y, firstx, firsty, secondy2,secondx2, rightestx, rightesty = Reg(init=UInt(0, width = 16));
  val secondx1, secondy1, leftestx, leftesty = Reg(init=UInt(999, width = 16));
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
      rightestx := 0.U;
      leftestx := 999.U
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
      first := Bool(true);
    }.otherwise{
      when(x < secondx1){
        secondx1 := x;
        secondy1 := y;
      }

      when(x > secondx2){
        secondx2 := x;
        secondy2 := y;
      }

      when(x < leftestx){
        leftestx := x;
        leftesty := y;
      }

      when(x > rightestx){
        rightestx := x;
        rightesty := y;
      }
    }
  }

  when(x === 479.U){
    when(leftestx === firstx){
      when(leftesty > ( firsty + 5.U)){
        x0temp := firstx;
        y0temp := firsty;
        x1temp := secondx2;
        y1temp := secondy2;

        done := 1.U;
      }
    }


    when(rightestx < secondx2){
      when(rightesty > (secondy2 + 5.U)){
        x0temp := firstx;
        y0temp := firsty;
        x1temp := secondx2;
        y1temp := secondy2;

        done := 1.U;
      }
    }

    when(leftestx > secondx1){
      when(leftesty > (secondy1 + 5.U)){
        x0temp := secondx1;
        y0temp := secondy1;
        x1temp := firstx;
        y1temp := firsty;

        done := 1.U;
      }
    }
  }

}

class CornersModuleTests(c: CornersModule) extends Tester(c) {
  var x,y, x0,y0,x1,y1 : Int = 0;
  var done : Boolean = false;

  /*val imagename : String = "sudoku2_middle.bmp";
  x0 = 180;
  y0 = 108;
  x1 = 439;
  y1 = 108;*/


  /*val imagename : String = "sudoku2_right_40deg.bmp";
  x0 = 392;
  y0 = 60;
  x1 = 592;
  y1 = 226;*/


  val imagename : String = "sudoku2_left_-39deg.bmp";
  x0 = 27;
  y0 = 207;
  x1 = 228;
  y1 = 44;


  poke(c.io.enable,1);

  val photo = ImageIO.read(new File("../../../test_images/" + imagename));

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

  expect(c.io.done, 1)
  expect(c.io.x0, x0)
  expect(c.io.y0, y0)
  expect(c.io.x1, x1)
  expect(c.io.y1, y1)

}

object corners {
  def main(args: Array[String]): Unit = {
    chiselMainTest(Array[String]("--backend", "c", "--compile", "--test", "--genHarness"),
       () => Module(new CornersModule())){c => new CornersModuleTests(c)}
  }
}
