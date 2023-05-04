module tb;

reg i_clk, i_rst;
reg [7:0] i_a, i_b;

wire [7:0] o_sum;

serialAdder UUT(i_clk, i_rst, i_a, i_b, o_sum);

always begin
    i_clk = 0;
    forever i_clk = #5 ~i_clk;
end

always begin
    #0 i_rst = 1;
    #5 i_rst = 0;
    #10 i_a = 8'b11001100; i_rst = 1; i_b = 8'b00110011;
    #100;
    #10 i_a = 8'b10101010; i_rst = 1; i_b = 8'b10010011;
    #100;
    $finish;
end

endmodule