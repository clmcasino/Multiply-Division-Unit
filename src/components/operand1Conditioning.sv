//operand0 is MULTIPLIER or DIVIDEND
module operand0Conditioning (signalIn,signalOut,opCode);
  parameter PAR=32;
  parameter OPCODE_WIDTH=3;

  input  [PAR-1:0] signalIn;
  output [PAR:0] signalOut;
  input [OPCODE_WIDTH-1:0] opCode;

  logic [PAR:0] signal;
  assign signalOut=signal;

  always_comb begin
    if (opCode[2]==1) begin     //if DIVISION is to be performed
      if (opCode[0]==1) begin   //if UNSIGNED LSB=1
        signal={1'b0,signalIn};
      end else begin            //SIGNED --> sign extension
        signal={signalIn[PAR-1],signalIn};
      end
    end else begin              //MULTIPLICATION (multiplicand )
      if (opCode[1:0]==2'b10) begin   //if UNSIGNED opcode=001 (MULHU)
        signal={1'b0,signalIn};
      end else begin            //SIGNED --> sign extension for MULH or MULHSU
        signal={signalIn[PAR-1],signalIn};
      end
    end
  end
end
