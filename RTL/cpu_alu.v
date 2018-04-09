module alu #
(
  parameter              DM_ADDR_W = 8, // Data Memory address width
  parameter              PM_ADDR_W = 8  // Program Memory address width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input [ 7:0]           instr_code,    // Instruction Code
  input [31:0]           dm_out,        // Data Memory output
  input [31:0]           cr_out,        // Current Result
  input [31:0]           pm_const,      // Program Constant (operand)
  input [ 1:0]           dm_type,       // Data Memory access type (Program Memory)
  
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output reg [31:0]      alu_out_cr,    // ALU output to Current Result Register
  output reg [31:0]      alu_out_dm     // ALU output to Data Memory
);
  //----------------------------------------------------------------------------------------------------------------------
  // Includes
  //----------------------------------------------------------------------------------------------------------------------
  `include "cpu_program_lib.v"          // Instruction Codes
  
  //----------------------------------------------------------------------------------------------------------------------
  // Data Memory access types
  //----------------------------------------------------------------------------------------------------------------------
  localparam             BIT   = 2'b00; // 1-bit Data Memory access type
  localparam             BYTE  = 2'b01; // 8-bit Data Memory access type
  localparam             WORD  = 2'b10; // 16-bit Data Memory access type
  localparam             DWORD = 2'b11; // 32-bit Data Memory access type

  //----------------------------------------------------------------------------------------------------------------------
  // ALU
  //---------------------------------------------------------------------------------------------------------------------- 
  always @(*)
  begin
    case (instr_code)
      LD_I:
        begin
          alu_out_cr = dm_out;
          alu_out_dm = 32'd0;
        end
      LDN_I:
        begin
          alu_out_cr = ~dm_out;
          alu_out_dm = 32'd0;
        end
      LDI_I:
        begin
          alu_out_cr = pm_const;
          alu_out_dm = 32'd0;
        end
      SR_I:
        begin
          alu_out_cr = {cr_out[0], cr_out[31:1]};
          alu_out_dm = 32'd0;
        end
      SL_I:
        begin
          alu_out_cr = {cr_out[30:0], cr_out[31]};
          alu_out_dm = 32'd0;
        end
      AND_I:
        begin
          alu_out_cr = cr_out & dm_out;
          alu_out_dm = 32'd0;
        end
      ANDN_I:
        begin
          alu_out_cr = cr_out & ~dm_out;
          alu_out_dm = 32'd0;
        end
      ANDI_I:
        begin
          alu_out_cr = cr_out & pm_const;
          alu_out_dm = 32'd0;
        end
      OR_I:
        begin
          alu_out_cr = cr_out | dm_out;
          alu_out_dm = 32'd0;
        end
      ORN_I:
        begin
          alu_out_cr = cr_out | ~dm_out;
          alu_out_dm = 32'd0;
        end
      ORI_I:
        begin
          alu_out_cr = cr_out | pm_const;
          alu_out_dm = 32'd0;
        end
      XOR_I:
        begin
          alu_out_cr = cr_out ^ dm_out;
          alu_out_dm = 32'd0;
        end
      XORN_I:
        begin
          alu_out_cr = cr_out ^ ~dm_out;
          alu_out_dm = 32'd0;
        end
      XORI_I:
        begin
          alu_out_cr = cr_out ^ pm_const;
          alu_out_dm = 32'd0;
        end
      ST_I:
        begin
          alu_out_cr = 32'd0;
          alu_out_dm = cr_out;
        end
      STN_I:
        begin
          alu_out_cr = 32'd0;
          alu_out_dm = ~cr_out;
        end
      R_I:
        begin
          alu_out_cr = 32'h0000_0000;
          alu_out_dm = 32'h0000_0000;
        end
      S_I:
        begin
          alu_out_cr = 32'h0000_0000;
          alu_out_dm = 32'hFFFF_FFFF;
        end
      F_TRIG_I:
        begin
          alu_out_cr = ~cr_out & dm_out;
          alu_out_dm = cr_out;
        end
      R_TRIG_I:
        begin
          alu_out_cr = cr_out & ~dm_out;
          alu_out_dm = cr_out;
        end
      NOT_I:
        begin
          alu_out_cr = ~cr_out;
          alu_out_dm = 32'd0;
        end
      EQU_I:
        begin
          case (dm_type)
            BIT:
              begin
                alu_out_cr = {31'd0, (cr_out[0] == dm_out[0])};
                alu_out_dm = 32'd0;
              end
            BYTE:
              begin
                alu_out_cr = {31'd0, (cr_out[7:0] == dm_out[7:0])};
                alu_out_dm = 32'd0;
              end
            WORD:
              begin
                alu_out_cr = {31'd0, (cr_out[15:0] == dm_out[15:0])};
                alu_out_dm = 32'd0;
              end
            DWORD:
              begin
                alu_out_cr = {31'd0, (cr_out[31:0] == dm_out[31:0])};
                alu_out_dm = 32'd0;
              end
          endcase
        end
      default:
        begin
          alu_out_cr = 32'd0;
          alu_out_dm = 32'd0;
        end
    endcase
  end

endmodule