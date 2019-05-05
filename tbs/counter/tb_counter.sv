`timescale 1ns/1ns
module tb_counter();

  parameter WIDTH=6;

  logic clk;              //synchronization signal
  logic rst_n;              //asynchronous reset signal
  logic clear;            //synchronouus reset signal
  logic [WIDTH-1:0] parallelLoad;     //starting number to start counting
  logic [WIDTH-1:0] threashold;       //threashold at which tc is rised
  logic upDown_n;         //1 for counting up, 0 for cunting down
  logic load_en;          //enable for loading the parallelLoad input
  logic cnt_en;           //enable for counting according to upDown_n signal
  logic terminalCount;   //rised when threashold is reached
  logic [WIDTH-1:0] parallelOutput;

  //DUT instance
  syncCounter #(WIDTH) DUT(.*);

  //rst_n stimulus
  initial begin
    #0 rst_n=0;
    #5 rst_n=1;
  end

  //clear stimulus
  initial begin
    #0 clear=0;
    #11 clear=1;
    #13 clear=0;
  end

  //parallelLoad stimulus
  initial begin
    clk=0;
    upDown_n=0;
    parallelLoad=6'b000110;
    threashold=6'b000001;
  end

  //clock stimulus
  always #2 clk = ~clk;

  //upDown_n stimulus
  always #7 upDown_n = ~upDown_n;

  //load_en stimulus
  initial begin
    #0 load_en=0;
    #9 load_en=1;
    #11 load_en=0;
  end

  //cnt_en stimulus
  initial begin
    #0 cnt_en=1;
    #20 cnt_en=0;
    #30 cnt_en=1;
  end
endmodule
