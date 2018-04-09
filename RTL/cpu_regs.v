module regs #
(
  parameter              DM_ADDR_W = 8, // Data Memory address width
  parameter              PM_ADDR_W = 8  // Program Memory address width
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                  cpu_clk,       // CPU clock
  input                  cpu_resetn,    // CPU reset
  input                  apb_en,        // AMBA APB enable signal
  input                  cr_en,         // Current Result Register enable signal
  input                  dm_en,         // Data Memory enable signal
  input                  dm_wr,         // Data Memory write signal
  input [DM_ADDR_W-1:0]  dm_addr,       // Data Memory cell address (operand; Program Memory)
  input [ 1:0]           dm_type,       // Data Memory access type (Program Memory)      
  input [31:0]           prdata,        // AMBA APB Read Data
  input [31:0]           alu_out_cr,    // ALU output to Current Result Register
  input [31:0]           alu_out_dm,    // ALU output to Data Memory
  
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output     [31:0]      cr_out,        // Current Result
  output reg [31:0]      pwdata,        // AMBA APB Write Data
  output reg [31:0]      dm_out         // Data Memory output
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
  // Internal Signals
  //----------------------------------------------------------------------------------------------------------------------
  reg  [31:0]            cr_reg;        // Current Result Register
  reg  [31:0]            dm_in;         // Data Memory input
  reg  [ 3:0]            dm_en_bit;     // Bit ports enable signal
  reg  [ 3:0]            dm_en_byte;    // Byte ports enable signal
  reg  [ 3:0]            dm_wr_bit;     // Bit ports write signal
  reg  [ 3:0]            dm_wr_byte;    // Byte ports write signal
  reg                    apb_rd;        // AMBA APB ready signal
  
  wire [ 7:0]            dm_out_byte    // Byte ports output signal
       [ 3:0];
  wire [31:0]            cr_in;         // Current Result input multiplexer
  wire [31:0]            dm_in_data;    // Data Memory input data
  wire [ 3:0]            dm_out_bit;    // Bit ports output signal
  
  //----------------------------------------------------------------------------------------------------------------------
  // Registers' Data Sources/Outputs
  //---------------------------------------------------------------------------------------------------------------------- 
  always @(posedge cpu_clk or negedge cpu_resetn)
  if (~cpu_resetn)
    pwdata <= 32'd0;
  else if (apb_en)
    pwdata <= cr_out;
  else
    pwdata <= pwdata;
  
  // Current Result Input Data
  assign cr_in = apb_en ? prdata : alu_out_cr;
  
  //----------------------------------------------------------------------------------------------------------------------
  // Current Result (accumulator)
  //----------------------------------------------------------------------------------------------------------------------
  always @(posedge cpu_clk or negedge cpu_resetn)
    if (~cpu_resetn)
      cr_reg <= 32'd0;
    else if (cr_en)
      cr_reg <= cr_in;
    else
      cr_reg <= cr_reg;
  
  // Current Result Output Data
  assign cr_out = cr_reg;
  
  //----------------------------------------------------------------------------------------------------------------------
  // Data Memory enable signal multiplexer
  //---------------------------------------------------------------------------------------------------------------------- 
  always @(*)
  begin
    case (dm_type)
      BIT:
        begin
          case (dm_addr[4:3])
            2'b00:
              begin
                dm_en_bit  = {4{dm_en}} & 4'b0001;
                dm_wr_bit  = {4{dm_wr}} & 4'b0001;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
            2'b01:
              begin
                dm_en_bit  = {4{dm_en}} & 4'b0010;
                dm_wr_bit  = {4{dm_wr}} & 4'b0010;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
            2'b10:
              begin
                dm_en_bit  = {4{dm_en}} & 4'b0100;
                dm_wr_bit  = {4{dm_wr}} & 4'b0100;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
            2'b11:
              begin
                dm_en_bit  = {4{dm_en}} & 4'b1000;
                dm_wr_bit  = {4{dm_wr}} & 4'b1000;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
            default:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
          endcase  
        end
      BYTE:
        begin
          case (dm_addr[4:3])
            2'b00:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = {4{dm_en}} & 4'b0001;
                dm_wr_byte = {4{dm_wr}} & 4'b0001;
              end
            2'b01:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = {4{dm_en}} & 4'b0010;
                dm_wr_byte = {4{dm_wr}} & 4'b0010;
              end
            2'b10:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = {4{dm_en}} & 4'b0100;
                dm_wr_byte = {4{dm_wr}} & 4'b0100;
              end
            2'b11:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = {4{dm_en}} & 4'b1000;
                dm_wr_byte = {4{dm_wr}} & 4'b1000;
              end
            default:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
          endcase  
        end
      WORD:
        begin
          case (dm_addr[4])
            1'b0:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = {4{dm_en}} & 4'b0011;
                dm_wr_byte = {4{dm_wr}} & 4'b0011;
              end
            1'b1:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = {4{dm_en}} & 4'b1100;
                dm_wr_byte = {4{dm_wr}} & 4'b1100;
              end
            default:
              begin
                dm_en_bit  = 4'b0000;
                dm_wr_bit  = 4'b0000;
                dm_en_byte = 4'b0000;
                dm_wr_byte = 4'b0000;
              end
          endcase  
        end
      DWORD:
        begin
          dm_en_bit  = 4'b0000;
          dm_wr_bit  = 4'b0000;
          dm_en_byte = {4{dm_en}};
          dm_wr_byte = {4{dm_wr}};
        end
      default:
        begin
          dm_en_bit  = 4'b0000;
          dm_wr_bit  = 4'b0000;
          dm_en_byte = 4'b0000;
          dm_wr_byte = 4'b0000;
        end
    endcase
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // Data Memory output multiplexer
  //---------------------------------------------------------------------------------------------------------------------- 
  always @(*)
  begin
    case (dm_type)
      BIT:
        begin
          case (dm_addr[4:3])
            2'b00:
              begin
                dm_out  = {31'd0, dm_out_bit[0]};
              end
            2'b01:
              begin
                dm_out  = {31'd0, dm_out_bit[1]};
              end
            2'b10:
              begin
                dm_out  = {31'd0, dm_out_bit[2]};
              end
            2'b11:
              begin
                dm_out  = {31'd0, dm_out_bit[3]};
              end
            default:
              begin
                dm_out  = 32'd0;
              end
          endcase  
        end
      BYTE:
        begin
          case (dm_addr[4:3])
            2'b00:
              begin
                dm_out  = {24'd0, dm_out_byte[0]};
              end
            2'b01:
              begin
                dm_out  = {24'd0, dm_out_byte[1]};
              end
            2'b10:
              begin
                dm_out  = {24'd0, dm_out_byte[2]};
              end
            2'b11:
              begin
                dm_out  = {24'd0, dm_out_byte[3]};
              end
            default:
              begin
                dm_out  = 32'd0;
              end
          endcase  
        end
      WORD:
        begin
          case (dm_addr[4])
            1'b0:
              begin
                dm_out  = {16'd0, dm_out_byte[1], dm_out_byte[0]};
              end
            1'b1:
              begin
                dm_out  = {16'd0, dm_out_byte[3], dm_out_byte[2]};
              end
            default:
              begin
                dm_out  = 32'd0;
              end
          endcase  
        end
      DWORD:
        begin
          dm_out  = {dm_out_byte[3], dm_out_byte[2], dm_out_byte[1], dm_out_byte[0]};
        end
      default:
        begin
          dm_out  = 32'd0;
        end
    endcase
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // Data Memory input multiplexer
  //----------------------------------------------------------------------------------------------------------------------
  
  // Data Memory Input Data
  assign dm_in_data = alu_out_dm;
  
  always @(*)
  begin
    case (dm_type)
      BIT:
        begin
          dm_in  = {31'd0, dm_in_data[0]};
        end
      BYTE:
        begin
          case (dm_addr[4:3])
            2'b00:
              begin
                dm_in  = {24'd0, dm_in_data[7:0]};
              end
            2'b01:
              begin
                dm_in  = {16'd0, dm_in_data[7:0], 8'd0};
              end
            2'b10:
              begin
                dm_in  = {8'd0, dm_in_data[7:0], 16'd0};
              end
            2'b11:
              begin
                dm_in  = {dm_in_data[7:0], 24'd0};
              end
            default:
              begin
                dm_in  = 32'd0;
              end
          endcase  
        end
      WORD:
        begin
          case (dm_addr[4])
            1'b0:
              begin
                dm_in  = {16'd0, dm_in_data[15:0]};
              end
            1'b1:
              begin
                dm_in  = {dm_in_data[15:0], 16'd0};
              end
            default:
              begin
                dm_in  = 32'd0;
              end
          endcase  
        end
      DWORD:
        begin
          dm_in   = dm_in_data[31:0];
        end
      default:
        begin
          dm_in   = 32'd0;
        end
    endcase
  end
  
  //----------------------------------------------------------------------------------------------------------------------
  // Dual Port Memory instances
  //----------------------------------------------------------------------------------------------------------------------
  genvar i;
  
  generate
  begin: g_data_memory
  for (i = 0; i < 4; i = i + 1)
    begin: i_data_memory
      /*dual_port_ram #
      (
        .DM_ADDR_W(DM_ADDR_W)
      )
      i_dual_port_ram
      (
        .cpu_clk(cpu_clk), 
        .en_bit(dm_en_bit[i]), 
        .en_byte(dm_en_byte[i]), 
        .wr_bit(dm_wr_bit[i]), 
        .wr_byte(dm_wr_byte[i]), 
        .addr_bit({dm_addr[DM_ADDR_W-1:5], dm_addr[2:0]}), 
        .addr_byte(dm_addr[DM_ADDR_W-1:5]), 
        .in_bit(dm_in[0]), 
        .in_byte(dm_in[8*(i+1)-1:8*i]), 
        .out_bit(dm_out_bit[i]), 
        .out_byte(dm_out_byte[i])
      );*/
      blk_mem_gen_0
      i_dual_port_ram
      (
        .clka   (cpu_clk),
        .ena    (dm_en_bit[i]),
        .wea    (dm_wr_bit[i]),
        .addra  ({dm_addr[DM_ADDR_W-1:5], dm_addr[2:0]}),
        .dina   (dm_in[0]),
        .douta  (dm_out_bit[i]),
        .clkb   (cpu_clk),
        .enb    (dm_en_byte[i]),
        .web    (dm_wr_byte[i]),
        .addrb  (dm_addr[DM_ADDR_W-1:5]),
        .dinb   (dm_in[8*(i+1)-1:8*i]),
        .doutb  (dm_out_byte[i])
      );
    end
  end // g_data_memory
  endgenerate
  
endmodule