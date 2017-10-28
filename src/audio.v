module audio(ALM,CLOCK, Button,music,SDAT, SCLK, ADCLRCK, ADCDAT, DACLRCK, DACDAT, BCLK, XCK);
	input ALM;
	input CLOCK;
	input [1:0] Button;
	input [7:0] music;
	input ADCDAT;
	inout SDAT;
	output SCLK;
	output ADCLRCK, DACLRCK;
	output DACDAT;
	output reg BCLK;
	output reg XCK;
	parameter REF_CLK = 18432000;
	parameter SAMPLE_RATE = 48000;
	parameter DATA_WIDTH = 16;
	parameter CHANNEL_NUM = 2;
	parameter SIN_SAMPLE_DATA = 48;
	parameter DO = 2000;
	parameter RE = 1900;
	parameter MI = 1805;
	parameter PA = 1760;
	parameter SOL =1675;
	parameter LA = 1595;
	parameter SI = 1520;
	parameter DO1 = 1485;
	//reg ARARM =1;
	reg CLOCK_27M=0;
	reg [19:0] COUNT20;
	reg DLY_RST;
	reg [3:0] BCK_DIV;
	reg [8:0] LRCK_1X_DIV;
	reg LRCK_1X;
	reg [3:0] SEL_COUNT;
	reg [11:0] COUNT12;
	reg SIGN;
	wire [7:0] LD;
	reg [DATA_WIDTH-1:0] SOUND1, SOUND2, SOUND3;
	/*reg [1:0] COUNT2;*/
	reg [7:0] OCTAVE;
	/*reg [3:0] VOL;*/
	
	i2c_codec_control u1(.iCLK(CLOCK_27M), .iRST_N(Button[0]),.I2C_SCLK(SCLK), .I2C_SDAT(SDAT), .LUT_INDEX(LD[7:4]));
	always@(posedge CLOCK)
		begin
			CLOCK_27M = ~CLOCK_27M;
		end
	
	always@(posedge CLOCK_27M or negedge DLY_RST)
		begin
			if(!DLY_RST)
				XCK <= 1'b0;
			else
				XCK <= ~XCK;
		end
	always@(posedge CLOCK_27M)
		begin
			if(COUNT20!=20'hFFFFF)
				begin
					COUNT20 <= COUNT20 +1;
					DLY_RST <=1'b0;
				end
			else
				DLY_RST <= 1'b1;
		end
	always@(posedge CLOCK_27M or negedge DLY_RST)
		begin
			if(!DLY_RST)
				begin
					BCK_DIV <= 4'b0000;
					BCLK <= 1'b0;
				end
			else 
				begin
					if(BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1)
						begin
							BCK_DIV <= 4'b0000;
							BCLK <= ~BCLK;
						end
					else
						BCK_DIV <=BCK_DIV + 1;
				end
			end
	always@(posedge XCK or negedge DLY_RST)
		begin
			if(!DLY_RST)
				begin
					LRCK_1X_DIV <= 9'b000000000;
					LRCK_1X <= 1'b0;
				end
			else
				begin
				if(LRCK_1X_DIV>=REF_CLK/(SAMPLE_RATE*2)-1)
					begin
						LRCK_1X_DIV <= 9'b000000000;
						LRCK_1X <= ~LRCK_1X;
					end
				else
					LRCK_1X_DIV <= LRCK_1X_DIV +1;
			end
		end
		
		assign ADCLRCK = LRCK_1X;
		assign DACLRCK = LRCK_1X;
		
		always@(negedge BCLK or negedge DLY_RST)
			begin
				if(!DLY_RST)
					OCTAVE <= 8'b00000000;
				else
					if(|music)
						OCTAVE <= music;
			end
		always@(posedge BCLK or negedge DLY_RST)
			begin
				if(!DLY_RST)
					COUNT12 <= 12'h000;
				else
					begin
					if(OCTAVE == 8'b00000001)
						begin
						if(COUNT12==DO)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b00000010)
						begin
						if(COUNT12==RE)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b00000100)
						begin
						if(COUNT12==MI)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b00001000)
						begin
						if(COUNT12==PA)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b00010000)
						begin
						if(COUNT12==SOL)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b00100000)
						begin
						if(COUNT12==LA)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b01000000)
						begin
						if(COUNT12==SI)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					else if(OCTAVE==8'b10000000)
						begin
						if(COUNT12==DO1)
							COUNT12 <= 12'h000;
						else
							COUNT12 <= COUNT12+1;
						end
					end
			end
			//assign LEDR = OCTAVE;
			always@(negedge BCLK or negedge DLY_RST)
			begin
				if(!DLY_RST)
					begin
					SOUND1 <=0;
					//SOUND2 <=0;
					//SOUND3 <=0;
					SIGN <= 1'b0;
					end
				else
					begin
					if(COUNT12 == 12'h001)
						begin
						SOUND1 <=(SIGN==1'b1)?32768+29000:32768-29000;
						//SOUND2 <=(SIGN==1'b1)?32768+29000:32768-29000;
						//SOUND3 <=(SIGN==1'b1)?32768+29000:32768-29000;
						SIGN <= ~SIGN;
						end
					end
			end
			/*always@(negedge KEY[3] or negedge DLY_RST)
			begin
				if(!DLY_RST)
					COUNT2 <=2'b00;
				else
					COUNT2 <= COUNT2 +1;
			end*/
			always@(negedge BCLK or negedge DLY_RST)
			begin
				if(!DLY_RST)
					SEL_COUNT <=4'b0000;
				else
					SEL_COUNT <=SEL_COUNT+1;
			end
			assign DACDAT = (ALM==2'd1)?SOUND1[~SEL_COUNT]:1'b0;
			
endmodule
module i2c_codec_control(iCLK, iRST_N, I2C_SCLK, I2C_SDAT, LUT_INDEX);
	input iCLK, iRST_N;
	inout I2C_SDAT;
	output I2C_SCLK;
	output [3:0] LUT_INDEX;

	reg [15:0] mI2C_CLK_DIV;
	reg [23:0] mI2C_DATA;
	reg mI2C_CTRL_CLK, mI2C_SCLK;
	reg mI2C_GO, mI2C_END;
	reg [2:0] mSetup_ST;
	reg [15:0] LUT_DATA;
	reg [3:0] LUT_INDEX;
	reg [23:0] SD;
	reg [5:0] SD_COUNT;
	reg SDO;
	reg [2:0] ACK;
	
	wire I2C_SCLK =mI2C_SCLK|(((SD_COUNT>=4)&&(SD_COUNT<=30))?~mI2C_CTRL_CLK:0);
	wire I2C_SDAT = SDO ? 1'bz:0;
	wire mI2C_ACK = ACK[0] | ACK[1] | ACK[2];
	
	parameter CLK_Freq = 50000000;
	parameter I2C_Freq = 20000;
	parameter LUT_SIZE = 11;
	
	always@(posedge iCLK or negedge iRST_N)
	begin
		if(!iRST_N)
			begin
			mI2C_CTRL_CLK <=1'b0;
			mI2C_CLK_DIV <=16'h0000;
			end
		else
			begin
			if(mI2C_CLK_DIV <(CLK_Freq/I2C_Freq))
				mI2C_CLK_DIV <= mI2C_CLK_DIV+1;
			else
				begin
					mI2C_CLK_DIV <= 16'h00000;
					mI2C_CTRL_CLK<= ~mI2C_CTRL_CLK;
				end
			end
	end
	always@(negedge iRST_N or negedge mI2C_CTRL_CLK)
	begin
		if(!iRST_N)
			SD_COUNT <=6'b111111;
		else
			begin
			if(mI2C_GO == 1'b0)
				SD_COUNT <=6'b000000;
			else if(SD_COUNT<6'b111111)
				SD_COUNT <= SD_COUNT+1;
			end
	end
	always@(negedge iRST_N or posedge mI2C_CTRL_CLK)
	begin
		if(!iRST_N)
			begin
			mI2C_SCLK <= 1'b1;
			SD<=24'h000000;
			SDO <=1'b1;
			ACK <= 3'b000;
			mI2C_END <=1'b1;
			end
		else
			begin
			case(SD_COUNT)
				6'd0: begin
						ACK<= 3'b000;
						mI2C_END <=1'b0;
						SDO <=1'b1;
						mI2C_SCLK <=1'b1;
						end
				6'd1: begin
						SD <= mI2C_DATA;
						SDO <= 1'b0;
						end
				6'd2: mI2C_SCLK <=1'b0;
				6'd3: SDO <=SD[23];
				6'd4: SDO <=SD[22];
				6'd5: SDO <=SD[21];
				6'd6: SDO <=SD[20];
				6'd7: SDO <=SD[19];
				6'd8: SDO <=SD[18];
				6'd9: SDO <=SD[17];
				6'd10: SDO <=SD[16];
				6'd11: SDO <=1'b1;
				6'd12: begin
							SDO<=SD[15];
							ACK[0] <=I2C_SDAT;
							end
				6'd13: SDO <=SD[14];
				6'd14: SDO <=SD[13];
				6'd15: SDO <=SD[12];
				6'd16: SDO <=SD[11];
				6'd17: SDO <=SD[10];
				6'd18: SDO <=SD[9];
				6'd19: SDO <=SD[8];
				6'd20: SDO <=1'b1;
				6'd21: begin
						SDO <= SD[7];
						ACK[1] <= I2C_SDAT;
						end
				6'd22: SDO <=SD[6];
				6'd23: SDO <=SD[5];
				6'd24: SDO <=SD[4];
				6'd25: SDO <=SD[3];
				6'd26: SDO <=SD[2];
				6'd27: SDO <=SD[1];
				6'd28: SDO <=SD[0];
				6'd29: SDO <=1'b1;
				6'd30: begin
							SDO<=1'b0;
							mI2C_SCLK <=1'b0;
							ACK[2] <= I2C_SDAT;
						end
				6'd31: begin
						SDO <=1'b0;
						mI2C_SCLK <=1'b0;
						ACK[2]<=I2C_SDAT;
						end
				6'd32: begin
						SDO <= 1'b1;
						mI2C_END <=1'b1;
						end
			endcase
			end
			
	end
	always@(negedge mI2C_CTRL_CLK or negedge iRST_N)
	begin
		if(!iRST_N)
			begin
			LUT_INDEX <=4'b0000;
			mSetup_ST <= 3'b000;
			mI2C_GO <=1'b0;
			mI2C_DATA<=24'h000000;
			end
		else
			begin
			if(LUT_INDEX<LUT_SIZE)
			begin
			case(mSetup_ST)
				0: begin
					mI2C_DATA<={8'h34, LUT_DATA};
					mI2C_GO <=1'b1;
					mSetup_ST <= 1;
					end
				1: begin
					if(mI2C_END)
						begin
						mI2C_GO <=1'b0;
						if(!mI2C_ACK)
							mSetup_ST <=2;
						else
							mSetup_ST <=0;
						end
					end
				2: begin
					LUT_INDEX <=LUT_INDEX +1;
					mSetup_ST<=0;
					end
				endcase
				end
			end
	end
	always@(LUT_INDEX)
	begin
		case(LUT_INDEX)
			0: LUT_DATA <=16'h0000;
			1: LUT_DATA <=16'h001A;
			2: LUT_DATA <=16'h021A;
			3: LUT_DATA <=16'h047B;
			4: LUT_DATA <=16'h067B;
			5: LUT_DATA <=16'h08F8;
			6: LUT_DATA <=16'h0A06;
			7: LUT_DATA <=16'h0C00;
			8: LUT_DATA <=16'h0E01;
			9: LUT_DATA <=16'h1002;
			10: LUT_DATA <=16'h1201;
			default: LUT_DATA <=16'h0000;
		endcase
	end
endmodule
	
