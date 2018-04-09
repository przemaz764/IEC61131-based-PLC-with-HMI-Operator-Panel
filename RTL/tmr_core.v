module tmr_core #
(
  parameter ADDR_W = 8
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                   tmr_clk,
  input      [ADDR_W-1:0] tmr_addr,
  input                   tmr_en,
  input      [31:0]       tmr_data_in,
  input                   tmr_pt_wr,
  input                   tmr_in_wr,
  input                   tmr_type_wr,
  input      [31:0]       tmr_rtc_data_out,
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output     [31:0]       tmr_pt_data_out,
  output                  tmr_in_data_out,
  output     [ 1:0]       tmr_type_data_out,
  output reg [31:0]       tmr_et_data_out,
  output reg              tmr_q_data_out
);
  //----------------------------------------------------------------------------------------------------------------------
  // Timers' types
  //----------------------------------------------------------------------------------------------------------------------
  localparam TP  = 2'h0;
  localparam TON = 2'h1;
  localparam TOF = 2'h2;

  //----------------------------------------------------------------------------------------------------------------------
  // Internal signals
  //----------------------------------------------------------------------------------------------------------------------

  // Preset Time Memory
  reg  [31:0]            pt_array 
       [2**(ADDR_W)-1:0];
  wire [ADDR_W-1:0]      pt_addr;
  wire [31:0]            pt_data_in;
  reg  [31:0]            pt_data_out;
  wire                   pt_en;
  wire                   pt_wr;
  
  // Start Time Memory
  reg  [31:0]            st_array 
       [2**(ADDR_W)-1:0];
  wire [ADDR_W-1:0]      st_addr;
  wire [31:0]            st_data_in;
  reg  [31:0]            st_data_out;
  wire                   st_en;
  wire                   st_wr;
  reg                    st_wr_mux;

  // Input Memory
  reg  [2**(ADDR_W)-1:0] in_array;
  wire [ADDR_W-1:0]      in_addr;
  wire                   in_data_in;
  reg                    in_data_out;
  wire                   in_en;
  wire                   in_wr;
  wire                   in_data_out_redge;
  wire                   in_data_out_fedge;

  // Type Memory
  reg  [ 1:0]            type_array 
       [2**(ADDR_W)-1:0];
  wire [ADDR_W-1:0]      type_addr;
  wire [ 1:0]            type_data_in;
  reg  [ 1:0]            type_data_out;
  wire                   type_en;
  wire                   type_wr;

  // Run Memory
  reg  [2**(ADDR_W)-1:0] run_array;
  wire [ADDR_W-1:0]      run_addr;
  wire                   run_data_in;
  reg                    run_data_out;
  wire                   run_en;
  wire                   run_wr;
  
  wire                   rtc_grt_or_eq_st;
  wire [31:0]            et_mux_out;
  wire                   et_less_than_pt;
  wire [31:0]            et_st_mux_out;

  //----------------------------------------------------------------------------------------------------------------------
  // Preset Time Memory
  //----------------------------------------------------------------------------------------------------------------------
  assign pt_addr    = tmr_addr;
  assign pt_data_in = tmr_data_in;
  assign pt_en      = tmr_en;
  assign pt_wr      = tmr_pt_wr;

  // RAM model
  always @(posedge tmr_clk)
    if (pt_en)
    begin
      if (pt_wr)
        pt_array[pt_addr] <= pt_data_in;
      else
        pt_data_out       <= pt_array[pt_addr];
    end

  assign tmr_pt_data_out = pt_data_out;

  //----------------------------------------------------------------------------------------------------------------------
  // Start Time Memory
  //----------------------------------------------------------------------------------------------------------------------
  assign st_addr    = tmr_addr;
  assign st_data_in = tmr_rtc_data_out;
  assign st_en      = tmr_en;
  assign st_wr      = tmr_in_wr & st_wr_mux;

  // RAM model
  always @(posedge tmr_clk)
    if (st_en)
    begin
      if (st_wr)
      begin
        st_array[st_addr] <= st_data_in;
        st_data_out       <= st_data_in;
      end
      else
        st_data_out       <= st_array[st_addr];
    end

  //----------------------------------------------------------------------------------------------------------------------
  // Start Time Write Enable Multiplexer
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
    case (type_data_out)
      TP:
        st_wr_mux = in_data_out_redge & ~tmr_q_data_out;
      TON:
        st_wr_mux = in_data_out_redge;
      default: // TOF
        st_wr_mux = in_data_out_fedge;
    endcase

  //----------------------------------------------------------------------------------------------------------------------
  // Input Memory
  //----------------------------------------------------------------------------------------------------------------------
  assign in_addr    = tmr_addr;
  assign in_data_in = tmr_data_in[0];
  assign in_en      = tmr_en;
  assign in_wr      = tmr_in_wr;

  // RAM model
  always @(posedge tmr_clk)
    if (in_en)
    begin
      if (in_wr)
      begin
        in_array[in_addr] <= in_data_in;
        in_data_out       <= in_data_in;
      end
      else
        in_data_out       <= in_array[in_addr];
    end

  assign tmr_in_data_out = in_data_out;

  // Edge detectors
  assign in_data_out_redge = in_data_in & ~in_data_out;
  assign in_data_out_fedge = ~in_data_in & in_data_out;

  //----------------------------------------------------------------------------------------------------------------------
  // Type Memory
  //----------------------------------------------------------------------------------------------------------------------
  assign type_addr    = tmr_addr;
  assign type_data_in = tmr_data_in[1:0];
  assign type_en      = tmr_en;
  assign type_wr      = tmr_type_wr;

  // RAM model
  always @(posedge tmr_clk)
    if (type_en)
    begin
      if (type_wr)
      begin
        type_array[type_addr] <= type_data_in;
        type_data_out         <= type_data_in;
      end
      else
        type_data_out         <= type_array[type_addr];
    end

  assign tmr_type_data_out = type_data_out;

  //----------------------------------------------------------------------------------------------------------------------
  // Run Memory
  //----------------------------------------------------------------------------------------------------------------------
  assign run_addr    = tmr_addr;
  assign run_data_in = st_wr_mux | run_data_out;
  assign run_en      = tmr_en;
  assign run_wr      = tmr_in_wr;
  
  // RAM model
  always @(posedge tmr_clk)
    if (run_en)
    begin
      if (run_wr)
      begin
        run_array[run_addr] <= run_data_in;
        run_data_out        <= run_data_in;
      end
      else
        run_data_out        <= run_array[run_addr];
    end

  //----------------------------------------------------------------------------------------------------------------------
  // Combinational part
  //----------------------------------------------------------------------------------------------------------------------
  assign rtc_grt_or_eq_st = tmr_rtc_data_out >= st_data_out;
  assign et_mux_out       = rtc_grt_or_eq_st ? (tmr_rtc_data_out - st_data_out)
                                             : (33'h1_0000_0000 - (st_data_out - tmr_rtc_data_out));
  assign et_less_than_pt  = et_mux_out < pt_data_out;
  assign et_st_mux_out    = et_less_than_pt ? et_mux_out : pt_data_out;

  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  always @(*)
    case (type_data_out)
      TP:
        tmr_q_data_out = et_less_than_pt & run_data_out;
      TON:
        tmr_q_data_out = ~et_less_than_pt & in_data_out & run_data_out;
      default: // TOF
        tmr_q_data_out = (in_data_out | et_less_than_pt) & run_data_out;
    endcase
    
  always @(*)
    case (type_data_out)
      TP:
        tmr_et_data_out = et_st_mux_out & {32{(et_less_than_pt | in_data_out) & run_data_out}};
      TON:
        tmr_et_data_out = et_st_mux_out & {32{in_data_out & run_data_out}};
      default: // TOF
        tmr_et_data_out = et_st_mux_out & {32{~in_data_out & run_data_out}};
    endcase

endmodule