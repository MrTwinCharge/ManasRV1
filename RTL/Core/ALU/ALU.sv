// ALU/ALU.sv
// -----------------------------------------------------------------------------
// Top-level ALU Module - Orchestrates all functional units
// Parameterized, modular design supporting RV64I and RV64M extensions
// Pipeline-friendly with comprehensive error handling
// -----------------------------------------------------------------------------

`include "submodules/alu_inc.sv"
import alu_inc::*;

module ALU #(
    parameter WIDTH = 64,
    parameter ENABLE_M_EXT = 1,     // Enable RV64M multiply/divide extension
    parameter PIPELINE_MULDIV = 0   // Future: Enable pipelined multiply/divide
) (
    // Clock and reset (for pipelined operations)
    input  logic               clk,
    input  logic               rst_n,
    
    // Input operands
    input  logic [WIDTH-1:0]   op_a,
    input  logic [WIDTH-1:0]   op_b,
    input  alu_op_t            alu_op,
    input  logic [WIDTH-1:0]   pc,          // Program counter (for AUIPC)
    input  logic [WIDTH-1:0]   imm,         // Immediate value (for LUI/AUIPC)
    input  logic               enable,       // Enable signal for pipelined ops
    
    // Outputs
    output logic [WIDTH-1:0]   result,      // ALU result
    output logic               branch_taken, // Branch decision
    output logic               valid,        // Valid signal for pipelined ops
    output alu_flags_t         flags         // Combined status flags
);
    
    // Functional unit outputs
    logic [WIDTH-1:0] arith_result, logic_result, shift_result, muldiv_result;
    alu_flags_t arith_flags, logic_flags, shift_flags, branch_flags, muldiv_flags;
    logic muldiv_valid;
    
    // Instantiate functional units
    alu_arithmetic #(
        .WIDTH(WIDTH)
    ) u_arithmetic (
        .op_a(op_a),
        .op_b(op_b),
        .alu_op(alu_op),
        .pc(pc),
        .imm(imm),
        .result(arith_result),
        .flags(arith_flags)
    );
    
    alu_logical #(
        .WIDTH(WIDTH)
    ) u_logical (
        .op_a(op_a),
        .op_b(op_b),
        .alu_op(alu_op),
        .result(logic_result),
        .flags(logic_flags)
    );
    
    alu_shifter #(
        .WIDTH(WIDTH)
    ) u_shifter (
        .op_a(op_a),
        .op_b(op_b),
        .alu_op(alu_op),
        .result(shift_result),
        .flags(shift_flags)
    );
    
    alu_branch #(
        .WIDTH(WIDTH)
    ) u_branch (
        .op_a(op_a),
        .op_b(op_b),
        .alu_op(alu_op),
        .branch_taken(branch_taken),
        .flags(branch_flags)
    );
    
    alu_muldiv #(
        .WIDTH(WIDTH),
        .ENABLE_M_EXT(ENABLE_M_EXT)
    ) u_muldiv (
        .clk(clk),
        .rst_n(rst_n),
        .op_a(op_a),
        .op_b(op_b),
        .alu_op(alu_op),
        .enable(enable),
        .result(muldiv_result),
        .valid(muldiv_valid),
        .flags(muldiv_flags)
    );
    
    // Result multiplexing and flag aggregation
    always_comb begin
        result = '0;
        flags = '0;
        valid = 1'b1; // Default to valid for combinational ops
        
        case (alu_op)
            // Arithmetic operations
            ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU, ALU_LUI, ALU_AUIPC,
            ALU_ADDW, ALU_SUBW: begin
                result = arith_result;
                flags = arith_flags;
            end
            
            // Logical operations
            ALU_AND, ALU_OR, ALU_XOR: begin
                result = logic_result;
                flags = logic_flags;
            end
            
            // Shift operations
            ALU_SLL, ALU_SRL, ALU_SRA, ALU_SLLW, ALU_SRLW, ALU_SRAW: begin
                result = shift_result;
                flags = shift_flags;
            end
            
            // Branch operations (result is don't care, branch_taken is the output)
            ALU_BEQ, ALU_BNE, ALU_BLT, ALU_BGE, ALU_BLTU, ALU_BGEU: begin
                result = '0; // Branch instructions don't produce results
                flags = branch_flags;
            end
            
            // Multiply/Divide operations
            ALU_MUL, ALU_MULH, ALU_MULHSU, ALU_MULHU,
            ALU_DIV, ALU_DIVU, ALU_REM, ALU_REMU: begin
                result = muldiv_result;
                flags = muldiv_flags;
                valid = muldiv_valid;
            end
            
            // No operation
            ALU_NOP: begin
                result = '0;
                flags = '0;
            end
            
            // Default case
            default: begin
                result = '0;
                flags.invalid_op = 1'b1;
            end
        endcase
    end

endmodule