// let's try building a parameterized Serial Adder 
// List of modules to be instantiated :
// 2 Shift reg, 1 Full Adder, 1 DFF, 1 And gate

`default_nettype none
// Serial Adder

module serialAdder( i_clk, i_rst, i_a, i_b, o_sum);

parameter DATAWIDTH = 8;

input wire i_clk, i_rst;
input wire [DATAWIDTH-1:0] i_a, i_b;
output reg [DATAWIDTH-1:0] o_sum;

reg i_shift, i_load;
wire [DATAWIDTH-1:0] o_rega, o_regb;

wire o_regc;
wire o_and, dff_in, dff_out;

// Wrap entire code over a counter of DATAWIDTH bits

reg [DATAWIDTH:0] counter;

// module instantiations
shiftReg A(i_clk, i_rst, i_shift, i_load, i_a, o_rega);
shiftReg B(i_clk, i_rst, i_shift, i_load, i_b, o_regb);

fullAdder C(o_rega[0], o_regb[0], dff_out, o_regc, dff_in);

dff D(o_and, i_rst, dff_in, dff_out);

andGate AND(i_shift, i_clk, o_and);

always @(posedge i_clk) 
    if (!i_rst)  
    begin
        counter <= DATAWIDTH+2;
        i_shift <= 0;
        i_load <= 0;
        o_sum <= 0;
    end
    else if (counter == DATAWIDTH+2)
    begin
        i_load <= 1;
        i_shift <= 0;
        counter <= counter - 1;
    end
    else if (counter != 0)
    begin
        i_load <= 0;
        i_shift <= 1;
        o_sum <= {o_regc, o_sum[DATAWIDTH-1:1]};
        counter <= counter - 1;
    end
    else
    begin
        i_load <= 0;
        i_shift <= 0;
        counter <= DATAWIDTH+2;
        o_sum <= 0;
    end

endmodule

// Shift reg
module shiftReg( i_clk, i_rst, i_shift, i_load, i_data, o_data );

parameter DATAWIDTH = 8;
input wire i_rst, i_clk, i_shift, i_load;
input wire [DATAWIDTH-1:0] i_data;
output wire [DATAWIDTH-1:0] o_data;

reg [DATAWIDTH-1:0] o_reg;

always @(posedge i_clk) begin 
    if (!i_rst) 
        o_reg <= 0;
    else if (i_load)
        o_reg <= i_data;
    else if (i_shift)
        o_reg <= {1'b0, o_reg[DATAWIDTH-1:1]};
end

assign o_data = o_reg;
endmodule


// D flip flop
module dff( i_clk, i_rst, i_data, o_data );
input wire i_clk, i_rst, i_data;
output wire o_data;

reg o_reg;
always @(posedge i_clk) begin 
    if (!i_rst) 
        o_reg <= 0;
    else
        o_reg <= i_data;
end

assign o_data = o_reg;

endmodule


// And Gate
module andGate( i_a, i_b, o_c );
input wire i_a, i_b;
output wire o_c;

assign o_c = i_a & i_b;

endmodule


// Full Adder
module fullAdder( i_a, i_b, i_cin, o_sum, o_cout );

input wire i_a, i_b, i_cin;
output wire o_cout;
output reg o_sum;
reg o_cout_reg;

always @(*) begin
    o_sum = i_a ^ i_b ^ i_cin;
    o_cout_reg = (i_a & i_b) | (i_b & i_cin) | (i_a & i_cin);
end

assign o_cout = o_cout_reg;
endmodule