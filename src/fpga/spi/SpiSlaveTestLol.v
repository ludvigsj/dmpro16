module SpiShiftRegister(input clk, input reset,
    input  io_in,
    input  io_shift,
    input [7:0] io_value,
    input  io_set,
    output io_out
);

  reg  r7;
  wire T0;
  wire T1;
  wire T2;
  wire T3;
  wire T4;
  wire T5;
  reg  r6;
  wire T6;
  wire T7;
  wire T8;
  wire T9;
  reg  r5;
  wire T10;
  wire T11;
  wire T12;
  wire T13;
  reg  r4;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  reg  r3;
  wire T18;
  wire T19;
  wire T20;
  wire T21;
  reg  r2;
  wire T22;
  wire T23;
  wire T24;
  wire T25;
  reg  r1;
  wire T26;
  wire T27;
  wire T28;
  wire T29;
  reg  r0;
  wire T30;
  wire T31;
  wire T32;
  wire T33;
  wire T34;
  wire T35;
  wire T36;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    r7 = {1{$random}};
    r6 = {1{$random}};
    r5 = {1{$random}};
    r4 = {1{$random}};
    r3 = {1{$random}};
    r2 = {1{$random}};
    r1 = {1{$random}};
    r0 = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_out = r7;
  assign T0 = T34 ? r6 : T1;
  assign T1 = T4 ? T3 : T2;
  assign T2 = reset ? 1'h0 : r7;
  assign T3 = io_value[7];
  assign T4 = T5 & io_set;
  assign T5 = reset ^ 1'h1;
  assign T6 = T34 ? r5 : T7;
  assign T7 = T4 ? T9 : T8;
  assign T8 = reset ? 1'h0 : r6;
  assign T9 = io_value[6];
  assign T10 = T34 ? r4 : T11;
  assign T11 = T4 ? T13 : T12;
  assign T12 = reset ? 1'h0 : r5;
  assign T13 = io_value[5];
  assign T14 = T34 ? r3 : T15;
  assign T15 = T4 ? T17 : T16;
  assign T16 = reset ? 1'h0 : r4;
  assign T17 = io_value[4];
  assign T18 = T34 ? r2 : T19;
  assign T19 = T4 ? T21 : T20;
  assign T20 = reset ? 1'h0 : r3;
  assign T21 = io_value[3];
  assign T22 = T34 ? r1 : T23;
  assign T23 = T4 ? T25 : T24;
  assign T24 = reset ? 1'h0 : r2;
  assign T25 = io_value[2];
  assign T26 = T34 ? r0 : T27;
  assign T27 = T4 ? T29 : T28;
  assign T28 = reset ? 1'h0 : r1;
  assign T29 = io_value[1];
  assign T30 = T34 ? io_in : T31;
  assign T31 = T4 ? T33 : T32;
  assign T32 = reset ? 1'h0 : r0;
  assign T33 = io_value[0];
  assign T34 = T35 & io_shift;
  assign T35 = T36 ^ 1'h1;
  assign T36 = reset | io_set;

  always @(posedge clk) begin
    if(T34) begin
      r7 <= r6;
    end else if(T4) begin
      r7 <= T3;
    end else if(reset) begin
      r7 <= 1'h0;
    end
    if(T34) begin
      r6 <= r5;
    end else if(T4) begin
      r6 <= T9;
    end else if(reset) begin
      r6 <= 1'h0;
    end
    if(T34) begin
      r5 <= r4;
    end else if(T4) begin
      r5 <= T13;
    end else if(reset) begin
      r5 <= 1'h0;
    end
    if(T34) begin
      r4 <= r3;
    end else if(T4) begin
      r4 <= T17;
    end else if(reset) begin
      r4 <= 1'h0;
    end
    if(T34) begin
      r3 <= r2;
    end else if(T4) begin
      r3 <= T21;
    end else if(reset) begin
      r3 <= 1'h0;
    end
    if(T34) begin
      r2 <= r1;
    end else if(T4) begin
      r2 <= T25;
    end else if(reset) begin
      r2 <= 1'h0;
    end
    if(T34) begin
      r1 <= r0;
    end else if(T4) begin
      r1 <= T29;
    end else if(reset) begin
      r1 <= 1'h0;
    end
    if(T34) begin
      r0 <= io_in;
    end else if(T4) begin
      r0 <= T33;
    end else if(reset) begin
      r0 <= 1'h0;
    end
  end
endmodule

