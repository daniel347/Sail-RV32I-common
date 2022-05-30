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
    $monitor("read_data = %h    led = %b    clk_stall = %b, time = %3d", read_data, led, clk_stall, $time);
    //write a word
    addr = 32'h1100;
    write_data = 32'hff03ab21;
    memwrite = 1'b1;
    memread = 1'b0;
    sign_mask = 4'b111;
    
    #2;
    memwrite = 1'b0;
    
    #8;
    //read the word
    memwrite = 1'b0;
    memread = 1'b1;
    sign_mask = 4'b111;
    
    #2;
    memread = 1'b0;
  end

  initial begin
	  $dumpfile("test.vcd");
	  $dumpvars(0,test);
	end
    
endmodule
