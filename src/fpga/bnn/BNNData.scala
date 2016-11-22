package SudoKu.bnn

import Chisel._
import scala.collection.mutable.ArrayBuffer
import scala.collection.mutable.ListBuffer

object Test_image {
  def readCSV(filename:String) : List[Bits] = {
    var rows:List[Bits] = List.empty
    val source = io.Source.fromFile(filename)
    for (line <- source.getLines) {
      val row:List[Bits] = line.split(",")
            .map(_.trim)
            .map(_.toInt)
            .map(x => Bits(x, width=1)).toList
      rows = row
    }
    rows
  }
  val data = readCSV("./test_values.csv")
}

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

// Perhaps rotate matrix 90 deg
object Weights {
  def readCSV(filename:String) : Array[Bits] = {
    var rows:Array[Bits] = Array.empty
    val source = io.Source.fromFile(filename)
    for (line <- source.getLines) {
      val row:Array[Bits] = line.split(",")
            .map(_.trim)
            .map(_.toInt)
            .map(x => Bits(x, width=1)).toArray
            //.map(Bits(_))
            //.map(x => Reg(init=(x)))

      var bits:Bits = row.reduceLeft( Cat(_,_))
      rows = rows ++ bits
    }
    rows
  }

  val w = Array( readCSV("./weights0.csv"), readCSV("./weights1.csv"), readCSV("./weights2.csv"), readCSV("./weights3.csv"))
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
