/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This module monitors the data from UART
// It also assembles and writes the data into the SRAM
module M1_interface (
   input  logic		Clock,
   input  logic		Resetn, 

   input  logic		Initialize,
   
   input  logic [15:0]  SRAM_read_data,
   output logic [17:0]	SRAM_address,
   output logic [15:0]	SRAM_write_data,
   output logic		SRAM_we_n,
   
   output logic M1Finished
   
);

M1_state_type SRAM_state;



//Our Defined Variables


logic [15:0] R_VALUE;
logic [15:0] G_VALUE;
logic [15:0] B_VALUE;

logic [31:0] R_CALC_E;
logic [31:0] R_CALC_O;

logic [31:0] G_CALC_E;
logic [31:0] G_CALC_O;

logic [31:0] B_CALC_E;
logic [31:0] B_CALC_O;


logic [15:0] U_REG [5:0];
logic [15:0] V_REG [5:0];

logic [7:0] U_PRIME;//fix this later
logic [31:0] U_PRIME_CALC;

//************************//


logic [7:0] V_PRIME;//fix this later
logic [31:0] V_PRIME_CALC;

//logic [7:0] U_OLD;
//logic [7:0] V_OLD;
//logic [7:0] V_PRIME_BEFORE;

logic [15:0] Y_STORE;
logic [31:0] Y_MULTIPLY;

logic [15:0] U_STORE;
logic [15:0] V_STORE;

logic [8:0] COL_NUM;

logic flag;




logic [31:0] op11, op12, m1;
logic [63:0] product_long1;
assign product_long1 = $signed(op11) * $signed(op12);
assign m1 = product_long1[31:0];

logic [31:0] op21, op22, m2;
logic [63:0] product_long2;
assign product_long2 = $signed(op21) * $signed(op22);
assign m2 = product_long2[31:0];

logic [31:0] op31, op32, m3;
logic [63:0] product_long3;
assign product_long3 = $signed(op31) * $signed(op32);
assign m3 = product_long3[31:0];

logic [31:0] op41, op42, m4;
logic [63:0] product_long4;
assign product_long4 = $signed(op41) * $signed(op42);
assign m4 = product_long4[31:0];
	
	

//logic [63:0] m1;
//logic [63:0] m2;
//logic [63:0] m3;
//logic [63:0] m4;

logic [17:0] Y_START;
logic [17:0] U_START;
logic [17:0] V_START;
logic [17:0] COLOUR_START;




