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

  always #5 clk=~clk;

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
    `ifdef NO_GUI
      usigned=0;
      dividend=32'b00000000001101011100110010000000;
      divisor=32'b11110000001101011001010101110111;
      valid=1;
      @(posedge clk);
      valid=0;
      @(posedge res_ready);
      @(posedge clk);
      $stop;
    `else
      fin_pointer= $fopen("/home/clmcasino/Desktop/Mult-Div-Unit/Multiply-Division-Unit/common/divisorInSample.txt","r");
      fout_pointer= $fopen("/home/clmcasino/Desktop/Mult-Div-Unit/Multiply-Division-Unit/common/divisorHWResults.txt","w");
      while (! $feof(fin_pointer)) begin
        $fscanf(fin_pointer,"%b",usigned);
      $fscanf(fin_pointer,"%b",dividend);
        $fscanf(fin_pointer,"%b",divisor);
        valid=1;
        @(posedge clk);
        valid=0;
        @(posedge res_ready);
        $fwrite(fout_pointer,"%b %b\n",quotient,reminder);
        @(posedge clk);
    end
      $finish;
      $fclose(fin_pointer);
      $fclose(fout_pointer);
    `endif
  end
endmodule //tb_adder
