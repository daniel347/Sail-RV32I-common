module branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	//inputs
	input clk;
	input actual_branch_decision; 
	input branch_decode_sig;  // enable? If it is 0 branch prediction is always 0, and if it is 1, branch prediction is according to the state table
	input branch_mem_sig; // 
	input[31:0] in_addr; // pc_out
	input[31:0] offset;

	//outputs
	output[31:0] branch_addr;
	output prediction;

	//internal state
	reg[2:0] s;

	reg branch_mem_sig_reg;

	initial begin
		s = 3'b000;
		branch_mem_sig_reg = 1'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

	//using this microarchitecture, branches can't occur consecutively
	//therefore can use branch_mem_sig
	//as every branch is followed by a bubble, so a 0 to 1 transition

	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
            s[0] <= ((!s[2])&(!s[1])&actual_branch_decision) | ((!s[2])&(s[1])&(!actual_branch_decision)) | ((s[2])&(s[1])&actual_branch_decision) | ((s[2])&(!s[1])&(!actual_branch_decision));
			s[1] <= ((s[1]&(!s[0])) | ((!s[2])&(s[0])&(actual_branch_decision)) | ((s[2])&(s[0])&(!actual_branch_decision)));
			s[2] <= ((s[2]&(!s[1])) | ((s[2])&(s[0])) | ((s[2])&(actual_branch_decision)) |  ((s[1])&(!s[0])&(actual_branch_decision)));
		end
	end

	assign branch_addr = in_addr + offset; // offset due to immediate? 

	assign prediction = s[2] & branch_decode_sig;

endmodule