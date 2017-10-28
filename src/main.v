module main(VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_BLANK_N, VGA_HS, VGA_VS , VGA_SYNC_N, CLOCK_50, LEDR, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, AUD_ADCDAT,FPGA_I2C_SDAT, FPGA_I2C_SCLK, AUD_ADCLRCK, AUD_DACLRCK, AUD_DACDAT, AUD_BCLK, AUD_XCK);
	// I/O default Reject : VGA_H_SYNC, VGA_V_SYNC,

input 		CLOCK_50;  // 50MHz Clock -> Prescaling to 25MHz
output[9:0]	VGA_R, VGA_G, VGA_B;
output 		VGA_CLK, VGA_BLANK_N, VGA_SYNC_N;
output 	VGA_HS;
output 	VGA_VS;

input AUD_ADCDAT;
inout FPGA_I2C_SDAT;
output FPGA_I2C_SCLK;
output AUD_ADCLRCK, AUD_DACLRCK;
output AUD_DACDAT;
output AUD_BCLK;
output AUD_XCK;

wire[9:0]	wVGA_R, wVGA_G, wVGA_B;
wire 		wVGA_CLK, wVGA_BLANK_N, wVGA_SYNC_N;
wire 	wVGA_HS;
wire 	wVGA_VS;
input [1:0] KEY;
	output [9:0] LEDR;
	wire [9:0] vLEDR;
	wire [9:0] tLEDR;
	wire [9:0] aLEDR;
	wire [7:0] whour, wminute;
   output [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	wire [0:6] wHEX5, wHEX4, wHEX3, wHEX2, wHEX1, wHEX0;
   reg [1:0] count;
	reg [2:0] te;
   reg  fl1=0;
	reg [17:0] counter=0;
	reg [17:0] counterm=0;
	wire [5:0] sec;
	wire [0:6] sHEX5, sHEX4, sHEX3, sHEX2, sHEX1, sHEX0, vHEX5, vHEX4, vHEX3, vHEX2, vHEX1, vHEX0, tHEX5, tHEX4, tHEX3, tHEX2, tHEX1, tHEX0, aHEX3, aHEX2, aHEX1, aHEX0;
	wire [1:0] sKEY, vKEY, tKEY, aKEY;
	reg [1:0] fl=0;
	reg [24:0] Q = 1;
	reg [24:0] Qm=1;
	reg [7:0] music=1; 
	always@(posedge CLOCK_50)begin
		if(~KEY[0])begin
			fl1<=1;
			Q <= (Q + 1) % 500000;
			if(~|Q) counter=counter+1;
		end
		else if(KEY[0] && fl1)begin
			if(sec>1)fl<=(fl+1)%4;
			fl1<=0;
		end
		else if(KEY[0])begin
			Q<=0;
			counter<=0;
		end
	end
	always@(posedge CLOCK_50)begin
		Qm <= (Qm + 1) % 50000000;
		if(~|Qm)begin
			if(music[7]!=1) begin
				music=music<<1;
			end
			else if(music[7]==1) begin
				music=1;
			end
		end
	end
	assign vKEY[1]= (fl==0) ? KEY[1] : 1;
	assign vKEY[0]= (fl==0) ? KEY[0] : 1;
	assign LEDR[9:1]= (fl==0) ? vLEDR[8:0] : (fl==2) ? tLEDR[8:0] : (fl==3) ? aLEDR[9:1] : 0;
	assign LEDR[0] =aLEDR[0];
	assign sKEY[1]= (fl==1) ? KEY[1] : 1;
	assign sKEY[0]= (fl==1) ? KEY[0] : 1;
	assign tKEY[1]= (fl==2) ? KEY[1] : 1;
	assign tKEY[0]= (fl==2) ? KEY[0] : 1;
	assign aKEY[1]= (fl==3) ? KEY[1] : 1;
	assign aKEY[0]= (fl==3) ? KEY[0] : 1;
	stopwatch s1(CLOCK_50, sKEY, sHEX5, sHEX4, sHEX3, sHEX2, sHEX1, sHEX0);
	view v1(CLOCK_50, vKEY, vHEX0, vHEX1, vHEX2, vHEX3, vHEX4, vHEX5, vLEDR, whour, wminute);
	Timer t1(CLOCK_50, tKEY, fl, tHEX0, tHEX1, tHEX2, tHEX3, tHEX4, tHEX5, tLEDR[1:0]);
	Alarm aa1(CLOCK_50, whour, wminute, aKEY, fl, aHEX0, aHEX1, aHEX2, aHEX3, aLEDR[2:0]);
	audio aaa1(aLEDR[0], CLOCK_50, KEY[1:0], music, FPGA_I2C_SDAT, FPGA_I2C_SCLK, AUD_ADCLRCK, AUD_ADCDAT, AUD_DACLRCK, AUD_DACDAT, AUD_BCLK, AUD_XCK);
	assign sec = (counter%6000)/100;
	assign wHEX0=(fl==0) ? vHEX0 : (fl==1) ? sHEX0 : (fl==2) ? tHEX0 : (fl==3) ? aHEX0 : 7'b1111111;
	assign wHEX1=(fl==0) ? vHEX1 : (fl==1) ? sHEX1 : (fl==2) ? tHEX1 : (fl==3) ? aHEX1 : 7'b1111111;
	assign wHEX2=(fl==0) ? vHEX2 : (fl==1) ? sHEX2 : (fl==2) ? tHEX2 : (fl==3) ? aHEX2 : 7'b1111111;
	assign wHEX3=(fl==0) ? vHEX3 : (fl==1) ? sHEX3 : (fl==2) ? tHEX3 : (fl==3) ? aHEX3 : 7'b1111111;
	assign wHEX4=(fl==0) ? vHEX4 : (fl==1) ? sHEX4 : (fl==2) ? tHEX4 : (fl==3) ? 7'b1111111 : 7'b1111111;
	assign wHEX5=(fl==0) ? vHEX5 : (fl==1) ? sHEX5 : (fl==2) ? tHEX5 : (fl==3) ? 7'b1111111 : 7'b1111111;
	assign HEX0=wHEX0;
	assign HEX1=wHEX1;
	assign HEX2=wHEX2;
	assign HEX3=wHEX3;
	assign HEX4=wHEX4;
	assign HEX5=wHEX5;
assign VGA_R=wVGA_R;
assign VGA_G=wVGA_G;
assign VGA_B=wVGA_B;
assign VGA_CLK=wVGA_CLK;
assign VGA_BLANK_N=wVGA_BLANK_N;
assign VGA_SYNC_N=wVGA_SYNC_N;
assign VGA_HS=wVGA_HS;
assign VGA_VS=wVGA_VS;
//output reg Signal;  -> Maybe for LED
MonitorDisplay mm1(wVGA_R, wVGA_G, wVGA_B, wVGA_CLK, wVGA_BLANK_N, wVGA_HS, wVGA_VS , wVGA_SYNC_N, CLOCK_50, wHEX5, wHEX4, wHEX3, wHEX2, wHEX1, wHEX0);
endmodule