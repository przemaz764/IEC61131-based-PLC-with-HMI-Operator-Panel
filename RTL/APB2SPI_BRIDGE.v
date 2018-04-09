module APB2SPI_BRIDGE
(
//Inputs
  apb_psel, apb_pwrite, apb_penable, apb_paddr, apb_pwdata, apb_pclk, apb_presetn,
  spi_nss, spi_mosi, spi_sck,
//Outputs
  apb_prdata, apb_pready, apb_pslverr,
  spi_miso
);

//Global parametres
  parameter DATA_WIDTH       = 32;
  parameter SPI_DATA_WIDTH   = 8; //Raspberry PI requirement
  parameter ADDR_WIDTH       = 8;
  parameter PACKET_SIZE      = 32; //Power of two!
  parameter FIFO_DEPTH       = 16; 
  
  //Internal structure
    parameter REGISTERS_BASE_ADDR     =  6'h00;
    parameter CONTROL_REG_OFFSET      =  6'h00;
    parameter APB_STATE_OFFSET        =  6'h01;
    parameter SPI_STATE_OFFSET        =  6'h02;
    parameter STATUS_OFFSET           =  6'h03;
    parameter TX_FIFO_OFFSET          =  6'h04;
    parameter TX_FIFO_RDADDR_OFFSET   =  6'h05;
    parameter TX_FIFO_WRADDR_OFFSET   =  6'h06;
    parameter RX_FIFO_OFFSET          =  6'h07;
    parameter RX_FIFO_RDADDR_OFFSET   =  6'h08;
    parameter RX_FIFO_WRADDR_OFFSET   =  6'h09;
    parameter SOFTRESET_OFFSET        =  6'h0f;
    
    parameter SOFTRESET_VECTOR        =  {DATA_WIDTH{1'b1}};
    
//Input pins 
  //apb
  input                  apb_psel;
  input                  apb_pwrite;
  input                  apb_penable;
  input [ADDR_WIDTH-1:0] apb_paddr;
  input [DATA_WIDTH-1:0] apb_pwdata; 
  input                  apb_pclk;
  input                  apb_presetn;
  //spi 
  input                  spi_nss;
  input                  spi_mosi;
  input                  spi_sck;
//Output pins 
  //apb
  output [DATA_WIDTH-1:0] apb_prdata;
  output                  apb_pready;
  output                  apb_pslverr;
  //spi
  output                  spi_miso;

  //global signals
  wire sys_clrn_s = apb_presetn;
  wire sys_clk = apb_pclk;
  
//Global registers 
  reg [7:0] status_reg;
  reg [7:0] control_reg;
  
//Functions 
  function [31:0] CLOG2;
    input [31:0] value;
      begin
        value = value - 1;
          for (CLOG2 = 0; value > 0; CLOG2 = CLOG2 + 1) begin
                value = value >> 1;
          end
      end
  endfunction
  
//APB FSM

  //States
  parameter APB_IDLE          = 2'b00;
  parameter APB_READDATA      = 2'b01;
  parameter APB_WRITEDATA     = 2'b10;
  
  //Registers
  reg                          apb_psel_reg;
  reg  [ADDR_WIDTH-1:0]        apb_paddr_reg;
                               
  reg                          apb2spiwr_reg;
	reg                          spi2apbrd_reg;  
  reg [1:0]                    spi_state_reg;
                              
  reg [1:0]                    apb_state_reg;
                              
  reg [DATA_WIDTH-1:0]         apb_prdata_reg;
  reg [DATA_WIDTH-1:0]         apb_pwdata_reg;
  reg [DATA_WIDTH-1:0]         softreset_reg;
  
  // reg [CLOG2(PACKET_SIZE)-1:0] apb_packetcounter_reg;
  wire [CLOG2(PACKET_SIZE)-1:0] apb_nwords;
  wire [CLOG2(PACKET_SIZE)-1:0] spi_nwords;
  
  // reg                          apb_error_reg, spi_error_reg;
  
  reg                          softreset_reg_reg;
  
  //Wires  
  wire [DATA_WIDTH-1:0]        apb_pwdata_s;
  wire [ADDR_WIDTH-3:0]        apb_paddr_s;
	wire [DATA_WIDTH-1:0]        spi2apbfifo_dataout;
  wire [CLOG2(FIFO_DEPTH):0]   spi2apb_wrptr, spi2apb_rdptr, apb2spi_wrptr, apb2spi_rdptr;  
  wire                         softreset_s;

  assign apb_nwords = apb2spi_wrptr - apb2spi_rdptr;
  assign spi_nwords = spi2apb_wrptr - spi2apb_rdptr;
  assign softreset_s = (softreset_reg_reg == 1'b1) ? 1'b1 : 1'b0; 
  
  always @ (posedge sys_clk or negedge sys_clrn_s) begin
    if(!sys_clrn_s) begin
      softreset_reg     <= {DATA_WIDTH{1'b0}};
      softreset_reg_reg <= 1'b0;
    end
    else begin 
      if(softreset_reg_reg == 1'b1)
        softreset_reg     <= {DATA_WIDTH{1'b0}};
      
      softreset_reg_reg <= (softreset_reg == SOFTRESET_VECTOR) ? 1'b1 : 1'b0;
      
      if((apb_paddr_s == REGISTERS_BASE_ADDR + SOFTRESET_OFFSET) && (apb_psel) && (apb_pwrite))
        softreset_reg <= apb_pwdata_s;
    end
  end
  
  //Assignments
  assign apb_paddr_s = apb_paddr [ADDR_WIDTH-1:2];

  assign apb_prdata   = 
           (apb_paddr_reg == CONTROL_REG_OFFSET)    ? {{24{1'b0}},control_reg} :
           (apb_paddr_reg == APB_STATE_OFFSET)      ? apb_state_reg            :
           (apb_paddr_reg == SPI_STATE_OFFSET)      ? spi_state_reg            :
           (apb_paddr_reg == STATUS_OFFSET)         ? {{24{1'b0}},status_reg}  :
           (apb_paddr_reg == RX_FIFO_OFFSET)        ? apb_prdata_reg           :
           (apb_paddr_reg == RX_FIFO_RDADDR_OFFSET) ? spi2apb_rdptr            :
           (apb_paddr_reg == RX_FIFO_WRADDR_OFFSET) ? spi2apb_wrptr            :
           (apb_paddr_reg == TX_FIFO_RDADDR_OFFSET) ? apb2spi_rdptr            :
           (apb_paddr_reg == TX_FIFO_WRADDR_OFFSET) ? apb2spi_wrptr            :
                                                     apb_prdata_reg;
    
  
  assign apb_pready   = apb_psel_reg && apb_penable; 
  assign apb_pwdata_s = apb_pwdata;
  assign apb_pslverr  = 1'b0;
  
  //Main APB FSM
  always @ (posedge sys_clk or negedge sys_clrn_s) begin //sys_clk = apb_pclk
    if(!sys_clrn_s) begin
      apb_state_reg <= APB_IDLE;
    end else begin 
      //if(softreset_s) 
      //  apb_state_reg <= APB_IDLE;
      //else begin 
        case (apb_state_reg)
        
          APB_IDLE: begin
            if(apb_psel) begin 
              if(apb_pwrite) 
                apb_state_reg <= APB_WRITEDATA;
              else  
                apb_state_reg <= APB_READDATA;
            end
            else 
              apb_state_reg <= APB_IDLE;
          end   
        
          APB_READDATA: begin
            if(apb_pready)    
              apb_state_reg <= APB_IDLE;
             else //(~apb_pready) //waitstate
              apb_state_reg <= APB_READDATA;     
          end
         
          APB_WRITEDATA: begin          
            if(apb_pready)
              apb_state_reg <= APB_IDLE;
            else //if (~apb_pready)
              apb_state_reg <= APB_WRITEDATA; //waitstate
          end
        
        default: apb_state_reg <= APB_IDLE;
        endcase
      //end
    end      
  end  
  
  //APB logic
  always @ (posedge sys_clk or negedge sys_clrn_s) begin //sys_clk = apb_pclk
    if (!sys_clrn_s) begin
      apb_psel_reg          <= 1'b0;
      apb2spiwr_reg         <= 1'b0;
      spi2apbrd_reg         <= 1'b0;
      apb_prdata_reg        <= {DATA_WIDTH{1'b0}};
      //apb_packetcounter_reg <= {CLOG2(PACKET_SIZE){1'b0}};
      apb_paddr_reg         <= {ADDR_WIDTH{1'b0}};
      control_reg           <= {8{1'b0}};
    end else begin 
      case (apb_state_reg)
      
        APB_IDLE: begin
          apb_psel_reg      <= 1'b0;
          apb2spiwr_reg     <= 1'b0;
          spi2apbrd_reg     <= 1'b0;
          if(apb_psel) begin
            apb_psel_reg    <= 1'b1;
            apb_paddr_reg   <= apb_paddr_s;
            if(apb_pwrite) begin
              case(apb_paddr_s)
                REGISTERS_BASE_ADDR + TX_FIFO_OFFSET: begin 
                  apb2spiwr_reg <= 1'b1;
                  //apb_packetcounter_reg <= apb_packetcounter_reg + {{(CLOG2(PACKET_SIZE)-1){1'b0}},1'b1};
                end
                REGISTERS_BASE_ADDR + CONTROL_REG_OFFSET:
                  control_reg <= apb_pwdata_s;
                //REGISTERS_BASE_ADDR + SOFTRESET_OFFSET: 
                  //softreset_reg <= apb_pwdata_s;
                default:
                  control_reg <= control_reg;
              endcase 
            end
            else begin 
              if(apb_paddr_s == REGISTERS_BASE_ADDR + RX_FIFO_OFFSET)
              begin
                apb_prdata_reg <= spi2apbfifo_dataout;
                spi2apbrd_reg  <= 1'b1;
                //apb_packetcounter_reg <= apb_packetcounter_reg - {{(CLOG2(PACKET_SIZE)-1){1'b0}},1'b1};
              end
            end
          end
        end
        
        APB_READDATA: 
          spi2apbrd_reg <= 1'b0;  
               
        APB_WRITEDATA: 
          apb2spiwr_reg  <= 1'b0;                
      
      endcase
    end      
  end   
  
  
//SPI FSM 
  //States
  parameter SPI_IDLE          = 2'b00;
  parameter SPI_COMMANDSTEP   = 2'b01;
  parameter SPI_READDATA      = 2'b10;
  parameter SPI_WRITEDATA     = 2'b11;

  //Registers
  reg                          spi_nss_reg;
                               
  reg                          apb2spird_reg;
	reg                          spi2apbwr_reg;
  
  // reg [CLOG2(PACKET_SIZE)-1:0] spi_packetcounter_reg; 
  reg [CLOG2(DATA_WIDTH):0]    spi_wordsize_reg;  
  //reg [CLOG2(DATA_WIDTH):0]  spi_wordsize_reg; //Suitable for iVerilog
  
  reg                          serializer_load_reg;
  
  reg                          rxfifo_write_reg;
  reg                          txfifo_read_reg;
  //Wires
  wire [DATA_WIDTH-1:0] serializer_datain;
  wire [DATA_WIDTH-1:0] fifo_apb2spi_out;
  wire [DATA_WIDTH-1:0] deserializer_dataout;
	wire                  line;
	wire                  serializer_load;
	wire                  aa;
	wire                  spi_sck_posedge;
	wire                  spi_sck_negedge;
	wire                  spi_sck_synchronized;
	wire                  stable_ss_end;
  wire                  miso_s;
  
  //Main SPI FSM
  always @ (posedge sys_clk or negedge sys_clrn_s) begin
    if(!sys_clrn_s) begin 
      spi_state_reg <= SPI_IDLE;
    end else begin 
      case (spi_state_reg)
      
        SPI_IDLE: 
          if(!spi_nss) 
            spi_state_reg <= SPI_COMMANDSTEP;
       
        SPI_COMMANDSTEP: begin 
          if((spi_wordsize_reg == SPI_DATA_WIDTH) && (deserializer_dataout[31]==1'b0))
          // IMPROVEMENT if((spi_wordsize_reg == SPI_DATA_WIDTH) && (deserializer_dataout[SPI_DATA_WIDTH-1]==1'b0))
            spi_state_reg <= SPI_READDATA;
          else if((spi_wordsize_reg == SPI_DATA_WIDTH) && (deserializer_dataout[31]==1'b1))
            spi_state_reg <= SPI_WRITEDATA;
        end  
        
        SPI_READDATA: 
          if((spi_wordsize_reg==DATA_WIDTH))
            spi_state_reg <= SPI_IDLE;
            
        SPI_WRITEDATA:
          if((spi_wordsize_reg==DATA_WIDTH))
            spi_state_reg <= SPI_IDLE;
          
      endcase
    end      
  end

  //SPI logic
  always @ (posedge sys_clk or negedge sys_clrn_s) begin
    if(!sys_clrn_s) begin
      serializer_load_reg   <= 1'b0;
      //spi_packetcounter_reg <= {CLOG2(PACKET_SIZE){1'b0}};
      spi_wordsize_reg      <= {CLOG2(DATA_WIDTH){1'b0}};
      apb2spird_reg         <= 1'b0;
      spi2apbwr_reg         <= 1'b0;
      rxfifo_write_reg      <= 1'b0;
      txfifo_read_reg       <= 1'b0;
    end else begin
      case (spi_state_reg)
      
        SPI_IDLE: begin
          spi_wordsize_reg      <= {CLOG2(DATA_WIDTH){1'b0}};
          apb2spird_reg         <= 1'b0;
          spi2apbwr_reg         <= 1'b0;
          rxfifo_write_reg      <= 1'b0;
          txfifo_read_reg       <= 1'b0;
        end
         
        SPI_COMMANDSTEP: begin 
          if((spi_wordsize_reg == SPI_DATA_WIDTH) && (deserializer_dataout[31]==1'b0)) begin
            serializer_load_reg <= 1'b1;
            if(deserializer_dataout[29:26] == REGISTERS_BASE_ADDR + TX_FIFO_OFFSET)
              txfifo_read_reg <= 1'b1;
              //spi_packetcounter_reg <= spi_packetcounter_reg - {{(CLOG2(PACKET_SIZE)-1){1'b0}},1'b1};
          end
          else if((spi_wordsize_reg == SPI_DATA_WIDTH) && (deserializer_dataout[31]==1'b1) && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + RX_FIFO_OFFSET)) ) begin 
              rxfifo_write_reg <= 1'b1;
              //spi_packetcounter_reg <= spi_packetcounter_reg + {{(CLOG2(PACKET_SIZE)-1){1'b0}},1'b1};
          end
          spi_wordsize_reg <= (spi_wordsize_reg == SPI_DATA_WIDTH) ? {CLOG2(DATA_WIDTH){1'b0}} : 
                                                ((spi_sck_posedge) ? (spi_wordsize_reg + {{(CLOG2(DATA_WIDTH)-1){1'b0}},1'b1}) : 
                                                                     spi_wordsize_reg);
        end  
        
        SPI_READDATA: begin
          serializer_load_reg <= 1'b0; 
          if((spi_wordsize_reg==DATA_WIDTH)&&(txfifo_read_reg)) begin
            apb2spird_reg         <= 1'b1;  
          end
          spi_wordsize_reg <= (spi_sck_posedge) ? (spi_wordsize_reg + {{(CLOG2(DATA_WIDTH)-1){1'b0}},1'b1}) : spi_wordsize_reg;
        end
        
        
        SPI_WRITEDATA: begin
          if((spi_wordsize_reg==DATA_WIDTH) && rxfifo_write_reg) begin 
            spi2apbwr_reg         <= 1'b1;  
          end
          spi_wordsize_reg <= (spi_sck_posedge) ? (spi_wordsize_reg + {{(CLOG2(DATA_WIDTH)-1){1'b0}},1'b1}) : spi_wordsize_reg;
        end
        
      endcase 
    end
  end
  
//Generating flags 
	//Status Register 
	//		[7]			      [6]			    [5]			     [4]			     [3]					   [2]			      [1]	                 	 [0] 
	//{{APB_EMPTY}, {APB_FULL}, {SPI_EMPTY}, {SPI_FULL}, {APB_ERROR_REG}, {SPI_ERROR_REG}, { tx_fifo packet done  }, {rx_fifo packet done}}  

  wire spi_empty;
  wire spi_full;
  wire apb_empty;
  wire apb_full;

  always @ (posedge sys_clk or negedge sys_clrn_s) begin
    if(!sys_clrn_s) 
      status_reg <= 8'h00;
     
    else begin 
      status_reg [7] <= apb_empty                                    ? 1'b1 : 1'b0;
      status_reg [6] <= apb_full                                     ? 1'b1 : 1'b0;
      status_reg [5] <= spi_empty                                    ? 1'b1 : 1'b0;
      status_reg [4] <= spi_full                                     ? 1'b1 : 1'b0;
      //status_reg [3] <= apb_error_reg                                ? 1'b1 : 1'b0;
      //status_reg [2] <= spi_error_reg                                ? 1'b1 : 1'b0;
      status_reg [3] <=                                                       1'b0;
      status_reg [2] <=                                                       1'b0;
      //status_reg [1] <= (apb_packetcounter_reg==control_reg)         ? 1'b1 : 1'b0;
      status_reg [1] <= (apb_nwords>=control_reg[CLOG2(PACKET_SIZE)-1:0])                    ? 1'b1 : 1'b0;
      //status_reg [0] <= (spi_packetcounter_reg==control_reg)         ? 1'b1 : 1'b0; 
      status_reg [0] <= (spi_nwords>=control_reg[CLOG2(PACKET_SIZE)-1:0])                    ? 1'b1 : 1'b0; 
    end
  end  
  
 
//Submodule instances

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Data Storing - FIFO's 
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
	FIFO #
	(
	.DATA_WIDTH(DATA_WIDTH),
	.DEPTH(FIFO_DEPTH),
	.COUNTERSIZE(CLOG2(FIFO_DEPTH))
	) 
	FIFO_AMBA_2_SPI 
	(
	.clk(sys_clk),
	.clrn(sys_clrn_s), 
	.read(apb2spird_reg), 
	.write(apb2spiwr_reg), 
	.datain(apb_pwdata_s), 
  .softreset(softreset_s),
  //Big endian
	.dataout(fifo_apb2spi_out),
  //Little endian 
  //.dataout({fifo_apb2spi_out[7:0],fifo_apb2spi_out[15:8],fifo_apb2spi_out[23:16],fifo_apb2spi_out[31:24]}),  
	.empty(apb_empty),
	.ov(apb_full),
  .rd_ptr(apb2spi_rdptr),
  .wr_ptr(apb2spi_wrptr)
	); 
	
	FIFO #
	(
	.DATA_WIDTH(DATA_WIDTH),
	.DEPTH(FIFO_DEPTH),
	.COUNTERSIZE(CLOG2(FIFO_DEPTH))
	) 
	FIFO_SPI_2_AMBA
	(
	.clk(sys_clk),
	.clrn(sys_clrn_s), 
	.read(spi2apbrd_reg), 
	.write(spi2apbwr_reg), 
  .softreset(softreset_s),
  //Big endian
	.datain(deserializer_dataout), 
  //Little endian 
  //.datain({deserializer_dataout[7:0],deserializer_dataout[15:8],deserializer_dataout[23:16],deserializer_dataout[31:24]}),
	.dataout(spi2apbfifo_dataout),
	.empty(spi_empty),
	.ov(spi_full),
  .rd_ptr(spi2apb_rdptr),
  .wr_ptr(spi2apb_wrptr)
	);
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//SPI Control Unit -> SPI MODE = 10
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	SYNCHRONIZER S1	(
	.clk(sys_clk),
  .clrn(sys_clrn_s),
	.signal(spi_sck),
	.synchronized_signal(spi_sck_synchronized),
	.spi_sck_posedge(spi_sck_posedge),
	.spi_sck_negedge(spi_sck_negedge)	);
	
	//assign sck_posedge_s = ((spi_wordsize_reg != 5'h0) && (spi_wordsize_reg != 5'h8)&& (spi_wordsize_reg != 5'h10) &&(spi_wordsize_reg != 5'h18)) ? spi_sck_posedge : 1'b0; 
	//assign sck_posedge_s = spi_sck_posedge; //not enough
  assign sck_negedge_s = ((spi_wordsize_reg != 5'h0) ) ? spi_sck_negedge : 1'b0; //Propably shift bug fixed
  
	SERIALIZER PARALELL_2_SERIAL (
	.clk(sys_clk),
	.clrn(sys_clrn_s),
	.spi_sck_edge(sck_negedge_s), 
	//.datain({serializer_datain[0],serializer_datain[DATA_WIDTH-1:1]}),
  .datain(serializer_datain),
	.load(serializer_load_reg),
	.dataout(miso_s),
	.spi_nss(spi_nss)	);
  defparam PARALELL_2_SERIAL.DATA_WIDTH = DATA_WIDTH;
 
  
    wire command_word_s;
    assign command_word_s = serializer_load_reg;
    assign serializer_datain   = 
    
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + CONTROL_REG_OFFSET)))    ? {{24{1'b0}},control_reg} :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + APB_STATE_OFFSET)))      ? apb_state_reg            :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + SPI_STATE_OFFSET)))      ? spi_state_reg            :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + STATUS_OFFSET)))         ? {{24{1'b0}},status_reg}  :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + RX_FIFO_RDADDR_OFFSET))) ? spi2apb_rdptr            :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + RX_FIFO_WRADDR_OFFSET))) ? spi2apb_wrptr            :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + TX_FIFO_OFFSET)))        ? fifo_apb2spi_out         :         
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + TX_FIFO_RDADDR_OFFSET))) ? apb2spi_rdptr            :
         (command_word_s && (deserializer_dataout[29:26]==(REGISTERS_BASE_ADDR + TX_FIFO_WRADDR_OFFSET))) ? apb2spi_wrptr            :
                                                                                                          //{DATA_WIDTH{1'b1}};
                                                                                                          fifo_apb2spi_out;                                                                           
	 	
	DESERIALIZER SERIAL_2_PARALELL (
	.clk(sys_clk),
	.clrn(sys_clrn_s),
	.spi_sck_edge(spi_sck_posedge),
	.datain(spi_mosi),
	.dataout(deserializer_dataout),
	.spi_nss(spi_nss)	);  
	defparam SERIAL_2_PARALELL.DATA_WIDTH = DATA_WIDTH;
  
	TRI_STATE_BUF CUT_OFF_spi_miso	(
	.in(miso_s),
	.out(spi_miso),
	//.nsel(spi_nss) );  
	.nsel((spi_nss)&& ((spi_state_reg!=SPI_READDATA) && (spi_state_reg!=SPI_WRITEDATA))));  
  defparam CUT_OFF_spi_miso.SIZE = 1;
  
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Synchronizer 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module SYNCHRONIZER (
  clk, clrn, signal, 
  spi_sck_posedge,	spi_sck_negedge, synchronized_signal );
	
  input  clk;
  input  clrn;
  input  signal;
	output spi_sck_posedge;
	output spi_sck_negedge;
  output synchronized_signal;
  
	wire mq,sq; 

	D_FLIPFLOP master(clk, signal, mq, clrn);	
	D_FLIPFLOP slave( clk,     mq, sq, clrn);
  
assign spi_sck_posedge     =  (mq & ~sq);
assign spi_sck_negedge     = (~mq &  sq);
assign synchronized_signal =         sq;

endmodule

module D_FLIPFLOP( clk, d, q, r);
  
  input  clk;
	input  d;
  input  r;
	output q;  
	
  reg q_reg;
  
	always@(posedge clk or negedge r) begin
		if(!r)
      q_reg <= 1'b0;
    else 
      q_reg <= d;
    
  end
    
assign q = q_reg;	

endmodule


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FIFO 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module FIFO	(
	clk, clrn,	read,	write, datain, softreset, 
	dataout, empty,	ov, rd_ptr, wr_ptr );
  
  parameter DATA_WIDTH=8;
	parameter DEPTH=8;
	parameter COUNTERSIZE=3;
  
	input                    clk;
	input                    clrn; 
	input                    read; 
	input                    write; 
	input  [DATA_WIDTH-1:0]   datain; 
  input                    softreset;
	output [DATA_WIDTH-1:0]   dataout;
	output                   empty;
	output                   ov;
  output [COUNTERSIZE:0]   rd_ptr;
  output [COUNTERSIZE:0]   wr_ptr;
  
	reg  [COUNTERSIZE:0]   rd_ptr_reg,  wr_ptr_reg; 
  wire [COUNTERSIZE:0]   rd_addr,  wr_addr; 
  
  //Enabling rd/wr
	and a1(write_en,!read,write,!ov);
	and a2(read_en,!empty,read,!write);
	
  //Flags generation
  assign msb   = (wr_ptr_reg[COUNTERSIZE]     == rd_ptr_reg[COUNTERSIZE])     ? 1'b1 : 1'b0;
  assign equal = (wr_ptr_reg[COUNTERSIZE-1:0] == rd_ptr_reg[COUNTERSIZE-1:0]) ? 1'b1 : 1'b0;
  assign ov    = (!msb && equal) ? 1'b1 : 1'b0;
  assign empty = ( msb && equal) ? 1'b1 : 1'b0;
  //FIFO space address
  assign rd_ptr  = rd_ptr_reg;
  assign wr_ptr  = wr_ptr_reg;
  assign rd_addr = rd_ptr_reg[COUNTERSIZE-1:0];
  assign wr_addr = wr_ptr_reg[COUNTERSIZE-1:0];
  
//Simple RAM memory 
	reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];
  
	integer i,j;

	always@(posedge clk or negedge clrn)
	begin
		if(!clrn) begin
			for(i=0;i<DEPTH;i=i+1)
				memory[i] <= 0;
        wr_ptr_reg <= {COUNTERSIZE{1'b0}};
        rd_ptr_reg <= {COUNTERSIZE{1'b0}};
		end
		
		else begin
			if(write_en) begin
				memory [wr_addr] <= datain;
        wr_ptr_reg       <= wr_ptr_reg + 1;
			end
			if(read_en) 
        rd_ptr_reg <= rd_ptr_reg + 1;
      if(softreset) begin
        for(i=0;i<DEPTH;i=i+1)
          memory[i] <= 0;
        wr_ptr_reg <= {COUNTERSIZE{1'b0}};
        rd_ptr_reg <= {COUNTERSIZE{1'b0}};
      end
		end
	end

assign dataout = memory[rd_addr];
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Three-state buffer 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module TRI_STATE_BUF 
	    (in, out, nsel );
  
  parameter SIZE=1;
  
	input             nsel;
	input  [SIZE-1:0] in;
	output [SIZE-1:0] out; 

	assign out = nsel ? {SIZE{1'bz}} : in; //low level active
		
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2 to 1 Multiplexer 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module MUX_2_TO_1
	    (i0, i1, sel, out	);
  
  parameter SIZE = 1;
  
	input  [SIZE-1:0] i0;
	input  [SIZE-1:0] i1;
	input             sel;
	output [SIZE-1:0] out;	
  
	assign out = (sel ? i1 : i0);
	
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//shift register paralell data input, serial data output 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module SHIFT_REGISTER_PARALLEL_LOAD (	
  clk, clrn, load,	shift, datain,
	dataout	);
  
  parameter DATA_WIDTH = 8;
  
	input                  clk;
	input                  clrn;
	input                  load;
	input                  shift;
	input [DATA_WIDTH-1:0]  datain;
	output                 dataout;
	
	reg [DATA_WIDTH-1:0]   dataout_reg;
	
	always @ (posedge clk or negedge clrn) begin
		if(!clrn) 
			dataout_reg <= {DATA_WIDTH{1'b0}};
		
		else begin
			if(load) //priority set to load
				dataout_reg <= datain;
			else //load not active
				if(shift)
					dataout_reg <= {dataout_reg[0], dataout_reg[DATA_WIDTH-1:1]};
		end
	end
	
	assign dataout = dataout_reg[0];
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Serializer 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module SERIALIZER (	
  clk, clrn,	load,	spi_sck_edge,datain,	spi_nss,
	dataout	);

  parameter DATA_WIDTH=8;
  
	input clk;
	input clrn;
	input load;
	input spi_sck_edge;
	input [DATA_WIDTH-1:0] datain;
	input spi_nss;
	output dataout;
    
	MUX_2_TO_1 MUX1	(
    .i0(load),
		.i1(1'b0),
		.sel(spi_nss),
		.out(m1_out)	);
	defparam MUX1.SIZE = 1;
	
	MUX_2_TO_1 MUX2	(
		.i0(spi_sck_edge),
		.i1(1'b0),
		.sel(spi_nss),
		.out(m2_out) );
  defparam MUX2.SIZE = 1;
		
	SHIFT_REGISTER_PARALLEL_LOAD SHIFT_REG (
		.clk(clk),
		.clrn(clrn),
		.load(m1_out),
		.shift(m2_out),
		.datain(datain),
		.dataout(dataout) );
    defparam SHIFT_REG.DATA_WIDTH = DATA_WIDTH;
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//shift register serial data input, paralell data output 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module SHIFT_REGISTER_SERIAL_TO_PARALLEL (
		clk, clrn, shift, datain,
		dataout );
  
  parameter DATA_WIDTH=8;
  
	input clk;
	input clrn;
	input shift;
	input datain;
	output [DATA_WIDTH-1:0] dataout;	
  
	reg [DATA_WIDTH-1:0] temp;
	
	always @ (posedge clk or negedge clrn) begin
	  if(!clrn)
		  temp<={DATA_WIDTH{1'b0}};
	  else begin
		  if(shift)
            temp<={datain, temp[DATA_WIDTH-1:1]};
	  end
	end
  
assign dataout=temp;
	
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Deserializer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
module DESERIALIZER	(
		clk, clrn, spi_sck_edge, datain, spi_nss,
		dataout	);
  
  parameter DATA_WIDTH=8;
  
	input clk;
	input clrn;
	input spi_sck_edge;
	input datain;
	input spi_nss;
	output [DATA_WIDTH-1:0] dataout;
	
	MUX_2_TO_1 M2
		(
		.i0(spi_sck_edge),
		.i1(1'b0),
		.sel(spi_nss),
		.out(m2_out)
		);
		
	SHIFT_REGISTER_SERIAL_TO_PARALLEL 
		SHIFT_REG_S2P
		(
		.clk(clk),
		.clrn(clrn),
		.shift(m2_out),
		.datain(datain),
		.dataout(dataout)
		);
  defparam SHIFT_REG_S2P.DATA_WIDTH = DATA_WIDTH;
  
endmodule