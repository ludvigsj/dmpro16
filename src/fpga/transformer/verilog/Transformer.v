module SliceCrop(
    input [31:0] io_dest_addr,
    output[15:0] io_x,
    output[15:0] io_y
);

  wire[15:0] T12;
  wire[36:0] T0;
  wire[36:0] T1;
  wire[36:0] T13;
  wire[4:0] sliceY;
  wire[4:0] T2;
  wire[31:0] T3;
  wire[36:0] T4;
  wire[31:0] T5;
  wire[31:0] sliceNum;
  wire[31:0] T6;
  wire[15:0] T14;
  wire[8:0] T7;
  wire[8:0] T8;
  wire[8:0] T15;
  wire[4:0] sliceX;
  wire[4:0] T9;
  wire[8:0] T10;
  wire[3:0] T11;


  assign io_y = T12;
  assign T12 = T0[15:0];
  assign T0 = T1 + 37'h0;
  assign T1 = T4 + T13;
  assign T13 = {32'h0, sliceY};
  assign sliceY = T2;
  assign T2 = T3 % 5'h1c;
  assign T3 = io_dest_addr / 5'h1c;
  assign T4 = 5'h1c * T5;
  assign T5 = sliceNum / 4'h9;
  assign sliceNum = T6;
  assign T6 = io_dest_addr / 10'h310;
  assign io_x = T14;
  assign T14 = {7'h0, T7};
  assign T7 = T8 + 9'h0;
  assign T8 = T10 + T15;
  assign T15 = {4'h0, sliceX};
  assign sliceX = T9;
  assign T9 = io_dest_addr % 5'h1c;
  assign T10 = 5'h1c * T11;
  assign T11 = sliceNum % 4'h9;
endmodule

module MatrTrans(
    output[15:0] io_srcX,
    output[15:0] io_srcY,
    input [15:0] io_dstX,
    input [15:0] io_dstY,
    input [15:0] io_x0,
    input [15:0] io_x1,
    input [15:0] io_y0,
    input [15:0] io_y1
);

  wire[15:0] T14;
  wire[31:0] T0;
  wire[31:0] T15;
  wire[31:0] T1;
  wire[31:0] T2;
  wire[31:0] T3;
  wire[15:0] T4;
  wire[31:0] T5;
  wire[15:0] T6;
  wire[15:0] T16;
  wire[31:0] T7;
  wire[31:0] T17;
  wire[31:0] T8;
  wire[31:0] T9;
  wire[31:0] T10;
  wire[15:0] T11;
  wire[31:0] T12;
  wire[15:0] T13;


  assign io_srcY = T14;
  assign T14 = T0[15:0];
  assign T0 = T1 + T15;
  assign T15 = {16'h0, io_y0};
  assign T1 = T2 / 8'hfc;
  assign T2 = T5 + T3;
  assign T3 = T4 * io_dstY;
  assign T4 = io_x1 - io_x0;
  assign T5 = T6 * io_dstX;
  assign T6 = io_y1 - io_y0;
  assign io_srcX = T16;
  assign T16 = T7[15:0];
  assign T7 = T8 + T17;
  assign T17 = {16'h0, io_x0};
  assign T8 = T9 / 8'hfc;
  assign T9 = T12 - T10;
  assign T10 = T11 * io_dstY;
  assign T11 = io_y1 - io_y0;
  assign T12 = T13 * io_dstX;
  assign T13 = io_x1 - io_x0;
endmodule

module AddrTrans(
    input [31:0] io_dest_addr,
    output[31:0] io_src_addr,
    input [15:0] io_x0,
    input [15:0] io_x1,
    input [15:0] io_y0,
    input [15:0] io_y1
);

  wire[31:0] T2;
  wire[25:0] T0;
  wire[25:0] T3;
  wire[25:0] T1;
  wire[15:0] sc_io_x;
  wire[15:0] sc_io_y;
  wire[15:0] mt_io_srcX;
  wire[15:0] mt_io_srcY;


  assign io_src_addr = T2;
  assign T2 = {6'h0, T0};
  assign T0 = T1 + T3;
  assign T3 = {10'h0, mt_io_srcX};
  assign T1 = 10'h280 * mt_io_srcY;
  SliceCrop sc(
       .io_dest_addr( io_dest_addr ),
       .io_x( sc_io_x ),
       .io_y( sc_io_y )
  );
  MatrTrans mt(
       .io_srcX( mt_io_srcX ),
       .io_srcY( mt_io_srcY ),
       .io_dstX( sc_io_x ),
       .io_dstY( sc_io_y ),
       .io_x0( io_x0 ),
       .io_x1( io_x1 ),
       .io_y0( io_y0 ),
       .io_y1( io_y1 )
  );
endmodule

module MatrixTransformer(input clk, input reset,
    output[19:0] io_src_addr,
    output io_done,
    input [15:0] io_x0,
    input [15:0] io_x1,
    input [15:0] io_y0,
    input [15:0] io_y1,
    input  io_enable
);

  wire[31:0] T2;
  reg [15:0] out_addr;
  wire[15:0] T3;
  wire[15:0] T0;
  wire[15:0] T1;
  wire[19:0] T4;
  wire[31:0] at_io_src_addr;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    out_addr = {1{$random}};
  end
// synthesis translate_on
`endif

`ifndef SYNTHESIS
// synthesis translate_off
  assign io_done = {1{$random}};
// synthesis translate_on
`endif
  assign T2 = {16'h0, out_addr};
  assign T3 = reset ? 16'h0 : T0;
  assign T0 = io_enable ? T1 : out_addr;
  assign T1 = out_addr + 16'h1;
  assign io_src_addr = T4;
  assign T4 = at_io_src_addr[19:0];
  AddrTrans at(
       .io_dest_addr( T2 ),
       .io_src_addr( at_io_src_addr ),
       .io_x0( io_x0 ),
       .io_x1( io_x1 ),
       .io_y0( io_y0 ),
       .io_y1( io_y1 )
  );

  always @(posedge clk) begin
    if(reset) begin
      out_addr <= 16'h0;
    end else if(io_enable) begin
      out_addr <= T1;
    end
  end
endmodule

module CameraController(
    output io_done,
    output io_data,
    input  io_enable,
    output[19:0] io_addr,
    output io_write
);



  assign io_write = 1'h0;
  assign io_addr = 20'h0;
  assign io_data = 1'h0;
  assign io_done = 1'h1;
endmodule

module ImgMem(input clk,
    input [19:0] io_addr,
    output io_out,
    input  io_in,
    input  io_wen
);

  wire T0;
  wire T1;
  reg  mem [307199:0];
  wire T2;
  wire T3;
  wire T4;
  wire[18:0] T5;
  wire[18:0] T7;
  wire[18:0] T8;
  wire T6;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    for (initvar = 0; initvar < 307200; initvar = initvar+1)
      mem[initvar] = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_out = T0;
  assign T0 = T6 ? T1 : 1'h0;
  assign T1 = mem[T8];
  assign T3 = io_wen & T4;
  assign T4 = T5 < 19'h4b000;
  assign T5 = io_addr[18:0];
  assign T7 = io_addr[18:0];
  assign T8 = io_addr[18:0];
  assign T6 = io_wen ^ 1'h1;

  always @(posedge clk) begin
    if (T3)
      mem[T7] <= io_in;
  end
endmodule

module CornersModule(input clk, input reset,
    input  io_pxin,
    input  io_pxin1,
    input  io_pxin2,
    input  io_pxin3,
    output[15:0] io_x0,
    output[15:0] io_x1,
    output[15:0] io_y0,
    output[15:0] io_y1,
    input  io_enable,
    output io_done,
    output[19:0] io_adr
);

  wire[19:0] T96;
  wire[25:0] T0;
  wire[25:0] T97;
  reg [15:0] x;
  wire[15:0] T98;
  wire[15:0] T1;
  wire[15:0] T2;
  wire[15:0] T3;
  wire T4;
  wire T5;
  wire[15:0] T6;
  wire T7;
  wire T8;
  wire T9;
  wire[25:0] T10;
  reg [15:0] y;
  wire[15:0] T99;
  wire[15:0] T11;
  wire[15:0] T12;
  wire[15:0] T13;
  reg  done;
  wire T100;
  wire T14;
  wire T15;
  wire T16;
  wire T17;
  wire T18;
  wire T19;
  wire T20;
  wire T21;
  wire T22;
  wire T23;
  wire T24;
  reg [15:0] leftesty;
  wire[15:0] T101;
  wire[15:0] T25;
  wire T26;
  wire T27;
  wire T28;
  wire T29;
  wire T30;
  wire T31;
  wire T32;
  wire T33;
  reg [15:0] leftestx;
  wire[15:0] T102;
  wire[15:0] T34;
  wire[15:0] T35;
  wire[15:0] T36;
  wire T37;
  reg  firstFound;
  wire T103;
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
  reg  first;
  wire T104;
  wire T49;
  wire T50;
  wire T51;
  wire T52;
  wire T53;
  wire[15:0] T54;
  reg [15:0] firsty;
  wire[15:0] T105;
  wire[15:0] T55;
  wire T56;
  reg [15:0] firstx;
  wire[15:0] T106;
  wire[15:0] T57;
  wire[15:0] T58;
  wire T59;
  wire T60;
  wire T61;
  wire T62;
  reg [15:0] rightesty;
  wire[15:0] T107;
  wire[15:0] T63;
  reg [15:0] secondy2;
  wire[15:0] T108;
  wire T64;
  reg [15:0] secondx2;
  wire[15:0] T109;
  wire[15:0] T65;
  reg [15:0] rightestx;
  wire[15:0] T110;
  wire[15:0] T66;
  wire[15:0] T67;
  wire T68;
  wire T69;
  wire T70;
  wire[15:0] T71;
  reg [15:0] secondy1;
  wire[15:0] T111;
  wire[15:0] T72;
  wire T73;
  wire T74;
  wire T75;
  wire T76;
  wire T77;
  wire T78;
  wire T79;
  wire T80;
  reg [15:0] secondx1;
  wire[15:0] T112;
  wire[15:0] T81;
  wire[15:0] T82;
  wire T83;
  reg [15:0] y1temp;
  wire[15:0] T113;
  wire[15:0] T84;
  wire[15:0] T85;
  wire[15:0] T86;
  reg [15:0] y0temp;
  wire[15:0] T114;
  wire[15:0] T87;
  wire[15:0] T88;
  wire[15:0] T89;
  reg [15:0] x1temp;
  wire[15:0] T115;
  wire[15:0] T90;
  wire[15:0] T91;
  wire[15:0] T92;
  reg [15:0] x0temp;
  wire[15:0] T116;
  wire[15:0] T93;
  wire[15:0] T94;
  wire[15:0] T95;

`ifndef SYNTHESIS
// synthesis translate_off
  integer initvar;
  initial begin
    #0.002;
    x = {1{$random}};
    y = {1{$random}};
    done = {1{$random}};
    leftesty = {1{$random}};
    leftestx = {1{$random}};
    firstFound = {1{$random}};
    first = {1{$random}};
    firsty = {1{$random}};
    firstx = {1{$random}};
    rightesty = {1{$random}};
    secondy2 = {1{$random}};
    secondx2 = {1{$random}};
    rightestx = {1{$random}};
    secondy1 = {1{$random}};
    secondx1 = {1{$random}};
    y1temp = {1{$random}};
    y0temp = {1{$random}};
    x1temp = {1{$random}};
    x0temp = {1{$random}};
  end
// synthesis translate_on
`endif

  assign io_adr = T96;
  assign T96 = T0[19:0];
  assign T0 = T10 + T97;
  assign T97 = {10'h0, x};
  assign T98 = reset ? 16'h0 : T1;
  assign T1 = T9 ? 16'h0 : T2;
  assign T2 = T7 ? T6 : T3;
  assign T3 = T4 ? 16'h0 : x;
  assign T4 = io_enable & T5;
  assign T5 = x == 16'h27f;
  assign T6 = x + 16'h1;
  assign T7 = io_enable & T8;
  assign T8 = T5 ^ 1'h1;
  assign T9 = io_enable ^ 1'h1;
  assign T10 = y * 10'h27f;
  assign T99 = reset ? 16'h0 : T11;
  assign T11 = T9 ? 16'h0 : T12;
  assign T12 = T4 ? T13 : y;
  assign T13 = y + 16'h1;
  assign io_done = done;
  assign T100 = reset ? 1'h0 : T14;
  assign T14 = T68 ? 1'h1 : T15;
  assign T15 = T60 ? 1'h1 : T16;
  assign T16 = T22 ? 1'h1 : T17;
  assign T17 = T19 ? 1'h1 : T18;
  assign T18 = T9 ? 1'h0 : done;
  assign T19 = T21 & T20;
  assign T20 = x == 16'h27f;
  assign T21 = y == 16'h1df;
  assign T22 = T59 & T23;
  assign T23 = T56 & T24;
  assign T24 = T54 < leftesty;
  assign T101 = reset ? 16'h3e7 : T25;
  assign T25 = T26 ? y : leftesty;
  assign T26 = T37 & T27;
  assign T27 = T29 & T28;
  assign T28 = io_pxin3 == 1'h1;
  assign T29 = T31 & T30;
  assign T30 = io_pxin2 == 1'h1;
  assign T31 = T33 & T32;
  assign T32 = io_pxin1 == 1'h1;
  assign T33 = x < leftestx;
  assign T102 = reset ? 16'h3e7 : T34;
  assign T34 = T26 ? x : T35;
  assign T35 = T9 ? 16'h3e7 : T36;
  assign T36 = T4 ? 16'h3e7 : leftestx;
  assign T37 = T53 & firstFound;
  assign T103 = reset ? 1'h0 : T38;
  assign T38 = T39 ? 1'h1 : firstFound;
  assign T39 = T41 & T40;
  assign T40 = io_pxin3 == 1'h0;
  assign T41 = T43 & T42;
  assign T42 = io_pxin2 == 1'h0;
  assign T43 = T45 & T44;
  assign T44 = io_pxin1 == 1'h0;
  assign T45 = T47 & T46;
  assign T46 = io_pxin == 1'h0;
  assign T47 = first & T48;
  assign T48 = firstFound ^ 1'h1;
  assign T104 = reset ? 1'h0 : T49;
  assign T49 = T51 ? 1'h1 : T50;
  assign T50 = T9 ? 1'h0 : first;
  assign T51 = T53 & T52;
  assign T52 = first ^ 1'h1;
  assign T53 = io_pxin == 1'h1;
  assign T54 = firsty + 16'h5;
  assign T105 = reset ? 16'h0 : T55;
  assign T55 = T39 ? y : firsty;
  assign T56 = leftestx == firstx;
  assign T106 = reset ? 16'h0 : T57;
  assign T57 = T39 ? T58 : firstx;
  assign T58 = x - 16'h1;
  assign T59 = x == 16'h27f;
  assign T60 = T59 & T61;
  assign T61 = T64 & T62;
  assign T62 = T63 < rightesty;
  assign T107 = reset ? 16'h0 : rightesty;
  assign T63 = secondy2 + 16'h5;
  assign T108 = reset ? 16'h0 : secondy2;
  assign T64 = rightestx < secondx2;
  assign T109 = reset ? 16'h0 : T65;
  assign T65 = T9 ? 16'h0 : secondx2;
  assign T110 = reset ? 16'h0 : T66;
  assign T66 = T9 ? 16'h0 : T67;
  assign T67 = T4 ? 16'h0 : rightestx;
  assign T68 = T59 & T69;
  assign T69 = T83 & T70;
  assign T70 = T71 < leftesty;
  assign T71 = secondy1 + 16'h5;
  assign T111 = reset ? 16'h3e7 : T72;
  assign T72 = T73 ? y : secondy1;
  assign T73 = T37 & T74;
  assign T74 = T76 & T75;
  assign T75 = io_pxin3 == 1'h1;
  assign T76 = T78 & T77;
  assign T77 = io_pxin2 == 1'h1;
  assign T78 = T80 & T79;
  assign T79 = io_pxin1 == 1'h1;
  assign T80 = x < secondx1;
  assign T112 = reset ? 16'h3e7 : T81;
  assign T81 = T73 ? x : T82;
  assign T82 = T9 ? 16'h3e7 : secondx1;
  assign T83 = secondx1 < leftestx;
  assign io_y1 = y1temp;
  assign T113 = reset ? 16'h0 : T84;
  assign T84 = T68 ? firsty : T85;
  assign T85 = T60 ? secondy2 : T86;
  assign T86 = T22 ? secondy2 : y1temp;
  assign io_y0 = y0temp;
  assign T114 = reset ? 16'h0 : T87;
  assign T87 = T68 ? secondy1 : T88;
  assign T88 = T60 ? firsty : T89;
  assign T89 = T22 ? firsty : y0temp;
  assign io_x1 = x1temp;
  assign T115 = reset ? 16'h0 : T90;
  assign T90 = T68 ? firstx : T91;
  assign T91 = T60 ? secondx2 : T92;
  assign T92 = T22 ? secondx2 : x1temp;
  assign io_x0 = x0temp;
  assign T116 = reset ? 16'h0 : T93;
  assign T93 = T68 ? secondx1 : T94;
  assign T94 = T60 ? firstx : T95;
  assign T95 = T22 ? firstx : x0temp;

  always @(posedge clk) begin
    if(reset) begin
      x <= 16'h0;
    end else if(T9) begin
      x <= 16'h0;
    end else if(T7) begin
      x <= T6;
    end else if(T4) begin
      x <= 16'h0;
    end
    if(reset) begin
      y <= 16'h0;
    end else if(T9) begin
      y <= 16'h0;
    end else if(T4) begin
      y <= T13;
    end
    if(reset) begin
      done <= 1'h0;
    end else if(T68) begin
      done <= 1'h1;
    end else if(T60) begin
      done <= 1'h1;
    end else if(T22) begin
      done <= 1'h1;
    end else if(T19) begin
      done <= 1'h1;
    end else if(T9) begin
      done <= 1'h0;
    end
    if(reset) begin
      leftesty <= 16'h3e7;
    end else if(T26) begin
      leftesty <= y;
    end
    if(reset) begin
      leftestx <= 16'h3e7;
    end else if(T26) begin
      leftestx <= x;
    end else if(T9) begin
      leftestx <= 16'h3e7;
    end else if(T4) begin
      leftestx <= 16'h3e7;
    end
    if(reset) begin
      firstFound <= 1'h0;
    end else if(T39) begin
      firstFound <= 1'h1;
    end
    if(reset) begin
      first <= 1'h0;
    end else if(T51) begin
      first <= 1'h1;
    end else if(T9) begin
      first <= 1'h0;
    end
    if(reset) begin
      firsty <= 16'h0;
    end else if(T39) begin
      firsty <= y;
    end
    if(reset) begin
      firstx <= 16'h0;
    end else if(T39) begin
      firstx <= T58;
    end
    if(reset) begin
      rightesty <= 16'h0;
    end
    if(reset) begin
      secondy2 <= 16'h0;
    end
    if(reset) begin
      secondx2 <= 16'h0;
    end else if(T9) begin
      secondx2 <= 16'h0;
    end
    if(reset) begin
      rightestx <= 16'h0;
    end else if(T9) begin
      rightestx <= 16'h0;
    end else if(T4) begin
      rightestx <= 16'h0;
    end
    if(reset) begin
      secondy1 <= 16'h3e7;
    end else if(T73) begin
      secondy1 <= y;
    end
    if(reset) begin
      secondx1 <= 16'h3e7;
    end else if(T73) begin
      secondx1 <= x;
    end else if(T9) begin
      secondx1 <= 16'h3e7;
    end
    if(reset) begin
      y1temp <= 16'h0;
    end else if(T68) begin
      y1temp <= firsty;
    end else if(T60) begin
      y1temp <= secondy2;
    end else if(T22) begin
      y1temp <= secondy2;
    end
    if(reset) begin
      y0temp <= 16'h0;
    end else if(T68) begin
      y0temp <= secondy1;
    end else if(T60) begin
      y0temp <= firsty;
    end else if(T22) begin
      y0temp <= firsty;
    end
    if(reset) begin
      x1temp <= 16'h0;
    end else if(T68) begin
      x1temp <= firstx;
    end else if(T60) begin
      x1temp <= secondx2;
    end else if(T22) begin
      x1temp <= secondx2;
    end
    if(reset) begin
      x0temp <= 16'h0;
    end else if(T68) begin
      x0temp <= secondx1;
    end else if(T60) begin
      x0temp <= firstx;
    end else if(T22) begin
      x0temp <= firstx;
    end
  end
endmodule

module Transformer(input clk, input reset,
    input  io_enable,
    output io_done
);

  wire T0;
  wire T1;
  wire[19:0] T2;
  wire[19:0] mux1;
  wire cam_io_done;
  wire cam_io_data;
  wire[19:0] cam_io_addr;
  wire cam_io_write;
  wire imgmem_io_out;
  wire[15:0] corner_io_x0;
  wire[15:0] corner_io_x1;
  wire[15:0] corner_io_y0;
  wire[15:0] corner_io_y1;
  wire corner_io_done;
  wire[19:0] corner_io_adr;
  wire[19:0] matrix_io_src_addr;
  wire matrix_io_done;


  assign T0 = cam_io_write & T1;
  assign T1 = cam_io_done ^ 1'h1;
  assign T2 = corner_io_done ? matrix_io_src_addr : mux1;
  assign mux1 = cam_io_done ? corner_io_adr : cam_io_addr;
  assign io_done = matrix_io_done;
  MatrixTransformer matrix(.clk(clk), .reset(reset),
       .io_src_addr( matrix_io_src_addr ),
       .io_done( matrix_io_done ),
       .io_x0( corner_io_x0 ),
       .io_x1( corner_io_x1 ),
       .io_y0( corner_io_y0 ),
       .io_y1( corner_io_y1 ),
       .io_enable( corner_io_done )
  );
`ifndef SYNTHESIS
// synthesis translate_off
    assign matrix.io_done = {1{$random}};
// synthesis translate_on
`endif
  CameraController cam(
       .io_done( cam_io_done ),
       .io_data( cam_io_data ),
       .io_enable( io_enable ),
       .io_addr( cam_io_addr ),
       .io_write( cam_io_write )
  );
  ImgMem imgmem(.clk(clk),
       .io_addr( T2 ),
       .io_out( imgmem_io_out ),
       .io_in( cam_io_data ),
       .io_wen( T0 )
  );
  CornersModule corner(.clk(clk), .reset(reset),
       .io_pxin( imgmem_io_out ),
       //.io_pxin1(  )
       //.io_pxin2(  )
       //.io_pxin3(  )
       .io_x0( corner_io_x0 ),
       .io_x1( corner_io_x1 ),
       .io_y0( corner_io_y0 ),
       .io_y1( corner_io_y1 ),
       .io_enable( cam_io_done ),
       .io_done( corner_io_done ),
       .io_adr( corner_io_adr )
  );
`ifndef SYNTHESIS
// synthesis translate_off
    assign corner.io_pxin1 = {1{$random}};
    assign corner.io_pxin2 = {1{$random}};
    assign corner.io_pxin3 = {1{$random}};
// synthesis translate_on
`endif
endmodule

