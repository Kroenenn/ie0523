IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
OUTFILE = test
VERILOG_FILES = Testbench.v

# Instrucciones
all:
	$(IVERILOG) -o  $(OUTFILE) $(VERILOG_FILES)
	$(VVP) $(OUTFILE)
	$(GTKWAVE) test.vcd gtkwaveconfig.gtkw

# Compila los archivos Verilog
compile:
	$(IVERILOG) -o $(OUTFILE) $(VERILOG_FILES)

# Ejecuta la simulación
run: 
	$(VVP) $(OUTFILE)

# Abre la onda generada en GTKWave
gtkwave:
	$(GTKWAVE) test.vcd gtkwaveconfig.gtkw

# Limpia los archivos generados
clean:
	rm -f $(OUTFILE) test.vcd test

.PHONY: all compile run wave clean