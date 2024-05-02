`timescale 1s / 1ps

// Inlclusion de cmos_cells.v
`include "cmos_cells.v"

/*
    Archivo: testbench.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 1 de mayo de 2024

    Descripción: Testbench para el sistema de control de acceso de una compuerta de estacionamiento.
*/

module testbench;
    // Se declaran las señales como wires que conectan el tester con el sistema.
    reg clock, reset;
    wire [7:0] P;
    wire sensor_arrival;
    wire sensor_parked;
    wire p_enter;
    wire S_L;
    wire A_P;
    wire G_O;
    wire G_C;
    wire B;
    wire A_B;

    // Se instancia el probador
    tester probador(
        .P(P),
        .sensor_arrival(sensor_arrival),
        .sensor_parked(sensor_parked),
        .p_enter(p_enter)
    );

    // Se instancia el sistema de pruebas
    passwordSystem sistema_password(
        .clock(clock),
        .reset(reset),
        .P(P),
        .sensor_arrival(sensor_arrival),
        .sensor_parked(sensor_parked),
        .p_enter(p_enter),
        .S_L(S_L),
        .A_P(A_P)
    );

    // Se instancia el sistema de compuerta
    gateSystem sistema_gate(
        .clock(clock),
        .reset(reset),
        .S_L(S_L),
        .sensor_arrival(sensor_arrival),
        .sensor_parked(sensor_parked),
        .G_O(G_O),
        .G_C(G_C),
        .B(B),
        .A_B(A_B)
    );

    // Generación de la onda de reloj
    initial clock = 0;
    always #2.5 clock = ~clock; // Genera una onda cuadrada

    // Inicio de la simulación y creación de archivo de ondas
    initial begin
        $dumpfile("test.vcd"); // Nombre del archivo VCD
        $dumpvars(0, testbench); // Se usa 0 para guardar todas las variables, y testbench para guardar las variables del módulo testbench

        reset = 1; // Activamos el reset al comienzo de la simulación
        #5; // Esperamos un tiempo para que tome efecto el reset
        reset = 0; // Desactivamos el reset para continuar con la simulación

        // Esperar 100,000 nanosegundos antes de finalizar la simulación
        #10000;
        $finish; // Finaliza la simulación
    end

endmodule