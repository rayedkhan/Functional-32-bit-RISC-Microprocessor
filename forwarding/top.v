`include "adder.v"
`include "alu.v"
`include "alucontrol.v"
`include "control.v"
`include "dmem.v"
`include "forward.v"
`include "imem.v"
`include "mux.v"
`include "muxfwd.v"
`include "pc.v"
`include "regfile.v"
`include "register.v"
`include "signextend.v"
`include "sll2.v"
`include "forwardingDetectionUnit.v"

module Top(clk);

input wire clk;

// fetch

wire [31:0] pc;
wire [31:0] pc4;
wire [31:0] instruction;
wire [31:0] mux_jump_out;


PC pc_block(clk, mux_jump_out, pc);
Adder adder4(pc, 4, pc4);
Imem imem(pc, instruction);


// fetch-decode
wire [31:0] pc4_fd;
wire [31:0] instruction_fd;

Pipe r1 (clk, pc4, pc4_fd);
Pipe r2 (clk, instruction, instruction_fd);

// decode

wire reg_dst;
wire jump;
wire branch;
wire mem_read;
wire mem_to_reg;
wire [1:0] alu_op;
wire mem_write;
wire alu_src;
wire reg_write;
wire [31:0] imm;
wire [31:0] rs_value;
wire [31:0] rt_value;
wire [27:0] jump_address28;
wire [31:0] jump_address;
wire reg_write_mw;
wire [4:0] rd_address_mw;
wire [31:0] rd_value;

Control control(instruction_fd[31:26], reg_dst, jump, branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write);

SignExtend signextend(instruction_fd[15:0], imm);
RegisterFile regfile(clk, instruction_fd[25:21], instruction_fd[20:16], rd_address_mw, rd_value, reg_write_mw, rs_value, rt_value);
Sll2 #(26,28) sll_jump(instruction_fd[25:0], jump_address28);
assign jump_address = { pc4_fd[31:28], jump_address28[27:0] };

// decode-execute

wire [31:0] pc4_dx;
wire reg_dst_dx;
wire branch_dx;
wire mem_read_dx;
wire mem_to_reg_dx;
wire [1:0] alu_op_dx;
wire mem_write_dx;
wire alu_src_dx;
wire reg_write_dx;
wire [31:0] imm_dx;
wire [31:0] rs_value_dx;
wire [31:0] rt_value_dx;
wire [4:0] rt_address_dx;
wire [4:0] rd_address_dx;
wire [4:0] rs_address_dx;

Pipe r3 (clk, pc4_fd, pc4_dx);

Pipe #(1) r4 (clk, reg_dst   , reg_dst_dx);
Pipe #(1) r5 (clk, branch    , branch_dx);
Pipe #(1) r6 (clk, mem_read  , mem_read_dx);
Pipe #(1) r7 (clk, mem_to_reg, mem_to_reg_dx);
Pipe #(2) r8(clk, alu_op    , alu_op_dx);
Pipe #(1) r9 (clk, mem_write , mem_write_dx);
Pipe #(1) ra (clk, alu_src   , alu_src_dx);
Pipe #(1) rb (clk, reg_write , reg_write_dx);
Pipe      rc (clk, imm       , imm_dx);
Pipe      rd (clk, rs_value  , rs_value_dx);
Pipe      re (clk, rt_value  , rt_value_dx);
Pipe #(5) rf (clk, instruction_fd[20:16], rt_address_dx);
Pipe #(5) rg (clk, instruction_fd[15:11], rd_address_dx);

Pipe #(5) rw (clk, instruction_fd[25:21], rs_address_dx);


// execute

wire [4:0] rd_address;
wire [3:0] op;
wire [31:0] mux_alu_b;
wire [31:0] alu_A;
wire [31:0] alu_B;
wire [31:0] alu_result;
wire zero;
wire [31:0] simm;
wire [31:0] branch_address;
wire [1:0] forward_A;
wire [1:0] forward_B;
wire [31:0] alu_result_xm;
wire [4:0] rd_address_xm;
wire reg_write_xm;
wire [31:0] mux_alu_b_xm;

Mux #(5) mux_regfile (reg_dst_dx, rt_address_dx, rd_address_dx, rd_address);
forwardingDetectionUnit fwd(reg_write_xm, reg_write_mw, rs_address_dx, rt_address_dx, rd_address_xm, rd_address_mw, 
                                forward_A, forward_B);

MuxFwd mux_alu_A(forward_A, rs_value_dx, rd_value, alu_result_xm, alu_A);
MuxFwd mux_alu_B(forward_B, rt_value_dx, rd_value, alu_result_xm, mux_alu_b);
Mux mux_alu(alu_src_dx, mux_alu_b, imm_dx, alu_B);


AluControl alucontrol(alu_op_dx, imm_dx[5:0], op);
Alu alu(op, alu_A, alu_B, alu_result, zero);
Sll2 sll_imm(imm_dx, simm);
Adder adderimm(pc4_dx, simm, branch_address);


// execute-memory

wire branch_xm;
wire mem_read_xm;
wire mem_to_reg_xm;
wire mem_write_xm;
wire [31:0] branch_address_xm;
wire zero_xm;

Pipe #(1) rh (clk, branch_dx     , branch_xm);
Pipe #(1) ri (clk, mem_read_dx   , mem_read_xm);
Pipe #(1) rj (clk, mem_to_reg_dx , mem_to_reg_xm);
Pipe #(1) rk (clk, mem_write_dx  , mem_write_xm);
Pipe #(1) rl (clk, reg_write_dx  , reg_write_xm);
Pipe      rm (clk, branch_address, branch_address_xm);
Pipe #(1) rn (clk, zero          , zero_xm);
Pipe      ro (clk, alu_result    , alu_result_xm);
Pipe #(5) rp (clk, rd_address    , rd_address_xm);
Pipe      rq (clk, mux_alu_b   , mux_alu_b_xm);


// memory

wire pc_src;
wire [31:0] mux_branch_out;
wire [31:0] read_data;

assign pc_src = branch_xm & zero_xm;
Mux mux_branch(pc_src, pc4, branch_address_xm, mux_branch_out);
Mux mux_jump(jump, mux_branch_out, jump_address, mux_jump_out);
Dmem dmem(clk, alu_result_xm, mux_alu_b_xm, mem_read_xm, mem_write_xm, read_data);


// memory - write-back

wire mem_to_reg_mw;
wire [31:0] alu_result_mw;
wire [31:0] read_data_mw;

Pipe #(1) rr (clk, mem_to_reg_xm , mem_to_reg_mw);
Pipe #(1) rs (clk, reg_write_xm  , reg_write_mw);
Pipe      rt (clk, alu_result_xm , alu_result_mw);
Pipe      ru (clk, read_data     , read_data_mw);
Pipe #(5) rv (clk, rd_address_xm , rd_address_mw);


// write-back

Mux mux_mem(mem_to_reg_mw, alu_result_mw, read_data_mw, rd_value);

endmodule
