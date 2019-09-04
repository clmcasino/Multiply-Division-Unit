`timescale 1ns / 1ns

module tb_multDivUnit ();
  parameter parallelism=32;
  logic clk;
  logic rst_n;
  logic [2:0] opCode;
  logic valid;
  logic [parallelism-1:0] lOp;
  logic [parallelism-1:0] rOp;
  logic [parallelism-1:0] result;
  logic done;
  logic divByZero;
  logic divOverflow;

  MultDivUnit #(parallelism) DUT (.*);

  always #2 clk=~clk;

  //Clock and reset release
  initial begin
    valid=0;
    clk=0;
    rst_n=0; //Clock low at time zero
    @(posedge clk);
    @(posedge clk);
    rst_n=1;
  end

  integer fin_pointer,fout_pointer;
  string s;
  initial begin
    @(posedge rst_n);
    @(posedge clk);
    fin_pointer= $fopen("/home/clmcasino/Desktop/Mult-Div-Unit/Multiply-Division-Unit/common/inSample.txt","r");
    fout_pointer= $fopen("/home/clmcasino/Desktop/Mult-Div-Unit/Multiply-Division-Unit/common/HWResults.txt","w");
    while (! $feof(fin_pointer)) begin
      $fscanf(fin_pointer,"%b",opCode);
      $fscanf(fin_pointer,"%b",lOp);
      $fscanf(fin_pointer,"%b",rOp);
      valid=1;
      @(posedge clk);
      valid=0;
      @(posedge done);
      $fwrite(fout_pointer,"%b\n",result);
      @(posedge clk);
    end
    $stop;
    $fclose(fin_pointer);
    $fclose(fout_pointer);
  end
endmodule
