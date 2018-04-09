module gpio_top #
(
  parameter               GPI_W  = 16,        // GPI width
  parameter               GPO_W  = 16         // GPO width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                   pclk,               // AMBA APB Clock signal
  input                   presetn,            // AMBA APB Reset signal
  input                   paddr,              // AMBA APB Address
  input  [31:0]           pwdata,             // AMBA APB Write Data
  input                   psel,               // AMBA APB Select signal
  input                   penable,            // AMBA APB Enable signal
  input                   pwrite,             // AMBA APB Write signal
  input  [GPI_W-1:0]      gpi,                // General Purpose Inputs

  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output                  unused_ok,          // Unused signals
  output [31:0]           prdata,             // AMBA APB Read Data
  output                  pready,             // AMBA APB Ready signal
  output [GPO_W-1:0]      gpo                 // General Purpose Outputs
);
  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------
  reg    [GPI_W-1:0]      gpi_reg;            // GPI Register
  reg    [GPO_W-1:0]      gpo_reg;            // GPO Register
  wire                    addressing_gpi;     // AMBA APB Write Data
  wire                    addressing_gpo;     // AMBA APB Write Data
  
  //----------------------------------------------------------------------------------------------------------------------
  // APB Address Decoder
  //----------------------------------------------------------------------------------------------------------------------
  
  // Addressing the GPI register
  assign addressing_gpi = paddr == 1'b0;
  
  // Addressing the GPO register
  assign addressing_gpo = paddr == 1'b1;
  
  //----------------------------------------------------------------------------------------------------------------------
  // GPI Register
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge pclk or negedge presetn)
  begin
    if (~presetn)
      gpi_reg <= {GPI_W{1'b0}};
    else if (psel & addressing_gpi & ~pwrite)
      gpi_reg <= gpi;
    else
      gpi_reg <= gpi_reg;
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // GPO Register
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge pclk or negedge presetn)
  begin
    if (~presetn)
      gpo_reg <= {GPO_W{1'b0}};
    else if (psel & addressing_gpo & pwrite)
      gpo_reg <= pwdata[GPO_W-1:0];
    else
      gpo_reg <= gpo_reg;
  end
  
  assign gpo = gpo_reg;
  
  //----------------------------------------------------------------------------------------------------------------------
  // APB Slave interface
  //----------------------------------------------------------------------------------------------------------------------
  
  // Reverse penable as pready
  assign pready = penable;
  
  // Multiplex prdata based on paddr
  assign prdata = addressing_gpi ? {{32-GPI_W{1'b0}}, gpi_reg}: 
                                   {{32-GPO_W{1'b0}}, gpo_reg};
                                   
  //----------------------------------------------------------------------------------------------------------------------
  // Unused signals
  //----------------------------------------------------------------------------------------------------------------------
  assign unused_ok = &pwdata[31:16];

endmodule
