// ALU/alu_shifter.sv
// -----------------------------------------------------------------------------
// Shift Unit - Logical and arithmetic shift operations
// Supports both 64-bit and 32-bit (W-instruction) variants
// -----------------------------------------------------------------------------

import alu_pkg::*;

module alu_shifter #(
    parameter WIDTH = 64
) (
    input  logic [WIDTH-1:0]   op_a,
    input  logic [WIDTH-1:0]   op_b,
    input  alu_op_t            alu_op,
    
    output logic [WIDTH-1:0]   result,
    output alu_flags_t         flags
);
    
    localparam SHIFT_BITS = $clog2(WIDTH);
    localparam SHIFT_BITS_32 = 5; // For 32-bit shifts
    
    logic [SHIFT_BITS-1:0] shift_amount;
    logic [SHIFT_BITS_32-1:0] shift_amount_32;
    
    always_comb begin
        result = '0;
        flags = '0;
        
        shift_amount = op_b[SHIFT_BITS-1:0];
        shift_amount_32 = op_b[SHIFT_BITS_32-1:0];
        
        case (alu_op)
            // 64-bit shift operations
            ALU_SLL: begin
                result = op_a << shift_amount;
            end
            
            ALU_SRL: begin
                result = op_a >> shift_amount;
            end
            
            ALU_SRA: begin
                result = $signed(op_a) >>> shift_amount;
            end
            
            // 32-bit shift operations (RV64I W-instructions)
            ALU_SLLW: begin
                if (WIDTH == 64) begin
                    logic [31:0] shift32_result;
                    shift32_result = op_a[31:0] << shift_amount_32;
                    result = {{32{shift32_result[31]}}, shift32_result}; // Sign-extend
                end else begin
                    // For 32-bit base, SLLW is same as SLL
                    result = op_a << shift_amount;
                end
            end
            
            ALU_SRLW: begin
                if (WIDTH == 64) begin
                    logic [31:0] shift32_result;
                    shift32_result = op_a[31:0] >> shift_amount_32;
                    result = {{32{shift32_result[31]}}, shift32_result}; // Sign-extend
                end else begin
                    // For 32-bit base, SRLW is same as SRL
                    result = op_a >> shift_amount;
                end
            end
            
            ALU_SRAW: begin
                if (WIDTH == 64) begin
                    logic signed [31:0] shift32_result;
                    shift32_result = $signed(op_a[31:0]) >>> shift_amount_32;
                    result = {{32{shift32_result[31]}}, shift32_result}; // Sign-extend
                end else begin
                    // For 32-bit base, SRAW is same as SRA
                    result = $signed(op_a) >>> shift_amount;
                end
            end
            
            default: begin
                flags.invalid_op = 1'b1;
            end
        endcase
    end

endmodule