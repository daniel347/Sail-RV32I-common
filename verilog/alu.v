`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"



/*
 *	Description:
 *
 *		This module implements the ALU for the RV32I.
 */
module ALUlogic( A, B, sel, out);
	input 		A;
	input 		B;
	input[1:0] 	sel;
	output 		out;

	assign out = sel[1]?(sel[0] ? (A && B) : (A ^ B) ):(sel[0] ? ( (!A) && B) : (A||B) );
endmodule

module ALUlogictotal(A,B, sel, out);
	input[31:0] 	A;
	input[31:0]	B;
	input[1:0]	sel;
	output[31:0]	out;

	genvar i;

	generate
	for (i=0 ; i<32 ; i = i+1) begin
		ALUlogic logunit(A[i],B[i],sel,out[i]);
		end
	endgenerate

endmodule

module ALUadr(input1,input2,ctl,out);
	input [31:0] 	input1; 
	input [31:0] 	input2;
	input		ctl;  
	output [32:0] 	out;
	wire [31:0]	add1;
	wire [31:0]	add2;
	
	
	assign add1 = input1;
	assign add2 = ctl ? ~(input2): input2;
			/*assign out = ctl ? (add1 + add2) : (add1 + add2);*/
	assign out = {1'b0,add1} + {1'b0,add2} + {32'b0,ctl};
endmodule


/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */
module alu(ALUctl, A, B, ALUOut, Branch_Enable);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	wire [31:0]		addr;
	wire 			ucomp;
	output reg [31:0]	ALUOut;
	output reg		Branch_Enable;
	wire[31:0]		logic_out;
	wire[1:0]		logicstate;

	ALUadrDSP ALUaddr_block(A,B,ALUctl[2],{ucomp,addr});

	assign logicstate = { ~|(ALUctl[1:0]) , (&{ALUctl[3],ALUctl[2:0]} || &(~{ALUctl[3],ALUctl[2:0]}) ) };

	ALUlogictotal ALUlog(A,B,logicstate,logic_out);
	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		ALUOut = 32'b0;
		Branch_Enable = 1'b0;
	end

	always @(ALUctl, A, B,addr,logic_out) begin
		case (ALUctl[3:0])
			/*
			 *	AND (the fields also match ANDI and LUI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:	ALUOut = logic_out;

			/*
			 *	OR (the fields also match ORI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:	ALUOut = logic_out;

			/*
			 *	ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:	ALUOut = addr;

			/*
			 *	SUBTRACT (the fields also matches all branches)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:	ALUOut = addr ;

			/*
			 *	SLT (the fields also matches all the other SLT variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:	ALUOut = (addr[31]) ? 32'b1 : 32'b0;

			/*
			 *	SRL (the fields also matches the other SRL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:	ALUOut = A >> B[4:0];

			/*
			 *	SRA (the fields also matches the other SRA variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:	ALUOut = A >>> B[4:0];

			/*
			 *	SLL (the fields also match the other SLL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:	ALUOut = A << B[4:0];

			/*
			 *	XOR (the fields also match other XOR variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:	ALUOut = logic_out;

			/*
			 *	CSRRW  only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	ALUOut = A;

			/*
			 *	CSRRS only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	ALUOut = logic_out;

			/*
			 *	CSRRC only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	ALUOut = logic_out;

			/*
			 *	Should never happen.
			*/
			default:					ALUOut = 0;
		endcase
	end

	always @(ALUctl, ALUOut, A, B,addr) begin
		case (ALUctl[6:4])
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:	Branch_Enable = ( addr == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:	Branch_Enable = !( addr == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:	Branch_Enable = (addr[31]);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:	Branch_Enable = !(addr[31]);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:	Branch_Enable = !(ucomp);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:	Branch_Enable = (ucomp);

			default:					Branch_Enable = 1'b0;
		endcase
	end
endmodule


