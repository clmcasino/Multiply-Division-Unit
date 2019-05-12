`timescale 1ns / 1ns

module tb_csa ();
  parameter width = 4;
  logic [width-1:0] addendA;
  logic [width-1:0] addendB;
  logic [width-1:0] addendC;
  logic [width-1:0] sum;
  logic [width-1:0] carry;

  carrySaveAdder #(width) add0(.*);

  initial begin
  #0 addendA=4'b0001;
  #0 addendB=4'b0001;
  #0 addendC=4'b0001;
  #1 addendA=4'b0100;
  #1 addendB=4'b0010;
  #1 addendC=4'b0001;
  #2 addendA=4'b0100;
  #2 addendB=4'b0110;
  #2 addendC=4'b1101;
  end
endmodule //tb_csa
