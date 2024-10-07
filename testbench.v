module testbench;
    // Define registers for inputs and expected outputs
    reg [31:0] operand_a, operand_b;
    reg [2:0] operation;

    // ALU output signals
    wire [31:0] actual_result;
    wire zero_out, overflow_out, carry_out, negative_out;

    // Instantiate the ALU module
    alu alu_dut (
        .a(operand_a),
        .b(operand_b),
        .f(operation),
        .result(actual_result),
        .zero(zero_out),
        .overflow(overflow_out),
        .carry(carry_out),
        .negative(negative_out)
    );

    // Registers for expected results from the test vectors
    reg [31:0] expected_result;
    reg expected_zero, expected_overflow, expected_carry, expected_negative;
    integer vector_file, vector_read;
    reg end_of_test; // Control flag for ending the loop

    // Task to load the next test vector from the file
    task load_test_vector;
        input integer file;
        output integer result;
        result = $fscanf(file, "%h %h %h %h %d %d %d %d\n",
                         operation, operand_a, operand_b, expected_result,
                         expected_zero, expected_overflow, expected_carry, expected_negative);
    endtask

    // Task to validate actual results against expected results
    task validate_results;
        if (actual_result !== expected_result || zero_out !== expected_zero ||
            overflow_out !== expected_overflow || carry_out !== expected_carry ||
            negative_out !== expected_negative) begin
            $display("Test FAILED for operation=%h, a=%h, b=%h. Expected: result=%h zero=%d overflow=%d carry=%d negative=%d. Got: result=%h zero=%d overflow=%d carry=%d negative=%d",
                     operation, operand_a, operand_b, expected_result, expected_zero, expected_overflow,
                     expected_carry, expected_negative, actual_result, zero_out, overflow_out, carry_out, negative_out);
        end else begin
            $display("Test PASSED for operation=%d, a=%h, b=%h.", operation, operand_a, operand_b);
        end
    endtask

    // Main testing process
    initial begin
        // Initialize the end_of_test flag
        end_of_test = 0;

        // Open the test vector file
        vector_file = $fopen("alu.tv", "r");
        if (vector_file == 0) begin
            $display("ERROR: Could not open test vector file.");
            $finish;
        end

        // Loop through the file and test each vector
        while (!end_of_test) begin
            // Load the test vector
            load_test_vector(vector_file, vector_read);
            
            // If the test vector isn't read correctly, stop the loop
            if (vector_read != 8) begin
                $display("End of file or invalid format detected. Exiting loop.");
                end_of_test = 1; // Set flag to exit the loop
            end else begin
                // Allow some time for the ALU to process the inputs
                #10;
                // Validate the actual outputs with the expected results
                validate_results();
            end
        end

        // Close the file and end the simulation
        $fclose(vector_file);
        $stop;
    end
endmodule
