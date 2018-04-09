module tmr_top #
(
  parameter FREQ       = 10000000,
  parameter ADDR_W     = 8,
  parameter APB_ADDR_W = 16
)
(
  //----------------------------------------------------------------------------------------------------------------------
  // Inputs
  //----------------------------------------------------------------------------------------------------------------------
  input                       pclk,
  input                       presetn,
  input      [APB_ADDR_W-1:0] paddr,
  input                       psel,
  input                       penable,
  input                       pwrite,
  input      [31:0]           pwdata,
  //----------------------------------------------------------------------------------------------------------------------
  // Outputs
  //----------------------------------------------------------------------------------------------------------------------
  output     [31:0]           prdata,
  output                      pready
);
  //----------------------------------------------------------------------------------------------------------------------
  // Internal Signals
  //----------------------------------------------------------------------------------------------------------------------
  wire [31:0]       tmr_rtc_data_out;
  wire [ADDR_W-1:0] tmr_addr;
  wire              tmr_en;
  wire [31:0]       tmr_data_in;
  wire              tmr_pt_wr;
  wire              tmr_in_wr;
  wire              tmr_type_wr;
  wire [31:0]       tmr_pt_data_out;
  wire              tmr_in_data_out;
  wire [ 1:0]       tmr_type_data_out;
  wire [31:0]       tmr_et_data_out;
  wire              tmr_q_data_out;
  
  //----------------------------------------------------------------------------------------------------------------------
  // Assignments
  //----------------------------------------------------------------------------------------------------------------------
  assign tmr_addr    = paddr[2+ADDR_W:3];
  assign tmr_data_in = pwdata;
  assign tmr_clk     = pclk;
  assign tmr_resetn  = presetn;
  assign pready      = psel & penable;
  
  //----------------------------------------------------------------------------------------------------------------------
  // Real-Time Clock Instance
  //----------------------------------------------------------------------------------------------------------------------
  tmr_rtc #
  (
    .FREQ             (FREQ)
  )
  i_tmr_rtc 
  (
    .tmr_clk          (tmr_clk), 
    .tmr_resetn       (tmr_resetn), 
    .tmr_rtc_data_out (tmr_rtc_data_out)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // Core Instance
  //----------------------------------------------------------------------------------------------------------------------
  tmr_core #
  (
    .ADDR_W            (ADDR_W)
  )
  i_tmr_core  
  (
    .tmr_clk           (tmr_clk), 
    .tmr_addr          (tmr_addr), 
    .tmr_en            (tmr_en), 
    .tmr_data_in       (tmr_data_in), 
    .tmr_pt_wr         (tmr_pt_wr), 
    .tmr_in_wr         (tmr_in_wr), 
    .tmr_type_wr       (tmr_type_wr), 
    .tmr_rtc_data_out  (tmr_rtc_data_out), 
    .tmr_pt_data_out   (tmr_pt_data_out), 
    .tmr_in_data_out   (tmr_in_data_out), 
    .tmr_type_data_out (tmr_type_data_out), 
    .tmr_et_data_out   (tmr_et_data_out), 
    .tmr_q_data_out    (tmr_q_data_out)
  );

  //----------------------------------------------------------------------------------------------------------------------
  // APB Decoder Instance
  //----------------------------------------------------------------------------------------------------------------------
  tmr_apb_decoder #
  (
    .ADDR_W            (ADDR_W),
    .APB_ADDR_W        (APB_ADDR_W)
  )
  i_tmr_apb_decoder 
  (
    .paddr             (paddr),
    .psel              (psel),
    .penable           (penable),
    .pwrite            (pwrite),
    .tmr_pt_data_out   (tmr_pt_data_out),
    .tmr_in_data_out   (tmr_in_data_out),
    .tmr_type_data_out (tmr_type_data_out),
    .tmr_et_data_out   (tmr_et_data_out),
    .tmr_q_data_out    (tmr_q_data_out),
    .prdata            (prdata), 
    .tmr_en            (tmr_en), 
    .tmr_pt_wr         (tmr_pt_wr), 
    .tmr_in_wr         (tmr_in_wr), 
    .tmr_type_wr       (tmr_type_wr)
  );

endmodule