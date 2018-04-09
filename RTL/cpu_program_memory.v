module program_memory #
(
  parameter                   DM_ADDR_W  = 8,     // Data Memory Address width
  parameter                   PM_ADDR_W  = 8,     // Program Memory Address width
  parameter                   APB_ADDR_W = 16     // AMBA APB Address width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                       cpu_clk,            // CPU Clock
  input                       cpu_resetn,         // CPU Reset
  input                       spi_mosi,           // SPI Master Output Slave Input
  input                       spi_sck,            // SPI Serial Clock
  input                       apb_en,             // APB FSM Enable signal
  input                       pm_en,              // Program Memory Enable signal
  input                       ir_en,              // Instruction Register Enable signal
  input                       pc_en,              // Program Counter Enable signal
  input                       pc_ld,              // Program Counter Load signal
  
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output reg [APB_ADDR_W-1:0] paddr,              // AMBA APB Address
  output reg                  cpu_run,            // CPU Run state
  output reg                  spi_miso,           // SPI Master Input Slave Output
  output [DM_ADDR_W-1:0]      dm_addr,            // Data Memory cell address (operand)
  output [31:0]               pm_const,           // Program Constant (operand)
  output [ 7:0]               instr_code,         // Instruction Code
  output [ 1:0]               dm_type             // Data Memory Access Type  
);
  //----------------------------------------------------------------------------------------------------------------------
  // Includes
  //----------------------------------------------------------------------------------------------------------------------
  `include "cpu_program_lib.v"                    // Instruction Codes
  
  //----------------------------------------------------------------------------------------------------------------------
  // FSM states
  //----------------------------------------------------------------------------------------------------------------------
  localparam PROG_IDLE  = 2'b00;                  // Programming FSM Idle State
  localparam PROG_INIT  = 2'b01;                  // Programming FSM Initialization State
  localparam PROG_PEND  = 2'b10;                  // Programming FSM Pending State
  localparam PROG_VERIF = 2'b11;                  // Programming FSM Verification State
  
  //----------------------------------------------------------------------------------------------------------------------
  // Internal Signals
  //----------------------------------------------------------------------------------------------------------------------
  reg  [31:0]                pm_array             // Program Memory array
       [(2**PM_ADDR_W)-1:0];                      
  reg  [PM_ADDR_W-1:0]       spi_prog_cnt;        // Programming Counter
  reg  [PM_ADDR_W-1:0]       pc_reg;              // Program Counter Register
  reg  [31:0]                spi_rx_reg;          // SPI RX Register
  reg  [31:0]                spi_tx_reg;          // SPI TX Register
  reg  [31:0]                spi_rx_checksum;     // SPI RX Checksum Register
  reg  [31:0]                pm_reg;              // Program Memory output
  reg  [ 7:0]                ir_reg;              // Instruction Register
  reg  [ 5:0]                spi_rx_bit_cnt;      // SPI RX Bit counter
  reg  [ 5:0]                spi_tx_bit_cnt;      // SPI TX Bit counter
  reg  [ 3:0]                spi_sck_reg;         // SPI Serial Clock register
  reg  [ 2:0]                ir_rd_reg;           // Instruction Register Ready signal
  reg  [ 1:0]                prog_cstate;         // Programming FSM Current State
  reg  [ 1:0]                prog_nstate;         // Programming FSM Next State
  reg                        spi_tx_en;           // SPI TX Enable signal
  reg                        spi_rx_bit_cnt_en;   // SPI RX Bit Counter Enable signal
  reg                        spi_tx_bit_cnt_en;   // SPI TX Bit Counter Enable signal
  reg                        spi_prog_cnt_dec;    // Programming Counter Decrement signal
  reg                        spi_prog_cnt_en;     // Programming Counter Enable signal
  reg                        spi_prog_cnt_wr;     // Programming Counter Write signal
  reg                        cpu_run_en;          // CPU Run State
  reg                        spi_rx_checksum_en;  // SPI Checksum Register Enable signal
  reg                        spi_prog_cnt_dec_en; // Programming Counter Decrement Enable signal
  reg                        spi_prog_done;       // SPI Programming Done signal
  reg                        pm_wr;               // Program Memory Write signal

  wire [PM_ADDR_W-1:0]       pc_addr;             // Program Counter Load Address
  wire [PM_ADDR_W-1:0]       pm_addr;             // Program Memory Address
  wire [31:0]                pm_in;               // Program Memory Input Data
  wire                       spi_sck_redge;       // SPI Serial Clock Rising Edge
  wire                       spi_sck_fedge;       // SPI Serial Clock Falling Edge
  wire                       spi_rx_bit_32;       // Last Rx bit has been transmitted
  wire                       spi_tx_bit_32;       // Last Tx bit has been transmitted
  wire                       ir_rd;               // Instruction Register has valid Instruction Code
  
  //----------------------------------------------------------------------------------------------------------------------
  // Program Counter
  //---------------------------------------------------------------------------------------------------------------------- 
  always @(posedge cpu_clk or negedge cpu_resetn)
    if (~cpu_resetn)
      pc_reg <= {PM_ADDR_W{1'b0}};
    else if (pc_en)
      pc_reg <= pc_ld ? (pc_addr) :
                        (pc_reg + {{(PM_ADDR_W-1){1'b0}}, 1'b1});
    else
      pc_reg <= pc_reg;

  //----------------------------------------------------------------------------------------------------------------------
  // Instruction Register
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk or negedge cpu_resetn)
    if (~cpu_resetn)
      ir_reg <= 8'd0;
    else if (ir_en)
      ir_reg <= instr_code;

  // Instruction Register Ready signal
  always @(posedge cpu_clk or negedge cpu_resetn)
    if (~cpu_resetn)
      ir_rd_reg <= 3'h0;
    else
      ir_rd_reg <= {ir_rd_reg[1:0], ir_en};
      
  assign ir_rd = |ir_rd_reg;

  //----------------------------------------------------------------------------------------------------------------------
  // Program Memory
  //----------------------------------------------------------------------------------------------------------------------      
  always @(posedge cpu_clk)
  begin
    if (pm_en)
    begin
      if (pm_wr)
      begin
        pm_array[pm_addr] <= pm_in;
        pm_reg            <= pm_in;
      end
      else
      begin
        pm_reg            <= pm_array[pm_addr];
      end
    end
  end
  
  // Program Memory Address
  assign pm_addr = cpu_run ? pc_reg : 
                             spi_prog_cnt;

  // Program Memory Input Data
  assign pm_in   = spi_rx_reg;

  //----------------------------------------------------------------------------------------------------------------------
  // Program Memory outputs
  //----------------------------------------------------------------------------------------------------------------------
  
  // APB Address
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
  if (~cpu_resetn)
    paddr <= {APB_ADDR_W{1'b0}};
  else if (apb_en)
    paddr <= pm_reg[APB_ADDR_W-1:0];
  else
    paddr <= paddr;
  end
  
  // Data Memory Address
  assign dm_addr    = pm_reg[DM_ADDR_W-1:0];
  
  // Data Memory Addressing Type
  assign dm_type    = pm_reg[DM_ADDR_W+1:DM_ADDR_W];
  
  // Instruction Code
  assign instr_code = ir_rd ? (ir_reg) : 
                              (pm_reg[31:24]);
  
  // Program Counter Load Address
  assign pc_addr    = pm_reg[PM_ADDR_W-1:0];
  
  // Program Constant
  assign pm_const   = pm_reg;
  
  //----------------------------------------------------------------------------------------------------------------------
  // Serial Peripheral Interface Controller
  //----------------------------------------------------------------------------------------------------------------------

  // SPI Serial Clock Edges detector
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_sck_reg <= 4'hF;
    else 
      spi_sck_reg <= {spi_sck_reg[2:0], spi_sck};
  end
  
  assign spi_sck_redge = ~spi_sck_reg[3] & (&spi_sck_reg[2:0]);
  assign spi_sck_fedge = spi_sck_reg[3] & (~|spi_sck_reg[2:0]);
  
  // SPI RX Register
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_rx_reg <= 32'd0;
    else if (spi_sck_redge)
      spi_rx_reg <= {spi_mosi, spi_rx_reg[31:1]};
    else
      spi_rx_reg <= spi_rx_reg;
  end
  
  // SPI RX Bit Counter
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_rx_bit_cnt <= 6'd0;
    else if (spi_rx_bit_32)
      spi_rx_bit_cnt <= 6'd0;
    else if (spi_rx_bit_cnt_en)
      spi_rx_bit_cnt <= spi_rx_bit_cnt + 6'd1;
    else
      spi_rx_bit_cnt <= spi_rx_bit_cnt;
  end
  
  assign spi_rx_bit_32 = spi_rx_bit_cnt == 6'd32;
  
  // SPI TX register
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_miso <= 1'b1;
    else if (spi_tx_en)
      spi_miso <= spi_rx_checksum[spi_tx_bit_cnt[4:0]];
  end
  
  // SPI TX bit counter
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_tx_bit_cnt <= 6'd0;
    else if (spi_tx_bit_32)
      spi_tx_bit_cnt <= 6'd0;
    else if (spi_tx_bit_cnt_en)
      spi_tx_bit_cnt <= spi_tx_bit_cnt + 6'd1;
    else
      spi_tx_bit_cnt <= spi_tx_bit_cnt;
  end
  
  assign spi_tx_bit_32 = spi_tx_bit_cnt == 6'd33;
  
  // SPI Programming Counter
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_prog_cnt <= {PM_ADDR_W{1'b0}};
    else if (spi_prog_cnt_wr)
      spi_prog_cnt <= spi_rx_reg[PM_ADDR_W-1:0];
    else if (spi_prog_cnt_en)
      spi_prog_cnt <= spi_prog_cnt - {{PM_ADDR_W-1{1'b0}}, 1'b1};
    else
      spi_prog_cnt <= spi_prog_cnt;
  end
  
  // SPI Programming Counter Decrement
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_prog_cnt_dec <= 1'b0;
    else if (spi_prog_cnt_dec_en)
      spi_prog_cnt_dec <= spi_rx_bit_32;
    else
      spi_prog_cnt_dec <= spi_prog_cnt_dec;
  end

  // SPI Programming Done
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_prog_done <= 1'b0;
    else
      spi_prog_done <= spi_prog_cnt_dec_en & spi_rx_bit_32 & ~|spi_prog_cnt;
  end
  
  // SPI RX Checksum Accumulator
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      spi_rx_checksum <= 32'd0;
    else if (spi_rx_checksum_en)
      spi_rx_checksum <= spi_rx_checksum + spi_rx_reg;
    else
      spi_rx_checksum <= spi_rx_checksum;
  end
  
  // SPI RX Checksum Comparator
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if(~cpu_resetn)
      cpu_run <= 1'd0;
    else if (cpu_run_en)
      cpu_run <= spi_rx_checksum == spi_rx_reg;
    else
      cpu_run <= cpu_run;
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // Programming controller FSM - combinational
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
  begin
    case (prog_cstate)
      PROG_IDLE:
        begin
          prog_nstate         = cpu_run ? PROG_IDLE : PROG_INIT;
          spi_prog_cnt_en     = 1'b0;
          spi_prog_cnt_wr     = 1'b0;
          spi_prog_cnt_dec_en = 1'b0;
          spi_rx_bit_cnt_en   = 1'b0;
          spi_tx_bit_cnt_en   = 1'b0;
          spi_rx_checksum_en  = 1'b0;
          spi_tx_en           = 1'b0;
          pm_wr               = 1'b0;
          cpu_run_en          = 1'b0;
        end
      PROG_INIT:
        begin
          prog_nstate         = ~spi_rx_bit_32 ? PROG_INIT : PROG_PEND;
          spi_prog_cnt_en     = 1'b0;
          spi_prog_cnt_wr     = spi_rx_bit_32;
          spi_prog_cnt_dec_en = 1'b0;
          spi_rx_bit_cnt_en   = spi_sck_redge;
          spi_tx_bit_cnt_en   = 1'b0;
          spi_rx_checksum_en  = 1'b0;
          spi_tx_en           = 1'b0;
          pm_wr               = 1'b0;
          cpu_run_en          = 1'b0;
        end
      PROG_PEND:
        begin
          prog_nstate         = ~spi_prog_done ? PROG_PEND : PROG_VERIF;
          spi_prog_cnt_en     = spi_prog_cnt_dec;
          spi_prog_cnt_wr     = 1'b0;
          spi_prog_cnt_dec_en = 1'b1;
          spi_rx_bit_cnt_en   = spi_sck_redge;
          spi_tx_bit_cnt_en   = 1'b0;
          spi_rx_checksum_en  = spi_rx_bit_32;
          spi_tx_en           = 1'b0;
          pm_wr               = spi_rx_bit_32;
          cpu_run_en          = 1'b0;
        end
      PROG_VERIF:
        begin
          prog_nstate         = ~spi_tx_bit_32 ? PROG_VERIF : PROG_IDLE;
          spi_prog_cnt_en     = 1'b0;
          spi_prog_cnt_wr     = 1'b0;
          spi_prog_cnt_dec_en = 1'b0;
          spi_rx_bit_cnt_en   = spi_sck_redge;
          spi_tx_bit_cnt_en   = spi_sck_fedge;
          spi_rx_checksum_en  = 1'b0;
          spi_tx_en           = spi_sck_fedge;
          pm_wr               = 1'b0;
          cpu_run_en          = spi_rx_bit_32;
        end
    endcase
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // Programming controller FSM - sequential
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if (~cpu_resetn)
      prog_cstate <= PROG_IDLE;
    else
      prog_cstate <= prog_nstate;
  end
  
endmodule