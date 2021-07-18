`timescale 1ns / 1ps

`include "defines.h"

module hazard(
	//fetch stage
	output wire         if_stall,
	output wire         if_flush,

	//decode stage
	output              id_flush,
	input  wire[4:0]    id_rs,
	input  wire[4:0]    id_rt,
	output wire         id_stall,

	//execute stage
	input wire[4:0]     ex_alucontrol,
	input wire[4:0]     ex_rt,
	input wire          mem_rmem,
	output wire         ex_flush,
	output wire         ex_stall,
	output wire         div_start,
	input  wire         div_ready,
	//mem stage
	output wire         mem_stall,
	output wire         mem_flush,
	input  wire[31:0]   mem_excepttype,
	input  wire[31:0]   mem_cp0_epc,
	output reg [31:0]   mem_newpc,

	//write back stage
	output wire         wb_flush,
	input  wire         stallreq_from_if,
	input  wire         stallreq_from_mem
    );

	wire id_lwstall;
	wire except_flush;

	assign div_start = 	(ex_alucontrol == `DIV_CONTROL  && div_ready == 1'b0 ) ? 1'b1 : 
				(ex_alucontrol == `DIV_CONTROL  && div_ready == 1'b1 ) ? 1'b0 : 
				(ex_alucontrol == `DIVU_CONTROL && div_ready == 1'b0 ) ? 1'b1 : 
				(ex_alucontrol == `DIVU_CONTROL && div_ready == 1'b1 ) ? 1'b0 : 1'b0;

	assign id_lwstall = mem_rmem & (ex_rt == id_rs | ex_rt == id_rt);

	assign if_stall     = id_lwstall | div_start | stallreq_from_if | stallreq_from_mem;
	assign id_stall     = id_lwstall | div_start | stallreq_from_if | stallreq_from_mem;
	assign ex_stall     =              div_start |                    stallreq_from_mem;		       
	assign mem_stall    =              div_start |                    stallreq_from_mem;

	assign except_flush = mem_excepttype != 32'b0;

	assign if_flush     =              except_flush;	
	assign id_flush     =              except_flush;
	assign ex_flush     = id_lwstall | except_flush;
	assign mem_flush    =              except_flush;
	assign wb_flush     =              except_flush | stallreq_from_mem;

  	always @(*) begin
		if(mem_excepttype != 32'b0) begin
			/* code */
			case (mem_excepttype)
				32'h00000001:begin 
					mem_newpc <= 32'hBFC00380;
				end
				32'h00000004:begin 
					mem_newpc <= 32'hBFC00380;

				end
				32'h00000005:begin 
					mem_newpc <= 32'hBFC00380;

				end
				32'h00000008:begin 
					mem_newpc <= 32'hBFC00380;
					// new_pc <= 32'h00000040;
				end
				32'h00000009:begin 
					mem_newpc <= 32'hBFC00380;

				end
				32'h0000000a:begin 
					mem_newpc <= 32'hBFC00380;

				end
				32'h0000000c:begin 
					mem_newpc <= 32'hBFC00380;

				end
				32'h0000000d:begin 
					mem_newpc <= 32'hBFC00380;

				end
				32'h0000000e:begin 
					mem_newpc <= mem_cp0_epc;
				end
				default : /* default */;
			endcase
		end
	end
endmodule