// core/Register_File.sv
// -----------------------------------------------------------------------------
// 32 registers (x0-x31), two read ports, one write port
// Features:
//   - x0 hardwired to 0
//   - Write-back forwarding support for same-cycle reads
//   - Parameterized width and register count
//   - Optional synchronous reset (active-low)
// -----------------------------------------------------------------------------

module regfile #(
    parameter REG_WIDTH = 64,       
    parameter REG_COUNT = 32        
)(
    input  logic                 clk,         
    input  logic                 rst_n,       
    input  logic                 reg_write,   
    input  logic [4:0]           read_addr1,  
    input  logic [4:0]           read_addr2,  
    input  logic [4:0]           write_addr,  
    input  logic [REG_WIDTH-1:0] write_data,  
    output logic [REG_WIDTH-1:0] read_data1,  
    output logic [REG_WIDTH-1:0] read_data2   
);

    //Reg array
    logic [REG_WIDTH-1:0] regs [REG_COUNT-1:0];
    
    //Synchronous 
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            //init all reg to 0
            integer i;
            for (i = 0; i < REG_COUNT; i = i + 1)
                regs[i] <= '0;
        end
        else if (reg_write && write_addr != 5'd0) begin
            regs[write_addr] <= write_data;
        end
    end
    // Read ports with wb forward
    assign read_data1 = (read_addr1 == 5'd0) ? '0 :
                        (reg_write && read_addr1 == write_addr) ? write_data :
                        regs[read_addr1];
    assign read_data2 = (read_addr2 == 5'd0) ? '0 :
                        (reg_write && read_addr2 == write_addr) ? write_data :
                        regs[read_addr2];

endmodule
