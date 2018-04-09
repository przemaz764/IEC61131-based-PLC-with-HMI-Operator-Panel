module tmr_apb_decoder #
(
  parameter ADDR_W = 8,
  parameter APB_ADDR_W = 16
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input      [APB_ADDR_W-1:0] paddr,
  input                       psel,
  input                       penable,
  input                       pwrite,
  input      [31:0]           tmr_pt_data_out,
  input                       tmr_in_data_out,
  input      [ 1:0]           tmr_type_data_out,
  input      [31:0]           tmr_et_data_out,
  input                       tmr_q_data_out,
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output reg [31:0]           prdata,
  output                      tmr_en,
  output reg                  tmr_pt_wr,
  output reg                  tmr_in_wr,
  output reg                  tmr_type_wr
);
  //----------------------------------------------------------------------------------------------------------------------
  // Local Parameters
  //----------------------------------------------------------------------------------------------------------------------
  localparam REG_TYPE = 3'h0;
  localparam REG_PT   = 3'h1;
  localparam REG_IN   = 3'h2;
  localparam REG_Q    = 3'h3;
  localparam REG_ET   = 3'h4;

  //----------------------------------------------------------------------------------------------------------------------
  // Write Enable Multiplexer
  //----------------------------------------------------------------------------------------------------------------------
  always @ (*)
    case(paddr[2:0])
      REG_TYPE:
      begin
        tmr_pt_wr   = 1'b0;
        tmr_in_wr   = 1'b0;
        tmr_type_wr = psel & penable & pwrite;
      end
      REG_PT:
      begin
        tmr_pt_wr   = psel & penable & pwrite;
        tmr_in_wr   = 1'b0;
        tmr_type_wr = 1'b0;
      end
      REG_IN:
      begin
        tmr_pt_wr   = 1'b0;
        tmr_in_wr   = psel & penable & pwrite;
        tmr_type_wr = 1'b0;
      end
      default:
      begin
        tmr_pt_wr   = 1'b0;
        tmr_in_wr   = 1'b0;
        tmr_type_wr = 1'b0;
      end
    endcase

  //----------------------------------------------------------------------------------------------------------------------
  // Data Output Multiplexer
  //----------------------------------------------------------------------------------------------------------------------
  always @ (*)
    case(paddr[2:0])
      REG_TYPE:
        prdata <= {30'd0, tmr_type_data_out};
      REG_PT:
        prdata <= tmr_pt_data_out;
      REG_IN:
        prdata <= {31'd0, tmr_in_data_out};
      REG_Q:
        prdata <= {31'd0, tmr_q_data_out};
      default: // REG_ET
        prdata <= tmr_et_data_out;
    endcase

  //----------------------------------------------------------------------------------------------------------------------
  // Enable
  //----------------------------------------------------------------------------------------------------------------------
  assign tmr_en = psel;

endmodule