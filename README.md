# MIPS Pipelined CPU

A 32-bit MIPS processor written in Verilog, with the classic five-stage
pipeline: fetch, decode, execute, memory, write-back.

It exists twice. One version resolves data hazards in hardware by forwarding,
the other by stalling. Building both meant the two strategies could run the
same program and be compared directly instead of argued about.

On the six-instruction test program in `imem.v`, the forwarding design writes
its last result on cycle 10 and the stalling design on cycle 16. Both end with
identical register contents. The gap is the six cycles of bubbles that
forwarding avoids.

```
IF  ->  IF/ID  ->  ID  ->  ID/EX  ->  EX  ->  EX/MEM  ->  MEM  ->  MEM/WB  ->  WB
pc                 control           alu                 dmem                write
imem               regfile           alucontrol                              back
```

`forwarding/` bypasses the EX/MEM and MEM/WB results back into the ALU inputs
through two three-way muxes, so a dependent instruction never waits.

`hazard-stall/` detects the same dependency one stage earlier, then freezes the
PC and the IF/ID register and zeroes every control signal, turning the
instruction in decode into a bubble until the value lands.

## Run

Needs [Icarus Verilog](https://steveicarus.github.io/iverilog/), plus
[GTKWave](https://gtkwave.sourceforge.net/) to look at the waveforms.

```
brew install icarus-verilog gtkwave     # macOS
sudo apt install iverilog gtkwave       # Debian, Ubuntu
```

Simulate either variant:

```
cd forwarding          # or: cd hazard-stall
iverilog -o top top_tb.v
vvp top
```

That writes `top.vcd`. Open it with `gtkwave top.vcd`.

`forwarding/` also holds unit benches for the register file, instruction
memory, data memory and sign extender:

```
iverilog -o regfile.vvp regfile_tb.v && vvp regfile.vvp
```

## Scope

Decodes `add`, `sub`, `and`, `or`, `addi`, `lw`, `sw`, `beq` and `j`.
Instruction and data memory are 256 words each.

Only data hazards are handled in hardware. Branches resolve in MEM and nothing
flushes the instructions already fetched behind them, so branching programs
still need nop padding. `forwarding/imem_nop.v` is that baseline: a loop with
every hazard spaced out in software, which is what the two detection units
replace.

## License

MIT. See [LICENSE](LICENSE).
