package SudoKu.bnn

import Chisel._
import scala.collection.mutable.ArrayBuffer

object Thresholds {
  def readCSV(filename:String) : Array[Array[UInt]] = {
    var rows:Array[Array[UInt]] = Array.empty
    val source = io.Source.fromFile(filename)
    for (line <- source.getLines) {
      val row = line.split(",").map(_.trim).map(_.toInt).map(x => UInt(x))
      rows = rows :+ row
    }
    rows
  }
  val t = readCSV("./thresholds.csv")
}

object Weights {
  //def readCSV(filename:String) : Array[Bits] = {
  def readCSV(filename:String) : Array[String] = {
    var rows:Array[String] = Array.empty
    val source = io.Source.fromFile(filename)
    for (line <- source.getLines) {
      val row:String = line.trim
      rows = rows :+ row
    }
    //rows.map(x => Bits(x))
    return rows
  }

  def getW(): Array[Array[String]] = {
      return Array( readCSV("./weights0.csv"), readCSV("./weights1.csv"), readCSV("./weights2.csv"), readCSV("./weights3.csv"), readCSV("./weights0.csv"))
  }

 def getWforLayer(i: Int): Array[String] = {
     val ww = getW()
     return ww(i)
 }

  //val w = Array( readCSV("./weights0.csv"), readCSV("./weights1.csv"), readCSV("./weights2.csv"), readCSV("./weights3.csv"))
}


object TestThresholds {
  // Thresholds.t[layer][neuron]
  val t =
  Array(
    Array(UInt(1), UInt(2), UInt(1)),
    Array(UInt(2), UInt(1), UInt(1)),
    Array(UInt(3), UInt(1), UInt(3))
  )
}

object TestWeights {
  // Weights.w[layer][neuron][synapse]
  val w =
  Array(
    Array(
      Array(Bits(0),Bits(0),Bits(0),Bits(0)),
      Array(Bits(0),Bits(0),Bits(1),Bits(1)),
      Array(Bits(0),Bits(1),Bits(0),Bits(0))
    ),
    Array(
      Array(Bits(0),Bits(0),Bits(0)),
      Array(Bits(0),Bits(1),Bits(1)),
      Array(Bits(0),Bits(1),Bits(0))
    ),
    Array(
      Array(Bits(1),Bits(1),Bits(0)),
      Array(Bits(0),Bits(1),Bits(0)),
      Array(Bits(0),Bits(1),Bits(1))
    )
  )
}
