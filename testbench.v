`timescale 1ns / 1ps

module testbench;
    reg clk, reset;
    reg [2:0] f;              // Function select, from testvectors
    reg [31:0] a, b;          // Inputs to ALU from testvector 
    reg [31:0] exp_res;       // Expected output from testvector, will be compared against output of ALU
    reg exp_zero, exp_over, exp_carry, exp_neg; // Expected flag values from testvector, will be compared against ALU

    wire [31:0] result;        // Output from the ALU, will be compared against expected output from testvector
    wire zero, overflow, carry, negative; // Flag outputs from ALU, will be compared against expected flags from testvector

    reg [31:0] vectornum, errors;   // variables to keep track of test cases (vector being tested and count of the number of errors)
    reg [31:0] testvectors[184:0];  // array of testvectors  (specifies size of each element and number of elements, in this case 23*8)

    // Instantiate the ALU
    alu my_alu (
        .a(a),
        .b(b),
        .f(f),
        .result(result),
        .zero(zero),
        .overflow(overflow),
        .carry(carry),
        .negative(negative)
    );

    // generate clock
    always begin
        // clock with 10ns period
        clk = 1; #5;
        clk = 0; #5;
    end

    // Read vectors
    initial begin
        $readmemh("alu.tv", testvectors); // Read vectors in hex format (mem*h*) and store in testvectors
        vectornum = 0;  // row number from vectorfile
        errors = 0;     // error counter
        reset = 1;      // Apply reset wait
        #10;            // delay
        reset = 0;
    end

    // apply test vectors on rising edge of clk
    always @(posedge clk) begin
        #1;
        {f, a, b, exp_res, exp_zero, exp_over, exp_carry, exp_neg} = testvectors[vectornum];
    end

    always @(negedge clk)
        if(~reset) begin
            if (result !== exp_res) begin
                $display("Error: inputs = %h", {f,a,b});
                $display(" outputs = %h (%h exp)", result, exp_res);
                errors= errors+1;
            end
            if (exp_carry !== carry) begin
                $display("Error: inputs = %h", {f,a,b});
                $display(" outputs = %h (%h exp)", carry, exp_carry);
                errors= errors+1;
            end
            if (exp_neg !== negative) begin
                $display("Error: inputs = %h", {f,a,b});
                $display(" outputs = %h (%h exp)", negative, exp_neg);
                errors= errors+1;
            end
            if (exp_over !== overflow) begin
                $display("Error: inputs = %h", {f,a,b});
                $display(" outputs = %h (%h exp)", overflow, exp_over);
                errors= errors+1;
            end
            if (exp_zero !== zero) begin
                $display("Error: inputs = %h", {f,a,b});
                $display(" outputs = %h (%h exp)", zero, exp_zero);
                errors= errors+1;
            end
            vectornum = vectornum+1;
            if(testvectors[vectornum] == 8'hx) begin
                $display("%d tests completed with %d errrors", vectornum, errors);
                $finish;
            end
        end
endmodule
