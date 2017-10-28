module stopwatch(CLOCK_50, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
   input CLOCK_50;
   input [1:0] KEY;
   output [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
   reg [1:0] fl=0;
	reg [17:0] count=0;
	reg [17:0] save1, save2, save3;
	reg [17:0] pipe;
	reg [1:0] num=1;
	reg [1:0] num1=0;
   wire [5:0] min, sec;
   wire [6:0] msec;
	reg [24:0] Q = 0;
	reg fl1, fl0;
	always@(posedge CLOCK_50)begin
	   if(~KEY[1])begin
			fl1<=1;
			if(~(fl==1))Q<=0;
	   end
	   else if(KEY[1] && fl1)begin
			fl1<=0;
			fl<=(fl+1)%3;
	   end
		else if(KEY[1])begin
			if(fl==0)begin
				count<=0;
				num<=0;
			end
			if(fl==1)begin
				Q <= (Q + 1) % 500000;
			end
			if(fl==2)begin
				count<=count;
			end
			if(~|Q && fl==1) count<=count+1;
		end
		if(~KEY[0])begin
			fl0<=1;
		end
		else if(KEY[0] && fl0)begin
			fl0=0;
			if(fl==1 && num<3) begin
				if(num==0) save1<=count;
				else if(num==1) save2<=count;
				else if(num==2) save3<=count;
				if(num<3) num<=num+1;
			end
		end
		else if(KEY[0])begin
			if(fl==0) num<=0;
		end
	end
	always @(posedge CLOCK_50)begin
		if(fl==2)begin
			if(KEY[0] && fl0)begin
				if(num1==0) pipe<=count;
				else if(num1==1) pipe<=save1;
				else if(num1==2) pipe<=save2;
				else if(num1==3) pipe<=save3;
				num1<=(num1+1)%(num+1);
			end
		end
		else pipe<=count;
		if(fl==1) begin
			num1<=0;
		end
	end
   assign min = pipe/6000;
   assign sec = (pipe%6000)/100;
   assign msec = pipe%100;
   segment_7 s1(min/10, HEX5);
   segment_7 s2(min%10, HEX4);
   segment_7 s3(sec/10, HEX3);
   segment_7 s4(sec%10, HEX2);
   segment_7 s5(msec/10, HEX1);
   segment_7 s6(msec%10, HEX0);
endmodule