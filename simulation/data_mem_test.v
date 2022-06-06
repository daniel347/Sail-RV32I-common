module test;
  reg clk;
  reg start;
  reg [31:0] addr;
  reg [31:0] write_data;
  reg memwrite;
  reg memread;
  reg [3:0] sign_mask;
  wire [31:0] read_data;
  wire [7:0] led;
  wire clk_stall;
  
  // Instantiate design under test
  data_mem uut(
    .clk(clk),
    .addr(addr),
    .write_data(write_data),
    .memwrite(memwrite),
    .memread(memread),
    .sign_mask(sign_mask),
    .read_data(read_data),
    .led(led),
    .clk_stall(clk_stall));
  
  initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
  end
    
  initial begin
    $dumpfile("data_mem.vcd");
    $dumpvars;
    $monitor("read_data = %h    led = %b    clk_stall = %b, time = %3d", read_data, led, clk_stall, $time);

    addr = 32'h00000000;
    write_data = 32'h00000000;
    memwrite = 1'b0;
    memread = 1'b0;
    sign_mask = 4'b0000;

    #10; //write a word
    addr = 32'h00000004;
    write_data = 32'hff03ab21;
    memwrite = 1'b1;
    memread = 1'b0;
    sign_mask = 4'b0111;
    
    #2;
    memwrite = 1'b0;
    
    #8;
    //read the word
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b0111;
    
    #2;
    memread = 1'b0;

    #8; //write a half word
    addr = 32'h00000008;
    write_data = 32'h0000ab21;
    memwrite = 1'b1;
    memread = 1'b0;
    sign_mask = 4'b0011;
    
    #2;
    memwrite = 1'b0;

    #8;
    //read the halfword signed
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b1011;
    
    #2;
    memread = 1'b0;

    #8;
    //read the halfword unsigned 
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b0011;
    
    #2;
    memread = 1'b0;


    #8; //write a byte
    addr = 32'h00000013;
    write_data = 32'h00000053;
    memwrite = 1'b1;
    memread = 1'b0;
    sign_mask = 4'b0001;
    
    #2;
    memwrite = 1'b0;

    #8;
    //read the bytes unsigned 
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b0001;
    
    #2;
    memread = 1'b0;

    #8;
    //read the bytes signed 
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b1001;
    
    #2;
    memread = 1'b0;


    #8;
    //read the first word written again 
    addr = 32'h00000004;
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b0111;
    
    #2;
    memread = 1'b0;

    #8; //write a word then read straight after (only applicable if no clock stall)
    addr = 32'h00000008;
    write_data = 32'habababab;
    memwrite = 1'b1;
    memread = 1'b0;
    sign_mask = 4'b0111;

    #2; //read a halfword straght after writing
    addr = 32'h00000004;
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b0011;
    
    #2;
    memread = 1'b0;

    #8;
    // write to the led memory mapped register
    addr = 32'h00002000;
    memwrite = 1'b1;
    memread = 1'b0;
    sign_mask = 4'b0111;
    
    #2;
    memwrite = 1'b1;
  end

  initial begin
    #150 $stop;
  end
    
endmodule