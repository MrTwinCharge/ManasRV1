// core/ALU.sv
// -----------------------------------------------------------------------------
// 32 registers (x0-x31), two read ports, one write port
// Features:
//   - x0 hardwired to 0
//   - Write-back forwarding support for same-cycle reads
//   - Parameterized width and register count
//   - Optional synchronous reset (active-low)
// -----------------------------------------------------------------------------