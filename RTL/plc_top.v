module plc_top #
(
  parameter [15:0] GPI_W      = 16,      // GPI width
  parameter [15:0] GPO_W      = 16,      // GPO width
  parameter [15:0] DM_ADDR_W  = 8,       // Data Memory address width
  parameter [15:0] PM_ADDR_W  = 10,      // Program Memory address width
  parameter [15:0] APB_ADDR_W = 16,      // AMBA APB Address width
  parameter [32:0] SYS_FREQ   = 25000000 // System Clock Frequency
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                   cpu_clk,            // CPU clock
  input                   cpu_resetn,         // CPU reset
  input                   spi_mosi,           // SPI Master Output Slave Input
  input                   spi_sck,            // SPI Serial Clock
  input  [GPI_W-1:0]      gpi,                // General Purpose Inputs
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output                  spi_miso,           // SPI Master Input Slave Output
  output                  cpu_run,            // CPU Run state
  output [GPO_W-1:0]      gpo                 // General Purpose Outputs
);
  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------
  wire   [31:0]           pwdata;             // AMBA APB Write Data
  wire   [APB_ADDR_W-1:0] paddr;              // AMBA APB Address
  wire   [31:0]           prdata;             // AMBA APB Read Data
  wire   [31:0]           prdata_cnt;         // AMBA APB Read Data (CNTs)
  wire   [31:0]           prdata_tmr;         // AMBA APB Read Data (TMRs)
  wire   [31:0]           prdata_gpio;        // AMBA APB Read Data (GPIOs)
  wire   [31:0]           prdata_apb2spi;     // AMBA APB Read Data (APB2SPI)
  wire                    psel;               // AMBA APB Select signal
  wire                    psel_cnt;           // AMBA APB Select signal (CNTs)
  wire                    psel_tmr;           // AMBA APB Select signal (TMRs)
  wire                    psel_gpio;          // AMBA APB Select signal (GPIOs)
  wire                    psel_apb2spi;       // AMBA APB Select signal (APB2SPI)
  wire                    pready;             // AMBA APB Ready signal
  wire                    pready_cnt;         // AMBA APB Ready signal (CNTs)
  wire                    pready_tmr;         // AMBA APB Ready signal (TMRs)
  wire                    pready_gpio;        // AMBA APB Ready signal (GPIOs)
  wire                    pready_apb2spi;     // AMBA APB Ready signal (APB2SPI)
  wire                    pclk;               // AMBA APB Clock signal
  wire                    presetn;            // AMBA APB Reset signal
  wire                    penable;            // AMBA APB Enable signal
  wire                    pwrite;             // AMBA APB Write signal
  wire                    spi_miso_cpu;       // SPI MISO (CPU)
  wire                    spi_miso_apb2spi;   // SPI MISO (APB2SPI)
  wire                    spi_nss;            // SPI Select

  //----------------------------------------------------------------------------------------------------------------------
  // CPU instance
  //----------------------------------------------------------------------------------------------------------------------
  cpu_top #
  (
    .DM_ADDR_W  (DM_ADDR_W),
	  .PM_ADDR_W  (PM_ADDR_W),
	  .APB_ADDR_W (APB_ADDR_W)
  )
  i_cpu_top
  (
    .cpu_clk    (cpu_clk_div),
    .cpu_resetn (cpu_resetn),
    .prdata     (prdata),
    .pready     (pready),
    .spi_mosi   (spi_mosi),
    .spi_sck    (spi_sck),
    .pwdata     (pwdata),
    .paddr      (paddr),
    .pclk       (pclk),
    .presetn    (presetn),
    .psel       (psel),
    .penable    (penable),
    .pwrite     (pwrite),
    .spi_miso   (spi_miso_cpu),
    .cpu_run    (cpu_run)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // CNTs instance
  //----------------------------------------------------------------------------------------------------------------------
  licznik #
  (
    .szerokosc        (32),
	  .szerokosc_adresu (11),
	  .adresy_licznikow (10)
  )
  i_licznik
  (
    .PCLK    (pclk),
    .PSEL    (psel_cnt),
    .PADDR   (paddr[10:0]),
    .PWDATA  (pwdata),
    .PRDATA  (prdata_cnt),
    .PENABLE (penable),
    .PWRITE  (pwrite),
    .PREADY  (pready_cnt)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // TMRs instance
  //----------------------------------------------------------------------------------------------------------------------
  tmr_top #
  (
    .FREQ       (SYS_FREQ),
    .ADDR_W     (8),
    .APB_ADDR_W (11)
  )
  i_tmr_top
  (
    .pclk       (pclk),
    .presetn    (presetn),
    .paddr      (paddr[10:0]),
    .psel       (psel_tmr),
    .penable    (penable),
    .pwrite     (pwrite),
    .pwdata     (pwdata),
    .prdata     (prdata_tmr),
    .pready     (pready_tmr)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // GPIOs instance
  //----------------------------------------------------------------------------------------------------------------------
  gpio_top #
  (
    .GPI_W (GPI_W),
    .GPO_W (GPO_W)
  )
  i_gpio_top
  (
    .pclk      (pclk),
    .presetn   (presetn),
    .paddr     (paddr[0]),
    .pwdata    (pwdata),
    .psel      (psel_gpio),
    .penable   (penable),
    .pwrite    (pwrite),
    .gpi       (gpi),
    .prdata    (prdata_gpio),
    .pready    (pready_gpio),
    .gpo       (gpo),
    .unused_ok ()
  );

  //----------------------------------------------------------------------------------------------------------------------
  // APB Decoder instance
  //----------------------------------------------------------------------------------------------------------------------
  apb_decoder #
  (
    .APB_ADDR_W (APB_ADDR_W)
  )
  i_apb_decoder
  (
    .paddr          (paddr),
    .psel_cpu       (psel),
    .prdata_cnt     (prdata_cnt),
    .prdata_tmr     (prdata_tmr),
    .prdata_gpio    (prdata_gpio),
    .prdata_apb2spi (prdata_apb2spi),
    .pready_cnt     (pready_cnt),
    .pready_tmr     (pready_tmr),
    .pready_gpio    (pready_gpio),
    .pready_apb2spi (pready_apb2spi),
    .psel_cnt       (psel_cnt),
    .psel_tmr       (psel_tmr),
    .psel_gpio      (psel_gpio),
    .psel_apb2spi   (psel_apb2spi),
    .prdata_cpu     (prdata),
    .pready_cpu     (pready),
    .unused_ok      ()
  );

  //----------------------------------------------------------------------------------------------------------------------
  // SPI Decoder instance
  //----------------------------------------------------------------------------------------------------------------------
  spi_decoder i_spi_decoder
  (
    .cpu_run          (cpu_run),
    .spi_miso_cpu     (spi_miso_cpu),
    .spi_miso_apb2spi (spi_miso_apb2spi),
    .spi_miso         (spi_miso),
    .spi_nss          (spi_nss)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // APB to SPI Bridge instance
  //----------------------------------------------------------------------------------------------------------------------
  APB2SPI_BRIDGE #
  (
    .ADDR_WIDTH(10)
  )
  i_apb2spi
  (
    .apb_pclk    (pclk),
    .apb_presetn (presetn),
    .apb_psel    (psel_apb2spi),
    .apb_pwrite  (pwrite),
    .apb_penable (penable),
    .apb_paddr   (paddr[9:0]),
    .apb_pwdata  (pwdata),
    .apb_prdata  (prdata_apb2spi),
    .apb_pready  (pready_apb2spi),
    .apb_pslverr (),
    .spi_nss     (spi_nss),
    .spi_mosi    (spi_mosi),
    .spi_sck     (spi_sck),
    .spi_miso    (spi_miso_apb2spi)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // Clock frequency divider
  //----------------------------------------------------------------------------------------------------------------------
  // assign cpu_clk_div = cpu_clk;
  clock i_clk
  (
    .CLK_IN1  (cpu_clk),
    .CLK_OUT1 (cpu_clk_div)
  );

endmodule
