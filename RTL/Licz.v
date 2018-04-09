`timescale 1ns / 1ps

module licznik( PCLK,PSEL, PADDR, PWDATA, PRDATA, PENABLE, PWRITE, PREADY);
parameter szerokosc = 32;
parameter szerokosc_adresu = 16;
parameter adresy_licznikow = 10;
input PCLK, PSEL, PWRITE, PENABLE;
input [szerokosc-1:0] PWDATA;
input [szerokosc_adresu-1:0] PADDR;
output [szerokosc-1:0] PRDATA;
output PREADY;
wire [szerokosc-1:0]  mux1_sum, sum_mux2, mux2_cv,PV2, CV;

sumator #(szerokosc)sumator1(CV, mux1_sum, sum_mux2);

multiplekser #(szerokosc)multiplekser1({szerokosc{1'b0}}, {{szerokosc-1{1'b0}},1'b1}, {szerokosc{1'b1}}, {szerokosc{1'b0}}, {zbocze2,zbocze1}, mux1_sum); 
multiplekser #(szerokosc)multiplekser2(sum_mux2, PV2, {szerokosc{1'b0}}, {szerokosc{1'b0}}, {R,L}, mux2_cv);

wykrywacz_zbocza wejscieCU(CU, zbocze1, PCLK, PADDR[adresy_licznikow:adresy_licznikow-7], PSEL&PENABLE&CUE);
wykrywacz_zbocza wejscieCD(CD, zbocze2, PCLK, PADDR[adresy_licznikow:adresy_licznikow-7], PSEL&PENABLE&CDE); 
max #(szerokosc)wykrywacz_maksimum(CV,max,zbocze2, zbocze1,L,R); 

Q #(szerokosc)wQU(CV,PV2,QU); 
Q2 #(szerokosc)wQD(CV, {szerokosc{1'b0}}, QD); 

RAM #(szerokosc, adresy_licznikow-2)counter_value(PCLK, ~max&(zbocze1|zbocze2|R|L)&PENABLE&PWRITE, PADDR[adresy_licznikow:adresy_licznikow-7],mux2_cv, CV, PSEL);
RAM #(szerokosc, adresy_licznikow-2)preset_value(PCLK, WE&PSEL, PADDR[adresy_licznikow:adresy_licznikow-7], PWDATA, PV2, 1'b1);

RAM #(1,adresy_licznikow-2)CU_buff(PCLK, CUE&PSEL, PADDR[adresy_licznikow:adresy_licznikow-7], PWDATA[0], CU, PSEL);
RAM #(1,adresy_licznikow-2)CD_buff(PCLK, CDE&PSEL, PADDR[adresy_licznikow:adresy_licznikow-7], PWDATA[0], CD, PSEL);
RAM #(1,adresy_licznikow-2)R_buff(PCLK, RE&PSEL, PADDR[adresy_licznikow:adresy_licznikow-7], PWDATA[0], R, PSEL);
RAM #(1,adresy_licznikow-2)L_buff(PCLK, LE&PSEL, PADDR[adresy_licznikow:adresy_licznikow-7], PWDATA[0], L, PSEL);

decoder APB_decoder({PWRITE, PADDR[2], PADDR[1], PADDR[0]},{CUE, CDE, RE, LE, WE, SEL1, SEL0});
multiplekser #(1)PRDATA0_mux(QU, QD, CV[0], 1'b0, {SEL1, SEL0}, PRDATA[0]);
assign PRDATA[szerokosc-1:1]=CV[szerokosc-1:1];
assign PREADY = PENABLE;
endmodule

module sumator(wejscieA, wejscieB, Q);
parameter szerokosc = 4;
input [szerokosc-1:0] wejscieA, wejscieB;
output [szerokosc-1:0] Q;

   wire [szerokosc-1:0] wejscieA;
   wire [szerokosc-1:0] wejscieB;
   wire [szerokosc-1:0] Q;
    assign Q = wejscieA + wejscieB;
	
endmodule 

module multiplekser(a,b,c,d,sel,out);
parameter szerokosc = 4;
input wire [szerokosc - 1:0]a,b,c,d;
input wire [1:0] sel;
output reg [szerokosc - 1:0] out;
 always @(sel, a, b, c, d)
      case (sel)
         2'b00: out = a;
         2'b01: out = b;
         2'b10: out = c;
         2'b11: out = d;
      endcase

endmodule



module wykrywacz_zbocza(in, out, CLK, addr, we); 
parameter szerokosc_adresu = 8;
input in, CLK, we;
input [szerokosc_adresu-1:0] addr;
output out;
RAM #(1, szerokosc_adresu)poprzedni_stan(CLK, we, addr, D, Q, 1'b1); 
assign D = in;
assign out=in&~Q;

endmodule



module max(in,out,CD,CU,L,R); 
parameter szerokosc = 4;
input [szerokosc-1:0] in;
input CD,CU,L,R;
output out;
assign out=(&{in[szerokosc-1],~in[szerokosc-2:0],~CU,~L,~R}|&{~in[szerokosc-1],in[szerokosc-2:0],~CD,~L,~R});
endmodule 

module Q(liczba1, liczba2, wyj);
parameter szerokosc = 4;
input [szerokosc-1:0] liczba1, liczba2;
output reg wyj;
always @(liczba1 or liczba2)
begin
if (liczba1[szerokosc-1]<liczba2[szerokosc-1])
wyj=1;
else if (liczba1[szerokosc-1]>liczba2[szerokosc-1])
wyj = 0;
else if(liczba1[szerokosc-2:0]>=liczba2[szerokosc-2:0])
wyj=1;
else 
wyj=0;
end

endmodule 

module Q2(liczba1,liczba2,wyj); 
parameter szerokosc = 4;
input [szerokosc-1:0] liczba1, liczba2;
output reg wyj;

always @(liczba1 or liczba2)
begin
if(liczba1[szerokosc-1]>liczba2[szerokosc-1])
wyj=1;
else if(liczba1==liczba2)
wyj = 1;
else
wyj = 0;
end
endmodule 


module RAM(clk,write_en,addr,in,out,ram_en);

parameter RAM_WIDTH = 4;
parameter RAM_ADDR_BITS = 4;
integer k;
   
   (* RAM_STYLE="block" *)
reg [RAM_WIDTH-1:0] memory [(2**RAM_ADDR_BITS)-1:0];
output reg [RAM_WIDTH-1:0] out = 0;

initial
begin
	for (k = 0; k < (2**RAM_ADDR_BITS) ; k = k + 1)
	begin
		memory[k] = {RAM_WIDTH{1'b0}};
	end
end

input [RAM_ADDR_BITS-1:0] addr;
input [RAM_WIDTH-1:0] in;
input write_en, clk, ram_en;


always @(posedge clk)
	if (ram_en) begin
		if (write_en) begin
			memory[addr] <= in;
			out <= in;
		end
		else
			out <= memory[addr];
	end

endmodule

module decoder(in, out);
input [3:0] in;
output reg [6:0] out;

always@(in)
	case(in)
		4'b1000 : out<=7'b1000000;
		4'b1001 : out<=7'b0100000;
		4'b1010 : out<=7'b0010000;
		4'b1011 : out<=7'b0001000;
		4'b1100 : out<=7'b0000100;
		4'b0101 : out<=7'b0000010;
		4'b0110 : out<=7'b0000001;
		4'b0111 : out<=7'b0000000;
		default : out<=7'b0000000;
	endcase
endmodule

