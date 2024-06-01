/*

    Archivo: Testbench.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 31 de mayo de 2024

    Descripción: Archivo que contiene el testbench para el sistema de comunicación SPI
    que se implementará en la FPGA. Este testbench se encarga de instanciar los módulos
    necesarios para la comunicación SPI y de generar las señales necesarias para probar
    el sistema.

    El testbench se encarga de instanciar los siguientes módulos:
    - Master: Módulo que se encarga de transmitir datos a los slaves.
    - Tester: Módulo que se encarga de generar las señales necesarias para probar el sistema.
    - Slave: Módulo que se encarga de recibir los datos transmitidos por el master.


*/


`include "Master.v"
`include "Tester.v"
`include "Slave.v"
module Testbench (
    input wire start_transaction,
    input wire CKP,
    input wire CPH,
    input wire CLK,
    input wire Reset,
    input wire MISO,
    input wire MOSI,
    input wire SCK,
    input wire CS,
    input wire SS
);

initial begin
$dumpfile("test.vcd");
$dumpvars;
end
wire MISO_to_slave2; // Señal de MISO para el segundo slave
wire MISO_to_slave3; // Señal de MISO para el tercer slave
wire CS_to_SS; // Señal de CS para el slave select

master_transmisor maestro (
    .start_transaction(start_transaction),
    .CKP(CKP),
    .CPH(CPH),
    .CLK(CLK),
    .Reset(Reset),
    .MISO(MISO),
    .MOSI(MOSI),
    .SCK(SCK),
    .CS(CS_to_SS)
);

Tester probador (
    .start_transaction(start_transaction),
    .CKP(CKP),
    .CPH(CPH),
    .CLK(CLK),
    .Reset(Reset),
    .SCK(SCK)
);

// Primer slave
slave_receptor slave1 (
    .start_transaction(start_transaction),
    .CKP(CKP),
    .CPH(CPH),
    .MISO(MISO_to_slave2), 
    .MOSI(MOSI),
    .SCK(SCK),
    .SS(CS_to_SS),
    .CLK(CLK)
);

//Segundo slave
slave_receptor slave2 (
    .start_transaction(start_transaction),
    .CKP(CKP),
    .CPH(CPH),
    .MISO(MISO_to_slave3), 
    .MOSI(MISO_to_slave2), 
    .SCK(SCK),
    .SS(CS_to_SS),
    .CLK(CLK)
);

//Tercer slave
slave_receptor slave3 (
    .start_transaction(start_transaction),
    .CKP(CKP),
    .CPH(CPH),
    .MISO(MISO),            
    .MOSI(MISO_to_slave3),  
    .SCK(SCK),
    .SS(CS_to_SS),
    .CLK(CLK)
);


endmodule