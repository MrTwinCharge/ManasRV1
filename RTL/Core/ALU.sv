// core/ALU.sv
// -----------------------------------------------------------------------------
// RV64I Arithmetic Logic Unit
// Features:
// - Supports 64-bit integer operations (add, sub, slt, sltu, and, or, xor, sll,
//   srl, sra, lui, auipc)
// - Branch comparison logic (beq, bne, blt, bge, bltu, bgeu)
// - Parameterized data width (default: 64 bits)
// - Single-cycle combinational design
// - Optional support for multiplication/division (RV64M extension, if enabled)
// - Outputs result and branch-taken signal
// -----------------------------------------------------------------------------

module ALU #(
    parameter WIDTH = 64 
) (
    input  logic [WIDTH-1:0]   op_a,      // Operand A
    input  logic [WIDTH-1:0]   op_b,      // Operand B
    input  logic [4:0]         alu_op,    // ALU Select
    input  logic [2:0]         funct3,    // RISC-V funct3
    input  logic [6:0]         funct7,    // RISC-V funct7

    output logic [WIDTH-1:0]   result,    
    output logic               branch_taken, 
    output logic               illegal_op    
);

    logic cmp_result; 

    // -------------------------------------------------------------------------
    // ALU Logic
    // -------------------------------------------------------------------------
    always_comb begin
        // Default outputs
        result       = '0;
        branch_taken = 1'b0;
        illegal_op   = 1'b0;

        unique case (alu_op)
            // Arithmetic operations
            // -------------------------------------------------
            // TODO: Implement ADD, SUB
            // TODO: Implement SLT, SLTU
            // TODO: Implement LUI, AUIPC

            // Logical operations
            // -------------------------------------------------
            // TODO: Implement AND, OR, XOR

            // Shift operations
            // -------------------------------------------------
            // TODO: Implement SLL, SRL, SRA

            // Branch comparisons
            // -------------------------------------------------
            // TODO: Implement BEQ, BNE, BLT, BGE, BLTU, BGEU

            // Optional: RV64M extension (MUL/DIV/REM)
            // -------------------------------------------------
            // TODO: Add MUL, DIV, REM ops if enabled

            default: begin
                result       = '0;
                branch_taken = 1'b0;
                illegal_op   = 1'b1; // unsupported ALU operation
            end
        endcase
    end

endmodule
