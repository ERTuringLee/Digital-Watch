module MonitorDisplay(VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_BLANK_N, VGA_HS, VGA_VS , VGA_SYNC_N, CLOCK_50, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
	// I/O default Reject : VGA_H_SYNC, VGA_V_SYNC,

input 		CLOCK_50;  // 50MHz Clock -> Prescaling to 25MHz
output[9:0]	VGA_R, VGA_G, VGA_B;
output 		VGA_CLK, VGA_BLANK_N, VGA_SYNC_N;
output reg 	VGA_HS;
output reg 	VGA_VS;
input [0:6] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
//output reg Signal;  -> Maybe for LED
//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	45+3;
parameter	H_SYNC_ACT	=	640  ;	//	646
parameter	H_SYNC_FRONT	=	13+3;
parameter	H_SYNC_TOTAL	=	800 ;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	30+2;
parameter	V_SYNC_ACT	=	480 ;	//	484
parameter	V_SYNC_FRONT	=	9+2;
parameter	V_SYNC_TOTAL	=	525 ;

//	Start Offset
parameter	X_START		=	H_SYNC_CYC + H_SYNC_BACK+4;
parameter	Y_START		=	V_SYNC_CYC + V_SYNC_BACK;

reg				iCLK;
reg		[9:0]		H_Cont;
reg		[9:0]		V_Cont;
reg		[9:0]		Cur_Color_R;
reg		[9:0]		Cur_Color_G;
reg		[9:0]		Cur_Color_B;
reg		[9:0]		row,col;
reg 		[29:0]	RGB;
reg 		[8:0]		title1;
	
reg		[26:0] Cnt;
reg 		[5:0] SCnt, MCnt;
reg 		[10:0] BCnt, BCnt2;

reg CLK_Cnt = 0;

//control 

assign VGA_BLANK_N 	= VGA_HS & VGA_VS;
assign VGA_SYNC_N	= 1'b0;
assign VGA_CLK 	= iCLK;
assign VGA_R 		= RGB[29:20];
assign VGA_G 		= RGB[19:10];
assign VGA_B 		= RGB[9:0];

wire [0:159] Num[9:0];
wire [0:159] Alpha[36:0];
wire [0:159] Arrow[1:0];

reg Start;


// A
assign Alpha[0] = 160'b0000000000000000000000001100000001001000001000010001100001100110000110011000011001111111100110000110011000011001100001100110000110011000011001100001100000000000;
// B
assign Alpha[1] = 160'b0000000000011111100001111111000110000110011000110001100011000110111000011111000001101110000110001100011000110001100001000110000110011111110001111110000000000000;
// C
assign Alpha[2] = 160'b0000000000000111100000111111000110000110011000011001100001100110000000011000000001100000000110000000011000011001100001100110000110001111110000011110000000000000;
// D
assign Alpha[3] = 160'b0000000000011111100001111111000110000110011000011001100001100110000110011000011001100001100110000110011000011001100001100110000110011111110001111110000000000000;
// E
assign Alpha[4] = 160'b0000000000011111111001111111100110000000011000000001100000000110000000011111111001111111100110000000011000000001100000000110000000011111111001111111100000000000;
// F
assign Alpha[5] = 160'b0000000000011111111001111111100110000000011000000001100000000110000000011111111001111111100110000000011000000001100000000110000000011000000001100000000000000000;
// G
assign Alpha[6] = 160'b0000000000000111100000110011000110000000010000000001000000000100000000010000000001000000000100000000010011111001000001100110000110001100101000011100100000000000;
// H
assign Alpha[7] = 160'b0000000000011000011001100001100110000110011000011001100001100110000110011111111001111111100110000110011000011001100001100110000110011000011001100001100000000000;
// I
assign Alpha[8] = 160'b0000000000011111111001111111100000110000000011000000001100000000110000000011000000001100000000110000000011000000001100000000110000011111111001111111100000000000;
// J
assign Alpha[9] = 160'b0000000000011111111001111111100000011000000001100000000110000000011000000001100000000110000110011000011001100001100110000110110000001111000000110000000000000000;
// K
assign Alpha[10] = 160'b0000000000011000011001100011000110001000011001000001101100000111100000011100000001110000000111100000011011000001100100000110001000011000110001100001100000000000;
// L
assign Alpha[11] = 160'b0000000000011000000001100000000110000000011000000001100000000110000000011000000001100000000110000000011000000001100000000110000000011111111001111111100000000000;
// M
assign Alpha[12] = 160'b0000000000011000011001110011100111001110011100111001110011100111001110011100111001111111100110110110011011011001100001100110000110011000011001100001100000000000;
// N
assign Alpha[13] = 160'b0000000000011000011001110001100110100110011010011001101001100110100110011010011001101001100110010110011001011001100101100110010110011000111001100001100000000000;
// O
assign Alpha[14] = 160'b0000000000001111110001100001100110000110011000011001100001100110000110011000011001100001100110000110011000011001100001100110000110011000011000111111000000000000;
// P
assign Alpha[15] = 160'b0000000000011111111001100001100110000110011000011001100001100110001100011000110001111100000110000000011000000001100000000110000000011000000001100000000000000000;
// Q
assign Alpha[16] = 160'b0000000000011111111001100001100110000100011000010001100011000110011000011011000001111000000110110000011001100001100011000110000100011000011001100001100000000000;
// R
assign Alpha[17] = 160'b0000000000011111111001100001100110000100011000010001100011000110011000011011000001111000000110110000011001100001100011000110000100011000011001100001100000000000;
// S
assign Alpha[18] = 160'b0000000000000111110000111111100011000110011000001001100000000111000000001111100000011111000000001110000000011001000001100110001100011111110000111110000000000000;
// T
assign Alpha[19] = 160'b0000000000011111111001111111100000110000000011000000001100000000110000000011000000001100000000110000000011000000001100000000110000000011000000001100000000000000;
// U
assign Alpha[20] = 160'b0000000000011000011001100001100110000110011000011001100001100110000110011000011001100001100110000110011000011001100001100110000110001111110000011110000000000000;
// V
assign Alpha[21] = 160'b0000000000011000011001100001100110000110011000011001100001100110000110011000011001100001100110000110011000011000110011000011001100001111110000001100000000000000;
// W
assign Alpha[22] = 160'b0000000000110000001111000000111100000011110000001111000000111100110011110011001111001100111100110011111011011101111111100011001100001100110000110011000000000000;
// X
assign Alpha[23] = 160'b0000000000011000011001100001100110000110011000011000110011000011001100000011000000001100000011001100001100110001100011000110000110011000011001100001100000000000;
// Y
assign Alpha[24] = 160'b0000000000011000011001100001100110000110011000011001100001100110000110011000011000110011000011001100001111110000001100000000110000000011000000001100000000000000;
// Z
assign Alpha[25] = 160'b0000000000011111111001111111100000000110000000011000000011000000001100000001100000000110000000110000000011000000011000000001100000011111111001111111100000000000;
// 1
assign Alpha[26] = 160'b0000000000000011000000001100000011110000001111000000001100000000110000000011000000001100000000110000000011000000001100000000110000011111111001111111100000000000;
// 2
assign Alpha[27] = 160'b0000000000001111100001111111100110000110000000011000000011000000001100000001100000000110000000110000000011000000011000000001100000011111111001111111100000000000;
// 3
assign Alpha[28] = 160'b0000000000000111110001111111100111000110000000011000000001100000000110011111111001111111100000000110000000011000000001100111000110011111111000011111000000000000;
// 4
assign Alpha[29] = 160'b0000000000000000110000000111000000101100000010110000010011000001001100001000110000100011000100001100010000110001111111100111111110000000110000000011000000000000;
// 5
assign Alpha[30] = 160'b0000000000011111111001111111100110000000011000000001100000000110000000011111000001111110000000001100000000011000000001100000001100000011110001111110000000000000;
// 6
assign Alpha[31] = 160'b0000000000000000000000000110000000110000000110000000110000000110000000010111100001110011000110000110011000011001100001100011001100000111100000000000000000000000;
// 7
assign Alpha[32] = 160'b0000000000000000000001111111000111111100000000110000000011000000001100000000110000000011000000001100000000110000000011000000000000000000000000000000000000000000;
// 8
assign Alpha[33] = 160'b0000000000000111100000111111000110000110011000011001100001100011111100000111100000011110000011111100011000011001100001100110000110001111110000011110000000000000;
// 9
assign Alpha[34] = 160'b0000000000000000000001111111100110000110011000011001100001100111111110000000111000000011100000001110000000111000000011100000001110000000000000000000000000000000;
// 0
assign Alpha[35] =160'b0000000000000000000000011110000011111100011000011001100001100110000110011000011001100001100110000110011000011001100001100011111100000111100000000000000000000000;
//:
assign Alpha[36] =160'b0000000000000000000000000000000001111000000111100000011110000000000000000000000000000000000001111000000111100000011110000000000000000000000000000000000000000000; 
always @(posedge CLOCK_50) // 50HMz Prescale to 25MHz
begin	
	iCLK = ~iCLK;
end

// [Second] Count  -->  Reject // At Underflow Code.. This isn't Usable

always @(posedge CLOCK_50)
begin
	if(Cnt < 5000000)
		Cnt <= Cnt + 1;
	else begin
		if(MCnt != 0)
			MCnt <= MCnt - 1;
		else 
		begin
			if(SCnt != 0) 
			begin
				SCnt <= SCnt - 1;
				MCnt <= 9;
			end
			else 
			begin
				SCnt <=0;
				MCnt <=0;
//				Signal <=1;
				BCnt <= BCnt + 1 ;
				
				if(BCnt % 2 == 0)
						BCnt2 <= BCnt2 + 1; 					
			end
		end
		Cnt <= 0;
	end
end
	
//	H_Sync Generator,  Ref. 25.175 MHz Clock-[[0[- : 25.174MHz -> 25MHZ
always @(posedge iCLK)
begin
	//************************ Need Some SYNC Analysis.... ***********************//
	
	//	H_Sync Counter
	if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
	else
		H_Cont	<=	0;
	
	//	H_Sync Generator
	if( H_Cont < H_SYNC_CYC )
		VGA_HS	<=	0;
	else
		VGA_HS	<=	1;
	//end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK)// or negedge iRST_N)
begin
	
	//	When H_Sync Re-start
	if(H_Cont==0)
	begin
		//	V_Sync Counter
		if( V_Cont < V_SYNC_TOTAL )
		V_Cont	<=	V_Cont+1;
		else
		V_Cont	<=	0;
		
		//	V_Sync Generator
		if(	V_Cont < V_SYNC_CYC )
		VGA_VS	<=	0;
		else
		VGA_VS	<=	1;
	end
end


always@(posedge iCLK )
begin
	col <= H_Cont - X_START;
	row <= V_Cont - Y_START;
end


always@(posedge iCLK)
begin

	// Character (TEST) Display 

	// First Section Start
	if( ( 0 <= row ) & ( row < 240) ) begin

		if( ( 192 <= col ) & ( col < 232 ) & ( 100 <= row ) & ( row < 164 ) )
			if( Alpha[2][ (col - 192)/4 + ((row - 100)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
			else
				RGB <= 30'b 1111111111_1111111111_1111111111; //흰색
				//C
		else if( ( 232 <= col ) & ( col < 272 ) & ( 100 <= row ) & ( row < 164 ) )
			if( Alpha[11][ (col - 232)/4 + ((row - 100)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000;
			else
				RGB <= 30'b 1111111111_1111111111_1111111111;
				//L
		else if( ( 272 <= col ) & ( col < 312 ) & ( 100 <= row ) & ( row < 164 ) )
			if( Alpha[14][ (col - 272)/4 + ((row - 100)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000;
			else
				RGB <= 30'b 1111111111_1111111111_1111111111;
				//O
		else if( ( 312 <= col ) & ( col < 352 ) & ( 100 <= row ) & ( row < 164 ) )
			if( Alpha[2][ (col - 312)/4 + ((row - 100)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000;
			else
				RGB <= 30'b 1111111111_1111111111_1111111111;
				//C
      else if( ( 352 <= col ) & ( col < 392 ) & ( 100 <= row ) & ( row < 164 ) )
			if( Alpha[10][ (col - 352)/4 + ((row - 100)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000;
			else
				RGB <= 30'b 1111111111_1111111111_1111111111;
				//K
		// Default Blank
		else
			RGB <= 30'b 1111111111_1111111111_1111111111; 

	end // WELCOME 출력
	
	if( ( 200 <= row ) & ( row < 270) ) begin
	
	   if( ( 192 <= col ) & ( col < 232 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if(HEX5==7'b1001111)begin
				if( Alpha[26][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0010010)begin
				if( Alpha[27][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0000110)begin
				if( Alpha[28][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b1001100)begin
				if( Alpha[29][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0100100)begin
				if( Alpha[30][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0100000)begin
				if( Alpha[31][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0001101)begin
				if( Alpha[32][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0000000)begin
				if( Alpha[33][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0000100)begin
				if( Alpha[34][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX5==7'b0000001)begin
				if( Alpha[35][ (col - 192)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
		end
				//5
		else if( ( 232 <= col ) & ( col < 272 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if(HEX4==7'b1001111)begin
				if( Alpha[26][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0010010)begin
				if( Alpha[27][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0000110)begin
				if( Alpha[28][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b1001100)begin
				if( Alpha[29][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0100100)begin
				if( Alpha[30][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0100000)begin
				if( Alpha[31][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0001101)begin
				if( Alpha[32][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0000000)begin
				if( Alpha[33][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0000100)begin
				if( Alpha[34][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX4==7'b0000001)begin
				if( Alpha[35][ (col - 232)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
		end
				//4
		else if( ( 272 <= col ) & ( col < 312 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if( Alpha[36][ (col - 272)/4 + ((row - 200)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000;
			else
				RGB <= 30'b 1111111111_1111111111_1111111111;
		end
				//:
		else if( ( 312 <= col ) & ( col < 352 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if(HEX3==7'b1001111)begin
				if( Alpha[26][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0010010)begin
				if( Alpha[27][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0000110)begin
				if( Alpha[28][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b1001100)begin
				if( Alpha[29][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0100100)begin
				if( Alpha[30][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0100000)begin
				if( Alpha[31][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0001101)begin
				if( Alpha[32][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0000000)begin
				if( Alpha[33][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0000100)begin
				if( Alpha[34][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX3==7'b0000001)begin
				if( Alpha[35][ (col - 312)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
		end
				//3
      else if( ( 352 <= col ) & ( col < 392 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if(HEX2==7'b1001111)begin
				if( Alpha[26][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0010010)begin
				if( Alpha[27][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0000110)begin
				if( Alpha[28][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b1001100)begin
				if( Alpha[29][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0100100)begin
				if( Alpha[30][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0100000)begin
				if( Alpha[31][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0001101)begin
				if( Alpha[32][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0000000)begin
				if( Alpha[33][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0000100)begin
				if( Alpha[34][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX2==7'b0000001)begin
				if( Alpha[35][ (col - 352)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
		end
				//2
		else if( ( 392 <= col ) & ( col < 432 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if( Alpha[36][ (col - 392)/4 + ((row - 200)/4)*10 ] == 1'b1 )
				RGB <= 30'b 0000000000_0000000000_0000000000;
			else
				RGB <= 30'b 1111111111_1111111111_1111111111;
		end
				//:
		else if( ( 432 <= col ) & ( col < 472 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if(HEX1==7'b1001111)begin
				if( Alpha[26][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0010010)begin
				if( Alpha[27][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0000110)begin
				if( Alpha[28][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b1001100)begin
				if( Alpha[29][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0100100)begin
				if( Alpha[30][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0100000)begin
				if( Alpha[31][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0001101)begin
				if( Alpha[32][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0000000)begin
				if( Alpha[33][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0000100)begin
				if( Alpha[34][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX1==7'b0000001)begin
				if( Alpha[35][ (col - 432)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
		end		
				//1
		else if( ( 472 <= col ) & ( col < 512 ) & ( 200 <= row ) & ( row < 264 ) )begin
			if(HEX0==7'b1001111)begin
				if( Alpha[26][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0010010)begin
				if( Alpha[27][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0000110)begin
				if( Alpha[28][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b1001100)begin
				if( Alpha[29][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0100100)begin
				if( Alpha[30][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0100000)begin
				if( Alpha[31][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0001101)begin
				if( Alpha[32][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0000000)begin
				if( Alpha[33][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0000100)begin
				if( Alpha[34][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
			else if(HEX0==7'b0000001)begin
				if( Alpha[35][ (col - 472)/4 + ((row - 200)/4)*10 ] == 1'b1 )
					RGB <= 30'b 0000000000_0000000000_0000000000; //검정색
				else
					RGB <= 30'b 1111111111_1111111111_1111111111;
			end
		end
		//0
	end
	
end
endmodule

