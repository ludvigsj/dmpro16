#include "MatrixTransformer.h"

void MatrixTransformer_t::init ( val_t rand_init ) {
  this->__srand(rand_init);
  MatrixTransformer__out_addr.randomize(&__rand_seed);
  clk.len = 1;
  clk.cnt = 0;
  clk.values[0] = 0;
}


int MatrixTransformer_t::clock ( dat_t<1> reset ) {
  uint32_t min = ((uint32_t)1<<31)-1;
  if (clk.cnt < min) min = clk.cnt;
  clk.cnt-=min;
  if (clk.cnt == 0) clock_lo( reset );
  if (!reset.to_bool()) print( std::cerr );
  if (clk.cnt == 0) clock_hi( reset );
  if (clk.cnt == 0) clk.cnt = clk.len;
  return min;
}


void MatrixTransformer_t::print ( FILE* f ) {
}
void MatrixTransformer_t::print ( std::ostream& s ) {
}


void MatrixTransformer_t::dump_init ( FILE* f ) {
}


void MatrixTransformer_t::dump ( FILE* f, val_t t, dat_t<1> reset ) {
}




void MatrixTransformer_t::clock_lo ( dat_t<1> reset, bool assert_fire ) {
  { MatrixTransformer_at__io_x0.values[0] = MatrixTransformer__io_x0.values[0];}
  { MatrixTransformer_at_mt__io_x0.values[0] = MatrixTransformer_at__io_x0.values[0];}
  val_t T0;
  { T0 = MatrixTransformer_at_mt__io_x0.values[0] | 0x0L << 16;}
  val_t T1;
  { T1 = MatrixTransformer__out_addr.values[0] | 0x0L << 16;}
  { MatrixTransformer_at__io_dest_addr.values[0] = T1;}
  { MatrixTransformer_at_sc__io_dest_addr.values[0] = MatrixTransformer_at__io_dest_addr.values[0];}
  val_t T2;
  *reinterpret_cast<dat_t<32>*>(&T2) = MatrixTransformer_at_sc__io_dest_addr / dat_t<5>(0x1c);
  val_t T3;
  *reinterpret_cast<dat_t<32>*>(&T3) = *reinterpret_cast<dat_t<32>*>(&T2) / dat_t<5>(0x1c);
  val_t T4;
  T4 = T3 * 0x1cL;
  val_t T5;
  { T5 = T4;}
  T5 = T5 & 0xffffffffL;
  val_t T6;
  { T6 = T2-T5;}
  T6 = T6 & 0xffffffffL;
  val_t T7;
  { T7 = T6 | 0x0L << 32;}
  val_t T8;
  *reinterpret_cast<dat_t<32>*>(&T8) = MatrixTransformer_at_sc__io_dest_addr / dat_t<10>(0x310);
  val_t T9;
  *reinterpret_cast<dat_t<32>*>(&T9) = *reinterpret_cast<dat_t<32>*>(&T8) / dat_t<4>(0x9);
  val_t T10;
  T10 = 0x1cL * T9;
  val_t T11;
  { T11 = T10+T7;}
  T11 = T11 & 0x1fffffffffL;
  val_t T12;
  { T12 = T11+0x0L;}
  T12 = T12 & 0x1fffffffffL;
  val_t T13;
  { T13 = T12;}
  T13 = T13 & 0xffffL;
  { MatrixTransformer_at_sc__io_y.values[0] = T13;}
  { MatrixTransformer_at_mt__io_dstY.values[0] = MatrixTransformer_at_sc__io_y.values[0];}
  { MatrixTransformer_at__io_y0.values[0] = MatrixTransformer__io_y0.values[0];}
  { MatrixTransformer_at_mt__io_y0.values[0] = MatrixTransformer_at__io_y0.values[0];}
  { MatrixTransformer_at__io_y1.values[0] = MatrixTransformer__io_y1.values[0];}
  { MatrixTransformer_at_mt__io_y1.values[0] = MatrixTransformer_at__io_y1.values[0];}
  val_t T14;
  { T14 = MatrixTransformer_at_mt__io_y1.values[0]-MatrixTransformer_at_mt__io_y0.values[0];}
  T14 = T14 & 0xffffL;
  val_t T15;
  T15 = T14 * MatrixTransformer_at_mt__io_dstY.values[0];
  val_t T16;
  *reinterpret_cast<dat_t<32>*>(&T16) = MatrixTransformer_at_sc__io_dest_addr / dat_t<5>(0x1c);
  val_t T17;
  T17 = T16 * 0x1cL;
  val_t T18;
  { T18 = T17;}
  T18 = T18 & 0xffffffffL;
  val_t T19;
  { T19 = MatrixTransformer_at_sc__io_dest_addr.values[0]-T18;}
  T19 = T19 & 0xffffffffL;
  val_t T20;
  { T20 = T19 | 0x0L << 32;}
  val_t T21;
  *reinterpret_cast<dat_t<32>*>(&T21) = *reinterpret_cast<dat_t<32>*>(&T8) / dat_t<4>(0x9);
  val_t T22;
  T22 = T21 * 0x9L;
  val_t T23;
  { T23 = T22;}
  T23 = T23 & 0xffffffffL;
  val_t T24;
  { T24 = T8-T23;}
  T24 = T24 & 0xffffffffL;
  val_t T25;
  T25 = 0x1cL * T24;
  val_t T26;
  { T26 = T25+T20;}
  T26 = T26 & 0x1fffffffffL;
  val_t T27;
  { T27 = T26+0x0L;}
  T27 = T27 & 0x1fffffffffL;
  val_t T28;
  { T28 = T27;}
  T28 = T28 & 0xffffL;
  { MatrixTransformer_at_sc__io_x.values[0] = T28;}
  { MatrixTransformer_at_mt__io_dstX.values[0] = MatrixTransformer_at_sc__io_x.values[0];}
  { MatrixTransformer_at__io_x1.values[0] = MatrixTransformer__io_x1.values[0];}
  { MatrixTransformer_at_mt__io_x1.values[0] = MatrixTransformer_at__io_x1.values[0];}
  val_t T29;
  { T29 = MatrixTransformer_at_mt__io_x1.values[0]-MatrixTransformer_at_mt__io_x0.values[0];}
  T29 = T29 & 0xffffL;
  val_t T30;
  T30 = T29 * MatrixTransformer_at_mt__io_dstX.values[0];
  val_t T31;
  { T31 = T30-T15;}
  T31 = T31 & 0xffffffffL;
  val_t T32;
  *reinterpret_cast<dat_t<32>*>(&T32) = *reinterpret_cast<dat_t<32>*>(&T31) / dat_t<8>(0xfc);
  val_t T33;
  { T33 = T32+T0;}
  T33 = T33 & 0xffffffffL;
  val_t T34;
  { T34 = T33;}
  T34 = T34 & 0xffffL;
  { MatrixTransformer_at_mt__io_srcX.values[0] = T34;}
  val_t T35;
  { T35 = MatrixTransformer_at_mt__io_srcX.values[0] | 0x0L << 16;}
  val_t T36;
  { T36 = MatrixTransformer_at_mt__io_y0.values[0] | 0x0L << 16;}
  val_t T37;
  { T37 = MatrixTransformer_at_mt__io_x1.values[0]-MatrixTransformer_at_mt__io_x0.values[0];}
  T37 = T37 & 0xffffL;
  val_t T38;
  T38 = T37 * MatrixTransformer_at_mt__io_dstY.values[0];
  val_t T39;
  { T39 = MatrixTransformer_at_mt__io_y1.values[0]-MatrixTransformer_at_mt__io_y0.values[0];}
  T39 = T39 & 0xffffL;
  val_t T40;
  T40 = T39 * MatrixTransformer_at_mt__io_dstX.values[0];
  val_t T41;
  { T41 = T40+T38;}
  T41 = T41 & 0xffffffffL;
  val_t T42;
  *reinterpret_cast<dat_t<32>*>(&T42) = *reinterpret_cast<dat_t<32>*>(&T41) / dat_t<8>(0xfc);
  val_t T43;
  { T43 = T42+T36;}
  T43 = T43 & 0xffffffffL;
  val_t T44;
  { T44 = T43;}
  T44 = T44 & 0xffffL;
  { MatrixTransformer_at_mt__io_srcY.values[0] = T44;}
  val_t T45;
  T45 = 0x280L * MatrixTransformer_at_mt__io_srcY.values[0];
  val_t T46;
  { T46 = T45+T35;}
  T46 = T46 & 0x3ffffffL;
  val_t T47;
  { T47 = T46 | 0x0L << 26;}
  { MatrixTransformer_at__io_src_addr.values[0] = T47;}
  val_t T48;
  { T48 = MatrixTransformer_at__io_src_addr.values[0];}
  T48 = T48 & 0xfffffL;
  { MatrixTransformer__io_src_addr.values[0] = T48;}
  val_t T49;
  { T49 = MatrixTransformer__out_addr.values[0]+0x1L;}
  T49 = T49 & 0xffffL;
  val_t T50;
  { T50 = TERNARY_1(MatrixTransformer__io_enable.values[0], T49, MatrixTransformer__out_addr.values[0]);}
  { T51.values[0] = TERNARY(reset.values[0], 0x0L, T50);}
}


