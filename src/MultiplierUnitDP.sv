module MultiplierUnitDP (clk,rst_n,usigned,multiplier,multiplicand,product,csa_clear,multiplicand_en,notMultiplicand_en,sumMux_sel,sum_en,carry_en,leftAddMux_sel,count_en,prod_en,tc);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input usigned;
  input [parallelism-1:0] multiplier;
  input [parallelism-1:0] multiplicand;
  output [parallelism*2-1:0] product;
  //control signals
  input csa_clear;
  input multiplicand_en;
  input notMultiplicand_en;
  input sumMux_sel;
  input sum_en;
  input carry_en;
  input leftAddMux_sel;
  input count_en;
  input prod_en;
  output tc;

  //signals
  logic [parallelism:0] signCorrection_to_MultiplierReg;
  logic [parallelism:0] signCorrection_to_MultipicandReg;
  logic [parallelism:0] multiplicand_to_kernelLogic;
  logic [parallelism:0] leftAdder_to_outReg;
  logic [parallelism:0] notMultiplicand_to_kernelLogic;
  logic [parallelism+1:0] sumL_to_newSumL;
  logic [parallelism:0] kl_to_csa;
  logic [parallelism:0] firstPP;
  logic [parallelism:0] csaSum_to_outReg;
  logic [parallelism:0] multiplicandMux_to_sumHReg;
  logic [parallelism:0] sum_to_csa;
  logic [parallelism+1:0] sumLMux_to_sumLReg;
  logic [parallelism:0] csaCarry_to_outReg;
  logic [parallelism:0] carry_to_csa;
  logic [parallelism:0] leftOpleftAdd;
  logic [parallelism:0] rightOpleftAdd;
  logic [parallelism-1:0] prodL;
  logic [parallelism-1:0] prodH;
  //dividing by 2 if datas are unsigned
  assign signCorrection_to_MultiplierReg = (usigned) ? {1'b0,multiplier[parallelism-1:0]} : {multiplier[parallelism-1],multiplier[parallelism-1:0]};
  assign signCorrection_to_MultipicandReg = (usigned) ? {1'b0,multiplicand[parallelism-1:0]} : {multiplicand[parallelism-1],multiplicand[parallelism-1:0]};

  //multiplicand register
  register #(parallelism+1) multiplicandRegister (  .parallelIn(signCorrection_to_MultipicandReg),
                                                  .parallelOut(multiplicand_to_kernelLogic),
                                                  .clk(clk),
                                                  .rst_n(rst_n),
                                                  .clear(csa_clear),
                                                  .sample_en(multiplicand_en));
  //~multiplicand register
  register #(parallelism+1) notMultiplicandRegister (  .parallelIn(leftAdder_to_outReg),
                                                  .parallelOut(notMultiplicand_to_kernelLogic),
                                                  .clk(clk),
                                                  .rst_n(rst_n),
                                                  .clear(csa_clear),
                                                  .sample_en(notMultiplicand_en));

  kernelLogic #(.parallelism(parallelism)) KL ( .data(multiplicand_to_kernelLogic),
                                                .notData(notMultiplicand_to_kernelLogic),
                                                .saveReminder(1'b0),
                                                .opCode({3'b0}),
                                                .sumMSBs(5'b0),
                                                .carryMSBs(5'b0),
                                                .multDecisionBits(sumL_to_newSumL[1:0]),
                                                .SignSel(),
                                                .Non0(),
                                                .outData(kl_to_csa),
                                                .d_MSB(1'b0));
  //sumHMux
  mux2to1 #(parallelism+1) sumHMux ( .inA({firstPP[parallelism],firstPP[parallelism:1]}), //first partial product /2
                                    .inB({csaSum_to_outReg[parallelism],csaSum_to_outReg[parallelism:1]}),
                                    .out(multiplicandMux_to_sumHReg),
                                    .sel(sumMux_sel));

  assign firstPP = (signCorrection_to_MultiplierReg[0]) ? leftAdder_to_outReg : {parallelism+1{1'b0}};

  //sumH register
  register #(parallelism+1) sumH (  .parallelIn(multiplicandMux_to_sumHReg),
                                    .parallelOut(sum_to_csa),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(csa_clear),
                                    .sample_en(sum_en));
  //sumLMux
  mux2to1 #(parallelism+2) sumLMux ( .inA({firstPP[0],signCorrection_to_MultiplierReg}), //first partial product /2
                                    .inB({csaSum_to_outReg[0],sumL_to_newSumL[parallelism+1:1]}),
                                    .out(sumLMux_to_sumLReg),
                                    .sel(sumMux_sel));

  //sumL
  register #(parallelism+2) sumL (  .parallelIn(sumLMux_to_sumLReg),
                                  .parallelOut(sumL_to_newSumL),
                                  .clk(clk),
                                  .rst_n(rst_n),
                                  .clear(csa_clear),
                                  .sample_en(sum_en));

  //carry
  register #(parallelism+1) carryH (  .parallelIn(csaCarry_to_outReg),
                                    .parallelOut(carry_to_csa),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(csa_clear),
                                    .sample_en(carry_en));

  //carrysave adder
  carrySaveAdder #(parallelism+1) csa ( .addendA(kl_to_csa),
                                      .addendB(sum_to_csa),
                                      .addendC(carry_to_csa),
                                      .sum(csaSum_to_outReg),
                                      .carry(csaCarry_to_outReg));

  //muxleft operand left adder
  mux2to1 #(parallelism+1) leftOpleftAdd_mux (  .inA(~signCorrection_to_MultipicandReg),
                                              .inB({1'b0,carry_to_csa[parallelism-2:0],1'b0}),
                                              .out(leftOpleftAdd),
                                              .sel(leftAddMux_sel));

  //muxright operand left adder
  mux2to1 #(parallelism+1) rightOpleftAdd_mux ( .inA(33'b1),
                                              .inB({1'b0,sum_to_csa[parallelism-2:0],sumL_to_newSumL[parallelism+1]}),
                                              .out(rightOpleftAdd),
                                              .sel(leftAddMux_sel));

  //left adder
  adder #(parallelism+1) leftAdder (  .add1(leftOpleftAdd),
                                    .add0(rightOpleftAdd),
                                    .carry_in(1'b0),
                                    .sum(leftAdder_to_outReg));
  //prod register
  register #(parallelism) prodLReg (  .parallelIn(sumL_to_newSumL[parallelism:1]),
                                        .parallelOut(prodL),
                                        .clk(clk),
                                        .rst_n(rst_n),
                                        .clear(1'b0),
                                        .sample_en(prod_en));

  //prod register
  register #(parallelism) prodHReg (  .parallelIn(leftAdder_to_outReg[parallelism-1:0]),
                                        .parallelOut(prodH),
                                        .clk(clk),
                                        .rst_n(rst_n),
                                        .clear(1'b0),
                                        .sample_en(prod_en));

  assign product = ({prodH,prodL});

  syncCounter #(6) counter ( .clk(clk),
                            .rst_n(rst_n),
                            .clear(1'b0),
                            .parallelLoad(6'b0),
                            .threashold(6'b011111),
                            .upDown_n(1'b1),
                            .load_en(1'b0),
                            .cnt_en(count_en),
                            .terminalCount(tc),
                            .parallelOutput());
endmodule
