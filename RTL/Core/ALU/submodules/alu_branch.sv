// ALU/alu_branch.sv
// -----------------------------------------------------------------------------
// Branch Unit - Branch comparison logic
// Handles all RISC-V branch conditions: BEQ, BNE, BLT, BGE, BLTU, BGEU
// -----------------------------------------------------------------------------

import alu_pkg::*;

module alu_branch #(
    parameter WIDTH = 64
) (
    input  logic [WIDTH-1:0]   op_a,
    input  logic [WIDTH-1:0]   op_b,
    input  alu_op_t            alu_op,
    
    output logic               branch_taken,
    output alu_flags_t         flags
);
    
    always_comb begin
        branch_taken = 1'b0;
        flags = '0;
        
        case (alu_op)
            ALU_BEQ: begin
                branch_taken = (op_a == op_b);
            end
            
            ALU_BNE: begin
                branch_taken = (op_a != op_b);
            end
            
            ALU_BLT: begin
                branch_taken = ($signed(op_a) < $signed(op_b));
            end
            
            ALU_BGE: begin
                branch_taken = ($signed(op_a) >= $signed(op_b));
            end
            
            ALU_BLTU: begin
                branch_taken = (op_a < op_b);
            end
            
            ALU_BGEU: begin
                branch_taken = (op_a >= op_b);
            end
            
            default: begin
                flags.invalid_op = 1'b1;
            end
        endcase
    end

endmodule