module DivisorUnit (clk,rst_n,valid,usigned_n,divisor,dividend,reminder,quotient,res_ready);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input valid;
  input usigned_n;
  input [parallelism-1:0] divisor;
  input [parallelism-1:0] dividend;
  output [parallelism-1:0] reminder;
  output [parallelism-1:0] quotient;
  output res_ready;

  enum {  idle          =4'b0000,
          loadData      =4'b0001,
          loadCnt1      =4'b0010,
          divisorLShift =4'b0011,
          saveIterLoop  =4'b0100,
          divKernelStep =4'b0101,
          computeQ      =4'b0110,
          waitSignals   =4'b0111,
          correctDown   =4'b1000,
          correctUp     =4'b1001,
          qInv          =4'b1010,
          loadIterLoop  =4'b1011,
          remCorrection =4'b1100,
          divDone       =4'b1101} present_state, next_state;
  //controSignals
  logic divisor_en;
  logic divisor_lShift;
  logic notDIvisor_en;
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
  logic tc;
  logic signS;
  logic [1:0] magnitudeD;
  logic signD;
  logic signZ;
  logic divisorReady;

  //assigning signs
  always_comb begin
    if (usigned_n) begin
      signZ=1'b0;
      signD=1'b0;
    end else begin
      signZ=dividend[parallelism-1];
      signD=divisor[parallelism-1];
    end
  end

  //divisor magnitude
  always_comb begin
    if (magnitudeD[1] xor magnitudeD[0]) begin
      divisorReady=1'b1;
    end else begin
      divisorReady=1'b0;
    end
  end

  //instantiating the dp
  DivisorUnitDP #(parallelism) divisorDP (.*);

  //state transition
  always_ff @ (posedge clk) begin
    if (rst)
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
      loadData: if (divisorReady) begin
                  next_state=loadCnt1;
                end else begin
                  next_state=divisorLShift;
                end
      loadCnt1: next_state=saveIterLoop;
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
      computeQ: next_state=waitSignals;
      waitSignals:  if (signS xor signZ) begin
                      if (signS xor signD) begin
                        next_state=correctDown;
                      end else begin
                        next_state=correctUp;
                      end
                    end else begin
                      if (signD) begin
                        next_state=qInv;
                      end else begin
                        next_state=loadIterLoop;
                      end
                    end
      correctDown:  if (signD) begin
                      next_state=qInv;
                    end else begin
                      next_state=loadIterLoop;
                    end
      correctUp:  if (signD) begin
                    next_state=qInv;
                  end else begin
                    next_state=loadIterLoop;
                  end
      qInv: next_state=loadIterLoop;
      loadIterLoop: next_state=remCorrection;
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
      idle:
      loadData:
      loadCnt1:
      divisorLShift:
      saveIterLoop:
      divKernelStep:
      computeQ:
      waitSignals:
      correctDown:
      correctUp:
      qInv:
      loadIterLoop:
      remCorrection:
      divDone:      divisor_en=
                    divisor_lShift=
                    notDIvisor_en=
                    saveReminder=
                    sumHMux_sel=
                    sum_en=
                    carry_en=
                    leftAddMux_sel=
                    rightAddMux_sel=
                    QCorrectBitMux_sel=
                    leftAddMode=
                    rightAddMode=
                    reminder_en=
                    reminder_rShift=
                    quotient_en=
                    counterMux_sel=
                    count_upDown=
                    count_load=
                    count_en=
                    counterReg_en=
                    res_ready=     
    endcase
  end