always_ff @ (posedge Clock or negedge Resetn) begin
// Receive data from UART
	if (~Resetn) begin

		Y_START <= 18'd0;
		U_START <= 18'd38400;
		V_START <= 18'd57600;
		
		COLOUR_START <= 18'd146944;
			
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;

		U_REG[5] <= 8'd0;
		U_REG[4] <= 8'd0;
		U_REG[3] <= 8'd0;
		U_REG[2] <= 8'd0;
		U_REG[1] <= 8'd0;
		U_REG[0] <= 8'd0;
		
		V_REG[5] <= 8'd0;
		V_REG[4] <= 8'd0;
		V_REG[3] <= 8'd0;
		V_REG[2] <= 8'd0;
		V_REG[1] <= 8'd0;
		V_REG[0] <= 8'd0;
		
	//	U_OLD <= 8'd0;
	//	V_PRIME_BEFORE <= 8'd0;
		
		Y_MULTIPLY <= 32'd0;
		Y_STORE <= 16'd0;
		U_STORE <= 16'd0;
		V_STORE <= 16'd0;
		
		op11 <= 32'b0;
		op12 <= 32'b0;
		op21 <= 32'b0;
		op22 <= 32'b0;
		op31 <= 32'b0;
		op32 <= 32'b0;
		op41 <= 32'b0;
		op42 <= 32'b0;
		
		U_PRIME <= 8'd0;
		V_PRIME <= 8'd0;
		
		U_PRIME_CALC <= 32'd0;
		V_PRIME_CALC <= 32'd0;
		
		
		R_CALC_E <= 32'd0;
		R_CALC_O <= 32'd0;
		
		G_CALC_E <= 32'd0;
		G_CALC_O <= 32'd0;
		
		B_CALC_E <= 32'd0;
		B_CALC_O <= 32'd0;
		
		
		R_VALUE <= 16'd0;
		G_VALUE <= 16'd0;
		B_VALUE <= 16'd0;
		
		
		COL_NUM <= 9'd0;
		
				
		flag <= 1'b0;
		M1Finished <= 1'b0;
		
		SRAM_state <= S_M1_IDLE;
	end else begin
		case (SRAM_state)
			
			S_M1_IDLE: begin
			
				Y_START <= 18'd0;
				U_START <= 18'd38400;
				V_START <= 18'd57600;
				
				COLOUR_START <= 18'd146944;
					
				SRAM_we_n <= 1'b1;
				SRAM_write_data <= 16'd0;
				SRAM_address <= 18'd0;

				U_REG[5] <= 8'd0;
				U_REG[4] <= 8'd0;
				U_REG[3] <= 8'd0;
				U_REG[2] <= 8'd0;
				U_REG[1] <= 8'd0;
				U_REG[0] <= 8'd0;
				
				V_REG[5] <= 8'd0;
				V_REG[4] <= 8'd0;
				V_REG[3] <= 8'd0;
				V_REG[2] <= 8'd0;
				V_REG[1] <= 8'd0;
				V_REG[0] <= 8'd0;
				
				//U_OLD <= 8'd0;
				//V_PRIME_BEFORE <= 8'd0;
				
				Y_MULTIPLY <= 32'd0;
				Y_STORE <= 16'd0;
				U_STORE <= 16'd0;
				V_STORE <= 16'd0;
				
				op11 <= 32'b0;
				op12 <= 32'b0;
				op21 <= 32'b0;
				op22 <= 32'b0;
				op31 <= 32'b0;
				op32 <= 32'b0;
				op41 <= 32'b0;
				op42 <= 32'b0;
				
				U_PRIME <= 8'd0;
				V_PRIME <= 8'd0;
				
				U_PRIME_CALC <= 32'd0;
				V_PRIME_CALC <= 32'd0;
				
				
				R_CALC_E <= 32'd0;
				R_CALC_O <= 32'd0;
				
				G_CALC_E <= 32'd0;
				G_CALC_O <= 32'd0;
				
				B_CALC_E <= 32'd0;
				B_CALC_O <= 32'd0;
				
				
				R_VALUE <= 16'd0;
				G_VALUE <= 16'd0;
				B_VALUE <= 16'd0;
				
				COL_NUM <= 9'd0;
						
				flag <= 1'b0;
				M1Finished <= 1'b0;
				
				if (Initialize)
					SRAM_state <= S_LI_1;
				

			end
			
			//****************************//
			//********LEAD IN START*******//
			//****************************//
			
			S_LI_1: begin
				
				SRAM_address <= Y_START;
				Y_START <= Y_START + 18'd1;
				SRAM_we_n <= 1'b1;
								
				SRAM_state <= S_LI_2;
			end
			
			S_LI_2: begin
				
				SRAM_address <= U_START;
				U_START <= U_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				SRAM_state <= S_LI_3;
			end
			
			S_LI_3: begin
				
				SRAM_address <= V_START;
				V_START <= V_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				SRAM_state <= S_LI_4;
			end
			
			S_LI_4: begin
				
				SRAM_we_n <= 1'b1;
				
				Y_STORE <= SRAM_read_data;
				SRAM_state <= S_LI_5;
			end
			
			S_LI_5: begin
				
				SRAM_we_n <= 1'b1;
				
				U_STORE <= SRAM_read_data;
				
				SRAM_state <= S_LI_6;
			end
			
			S_LI_6: begin
				
				SRAM_we_n <= 1'b1;
				
				U_REG[1] <= U_STORE[15:8];
				U_REG[0] <= U_STORE[7:0];
				
				V_REG[1] <= SRAM_read_data[15:8];
				V_REG[0] <= SRAM_read_data[7:0];
				
				SRAM_state <= S_LI_7;
			end
			
			
			//LEAD IN CASE 2
			
			S_LI_7: begin
				
				SRAM_we_n <= 1'b1;
								
				SRAM_state <= S_LI_8;
			end
			
			S_LI_8: begin
				
				SRAM_address <= U_START;
				U_START <= U_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				SRAM_state <= S_LI_9;
			end
			
			S_LI_9: begin
				
				SRAM_address <= V_START;
				V_START <= V_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				SRAM_state <= S_LI_10;
			end
			
			S_LI_10: begin
				
				SRAM_we_n <= 1'b1;
				
				SRAM_state <= S_LI_11;
			end
			
			S_LI_11: begin
				
				SRAM_we_n <= 1'b1;
				
				U_STORE <= SRAM_read_data;
				
				SRAM_state <= S_LI_12;
			end
			
			S_LI_12: begin
				
				SRAM_we_n <= 1'b1;
				
				
				
		//		U_REG[5] <= U_REG[1];
		//		U_REG[4] <= U_REG[1];
				U_REG[3] <= U_REG[1];
				U_REG[2] <= U_REG[0];
				
				
		//		V_REG[5] <= V_REG[1];
		//		V_REG[4] <= V_REG[1];
				V_REG[3] <= V_REG[1];
				V_REG[2] <= V_REG[0];
				
				U_REG[1] <= U_STORE[15:8];
				U_REG[0] <= U_STORE[7:0];
				
				V_REG[1] <= SRAM_read_data[15:8];
				V_REG[0] <= SRAM_read_data[7:0];
				
				SRAM_state <= S_LI_13;
			end
			
			
			//LEAD IN CASE 3
			
			
			S_LI_13: begin
				
				SRAM_we_n <= 1'b1;
				
				//m1
				op11 <= 32'd21;
				op12 <= U_REG[3];
				
				//m2
				op21 <= 32'd21;
				op22 <= V_REG[3];

	
				SRAM_state <= S_LI_14;
			end
			
			S_LI_14: begin
				
				SRAM_address <= U_START;
				U_START <= U_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				
				U_PRIME_CALC <= m1;
				
				V_PRIME_CALC <= m2;
				
				//m1
				op11 <= 32'd52;
				op12 <= U_REG[3];
				
				//m2
				op21 <= 32'd52;
				op22 <= V_REG[3];
				
				
				SRAM_state <= S_LI_15;
			end
			
			S_LI_15: begin
				
				SRAM_address <= V_START;
				V_START <= V_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				//m1
				op11 <= 32'd159;
				op12 <= U_REG[3];
				
				//m2
				op21 <= 32'd159;
				op22 <= V_REG[3];
				
				SRAM_state <= S_LI_16;
			end
			
			S_LI_16: begin
				
				SRAM_we_n <= 1'b1;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				
				//m1
				op11 <= 32'd159;
				op12 <= U_REG[2];
				
				//m2
				op21 <= 32'd159;
				op22 <= V_REG[2];
				
				SRAM_state <= S_LI_17;
			end
			
			S_LI_17: begin
				
				SRAM_we_n <= 1'b1;
				
				U_STORE <= SRAM_read_data;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				//m1
				op11 <= 32'd52;
				op12 <= U_REG[1];
				
				//m2
				op21 <= 32'd52;
				op22 <= V_REG[1];
				
				SRAM_state <= S_LI_18;
			end
			
			S_LI_18: begin
				
				SRAM_we_n <= 1'b1;
				
				V_STORE <= SRAM_read_data;
				
				//m1
				op11 <= 32'd21;
				op12 <= U_REG[0];
				
				//m2
				op21 <= 32'd21;
				op22 <= V_REG[0];
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				U_REG[5] <= U_REG[4];
				U_REG[4] <= U_REG[3];
				U_REG[3] <= U_REG[2];
				U_REG[2] <= U_REG[1];
				U_REG[1] <= U_REG[0];
				U_REG[0] <= U_STORE[15:8];
				
				V_REG[5] <= V_REG[4];
				V_REG[4] <= V_REG[3];
				V_REG[3] <= V_REG[2];
				V_REG[2] <= V_REG[1];
				V_REG[1] <= V_REG[0];
				V_REG[0] <= SRAM_read_data[15:8];
				
				SRAM_state <= S_LI_19;
			end
			
			
			//LEAD IN CASE 4
			
			
			S_LI_19: begin
				
				SRAM_address <= Y_START;
				Y_START <= Y_START + 18'd1;
				SRAM_we_n <= 1'b1;

				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;

				//m1
				op11 <= 32'd21;
				op12 <= U_REG[4];
				
				//m2
				op21 <= 32'd21;
				op22 <= V_REG[4];
				
				//m3
				op31 <= 32'd76284;
				op32 <= Y_STORE[15:8]-8'd16;
				
				//m4
				op41 <= 32'd104595;
				op42 <= V_REG[4]-8'd128;
				
								
				SRAM_state <= S_LI_20;
			end
			
			S_LI_20: begin
				SRAM_we_n <= 1'b1;
				
				R_CALC_E <= m3 + m4;
				
				Y_MULTIPLY <= m3;
				
				U_PRIME_CALC <= m1;
				U_PRIME <= (U_PRIME_CALC+8'd128)>>>8;
				
				V_PRIME_CALC <= m2;
				V_PRIME <= (V_PRIME_CALC+8'd128)>>>8;//V_PRIME_BEFORE;
			//	V_PRIME_BEFORE <= (V_PRIME_CALC+8'd128)>>>8;
				
				//m1
				op11 <= 32'd52;
				op12 <= U_REG[4];
				
				//m2
				op21 <= 32'd52;
				op22 <= V_REG[4];
								
				//m3
				op31 <= 32'd25624;
				op32 <= U_REG[4]-8'd128;
				
				
				//m4
				op41 <= 32'd53281;
				op42 <= V_REG[4]-8'd128;
				
				
				
				
				SRAM_state <= S_LI_21;
			end
			
			S_LI_21: begin
				SRAM_we_n <= 1'b1;
				
				G_CALC_E <= Y_MULTIPLY - m3 - m4;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				
				//m1
				op11 <= 32'd159;
				op12 <= U_REG[3];
				
				//m2
				op21 <= 32'd159;
				op22 <= V_REG[3];
				
				//m3
				op31 <= 32'd76284;
				op32 <= Y_STORE[7:0]-8'd16;
				
				//m4
				op41 <= 32'd132251;
				op42 <= U_REG[4]-8'd128;//******************************************************************change to u_reg[4] maybe
				
				
				SRAM_state <= S_LI_22;
			end
			
			S_LI_22: begin
				
				SRAM_we_n <= 1'b1;
				
				Y_STORE <= SRAM_read_data;
				
				B_CALC_E <= Y_MULTIPLY + m4;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				Y_MULTIPLY <= m3;
				
				//m1
				op11 <= 32'd159;
				op12 <= U_REG[2];
				
				//m2
				op21 <= 32'd159;
				op22 <= V_REG[2];
				
				//m3
				op31 <= 32'd132251;
				op32 <= U_PRIME-8'd128;
				
				//m4
				op41 <= 32'd104595;
				op42 <= V_PRIME-8'd128;
				
				SRAM_state <= S_LI_23;
			end
			
			S_LI_23: begin
				
				SRAM_we_n <= 1'b1;
				
				R_CALC_O <= Y_MULTIPLY + m4;
				B_CALC_O <= Y_MULTIPLY + m3;
				
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				
				//m1
				op11 <= 32'd52;
				op12 <= U_REG[1];
				
				//m2
				op21 <= 32'd52;
				op22 <= V_REG[1];
				
				
				op31 <= 32'd25624;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd53281;
				op42 <= V_PRIME-8'd128;
				
				
				SRAM_state <= S_LI_24;
			end
			
			S_LI_24: begin
				
				SRAM_we_n <= 1'b1;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				//m1
				op11 <= 32'd21;
				op12 <= U_REG[0];
				
				//m2
				op21 <= 32'd21;
				op22 <= V_REG[0];
				
				G_CALC_O <= Y_MULTIPLY - m3-m4;
				
				U_REG[5] <= U_REG[4];
				U_REG[4] <= U_REG[3];
				U_REG[3] <= U_REG[2];
				U_REG[2] <= U_REG[1];
				U_REG[1] <= U_REG[0];
				U_REG[0] <= U_STORE[7:0];
				
				V_REG[5] <= V_REG[4];
				V_REG[4] <= V_REG[3];
				V_REG[3] <= V_REG[2];
				V_REG[2] <= V_REG[1];
				V_REG[1] <= V_REG[0];
				V_REG[0] <= V_STORE[7:0];
				
				flag <= 1'b0;
				COL_NUM <= 1'b0;
				
				SRAM_state <= S_C1;
			end

			
			
		
		//***************************************//
		//***********COMMON CASE START***********//
		//***************************************//
		
		
		//common case starting addres: 
			
			
			S_C1: begin
				
				SRAM_address <= Y_START;
				Y_START <= Y_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				if(R_CALC_E[31] == 1'b1) begin
					R_VALUE[15:8] <= 8'b0;
				end else if(R_CALC_E[30:24] != 7'b0) begin
					R_VALUE[15:8] <= 8'b11111111;
				end else begin
					R_VALUE[15:8] <= R_CALC_E[23:16];
				end
				
				if(R_CALC_O[31] == 1'b1) begin
					R_VALUE[7:0] <= 8'b0;
				end else if(R_CALC_O[30:24] != 7'b0) begin
					R_VALUE[7:0] <= 8'b11111111;
				end else begin
					R_VALUE[7:0] <= R_CALC_O[23:16];
				end
				
				if(G_CALC_E[31] == 1'b1) begin
					G_VALUE[15:8] <= 8'b0;
				end else if(G_CALC_E[30:24] != 7'b0) begin
					G_VALUE[15:8] <= 8'b11111111;
				end else begin
					G_VALUE[15:8] <= G_CALC_E[23:16];
				end
				
				if(G_CALC_O[31] == 1'b1) begin
					G_VALUE[7:0] <= 8'b0;
				end else if(G_CALC_O[30:24] != 7'b0) begin
					G_VALUE[7:0] <= 8'b11111111;
				end else begin
					G_VALUE[7:0] <= G_CALC_O[23:16];
				end
				
				if(B_CALC_E[31] == 1'b1) begin
					B_VALUE[15:8] <= 8'b0;
				end else if(B_CALC_E[30:24] != 7'b0) begin
					B_VALUE[15:8] <= 8'b11111111;
				end else begin
					B_VALUE[15:8] <= B_CALC_E[23:16];
				end
				
				if(B_CALC_O[31] == 1'b1) begin
					B_VALUE[7:0] <= 8'b0;
				end else if(B_CALC_O[30:24] != 7'b0) begin
					B_VALUE[7:0] <= 8'b11111111;
				end else begin
					B_VALUE[7:0] <= B_CALC_O[23:16];
				end
				
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd21;
				op12 <= U_REG[5];
				op21 <= 32'd21;
				op22 <= V_REG[5];
				op31 <= 32'd76284;
				op32 <= Y_STORE[15:8]-8'd16;
				op41 <= 32'd104595;
				op42 <= V_REG[4]-8'd128;
				
				SRAM_state <= S_C2;
			end
			
			S_C2: begin
				
				if(~flag) begin
					SRAM_address <= U_START;
					U_START <= U_START + 18'd1;
				end
				
				SRAM_we_n <= 1'b1;				
				
				R_CALC_E <= m3 + m4;
				
				U_PRIME_CALC <= m1;
				U_PRIME <= (U_PRIME_CALC+8'd128)>>>8;
				
				V_PRIME_CALC <= m2;
		//		V_PRIME <= V_PRIME_BEFORE;
				V_PRIME <= (V_PRIME_CALC+8'd128)>>>8;

				
				op11 <= 32'd52;
				op12 <= U_REG[4];
				op21 <= 32'd52;
				op22 <= V_REG[4];
				
				
				op31 <= 32'd25624;
				op32 <= U_REG[4]-8'd128;
				op41 <= 32'd53281;
				op42 <= V_REG[4]-8'd128;
				
				//m1 <= 52*U_REG[4];
				//m2 <= 52*V_REG[4];
				//m3 <= 25624*U_REG[4];
				//m4 <= 53281*V_REG[4];
				
				Y_MULTIPLY <= m3;
				
				SRAM_state <= S_C3;
			end
			
			S_C3: begin
				
				if(~flag) begin
					SRAM_address <= V_START;
					V_START <= V_START + 18'd1;
				end
				SRAM_we_n <= 1'b1;
				
				G_CALC_E <= Y_MULTIPLY - m3 - m4;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[3];
				op21 <= 32'd159;
				op22 <= V_REG[3];
				
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[7:0]-8'd16;
				op41 <= 32'd132251;
				op42 <= U_REG[4]-8'd128;
				
				//m1 <= 159*U_REG[3];
				//m2 <= 159*V_REG[3];
				//m3 <= 76284*Y_STORE[7:0];
				//m4 <= 132251*U_REG[3];
				
				SRAM_state <= S_C4;
			end
			
			S_C4: begin
			
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= R_VALUE[15:8]; 
				SRAM_write_data[7:0] <= G_VALUE[15:8];
				SRAM_we_n <= 1'b0;
				COL_NUM <= COL_NUM + 9'd2;
				
				B_CALC_E <= Y_MULTIPLY + m4;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[2];
				op21 <= 32'd159;
				op22 <= V_REG[2];
				
				
				op31 <= 32'd132251;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd104595;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 159*U_REG[2];
				//m2 <= 159*V_REG[2];
				//m3 <= 132251*U_PRIME;
				//m4 <= 104595*V_PRIME;
				
				Y_STORE <= SRAM_read_data;

				Y_MULTIPLY <= m3;
				
				SRAM_state <= S_C5;
			end
			
			S_C5: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= B_VALUE[15:8]; 
				SRAM_write_data[7:0] <= R_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				R_CALC_O <= Y_MULTIPLY + m4;
				B_CALC_O <= Y_MULTIPLY + m3;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;				
				
				op11 <= 32'd52;
				op12 <= U_REG[1];
				op21 <= 32'd52;
				op22 <= V_REG[1];
				
				
				op31 <= 32'd25624;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd53281;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 52*U_REG[1];
				//m2 <= 52*V_REG[1];
				//m3 <= 25624*U_PRIME;
				//m4 <= 53281*V_PRIME;
				
				
				U_REG[5] <= U_REG[4];
				U_REG[4] <= U_REG[3];
				U_REG[3] <= U_REG[2];
				U_REG[2] <= U_REG[1];
				U_REG[1] <= U_REG[0];
				
				if(~flag) begin
					U_REG[0] <= SRAM_read_data[15:8];
					U_STORE <= SRAM_read_data;
				end else begin
					U_REG[0] <= U_STORE[7:0];
				end
				SRAM_state <= S_C6;
				
				
			end
			
			S_C6: begin
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;			
				SRAM_write_data[15:8] <= G_VALUE[7:0]; 
				SRAM_write_data[7:0] <= B_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				G_CALC_O <= Y_MULTIPLY - m3-m4;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;	
				
				
				
				op11 <= 32'd21;
				op12 <= U_REG[1];
				op21 <= 32'd21;
				op22 <= V_REG[0];
				
				
				V_REG[5] <= V_REG[4];
				V_REG[4] <= V_REG[3];
				V_REG[3] <= V_REG[2];
				V_REG[2] <= V_REG[1];
				V_REG[1] <= V_REG[0];
				
				if(COL_NUM==9'd310)begin
					
					
					SRAM_state <= S_LO_1;
				
				end else if(~flag) begin
				
					V_REG[0] <= SRAM_read_data[15:8];
					
					V_STORE <= SRAM_read_data;	
					SRAM_state <= S_C1;
					
				end else begin
				
					V_REG[0] <= V_STORE[7:0];
					SRAM_state <= S_C1;
					
				end
				flag <= flag? 1'b0 : 1'b1;
					
			end
			
			
			//***************************************//
			//***********LEAD OUT START***********//
			//***************************************//
		
			
			//LEAD OUT CASE 1
			
			S_LO_1: begin
				
				SRAM_address <= Y_START;
				Y_START <= Y_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				if(R_CALC_E[31] == 1'b1) begin
					R_VALUE[15:8] <= 8'b0;
				end else if(R_CALC_E[30:24] != 7'b0) begin
					R_VALUE[15:8] <= 8'b11111111;
				end else begin
					R_VALUE[15:8] <= R_CALC_E[23:16];
				end
				
				if(R_CALC_O[31] == 1'b1) begin
					R_VALUE[7:0] <= 8'b0;
				end else if(R_CALC_O[30:24] != 7'b0) begin
					R_VALUE[7:0] <= 8'b11111111;
				end else begin
					R_VALUE[7:0] <= R_CALC_O[23:16];
				end
				
				if(G_CALC_E[31] == 1'b1) begin
					G_VALUE[15:8] <= 8'b0;
				end else if(G_CALC_E[30:24] != 7'b0) begin
					G_VALUE[15:8] <= 8'b11111111;
				end else begin
					G_VALUE[15:8] <= G_CALC_E[23:16];
				end
				
				if(G_CALC_O[31] == 1'b1) begin
					G_VALUE[7:0] <= 8'b0;
				end else if(G_CALC_O[30:24] != 7'b0) begin
					G_VALUE[7:0] <= 8'b11111111;
				end else begin
					G_VALUE[7:0] <= G_CALC_O[23:16];
				end
				
				if(B_CALC_E[31] == 1'b1) begin
					B_VALUE[15:8] <= 8'b0;
				end else if(B_CALC_E[30:24] != 7'b0) begin
					B_VALUE[15:8] <= 8'b11111111;
				end else begin
					B_VALUE[15:8] <= B_CALC_E[23:16];
				end
				
				if(B_CALC_O[31] == 1'b1) begin
					B_VALUE[7:0] <= 8'b0;
				end else if(B_CALC_O[30:24] != 7'b0) begin
					B_VALUE[7:0] <= 8'b11111111;
				end else begin
					B_VALUE[7:0] <= B_CALC_O[23:16];
				end
				
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd21;
				op12 <= U_REG[5];
				op21 <= 32'd21;
				op22 <= V_REG[5];
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[15:8]-8'd16;
				op41 <= 32'd104595;
				op42 <= V_REG[4]-8'd128;
				
				
				SRAM_state <= S_LO_2;
			
			
			end
			
			
			S_LO_2: begin
				
				SRAM_we_n <= 1'b1;				
				
				R_CALC_E <= m3 + m4;
				
				U_PRIME_CALC <= m1;
				U_PRIME <= (U_PRIME_CALC+128)>>>8;
				
				V_PRIME_CALC <= m2;
				V_PRIME <= (V_PRIME_CALC+128)>>>8;
				
				op11 <= 32'd52;
				op12 <= U_REG[4];
				op21 <= 32'd52;
				op22 <= V_REG[4];
				
				
				op31 <= 32'd25624;
				op32 <= U_REG[4]-8'd128;
				op41 <= 32'd53281;
				op42 <= V_REG[4]-8'd128;
				
				//m1 <= 52*U_REG[4];
				//m2 <= 52*V_REG[4];
				//m3 <= 25624*U_REG[4];
				//m4 <= 53281*V_REG[4];
				
				Y_MULTIPLY <= m3;
			
			
				SRAM_state <= S_LO_3;
			
			end
			
			
			S_LO_3: begin
				
				SRAM_we_n <= 1'b1;
				
				G_CALC_E <= Y_MULTIPLY - m3 - m4;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[3];
				op21 <= 32'd159;
				op22 <= V_REG[3];
				
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[7:0]-8'd16;
				op41 <= 32'd132251;
				op42 <= U_REG[4]-8'd128;//                       ***************************************************************************change to u_reg [4] maybe
				
				//m1 <= 159*U_REG[3];
				//m2 <= 159*V_REG[3];
				//m3 <= 76284*Y_STORE[7:0];
				//m4 <= 132251*U_REG[3];
				
				
				SRAM_state <= S_LO_4;
			
			end
			
			
			S_LO_4: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= R_VALUE[15:8]; 
				SRAM_write_data[7:0] <= G_VALUE[15:8];
				SRAM_we_n <= 1'b0;
				
				B_CALC_E <= Y_MULTIPLY + m4;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[2];
				op21 <= 32'd159;
				op22 <= V_REG[2];
				
				
				op31 <= 32'd132251;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd104595;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 159*U_REG[2];
				//m2 <= 159*V_REG[2];
				//m3 <= 132251*U_PRIME;
				//m4 <= 104595*V_PRIME;
				
				Y_STORE <= SRAM_read_data;

				Y_MULTIPLY <= m3;
				
			
				SRAM_state <= S_LO_5;
			
			
			end
			
			
			S_LO_5: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= B_VALUE[15:8]; 
				SRAM_write_data[7:0] <= R_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				R_CALC_O <= Y_MULTIPLY + m4;
				B_CALC_O <= Y_MULTIPLY + m3;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;				
				
				op11 <= 32'd52;
				op12 <= U_REG[1];
				op21 <= 32'd52;
				op22 <= V_REG[1];
				
				
				op31 <= 32'd25624;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd53281;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 52*U_REG[1];
				//m2 <= 52*V_REG[1];
				//m3 <= 25624*U_PRIME;
				//m4 <= 53281*V_PRIME;
				
				
				U_REG[5] <= U_REG[4];
				U_REG[4] <= U_REG[3];
				U_REG[3] <= U_REG[2];
				U_REG[2] <= U_REG[1];
				
				
				SRAM_state <= S_LO_6;
			
			
			end
			
			S_LO_6: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				
				G_CALC_O <= Y_MULTIPLY - m3-m4;
				
				
				SRAM_write_data[15:8] <= G_VALUE[7:0]; 
				SRAM_write_data[7:0] <= B_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;	
				
				op11 <= 32'd21;
				op12 <= U_REG[1];//changed from 1 to 0
				op21 <= 32'd21;
				op22 <= V_REG[0];
				
				//m1 <= 21*U_REG[1];
				//m2 <= 21*V_REG[0];
				

				V_REG[5] <= V_REG[4];
				V_REG[4] <= V_REG[3];
				V_REG[3] <= V_REG[2];
				V_REG[2] <= V_REG[1];				
				
				SRAM_state <= S_LO_7;
			
			
			end
			
			
			
			//LEAD OUT CASE 2
			
			S_LO_7: begin
				
				SRAM_address <= Y_START;
				Y_START <= Y_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				if(R_CALC_E[31] == 1'b1) begin
					R_VALUE[15:8] <= 8'b0;
				end else if(R_CALC_E[30:24] != 7'b0) begin
					R_VALUE[15:8] <= 8'b11111111;
				end else begin
					R_VALUE[15:8] <= R_CALC_E[23:16];
				end
				
				if(R_CALC_O[31] == 1'b1) begin
					R_VALUE[7:0] <= 8'b0;
				end else if(R_CALC_O[30:24] != 7'b0) begin
					R_VALUE[7:0] <= 8'b11111111;
				end else begin
					R_VALUE[7:0] <= R_CALC_O[23:16];
				end
				
				if(G_CALC_E[31] == 1'b1) begin
					G_VALUE[15:8] <= 8'b0;
				end else if(G_CALC_E[30:24] != 7'b0) begin
					G_VALUE[15:8] <= 8'b11111111;
				end else begin
					G_VALUE[15:8] <= G_CALC_E[23:16];
				end
				
				if(G_CALC_O[31] == 1'b1) begin
					G_VALUE[7:0] <= 8'b0;
				end else if(G_CALC_O[30:24] != 7'b0) begin
					G_VALUE[7:0] <= 8'b11111111;
				end else begin
					G_VALUE[7:0] <= G_CALC_O[23:16];
				end
				
				if(B_CALC_E[31] == 1'b1) begin
					B_VALUE[15:8] <= 8'b0;
				end else if(B_CALC_E[30:24] != 7'b0) begin
					B_VALUE[15:8] <= 8'b11111111;
				end else begin
					B_VALUE[15:8] <= B_CALC_E[23:16];
				end
				
				if(B_CALC_O[31] == 1'b1) begin
					B_VALUE[7:0] <= 8'b0;
				end else if(B_CALC_O[30:24] != 7'b0) begin
					B_VALUE[7:0] <= 8'b11111111;
				end else begin
					B_VALUE[7:0] <= B_CALC_O[23:16];
				end
				
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd21;
				op12 <= U_REG[5];
				op21 <= 32'd21;
				op22 <= V_REG[5];
				op31 <= 32'd76284;
				op32 <= Y_STORE[15:8]-8'd16;
				op41 <= 32'd104595;
				op42 <= V_REG[4]-8'd128;
				
				
				SRAM_state <= S_LO_8;
			
			
			end
			
			
			S_LO_8: begin
				
				SRAM_we_n <= 1'b1;				
				
				R_CALC_E <= m3 + m4;
				
				U_PRIME_CALC <= m1;
				U_PRIME <= (U_PRIME_CALC+128)>>>8;
				
				V_PRIME_CALC <= m2;
				V_PRIME <= (V_PRIME_CALC+128)>>>8;
				
				op11 <= 32'd52;
				op12 <= U_REG[4];
				op21 <= 32'd52;
				op22 <= V_REG[4];
				
				
				op31 <= 32'd25624;
				op32 <= U_REG[4]-8'd128;
				op41 <= 32'd53281;
				op42 <= V_REG[4]-8'd128;
				
				//m1 <= 52*U_REG[4];
				//m2 <= 52*V_REG[4];
				//m3 <= 25624*U_REG[4];
				//m4 <= 53281*V_REG[4];
				
				Y_MULTIPLY <= m3;
			
			
				SRAM_state <= S_LO_9;
			
			end
			
			
			S_LO_9: begin
				
				SRAM_we_n <= 1'b1;
				
				G_CALC_E <= Y_MULTIPLY - m3 - m4;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[3];
				op21 <= 32'd159;
				op22 <= V_REG[3];
				
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[7:0]-8'd16;
				op41 <= 32'd132251;
				op42 <= U_REG[4]-8'd128;//*****************************************************************************************
				
				//m1 <= 159*U_REG[3];
				//m2 <= 159*V_REG[3];
				//m3 <= 76284*Y_STORE[7:0];
				//m4 <= 132251*U_REG[3];
				
				
				SRAM_state <= S_LO_10;
			
			end
			
			
			S_LO_10: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= R_VALUE[15:8]; 
				SRAM_write_data[7:0] <= G_VALUE[15:8];
				SRAM_we_n <= 1'b0;
				
				B_CALC_E <= Y_MULTIPLY + m4;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[2];
				op21 <= 32'd159;
				op22 <= V_REG[2];
				
				
				op31 <= 32'd132251;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd104595;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 159*U_REG[2];
				//m2 <= 159*V_REG[2];
				//m3 <= 132251*U_PRIME;
				//m4 <= 104595*V_PRIME;
				
				Y_STORE <= SRAM_read_data;

				Y_MULTIPLY <= m3;
				
			
				SRAM_state <= S_LO_11;
			
			
			end
			
			
			S_LO_11: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= B_VALUE[15:8]; 
				SRAM_write_data[7:0] <= R_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				R_CALC_O <= Y_MULTIPLY + m4;
				B_CALC_O <= Y_MULTIPLY + m3;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;				
				
				op11 <= 32'd52;
				op12 <= U_REG[1];
				op21 <= 32'd52;
				op22 <= V_REG[1];
				
				
				op31 <= 32'd25624;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd53281;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 52*U_REG[1];
				//m2 <= 52*V_REG[1];
				//m3 <= 25624*U_PRIME;
				//m4 <= 53281*V_PRIME;
				
				
				U_REG[5] <= U_REG[4];
				U_REG[4] <= U_REG[3];
				U_REG[3] <= U_REG[2];

				
			
				SRAM_state <= S_LO_12;
			
			
			end
			
			S_LO_12: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				
				G_CALC_O <= Y_MULTIPLY - m3-m4;
				
				
				SRAM_write_data[15:8] <= G_VALUE[7:0]; 
				SRAM_write_data[7:0] <= B_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;	
				
				op11 <= 32'd21;
				op12 <= U_REG[1];//changed from 1 to 0
				op21 <= 32'd21;
				op22 <= V_REG[0];
				
				//m1 <= 21*U_REG[1];
				//m2 <= 21*V_REG[0];
				

				V_REG[5] <= V_REG[4];
				V_REG[4] <= V_REG[3];
				V_REG[3] <= V_REG[2];

				
					
				SRAM_state <= S_LO_13;
			
			
			end
			
			
			//LEAD OUT CASE 3
			
			S_LO_13: begin
				
				SRAM_address <= Y_START;
				Y_START <= Y_START + 18'd1;
				SRAM_we_n <= 1'b1;
				
				if(R_CALC_E[31] == 1'b1) begin
					R_VALUE[15:8] <= 8'b0;
				end else if(R_CALC_E[30:24] != 7'b0) begin
					R_VALUE[15:8] <= 8'b11111111;
				end else begin
					R_VALUE[15:8] <= R_CALC_E[23:16];
				end
				
				if(R_CALC_O[31] == 1'b1) begin
					R_VALUE[7:0] <= 8'b0;
				end else if(R_CALC_O[30:24] != 7'b0) begin
					R_VALUE[7:0] <= 8'b11111111;
				end else begin
					R_VALUE[7:0] <= R_CALC_O[23:16];
				end
				
				if(G_CALC_E[31] == 1'b1) begin
					G_VALUE[15:8] <= 8'b0;
				end else if(G_CALC_E[30:24] != 7'b0) begin
					G_VALUE[15:8] <= 8'b11111111;
				end else begin
					G_VALUE[15:8] <= G_CALC_E[23:16];
				end
				
				if(G_CALC_O[31] == 1'b1) begin
					G_VALUE[7:0] <= 8'b0;
				end else if(G_CALC_O[30:24] != 7'b0) begin
					G_VALUE[7:0] <= 8'b11111111;
				end else begin
					G_VALUE[7:0] <= G_CALC_O[23:16];
				end
				
				if(B_CALC_E[31] == 1'b1) begin
					B_VALUE[15:8] <= 8'b0;
				end else if(B_CALC_E[30:24] != 7'b0) begin
					B_VALUE[15:8] <= 8'b11111111;
				end else begin
					B_VALUE[15:8] <= B_CALC_E[23:16];
				end
				
				if(B_CALC_O[31] == 1'b1) begin
					B_VALUE[7:0] <= 8'b0;
				end else if(B_CALC_O[30:24] != 7'b0) begin
					B_VALUE[7:0] <= 8'b11111111;
				end else begin
					B_VALUE[7:0] <= B_CALC_O[23:16];
				end
				
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd21;
				op12 <= U_REG[5];
				op21 <= 32'd21;
				op22 <= V_REG[5];
				op31 <= 32'd76284;
				op32 <= Y_STORE[15:8]-8'd16;
				op41 <= 32'd104595;
				op42 <= V_REG[4]-8'd128;
				
				
				SRAM_state <= S_LO_14;
			
			
			end
			
			
			S_LO_14: begin
				
				SRAM_we_n <= 1'b1;				
				
				R_CALC_E <= m3 + m4;
				
				U_PRIME_CALC <= m1;
				U_PRIME <= (U_PRIME_CALC+128)>>>8;
				
				V_PRIME_CALC <= m2;
				V_PRIME <= (V_PRIME_CALC+128)>>>8;
				
				op11 <= 32'd52;
				op12 <= U_REG[4];
				op21 <= 32'd52;
				op22 <= V_REG[4];
				
				
				op31 <= 32'd25624;
				op32 <= U_REG[4]-8'd128;
				op41 <= 32'd53281;
				op42 <= V_REG[4]-8'd128;
				
				//m1 <= 52*U_REG[4];
				//m2 <= 52*V_REG[4];
				//m3 <= 25624*U_REG[4];
				//m4 <= 53281*V_REG[4];
				
				Y_MULTIPLY <= m3;
			
			
				SRAM_state <= S_LO_15;
			
			end
			
			
			S_LO_15: begin
				
				SRAM_we_n <= 1'b1;
				
				G_CALC_E <= Y_MULTIPLY - m3 - m4;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[3];
				op21 <= 32'd159;
				op22 <= V_REG[3];
				
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[7:0]-8'd16;
				op41 <= 32'd132251;
				op42 <= U_REG[4]-8'd128;//********************************************************************************************
				
				//m1 <= 159*U_REG[3];
				//m2 <= 159*V_REG[3];
				//m3 <= 76284*Y_STORE[7:0];
				//m4 <= 132251*U_REG[3];
				
				
				SRAM_state <= S_LO_16;
			
			end
			
			
			S_LO_16: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= R_VALUE[15:8]; 
				SRAM_write_data[7:0] <= G_VALUE[15:8];
				SRAM_we_n <= 1'b0;
				
				B_CALC_E <= Y_MULTIPLY + m4;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				op11 <= 32'd159;
				op12 <= U_REG[2];
				op21 <= 32'd159;
				op22 <= V_REG[2];
				
				
				op31 <= 32'd132251;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd104595;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 159*U_REG[2];
				//m2 <= 159*V_REG[2];
				//m3 <= 132251*U_PRIME;
				//m4 <= 104595*V_PRIME;
				
				Y_STORE <= SRAM_read_data;

				Y_MULTIPLY <= m3;
				
			
				SRAM_state <= S_LO_17;
			
			
			end
			
			
			S_LO_17: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= B_VALUE[15:8]; 
				SRAM_write_data[7:0] <= R_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				R_CALC_O <= Y_MULTIPLY + m4;
				B_CALC_O <= Y_MULTIPLY + m3;
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;				
				
				op11 <= 32'd52;
				op12 <= U_REG[1];
				op21 <= 32'd52;
				op22 <= V_REG[1];
				
				
				op31 <= 32'd25624;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd53281;
				op42 <= V_PRIME-8'd128;
				
				//m1 <= 52*U_REG[1];
				//m2 <= 52*V_REG[1];
				//m3 <= 25624*U_PRIME;
				//m4 <= 53281*V_PRIME;
				
				
				U_REG[5] <= U_REG[4];
				U_REG[4] <= U_REG[3];				
			
				SRAM_state <= S_LO_18;
			
			
			end
			
			S_LO_18: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				
				G_CALC_O <= Y_MULTIPLY - m3-m4;
				
				
				SRAM_write_data[15:8] <= G_VALUE[7:0]; 
				SRAM_write_data[7:0] <= B_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				U_PRIME_CALC <= U_PRIME_CALC - m1;
				V_PRIME_CALC <= V_PRIME_CALC - m2;	
				
				op11 <= 32'd21;
				op12 <= U_REG[1];//changed from 1 to 0
				op21 <= 32'd21;
				op22 <= V_REG[0];
				
				//m1 <= 21*U_REG[1];
				//m2 <= 21*V_REG[0];
				

				V_REG[5] <= V_REG[4];
				V_REG[4] <= V_REG[3];				
					
				SRAM_state <= S_LO_19;
			
			
			end
			
			//LEAD OUT CASE 4
			
			S_LO_19: begin
				
				SRAM_we_n <= 1'b1;
				
				if(R_CALC_E[31] == 1'b1) begin
					R_VALUE[15:8] <= 8'b0;
				end else if(R_CALC_E[30:24] != 7'b0) begin
					R_VALUE[15:8] <= 8'b11111111;
				end else begin
					R_VALUE[15:8] <= R_CALC_E[23:16];
				end
				
				if(R_CALC_O[31] == 1'b1) begin
					R_VALUE[7:0] <= 8'b0;
				end else if(R_CALC_O[30:24] != 7'b0) begin
					R_VALUE[7:0] <= 8'b11111111;
				end else begin
					R_VALUE[7:0] <= R_CALC_O[23:16];
				end
				
				if(G_CALC_E[31] == 1'b1) begin
					G_VALUE[15:8] <= 8'b0;
				end else if(G_CALC_E[30:24] != 7'b0) begin
					G_VALUE[15:8] <= 8'b11111111;
				end else begin
					G_VALUE[15:8] <= G_CALC_E[23:16];
				end
				
				if(G_CALC_O[31] == 1'b1) begin
					G_VALUE[7:0] <= 8'b0;
				end else if(G_CALC_O[30:24] != 7'b0) begin
					G_VALUE[7:0] <= 8'b11111111;
				end else begin
					G_VALUE[7:0] <= G_CALC_O[23:16];
				end
				
				if(B_CALC_E[31] == 1'b1) begin
					B_VALUE[15:8] <= 8'b0;
				end else if(B_CALC_E[30:24] != 7'b0) begin
					B_VALUE[15:8] <= 8'b11111111;
				end else begin
					B_VALUE[15:8] <= B_CALC_E[23:16];
				end
				
				if(B_CALC_O[31] == 1'b1) begin
					B_VALUE[7:0] <= 8'b0;
				end else if(B_CALC_O[30:24] != 7'b0) begin
					B_VALUE[7:0] <= 8'b11111111;
				end else begin
					B_VALUE[7:0] <= B_CALC_O[23:16];
				end
				
				
				U_PRIME_CALC <= U_PRIME_CALC + m1;
				V_PRIME_CALC <= V_PRIME_CALC + m2;
				
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[15:8]-8'd16;
				op41 <= 32'd104595;
				op42 <= V_REG[4]-8'd128;
				
				
			
				SRAM_state <= S_LO_20;
			
			
			end
			
			S_LO_20: begin
				
				SRAM_we_n <= 1'b1;				
				
				R_CALC_E <= m3 + m4;
				
				U_PRIME <= (U_PRIME_CALC+128)>>>8;
				V_PRIME <= (V_PRIME_CALC+128)>>>8;
				
				op31 <= 32'd25624;
				op32 <= U_REG[4]-8'd128;
				op41 <= 32'd53281;
				op42 <= V_REG[4]-8'd128;
				
				Y_MULTIPLY <= m3;
				
			
				SRAM_state <= S_LO_21;
			
			
			end
			
			S_LO_21: begin
				
				SRAM_we_n <= 1'b1;
				
				G_CALC_E <= Y_MULTIPLY - m3 - m4;				
				
				op31 <= 32'd76284;
				op32 <= Y_STORE[7:0]-8'd16;
				op41 <= 32'd132251;
				op42 <= U_REG[4]-8'd128;//*************************************************************************************change to 4 maybe
			
				SRAM_state <= S_LO_22;
			
			
			end
			
			S_LO_22: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= R_VALUE[15:8]; 
				SRAM_write_data[7:0] <= G_VALUE[15:8];
				SRAM_we_n <= 1'b0;
				
				B_CALC_E <= Y_MULTIPLY + m4;
				
				op31 <= 32'd132251;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd104595;
				op42 <= V_PRIME-8'd128;

				Y_MULTIPLY <= m3;
				
			
				SRAM_state <= S_LO_23;
			
			
			end
			
			S_LO_23: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= B_VALUE[15:8]; 
				SRAM_write_data[7:0] <= R_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				R_CALC_O <= Y_MULTIPLY + m4;
				B_CALC_O <= Y_MULTIPLY + m3;
				
				op31 <= 32'd25624;
				op32 <= U_PRIME-8'd128;
				op41 <= 32'd53281;
				op42 <= V_PRIME-8'd128;
				
				
				U_REG[5] <= U_REG[4];
			
				SRAM_state <= S_LO_24;
			
			
			end
			
			S_LO_24: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= G_VALUE[7:0]; 
				SRAM_write_data[7:0] <= B_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				G_CALC_O <= Y_MULTIPLY - m3-m4;
				
				V_REG[5] <= V_REG[4];
			
				SRAM_state <= S_LO_25;
	
			end
			
			
			//LEAD OUT CASE 5
			
			S_LO_25: begin
				
				SRAM_we_n <= 1'b1;
				
				if(R_CALC_E[31] == 1'b1) begin
					R_VALUE[15:8] <= 8'b0;
				end else if(R_CALC_E[30:24] != 7'b0) begin
					R_VALUE[15:8] <= 8'b11111111;
				end else begin
					R_VALUE[15:8] <= R_CALC_E[23:16];
				end
				
				if(R_CALC_O[31] == 1'b1) begin
					R_VALUE[7:0] <= 8'b0;
				end else if(R_CALC_O[30:24] != 7'b0) begin
					R_VALUE[7:0] <= 8'b11111111;
				end else begin
					R_VALUE[7:0] <= R_CALC_O[23:16];
				end
				
				if(G_CALC_E[31] == 1'b1) begin
					G_VALUE[15:8] <= 8'b0;
				end else if(G_CALC_E[30:24] != 7'b0) begin
					G_VALUE[15:8] <= 8'b11111111;
				end else begin
					G_VALUE[15:8] <= G_CALC_E[23:16];
				end
				
				if(G_CALC_O[31] == 1'b1) begin
					G_VALUE[7:0] <= 8'b0;
				end else if(G_CALC_O[30:24] != 7'b0) begin
					G_VALUE[7:0] <= 8'b11111111;
				end else begin
					G_VALUE[7:0] <= G_CALC_O[23:16];
				end
				
				if(B_CALC_E[31] == 1'b1) begin
					B_VALUE[15:8] <= 8'b0;
				end else if(B_CALC_E[30:24] != 7'b0) begin
					B_VALUE[15:8] <= 8'b11111111;
				end else begin
					B_VALUE[15:8] <= B_CALC_E[23:16];
				end
				
				if(B_CALC_O[31] == 1'b1) begin
					B_VALUE[7:0] <= 8'b0;
				end else if(B_CALC_O[30:24] != 7'b0) begin
					B_VALUE[7:0] <= 8'b11111111;
				end else begin
					B_VALUE[7:0] <= B_CALC_O[23:16];
				end
			
				SRAM_state <= S_LO_26;
			
			
			end
			
			S_LO_26: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= R_VALUE[15:8]; 
				SRAM_write_data[7:0] <= G_VALUE[15:8];
				SRAM_we_n <= 1'b0;
			
				SRAM_state <= S_LO_27;
			
			
			end
			
			S_LO_27: begin
				
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= B_VALUE[15:8]; 
				SRAM_write_data[7:0] <= R_VALUE[7:0];
				SRAM_we_n <= 1'b0;
				
				U_REG[5] <= 8'b0;
				U_REG[4] <= 8'b0;
				U_REG[3] <= 8'b0;
				U_REG[2] <= 8'b0;
				U_REG[1] <= 8'b0;
				U_REG[0] <= 8'b0;
				
				
				SRAM_state <= S_LO_28;
			
			
			end
			
			
			S_LO_28: begin
				SRAM_address <= COLOUR_START;
				COLOUR_START <= COLOUR_START + 18'd1;
				SRAM_write_data[15:8] <= G_VALUE[7:0]; 
				SRAM_write_data[7:0] <= B_VALUE[7:0];
				SRAM_we_n <= 1'b0;		
				
				V_START <= V_START - 1'b1;
				U_START <= U_START - 1'b1;

				V_REG[5] <= 8'b0;
				V_REG[4] <= 8'b0;
				V_REG[3] <= 8'b0;
				V_REG[2] <= 8'b0;
				V_REG[1] <= 8'b0;
				V_REG[0] <= 8'b0;
				
				
				if(COLOUR_START >= 18'd262143)
					M1Finished <= 1'b1;
				else 
					M1Finished <= 1'b0;
					
					SRAM_state <= S_LI_1;
				
			end
			
			
			default: SRAM_state <= S_M1_IDLE;
		endcase
	end
end
endmodule