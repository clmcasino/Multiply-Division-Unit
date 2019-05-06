//es. -->  out[2:0]={in[0],in[1],in[2]}
//tested
module revertingBlock (signalIn,signalOut,rev_en);
  parameter width=32;
  input  [width-1:0] signalIn;
  output [width-1:0] signalOut;
  input rev_en;

  logic [width-1:0] temp;
  assign signalOut = (rev_en) ? {<<{signalIn}} : signalIn;
  //<< is for reverting blocks!
endmodule
