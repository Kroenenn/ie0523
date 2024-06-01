/*

    Archivo: Tester.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 31 de mayo de 2024

    Descripción: Archivo que contiene el módulo Tester, el cual se encarga de generar las señales
    necesarias para probar el sistema de comunicación SPI que se implementará en la FPGA.

    El módulo Tester se encarga de generar las señales necesarias para probar el sistema de
    comunicación SPI. Estas señales son las siguientes:
    - start_transaction: Señal que indica al sistema que se debe iniciar una transacción.
    - CKP: Señal que indica el estado
    - CPH: Señal que indica el estado
    - CLK: Señal que indica el estado
    - Reset: Señal que indica el estado
    - SCK: Señal que indica el estado


*/

module Tester (
    output reg start_transaction,
    output reg CKP,
    output reg CPH,
    output reg CLK,
    output reg Reset,
    input wire SCK
);

// Secuencia de pruebas
initial begin
    // Inicialización
    CLK = 0;
    CKP = 0;
    CPH = 0;
    Reset = 0;
    start_transaction = 0;
    #20;

    // Estados de reposo
    Reset = 1;
    #28;

    //primer modo;
    CKP = 0;
    CPH = 1;
    #20;
    start_transaction = 1;
    #138;
    start_transaction = 0;
    #50;

    //Segundo modo
    CKP = 1;
    CPH = 0;
    #50;
    start_transaction = 1;
    #130;
    start_transaction = 0;
    #50;

    //Tercer modo
    CKP = 0;
    CPH = 0;
    #50;
    start_transaction = 1;
    #130;
    start_transaction = 0;
    #50;

    //Cuarto modo
    CKP = 1;
    CPH = 1;
    #50;
    start_transaction = 1;
    #138;
    start_transaction = 0;
    #50;

    //Estado de reposo
    CKP = 0; 
    #30; 
    CKP = 1; 
    #30; 
    CKP = 0; 
    #30; 
    CKP = 1; 

    // Fin del Testbench
    #50 $finish;
    end



    always begin
    #1 CLK = !CLK;
end

endmodule