// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Thu Oct  3 12:01:22 2024
// Host        : LAPTOP-HJ430IGT running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/abonn/Desktop/Cours
//               ESIREM/4eme_Annee/Archi_Reconfigurable/Projet_TP/Projet_TP.gen/sources_1/ip/fifo_imag_9b_32K/fifo_imag_9b_32K_stub.v}
// Design      : fifo_imag_9b_32K
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_7,Vivado 2022.2" *)
module fifo_imag_9b_32K(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty, prog_full)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[8:0],wr_en,rd_en,dout[8:0],full,empty,prog_full" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [8:0]din;
  input wr_en;
  input rd_en;
  output [8:0]dout;
  output full;
  output empty;
  output prog_full;
endmodule
