module kernelLogic (data,notData,saveReminder,opCode,sumMSBs,carryMSBs,SignSel,Non0,outData,z_MSB,d_MSB);
  parameter parallelism=32;
  parameter csaBits=4;
  input [parallelism:0] data;
  input [parallelism:0] notData;
  input saveReminder;
  input [2:0] opCode;
  input [csaBits-1:0] sumMSBs;
  input [csaBits-1:0] carryMSBs;
  input z_MSB;
  input d_MSB;
  output SignSel;
  output Non0;
  output [parallelism:0] outData;

  logic [1:0] divisionControl;
  logic signZ,signS,signD;
  //divisionControl combinatory logic
  logic signed [csaBits:0] temp;
  always_comb begin
    //I'm doing a sum but actually is implemented as a PLA or LUT;
    temp=($signed(sumMSBs))+($signed(carryMSBs));
    if (temp<-2) begin
      divisionControl=2'b00;
    end else if (temp>=0) begin
      divisionControl=2'b01;
    end else begin
      divisionControl=2'b11;
    end
  end

  //signZ and signD combinatory logic
  always_comb begin
    if(opCode[0]) begin                 //unsigned
      signZ=0;
      signD=0;
    end else begin
      signZ=z_MSB;
      signD=d_MSB;
    end
  end

  //signS combinatory logic
  always_comb begin
    if (divisionControl==2'b01) begin
      signS=0;
    end else begin
      signS=1;
    end
  end

  logic SS,N0;
  logic signed [parallelism:0] oData;
  assign SignSel=SS;
  assign Non0=N0;
  assign outData=oData;

  //outData driving combinatory logic
  always_comb begin
    if (saveReminder) begin              //case we are in saveReminder STATE
      //assigning by default SignSel and Non0
      SS<=1'b0;
      N0<=1'b0;
      if (signS!=signZ) begin
        if (signS!=signD) begin          //correct DOWN
          if (signD) begin               //divisor NEGATIVE
            oData<=notData;
          end else begin                 //divisor POSITIVE
            oData<=data;
          end
        end else begin                   //correct UP
          if (signD) begin               //divisor NEGATIVE
            oData<=data;
          end else begin                 //divisor POSITIVE
            oData<=notData;
          end
        end
      end else begin                     //case in which reminder is already correct
        oData<={parallelism{1'b0}};
      end
    end else begin
      if (opCode[2]==1'b1) begin        //case DIVISION
        if (!signD) begin    //case divisor is NEGATIVE
          case (divisionControl)
            2'b00: begin
              oData=data;
              SS=1'b1;
              N0=1'b1;
            end
            2'b01: begin
              oData=notData;
              SS=1'b0;
              N0=1'b1;
            end
            default: begin
              oData={parallelism{1'b0}};
              SS=1'b0;
              N0=1'b0;
            end
          endcase
        end else begin                //case divisor is POSITIVE
          case (divisionControl)
            2'b00: begin
              oData=notData;
              SS=1'b1;
              N0=1'b1;
            end
            2'b01: begin
              oData=data;
              SS=1'b0;
              N0=1'b1;
            end
            default: begin
              oData={parallelism{1'b0}};
              SS=1'b0;
              N0=1'b0;
            end
          endcase
        end
      end else begin                    //case MULTIPLICATION
        //assigning by default SignSel and Non0
        SS=1'b0;
        N0=1'b0;
        case (sumMSBs[csaBits-1:csaBits-2])
          2'b10: oData=data; //should be data
          2'b01: oData=notData; // should be notData
          default: oData={parallelism{1'b0}};
        endcase
      end
    end
  end
endmodule //
