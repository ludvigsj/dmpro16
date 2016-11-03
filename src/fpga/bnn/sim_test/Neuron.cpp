#include "Neuron.h"

void Neuron_t::init ( val_t rand_init ) {
  this->__srand(rand_init);
  Neuron__acc.randomize(&__rand_seed);
  Neuron__outstore.randomize(&__rand_seed);
  clk.len = 1;
  clk.cnt = 0;
  clk.values[0] = 0;
}


int Neuron_t::clock ( dat_t<1> reset ) {
  uint32_t min = ((uint32_t)1<<31)-1;
  if (clk.cnt < min) min = clk.cnt;
  clk.cnt-=min;
  if (clk.cnt == 0) clock_lo( reset );
  if (!reset.to_bool()) print( std::cerr );
  if (clk.cnt == 0) clock_hi( reset );
  if (clk.cnt == 0) clk.cnt = clk.len;
  return min;
}


void Neuron_t::print ( FILE* f ) {
}
void Neuron_t::print ( std::ostream& s ) {
}


void Neuron_t::dump_init ( FILE* f ) {
}


void Neuron_t::dump ( FILE* f, val_t t, dat_t<1> reset ) {
}




void Neuron_t::clock_lo ( dat_t<1> reset, bool assert_fire ) {
  val_t T0;
  { T0 = TERNARY(Neuron__io_stcp.values[0], 0x0L, Neuron__acc.values[0]);}
  val_t T1;
  { T1 = Neuron__acc.values[0]+0x0L;}
  T1 = T1 & 0x3ffL;
  val_t T2;
  { T2 = Neuron__io_stcp.values[0] ^ 0x1L;}
  val_t T3;
  { T3 = TERNARY_1(T2, T1, T0);}
  { T4.values[0] = TERNARY(reset.values[0], 0x0L, T3);}
  val_t T5;
  T5 = 0xf9L<Neuron__acc.values[0];
  val_t T6;
  { T6 = TERNARY_1(Neuron__io_stcp.values[0], T5, Neuron__outstore.values[0]);}
  { T7.values[0] = TERNARY(reset.values[0], 0x0L, T6);}
  { Neuron__io_out.values[0] = Neuron__outstore.values[0];}
}


void Neuron_t::clock_hi ( dat_t<1> reset ) {
  dat_t<10> Neuron__acc__shadow = T4;
  dat_t<1> Neuron__outstore__shadow = T7;
  Neuron__acc = T4;
  Neuron__outstore = T7;
}


void Neuron_api_t::init_sim_data (  ) {
  sim_data.inputs.clear();
  sim_data.outputs.clear();
  sim_data.signals.clear();
  Neuron_t* mod = dynamic_cast<Neuron_t*>(module);
  assert(mod);
  sim_data.inputs.push_back(new dat_api<10>(&mod->Neuron__io_pixel_num));
  sim_data.inputs.push_back(new dat_api<1>(&mod->Neuron__io_in));
  sim_data.inputs.push_back(new dat_api<1>(&mod->Neuron__io_stcp));
  sim_data.outputs.push_back(new dat_api<1>(&mod->Neuron__io_out));
  sim_data.signals.push_back(new dat_api<10>(&mod->Neuron__acc));
  sim_data.signal_map["Neuron.acc"] = 0;
  sim_data.signals.push_back(new dat_api<1>(&mod->Neuron__outstore));
  sim_data.signal_map["Neuron.outstore"] = 1;
  sim_data.clk_map["clk"] = new clk_api(&mod->clk);
}
