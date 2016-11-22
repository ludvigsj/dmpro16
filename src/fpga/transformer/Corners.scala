package SudoKu

import Chisel._

import java.nio.file.{Files, Paths}

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

  val x, y, firstx, firsty, secondy2,secondx2, rightestx, rightesty = Reg(init=UInt(0, width = 16))
  val secondx1, secondy1, leftestx, leftesty = Reg(init=UInt(999, width = 16))
  val firstLeft, firstRight, firstFound = Reg(init=Bool(false))
  val x0temp, y0temp, x1temp, y1temp = Reg(init=UInt(0, width = 16))
  val pxin1 = Reg(next=io.pxin)
  val pxin2 = Reg(next=pxin1)
  val pxin3 = Reg(next=pxin2)

  val done = Reg(init=Bool(false))
  val enableDelay = Reg(next=io.enable)

  io.done := done
  io.adr := 0.U
  io.adr := (y * 640.U + x)

  io.x0 := x0temp
  io.y0 := y0temp
  io.x1 := x1temp
  io.y1 := y1temp

  when(io.enable){
    when(!done){
      when(x === 639.U){
        y := y + 1.U
        x := 0.U
        rightestx := 0.U
        leftestx := 999.U
      }.otherwise{
        x := x + 1.U
      }
    }
  }.otherwise{
    x := 0.U
    y := 0.U

    done := Bool(false)
    firstLeft := Bool(false)
    firstRight := Bool(false)
    secondx1 := 999.U
    secondx2 := 0.U
    rightestx := 0.U
    leftestx := 999.U
  }

  when(y === 479.U && x === 639.U){
    done := Bool(true)
  }

  when(firstRight && !firstFound &&
    pxin3 === UInt(0) &&
    pxin2 === UInt(0) &&
    pxin1 === UInt(0) &&
    io.pxin === UInt(0) ){
      firstx := x - 1.U
      firsty := y
      firstFound := Bool(true)
  }.elsewhen(firstLeft && !firstFound){
    firstx := x
    firsty := y
    firstFound := Bool(true)
  }

  when(pxin3 === UInt(1)){
    when(!firstLeft && !firstRight){
      when(x < 640.U/2.U){
        firstLeft := Bool(true)
      }.otherwise{
        firstRight := Bool(true)
      }
    }

    when(firstFound){

      when(firstLeft){
        when(x > secondx2 &&
          pxin2 === UInt(0) &&
          pxin1 === UInt(0) &&
          io.pxin === UInt(0)){

            secondx2 := x
            secondy2 := y
        }

        when(x > rightestx &&
          pxin2 === UInt(0) &&
          pxin1 === UInt(0) &&
          io.pxin === UInt(0)){

            rightestx := x
            rightesty := y
        }
      }.elsewhen(firstRight){
        when(x < secondx1 &&
          pxin2 === UInt(1) &&
          pxin1 === UInt(1) &&
          io.pxin === UInt(1)){
            secondx1 := x
            secondy1 := y
        }

        when(x < leftestx &&
          pxin2 === UInt(1) &&
          pxin1 === UInt(1) &&
          io.pxin === UInt(1)){
            leftestx := x
            leftesty := y
        }
      }
    }
  }

  when(x === 639.U){

    when(firstLeft){

      when(rightesty === secondy2 && firsty === secondy2 && secondx2 > (firstx + 40.U)){
        x0temp := firstx - 3.U
        y0temp := firsty
        x1temp := secondx2 - 3.U
        y1temp := firsty

        done := Bool(true)
      }

      when(rightestx < secondx2 && rightesty > (secondy2 + 5.U)){
        x0temp := firstx - 3.U
        y0temp := firsty
        x1temp := secondx2 - 3.U
        y1temp := secondy2

        done := Bool(true)
      }

    }.elsewhen(firstRight){

      when(leftestx > secondx1 && leftesty > (secondy1 + 5.U)){
        x0temp := secondx1 - 3.U
        y0temp := secondy1
        x1temp := firstx - 3.U
        y1temp := firsty

        done := Bool(true)
      }
    }
  }
}

class CornersModuleTests(c: CornersModule) extends Tester(c) {
  var i, x0,y0,x1,y1 : Int = 0
  var done : Boolean = false

  /*val imagename : String = "foto2.gray"
  x0 = 193
  y0 = 91
  x1 = 501
  y1 = 89*/

  /*val imagename : String = "foto3.gray"
  x0 = 176
  y0 = 86
  x1 = 504
  y1 = 60*/

  //White pixel in the middle of nothing makes this give wrong output
  /*val imagename : String = "foto4.gray"
  x0 = 191
  y0 = 91
  x1 = 496
  y1 = 87*/

  /*val imagename : String = "foto5.gray"
  x0 = 154
  y0 = 86
  x1 = 472
  y1 = 86*/

  /*val imagename : String = "foto6.gray"
  x0 = 155
  y0 = 70
  x1 = 477
  y1 = 99*/

  val imagename : String = "foto7.gray"
  x0 = 106
  y0 = 103
  x1 = 443
  y1 = 29


  poke(c.io.enable,true)
  val byteArray = Files.readAllBytes(Paths.get("../../../test_images/" + imagename))

  while(!done){
    expect(c.io.adr, i)

    poke(c.io.pxin, if ((byteArray(i) & 0xff) < 32) 0 else 1)
    step(1)
    i = i + 1

    if(peek(c.io.done) == 1) {
      done = true
    }

  }

  val byteArray2 = Files.readAllBytes(Paths.get("../../../test_images/foto2.gray"))

  var x = 0

  for(x <- 0 until 307200){
    poke(c.io.pxin, if ((byteArray2(x) & 0xff) < 32) 0 else 1)
  }


  step(100)

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
