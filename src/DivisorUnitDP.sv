module DivisorUnitDP (clk,rst_n,usigned,divisor,dividend,reminder,quotient,divisor_en,divisor_lShift,notDivisor_en,saveReminder,sumHMux_sel,sum_en,carry_en,leftAddMux_sel,rightAddMux_sel,QCorrectBitMux_sel,leftAddMode,rightAddMode,reminder_en,reminder_rShift,quotient_en,counterMux_sel,count_upDown,count_load,count_en,counterReg_en,tc,signS,magnitudeD,csa_clear);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input usigned;
  input [parallelism-1:0] divisor;
  input [parallelism-1:0] dividend;
  output [parallelism-1:0] reminder;
  output [parallelism-1:0] quotient;
  //control signals
  input divisor_en;
  input divisor_lShift;
  input notDivisor_en;
  input saveReminder;
  input sumHMux_sel;
  input sum_en;
  input carry_en;
  input [1:0] leftAddMux_sel;
  input [1:0] rightAddMux_sel;
  input QCorrectBitMux_sel;
  input leftAddMode;
  input rightAddMode;
  input reminder_en;
  input reminder_rShift;
  input quotient_en;
  input counterMux_sel;
  input count_upDown;
  input count_load;
  input count_en;
  input counterReg_en;
  input csa_clear;
  output tc;
  output signS;
  output [1:0] magnitudeD;
  //signals
  logic [parallelism:0] signCorrection_to_DivisorReg;
  logic [parallelism:0] signCorrection_to_DividendReg;
  logic [parallelism:0] divisor_to_kernelLogic;
  logic [parallelism:0] notDivisor_to_kernelLogic;
  logic [parallelism:0] leftAdder_to_outReg;
  logic [parallelism+2:0] sumH_to_cond;
  logic SignSel;
  logic Non0;
  logic newNQ;
  logic newQ;
  logic [parallelism:0] kl_to_csa;
  logic [parallelism+1:0] csaSum_to_outReg;
  logic [parallelism+2:0] dividendMux_to_sumHReg;
  logic [parallelism-1:0] newQBitAdder_to_sumL;
  logic [parallelism-1:0] sumL_to_newQBitAdder;
  logic [parallelism-1:0] newQBitAdder_to_carryL;
  logic [parallelism-1:0] carryL_to_newQBitAdder;
  logic [parallelism+1:0] sum_to_csa;
  logic [parallelism+1:0] csaCarry_to_outReg;
  logic [parallelism+2:0] carryH_to_cond;
  logic [parallelism+1:0] carry_to_csa;
  logic [parallelism:0] leftOpleftAdd;
  logic [parallelism:0] rightOpleftAdd;
  logic [parallelism-1:0] leftOprightAdd;
  logic [parallelism-1:0] rightOprightAdd;
  logic [parallelism-1:0] quotientCorrectBit;
  logic [parallelism-1:0] rightAdder_to_outReg;
  logic [parallelism+1:0] reminderOutReg;
  logic [5:0] counterMux_to_counter;
  logic [5:0] counterOut_to_counterReg;
  logic [5:0] counterRegOut;
  //begin describing architecture

  //dividing by 2 if datas are unsigned
  assign signCorrection_to_DivisorReg = (usigned) ? {1'b0,divisor[parallelism-1:0]} : {divisor[parallelism-1],divisor[parallelism-1:0]};
  assign signCorrection_to_DividendReg = (usigned) ? {1'b0,dividend[parallelism-1:0]} : {dividend[parallelism-1],dividend[parallelism-1:0]};

  //divisor shift register
  shiftRegister #(parallelism+1) divisorRegister (  .parallelIn(signCorrection_to_DivisorReg),
                                                    .parallelOut(divisor_to_kernelLogic),
                                                    .clk(clk),
                                                    .rst_n(rst_n),
                                                    .clear(csa_clear),
                                                    .sample_en(divisor_en),
                                                    .shiftLeft(divisor_lShift),
                                                    .shiftRight(1'b0),
                                                    .newBit(1'b0));
  assign magnitudeD = divisor_to_kernelLogic[parallelism-1:parallelism-2];

  //~divisor register
  register #(parallelism+1) notDivisorRegister (  .parallelIn(leftAdder_to_outReg),
                                                  .parallelOut(notDivisor_to_kernelLogic),
                                                  .clk(clk),
                                                  .rst_n(rst_n),
                                                  .clear(csa_clear),
                                                  .sample_en(notDivisor_en));

  kernelLogic #(.parallelism(parallelism)) KL ( .data(divisor_to_kernelLogic),
                                                .notData(notDivisor_to_kernelLogic),
                                                .saveReminder(saveReminder),
                                                .opCode({2'b11,usigned}),
                                                .sumMSBs(sumH_to_cond[parallelism+2:parallelism-2]), //4 in this case
                                                .carryMSBs(carryH_to_cond[parallelism+2:parallelism-2]),
                                                .SignSel(SignSel),
                                                .Non0(Non0),
                                                .outData(kl_to_csa),
                                                .d_MSB(signCorrection_to_DivisorReg[parallelism]));

  //mux access to sumH 35 bits (3.32)
  mux2to1 #(parallelism+3) sumHMux ( .inA({signCorrection_to_DividendReg[parallelism],signCorrection_to_DividendReg[parallelism],signCorrection_to_DividendReg}), //we need to multiply *2
                                    .inB({csaSum_to_outReg[parallelism+1:0],1'b0}),
                                    .out(dividendMux_to_sumHReg),
                                    .sel(sumHMux_sel));

  //sumH register
  register #(parallelism+3) sumH (  .parallelIn(dividendMux_to_sumHReg),
                                    .parallelOut(sumH_to_cond),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(csa_clear),
                                    .sample_en(sum_en));
  //if it's the last step we need to divide by 2
  // since it was already done automatically at the previous step
  assign sum_to_csa = (saveReminder) ? {sumH_to_cond[parallelism+2:1]} : sumH_to_cond[parallelism+1:0];


  //sumL register
  register #(parallelism) sumL (  .parallelIn(newQBitAdder_to_sumL),
                                  .parallelOut(sumL_to_newQBitAdder),
                                  .clk(clk),
                                  .rst_n(rst_n),
                                  .clear(csa_clear),
                                  .sample_en(sum_en));
  assign newQ = (Non0 & ~SignSel);
  assign newQBitAdder_to_sumL = {sumL_to_newQBitAdder[parallelism-2:0],newQ};

  //carryH register
  register #(parallelism+3) carryH (  .parallelIn({csaCarry_to_outReg[parallelism:0],2'b0}),
                                    .parallelOut(carryH_to_cond),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(csa_clear),
                                    .sample_en(carry_en));

  //if it's the last step we need to divide by 2
  // since it was already done automatically at the previous step
  assign carry_to_csa = (saveReminder) ? {carryH_to_cond[parallelism+2:1]} : carryH_to_cond[parallelism+1:0];


  //carryL register
  register #(parallelism) carryL (  .parallelIn(newQBitAdder_to_carryL),
                                  .parallelOut(carryL_to_newQBitAdder),
                                  .clk(clk),
                                  .rst_n(rst_n),
                                  .clear(csa_clear),
                                  .sample_en(carry_en));
  assign newNQ = (Non0 & SignSel);
  assign newQBitAdder_to_carryL = {carryL_to_newQBitAdder[parallelism-2:0],newNQ};

  //carrysave adder
  carrySaveAdder #(parallelism+2) csa ( .addendA({kl_to_csa[parallelism],kl_to_csa[parallelism:0]}),
                                      .addendB(sum_to_csa),
                                      .addendC(carry_to_csa),
                                      .sum(csaSum_to_outReg),
                                      .carry(csaCarry_to_outReg));

  //muxleft operand left adder
  mux4to1 #(parallelism+1) leftOpleftAdd_mux (  .inA(csaSum_to_outReg[parallelism:0]),
                                              .inB(~divisor_to_kernelLogic),
                                              .inC(divisor_to_kernelLogic),
                                              .inD(notDivisor_to_kernelLogic),
                                              .out(leftOpleftAdd),
                                              .sel(leftAddMux_sel));
  //mux right operand left adder
  mux4to1 #(parallelism+1) rightOpleftAdd_mux (  .inA({csaCarry_to_outReg[parallelism-1:0],1'b0}),
                                              .inB({parallelism+1{1'b0}}), //remember to set input carry
                                              .inC(reminderOutReg[parallelism+1:1]),
                                              .inD(reminderOutReg[parallelism+1:1]),
                                              .out(rightOpleftAdd),
                                              .sel(leftAddMux_sel));
  //mux left operand right adder
  mux4to1 #(parallelism) leftOprightAdd_mux (  .inA(sumL_to_newQBitAdder),
                                              .inB(quotient),
                                              .inC(~quotient),
                                              .inD(),
                                              .sel(rightAddMux_sel),
                                              .out(leftOprightAdd));
  //mux correct bit
  mux2to1 #(parallelism) QCorrectBit_mux (    .inA({{parallelism-1{1'b0}},1'b1}),
                                              .inB({{parallelism{1'b1}}}),
                                              .out(quotientCorrectBit),
                                              .sel(QCorrectBitMux_sel));

  //mux right op right adder
  mux4to1 #(parallelism) rightOprightAdd_mux (  .inA(~carryL_to_newQBitAdder),
                                              .inB(quotientCorrectBit),
                                              .inC({parallelism{1'b0}}),
                                              .inD(),
                                              .sel(rightAddMux_sel),
                                              .out(rightOprightAdd));
  //left adder
  adder #(parallelism+1) leftAdder (  .add1(leftOpleftAdd),
                                    .add0(rightOpleftAdd),
                                    .carry_in(leftAddMode),
                                    .sum(leftAdder_to_outReg));
  //right adder
  adder #(parallelism) rightAdder (  .add1(leftOprightAdd),
                                    .add0(rightOprightAdd),
                                    .carry_in(rightAddMode),
                                    .sum(rightAdder_to_outReg));
  //reminder
  shiftRegister #(parallelism+2) reminderRegister (  .parallelIn({leftAdder_to_outReg,1'b0}),
                                                    .parallelOut(reminderOutReg),
                                                    .clk(clk),
                                                    .rst_n(rst_n),
                                                    .clear(1'b0),
                                                    .sample_en(reminder_en),
                                                    .shiftLeft(1'b0),
                                                    .shiftRight(reminder_rShift),
                                                    .newBit(reminderOutReg[parallelism+1]));
  assign signS = (reminderOutReg[parallelism+1]);
  assign reminder = (reminderOutReg[parallelism-1:0]);
  //quotient
  register #(parallelism) quotientReg (  .parallelIn(rightAdder_to_outReg),
                                  .parallelOut(quotient),
                                  .clk(clk),
                                  .rst_n(rst_n),
                                  .clear(1'b0),
                                  .sample_en(quotient_en));
  //counter module
  mux2to1 #(6) counterMux (  .inA(6'b000001),
                              .inB(counterRegOut), //remember to set input carry
                              .out(counterMux_to_counter),
                              .sel(counterMux_sel));
  syncCounter #(6) counter ( .clk(clk),
                            .rst_n(rst_n),
                            .clear(1'b0),
                            .parallelLoad(counterMux_to_counter),
                            .threashold({5'b0,1'b1}),
                            .upDown_n(count_upDown),
                            .load_en(count_load),
                            .cnt_en(count_en),
                            .terminalCount(tc),
                            .parallelOutput(counterOut_to_counterReg));
  register #(6) counterReg (  .parallelIn(counterOut_to_counterReg),
                              .parallelOut(counterRegOut),
                              .clk(clk),
                              .rst_n(rst_n),
                              .clear(1'b0),
                              .sample_en(counterReg_en));

endmodule
