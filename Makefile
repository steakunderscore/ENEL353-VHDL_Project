# Makefile automatically generated by ghdl
# Version: GHDL 0.29 (20100109) [Sokcho edition] - GCC back-end code generator
# Command used to generate this makefile:
# /usr/lib/ghdl/bin/ghdl --gen-makefile --ieee=mentor alu_tb

GHDL=ghdl
GHDLFLAGS= --ieee=mentor

# Default target
all: alu_tb alu buses cpu IO microprocessor mmu

.PHONY: cleanall
cleanall: clean
	rm -f alu_tb alu gpr_tb gpr spr_tb spr

.PHONY: clean
clean:
	rm -f *.o

# Elaboration target
alu_tb: alu.o alu_tb.o
	$(GHDL) -e $(GHDLFLAGS) $@

alu: alu.o
	$(GHDL) -e $(GHDLFLAGS) $@

buses: buses.o
	$(GHDL) -e $(GHDLFLAGS) $@

cpu: cpu.o
	$(GHDL) -e $(GHDLFLAGS) $@

gpr_tb: gpr.o gpr_tb.o
	$(GHDL) -e $(GHDLFLAGS) $@

gpr: gpr.o
	$(GHDL) -e $(GHDLFLAGS) $@

IO: IO.o
	$(GHDL) -e $(GHDLFLAGS) $@

microprocessor: microprocessor.o
	$(GHDL) -e $(GHDLFLAGS) $@

mmu: mmu.o
	$(GHDL) -e $(GHDLFLAGS) $@

spr_tb: spr.o spr_tb.o
	$(GHDL) -e $(GHDLFLAGS) $@

spr: spr.o
	$(GHDL) -e $(GHDLFLAGS) $@

# Targets to analyze files
alu_tb.o: processor/alu_tb.vhd alu.o
	$(GHDL) -a $(GHDLFLAGS) $<

alu.o: processor/alu.vhd numeric_std.o
	$(GHDL) -a $(GHDLFLAGS) $<

buses.o: buses.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

cpu.o: processor/cpu.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

gpr_tb.o: processor/gpr_tb.vhd gpr.o
	$(GHDL) -a $(GHDLFLAGS) $<

gpr.o: processor/gpr.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

IO.o: IO.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

numeric_std.o: processor/numeric_std.vhdl
	$(GHDL) -a $(GHDLFLAGS) $<

microprocessor.o: microprocessor.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

mmu.o: mmu.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

spr_tb.o: processor/spr_tb.vhd spr.o
	$(GHDL) -a $(GHDLFLAGS) $<

spr.o: processor/spr.vhd
	$(GHDL) -a $(GHDLFLAGS) $<

