module sAdd( ain, bin, reset_n, clk, start, sum, done);
	parameter N =8;
	input [N-1:0] ain, bin;
	input reset_n, clk, start;
	output reg done;
	output reg [N-1:0]sum;
	
	reg [2:0] counter;
	reg [1:0] state;
	reg [N-1:0] ain_reg, bin_reg, sum_in;
	wire [N-1:0] A_reg, B_reg, sum_reg;
	localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

	// instantiate all the components 
	reg fin_a, fin_b, reset;
	//wire lin_s;
	reg load_a, load_b, load_s, shiftR, lin;
	wire dff_in;
	wire dff_out, f_cout;
	wire f_out;
	assign dff_in = f_cout;
	//reg lin_s;
	//assign dff_out = cin;

	fulladder FA(fin_a, fin_b, dff_out, f_out, f_cout);

	shiftre regA(ain_reg, load_a, shiftR, lin, clk, reset, A_reg);
	shiftre regB(bin_reg, load_b, shiftR, lin, clk, reset, B_reg);
	shiftre regsum(sum_in, load_s, shiftR, f_out, clk, reset, sum_reg );
	
	dff flipflop(dff_in, reset, clk, dff_out);

	always @(posedge clk, negedge reset)
	begin
	state <= S0;
	case(state)	
	S0 : begin
	if(!(reset_n) && start) begin
		load_a = 0;
		load_b = 0;
		load_s = 0;
		reset = 0;
		done = 0;
		lin = 0;
		shiftR =0;
		state <= S1;
		end
	end
	S1 : begin
		//dff_in = f_cout;
		reset = 1;
		ain_reg <= ain;
		bin_reg <= bin;

		load_a = 1;
		load_b = 1;
		lin = 0;
		counter = 3'b111;
		state <= S2;
		end
	S2 : begin
		if(counter !=0) begin
		shiftR = 1;
		counter = counter -1;
		ain_reg = A_reg;
		bin_reg = B_reg;
		fin_a = ain_reg[0];
		fin_b = bin_reg[0];
		sum_in = sum_reg;
		state <= S2;
		end
		else  begin
		state <= S3;
		end
	end
	S3 : begin
		done = 1'b1;
		reset = 1'b0;
		sum = sum_reg;
	     end
	endcase
	end
endmodule


module fulladder (input a, input b, input cin , output sum, output cout);
	assign sum = a ^ b ^ cin;
	assign cout = (a & b) || (b & cin) || (cin & a);
endmodule

module dff (input d, input reset, input clk, output reg q);
	
	always @(posedge clk)	
	begin
	if(!reset)
 		q<=0;
	else 
		q<=d;
	end
endmodule

module shiftre #(parameter N=8)(input [N-1:0] D, input load, shiftR , lin , clk, reset_n, output reg [N-1:0] Q);
	always @(posedge clk or negedge reset_n) begin
	if (!reset_n ) Q <= {N{1'b0}};
	else if (shiftR)
		Q <= {lin , Q[N-1:1]};
	else if (load)
		Q <= D;
	end
endmodule