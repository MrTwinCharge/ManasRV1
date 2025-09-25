// ALU/alu_pkg.sv
// -----------------------------------------------------------------------------
// ALU Package - Operation definitions and common types
// -----------------------------------------------------------------------------

package alu_pkg;

    // ALU operation encoding - 6 bits for expandability
    typedef enum logic [5:0] {
        // Base Integer Operations (RV64I) - 0x00-0x17
        ALU_ADD    = 6'h00,  // Add
        ALU_SUB    = 6'h01,  // Subtract
        ALU_SLT    = 6'h02,  // Set less than (signed)
        ALU_SLTU   = 6'h03,  // Set less than (unsigned)
        ALU_LUI    = 6'h04,  // Load upper immediate
        ALU_AUIPC  = 6'h05,  // Add upper immediate to PC
        
        // Logical Operations - 0x08-0x0F
        ALU_AND    = 6'h08,  // Bitwise AND
        ALU_OR     = 6'h09,  // Bitwise OR
        ALU_XOR    = 6'h0A,  // Bitwise XOR
        
        // Shift Operations - 0x10-0x17
        ALU_SLL    = 6'h10,  // Shift left logical
        ALU_SRL    = 6'h11,  // Shift right logical
        ALU_SRA    = 6'h12,  // Shift right arithmetic
        
        // Branch Operations - 0x18-0x1F
        ALU_BEQ    = 6'h18,  // Branch equal
        ALU_BNE    = 6'h19,  // Branch not equal
        ALU_BLT    = 6'h1A,  // Branch less than (signed)
        ALU_BGE    = 6'h1B,  // Branch greater equal (signed)
        ALU_BLTU   = 6'h1C,  // Branch less than (unsigned)
        ALU_BGEU   = 6'h1D,  // Branch greater equal (unsigned)
        
        // Multiplication/Division (RV64M) - 0x20-0x2F
        ALU_MUL    = 6'h20,  // Multiply (lower 64 bits)
        ALU_MULH   = 6'h21,  // Multiply high (signed x signed)
        ALU_MULHSU = 6'h22,  // Multiply high (signed x unsigned)
        ALU_MULHU  = 6'h23,  // Multiply high (unsigned x unsigned)
        ALU_DIV    = 6'h24,  // Divide (signed)
        ALU_DIVU   = 6'h25,  // Divide (unsigned)
        ALU_REM    = 6'h26,  // Remainder (signed)
        ALU_REMU   = 6'h27,  // Remainder (unsigned)
        
        // Reserved for future extensions - 0x30-0x37
        
        // 32-bit Variants (RV64I W-instructions) - 0x38-0x3E
        ALU_ADDW   = 6'h38,  // Add word (32-bit, sign-extended)
        ALU_SUBW   = 6'h39,  // Subtract word (32-bit, sign-extended)
        ALU_SLLW   = 6'h3A,  // Shift left logical word
        ALU_SRLW   = 6'h3B,  // Shift right logical word
        ALU_SRAW   = 6'h3C,  // Shift right arithmetic word
        
        // Special Operations
        ALU_NOP    = 6'h3F   // No operation
    } alu_op_t;
    
    // ALU status flags
    typedef struct packed {
        logic overflow;       // Arithmetic overflow
        logic underflow;      // Arithmetic underflow
        logic divide_by_zero; // Division by zero
        logic invalid_op;     // Invalid/unsupported operation
    } alu_flags_t;
    
    // ALU interface bundle for easier port management
    typedef struct packed {
        logic [63:0]   op_a;        // Operand A
        logic [63:0]   op_b;        // Operand B  
        alu_op_t       alu_op;      // Operation select
        logic [63:0]   pc;          // Program counter
        logic [63:0]   imm;         // Immediate value
        logic          enable;      // Enable for pipelined ops
    } alu_inputs_t;
    
    typedef struct packed {
        logic [63:0]   result;      // ALU result
        logic          branch_taken;// Branch decision
        logic          valid;       // Result valid (for pipelined ops)
        alu_flags_t    flags;       // Status flags
    } alu_outputs_t;

endpackage