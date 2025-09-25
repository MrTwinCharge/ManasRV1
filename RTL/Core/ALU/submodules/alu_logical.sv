// ALU/alu_logical.sv
// -----------------------------------------------------------------------------
// Logical Unit - Bitwise logical operations (AND, OR, XOR)
// Simple combinational logic with error checking
// -----------------------------------------------------------------------------

import alu_pkg::*;

module alu_logical #(
    parameter WIDTH = 64
) (
    input  logic [WIDTH-1:0]   op_a,
    input  logic [WIDTH-1:0]   op_b,
    input  alu_op_t            alu_op,
    
    output logic [WIDTH-1:0]   result,
    output alu_flags_t         flags
);
    
    always_comb begin
        result = '0;
        flags = '0;
        
        case (alu_op)
            ALU_AND: begin
                result = op_a & op_b;
            end
            
            ALU_OR: begin
                result = op_a | op_b;
            end
            
            ALU_XOR: begin
                result = op_a ^ op_b;
            end
            
            default: begin
                flags.invalid_op = 1'b1;
            end
        endcase
    end

endmodule