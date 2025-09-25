// ALU/alu_arithmetic.sv
// -----------------------------------------------------------------------------
// Arithmetic Unit - Basic arithmetic operations (ADD, SUB, SLT, LUI, AUIPC)
// Includes overflow detection and 32-bit W-instruction variants
// -----------------------------------------------------------------------------

import alu_pkg::*;

module alu_arithmetic #(
    parameter WIDTH = 64
) (
    input  logic [WIDTH-1:0]   op_a,
    input  logic [WIDTH-1:0]   op_b,
    input  alu_op_t            alu_op,
    input  logic [WIDTH-1:0]   pc,
    input  logic [WIDTH-1:0]   imm,
    
    output logic [WIDTH-1:0]   result,
    output alu_flags_t         flags
);
    
    // Extended precision for overflow detection
    logic [WIDTH:0] add_result, sub_result, auipc_result;
    
    always_comb begin
        result = '0;
        flags = '0;
        
        case (alu_op)
            ALU_ADD: begin
                add_result = {1'b0, op_a} + {1'b0, op_b};
                result = add_result[WIDTH-1:0];
                flags.overflow = add_result[WIDTH];
            end
            
            ALU_SUB: begin
                sub_result = {1'b0, op_a} - {1'b0, op_b};
                result = sub_result[WIDTH-1:0];
                flags.underflow = sub_result[WIDTH];
            end
            
            ALU_SLT: begin
                result = ($signed(op_a) < $signed(op_b)) ? {{(WIDTH-1){1'b0}}, 1'b1} : '0;
            end
            
            ALU_SLTU: begin
                result = (op_a < op_b) ? {{(WIDTH-1){1'b0}}, 1'b1} : '0;
            end
            
            ALU_LUI: begin
                if (WIDTH == 64) begin
                    // For RV64, LUI produces a 64-bit result with upper 32 bits zeroed
                    result = {32'b0, imm[31:0]} << 12;
                end else begin
                    result = imm << 12;
                end
            end
            
            ALU_AUIPC: begin
                auipc_result = {1'b0, pc} + {1'b0, (imm << 12)};
                result = auipc_result[WIDTH-1:0];
                flags.overflow = auipc_result[WIDTH];
            end
            
            // 32-bit arithmetic operations (RV64I W-instructions)
            ALU_ADDW: begin
                if (WIDTH == 64) begin
                    logic [31:0] add32_result;
                    add32_result = op_a[31:0] + op_b[31:0];
                    result = {{32{add32_result[31]}}, add32_result}; // Sign-extend
                end else begin
                    // For 32-bit base, ADDW is same as ADD
                    add_result = {1'b0, op_a} + {1'b0, op_b};
                    result = add_result[WIDTH-1:0];
                    flags.overflow = add_result[WIDTH];
                end
            end
            
            ALU_SUBW: begin
                if (WIDTH == 64) begin
                    logic [31:0] sub32_result;
                    sub32_result = op_a[31:0] - op_b[31:0];
                    result = {{32{sub32_result[31]}}, sub32_result}; // Sign-extend
                end else begin
                    // For 32-bit base, SUBW is same as SUB
                    sub_result = {1'b0, op_a} - {1'b0, op_b};
                    result = sub_result[WIDTH-1:0];
                    flags.underflow = sub_result[WIDTH];
                end
            end
            
            default: begin
                flags.invalid_op = 1'b1;
            end
        endcase
    end

endmodule