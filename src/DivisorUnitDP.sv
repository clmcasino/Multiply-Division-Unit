module DivisorUnitDP (clk,rst_n,usigned_n,divisor,dividend,reminder,quotient,divisor_en,divisor_lShift,notDIvisor_en,save_reminder,sumHMux_sel,sum_en,carry_en,leftAddMux_sel,rightAddMux_sel,QCorrectBitMux_sel,reminder_en,reminder_rShift,quotient_en,counterMux_sel,count_upDown,count_load,count_en,counterReg_en,tc,signS,magnitudeD);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input usigned_n;
  input [parallelism-1:0] divisor;
  input [parallelism-1:0] dividend;
  output [parallelism-1:0] reminder;
  output [parallelism-1:0] quotient;
  //control signals
  input divisor_en;
  input divisor_lShift;
  input notDIvisor_en;
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
  output tc;
  output signS;
  output [1:0] magnitudeD;
  //signals
  logic [parallelism:0] signCorrection_to_DivisorReg;
  logic [parallelism:0] signCorrection_to_DividendReg;
  logic [parallelism:0] divisor_to_kernelLogic;
  logic [parallelism:0] notDivisor_to_kernelLogic;
  logic [parallelism:0] leftAdder_to_outReg;
  logic [parallelism:0] sumH_to_cond;
  logic [parallelism:0] carryH_to_cond;
  logic [parallelism:0] carryH_to_cond;
  logic SignSel;
  logic Non0;
  logic [parallelism:0] kl_to_csa;
  logic [parallelism:0] csaSum_to_outReg;
  logic [parallelism:0] dividendMux_to_sumHReg;
  logic [parallelism:0] sumHReg_to_cond;
  logic [parallelism-1:0] newQBitAdder_to_sumL;
  logic [parallelism-1:0] sumL_to_newQBitAdder;
  logic [parallelism:0] sum_to_csa;
  logic [parallelism:0] csaCarry_to_outReg;
  logic [parallelism:0] carryHReg_to_cond;
  logic [parallelism:0] carry_to_csa;
  logic [parallelism:0] csaCarry_to_outReg;
  logic [parallelism:0] carryHReg_to_cond;
  logic [parallelism:0] leftOpleftAdd;
  logic [parallelism:0] rightOpleftAdd;
  logic [parallelism:0] leftOprightAdd;
  logic [parallelism:0] rightOprightAdd;
  logic [parallelism-1:0] quotientCorrectBit;
  logic [parallelism-1:0] rightAdder_to_outReg;
  logic [parallelism:0] leftAdder_to_outReg;
  logic [parallelism:0] reminderOutReg;
  logic [5:0] counterMux_to_counter;
  logic [5:0] counterOut_to_counterReg;
  logic [5:0] counterRegOut;
  //begin describing architecture

  //dividing by 2 if datas are unsigned
  assign signCorrection_to_DivisorReg = (usigned_n) ? {1'b0,divisor[parallelism-1:0]} : {divisor[parallelism-1:0],1'b0}
  assign signCorrection_to_DividendReg = (usigned_n) ? {1'b0,dividend[parallelism-1:0]} : {dividend[parallelism-1:0],1'b0}

  //divisor shift register
  shiftRegister #(parallelism+1) divisorRegister (  .parallelIn(signCorrection_to_DivisorReg),
                                                    .parallelOut(divisor_to_kernelLogic),
                                                    .clk(clk),
                                                    .rst_n(rst_n),
                                                    .clear(1'b0),
                                                    .sample_en(divisor_en),
                                                    .shiftLeft(divisor_lShift),
                                                    .shiftRight(1'b0),
                                                    .newBit(1'b0));
  assign magnitudeD = divisor_to_kernelLogic[parallelism:parallelism-1];

  //~divisor register
  register #(parallelism+1) notDivisorRegister (  .parallelIn(leftAdder_to_outReg),
                                                  .parallelOut(notDivisor_to_kernelLogic),
                                                  .clk(clk),
                                                  .rst_n(rst_n),
                                                  .clear(1'b0),
                                                  .sample_en(notDIvisor_en));
  kernelLogic #(.parallelism(parallelism)) KL ( .data(divisor_to_kernelLogic),
                                                .notData(notDivisor_to_kernelLogic),
                                                .saveReminder(save_reminder),
                                                .opCode({2'b1,~usigned_n}),
                                                .sumMSBs(sumH_to_cond[parallelism:parallelism-4]), //4 in this case
                                                .carryMSBs(carryH_to_cond[parallelism:parallelism-4]),
                                                .SignSel(SignSel),
                                                .Non0(Non0),
                                                .outData(kl_to_csa),
                                                .d_MSB(signCorrection_to_DivisorReg[parallelism]));

  //mux access to sumH
  mux2to1 #(parallelism+1) sumHMux (  .inA(signCorrection_to_DividendReg),
                                    .inB({csaSum_to_outReg[parallelism-1,0],1'b0}),
                                    .out(dividendMux_to_sumHReg),
                                    .sel(sumHMux_sel));

  //sumH register
  register #(parallelism+1) sumH (  .parallelIn(dividendMux_to_sumHReg),
                                    .parallelOut(sumHReg_to_cond),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(1'b0),
                                    .sample_en(sum_en));
  //if it's the last step we need to divide by 2
  // since it was already done automatically at the previous step
  assign sum_to_csa = (save_reminder) ? {1'b0,sumHReg_to_cond[parallelism-1:0]} : sumHReg_to_cond;

  //sumL register
  register #(parallelism) sumL (  .parallelIn(newQBitAdder_to_sumL),
                                  .parallelOut(sumL_to_newQBitAdder),
                                  .clk(clk),
                                  .rst_n(rst_n),
                                  .clear(1'b0),
                                  .sample_en(sum_en));
  assign newQBitAdder_to_sumL = {sumL_to_newQBitAdder[parallelism-2:0],Non0 and ~SignSel};

  //carryH register
  register #(parallelism+1) carryH (  .parallelIn(csaCarry_to_outReg[parallelism-1,0],1'b0),
                                    .parallelOut(carryHReg_to_cond),
                                    .clk(clk),
                                    .rst_n(rst_n),
                                    .clear(1'b0),
                                    .sample_en(carry_en));

  //if it's the last step we need to divide by 2
  // since it was already done automatically at the previous step
  assign carry_to_csa = (save_reminder) ? {1'b0,carryHReg_to_cond[parallelism-1:0]} : carryHReg_to_cond;

  //carryL register
  register #(parallelism) carryL (  .parallelIn(newQBitAdder_to_carryL),
                                  .parallelOut(carryL_to_newQBitAdder),
                                  .clk(clk),
                                  .rst_n(rst_n),
                                  .clear(1'b0),
                                  .sample_en(carry_en));
  assign newQBitAdder_to_carryL = {carryL_to_newQBitAdder[parallelism-2:0],Non0 and SignSel};

  //carrysave adder
  carrySaveAdder #(parallelism) csa ( .addendA(kl_to_csa),
                                      .addendB(sum_to_csa),
                                      .addendC(carry_to_csa),
                                      .sum(csaSum_to_outReg),
                                      .carry(csaCarry_to_outReg));

  //muxleft operand left adder
  mux4to1 #(parallelism+1) leftOpleftAdd_mux (  .inA(csaSum_to_outReg),
                                              .inB(~divisor_to_kernelLogic),
                                              .inC(divisor_to_kernelLogic),
                                              .inD(notDivisor_to_kernelLogic),
                                              .out(leftOpleftAdd),
                                              .sel(leftAddMux_sel));
  //mux right operand left adder
  mux4to1 #(parallelism+1) rightOpleftAdd_mux (  .inA(csaCarry_to_outReg),
                                              .inB({parallelism+1{1'b0}}), //remember to set input carry
                                              .inC(reminderOutReg),
                                              .inD(),
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
  mux2to1 #(parallelism) QCorrectBit_mux (  .inA({{parallelism{1'b1}}),
                                              .inB({{parallelism-1{1'b0}},1'b1}), //remember to set input carry
                                              .out(quotientCorrectBit),
                                              .sel(QCorrectBitMux_sel));

  //mux right op right adder
  mux4to1 #(parallelism) rightOprightAdd_mux (  .inA(sumL_to_newQBitAdder),
                                              .inB(quotient),
                                              .inC(~quotient),
                                              .inD(),
                                              .sel(rightAddMux_sel),
                                              .out(leftOprightAdd));
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
  shiftRegister #(parallelism+1) reminderRegister (  .parallelIn(leftAdder_to_outReg),
                                                    .parallelOut(reminderOutReg),
                                                    .clk(clk),
                                                    .rst_n(rst_n),
                                                    .clear(1'b0),
                                                    .sample_en(reminder_en),
                                                    .shiftLeft(1'b0),
                                                    .shiftRight(reminder_rShift),
                                                    .newBit(leftAdder_to_outReg[parallelism]));
  assign signS = (reminderOutReg[parallelism]);
  assign reminder = (reminderOutReg[parallelism-1:0]);
  //quotient
  register #(parallelism) quotient (  .parallelIn(rightAdder_to_outReg),
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
                            .threashold(1'b000000),
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
