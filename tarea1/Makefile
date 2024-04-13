#   Archivo: Makefile
#    Autor: Oscar Porras Silesky C16042
#    Fecha: 13 de Abril de 2024

#    Descripción: Este archivo contiene las reglas para compilar y simular el diseño de la tarea 1.


# Definir las variables de los comandos del simulador
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Definir el nombre del archivo testbench y del ejecutable de simulación
TESTBENCH = testbench.v
TESTER = tester.v
DESIGN = pruebas.v
EXECUTABLE = simulation
WAVEFILE = test.vcd
GTKWCONFIG = C16042gtkwaveTarea1.gtkw

# Lista de archivos de dependencia
DEPENDENCIES = $(DESIGN) $(TESTBENCH) $(TESTER)

# Regla por defecto para hacer todo
all: view

# Compilar el testbench y crear el ejecutable de simulación
$(EXECUTABLE): $(DEPENDENCIES)
	$(IVERILOG) -o $(EXECUTABLE) $(TESTBENCH) $(DESIGN) $(TESTER)

# Ejecutar el simulador para generar el archivo wave
wave: $(EXECUTABLE)
	$(VVP) $(EXECUTABLE)

# Abre el visor de ondas con los resultados de la simulación usando el archivo de configuración
view: wave
	$(GTKWAVE) $(WAVEFILE) $(GTKWCONFIG)

# Limpiar archivos generados durante la compilación y simulación
clean:
	rm -f $(EXECUTABLE) $(WAVEFILE)

# Reglas que no corresponden a archivos
.PHONY: all wave view clean
