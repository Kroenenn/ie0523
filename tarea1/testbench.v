`timescale 1ns / 1ps

/*
    Archivo: testbench.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 13 de Abril de 2024

    Descripción: Testbench para el sistema de control de acceso de una compuerta de estacionamiento.
*/

module testbench;
    // Se declaran las señales como wires que conectan el tester con el sistema
    wire [7:0] P;
    wire reset;
    wire sensor_arrival;
    wire sensor_parked;
    wire p_enter;
    wire S_L;
    wire A_P;
    wire G;
    wire B;
    wire A_B;

    // Se instancia el probador
    tester probador(
        .P(P),
        .reset(reset),
        .sensor_arrival(sensor_arrival),
        .sensor_parked(sensor_parked),
        .p_enter(p_enter)
    );

    // Se instancia el sistema de pruebas
    passwordSystem sistema_password(
        .P(P),
        .reset(reset),
        .sensor_arrival(sensor_arrival),
        .sensor_parked(sensor_parked),
        .p_enter(p_enter),
        .S_L(S_L),
        .A_P(A_P)
    );

    // Se instancia el sistema de compuerta
    gateSystem sistema_gate(
        .S_L(S_L),
        .sensor_arrival(sensor_arrival),
        .sensor_parked(sensor_parked),
        .G(G),
        .B(B),
        .A_B(A_B)
    );

    // Inicio de la simulación y creación de archivo de ondas
    initial begin
        $dumpfile("test.vcd");  // Nombre del archivo VCD
        $dumpvars(0, testbench);  // Se usa 0 para guardar todas las variables, y testbench para guardar las variables del módulo testbench
        
        // Esperar 100,000 nanosegundos antes de finalizar la simulación
        #100000;
        $finish;  // Finaliza la simulación
    end

endmodule