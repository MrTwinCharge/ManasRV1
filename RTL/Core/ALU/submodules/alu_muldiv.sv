// ALU/alu_muldiv.sv
// -----------------------------------------------------------------------------
// Multiply/Divide Unit - RV64M extension operations
// Handles: MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
// -----------------------------------------------------------------------------

import alu_pkg::*;

module alu_muldiv #(
    parameter WIDTH = 64,
    parameter ENABLE_M_EXT = 1
) (
    input  logic               clk,
    input  logic               rst_n,
    input  logic [WIDTH-1:0]   op_a,
    input  logic [WIDTH-1:0]   op_b,
    input  alu_op_t            alu_op,
    input  logic               enable,
    
    output logic [WIDTH-1:0]   result,
    output logic               valid,
    output alu_flags_t         flags
);
    
    generate
        if (ENABLE_M_EXT) begin : gen_muldiv
            
            // Extended precision for multiplication
            logic [2*WIDTH-1:0] mul_result_u;
            logic signed [2*WIDTH-1:0] mul_result_s;
            logic signed [2*WIDTH-1:0] mul_result_su;
            
            // Division results
            logic signed [WIDTH-1:0] div_result_s;
            logic [WIDTH-1:0] div_result_u;
            logic signed [WIDTH-1:0] rem_result_s;
            logic [WIDTH-1:0] rem_result_u;
            logic div_by_zero;
            logic div_overflow; 
            
            always_comb begin
                result = '0;
                flags = '0;
                div_by_zero = (op_b == 0);
                
                if (WIDTH == 64) begin
                    div_overflow = ($signed(op_a) == 64'sh8000_0000_0000_0000) && ($signed(op_b) == -64'sd1);
                end else begin
                    div_overflow = ($signed(op_a) == {1'b1, {(WIDTH-1){1'b0}}}) && ($signed(op_b) == -1);
                end
                
                case (alu_op)
                    ALU_MUL: begin
                        mul_result_u = op_a * op_b;
                        result = mul_result_u[WIDTH-1:0];
                    end
                    
                    ALU_MULH: begin
                        mul_result_s = $signed(op_a) * $signed(op_b);
                        result = mul_result_s[2*WIDTH-1:WIDTH];
                    end
                    
                    ALU_MULHSU: begin
                        mul_result_su = $signed(op_a) * $signed({1'b0, op_b});
                        result = mul_result_su[2*WIDTH-1:WIDTH];
                    end
                    
                    ALU_MULHU: begin
                        mul_result_u = op_a * op_b;
                        result = mul_result_u[2*WIDTH-1:WIDTH];
                    end
                    
                    ALU_DIV: begin
                        if (div_by_zero) begin
                            result = {WIDTH{1'b1}};
                            flags.divide_by_zero = 1'b1;
                        end else if (div_overflow) begin
                            result = op_a;
                            flags.overflow = 1'b1;
                        end else begin
                            div_result_s = $signed(op_a) / $signed(op_b);
                            result = div_result_s;
                        end
                    end
                    
                    ALU_DIVU: begin
                        if (div_by_zero) begin
                            result = {WIDTH{1'b1}};
                            flags.divide_by_zero = 1'b1;
                        end else begin
                            div_result_u = op_a / op_b;
                            result = div_result_u;
                        end
                    end
                    
                    ALU_REM: begin
                        if (div_by_zero) begin
                            result = op_a;
                            flags.divide_by_zero = 1'b1;
                        end else if (div_overflow) begin
                            result = '0;
                            flags.overflow = 1'b1;
                        end else begin
                            rem_result_s = $signed(op_a) % $signed(op_b);
                            result = rem_result_s;
                        end
                    end
                    
                    ALU_REMU: begin
                        if (div_by_zero) begin
                            result = op_a;
                            flags.divide_by_zero = 1'b1;
                        end else begin
                            rem_result_u = op_a % op_b;
                            result = rem_result_u;
                        end
                    end
                    
                    default: begin
                        flags.invalid_op = 1'b1;
                    end
                endcase
            end
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    valid <= 1'b0;
                end else begin
                    valid <= enable;
                end
            end
        end else begin : gen_no_muldiv
            always_comb begin
                result = '0;
                valid = 1'b0;
                flags.invalid_op = 1'b1;
            end
        end
    endgenerate

endmodule