module dual_port_ram #
(
  parameter              DM_ADDR_W = 8  // Data Memory address width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                  cpu_clk,       // CPU clock
  input                  en_bit,        // Bit port enable signal
  input                  en_byte,       // Byte port enable signal
  input                  wr_bit,        // Bit port write signal
  input                  wr_byte,       // Byte port write signal
  input [DM_ADDR_W-3:0]  addr_bit,      // Bit port address
  input [DM_ADDR_W-6:0]  addr_byte,     // Byte port address
  input                  in_bit,        // Bit port input data
  input [7:0]            in_byte,       // Byte port input data  
  
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output reg             out_bit,       // Bit port input data
  output reg [7:0]       out_byte       // Byte port input data
);
  //----------------------------------------------------------------------------------------------------------------------
  // Memory array
  //----------------------------------------------------------------------------------------------------------------------
  reg [2**(DM_ADDR_W-2)-1:0] array;

  //----------------------------------------------------------------------------------------------------------------------
  // Bit port
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk)
    if (en_bit)
    begin: bit_port
      if (wr_bit)
      begin
        array[addr_bit] <= in_bit;
      end
      else
        out_bit         <= array[addr_bit];
    end

  //----------------------------------------------------------------------------------------------------------------------
  // Byte port
  //----------------------------------------------------------------------------------------------------------------------
  genvar i;
  
  generate 
  for (i = 0; i < 8; i = i + 1)
    begin: byte_port
      localparam [2:0] I = i;
      
      always @(posedge cpu_clk)
        if (en_byte)
          if (wr_byte) 
          begin
            array[{addr_byte, I}] <= in_byte[i];
          end 
          else
            out_byte[i] <= array[{addr_byte, I}];	  
    end
  endgenerate

endmodule