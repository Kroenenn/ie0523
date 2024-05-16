`timescale 1s / 1ps

/*
    Archivo: testbench.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 1 de mayo de 2024

    Descripción: Testbench para el sistema de control de acceso de una compuerta de estacionamiento.
*/

`include "cmos_cells.v"

module Testbench_banco;

    // Señales generadas por el tester
    wire CLK;
    wire RESET;
    wire TARJETA_RECIBIDA;
    wire [15:0] PIN;
    wire [3:0] DIGITO;
    wire DIGITO_STB;
    wire TIPO_TRANS;
    wire [31:0] MONTO;
    wire MONTO_STB;
    wire BALANCE_ACTUALIZADO;
    wire ENTREGAR_DINERO;
    wire FONDOS_INSUFICIENTES;
    wire PIN_INCORRECTO;
    wire ADVERTENCIA;
    wire BLOQUEO;

    initial begin
        $dumpfile("ondas.vcd");
        $dumpvars(0, Testbench_banco);
    end

    // Instanciación del controlador del cajero automático
    ATMController controlador_banco (
        .CLK(CLK),
        .RESET(RESET),
        .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
        .PIN(PIN),
        .DIGITO(DIGITO),
        .DIGITO_STB(DIGITO_STB),
        .TIPO_TRANS(TIPO_TRANS),
        .MONTO(MONTO),
        .MONTO_STB(MONTO_STB),
        .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
        .ENTREGAR_DINERO(ENTREGAR_DINERO),
        .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES),
        .PIN_INCORRECTO(PIN_INCORRECTO),
        .ADVERTENCIA(ADVERTENCIA),
        .BLOQUEO(BLOQUEO)
    );

    // Instanciación del tester
    Controller_bank_Tester controlador_tester (
        .CLK(CLK),
        .RESET(RESET),
        .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
        .PIN(PIN),
        .DIGITO(DIGITO),
        .DIGITO_STB(DIGITO_STB),
        .TIPO_TRANS(TIPO_TRANS),
        .MONTO(MONTO),
        .MONTO_STB(MONTO_STB),
        .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
        .ENTREGAR_DINERO(ENTREGAR_DINERO),
        .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES),
        .PIN_INCORRECTO(PIN_INCORRECTO),
        .ADVERTENCIA(ADVERTENCIA),
        .BLOQUEO(BLOQUEO)
    );
endmodule
