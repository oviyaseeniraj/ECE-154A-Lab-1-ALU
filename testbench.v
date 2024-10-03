`timescale 1ns / 1ps

module testbench;
    reg clk, reset;
    reg [31:0] a, b;           // Inputs to the ALU
    reg [2:0] f;               // Function select
    wire [31:0] result;        // Output from the ALU
    wire zero, overflow, carry, negative; // Flags

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

    // Read vectors
    initial begin
        $readmemh("alu.tv", testvectors); // Read vectors
        // Initialize
        vectornum = 0;
        errors = 0;
        //Apply reset wait
        reset = 1;
        #10; // delay
        reset = 0;
    end

    // apply test vectors on rising edge of clk
    always @(posedge clk) begin
        #1; // Apply inputs with some delay (1ns) AFTER clock
        {a, b, c, yexpected} = testvectors[vectornum];
    end

    // check results on falling edge of clk
    always @(negedge clk) if (~reset) // skip during reset
    begin
        if (y !== yexpected) begin 
            $display("Error: inputs = %h", {a, b, c});
            $display(" outputs = %h (%h exp)",y,yexpected);
            // increment array index and read next testvector
            vectornum = vectornum + 1;
            if (testvectors[vectornum] === 4'bx) begin 
                $display("%d tests completed with %d errors", 
                    vectornum, errors);
                $finish; // End simulation 
            end
        end
    end
endmodule
