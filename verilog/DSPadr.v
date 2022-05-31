module ALUadrDSP(input1,input2,ctl,out);
        input [31:0]    input1;
        input [31:0]    input2;
        input           ctl;
        output [32:0]   out;

        SB_MAC16 #(.TOPADDSUB_UPPERINPUT(1'b1),
                .TOPADDSUB_CARRYSELECT(2'b11),
                .BOTADDSUB_UPPERINPUT(1'b1),
                .BOTADDSUB_CARRYSELECT(2'b11),
                .A_SIGNED(1'b1),
                .B_SIGNED(1'b1)
        ) DSPadr ()

endmodule