void MatrixTransformer_t::clock_hi ( dat_t<1> reset ) {
  dat_t<16> MatrixTransformer__out_addr__shadow = T51;
  MatrixTransformer__out_addr = T51;
}


void MatrixTransformer_api_t::init_sim_data (  ) {
  sim_data.inputs.clear();
  sim_data.outputs.clear();
  sim_data.signals.clear();
  MatrixTransformer_t* mod = dynamic_cast<MatrixTransformer_t*>(module);
  assert(mod);
  sim_data.inputs.push_back(new dat_api<16>(&mod->MatrixTransformer__io_x0));
  sim_data.inputs.push_back(new dat_api<16>(&mod->MatrixTransformer__io_x1));
  sim_data.inputs.push_back(new dat_api<16>(&mod->MatrixTransformer__io_y0));
  sim_data.inputs.push_back(new dat_api<16>(&mod->MatrixTransformer__io_y1));
  sim_data.inputs.push_back(new dat_api<1>(&mod->MatrixTransformer__io_enable));
  sim_data.outputs.push_back(new dat_api<20>(&mod->MatrixTransformer__io_src_addr));
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at__io_x0));
  sim_data.signal_map["MatrixTransformer.at.io_x0"] = 0;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_x0));
  sim_data.signal_map["MatrixTransformer.at.mt.io_x0"] = 1;
  sim_data.signals.push_back(new dat_api<32>(&mod->MatrixTransformer_at__io_dest_addr));
  sim_data.signal_map["MatrixTransformer.at.io_dest_addr"] = 2;
  sim_data.signals.push_back(new dat_api<32>(&mod->MatrixTransformer_at_sc__io_dest_addr));
  sim_data.signal_map["MatrixTransformer.at.sc.io_dest_addr"] = 3;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_sc__io_y));
  sim_data.signal_map["MatrixTransformer.at.sc.io_y"] = 4;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_dstY));
  sim_data.signal_map["MatrixTransformer.at.mt.io_dstY"] = 5;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at__io_y0));
  sim_data.signal_map["MatrixTransformer.at.io_y0"] = 6;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_y0));
  sim_data.signal_map["MatrixTransformer.at.mt.io_y0"] = 7;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at__io_y1));
  sim_data.signal_map["MatrixTransformer.at.io_y1"] = 8;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_y1));
  sim_data.signal_map["MatrixTransformer.at.mt.io_y1"] = 9;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_sc__io_x));
  sim_data.signal_map["MatrixTransformer.at.sc.io_x"] = 10;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_dstX));
  sim_data.signal_map["MatrixTransformer.at.mt.io_dstX"] = 11;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at__io_x1));
  sim_data.signal_map["MatrixTransformer.at.io_x1"] = 12;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_x1));
  sim_data.signal_map["MatrixTransformer.at.mt.io_x1"] = 13;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_srcX));
  sim_data.signal_map["MatrixTransformer.at.mt.io_srcX"] = 14;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer_at_mt__io_srcY));
  sim_data.signal_map["MatrixTransformer.at.mt.io_srcY"] = 15;
  sim_data.signals.push_back(new dat_api<32>(&mod->MatrixTransformer_at__io_src_addr));
  sim_data.signal_map["MatrixTransformer.at.io_src_addr"] = 16;
  sim_data.signals.push_back(new dat_api<16>(&mod->MatrixTransformer__out_addr));
  sim_data.signal_map["MatrixTransformer.out_addr"] = 17;
  sim_data.clk_map["clk"] = new clk_api(&mod->clk);
}
