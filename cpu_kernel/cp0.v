`timescale 1ns / 1ps

// 此处CP0暂时用学长的替代，目前此模块还不完善 

`include "defines.vh"
module cp0(
	input wire clk,
	input wire rst,

	input wire we_i,
	input[4:0] waddr_i,
	input[4:0] raddr_i,
	input[`RegBus] data_i,

	input wire[5:0] int_i,

	input wire[`RegBus] excepttype_i,
	input wire[`RegBus] current_inst_addr_i,
	input wire is_in_delayslot_i,
	input wire[`RegBus] bad_addr_i,

	output reg[`RegBus] data_o,
	output reg[`RegBus] count_o,
	output reg[`RegBus] compare_o,
	(* mark_debug = "true" *) output reg[`RegBus] status_o,
	(* mark_debug = "true" *) output reg[`RegBus] cause_o,
	(* mark_debug = "true" *) output reg[`RegBus] epc_o,
	output reg[`RegBus] config_o,
	output reg[`RegBus] prid_o,
	output reg[`RegBus] badvaddr,
	output reg timer_int_o
    );

	reg one_bit_counter;

	always @(posedge clk) begin
		if(rst == `RstEnable) begin
			one_bit_counter <= 1'b0;
			count_o <= `ZeroWord;
			compare_o <= `ZeroWord;
			status_o <= 32'b00010000000000000000000000000000;
			cause_o <= `ZeroWord;
			epc_o <= `ZeroWord;
			config_o <= 32'b00000000000000001000000000000000;
			prid_o <= 32'b00000000010011000000000100000010;
			timer_int_o <= `InterruptNotAssert;
		end else begin
			count_o <= count_o + one_bit_counter;
			one_bit_counter <= ~one_bit_counter;
			cause_o[15:10] <= {timer_int_o,int_i[4:0]};
			if(compare_o != `ZeroWord && count_o == compare_o) begin
				/* code */
				timer_int_o <= `InterruptAssert;
			end
			if(we_i == `WriteEnable) begin
				/* code */
				case (waddr_i)
					`CP0_REG_COUNT:begin
						count_o <= data_i;
					end
					`CP0_REG_COMPARE:begin
						compare_o <= data_i;
						timer_int_o <= `InterruptNotAssert;
					end
					`CP0_REG_STATUS:begin
						status_o <= data_i;
					end
					`CP0_REG_CAUSE:begin
						cause_o[9:8] <= data_i[9:8];
						cause_o[23] <= data_i[23];
						cause_o[22] <= data_i[22];
					end
					`CP0_REG_EPC:begin
						epc_o <= data_i;
					end
					default : /* default */;
				endcase
			end
			case (excepttype_i)
				32'h00000001:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00000;
				end
				32'h00000004:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00100;
					badvaddr <= bad_addr_i;
				end
				32'h00000005:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00101;
					badvaddr <= bad_addr_i;
				end
				32'h00000008:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01000;
				end
				32'h00000009:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01001;
				end
				32'h0000000a:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01010;
				end
				32'h0000000c:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01100;
				end
				32'h0000000d:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01101;
				end
				32'h0000000e:begin
					status_o[1] <= 1'b0;
				end
				default : /* default */;
			endcase
		end
	end

	always @(*) begin
		if(rst == `RstEnable) begin
			/* code */
			data_o <= `ZeroWord;
		end else begin
			case (raddr_i)
				`CP0_REG_COUNT:begin
					data_o <= count_o;
				end
				`CP0_REG_COMPARE:begin
					data_o <= compare_o;
				end
				`CP0_REG_STATUS:begin
					data_o <= status_o;
				end
				`CP0_REG_CAUSE:begin
					data_o <= cause_o;
				end
				`CP0_REG_EPC:begin
					data_o <= epc_o;
				end
				`CP0_REG_PRID:begin
					data_o <= prid_o;
				end
				`CP0_REG_CONFIG:begin
					data_o <= config_o;
				end
				`CP0_REG_BADVADDR:begin
					data_o <= badvaddr;
				end
				default : begin
					data_o <= `ZeroWord;
				end
			endcase
		end

	end
endmodule
