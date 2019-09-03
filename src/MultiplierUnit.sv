module MultiplierUnit (clk,rst_n,valid,usigned,multiplier,multiplicand,product,res_ready);
  parameter parallelism=32;
  input clk;
  input rst_n;
  input valid;
  input usigned;
  input [parallelism-1:0] multiplier;
  input [parallelism-1:0] multiplicand;
  output [parallelism*2-1:0] product;
  output res_ready;

  enum bit [2:0] {idle            =3'b000,
                  save_muliplicand=3'b001,
                  save_mulitplier =3'b010,
                  multKernelStep  =3'b011,
                  save_product    =3'b100,
                  multDone         =3'b101} present_state, next_state;

  logic csa_clear;
  logic multiplicand_en;
  logic notMultiplicand_en;
  logic sumMux_sel;
  logic sum_en;
  logic carry_en;
  logic leftAddMux_sel;
  logic count_en;
  logic tc;
  logic rr;
  logic prod_en;

  assign res_ready=rr;

  //instantiating the dp
  MultiplierUnitDP #(parallelism) multiplierDP (.*);

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
              next_state=save_muliplicand;
            end else begin
              next_state=idle;
            end
      save_muliplicand: next_state=save_mulitplier;
      save_mulitplier:  next_state=multKernelStep;
      multKernelStep: if (tc) begin
                        next_state=save_product;
                      end else begin
                        next_state=multKernelStep;
                      end
      save_product: next_state=multDone;
      multDone: next_state=idle;
    endcase
  end

  always_comb begin
    case (present_state)
      idle: begin
        csa_clear=1'b1;
        multiplicand_en=1'b0;
        notMultiplicand_en=1'b0;
        sumMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=1'b0;
        count_en=1'b0;
        prod_en=1'b0;
        rr=1'b0;
      end
      save_muliplicand: begin
        csa_clear=1'b0;
        multiplicand_en=1'b1;
        notMultiplicand_en=1'b0;
        sumMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=1'b0;
        count_en=1'b0;
        prod_en=1'b0;
        rr=1'b0;
      end
      save_mulitplier: begin
        csa_clear=1'b0;
        multiplicand_en=1'b0;
        notMultiplicand_en=1'b1;
        sumMux_sel=1'b0;
        sum_en=1'b1;
        carry_en=1'b0;
        leftAddMux_sel=1'b0;
        count_en=1'b0;
        prod_en=1'b0;
        rr=1'b0;
      end
      multKernelStep: begin
        csa_clear=1'b0;
        multiplicand_en=1'b0;
        notMultiplicand_en=1'b0;
        sumMux_sel=1'b1;
        sum_en=1'b1;
        carry_en=1'b1;
        leftAddMux_sel=1'b0;
        count_en=1'b1;
        prod_en=1'b0;
        rr=1'b0;
      end
      save_product: begin
        csa_clear=1'b0;
        multiplicand_en=1'b0;
        notMultiplicand_en=1'b0;
        sumMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=1'b1;
        count_en=1'b0;
        prod_en=1'b1;
        rr=1'b0;
      end
      multDone: begin
        csa_clear=1'b0;
        multiplicand_en=1'b0;
        notMultiplicand_en=1'b0;
        sumMux_sel=1'b0;
        sum_en=1'b0;
        carry_en=1'b0;
        leftAddMux_sel=1'b0;
        count_en=1'b0;
        prod_en=1'b0;
        rr=1'b1;
      end
    endcase
  end
endmodule
