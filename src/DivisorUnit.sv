module DivisorUnit (clk,rst_n,valid,usigned_n,divisor,dividend,reminder,quotient,res_ready);
  parameter parallelism=32;
  input clk;
  input rst_n;

  input [parallelism-1:0] divisor;
  input [parallelism-1:0] dividend;
  output [parallelism-1:0] reminder;
  output [parallelism-1:0] quotient;
  output res_ready;
  enum {  idle          =4'b0000,
          loadData      =4'b0001,
          loadCnt       =4'b0010,
          divisorLShift =4'b0011,
          saveIterLookp =4'b0100,
          divKernelStep =4'b0101,
          computeQ      =4'b0110,
          waitSignals   =4'b0111,
          correctDown   =4'b1000,
          correctUp     =4'b1001,
          qInv          =4'b1010,
          loadIterLoop  =4'b1011,
          remCorrection =4'b1100,
          divDone       =4'b1101} present_state, next_state;
  //controSignals
  
