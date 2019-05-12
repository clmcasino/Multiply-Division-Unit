module MultDivUnitDP (clk,rst_n,opCode,operand0,operand1,result,res_ready,div_by_zero,overflow_div,overflow_mult,previousDataRegn_en,ad_en,divisor_lShift,notAd_en,sumH_sel,rev_en);
  parameter parallelism=32;
  parameter opCode_width=3;
  input clk;
  input rst_n;
  input [opCode_width-1:0] opCode;
  input [parallelism-1:0] operand0; //multiplicand/divisor
  input [parallelism-1:0] operand1; //multiplier/dividend
  output [parallelism-1:0] result;
  output res_ready;
  output div_by_zero;
  output overflow_div;
  output overflow_mult;
  //control signals
  input previousDataRegn_en;
  input ad_en;
  input divisor_lShift;
  input notAd_en;
  input [1:0] sumH_sel;
  input sumH_en;
  input rev_en;
  //signals
  logic [parallelism-1:0] adReg_to_comparator;
  logic [parallelism-1:0] mzReg_to_comparator;
  logic opFF_to_comparator;
  logic ad_Equality;
  logic mz_Equality;
  logic opPrec_Equality;
  logic [parallelism:0] op0_to_regn;
  logic [parallelism:0] op1_to_regn;
  logic [parallelism:0] ad_to_kernelLogic;
  logic [parallelism:0] leftAdder_to_outReg;
  logic [parallelism:0] notAd_to_kernelLogic;
  logic [parallelism:0] csaSum;
  logic [parallelism:0] csaCarry;
  logic [parallelism:0] condSum_to_remCorrection;
  logic [parallelism:0] sumhMux_to_sumH;
  logic [parallelism:0] sumH_to_cond2;
  logic [parallelism:0] sumL_to_rev;
  
  //begin describing architecture

  //////////////////SAME DATA AS PREVIOS OPERATION HW PART/////////////////////
  //a/d(t-1) register
  register #(parallelism) a_d ( .parallelIn(operand0),
                                .parallelOut(adReg_to_comparator),
                                .clk(clk),
                                .rst_n(rst_n),
                                .clear(1'b0),
                                .sample_en(previousDataRegn_en));
  //m/z(t-1) register
  register #(parallelism) m_z ( .parallelIn(operand1),
                                .parallelOut(mzReg_to_comparator),
                                .clk(clk),
                                .rst_n(rst_n),
                                .clear(1'b0),
                                .sample_en(previousDataRegn_en));
  //previous operation ff
  register #(1) opPrec_ff     ( .parallelIn(opCode[2]),
                                .parallelOut(opFF_to_comparator),
                                .clk(clk),
                                .rst_n(rst_n),
                                .clear(1'b0),
                                .sample_en(previousDataRegn_en));
  comparator #(parallelism) ad_comparator ( .inA(adReg_to_comparator),
                                            .inB(operand0),
                                            .isEqual(ad_Equality));
  comparator #(parallelism) mz_comparator ( .inA(mzReg_to_comparator),
                                            .inB(operand1),
                                            .isEqual(mz_Equality));
  comparator #(1) opPrec_comparator ( .inA(opFF_to_comparator),
                                      .inB(opCode[2]),
                                      .isEqual(opPrec_Equality));
  assign res_ready= ad_Equality & mz_Equality & opPrec_Equality;

  /////////////////////////////DIV BY ZERO DETECTION///////////////////////////
  divZeroDetect #(parallelism) divZeroDetect ( .divisor(operand0),
                                                .divByZero(div_by_zero));
  assign div_by_zero = (source);

  ///////////////////////////DIV OVERFLOW DETECTION////////////////////////////
  divOvfDetectBlock #(parallelism) divOvfDetectBlock (  .divisor(operand0),
                                                        .dividend(operand1),
                                                        .overflow(overflow_div));
  ///////////////////////////////////CONDITIONING//////////////////////////////
  operand0Conditioning #( .PAR(parallelism),.OPCODE_WIDTH(opCode_width)) operand0Conditioning ( .signalIn(operand0),
                                                                                                .signalOut(op0_to_regn),
                                                                                                .opCode(opCode));
  operand1Conditioning #( .PAR(parallelism),.OPCODE_WIDTH(opCode_width)) operand1Conditioning ( .signalIn(operand1),
                                                                                                .signalOut(op1_to_regn),
                                                                                                .opCode(opCode));
  //multiplicand and divisor (shift) register
  shiftRegister #(parallelism+1) adRegister ( .parallelIn(operand0),
                                              .parallelOut(ad_to_kernelLogic),
                                              .clk(clk),
                                              .rst_n(rst_n),
                                              .clear(1'b0),
                                              .sample_en(ad_en),
                                              .shiftLeft(divisor_lShift),
                                              .shiftRight(1'b0),
                                              .newBit(1'b0));
  //multiplicand and divisor 2's complement
  register #(parallelism+1) notAdRegister ( .parallelIn(leftAdder_to_outReg),
                                            .parallelOut(notAd_to_kernelLogic),
                                            .clk(clk),
                                            .rst_n(rst_n),
                                            .clear(1'b0),
                                            .sample_en(notAd_en));
  //input mux for SumH
  mux4to1 #(parallelism+1) inSumH_mux ( .inA(op1_to_regn),
                                        .inB({csaSum[parallelism-1:0],0}),
                                        .inC(condSum_to_remCorrection),
                                        .inD({parallelism+1{1'b0}}),
                                        .sel(sumH_sel),
                                        .out(sumhMux_to_sumH));
  //sumH register
  register #(parallelism+1) sumH (  .parallelIn(sumhMux_to_sumH),
                                    .parallelOut(sumH_to_cond2),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(1'b0),
                                    .sample_en(sumH_en));
  //cond2 block
  mux2to1 #(parallelism+1) cond2 (  .inA(sumH_to_cond2),
                                    .inB({sumH_to_cond2[parallelism-1:0],sumL_to_rev[parallelism]}),
                                    .out(condSum_to_remCorrection),
                                    .sel(rev_en));
  endmodule //MultDivUnitDP
