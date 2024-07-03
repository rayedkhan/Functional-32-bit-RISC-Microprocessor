`include "adder.v"
`include "alu.v"
`include "alucontrol.v"
`include "control.v"
`include "dmem.v"
`include "hazard.v"
`include "imem.v"
`include "mux.v"
`include "pc.v"
`include "regfile.v"
`include "register.v"
`include "registerfd.v"
`include "signextend.v"
`include "sll2.v"
`include "hazardDetectionUnit.v"

module Top(clk);

input wire clk;

// fetch

wire [31:0] pc;
wire [31:0] pc4;
wire [31:0] instruction;
wire [31:0] mux_jump_out;
wire hazard;

PC pc_block(clk, !hazard, mux_jump_out, pc);
Adder adder4(pc, 4, pc4);
Imem imem(pc, instruction);


// fetch-decode
wire [31:0] pc4_fd;
wire [31:0] instruction_fd;

Register_stall r1 (clk, !hazard, pc4, pc4_fd);
Register_stall r2 (clk, !hazard, instruction, instruction_fd);

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

wire c_reg_dst;
wire c_jump;
wire c_branch;
wire c_mem_read;
wire c_mem_to_reg;
wire [1:0] c_alu_op;
wire c_mem_write;
wire c_alu_src;
wire c_reg_write;

Control control(instruction_fd[31:26], c_reg_dst, c_jump, c_branch, c_mem_read, c_mem_to_reg, c_alu_op, c_mem_write, c_alu_src, c_reg_write);

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

Register r3 (clk, pc4_fd, pc4_dx);

Mux #(1) temp1 (hazard, c_reg_dst, 1'b0, reg_dst);
Mux #(1) temp2 (hazard, c_jump, 1'b0, jump);
Mux #(1) temp3 (hazard, c_branch, 1'b0, branch);
Mux #(1) temp4 (hazard, c_mem_read, 1'b0, mem_read);
Mux #(1) temp5 (hazard, c_mem_to_reg, 1'b0, mem_to_reg);
Mux #(2) temp6 (hazard, c_alu_op, 2'b00, alu_op);
Mux #(1) temp7 (hazard, c_mem_write, 1'b0, mem_write);
Mux #(1) temp8 (hazard, c_alu_src, 1'b0, alu_src);
Mux #(1) temp9 (hazard, c_reg_write, 1'b0, reg_write);

Register #(1) r4 (clk, reg_dst   , reg_dst_dx);
Register #(1) r5 (clk, branch    , branch_dx);
Register #(1) r6 (clk, mem_read  , mem_read_dx);
Register #(1) r7 (clk, mem_to_reg, mem_to_reg_dx);
Register #(2) r8(clk, alu_op    , alu_op_dx);
Register #(1) r9 (clk, mem_write , mem_write_dx);
Register #(1) ra (clk, alu_src   , alu_src_dx);
Register #(1) rb (clk, reg_write , reg_write_dx);
Register      rc (clk, imm       , imm_dx);
Register      rd (clk, rs_value  , rs_value_dx);
Register      re (clk, rt_value  , rt_value_dx);
Register #(5) rf (clk, instruction_fd[20:16], rt_address_dx);
Register #(5) rg (clk, instruction_fd[15:11], rd_address_dx);

Register #(5) rw (clk, instruction_fd[25:21], rs_address_dx);


// execute

wire [4:0] rd_address;
wire [3:0] op;
wire [31:0] alu_b;
wire [31:0] alu_result;
wire zero;
wire [31:0] simm;
wire [31:0] branch_address;

Mux #(5) mux_regfile (reg_dst_dx, rt_address_dx, rd_address_dx, rd_address);
AluControl alucontrol(alu_op_dx, imm_dx[5:0], op);
Mux mux_alu(alu_src_dx, rt_value_dx, imm_dx, alu_b);
Alu alu(op, rs_value_dx, alu_b, alu_result, zero);
Sll2 sll_imm(imm_dx, simm);
Adder adderimm(pc4_dx, simm, branch_address);


// execute-memory

wire branch_xm;
wire mem_read_xm;
wire mem_to_reg_xm;
wire mem_write_xm;
wire reg_write_xm;
wire [31:0] branch_address_xm;
wire zero_xm;
wire [31:0] alu_result_xm;
wire [4:0] rd_address_xm;
wire [31:0] rt_value_xm;

Register #(1) rh (clk, branch_dx     , branch_xm);
Register #(1) ri (clk, mem_read_dx   , mem_read_xm);
Register #(1) rj (clk, mem_to_reg_dx , mem_to_reg_xm);
Register #(1) rk (clk, mem_write_dx  , mem_write_xm);
Register #(1) rl (clk, reg_write_dx  , reg_write_xm);
Register      rm (clk, branch_address, branch_address_xm);
Register #(1) rn (clk, zero          , zero_xm);
Register      ro (clk, alu_result    , alu_result_xm);
Register #(5) rp (clk, rd_address    , rd_address_xm);
Register      rq (clk, rt_value_dx   , rt_value_xm);


// memory

wire pc_src;
wire [31:0] mux_branch_out;
wire [31:0] read_data;

assign pc_src = branch_xm & zero_xm;
Mux mux_branch(pc_src, pc4, branch_address_xm, mux_branch_out);
Mux mux_jump(jump, mux_branch_out, jump_address, mux_jump_out);
Dmem dmem(clk, alu_result_xm, rt_value_xm, mem_read_xm, mem_write_xm, read_data);


// memory - write-back

wire mem_to_reg_mw;
wire [31:0] alu_result_mw;
wire [31:0] read_data_mw;

Register #(1) rr (clk, mem_to_reg_xm , mem_to_reg_mw);
Register #(1) rs (clk, reg_write_xm  , reg_write_mw);
Register      rt (clk, alu_result_xm , alu_result_mw);
Register      ru (clk, read_data     , read_data_mw);
Register #(5) rv (clk, rd_address_xm , rd_address_mw);


// write-back

Mux mux_mem(mem_to_reg_mw, alu_result_mw, read_data_mw, rd_value);

hazardDetectionUnit Haz(reg_write_xm, reg_write_mw, rd_address_xm, rd_address_mw, instruction_fd[25:21], instruction_fd[20:16], hazard);

endmodule