module SpiSlave(input clk, input reset,
    input  io_cs,
    input  io_clk,
    input  io_mosi,
    output io_miso,
    output io_wake,
    output io_bnn_read,
    input [9:0] io_bnn_data,
    input  io_bnn_empty
);

  wire T0;
  reg  read;
  wire T68;
  wire T1;
  wire T2;
  wire T3;
  wire T4;
  wire T5;
  wire T6;
  wire T7;
  reg [2:0] n;
  wire[2:0] T69;
  wire[2:0] T8;
  wire[2:0] T9;
  wire[2:0] T10;
  wire T11;
  wire T12;
  reg  R13;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  wire T18;
  reg  R19;
  wire T20;
  wire[7:0] T70;
  wire[3:0] T21;
  wire[3:0] T22;
  wire[3:0] T71;
  wire[2:0] T23;
  wire[2:0] T24;
  wire[2:0] T25;
  wire[2:0] T26;
  wire[2:0] T72;
  wire[1:0] T27;
  wire[1:0] T28;
  wire[1:0] T73;
  wire T29;
  wire T30;
  wire T31;
  wire T32;
  wire T33;
  wire T34;
  wire T35;
  wire T36;
  wire T37;
  wire T38;
  wire T39;
  wire T40;
  wire T41;
  wire T42;
  wire T43;
  wire T44;
  wire T45;
  wire T46;
  wire T47;
  wire T48;
  wire T49;
  wire T50;
  wire T51;
  wire T52;
  wire T53;
  wire T54;
  wire T55;
  wire T56;
  wire T57;
  wire T58;
  wire T59;
  wire T60;
  wire T61;
  wire T62;
  wire T63;
  wire T64;
  wire T65;
  wire T66;
  wire T67;
  wire reg__io_out;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    read = {1{$random}};
    n = {1{$random}};
    R13 = {1{$random}};
    R19 = {1{$random}};
  end
