module Alarm(CLOCK_50,hour,min,KEY,mode,HEX0,HEX1,HEX2,HEX3,LEDR);
input CLOCK_50;
input [1:0]KEY;
input [7:0]hour,min;
input [1:0]mode;
output [0:6]HEX0,HEX1,HEX2,HEX3;
output [2:0]LEDR;
reg on=0,alarmreg=0;
reg holdstate_zero=0,holdstate_one=0,rised=0;
reg sel=0,donot=0;
reg [26:0]holdcnt=27'b0;
reg [7:0]alhour=0,almin=0;
wire [3:0] min_one,min_ten,hour_one,hour_ten;

//2sec 
always @ (posedge CLOCK_50) begin 
	if((!KEY[1] || !KEY[0]) && mode==3)begin
		holdcnt = holdcnt+ 1;
		if(holdcnt == 27'd100000000)begin
				rised=1;
		end
		else if(holdcnt == 27'd150000000)begin
				rised=0;
		end
	end
	else begin
	holdcnt=1;
	rised=0;
	end
end

always@(posedge CLOCK_50)begin
	if(holdstate_zero==0 && !KEY[0]&&mode==3) begin
	holdstate_zero=1;
	end
	else if(holdstate_zero==1 && KEY[0]&&mode==3&&rised==0)begin
		holdstate_zero=0;
		on=~on;
	end
	else if(holdstate_zero==1 && KEY[0]&&mode==3&&rised==1)begin
		holdstate_zero=0;
	end
	else if(holdstate_one==0 && !KEY[1]&&mode==3)begin
	holdstate_one=1;
	end
	else if(holdstate_one==1 && KEY[1]&&sel==0&&mode==3)begin
		holdstate_one=0;
		almin=(almin+1)%60;
	end
	else if(holdstate_one==1 && KEY[1] &&sel==1&&mode==3)begin
		holdstate_one=0;
		alhour=(alhour+1)%24;
	end
	else if((~|holdcnt) && holdstate_one==1&&mode==3)begin
		holdstate_one=0;
		sel=~sel;
	end
end

always@(min or almin)begin
	if(hour==alhour &&min==almin && on) alarmreg=1;
	else alarmreg=0;
end
assign LEDR[0]=alarmreg;
assign LEDR[1]=on;
assign LEDR[2]=sel;
assign min_one=almin%10;
assign min_ten=almin/10;
assign hour_one=alhour%10;
assign hour_ten=alhour/10;
segment_7 D0(min_one,HEX0);
segment_7 D1(min_ten,HEX1);
segment_7 D2(hour_one,HEX2);
segment_7 D3(hour_ten,HEX3);
endmodule