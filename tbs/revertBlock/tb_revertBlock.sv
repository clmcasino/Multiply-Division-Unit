`timescale 1ns/1ns
module tb_revertBlock();
  parameter width=6;
  logic  [width-1:0] signalIn;
  logic [width-1:0] signalOut;
  logic rev_en;

  revertingBlock #(width) DUT(.*);
  initial begin
    rev_en=0;
    signalIn=6'b000111;
  end

  initial begin
    #0 rev_en=0;
    #5 rev_en=1;
  end
endmodule
