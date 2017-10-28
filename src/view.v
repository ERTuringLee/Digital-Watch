module view(CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, whour, wminute);
	input CLOCK_50;
	input [1:0] KEY;
	output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output reg[9:0] LEDR=0;
	output [7:0] whour, wminute;
	reg [7:0] global=0;
	reg [7:0] second=0;
	reg [7:0] minute =0;
	reg [7:0] hour =0;
	reg [7:0] date =1;
	reg [7:0] month = 1;
	reg [7:0] year =0;
	reg [7:0] reg1 =0;
	reg [7:0] reg2 = 0;
	reg [7:0] reg3 = 0;
	reg [26:0] Counter = 1;
	reg s_c=0;
	reg m_c=0;
	reg h_c=0;
	reg d_c=0;
	reg mo_c=0;
	reg y_c=0;
	wire [3:0] w_c;
	reg g_c;
	reg [3:0] world= 0;
	assign whour=hour;
	assign wminute=minute;
	count c1(KEY[1], w_c);
	always@(posedge CLOCK_50)
		begin
			
			if(w_c<3) begin
				reg1 = second;
				reg2 = minute;
				reg3 = hour;
			end else if(w_c>=3&&w_c<=5) begin
				reg1 = date;
				reg2 = month;
				reg3 = year;
			end else if(w_c==6) begin
				reg1 = second;
				reg2 = minute;
				reg3 = global;
			end
			
			Counter = Counter + 1;
			if(Counter ==50000000) Counter = 0;
			if(Counter==0) begin
				second = second +1;
				if(second ==60) begin
					second = 0;
					minute = minute + 1;
				end
				if(minute==60) begin
					minute = 0;
					hour = hour+1;
				end
				if(hour == 24) begin
					hour = 0;
					date = date+1;
				end
							if(hour>=12 && hour<=23) begin
					LEDR[8] = 1;
				end
				 else if(hour>=0 && hour<=11) begin
					LEDR[8] = 0;
				end
				if(month==1||month==3||month==5||month==7||month==8||month==10||month==12) begin
					if(date==32) begin
						date = 1;
						month = month+1;
					end
				end else if(month==4||month==6||month==9||month==11) begin
					if(date==31) begin
						date = 1;
						month = month+1;
					end
				end else if(month==2) begin
					if(date==29) begin
						date = 1;
						month = month+1;
					end
				end
				if(month==13) begin
					month = 1;
					year = year+1;
				end
				if(year==100) begin
					year =0;
				end
				
			end 
			else if(~KEY[0]) begin
				if(w_c==0) begin
					LEDR[2:0] = 3'b001;
					s_c = 1;
				end else if(w_c==1) begin
					LEDR[2:0] = 3'b010;
					m_c =1;
				end else if(w_c==2) begin
					LEDR[2:0] = 3'b100;
					h_c =1;
				end else if(w_c==3) begin
					LEDR[2:0] = 3'b001;
					d_c=1;
				end else if(w_c==4) begin
					LEDR[2:0] = 3'b010;
					mo_c = 1;
				end else if(w_c==5) begin
					LEDR[2:0] = 3'b100;
					y_c =1;
				end else if(w_c==6) begin
					g_c = 1;
				end
			end
			else if(KEY[0]) begin
				LEDR[2:0] = 3'b000;
				if(w_c==0) begin 
					second = second+s_c;
					s_c=0;
					if(second==60) begin
						second = 0;
					end
				end else if(w_c==1) begin
					minute = minute+m_c;
					m_c=0;
					if(minute==60) begin
						minute = 0;
					end
				end else if(w_c==2) begin 
					hour = hour+h_c;
					h_c=0;
					if(hour==24) begin
						hour = 0;
					end
								if(hour>=12 && hour<=23) begin
					LEDR[8] = 1;
				end
				 else if(hour>=0 && hour<=11) begin
					LEDR[8] = 0;
				end
				end else if(w_c==3) begin
					date = date+d_c;
					d_c=0;
					if(month==1||month==3||month==5||month==7||month==8||month==10||month==12) begin
						if(date==32) begin
							date = 1;
						end
					end else if(month==4||month==6||month==9||month==11) begin
						if(date==31) begin
							date = 1;
						end
					end else if(month==2) begin
						if(date==29) begin
							date = 1;
						end
					end
				end else if(w_c==4) begin
					month = month+mo_c;
					mo_c=0;
					if(month==13) begin
						month = 1;
					end
				end else if(w_c==5) begin
					year = year+y_c;
					y_c=0;
					if(year==100) begin
						year = 0;
					end
				end else if(w_c == 6) begin
					world = world + g_c;
					g_c= 0;
					if(world == 1) begin// 중국 베이징
						if(hour==0) begin
							global = 23; 
						end else begin
							global = hour -1;
						end
					end else if(world == 2) begin//파키스탄 이슬라마바드
						if(hour<4) begin
							global = 24 + (hour -4); 
						end else begin
							global = hour -4;
						end
					end else if(world == 3) begin // 그리스 아테네
						if(hour<7) begin
							global = 24 + (hour -7);
						end else begin
							global = hour -7;
						end
					end else if(world == 4) begin // 모리타니 누악쇼트
						if(hour<8) begin
							global = 24 + (hour -8);
						end else begin
							global = hour -8;
						end
					end else if(world == 5) begin // 미국 뉴욕
						if(hour<14) begin
							global = 24 + (hour -14);
						end else begin
							global = hour -14;
						end
					end else if(world == 6) begin // 아르헨티나 부에노스 아이레스
						if(hour<12) begin
							global = 24 + (hour -12);
						end else begin
							global = hour -12;
						end
					end else begin
						world = 0;
						global = hour;
					end
				end
			end
			
		end
		Number_Display N1(reg1/10, HEX1);
		Number_Display N2(reg1%10, HEX0);
		Number_Display N3(reg2/10, HEX3);
		Number_Display N4(reg2%10, HEX2);
		Number_Display N5(reg3/10, HEX5);
		Number_Display N6(reg3%10, HEX4);
endmodule

module count(In1, Out1);
	input In1;
	output [3:0] Out1;
	reg [3:0] count1=0;
	always@(negedge In1)
		begin
			count1 = count1+1;
			if(count1==7) begin
				count1 = 0;
			end
		end
	assign Out1 = count1;
endmodule


