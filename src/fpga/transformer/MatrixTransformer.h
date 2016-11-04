#ifndef __MatrixTransformer__
#define __MatrixTransformer__

#include "emulator.h"

class MatrixTransformer_t : public mod_t {
 private:
  val_t __rand_seed;
  void __srand(val_t seed) { __rand_seed = seed; }
  val_t __rand_val() { return ::__rand_val(&__rand_seed); }
 public:
  dat_t<1> MatrixTransformer__io_enable;
  dat_t<1> reset;
  dat_t<16> MatrixTransformer__io_x0;
  dat_t<16> MatrixTransformer_at__io_x0;
  dat_t<16> MatrixTransformer_at_mt__io_x0;
  dat_t<16> MatrixTransformer_at_sc__io_y;
  dat_t<16> MatrixTransformer_at_mt__io_dstY;
  dat_t<16> MatrixTransformer__io_y0;
  dat_t<16> MatrixTransformer_at__io_y0;
  dat_t<16> MatrixTransformer_at_mt__io_y0;
  dat_t<16> MatrixTransformer__io_y1;
  dat_t<16> MatrixTransformer_at__io_y1;
  dat_t<16> MatrixTransformer_at_mt__io_y1;
  dat_t<16> MatrixTransformer_at_sc__io_x;
  dat_t<16> MatrixTransformer_at_mt__io_dstX;
  dat_t<16> MatrixTransformer__io_x1;
  dat_t<16> MatrixTransformer_at__io_x1;
  dat_t<16> MatrixTransformer_at_mt__io_x1;
  dat_t<16> MatrixTransformer_at_mt__io_srcX;
  dat_t<16> MatrixTransformer_at_mt__io_srcY;
  dat_t<16> T51;
  dat_t<16> MatrixTransformer__out_addr;
  dat_t<20> MatrixTransformer__io_src_addr;
  dat_t<32> MatrixTransformer_at__io_dest_addr;
  dat_t<32> MatrixTransformer_at_sc__io_dest_addr;
  dat_t<32> MatrixTransformer_at__io_src_addr;
  clk_t clk;

  void init ( val_t rand_init = 0 );
  void clock_lo ( dat_t<1> reset, bool assert_fire=true );
  void clock_hi ( dat_t<1> reset );
  int clock ( dat_t<1> reset );
  void print ( FILE* f );
  void print ( std::ostream& s );
  void dump ( FILE* f, val_t t, dat_t<1> reset=LIT<1>(0) );
  void dump_init ( FILE* f );

};

#include "emul_api.h"
class MatrixTransformer_api_t : public emul_api_t {
 public:
  MatrixTransformer_api_t(mod_t* m) : emul_api_t(m) { }
  void init_sim_data();
};

#endif
