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
module M2_interface (
   input  logic		Clock,
   input  logic		Resetn, 

   input  logic		Initialize,
   
   input  logic [15:0]  SRAM_read_data,
   output logic [17:0]	SRAM_address,
   output logic [15:0]	SRAM_write_data,
   output logic		SRAM_we_n,
   output logic 	M2Finished
);

M2_state_type SRAM_state;


logic [6:0] address_a [2:0];
logic [6:0] address_b [2:0];

logic [31:0] write_data_b [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];


dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( address_a[0] ),
	.address_b ( address_b[0] ),
	.clock ( clk ),
	.data_a ( 32'h00 ),
	.data_b ( write_data_b[0] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

dual_port_RAM2 dual_port_RAM_inst2 (
	.address_a ( address_a[1] ),
	.address_b ( address_b[1] ),
	.clock ( clk ),
	.data_a ( 32'h00 ),
	.data_b ( write_data_b[1] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);

dual_port_RAM3 dual_port_RAM_inst3 (
	.address_a ( address_a[2] ),
	.address_b ( address_b[2] ),
	.clock ( clk ),
	.data_a ( 32'h00 ),
	.data_b ( write_data_b[2] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	);


logic flag;
logic flag2;

logic [17:0] Y_BLOCK;
logic [17:0] U_BLOCK;
logic [17:0] V_BLOCK;

logic S_PRIME_WC [17:0];//S' write counter


logic [15:0] S_PRIME_BUF;
logic [15:0] S_PRIME_COMPUTE_BUF [7:0];
logic [31:0] T_COMPUTE_BUF [7:0];
logic [31:0] T_CALC;
logic [39:0] S_CALC;

logic [5:0] A1_ADDR_COUNTER;//ram 1 read counters
logic [5:0] B1_ADDR_COUNTER;

logic [5:0] A2_ADDR_COUNTER;//ram 2 read counters
logic [5:0] B2_ADDR_COUNTER;

logic [5:0] A2_ADDR_COUNTER_CT;//ram 2 read counters for calculations using C transpose
logic [5:0] B2_ADDR_COUNTER_CT;

logic [5:0] T_W_ADDR;//T write address for dpram3
logic [6:0] S_W_ADDR;//S write address for dpram3

logic [5:0] T_R_ADDR_A;//T read address for dpram3
logic [5:0] T_R_ADDR_B;//T read address for dpram3

logic [6:0] S_RC;//S Read Counter from dpram3

logic [3:0] ROW_COUNTER;
logic [3:0] ROW_COUNTER2;



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


always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		SRAM_address <= 18'd0;
		
		Y_BLOCK <= 18'd76800;
		U_BLOCK <= 18'd153600;
		V_BLOCK <= 18'd192000;
		
		S_PRIME_WC <= 1'b0;
		
		A1_ADDR_COUNTER <= 1'b0;
		A2_ADDR_COUNTER <= 1'b0;
		B1_ADDR_COUNTER <= 1'b1;
		B2_ADDR_COUNTER <= 1'b1;
		
		A2_ADDR_COUNTER_CT <= 6'd32;
		B2_ADDR_COUNTER_CT <= 6'd33;
		
		T_W_ADDR <= 1'b0;
		S_W_ADDR <= 7'd64;
		T_R_ADDR_A <= 6'd0;
		T_R_ADDR_B <= 6'd1;
		
		S_RC <= 7'd64;
		
		SRAM_state <= S_M2_IDLE;
		
	end else begin

		case (SRAM_state)
		
			S_M2_IDLE: begin
				
				
				
				SRAM_address <= 18'd0;		
				SRAM_we_n <= 1'b1;
				SRAM_write_data <= 16'd0;
				
				Y_BLOCK <= 18'd76800;
				U_BLOCK <= 18'd153600;
				V_BLOCK <= 18'd192000;
				
				S_PRIME_WC <= 1'b0;
				
				A1_ADDR_COUNTER <= 1'b0;
				A2_ADDR_COUNTER <= 1'b0;
				B1_ADDR_COUNTER <= 1'b1;
				B2_ADDR_COUNTER <= 1'b1;
				
				A2_ADDR_COUNTER_CT <= 6'd32;
				B2_ADDR_COUNTER_CT <= 6'd33;
				
				T_W_ADDR <= 1'b0;
				S_W_ADDR <= 7'd64;
				T_R_ADDR_A <= 6'd0;
				T_R_ADDR_B <= 6'd1;
				
				S_RC <= 7'd64;
				
				if(Initialize)
					SRAM_state <= S_LI_1;
				
			end
			
			S_M2_LI_1: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				SRAM_state <= S_LI_2;
				
			end
			
			S_M2_LI_2: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				SRAM_state <= S_LI_3;
				
			end
			
			S_M2_LI_3: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				SRAM_state <= S_LI_4;
				
			end
			
			S_M2_LI_4: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_BUF <= SRAM_read_data;
				
				
				
				
				SRAM_state <= S_LI_5;
				
			end
			
			S_M2_LI_5: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				
				
				SRAM_state <= S_LI_6;
				
			end
			
			S_M2_LI_6: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_BUF <= SRAM_read_data;
				
				SRAM_state <= S_LI_7;
				
			end
			
			S_M2_LI_7: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				SRAM_state <= S_LI_8;
				
			end
			
			S_M2_LI_8: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_BUF <= SRAM_read_data;
				
				SRAM_state <= S_LI_9;
				
			end
			
			S_M2_LI_9: begin
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data;
				write_enable_b[0] <= 1'b1;
				
				
				SRAM_state <= S_LI_10;
				
			end
			
			S_M2_LI_10: begin
				
				S_PRIME_BUF <= SRAM_read_data;
				
				
				SRAM_state <= S_LI_11;
				
			end
			
			S_M2_LI_11: begin
				
				
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				
				SRAM_state <= S_LI_12;
				
			end
			
			S_M2_LI_12: begin
				
				write_enable_b[0] <= 1'b0;
				address_a[0] <= A1_ADDR_COUNTER;
				A1_ADDR_COUNTER <= A1_ADDR_COUNTER + 6'd2;
				address_b[0] <= B1_ADDR_COUNTER;
				B1_ADDR_COUNTER <= B1_ADDR_COUNTER + 6'd2;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				SRAM_state <= S_LI_13;
				
			end
			
			S_M2_LI_13: begin
				
				write_enable_b[0] <= 1'b0;
				address_a[0] <= A1_ADDR_COUNTER;
				A1_ADDR_COUNTER <= A1_ADDR_COUNTER + 6'd2;
				address_b[0] <= B1_ADDR_COUNTER;
				B1_ADDR_COUNTER <= B1_ADDR_COUNTER + 6'd2;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				flag <= 1'b0;
				
				SRAM_state <= S_MA_1;
				
			end
			
			S_MA_1: begin
				
				ROW_COUNTER <= ROW_COUNTER + 1'b1;
				ROW_COUNTER2 <= 1'b0;
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				if(flag)
					T_CALC <= T_CALC + m1 + m2 + m3 + m4;
					
				S_PRIME_COMPUTE_BUF [7] <= read_data_a[0] [31:16];
				S_PRIME_COMPUTE_BUF [6] <= read_data_a[0] [15:0];
				S_PRIME_COMPUTE_BUF [5] <= read_data_b[0] [31:16];
				S_PRIME_COMPUTE_BUF [4] <= read_data_b[0] {15:0];
					
				op11 <= read_data_a[0] [31:16];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= read_data_a[0] [15:0];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_b[0] [31:16];
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[0] {15:0];
				op42 <= read_data_b[1] {15:0];
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				T_W_ADDR <= 1'b0;
				
				SRAM_state <= S_MA_2;
				
			end
			
			S_MA_2: begin
				
				flag <= 1'b1;
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_COMPUTE_BUF [3] <= read_data_a[0] [31:16];
				S_PRIME_COMPUTE_BUF [2] <= read_data_a[0] [15:0];
				S_PRIME_COMPUTE_BUF [1] <= read_data_b[0] [31:16];
				S_PRIME_COMPUTE_BUF [0] <= read_data_b[0] {15:0];
				
				op11 <= read_data_a[0] [31:16];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= read_data_a[0] [15:0];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_b[0] [31:16];
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[0] {15:0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
			
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				SRAM_state <= S_MA_3;
				
			end
			
			S_MA_3: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				SRAM_state <= S_MA_4;
				
			end
			
			S_MA_4: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_BUF <= SRAM_read_data;
				
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				SRAM_state <= S_MA_5;
				
			end
			
			S_MA_5: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				
				SRAM_state <= S_MA_6;
				
			end
			
			S_MA_6: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_BUF <= SRAM_read_data;
				
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				S_RC <= 7'd64;
				
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				SRAM_state <= S_MA_7;
				
			end
			
			S_MA_7: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				SRAM_state <= S_MA_8;
				
			end
			
			S_MA_8: begin
				
				SRAM_address <= Y_BLOCK;
				Y_BLOCK <= Y_BLOCK + 1'b1;
				SRAM_we_n <= 1'b1;
				
				S_PRIME_BUF <= SRAM_read_data;
				
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
								
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				SRAM_state <= S_MA_9;
				
			end
			
			S_MA_9: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				SRAM_state <= S_MA_10;
				
			end
			
			S_MA_10: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
				
				
				S_PRIME_BUF <= SRAM_read_data;
				
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
								
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				SRAM_state <= S_MA_11;
				
			end
			
			S_MA_11: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				address_b[0] <= S_PRIME_WC;
				S_PRIME_WC <= S_PRIME_WC + 1'b1;
				write_data_b[0] [31:16] <= S_PRIME_BUF;
				write_data_b[0] [15:0] <= SRAM_read_data
				write_enable_b[0] <= 1'b1;
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				SRAM_state <= S_MA_12;
				
			end
			
			S_MA_12: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
								
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
								
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				SRAM_state <= S_MA_13;
				
			end
			
			S_MA_13: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
				
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;
				
				
				SRAM_state <= S_MA_14;
				
			end
			
			S_MA_14: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
								
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
								
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
				address_a[2] <= S_RC;
				S_RC <= S_RC + 1'b1;				
				
				SRAM_state <= S_MA_15;
				
			end
			
			S_MA_15: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
				
				op11 <= S_PRIME_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= T_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[0] <= 1'b0;
				address_a[0] <= A1_ADDR_COUNTER;
				A1_ADDR_COUNTER <= A1_ADDR_COUNTER + 6'd2;
				address_b[0] <= B1_ADDR_COUNTER;
				B1_ADDR_COUNTER <= B1_ADDR_COUNTER + 6'd2;
				
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER;
				A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER;
				B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;			
				
				
				SRAM_state <= S_MA_16;
				
			end
			
			S_MA_16: begin
				
				SRAM_address <= S_WA;
				S_WA <= S_WA + 1'b1;
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= read_data_a[2];
								
				op11 <= S_PRIME_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= S_PRIME_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= S_PRIME_COMPUTE_BUF[1];
				op32 <= read_data_b[1] [31:16];
				op41 <= S_PRIME_COMPUTE_BUF[0];
				op42 <= read_data_b[1] {15:0];
				
				T_CALC <= m1 + m2 + m3 + m4;
				
				if(ROW_COUNTER >= 5'd8) begin
					
					T_R_ADDR_A <= 6'd0;
					T_R_ADDR_B <= 6'd1;
					SRAM_state <= S_MB_LI_1;
					
				end else begin
				
					write_enable_b[0] <= 1'b0;
					address_a[0] <= A1_ADDR_COUNTER;
					A1_ADDR_COUNTER <= A1_ADDR_COUNTER + 6'd2;
					address_b[0] <= B1_ADDR_COUNTER;
					B1_ADDR_COUNTER <= B1_ADDR_COUNTER + 6'd2;
					
					write_enable_b[1] <= 1'b0;
					address_a[1] <= A2_ADDR_COUNTER;
					A2_ADDR_COUNTER <= A2_ADDR_COUNTER + 6'd2;
					address_b[1] <= B2_ADDR_COUNTER;
					B2_ADDR_COUNTER <= B2_ADDR_COUNTER + 6'd2;
					
					SRAM_state <= S_MA_1;
				end
								
				address_b[2] <= T_W_ADDR;
				T_W_ADDR <= T_W_ADDR + 1'b1;
				write_data_b[2] <= (T_CALC)>>>8
				
			end
			
			S_MB_LI_1: begin
				
				write_enable_b[2] <= 1'b0;
				address_a[2] <= T_R_ADDR_A;
				address_b[2] <= T_R_ADDR_B;
				T_R_ADDR_A <= T_R_ADDR_A + 6'd2;
				T_R_ADDR_B <= T_R_ADDR_B + 6'd2;
				
				SRAM_state <= S_MB_LI_2;
				
			end
			
			S_MB_LI_2: begin
				
				write_enable_b[2] <= 1'b0;
				address_a[2] <= T_R_ADDR_A;
				address_b[2] <= T_R_ADDR_B;
				T_R_ADDR_A <= T_R_ADDR_A + 6'd2;
				T_R_ADDR_B <= T_R_ADDR_B + 6'd2;
				
				SRAM_state <= S_MB_LI_3;
				
			end
			
			S_MB_LI_3: begin
				
				write_enable_b[2] <= 1'b0;
				address_a[2] <= T_R_ADDR_A;
				address_b[2] <= T_R_ADDR_B;
				T_R_ADDR_A <= T_R_ADDR_A + 6'd2;
				T_R_ADDR_B <= T_R_ADDR_B + 6'd2;
				
				T_COMPUTE_BUF[7] <= read_data_a[2];
				T_COMPUTE_BUF[6] <= read_data_b[2];
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_LI_4;
				
			end
			
			S_MB_LI_4: begin
				
				write_enable_b[2] <= 1'b0;
				address_a[2] <= T_R_ADDR_A;
				address_b[2] <= T_R_ADDR_B;
				T_R_ADDR_A <= T_R_ADDR_A + 6'd2;
				T_R_ADDR_B <= T_R_ADDR_B + 6'd2;
				
				T_COMPUTE_BUF[5] <= read_data_a[2];
				T_COMPUTE_BUF[4] <= read_data_b[2];
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_1;
				
			end
			
			S_MB_1: begin
				
				
				ROW_COUNTER2 <= ROW_COUNTER2 + 1'b1;
				ROW_COUNTER <= 1'b0;
				
				if(flag2)
					S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[7];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[6];
				op22 <= read_data_a[1] [15:0];
				op31 <= T_COMPUTE_BUF[5];
				op32 <= read_data_b[1] [31:16];
				op41 <= T_COMPUTE_BUF[4];
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[3] <= read_data_a[2]
				T_COMPUTE_BUF[2] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				
				SRAM_state <= S_MB_2;
				
			end
			
			S_MB_2: begin
				
				flag2 <= 1'b1;
				
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_3;
				
			end
			
			S_MB_3: begin
				
				
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_4;
				
			end
			
			S_MB_4: begin
				
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_5;
				
			end
			
			S_MB_5: begin
				
				
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_6;
				
			end
			
			S_MB_6: begin
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_7;
				
			end
			
			S_MB_7: begin
				
				
				
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_8;
				
			end
			
			S_MB_8: begin
				
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_9;
				
			end
			
			S_MB_9: begin
				
				
				
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_10;
				
			end
			
			S_MB_10: begin
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_11;
				
			end
			
			S_MB_11: begin
				
				
				
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_12;
				
			end
			
			S_MB_12: begin
				
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_13;
				
			end
			
			S_MB_13: begin
				
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_14;
				
			end
			
			S_MB_14: begin
				
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				SRAM_state <= S_MB_15;
				
			end
			
			S_MB_15: begin
				
				S_CALC <= S_CALC + m1 + m2 + m3 + m4;
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				SRAM_state <= S_MB_16;
				
			end
			
			S_MB_16: begin
				
				S_CALC <= m1 + m2 + m3 + m4;
				
				op11 <= T_COMPUTE_BUF[3];//S'
				op12 <= read_data_a[1] [31:16];//C
				op21 <= T_COMPUTE_BUF[2];
				op22 <= read_data_a[1] [15:0];
				op31 <= read_data_a[2]
				op32 <= read_data_b[1] [31:16];
				op41 <= read_data_b[2]
				op42 <= read_data_b[1] {15:0];
				
				T_COMPUTE_BUF[1] <= read_data_a[2]
				T_COMPUTE_BUF[0] <= read_data_b[2]
				
				write_enable_b[1] <= 1'b0;
				address_a[1] <= A2_ADDR_COUNTER_CT;
				A2_ADDR_COUNTER_CT <= A2_ADDR_COUNTER_CT + 6'd2;
				address_b[1] <= B2_ADDR_COUNTER_CT;
				B2_ADDR_COUNTER_CT <= B2_ADDR_COUNTER_CT + 6'd2;
				
				address_b[2] <= S_W_ADDR;
				S_W_ADDR <= S_W_ADDR + 1'b1;
				write_data_b[2] <= (S_CALC)>>>16
				
				if(SRAM_address == 18'd146943) begin
					M2Finished <= 1'b1;
				end else if(ROW_COUNTER2 >= 8) begin
					SRAM_state <= S_MA_1
				end else begin
					SRAM_state <= S_MB_1;
				end
				
			end
			
			
			
			
			
			
			default: SRAM_state <= S_M2_IDLE;
		endcase
	end
end

endmodule