// synthesis translate_on
`endif

  assign T0 = read ? 1'h1 : 1'h0;
  assign T68 = reset ? 1'h0 : T1;
  assign T1 = T18 ? 1'h1 : T2;
  assign T2 = read ? 1'h0 : T3;
  assign T3 = T17 ? 1'h0 : T4;
  assign T4 = T15 ? 1'h0 : T5;
  assign T5 = T6 ? 1'h1 : read;
  assign T6 = T11 & T7;
  assign T7 = n == 3'h7;
  assign T69 = reset ? 3'h0 : T8;
  assign T8 = T15 ? T10 : T9;
  assign T9 = T6 ? 3'h0 : n;
  assign T10 = n + 3'h1;
  assign T11 = io_cs & T12;
  assign T12 = T14 & R13;
  assign T14 = io_clk ^ 1'h1;
  assign T15 = T11 & T16;
  assign T16 = T7 ^ 1'h1;
  assign T17 = io_cs ^ 1'h1;
  assign T18 = T20 & R19;
  assign T20 = io_bnn_empty ^ 1'h1;
  assign T70 = {4'h0, T21};
  assign T21 = T58 ? 4'h9 : T22;
  assign T22 = T54 ? 4'h8 : T71;
  assign T71 = {1'h0, T23};
  assign T23 = T50 ? 3'h7 : T24;
  assign T24 = T46 ? 3'h6 : T25;
  assign T25 = T42 ? 3'h5 : T26;
  assign T26 = T38 ? 3'h4 : T72;
  assign T72 = {1'h0, T27};
  assign T27 = T34 ? 2'h3 : T28;
  assign T28 = T31 ? 2'h2 : T73;
  assign T73 = {1'h0, T29};
  assign T29 = T30 ? 1'h1 : 1'h0;
  assign T30 = io_bnn_data == 10'h1;
  assign T31 = T33 & T32;
  assign T32 = io_bnn_data == 10'h2;
  assign T33 = T30 ^ 1'h1;
  assign T34 = T36 & T35;
  assign T35 = io_bnn_data == 10'h4;
  assign T36 = T37 ^ 1'h1;
  assign T37 = T30 | T32;
  assign T38 = T40 & T39;
  assign T39 = io_bnn_data == 10'h8;
  assign T40 = T41 ^ 1'h1;
  assign T41 = T37 | T35;
  assign T42 = T44 & T43;
  assign T43 = io_bnn_data == 10'h10;
  assign T44 = T45 ^ 1'h1;
  assign T45 = T41 | T39;
  assign T46 = T48 & T47;
  assign T47 = io_bnn_data == 10'h20;
  assign T48 = T49 ^ 1'h1;
  assign T49 = T45 | T43;
  assign T50 = T52 & T51;
  assign T51 = io_bnn_data == 10'h40;
  assign T52 = T53 ^ 1'h1;
  assign T53 = T49 | T47;
  assign T54 = T56 & T55;
  assign T55 = io_bnn_data == 10'h80;
  assign T56 = T57 ^ 1'h1;
  assign T57 = T53 | T51;
  assign T58 = T60 & T59;
  assign T59 = io_bnn_data == 10'h100;
  assign T60 = T61 ^ 1'h1;
  assign T61 = T57 | T55;
  assign T62 = T15 ? 1'h1 : 1'h0;
  assign io_bnn_read = T63;
  assign T63 = T18 ? 1'h1 : T64;
  assign T64 = T15 ? 1'h0 : T65;
  assign T65 = T6 ? 1'h1 : 1'h0;
  assign io_wake = T66;
  assign T66 = T67 ? 1'h1 : 1'h0;
  assign T67 = io_bnn_empty ^ 1'h1;
  assign io_miso = reg__io_out;
  SpiShiftRegister reg_(.clk(clk), .reset(reset),
       .io_in( io_mosi ),
       .io_shift( T62 ),
       .io_value( T70 ),
       .io_set( T0 ),
       .io_out( reg__io_out )
  );

  always @(posedge clk) begin
    if(reset) begin
      read <= 1'h0;
    end else if(T18) begin
      read <= 1'h1;
    end else if(read) begin
      read <= 1'h0;
    end else if(T17) begin
      read <= 1'h0;
    end else if(T15) begin
      read <= 1'h0;
    end else if(T6) begin
      read <= 1'h1;
    end
    if(reset) begin
      n <= 3'h0;
    end else if(T15) begin
      n <= T10;
    end else if(T6) begin
      n <= 3'h0;
    end
    R13 <= io_clk;
    R19 <= io_bnn_empty;
  end
endmodule

module SpiSlaveTestLol(input clk, input notreset,
    input  io_cs,
    input  io_clk,
    input  io_mosi,
    output io_miso,
    output io_wake,
    
    input poke,
    output poke_out,
    output rpi_poke_out
    
    
    //output reset_out,
    //output io_cs_out,
    //output io_clk_out,
    //output io_mosi_out
    
);

  wire T0;
  wire T1;
  wire T2;
  reg  started;
  wire T26;
  wire T3;
  wire[9:0] T4;
  wire[9:0] T5;
  wire[9:0] T6;
  wire[9:0] T7;
  wire T8;
  reg  n;
  wire T27;
  wire T9;
  wire T10;
  wire T11;
  wire T12;
  wire T13;
  wire T14;
  wire T15;
  wire T16;
  wire[1:0] T28;
  wire T17;
  wire T18;
  wire T19;
  wire T20;
  wire[1:0] T29;
  wire T21;
  wire T22;
  reg  R23;
  reg  R24;
  reg  R25;
  wire slave_io_miso;
  wire slave_io_wake;
  wire slave_io_bnn_read;
  wire reset;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    started = {1{$random}};
    n = {1{$random}};
    R23 = {1{$random}};
    R24 = {1{$random}};
    R25 = {1{$random}};
  end
// synthesis translate_on
`endif

  assign T0 = T1 == 1'h0;
  assign T1 = T2 ^ 1'h1;
  assign T2 = started ^ 1'h1;
  assign T26 = reset ? 1'h0 : T3;
  assign T3 = T2 ? 1'h1 : started;
  assign T4 = T19 ? 10'h10 : T5;
  assign T5 = T15 ? 10'h40 : T6;
  assign T6 = T12 ? 10'h1 : T7;
  assign T7 = T8 ? 10'h100 : 10'h0;
  assign T8 = n == 1'h0;
  assign T27 = reset ? 1'h0 : T9;
  assign T9 = slave_io_bnn_read ? T10 : n;
  assign T10 = T11 % 3'h4;
  assign T11 = n + 1'h1;
  assign T12 = T14 & T13;
  assign T13 = n == 1'h1;
  assign T14 = T8 ^ 1'h1;
  assign T15 = T17 & T16;
  assign T16 = T28 == 2'h2;
  assign T28 = {1'h0, n};
  assign T17 = T18 ^ 1'h1;
  assign T18 = T8 | T13;
  assign T19 = T21 & T20;
  assign T20 = T29 == 2'h3;
  assign T29 = {1'h0, n};
  assign T21 = T22 ^ 1'h1;
  assign T22 = T18 | T16;
  assign io_wake = slave_io_wake;
  assign io_miso = slave_io_miso;
  
  //assign io_cs_out = io_cs;
  //assign io_clk_out = io_clk;
  //assign reset_out = reset;
  //assign io_mosi_out = io_mosi;
  assign poke_out = ~poke;
  assign rpi_poke_out = poke;
  
  
  assign reset = !notreset;
  SpiSlave slave(.clk(clk), .reset(reset),
       .io_cs( R25 ),
       .io_clk( R24 ),
       .io_mosi( R23 ),
       .io_miso( slave_io_miso ),
       .io_wake( slave_io_wake ),
       .io_bnn_read( slave_io_bnn_read ),
       .io_bnn_data( T4 ),
       .io_bnn_empty( T0 )
  );

  always @(posedge clk) begin
    if(reset) begin
      started <= 1'h0;
    end else if(T2) begin
      started <= 1'h1;
    end
    if(reset) begin
      n <= 1'h0;
    end else if(slave_io_bnn_read) begin
      n <= T10;
    end
    R23 <= io_mosi;
    R24 <= io_clk;
    R25 <= io_cs;
  end
endmodule

