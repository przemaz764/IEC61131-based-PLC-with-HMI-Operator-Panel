module cpu_top #
(
  parameter               DM_ADDR_W  = 6,     // Data Memory address width
  parameter               PM_ADDR_W  = 6,     // Program Memory address width
  parameter               APB_ADDR_W = 16     // AMBA APB Address width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                   cpu_clk,            // CPU clock
  input                   cpu_resetn,         // CPU reset
  input  [31:0]           prdata,             // AMBA APB Read Data
  input                   pready,             // AMBA APB Ready signal
  input                   spi_mosi,           // SPI Master Output Slave Input
  input                   spi_sck,            // SPI Serial Clock
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output [31:0]           pwdata,             // AMBA APB Write Data
  output [APB_ADDR_W-1:0] paddr,              // AMBA APB Address
  output                  pclk,               // AMBA APB Clock signal
  output                  presetn,            // AMBA APB Reset signal
  output                  psel,               // AMBA APB Select signal
  output                  penable,            // AMBA APB Enable signal
  output                  pwrite,             // AMBA APB Write signal
  output                  spi_miso,           // SPI Master Input Slave Output
  output                  cpu_run             // CPU Run state
);
  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------
  reg  [ 1:0]             cpu_resetn_reg;     // CPU Reset Falling Edge detector
  
  wire [DM_ADDR_W-1:0]    dm_addr;            // Data Memory cell address (operand)
  wire [31:0]             alu_out_cr;         // ALU output to Current Result Register
  wire [31:0]             alu_out_dm;         // ALU output to Data Memory
  wire [31:0]             pm_const;           // Program Constant (operand)
  wire [31:0]             cr_out;             // Current Result
  wire [31:0]             dm_out;             // Data Memory output
  wire [ 7:0]             instr_code;         // Instruction Code
  wire [ 1:0]             dm_type;            // Data Memory access type 
  wire                    cpu_resetn_sync;    // CPU Reset synchronized do cpu_clk domain
  wire                    pm_en;              // Program Memory enable signal
  wire                    pc_en;              // Program Counter enable signal
  wire                    pc_ld;              // Program Counter load signal
  wire                    ir_en;              // Instruction Register enable signal
  wire                    cr_en;              // Current Result Register enable signal
  wire                    dm_en;              // Data Memory enable signal
  wire                    dm_wr;              // Data Memory write signal
  wire                    apb_en;             // AMBA APB enable signal  
  
  //----------------------------------------------------------------------------------------------------------------------
  // Reset synchronizing 
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk or negedge cpu_resetn)
  begin
    if (~cpu_resetn)
      cpu_resetn_reg <= 2'b00;
    else
      cpu_resetn_reg <= {cpu_resetn_reg[0], 1'b1};
  end
  
  assign cpu_resetn_sync = cpu_resetn_reg[1];
  
  //----------------------------------------------------------------------------------------------------------------------
  // Control Unit instance
  //----------------------------------------------------------------------------------------------------------------------
  control_unit #
  (
    .DM_ADDR_W(DM_ADDR_W),
    .PM_ADDR_W(PM_ADDR_W)
  )
  i_control_unit
  (
    .cpu_clk(cpu_clk), 
    .cpu_resetn(cpu_resetn_sync), 
    .pready(pready),
    .cr_bit(cr_out[0]), 
    .instr_code(instr_code),
    .cpu_run(cpu_run),
    .pclk(pclk), 
    .presetn(presetn), 
    .psel(psel), 
    .penable(penable), 
    .pwrite(pwrite), 
    .cr_en(cr_en), 
    .dm_en(dm_en), 
    .dm_wr(dm_wr), 
    .pm_en(pm_en), 
    .ir_en(ir_en), 
    .pc_en(pc_en), 
    .pc_ld(pc_ld), 
    .apb_en(apb_en)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // Program Memory instance
  //----------------------------------------------------------------------------------------------------------------------
  program_memory #
  (
    .DM_ADDR_W(DM_ADDR_W),
    .PM_ADDR_W(PM_ADDR_W),
    .APB_ADDR_W(APB_ADDR_W)
  )
  i_program_memory
  (
    .cpu_clk(cpu_clk), 
    .cpu_resetn(cpu_resetn_sync),
    .apb_en(apb_en), 
    .spi_mosi(spi_mosi), 
    .spi_sck(spi_sck), 
    .pm_en(pm_en), 
    .ir_en(ir_en), 
    .pc_en(pc_en), 
    .pc_ld(pc_ld), 
    .paddr(paddr), 
    .cpu_run(cpu_run), 
    .instr_code(instr_code), 
    .dm_addr(dm_addr), 
    .dm_type(dm_type), 
    .pm_const(pm_const),
    .spi_miso(spi_miso)
  );
  
  //----------------------------------------------------------------------------------------------------------------------
  // ALU instance
  //----------------------------------------------------------------------------------------------------------------------
  alu #
  (
    .DM_ADDR_W(DM_ADDR_W),
    .PM_ADDR_W(PM_ADDR_W)
  )
  i_alu
  (
    .instr_code(instr_code), 
    .dm_out(dm_out), 
    .cr_out(cr_out), 
    .pm_const(pm_const), 
    .alu_out_cr(alu_out_cr),
    .dm_type(dm_type),
    .alu_out_dm(alu_out_dm)
  );
  
  //----------------------------------------------------------------------------------------------------------------------
  // Registers instance
  //----------------------------------------------------------------------------------------------------------------------
  regs #
  (
    .DM_ADDR_W(DM_ADDR_W),
    .PM_ADDR_W(PM_ADDR_W)
  )
  i_regs
  (
    .cpu_clk(cpu_clk), 
    .cpu_resetn(cpu_resetn_sync),
    .apb_en(apb_en),
    .cr_en(cr_en), 
    .dm_en(dm_en), 
    .dm_wr(dm_wr), 
    .dm_addr(dm_addr), 
    .dm_type(dm_type), 
    .prdata(prdata), 
    .alu_out_cr(alu_out_cr), 
    .alu_out_dm(alu_out_dm), 
    .cr_out(cr_out), 
    .pwdata(pwdata), 
    .dm_out(dm_out)
  );
    
endmodule
