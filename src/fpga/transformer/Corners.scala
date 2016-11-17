package SudoKu

import Chisel._

import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import java.io.File
import java.awt.Color

class CornersModule extends Module {
  // x0, y0 always outputs left corner. x1, y1 always outputs right corner.

  val io = new Bundle {
    val pxin = UInt(INPUT, width = 1)
    val x0= UInt(OUTPUT, width = 16)
    val x1= UInt(OUTPUT, width = 16)
    val y0= UInt(OUTPUT, width = 16)
    val y1= UInt(OUTPUT, width = 16)
    val enable = Bool(INPUT)
    val done = Bool(OUTPUT)
    val adr = UInt(OUTPUT, width = 20)
  }

  val x, y, firstx, firsty, secondy2,secondx2, rightestx, rightesty = Reg(init=UInt(0, width = 16));
  val secondx1, secondy1, leftestx, leftesty = Reg(init=UInt(999, width = 16));
  val first, firstFound = Reg(init=Bool(false));
  val x0temp, y0temp, x1temp, y1temp = Reg(init=UInt(0, width = 16));
  val pxin1 = Reg(next=io.pxin);
  val pxin2 = Reg(next=pxin1);
  val pxin3 = Reg(next=pxin2);




  val done = Reg(init=Bool(false));

  io.done := done;
  io.adr := y * 639.U + x;

  io.x0 := x0temp;
  io.y0 := y0temp;
  io.x1 := x1temp;
  io.y1 := y1temp;

  when(io.enable){
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

    done := Bool(false);
    first := Bool(false);
    secondx1 := 999.U;
    secondx2 := 0.U;
    rightestx := 0.U;
    leftestx := 999.U;
  }

  when(y === 479.U && x === 639.U){
    done := Bool(true);
  }

  when(first && !firstFound &&
    pxin3 === UInt(0) &&
    pxin2 === UInt(0) &&
    pxin1 === UInt(0) &&
    io.pxin === UInt(0) ){
      firstx := x - 1.U;
      firsty := y;
      firstFound := Bool(true);
  }

  when(pxin3 === UInt(1)){
    when(!first){
      first := Bool(true);
    }

    when(firstFound){

      /*when(x > secondx2 &&
        io.pxin1 === UInt(0) &&
        io.pxin2 === UInt(0) &&
        io.pxin3 === UInt(0)){

          secondx2 := x;
          secondy2 := y;
      }

      when(x > rightestx &&
        io.pxin1 === UInt(0) &&
        io.pxin2 === UInt(0) &&
        io.pxin3 === UInt(0)){

          rightestx := x;
          rightesty := y;
      }*/

      when(x < secondx1 &&
        pxin2 === UInt(1) &&
        pxin1 === UInt(1) &&
        io.pxin === UInt(1)){
          secondx1 := x;
          secondy1 := y;
      }

      when(x < leftestx &&
        pxin2 === UInt(1) &&
        pxin1 === UInt(1) &&
        io.pxin === UInt(1)){
          leftestx := x;
          leftesty := y;
      }

    }

  }

  when(x === 639.U){
    when(leftestx === firstx && leftesty > ( firsty + 5.U)){
      x0temp := firstx;
      y0temp := firsty;
      x1temp := secondx2;
      y1temp := secondy2;

      done := Bool(true);

    }


    when(rightestx < secondx2 && rightesty > (secondy2 + 5.U)){
      x0temp := firstx;
      y0temp := firsty;
      x1temp := secondx2;
      y1temp := secondy2;

      done := Bool(true);
    }

    when(leftestx > secondx1 && leftesty > (secondy1 + 5.U)){
      x0temp := secondx1 - 3.U;
      y0temp := secondy1;
      x1temp := firstx - 3.U;
      y1temp := firsty;

      done := Bool(true);
    }
  }

}

class CornersModuleTests(c: CornersModule) extends Tester(c) {
  var x,y, x0,y0,x1,y1 : Int = 0;
  var done : Boolean = false;

  val imagename : String = "foto3.jpg";
  x0 = 176;
  y0 = 86;
  x1 = 504;
  y1 = 60;

  /*val imagename : String = "foto6.jpg";
  x0 = 155;
  y0 = 70;
  x1 = 477;
  y1 = 99;*/

  /*val imagename : String = "foto2.jpg";
  x0 = 193;
  y0 = 92;
  x1 = 501;
  y1 = 89;*/

  poke(c.io.enable,true);

  val photo = ImageIO.read(new File("../../../test_images/" + imagename));

  while(!done){
    if((new Color(photo.getRGB(x, y))).getGreen()  >= 128){
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
