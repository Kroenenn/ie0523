/*
    Archivo: tester.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 18 de mayo de 2024

    Descripción: Tester que se encarga de probar el módulo ATMController
    de la tarea 3 de IE0523. Este módulo se encarga de simular el funcionamiento
    de un cajero automático, el cual recibe una tarjeta, un pin y una transacción
    (retiro o depósito) y se encarga
    de realizar la transacción correspondiente. Si el pin es incorrecto, se
    permite un máximo de 3 intentos, luego de los cuales se bloquea la tarjeta.
    Se puede realizar un retiro de dinero, en cuyo caso se verifica que el monto
    a retirar no sea mayor al balance actual. Si el monto a retirar es mayor al
    balance, se activa la señal de FONDOS_INSUFICIENTES. Si el monto a retirar
    es menor o igual al balance, se resta el monto al balance y se activa la señal
    de ENTREGAR_DINERO. También se puede realizar un depósito de dinero, en cuyo
    caso se suma el monto al balance y se activa la señal de ENTREGAR_DINERO.
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
    // Recordar que RESET == 0 aplica el reset al sistema
    initial begin
        // Inicialización
        CLK = 0;
        RESET = 0;
        PIN = 16'h1525;
        TARJETA_RECIBIDA = 0;
        DIGITO_STB = 0;
        MONTO_STB = 0;
        TIPO_TRANS = 1;
        MONTO = 32'h0000_0000;
        DIGITO = 4'b0000;
        #2 RESET = 1;


    // Prueba 1: Inserción de tarjeta y Pin incorrecto una vez, dos veces y tres veces
        // Caso 1: Inserción de tarjeta y Pin incorrecto una vez
        #2 TARJETA_RECIBIDA = 1;
        #4 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0010; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b1111; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #20;

        // Caso 2: Inserción de tarjeta y Pin incorrecto dos veces (advertencia)
        #4 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0010; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b1111; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #20;

        // Caso 3: Inserción de tarjeta y Pin incorrecto tres veces (bloqueo)
        #4 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0010; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b1111; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #20;

    // Prueba 2: Depósito de dinero
        #2 RESET = 0;
        #2 RESET = 1;
        TARJETA_RECIBIDA = 1;
        #2 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0010; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 TIPO_TRANS = 0;
        #4 MONTO = 32'hAAA0; MONTO_STB = 1; #2 MONTO_STB = 0;
        #10;
        TARJETA_RECIBIDA = 0;
        #10;

    // Prueba 3: Retiro de dinero
        TARJETA_RECIBIDA = 1;
        #4 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0010; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 TIPO_TRANS = 1;
        #4 MONTO = 32'h0000_0080; MONTO_STB = 1; #2 MONTO_STB = 0;
        #3;
        #10;
        TARJETA_RECIBIDA = 0;
        #15;

    // Prueba 4: Retiro con fondos insuficientes
        TARJETA_RECIBIDA = 1;
        #4 DIGITO = 4'b0001; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0010; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 DIGITO = 4'b0101; DIGITO_STB = 1; #2 DIGITO_STB = 0;
        #2 TIPO_TRANS = 1;
        #4 MONTO = 32'hFFFF_FFFF; 
        #2 MONTO_STB = 1; #2 MONTO_STB = 0; 
        #10;
        TARJETA_RECIBIDA = 0;
        #10;

    // Reset del sistema
        RESET = 0;
        #10 RESET = 1; TARJETA_RECIBIDA = 0;
        #20;

        // Fin del Testbench
        #100 $finish;
    end

    always begin
        #1 CLK = !CLK;
    end

endmodule
