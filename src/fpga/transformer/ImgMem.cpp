#include "ImgMem.h"

void ImgMem_t::init ( val_t rand_init ) {
  this->__srand(rand_init);
  ImgMem__mem.randomize(&__rand_seed);
  clk.len = 1;
  clk.cnt = 0;
  clk.values[0] = 0;
}


int ImgMem_t::clock ( dat_t<1> reset ) {
  uint32_t min = ((uint32_t)1<<31)-1;
  if (clk.cnt < min) min = clk.cnt;
  clk.cnt-=min;
  if (clk.cnt == 0) clock_lo( reset );
  if (!reset.to_bool()) print( std::cerr );
  if (clk.cnt == 0) clock_hi( reset );
  if (clk.cnt == 0) clk.cnt = clk.len;
  return min;
}


void ImgMem_t::print ( FILE* f ) {
}
void ImgMem_t::print ( std::ostream& s ) {
}


void ImgMem_t::dump_init ( FILE* f ) {
}


void ImgMem_t::dump ( FILE* f, val_t t, dat_t<1> reset ) {
}




void ImgMem_t::clock_lo ( dat_t<1> reset, bool assert_fire ) {
  val_t T0;
  { T0 = ImgMem__io_addr.values[0];}
  T0 = T0 & 0x7ffffL;
  val_t T1;
  T1 = T0<0x4b000L;
  { T2.values[0] = ImgMem__io_wen.values[0] & T1;}
  { T3.values[0] = ImgMem__io_addr.values[0];}
  T3.values[0] = T3.values[0] & 0x7ffffL;
  val_t T4;
  { T4 = ImgMem__io_addr.values[0];}
  T4 = T4 & 0x7ffffL;
  val_t T5;
  { T5 = ImgMem__mem.get(T4, 0);}
  val_t T6;
  { T6 = ImgMem__io_wen.values[0] ^ 0x1L;}
  val_t T7;
  { T7 = TERNARY(T6, T5, 0x0L);}
  { ImgMem__io_out.values[0] = T7;}
}


void ImgMem_t::clock_hi ( dat_t<1> reset ) {
  { if (T2.values[0]) ImgMem__mem.put(T3.values[0], 0, ImgMem__io_in.values[0]);}
}


void ImgMem_api_t::init_sim_data (  ) {
  sim_data.inputs.clear();
  sim_data.outputs.clear();
  sim_data.signals.clear();
  ImgMem_t* mod = dynamic_cast<ImgMem_t*>(module);
  assert(mod);
  sim_data.inputs.push_back(new dat_api<20>(&mod->ImgMem__io_addr));
  sim_data.inputs.push_back(new dat_api<1>(&mod->ImgMem__io_in));
  sim_data.inputs.push_back(new dat_api<1>(&mod->ImgMem__io_wen));
  sim_data.outputs.push_back(new dat_api<1>(&mod->ImgMem__io_out));
  std::string ImgMem__mem_path = "ImgMem.mem";
  for (size_t i = 0 ; i < 307200 ; i++) {
    sim_data.signals.push_back(new dat_api<1>(&mod->ImgMem__mem.contents[i]));
    sim_data.signal_map[ImgMem__mem_path+"["+itos(i,false)+"]"] = 0+i;
  }
  sim_data.clk_map["clk"] = new clk_api(&mod->clk);
}
