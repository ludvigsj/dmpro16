package SudoKu.bnn

import Chisel._

class Neuron extends Module {
    val io = new Bundle {
        val pixel_num = UInt(INPUT, 10)
        val in = Bool(INPUT)
        val out = Bool(OUTPUT)
        val stcp = Bool(INPUT)
    }
    
	val preload_w = Array(
        Bool(true),
        Bool(false),
        Bool(false),
        Bool(true)
    )


    val t = UInt()
    t := UInt(249, 10)
    val w = Vec(preload_w)
    val acc = Reg(init=UInt(0, 10))
    val outstore = Reg(init=Bool(false))
    /*when(io.stcp){
        outstore := acc > t
        acc := UInt(0)
    } .otherwise {*/
    acc := acc + io.in
    io.out := outstore
}

class NeuronTest(c: Neuron) extends Tester(c) {
    
}

object neuron {
    def main(args: Array[String]): Unit = {
        val gen_args =
        //Array("--backend", "c", "--genHarness", "--compile", "--test", "--targetDir", "sim_test")
        //Array("--backend", "v", "--targetDir", "verilog")
        Array("--backend", "dot", "--targetDir", "dot")
        chiselMainTest(
            gen_args, 
            () => Module(new Neuron())) { c => new NeuronTest(c) }
    }
}


