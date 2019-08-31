module MultDivUnitDP (clk,rst_n,opCode,lOp,rOp,result);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input [2:0] opCode;
  input [parallelism-1:0] lOp;
  input [parallelism-1:0] rOp;
  output [parallelism-1:0] result;

  //control signals

  //signals
  logic usignedL,usignedR;
  logic [parallelism:0] signCorrection_to_lOpReg;
  logic [parallelism:0] signCorrection_to_rOpReg;

  //logic for driving usigned signals:
  //opCode  usignedL  usignedR
  //000         /         /
  //001         0         0
  //010         0         1
  //011         1         1
  //100-110     0         0
  //101-111     1         1
  always_comb begin
    case (opCode)
      3'b010:begin
        usignedL=0;
        usignedR=1;
      end
      3'b011:begin
        usignedL=1;
        usignedR=1;
      end
      3'b101:begin
        usignedL=1;
        usignedR=1;
      end
      3'b111:begin
        usignedL=0;
        usignedR=1;
      end
      default: begin
        usignedL=0;
        usignedR=0;
      end;
    endcase
  end

  //sign extension 32->33 bits
  assign signCorrection_to_lOpReg = (usignedL) ? {1'b0,lOp[parallelism-1:0]} : {lOp[parallelism-1],lOp[parallelism-1:0]};
  assign signCorrection_to_rOpReg = (usignedR) ? {1'b0,rOp[parallelism-1:0]} : {rOp[parallelism-1],rOp[parallelism-1:0]};

endmodule
