`timescale 1ns/1ns
module tb_shiftRegister ();
  parameter width = 4;
  logic [width-1:0] parallelIn;     //logic Sample, as for regular register
  logic [width-1:0] parallelOut;   //logic Sample, as for regular register
  logic clk;
  logic rst_n;                      //async. reset
  logic clear;                      //sync. reset
  logic sample_en;                  //enable the sampling of logic to logic
  logic shiftLeft;                  //enable the shift left operation (synchronous)
  logic shiftRight;                 //enable the shift right operation (synchronous)
  logic newBit;                     //when shifting, take place of the new LSB or MSB depending on the operation

  shiftRegister #(width) DUT (.*);
  initial begin
    clk=1;
    parallelIn=4'b0101;
  end
  always #1 clk=~clk;
  initial begin
    #0 rst_n=0;
    #1 rst_n=1;
  end
  initial begin
    #0 clear=0;
    #11 clear=1;
  end
  initial begin
    #0 sample_en=0;
    #1 sample_en=1;
    #3 sample_en=0;
  end
  initial begin
    #5 shiftLeft=1;
    #9 shiftLeft=0;
  end
  initial begin
    #0 newBit=0;
    #7 newBit=1;
    #9 newBit=0;
  end
  initial begin
    #9 shiftRight=1;
  end
endmodule // tb_shiftREgister
