module DivisorUnit (clk,rst_n,valid,usigned,divisor,dividend,reminder,quotient,res_ready);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input valid;
  input usigned;
  input [parallelism-1:0] divisor;
  input [parallelism-1:0] dividend;
  output [parallelism-1:0] reminder;
  output [parallelism-1:0] quotient;
  output res_ready;

  enum bit [3:0]{   idle          =4'b0000,
                    loadData      =4'b0001,
                    divisorLShift =4'b0011,
                    saveIterLoop  =4'b0100,
                    divKernelStep =4'b0101,
                    computeQ      =4'b0110,
                    waitSignals   =4'b0111,
                    correctDown   =4'b1000,
                    correctUp     =4'b1001,
                    qInv          =4'b1010,
                    remCorrection =4'b1011,
                    divDone       =4'b1100} present_state, next_state;
  //controSignals
  logic divisor_en;
  logic divisor_lShift;
  logic notDivisor_en;
  logic saveReminder;
  logic sumHMux_sel;
  logic sum_en;
  logic carry_en;
  logic [1:0] leftAddMux_sel;
  logic [1:0] rightAddMux_sel;
  logic QCorrectBitMux_sel;
  logic leftAddMode;
  logic rightAddMode;
  logic reminder_en;
  logic reminder_rShift;
  logic quotient_en;
  logic counterMux_sel;
  logic count_upDown;
  logic count_load;
  logic count_en;
  logic counterReg_en;
  logic csa_clear;
  logic tc;
  logic signS;
  logic [1:0] magnitudeD;
  logic signD;
  logic signZ;
  logic divisorReady;
  logic load1;
  logic rr;

  assign res_ready=rr;
  //assigning signs
  always_comb begin
    if (usigned) begin
      signZ=1'b0;
      signD=1'b0;
    end else begin
      signZ=dividend[parallelism-1];
      signD=divisor[parallelism-1];
    end
  end

  //divisor magnitude for lShift
  always_comb begin
    if (divisor[parallelism-1] & usigned) begin
      load1=1'b1;
    end else begin
      load1=1'b0;
    end
  end

  //divisor magnitude for loadCnt1
  always_comb begin
    if (magnitudeD[0] ^ magnitudeD[1]) begin
      divisorReady=1'b1;
    end else begin
      divisorReady=1'b0;
    end
  end

  //instantiating the dp
  DivisorUnitDP #(parallelism) divisorDP (.*);

  //state transition
  always_ff @ (posedge clk) begin
    if (~rst_n)
      present_state<=idle;//reset synchronous
    else
      present_state<=next_state;
  end



  always_comb begin
    case (present_state)
      idle: if (valid) begin
              next_state=loadData;
            end else begin
              next_state=idle;
            end
      loadData: if (load1) begin
                  next_state=saveIterLoop;
                end else begin
                  next_state=divisorLShift;
                end
      divisorLShift:  if (divisorReady) begin
                        next_state=saveIterLoop;
                      end else begin
                        next_state=divisorLShift;
                      end
      saveIterLoop: next_state=divKernelStep;
      divKernelStep:  if (tc) begin
                        next_state=computeQ;
                      end else begin
                        next_state=divKernelStep;
                      end
      computeQ: if (signD) begin
                  next_state=qInv;
                end else begin
                  next_state=waitSignals;
                end
      waitSignals:  if (signS ^ signZ) begin
                      if (signS ^ signD) begin
                        next_state=correctDown;
                      end else begin
                        next_state=correctUp;
                      end
                    end else begin
                      next_state=remCorrection;
                    end
      qInv: if (signS ^ signZ) begin
              if (signS ^ signD) begin
                next_state=correctDown;
              end else begin
                next_state=correctUp;
              end
            end else begin
              next_state=remCorrection;
            end
      correctDown: next_state=remCorrection;
      correctUp:  next_state=remCorrection;
      remCorrection: if (tc) begin
                        next_state=divDone;
                      end else begin
                        next_state=remCorrection;
                      end
      divDone: next_state=idle;
      default: next_state=idle;
    endcase
  end

  always_comb begin
    case (present_state)
      idle: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b1;
        rr=1'b0;
      end

      loadData:begin
        divisor_en=1'b1;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b1;
        sumHMux_sel=1'b0;
        sum_en=1'b1;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b1;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      divisorLShift:begin
        divisor_en=1'b0;
        divisor_lShift=1'b1;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b1;
        count_load=1'b0;
        count_en=1'b1;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      saveIterLoop: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b1;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b01;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b1;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b1;
        csa_clear=1'b0;
        rr=1'b0;
      end

      divKernelStep: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b1;
        sum_en=1'b1;
        carry_en=1'b1;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b1;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      computeQ: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b1;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b1;
        reminder_en=1'b1;
        reminder_rShift=1'b0;
        quotient_en=1'b1;
        counterMux_sel=1'b1;
        count_upDown=1'b0;
        count_load=1'b1;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      waitSignals: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      correctDown: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b10;
        rightAddMux_sel=2'b01;
        QCorrectBitMux_sel=1'b1;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b1;
        reminder_rShift=1'b0;
        quotient_en=1'b1;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      correctUp: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b11;
        rightAddMux_sel=2'b01;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b1;
        reminder_rShift=1'b0;
        quotient_en=1'b1;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      qInv: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b10;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b1;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b1;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      remCorrection: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b1;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b1;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b0;
      end

      divDone: begin
        divisor_en=1'b0;
        divisor_lShift=1'b0;
        notDivisor_en=1'b0;
        saveReminder=1'b0;
        sumHMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=2'b00;
        rightAddMux_sel=2'b00;
        QCorrectBitMux_sel=1'b0;
        leftAddMode=1'b0;
        rightAddMode=1'b0;
        reminder_en=1'b0;
        reminder_rShift=1'b0;
        quotient_en=1'b0;
        counterMux_sel=1'b0;
        count_upDown=1'b0;
        count_load=1'b0;
        count_en=1'b0;
        counterReg_en=1'b0;
        csa_clear=1'b0;
        rr=1'b1;
      end
    endcase
  end
endmodule
