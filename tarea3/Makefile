# Variables
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
YOSYS = yosys
OUTFILE = ondas

# Nombres de los archivos
TESTBENCH = testbench.v
TESTER = tester.v

DESIGN_FILES = pruebas.v
SYNTH_FILES = synth.v
RTLIL_FILES = RTLIL.v

# Simulacion del archivo conductual
EXECUTABLE1 = simulation1

# Simulacion del archivo RTLIL
EXECUTABLE2 = simulation2

# Simulacion del archivo sintetizado
EXECUTABLE3 = simulation3

WAVEFILE_CONDUCTUAL = ondas.vcd
WAVEFILE_RTLIL = ondas.vcd
WAVEFILE_SYNTH = ondas.vcd

GTKWCONFIG = gtkwaveconfig.gtkw

# Script de Yosys
YOSYS_SCRIPT = synthesis.ys

# Instrucciones
# Compila todo
all: view_conductual view_RTLIL view_synth

# Síntesis con Yosys
synth:
	$(YOSYS) -s synthesis.ys

# Compila los archivos Verilog
# Sintetizar el diseño
$(SYNTH_FILES) $(RTLIL_FILES): $(DESIGN_FILES)
	$(YOSYS) -s $(YOSYS_SCRIPT)

# Compilar los testbenches
$(EXECUTABLE1): $(TESTBENCH) $(DESIGN_FILES) $(TESTER)
	$(IVERILOG) -o $(EXECUTABLE1) $(TESTBENCH) $(DESIGN_FILES) $(TESTER)

$(EXECUTABLE2): $(TESTBENCH) $(RTLIL_FILES) $(TESTER)
	$(IVERILOG) -o $(EXECUTABLE2) $(TESTBENCH) $(RTLIL_FILES) $(TESTER)

$(EXECUTABLE3): $(TESTBENCH) $(SYNTH_FILES) $(TESTER)
	$(IVERILOG) -o $(EXECUTABLE3) $(TESTBENCH) $(SYNTH_FILES) $(TESTER)


# Ejecutar el simulador para generar el archivo wave para cada versión
wave_conductual: $(EXECUTABLE1)
	$(VVP) $(EXECUTABLE1)

wave_RTLIL: $(EXECUTABLE2)
	$(VVP) $(EXECUTABLE2) 

wave_synth: $(EXECUTABLE3)
	$(VVP) $(EXECUTABLE3) 

# Abrir el visor de ondas con los resultados de la simulación
view_conductual: wave_conductual
	$(GTKWAVE) $(WAVEFILE_CONDUCTUAL) $(GTKWCONFIG)

view_RTLIL: wave_RTLIL
	$(GTKWAVE) $(WAVEFILE_RTLIL) $(GTKWCONFIG)

view_synth: wave_synth
	$(GTKWAVE) $(WAVEFILE_SYNTH) $(GTKWCONFIG)

# Limpia los archivos generados
# Limpiar archivos generados durante la compilación y simulación
clean:
	rm -f $(EXECUTABLE1) $(EXECUTABLE2) $(EXECUTABLE3) $(EXECUTABLE_RETARDO)
	rm -f $(WAVEFILE_CONDUCTUAL) $(WAVEFILE_RTLIL) $(WAVEFILE_SYNTH) $(WAVEFILE_RETARDO)
	rm -f $(RTLIL_FILES) $(SYNTH_FILES)

# Reglas que no corresponden a archivos
.PHONY: all clean wave_conductual wave_RTLIL wave_synth wave_retardo
.PHONY: view_conductual view_RTLIL view_synth view_retardo
