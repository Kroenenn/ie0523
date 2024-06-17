/*

    Archivo: Testbench.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 17 de junio de 2024

    Descripción: Archivo que contiene el módulo Testbench, el cual se encarga de conectar el correcto
    funcionamiento de los módulos I2C_master y I2C_slave.

    El módulo Testbench se encarga de conectar el correcto funcionamiento de los módulos I2C_master y I2C_slave.
    Este módulo se encarga de conectar el correcto funcionamiento de los módulos I2C_master y I2C_slave,
    enviando datos de un módulo a otro y verificando que los datos sean recibidos correctamente.

*/



`include "I2C_master.v"
`include "Tester.v"
`include "I2C_slave.v"

// Declaracion de entradas, salidas, wires y regs
module Testbench (
    input wire CLK,
    input wire RESET,
    input wire RNW,
    input wire [6:0] I2c_addr_master,
    input wire [6:0] I2c_addr_slave,
    input wire [15:0] Wr_data_master,
    input wire [15:0] Rd_data_slave,
    input wire START_STB,
    input wire SDA_OUT,
    input wire SDA_OE,
    input wire SDA_IN,
    input wire SCL
);

initial begin
    $dumpfile("test.vcd");
    $dumpvars;
end

// Instancias de módulos, el transmisor, receptor y tester
master_i2c I2c_transmisor (
    .CLK(CLK),
    .RESET(RESET),
    .RNW(RNW),
    .I2c_addr_master(I2c_addr_master),
    .Wr_data_master(Wr_data_master),
    .START_STB(START_STB),
    .SDA_OUT(SDA_OUT),
    .SDA_OE(SDA_OE),
    .SDA_IN(SDA_IN),
    .SCL(SCL)
);

Tester probador (
    .CLK(CLK),
    .RESET(RESET),
    .RNW(RNW),
    .I2c_addr_master(I2c_addr_master),
    .I2c_addr_slave(I2c_addr_slave),
    .Wr_data_master(Wr_data_master),
    .Rd_data_slave(Rd_data_slave),
    .START_STB(START_STB),
    .SDA_OE(SDA_OE),
    .SDA_IN(SDA_IN),
    .SCL(SCL)
);

slave_i2c I2c_receptor (
    .CLK(CLK),
    .RESET(RESET),
    .I2c_addr_slave(I2c_addr_slave),
    .Rd_data_slave(Rd_data_slave),
    .SDA_OUT(SDA_OUT),
    .SDA_OE(SDA_OE),
    .SDA_IN(SDA_IN),
    .SCL(SCL)
);

endmodule