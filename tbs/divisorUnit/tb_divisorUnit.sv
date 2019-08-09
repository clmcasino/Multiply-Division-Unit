`timescale 1ns / 1ns

module tb_divisorUnit ();
  parameter parallelism=32;
  logic clk;
  logic rst_n;
  logic valid;
  logic usigned;
  logic [parallelism-1:0] divisor;
  logic [parallelism-1:0] dividend;
  logic [parallelism-1:0] reminder;
  logic [parallelism-1:0] quotient;
  logic res_ready;

  DivisorUnit #(parallelism) DUT (.*);

  initial begin
    rst_n=0;
    clk=1;
    usigned=0;
    dividend=32'hFFFFFF8B;
    divisor=32'hA;
  end

  initial begin
    #1 rst_n=1;
    #2 valid=1'b1;
  end

  always #1 clk=~clk;
endmodule //tb_adder
