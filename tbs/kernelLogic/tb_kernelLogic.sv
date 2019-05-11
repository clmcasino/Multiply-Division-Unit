`timescale 1ns/1ns

module tb_kernelLogic;
  parameter parallelism=32;
  parameter csaBits=4;
  logic [parallelism:0] data;
  logic [parallelism:0] notData;
  logic saveReminder;
  logic [2:0] opCode;
  logic signed [csaBits-1:0] sumMSBs;
  logic signed [csaBits-1:0] carryMSBs;
  logic z_MSB;
  logic d_MSB;
  logic SignSel;
  logic Non0;
  logic [parallelism:0] outData;

  kernelLogic DUT(.*);
  initial begin//devo cambiarlo per il segno!!!
    #0 data={{parallelism{1'b1}},1'b0};
    #0 notData={{parallelism-1{1'b0}},2'b10};
    #3 data={{parallelism-1{1'b0}},2'b10};
    #3 notData={{parallelism{1'b1}},1'b0};
    #5 data={{parallelism{1'b1}},1'b0};
    #5 notData={{parallelism-1{1'b0}},2'b10};
    #7 data={{parallelism-1{1'b0}},2'b10};
    #7 notData={{parallelism{1'b1}},1'b0};
    #10 data={{parallelism{1'b1}},1'b0};
    #10 notData={{parallelism-1{1'b0}},2'b10};
    #13 data={{parallelism-1{1'b0}},2'b10};
    #13 notData={{parallelism{1'b1}},1'b0};
    #15 data={{parallelism{1'b1}},1'b0};
    #15 notData={{parallelism-1{1'b0}},2'b10};
    #17 data={{parallelism-1{1'b0}},2'b10};
    #17 notData={{parallelism{1'b1}},1'b0};
  end
  initial begin
    #0 saveReminder=1;
    #10 saveReminder=0;
  end
  initial begin
    #0 opCode=3'b100;
    #5 opCode=3'b101;
    #10 opCode=3'b100;
    #15 opCode=3'b101;
    #20 opCode=3'b000;
  end
  initial begin
    #0 sumMSBs=4'b0000;
    #0 carryMSBs=4'b0000;
    #11 carryMSBs=4'b1111;
    #12 carryMSBs=4'b1100;
    #15 carryMSBs=4'b0000;
    #16 carryMSBs=4'b1111;
    #17 carryMSBs=4'b1100;
    #21 sumMSBs=4'b1111;
    #22 sumMSBs=4'b1011;
    #23 sumMSBs=4'b0111;
  end
  initial begin
    #0 z_MSB=1'b0;
    #0 d_MSB=1'b0;
    #1 z_MSB=1'b1;
    #1 d_MSB=1'b0;
    #2 z_MSB=1'b0;
    #2 d_MSB=1'b1;
    #3 z_MSB=1'b1;
    #3 d_MSB=1'b1;
    #5 z_MSB=1'b0;
    #5 d_MSB=1'b0;
    #6 z_MSB=1'b1;
    #6 d_MSB=1'b0;
    #7 z_MSB=1'b0;
    #7 d_MSB=1'b1;
    #8 z_MSB=1'b1;
    #8 d_MSB=1'b1;
    #10 z_MSB=1'b0;
    #10 d_MSB=1'b0;
    #11 z_MSB=1'b1;
    #11 d_MSB=1'b0;
    #12 z_MSB=1'b0;
    #12 d_MSB=1'b1;
    #13 z_MSB=1'b1;
    #13 d_MSB=1'b1;
    #15 z_MSB=1'b0;
    #15 d_MSB=1'b0;
    #16 z_MSB=1'b1;
    #16 d_MSB=1'b0;
    #17 z_MSB=1'b0;
    #17 d_MSB=1'b1;
    #18 z_MSB=1'b1;
    #18 d_MSB=1'b1;
    #20 z_MSB=1'b0;
    #20 d_MSB=1'b0;
    #21 z_MSB=1'b1;
    #21 d_MSB=1'b0;
    #22 z_MSB=1'b0;
    #22 d_MSB=1'b1;
    #23 z_MSB=1'b1;
    #23 d_MSB=1'b1;
  end

endmodule //tb_kernelLogic
