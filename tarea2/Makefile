# Archivo: Makefile
# Autor: Oscar Porras Silesky C16042
# Fecha: 13 de Abril de 2024

# Descripción: Este archivo contiene las reglas para compilar, simular y sintetizar el diseño de la tarea 2.

# Definir las variables de los comandos del simulador y el sintetizador
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave
YOSYS = yosys

# Nombres de los archivos
TESTBENCH = testbench.v
TESTBENCH_RETARDO = testbench_retardo.v
TESTER = tester.v

DESIGN_FILES = pruebas.v
SYNTH_FILES = both_synth.v
RTLIL_FILES = both_RTLIL.v

# Simulacion del archivo conductual
EXECUTABLE1 = simulation1

# Simulacion del archivo RTLIL
EXECUTABLE2 = simulation2

# Simulacion del archivo sintetizado
EXECUTABLE3 = simulation3

# Simulacion del archivo sintetizado con retardo
EXECUTABLE_RETARDO = simulation_retardo

WAVEFILE_CONDUCTUAL = test.vcd
WAVEFILE_RTLIL = test.vcd
WAVEFILE_SYNTH = test.vcd
WAVEFILE_RETARDO = test_retardo.vcd

GTKWCONFIG = C16042gtkwaveTarea2.gtkw

# Script de Yosys
YOSYS_SCRIPT = synthesis.ys

# Regla por defecto
all: view_conductual view_RTLIL view_synth view_retardo

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

$(EXECUTABLE_RETARDO): $(TESTBENCH_RETARDO) $(SYNTH_FILES) $(TESTER)
	$(IVERILOG) -o $(EXECUTABLE_RETARDO) $(TESTBENCH_RETARDO) $(SYNTH_FILES) $(TESTER)

# Ejecutar el simulador para generar el archivo wave para cada versión
wave_conductual: $(EXECUTABLE1)
	$(VVP) $(EXECUTABLE1)

wave_RTLIL: $(EXECUTABLE2)
	$(VVP) $(EXECUTABLE2) 

wave_synth: $(EXECUTABLE3)
	$(VVP) $(EXECUTABLE3) 

wave_retardo: $(EXECUTABLE_RETARDO)
	$(VVP) $(EXECUTABLE_RETARDO)

# Abrir el visor de ondas con los resultados de la simulación
view_conductual: wave_conductual
	$(GTKWAVE) $(WAVEFILE_CONDUCTUAL) $(GTKWCONFIG)

view_RTLIL: wave_RTLIL
	$(GTKWAVE) $(WAVEFILE_RTLIL) $(GTKWCONFIG)

view_synth: wave_synth
	$(GTKWAVE) $(WAVEFILE_SYNTH) $(GTKWCONFIG)

view_retardo: wave_retardo
	$(GTKWAVE) $(WAVEFILE_RETARDO) $(GTKWCONFIG)

# Limpiar archivos generados durante la compilación y simulación
clean:
	rm -f $(EXECUTABLE1) $(EXECUTABLE2) $(EXECUTABLE3) $(EXECUTABLE_RETARDO)
	rm -f $(WAVEFILE_CONDUCTUAL) $(WAVEFILE_RTLIL) $(WAVEFILE_SYNTH) $(WAVEFILE_RETARDO)
	rm -f $(RTLIL_FILES) $(SYNTH_FILES)

# Reglas que no corresponden a archivos
.PHONY: all clean wave_conductual wave_RTLIL wave_synth wave_retardo
.PHONY: view_conductual view_RTLIL view_synth view_retardo