module alu(
    input [31:0] a, b,
    input [2:0] f,
    output reg [31:0] result,
    output zero,
    output reg overflow,
    output reg carry,
    output reg negative
);

    wire [31:0] sum;
    wire [31:0] b_neg;
    wire [31:0] slt_result;
    wire cout;

    // Invert b for subtraction (only when f=SUB or SLT, which is f=1)
    assign b_neg = (f == 3'b001 || f == 3'b101) ? ~b + 1 : b;

    // Adder for addition and subtraction
    assign {cout, sum} = a + b_neg;

    // SLT operation: Signed comparison of a and b
    assign slt_result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;

    always @(*) begin
        // Default flag values for logical operations
        overflow = 1'b0;
        carry = 1'b0;
        negative = 1'b0;

        
        overflow = ~(f[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & (~f[1]); 

        case (f)
            3'b000: begin  // ADD operation (f=0)
                result = sum;            // ADD
                carry = cout;            // Carry for ADD
                // Overflow occurs when adding two numbers of the same sign results in a different signed result
                overflow = (a[31] == b[31]) && (result[31] != a[31]); 
                negative = result[31];   // Negative flag based on result MSB
            end
            3'b001: begin  // SUB operation (f=1)
                result = sum;            // SUB
                carry = cout || (b == 32'b0);            // Carry for SUB// Overflow for SUB
                negative = result[31];   // Negative flag based on result MSB
            end
            3'b010: begin  // AND operation (f=2)
                result = a & b;          // AND
                carry = 1'b0;            // No carry for AND
                overflow = 1'b0;         // No overflow for AND
                negative = result[31];   // Negative flag based on result MSB
            end
            3'b011: begin // OR operation (f=3)
                result = a | b;
                carry = 1'b0; // No carry for AND
                overflow = 1'b0; // No overflow for OR
                negative = result[31]; // Negative flag based on result MSB
            end
            3'b101: begin  // SLT operation (f=5)
                result = slt_result;     // SLT for f=5
                carry = cout || (b == 32'b0); // Subtraction cout
                negative = result[31];   // Negative flag based on result MSB
            end
            default: result = 32'b0;
        endcase
    end

    // Zero flag: Set if result is zero
    assign zero = (result == 32'b0);

endmodule
