module Timer(CLOCK_50,KEY,mode,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,LEDR);
input CLOCK_50;
input [1:0]KEY;
input [1:0]mode;
output [0:6]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
output [1:0]LEDR;
reg state=1,holdstate=0;
reg en=0,donot=0;
reg [7:0]hold=8'b0;
reg [19:0]registerd=0;
reg [19:0] seccnt = 20'b0;
reg [26:0]holdcnt=27'b0;
wire [6:0] hsec;
wire [5:0] sec;
wire [7:0] min;
wire [3:0] hsec_ten,hsec_one,sec_ten,sec_one,min_ten,min_one;

//0.01sec CLOCK
always @ (posedge CLOCK_50) begin 
	seccnt = seccnt + 1;
	if(seccnt == 20'd50000000)
			seccnt = 0;
end
//2sec counter
always @ (posedge CLOCK_50) begin 
	if(!KEY[1] &&mode==2)begin
		holdcnt = holdcnt+ 1;
		if(holdcnt == 27'd100000000)
				holdcnt = 0;
	end
	else holdcnt=1;
end
//mode change
always@(posedge !KEY[0] && mode==2) state=~state;
//if KEY[1]pressed, registerd increases
always@(posedge CLOCK_50)begin
	if(!KEY[1] && state==1 && holdstate==0 && mode==2)begin
		holdstate=1;
	end
	else if(KEY[1] && state==1 && holdstate==1 &&registerd!=0 && mode==2)begin
		holdstate=0;
		en=~en;
	end
	else if(state==0 && !KEY[1] && holdstate==0&&mode==2)begin
		holdstate=1;
	end
	else if(state==0 && KEY[1] && holdstate==1&&mode==2)begin
		registerd=registerd+6000;
		holdstate=0;
	end
	else if(en && (~|seccnt) && holdstate==0 && registerd!=0)begin
		registerd=registerd-1;
	end
	else if(!en && (~|holdcnt) && holdstate==1 && mode==2)begin
		holdstate=0;
		registerd=0;
	end
	else if(registerd==0) en=0;
	else registerd=registerd;
end
//assign
assign hsec = (registerd % 6000) % 100;
assign sec = (registerd % 6000) / 100;
assign min =  registerd /6000;
assign hsec_ten = hsec /10;
assign hsec_one = hsec %10;
assign sec_ten = sec /10;
assign sec_one = sec %10;
assign min_ten = min /10;
assign min_one = min %10;
//Display
assign LEDR[0]=state;
segment_7 D0(hsec_one,HEX0);
segment_7 D1(hsec_ten,HEX1);
segment_7 D2(sec_one,HEX2);
segment_7 D3(sec_ten,HEX3);
segment_7 D4(min_one,HEX4);
segment_7 D5(min_ten,HEX5);
endmodule