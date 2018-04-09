module control_unit #
(
  parameter         DM_ADDR_W = 8, // Data Memory Address Width
  parameter         PM_ADDR_W = 8  // Program Memory Address Width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input             cpu_clk,       // CPU Clock
  input             cpu_resetn,    // CPU Reset
  input [7:0]       instr_code,    // Instruction Code
  input             pready,        // AMBA APB Ready signal
  input             cr_bit,        // Current Result LSb
  input             cpu_run,       // CPU Run state
  
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output reg        psel,          // AMBA APB Select signal
  output reg        penable,       // AMBA APB Enable signal
  output reg        pwrite,        // AMBA APB Write signal
  output reg        cr_en,         // Current Result Register Enable signal
  output reg        dm_en,         // Data Memory Enable signal
  output reg        dm_wr,         // Data Memory Write signal
  output reg        pm_en,         // Program Memory Enable signal
  output reg        ir_en,         // Instruction Register Enable signal
  output reg        pc_en,         // Program Counter Enable signal
  output reg        pc_ld,         // Program Counter Load signal
  output reg        apb_en,        // AMBA APB Enable signal
  output            pclk,          // AMBA APB Clock signal
  output            presetn        // AMBA APB Reset signal
);
  //----------------------------------------------------------------------------------------------------------------------
  // Includes
  //----------------------------------------------------------------------------------------------------------------------
  `include "cpu_program_lib.v"     // Instruction Codes
  
  //----------------------------------------------------------------------------------------------------------------------
  // FSM states
  //----------------------------------------------------------------------------------------------------------------------
  localparam CU_IDLE     = 3'b000; // CPU Idle state
  localparam CU_PHASE_1  = 3'b001; // First clock cycle of the instruction
  localparam CU_PHASE_2  = 3'b010; // Second clock cycle of the instruction
  localparam CU_PHASE_3  = 3'b011; // Third clock cycle of the instruction
  localparam CU_PHASE_4  = 3'b100; // Fourth clock cycle of the instruction
  localparam APB_IDLE    = 2'b00;  // AMBA APB Idle Phase
  localparam APB_SETUP   = 2'b01;  // AMBA APB Setup Phase
  localparam APB_ACCESS  = 2'b10;  // AMBA APB Access Phase
  
  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------
  reg [2:0] cu_cstate;             // Control Unit Main FSM's current state
  reg [2:0] cu_nstate;             // Control Unit Main FSM's next state
  reg [1:0] apb_cstate;            // AMBA APB control FSM's current state
  reg       apb_wr;                // AMBA APB Write signal
  
  //----------------------------------------------------------------------------------------------------------------------
  // AMBA APB signal assignement
  //----------------------------------------------------------------------------------------------------------------------
  assign    pclk    = cpu_clk;     // AMBA APB Clock signal synchronous to cpu_clk
  assign    presetn = cpu_resetn;  // AMBA APB Reset signal tied to the cpu_resetn

  //----------------------------------------------------------------------------------------------------------------------
  // Control Unit Main FSM - combinational
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
  begin
    case (cu_cstate)
      CU_IDLE:
        begin
          cu_nstate   = cpu_run ? CU_PHASE_1 : CU_IDLE;
          pc_ld       = 1'b0;
          pc_en       = 1'b0;
          pm_en       = 1'b1;
          ir_en       = 1'b0;
          cr_en       = 1'b0;
          dm_en       = 1'b0;
          dm_wr       = 1'b0;
          apb_en      = 1'b0;
          apb_wr      = 1'b0;
        end
      CU_PHASE_1:
        case (instr_code)
          LD_I,
          LDN_I,
          AND_I,
          ANDN_I,
          OR_I,
          ORN_I,
          XOR_I,
          XORN_I,
          EQU_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b1;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          ST_I,
          STN_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b1;
              dm_wr       = 1'b1;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          R_I,
          S_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b1;
              dm_wr       = cr_bit;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          F_TRIG_I,
          R_TRIG_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b1;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          LDI_I,
          ANDI_I,
          ORI_I,
          XORI_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b1;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          NOT_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b1;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          JMP_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b1;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          JMPC_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = cr_bit;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          JMPCN_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = ~cr_bit;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          APB_RD_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b1;
              apb_wr      = 1'b0;
            end
          APB_WR_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b1;
              apb_wr      = 1'b1;
            end
          NOP_I:
            begin
              cu_nstate   = CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          default:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
        endcase
      CU_PHASE_2:
        case (instr_code)
          LD_I,
          LDN_I,
          AND_I,
          ANDN_I,
          OR_I,
          ORN_I,
          XOR_I,
          XORN_I,
          EQU_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b1;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          ST_I,
          STN_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          R_I,
          S_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          F_TRIG_I,
          R_TRIG_I:
            begin
              cu_nstate   = CU_PHASE_3;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b1;
              dm_en       = 1'b1;
              dm_wr       = 1'b1;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          LDI_I,
          ANDI_I,
          ORI_I,
          XORI_I:
            begin
              cu_nstate   = CU_PHASE_3;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          NOT_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          JMP_I,
          JMPC_I,
          JMPCN_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          APB_RD_I:
            begin
              cu_nstate   = pready ? CU_PHASE_1 : CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = pready;
              ir_en       = 1'b0;
              cr_en       = pready;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b1;
              apb_wr      = 1'b0;
            end
          APB_WR_I:
            begin
              cu_nstate   = pready ? CU_PHASE_1 : CU_PHASE_2;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = pready;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b1;
              apb_wr      = 1'b1;
            end
          NOP_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          default:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
        endcase
      CU_PHASE_3:
        case (instr_code)
          F_TRIG_I,
          R_TRIG_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          LDI_I,
          ANDI_I,
          ORI_I,
          XORI_I:
            begin
              cu_nstate   = CU_PHASE_4;
              pc_ld       = 1'b0;
              pc_en       = 1'b1;
              pm_en       = 1'b0;
              ir_en       = 1'b0;
              cr_en       = 1'b1;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          default:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
        endcase
      CU_PHASE_4:
        case (instr_code)
          LDI_I,
          ANDI_I,
          ORI_I,
          XORI_I:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
          default:
            begin
              cu_nstate   = CU_PHASE_1;
              pc_ld       = 1'b0;
              pc_en       = 1'b0;
              pm_en       = 1'b1;
              ir_en       = 1'b0;
              cr_en       = 1'b0;
              dm_en       = 1'b0;
              dm_wr       = 1'b0;
              apb_en      = 1'b0;
              apb_wr      = 1'b0;
            end
        endcase
      default:
        begin
          cu_nstate   = CU_IDLE;
          pc_ld       = 1'b0;
          pc_en       = 1'b0;
          pm_en       = 1'b1;
          ir_en       = 1'b0;
          cr_en       = 1'b0;
          dm_en       = 1'b0;
          dm_wr       = 1'b0;
          apb_en      = 1'b0;
          apb_wr      = 1'b0;
        end
    endcase
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // Control Unit Main FSM - sequential
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk or negedge cpu_resetn)
    if (~cpu_resetn)
      cu_cstate <= CU_IDLE;
    else
      cu_cstate <= cu_nstate;
  
  //----------------------------------------------------------------------------------------------------------------------
  // AMBA APB control FSM - sequential
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if (~cpu_resetn)
    begin
      apb_cstate  = APB_IDLE;
      psel        = 1'b0;
      pwrite      = 1'b0;
      penable     = 1'b0;
    end
    else
    case (apb_cstate)
      APB_IDLE:
        begin
          apb_cstate  = apb_en ? APB_SETUP : APB_IDLE;
          psel        = apb_en;
          pwrite      = apb_wr;
          penable     = 1'b0;
        end
      APB_SETUP:
        begin
          apb_cstate  = APB_ACCESS;
          psel        = 1'b1;
          pwrite      = apb_wr;
          penable     = 1'b1;  
        end
      APB_ACCESS:
        begin
          apb_cstate  = pready ? APB_IDLE : APB_ACCESS;
          psel        = ~pready;
          pwrite      = apb_wr;
          penable     = ~pready;  
        end
    endcase
  end

endmodule