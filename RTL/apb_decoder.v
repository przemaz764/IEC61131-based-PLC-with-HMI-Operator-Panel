module apb_decoder #
(
  parameter               APB_ADDR_W  = 16    // AMBA APB Address width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input  [APB_ADDR_W-1:0] paddr,              // AMBA APB Address
  input                   psel_cpu,           // AMBA APB Select signal (CPU)
  input  [31:0]           prdata_cnt,         // AMBA APB Read Data (CNTs)
  input  [31:0]           prdata_tmr,         // AMBA APB Read Data (TMRs)
  input  [31:0]           prdata_gpio,        // AMBA APB Read Data (GPIOs)
  input  [31:0]           prdata_apb2spi,     // AMBA APB Read Data (APB2SPI)
  input                   pready_cnt,         // AMBA APB Ready signal (CNTs)
  input                   pready_tmr,         // AMBA APB Ready signal (TMRs)
  input                   pready_gpio,        // AMBA APB Ready signal (GPIOs)
  input                   pready_apb2spi,     // AMBA APB Ready signal (APB2SPI)

  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output                  unused_ok,          // Unused signals
  output                  psel_cnt,           // AMBA APB Select signal (CNTs)
  output                  psel_tmr,           // AMBA APB Select signal (TMRs)
  output                  psel_gpio,          // AMBA APB Select signal (GPIOs)
  output                  psel_apb2spi,       // AMBA APB Select signal (APB2SPI)
  output  [31:0]          prdata_cpu,         // AMBA APB Read Data (CPU)
  output                  pready_cpu          // AMBA APB Ready (CPU)
);
  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------
  reg     [31:0]          prdata_cpu_mux;
  reg                     pready_cpu_mux;

  //----------------------------------------------------------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------------------------------------------------------
  localparam APB_ADDR_B  = 11;                // Number of the first paddr bit that can be used for selecitng particular APB-Slave devices
  
  //----------------------------------------------------------------------------------------------------------------------
  // APB Slaves' base addresses
  //----------------------------------------------------------------------------------------------------------------------
  localparam CNT_BASE_A     = 16'h0000;       // CNT module base address
  localparam TMR_BASE_A     = 16'h0800;       // TMR module base address
  localparam APB2SPI_BASE_A = 16'h1000;       // APB2SPI module base address
  localparam GPIO_BASE_A    = 16'h1800;       // GPIO module base address

  //----------------------------------------------------------------------------------------------------------------------
  // APB Select signal decoders
  //----------------------------------------------------------------------------------------------------------------------
  assign psel_cnt     = psel_cpu & (paddr[APB_ADDR_W-1:APB_ADDR_B] == CNT_BASE_A[APB_ADDR_W-1:APB_ADDR_B]);
  assign psel_tmr     = psel_cpu & (paddr[APB_ADDR_W-1:APB_ADDR_B] == TMR_BASE_A[APB_ADDR_W-1:APB_ADDR_B]);
  assign psel_apb2spi = psel_cpu & (paddr[APB_ADDR_W-1:APB_ADDR_B] == APB2SPI_BASE_A[APB_ADDR_W-1:APB_ADDR_B]);
  assign psel_gpio    = psel_cpu & (paddr[APB_ADDR_W-1:APB_ADDR_B] == GPIO_BASE_A[APB_ADDR_W-1:APB_ADDR_B]);
  
  //----------------------------------------------------------------------------------------------------------------------
  // APB Read Data decoder
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
  begin
    case (paddr[APB_ADDR_W-1:APB_ADDR_B])
      CNT_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        prdata_cpu_mux = prdata_cnt;
      TMR_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        prdata_cpu_mux = prdata_tmr;
      APB2SPI_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        prdata_cpu_mux = prdata_apb2spi;
      GPIO_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        prdata_cpu_mux = prdata_gpio;
      default:
        prdata_cpu_mux = 32'd0;
    endcase
  end
  
  assign prdata_cpu = prdata_cpu_mux;
  
  //----------------------------------------------------------------------------------------------------------------------
  // APB Ready decoder
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
  begin
    case (paddr[APB_ADDR_W-1:APB_ADDR_B])
      CNT_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        pready_cpu_mux = pready_cnt;
      TMR_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        pready_cpu_mux = pready_tmr;
      APB2SPI_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        pready_cpu_mux = pready_apb2spi;
      GPIO_BASE_A[APB_ADDR_W-1:APB_ADDR_B]:
        pready_cpu_mux = pready_gpio;
      default:
        pready_cpu_mux = 1'd0;
    endcase
  end
  
  assign pready_cpu = pready_cpu_mux;
  
  //----------------------------------------------------------------------------------------------------------------------
  // Unused signals
  //----------------------------------------------------------------------------------------------------------------------
  assign unused_ok = &paddr[APB_ADDR_B-1:0];

endmodule
