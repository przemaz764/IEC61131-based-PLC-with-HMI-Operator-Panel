module spi_decoder #
(
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input  cpu_run,
  input  spi_miso_cpu,
  input  spi_miso_apb2spi,

  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output spi_miso,
  output spi_nss
);
  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------
  reg spi_miso_mux;

  //----------------------------------------------------------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------------------------------------------------------
  localparam SPI_CPU     = 1'd0;
  localparam SPI_SPI2APB = 1'd1;
  
  //----------------------------------------------------------------------------------------------------------------------
  // SPI MISO Multiplexer
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
  begin
    case (cpu_run)
      SPI_CPU:
        spi_miso_mux = spi_miso_cpu;
      SPI_SPI2APB:
        spi_miso_mux = spi_miso_apb2spi;
    endcase
  end
  
  assign spi_miso = spi_miso_mux;

  //----------------------------------------------------------------------------------------------------------------------
  // SPI NSS for Bridge
  //----------------------------------------------------------------------------------------------------------------------
  assign spi_nss = ~cpu_run;
  
endmodule