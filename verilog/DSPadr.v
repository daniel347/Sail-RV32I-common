module ALUadrDSP(input1,input2,ctl,out);
        input [31:0]    input1;
        input [31:0]    input2;
        input           ctl;
        output [32:0]   out;
	wire 		outc;

        SB_MAC16 #(.TOPADDSUB_UPPERINPUT(1'b1),
                .TOPADDSUB_CARRYSELECT(2'b10),
                .BOTADDSUB_UPPERINPUT(1'b1),
		.MODE_8x8(1)
        ) DSPadr (.CLK(0),
		.A(input2[31:16]),
		.B(input2[15:0]),
		.C(input1[31:16]),
		.D(input1[15:0]),
		.ADDSUBTOP(ctl),
		.ADDSUBBOT(ctl),
		.CO(outc),
		.O(out[31:0])
		);

	assign out[32] = outc ^ ctl ;

endmodule

