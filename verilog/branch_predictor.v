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
	input branch_decode_sig;
	input branch_mem_sig;
	input[31:0] in_addr;
	input[31:0] offset;

	//outputs
	output[31:0] branch_addr;
	output prediction;

	//internal state
	reg[1:0] s;	
	reg branch_mem_sig_reg;
    reg[2:0] local_history_table[7:0];
    reg[1:0] local_prediction_table[7:0];
	reg[2:0] addr_reg[2:0];
	
	initial begin
		s = 2'b00;
		branch_mem_sig_reg = 1'b0;


		local_history_table[0] = 3'b000;
        local_history_table[1] = 3'b000;
        local_history_table[2] = 3'b000;
        local_history_table[3] = 3'b000;
        local_history_table[4] = 3'b000;
        local_history_table[5] = 3'b000;
        local_history_table[6] = 3'b000;
        local_history_table[7] = 3'b000;

        local_prediction_table[0] = 2'b00;
        local_prediction_table[1] = 2'b00;
        local_prediction_table[2] = 2'b00;
        local_prediction_table[3] = 2'b00;
        local_prediction_table[4] = 2'b00;
        local_prediction_table[5] = 2'b00;
        local_prediction_table[6] = 2'b00;
        local_prediction_table[7] = 2'b00;


	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

	//using this microarchitecture, branches can't occur consecutively
	//therefore can use branch_mem_sig
	//as every branch is followed by a bubble, so a 0 to 1 transition
	always @(posedge clk) begin

		addr_reg[2] <= addr_reg[1];
		addr_reg[1] <= addr_reg[0];
		addr_reg[0] <= in_addr[2:0];

		if (branch_mem_sig_reg) begin
			
			local_prediction_table[local_history_table[addr_reg[2]]][1] <= (local_prediction_table[local_history_table[addr_reg[2]]][1]&local_prediction_table[local_history_table[addr_reg[2]]][0]) | (local_prediction_table[local_history_table[addr_reg[2]]][0]&actual_branch_decision) | (local_prediction_table[local_history_table[addr_reg[2]]][1]&actual_branch_decision); //LPT update
			local_prediction_table[local_history_table[addr_reg[2]]][0] <= (local_prediction_table[local_history_table[addr_reg[2]]][1]&(!local_prediction_table[local_history_table[addr_reg[2]]][0])) | ((!local_prediction_table[local_history_table[addr_reg[2]]][0])&actual_branch_decision) | (local_prediction_table[local_history_table[addr_reg[2]]][1]&actual_branch_decision); //LPT update

			local_history_table[addr_reg[0]] <= local_history_table[addr_reg[0]]>>1; //LHT update rightshift
			local_history_table[addr_reg[0]][2] <= actual_branch_decision; //LHT update
		end
	end

	assign branch_addr = in_addr + offset;

	assign prediction = local_prediction_table[local_history_table[addr_reg[0]]][1] & branch_decode_sig;

endmodule