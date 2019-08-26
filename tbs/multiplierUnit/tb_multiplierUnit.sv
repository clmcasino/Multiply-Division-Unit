`timescale 1ns / 1ns

module tb_multiplierUnit ();
  parameter parallelism=32;
  logic clk;
  logic rst_n;
  logic valid;
  logic usigned;
  logic [parallelism-1:0] multiplier;
  logic [parallelism-1:0] multiplicand;
  logic [parallelism*2-1:0] product;
  logic res_ready;

  MultiplierUnit #(parallelism) DUT (.*);

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
    `ifdef GUI
      usigned=0;
      multiplicand=32'h16;
      multiplier=32'hFFFFFFEB;
      valid=1;
      @(posedge clk);
      valid=0;
      @(posedge res_ready);
      @(posedge clk);
      $stop;
  `else
    fin_pointer= $fopen("/home/clmcasino/Desktop/Mult-Div-Unit/Multiply-Division-Unit/common/harmInSample.txt","r");
    fout_pointer= $fopen("/home/clmcasino/Desktop/Mult-Div-Unit/Multiply-Division-Unit/common/multiplierHWResults.txt","w");
    while (! $feof(fin_pointer)) begin
      $fscanf(fin_pointer,"%b",usigned);
      $fscanf(fin_pointer,"%b",multiplicand);
      $fscanf(fin_pointer,"%b",multiplier);
      valid=1;
      @(posedge clk);
      valid=0;
      @(posedge res_ready);
      $fwrite(fout_pointer,"%b\n",product);
      @(posedge clk);
    end
    $finish;
    $fclose(fin_pointer);
    $fclose(fout_pointer);
  `endif
  end
endmodule
