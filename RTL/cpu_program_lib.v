//---------------------------------
// Instruction codes
//---------------------------------
localparam LD_I     = 8'b0000_0000;
localparam LDN_I    = 8'b0001_0000;
localparam AND_I    = 8'b0000_0001;
localparam ANDN_I   = 8'b0001_0001;
localparam OR_I     = 8'b0000_0010;
localparam ORN_I    = 8'b0001_0010;
localparam XOR_I    = 8'b0000_0011;
localparam XORN_I   = 8'b0001_0011;
localparam ST_I     = 8'b0000_0100;
localparam STN_I    = 8'b0001_0100;
localparam R_I      = 8'b0000_0101;
localparam S_I      = 8'b0001_0101;
localparam F_TRIG_I = 8'b0000_0110;
localparam R_TRIG_I = 8'b0001_0110;
localparam LDI_I    = 8'b0000_0111;
localparam EQU_I    = 8'b0001_0111;
localparam ANDI_I   = 8'b0000_1000;
localparam NOP_I    = 8'b0001_1000;
localparam ORI_I    = 8'b0000_1001;
localparam XORI_I   = 8'b0000_1010;
localparam NOT_I    = 8'b0000_1011;
localparam JMP_I    = 8'b0000_1100;
localparam JMPC_I   = 8'b0000_1101;
localparam JMPCN_I  = 8'b0001_1101;
localparam APB_RD_I = 8'b0000_1110;
localparam APB_WR_I = 8'b0001_1110;