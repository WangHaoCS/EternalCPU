`timescale 1ns / 1ps

`include "defines.vh"
module memsel(
	input wire[31:0] pc,
	input wire[5:0] op,
	input wire[31:0] addr,//equal aluoutM
	input wire[31:0] writedata, // rt value
	input wire[31:0] readdata, 
	// output wire memwrite,
	output wire[3:0] sel, 
	output wire[31:0] writedata2,
	output wire[31:0] finaldata,
	output wire[31:0] bad_addr,
	output wire adelM, // 读数据地址异常
	output wire adesM, // 写数据地址异常
	output wire[1:0] size
    );
	
	wire lw, lh, lhu, lb, lbu, sw, sh, sb, lwl, lwr, swl, swr, ll, sc;
	wire addr_B0, addr_B2, addr_B1, addr_B3;

	assign lw  = ~(|(op ^ `LW ));
	assign lh  = ~(|(op ^ `LH ));
	assign lhu = ~(|(op ^ `LHU));
	assign lb  = ~(|(op ^ `LB ));
	assign lbu = ~(|(op ^ `LBU));
	assign sw  = ~(|(op ^ `SW ));
	assign sh  = ~(|(op ^ `SH ));
	assign sb  = ~(|(op ^ `SB ));
	assign lwl = ~(|(op ^ `LWL));
	assign lwr = ~(|(op ^ `LWR));
	assign swl = ~(|(op ^ `SWL));
	assign swr = ~(|(op ^ `SWR));
	assign ll  = ~(|(op ^ `LL ));
	assign sc  = ~(|(op ^ `SC ));

	assign addr_B0 = ~(|(addr[1:0] ^ 2'b00));  // 00
    assign addr_B2 = ~(|(addr[1:0] ^ 2'b10));  // 10
    assign addr_B1 = ~(|(addr[1:0] ^ 2'b01));  // 01
    assign addr_B3 = ~(|(addr[1:0] ^ 2'b11));  // 11
	
	// bad addr
	assign adesM = ((sw | sc) & ~addr_B0) | (sh & ~(addr_B0 | addr_B2));
	assign adelM = ((lw | ll) & ~addr_B0) | ((lh | lhu) & ~(addr_B0 | addr_B2));
	assign bad_addr = (adesM | adelM) ? addr : pc;

	// memory wen
	assign sel =  ( {4{( (sw | sc) & addr_B0  )}} & 4'b1111)
                | ( {4{( sh & addr_B0  )}} & 4'b0011)
                | ( {4{( sh & addr_B2  )}} & 4'b1100)
				| ( {4{( sb & addr_B0  )}} & 4'b0001)
				| ( {4{( sb & addr_B1  )}} & 4'b0010)
				| ( {4{( sb & addr_B2  )}} & 4'b0100)
				| ( {4{( sb & addr_B3  )}} & 4'b1000)
				| ( {4{(swl & addr_B0  )}} & 4'b0001)
				| ( {4{(swl & addr_B1  )}} & 4'b0011)
				| ( {4{(swl & addr_B2  )}} & 4'b0111)
				| ( {4{(swl & addr_B3  )}} & 4'b1111)
				| ( {4{(swr & addr_B0  )}} & 4'b1111)
				| ( {4{(swr & addr_B1  )}} & 4'b1110)
				| ( {4{(swr & addr_B2  )}} & 4'b1100)
				| ( {4{(swr & addr_B3  )}} & 4'b1000);

	assign writedata2 =   ({ 32{(sw | sc) }} & writedata)
                        | ( {32{sh}}  & {2{writedata[15:0]} })
                        | ( {32{sb}}  & {4{writedata[7:0]}  })
                        | ( {32{swl & addr_B0  }} & {24'b0, writedata[31:24]})
                        | ( {32{swl & addr_B1  }} & {16'b0, writedata[31:16]})
                        | ( {32{swl & addr_B2  }} & { 8'b0, writedata[31:8 ]})
                        | ( {32{swl & addr_B3  }} & writedata)
                        | ( {32{swr & addr_B0  }} & writedata)
                        | ( {32{swr & addr_B1  }} & {writedata[23:0],  8'b0})
                        | ( {32{swr & addr_B2  }} & {writedata[15:0], 16'b0})
                        | ( {32{swr & addr_B3  }} & {writedata[7 :0], 24'b0});

	assign finaldata =    ( {32{(lw | ll)}}  & readdata)
						| ( {32{lwl   & addr_B0}}  & {readdata[7:0 ], writedata[23:0]} )
						| ( {32{lwl   & addr_B1}}  & {readdata[15:0], writedata[15:0]} )
						| ( {32{lwl   & addr_B2}}  & {readdata[23:0], writedata[7:0 ]} )
						| ( {32{lwl   & addr_B3}}  &  readdata )
						| ( {32{lwr   & addr_B0}}  &  readdata )
						| ( {32{lwr   & addr_B1}}  & {writedata[31:24],    readdata[31:8 ]})
						| ( {32{lwr   & addr_B2}}  & {writedata[31:16],    readdata[31:16]})
						| ( {32{lwr   & addr_B3}}  & {writedata[31:8 ],    readdata[31:24]})
						| ( {32{ lh   & addr_B0}}  & { {16{readdata[15]}}, readdata[15:0] })
						| ( {32{ lh   & addr_B2}}  & { {16{readdata[31]}}, readdata[31:16]})
						| ( {32{ lhu  & addr_B0}}  & {  16'b0,             readdata[15:0] })
						| ( {32{ lhu  & addr_B2}}  & {  16'b0,             readdata[31:16]})
						| ( {32{ lb   & addr_B0}}  & { {24{readdata[ 7]}}, readdata[7:0]  })
						| ( {32{ lb   & addr_B1}}  & { {24{readdata[15]}}, readdata[15:8] })
						| ( {32{ lb   & addr_B2}}  & { {24{readdata[23]}}, readdata[23:16]})
						| ( {32{ lb   & addr_B3}}  & { {24{readdata[31]}}, readdata[31:24]})
						| ( {32{ lbu  & addr_B0}}  & {  24'b0 ,            readdata[7:0]  })
						| ( {32{ lbu  & addr_B1}}  & {  24'b0 ,            readdata[15:8] })
						| ( {32{ lbu  & addr_B2}}  & {  24'b0 ,            readdata[23:16]})
						| ( {32{ lbu  & addr_B3}}  & {  24'b0 ,            readdata[31:24]});

	// !!!here is a bug
	assign size = (lw | sw | ll | sc) ? 2'b10 : 
				  (lh | lhu | sh)     ? 2'b01 : 2'b00 ;

	// always @(*) begin
	// 	bad_addr <= pc;//previous: pc - 8
	// 	adesM <= 1'b0;
	// 	adelM <= 1'b0;
	// 	writedata2 <= writedata;
	// 	case (op)
	// 		`LW:begin
	// 			size <= 2'b10;
	// 			if(addr[1:0] != 2'b00) begin
	// 				adelM <= 1'b1;
	// 				bad_addr <= addr;
	// 				sel <= 4'b0000;
	// 			end else begin
    //                 sel <= 4'b1111;
    //             end
	// 		end
	// 		`LB,`LBU:begin
	// 			size <= 2'b00;
	// 			case (addr[1:0])
	// 				2'b11:sel <= 4'b1000;
	// 				2'b10:sel <= 4'b0100;
	// 				2'b01:sel <= 4'b0010;
	// 				2'b00:sel <= 4'b0001;
	// 				default : /* default */;
	// 			endcase
	// 		end
	// 		`LH,`LHU:begin
	// 			size <= 2'b01;
    //             case (addr[1:0])
	// 				2'b10:sel <= 4'b1100;
	// 				2'b00:sel <= 4'b0011;
	// 				default :begin
    //                     adelM <= 1'b1;
    //                     bad_addr <= addr;
	// 					sel <= 4'b0000;
	// 				end 
	// 			endcase
	// 		end
	// 		`SW:begin 
	// 			size <= 2'b10;
	// 			if(addr[1:0] == 2'b00) begin
	// 				/* code */
	// 				sel <= 4'b1111;
	// 			end else begin 
	// 				adesM <= 1'b1;
	// 				bad_addr <= addr;
	// 				sel <= 4'b0000;
	// 			end
	// 		end
	// 		`SH:begin
	// 			size <= 2'b01;
	// 			writedata2 <= {writedata[15:0],writedata[15:0]};
	// 			case (addr[1:0])
	// 				2'b10:sel <= 4'b1100;
	// 				2'b00:sel <= 4'b0011;
	// 				default :begin 
	// 					adesM <= 1'b1;
	// 					bad_addr <= addr;
	// 					sel <= 4'b0000;
	// 				end 
	// 			endcase
	// 		end
	// 		`SB:begin
	// 			size <= 2'b00;
	// 			writedata2 <= {writedata[7:0],writedata[7:0],writedata[7:0],writedata[7:0]};
	// 			case (addr[1:0])
	// 				2'b11:sel <= 4'b1000;
	// 				2'b10:sel <= 4'b0100;
	// 				2'b01:sel <= 4'b0010;
	// 				2'b00:sel <= 4'b0001;
	// 				default : /* default */;
	// 			endcase
	// 		end
	// 		default :begin
	// 			size <= 2'b00;
	// 			sel <= 4'b0000;			
	// 		end 
	// 	endcase
	// 	// bad_addr <= pc - 8;
	// 	case (op)
	// 		`LW:begin 
	// 			if(addr[1:0] == 2'b00) begin
	// 				/* code */
	// 				finaldata <= readdata;
	// 			end
	// 			// 防止锁存器
	// 			else begin
	// 				finaldata <= `ZeroWord;
	// 			end
	// 		end
	// 		`LB:begin 
	// 			case (addr[1:0])
	// 				2'b11: finaldata <= {{24{readdata[31]}},readdata[31:24]};
	// 				2'b10: finaldata <= {{24{readdata[23]}},readdata[23:16]};
	// 				2'b01: finaldata <= {{24{readdata[15]}},readdata[15:8]};
	// 				2'b00: finaldata <= {{24{readdata[7]}},readdata[7:0]};
	// 				default : /* default */;		        
	// 			endcase
	// 		end
	// 		`LBU:begin 
	// 			case (addr[1:0])
	// 				2'b11: finaldata <= {{24{1'b0}},readdata[31:24]};
	// 				2'b10: finaldata <= {{24{1'b0}},readdata[23:16]};
	// 				2'b01: finaldata <= {{24{1'b0}},readdata[15:8]};
	// 				2'b00: finaldata <= {{24{1'b0}},readdata[7:0]};
	// 				default : /* default */;
	// 			endcase
	// 		end
	// 		`LH:begin 
	// 			case (addr[1:0])
	// 				2'b10: finaldata <= {{16{readdata[31]}},readdata[31:16]};
	// 				2'b00: finaldata <= {{16{readdata[15]}},readdata[15:0]};
	// 				default : finaldata <= `ZeroWord;
	// 			endcase
	// 		end
	// 		`LHU:begin 
	// 			case (addr[1:0])
	// 				2'b10: finaldata <= {{16{1'b0}},readdata[31:16]};
	// 				2'b00: finaldata <= {{16{1'b0}},readdata[15:0]};
	// 				default : finaldata <= `ZeroWord;
	// 			endcase
	// 		end
	// 		default : finaldata <= `ZeroWord;
	// 	endcase
	// end
endmodule
