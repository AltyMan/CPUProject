# ELEC 374 – CPU Design Project

## Project Directory Overview

```text
CPUProject/
├── README.md
├── SRC_ASM.py
├── core/
│   ├── Bus.v
│   ├── CONFF.v
│   ├── CONFF_logic.v
│   ├── DataPath.v
│   ├── SelectEncode.v
│   ├── control.v
│   ├── data.mem
│   ├── instructions.mem
│   ├── ram.v
│   ├── registers.v
│   ├── signext.v
│   └── alu/
│       ├── adder.v
│       ├── alu.v
│       ├── booth_tb.v
│       ├── booth_tb.vcd
│       ├── div.v
│       ├── helper.v
│       ├── logic.v
│       ├── mul.v
│       ├── neg.v
│       ├── rol.v
│       ├── ror.v
│       ├── shl.v
│       ├── shr.v
│       └── shra.v
├── dump/
├── phase1/
│   ├── p1tb.v
│   ├── p1tb.vcd
│   ├── p2tb.v
│   ├── p2tb.vcd
│   ├── p3tb.v
│   ├── p3tb.vcd
│   ├── p4tb.v
│   ├── p4tb.vcd
│   ├── p5tb.v
│   ├── p5tb.vcd
│   ├── p6tb.v
│   ├── p6tb.vcd
│   ├── p7tb.v
│   ├── p7tb.vcd
│   ├── p8tb.v
│   ├── p8tb.vcd
│   ├── p9tb.v
│   ├── p9tb.vcd
│   ├── p10tb.v
│   ├── p10tb.vcd
│   ├── p11tb.v
│   ├── p11tb.vcd
│   ├── p12tb.v
│   ├── p12tb.vcd
│   ├── p13tb.v
│   ├── p13tb.vcd
│   ├── template.v
│   ├── view_settings56.gtkw
│   ├── view_settings711.gtkw
│   ├── view_settings1213.gtkw
│   └── view_settings14.gtkw
├── phase2/
│   ├── p1tb.v
│   ├── p1tb.vcd
│   ├── p2tb.v
│   ├── p2tb.vcd
│   ├── p3tb.v
│   ├── p3tb.vcd
│   ├── p4tb.v
│   ├── p4tb.vcd
│   ├── p5tb.v
│   ├── p5tb.vcd
│   ├── p6tb.v
│   ├── p6tb.vcd
│   ├── p7tb.v
│   ├── p7tb.vcd
│   ├── view_settings1.gtkw
│   ├── view_settings2.gtkw
│   ├── view_settings3.gtkw
│   ├── view_settings4.gtkw
│   ├── view_settings5.gtkw
│   ├── view_settings6.gtkw
│   ├── view_settings7.gtkw
│   ├── alu/
│   │   ├── adder.v
│   │   ├── alu.v
│   │   ├── booth_tb.v
│   │   ├── booth_tb.vcd
│   │   ├── div.v
│   │   ├── helper.v
│   │   ├── logic.v
│   │   ├── mul.v
│   │   ├── neg.v
│   │   ├── rol.v
│   │   ├── ror.v
│   │   ├── shl.v
│   │   ├── shr.v
│   │   └── shra.v
│   └── core/
│       ├── Bus.v
│       ├── CONFF.v
│       ├── CONFF_logic.v
│       ├── DataPath.v
│       ├── SelectEncode.v
│       ├── ram.v
│       ├── registers.v
│       └── signext.v
├── phase3/
│   ├── instructions.mem
│   ├── instructions.s
│   ├── instructions.txt
│   └── tb.v
├── test_code/
│   ├── test_tb.v
│   └── tester.v
└── tutorial_code/
    ├── Bus.v
    ├── DataPath.v
    ├── adder.v
    ├── register.v
    ├── tutorial_tb.v
    └── tutorial_tb.vcd
```

Work Distribution: 
## Phase 1  
## Phase 2 

---

## Phase 1 – Datapath Foundations

### Fayez
- Designed and implemented the ALU (Arithmetic Logic Unit)
- Implemented:
  - ADD / SUB
  - AND / OR / NOT
  - Shift operations (SHL, SHR, SHRA)
  - Rotate operations (ROL, ROR)
  - NEG
- Verified ALU functionality using simulation
- Integrated ALU modules into top-level `alu.v`

### Yehia
- Designed and implemented:
  - Multiplication unit
  - Division unit
- Integrated MUL and DIV into the ALU structure

### Amit
- Designed and implemented:
  - Databus architecture
  - Register-to-bus connections
  - Core datapath wiring between modules
- Assisted in integrating registers and ALU into shared bus system

---

## Phase 2 – Completing the Mini SRC Datapath

### Fayez
- Implement:
  - Load and Store 
  - CONFF
  - Bus connection
  


### Yehia
- Work on:
  - Memory Subsystem integration
    - Memory module connections
  - Test Benches

### Amit
- Implement:
  - Update the bus connection
  - MAR/ MDR

