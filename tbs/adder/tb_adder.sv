`timescale 1ns / 1ns

module tb_adder ();
  parameter parallelism=4;
  logic unsigned [parallelism-1:0] add1;
  logic unsigned [parallelism-1:0] add0;
  logic carry_in;
  logic unsigned [parallelism-1:0] sum;
  adder #(parallelism) DUT (.*);

  initial begin
    #0 add1=4'b0010;
    #1 add1=4'b1101;
  end

  initial begin
    #0 add0=4'b0011;
  end

  initial begin
    #0 carry_in=1'b0;
    #1 carry_in=1'b1;
    #2 carry_in=1'b0;
  end
endmodule //tb_adder
