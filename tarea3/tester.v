/*
    Archivo: tester.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 13 de Abril de 2024

    Descripción: Tester .
*/

module Controller_bank_Tester(
    output reg CLK,
    output reg RESET,
    output reg TARJETA_RECIBIDA,
    output reg [15:0] PIN,
    output reg [3:0] DIGITO,
    output reg DIGITO_STB,
    output reg TIPO_TRANS,
    output reg [31:0] MONTO,
    output reg MONTO_STB,
    input wire BALANCE_ACTUALIZADO,
    input wire ENTREGAR_DINERO,
    input wire FONDOS_INSUFICIENTES,
    input wire PIN_INCORRECTO,
    input wire ADVERTENCIA,
    input wire BLOQUEO
);

    // Secuencia de pruebas
    initial begin
        // Inicialización
        CLK = 0;
        RESET = 1;
        PIN = 16'h8551;
        TARJETA_RECIBIDA = 0;
        DIGITO_STB = 0;
        MONTO_STB = 0;
        TIPO_TRANS = 0;
        #2 RESET = 0;

        // Caso 1: Inserción de tarjeta y Pin incorrecto una vez
        #2 TARJETA_RECIBIDA = 1;
        #4 DIGITO = 4'b1000; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b1111; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #20;

        // Caso 2: Inserción de tarjeta y Pin incorrecto dos veces (advertencia)
        #4 DIGITO = 4'b1000; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b1111; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #20;

        // Caso 3: Inserción de tarjeta y Pin incorrecto tres veces (bloqueo)
        #4 DIGITO = 4'b1000; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b1111; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #20;

        // Caso 4: Depósito exitoso con Pin correcto
        #2 RESET = 1;
        #2 RESET = 0;
        TARJETA_RECIBIDA = 1;
        #2 DIGITO = 4'b1000; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 TIPO_TRANS = 1;
        #4 MONTO = 32'hAAA0; MONTO_STB = 1; #2 MONTO_STB = 0;
        #10;
        TARJETA_RECIBIDA = 0;
        #10;

        // Caso 5: Retiro exitoso con Pin correcto
        TARJETA_RECIBIDA = 1;
        #4 DIGITO = 4'b1000; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 TIPO_TRANS = 0;
        #4 MONTO = 32'h0000_0080; MONTO_STB = 1; #2 MONTO_STB = 0;
        #3;
        #10;
        TARJETA_RECIBIDA = 0;
        #15;

        // Caso 6: Retiro con fondos insuficientes con Pin correcto
        TARJETA_RECIBIDA = 1;
        #4 DIGITO = 4'b1000; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 TIPO_TRANS = 0;
        #4 MONTO = 32'hFFFF_FFFF; 
        #2 MONTO_STB = 1; #2 MONTO_STB = 0; 
        #10;
        TARJETA_RECIBIDA = 0;
        #10;

        // Caso 7: Reset del sistema
        RESET = 1;
        #10 RESET = 0; TARJETA_RECIBIDA = 0;
        #20;

        // Fin del Testbench
        #100 $finish;
    end

    always begin
        #1 CLK = !CLK;
    end

endmodule
