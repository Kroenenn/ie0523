/*

    Archivo: Tester.v
    Autor: Oscar Porras Silesky C16042

    Descripción: Archivo que contiene el módulo Tester, el cual se encarga de probar el correcto
    funcionamiento del módulo I2C_slave.

    El módulo Tester se encarga de probar el correcto funcionamiento del módulo I2C_slave.
    Este módulo se encarga de probar el correcto funcionamiento del módulo I2C_slave,
    enviando datos de un módulo a otro y verificando que los datos sean recibidos correctamente.

*/


module Tester (
    output reg CLK,
    output reg RESET,
    output reg RNW,
    output reg [6:0] I2c_addr_master,
    output reg [6:0] I2c_addr_slave,
    output reg [15:0] Wr_data_master,
    output reg [15:0] Rd_data_slave,
    output reg START_STB,
    input wire SDA_OE,
    input wire SDA_IN,
    input wire SCL
);

// Inicialización de las señales
initial begin
    CLK = 0;
    RESET = 1;
    RNW = 0;
    I2c_addr_master = 7'b0101010;
    I2c_addr_slave = 7'b0101010;
    Wr_data_master = 16'b1010101010101010;
    Rd_data_slave = 16'b0000000000000000;
    START_STB = 0;
    
    // PRUEBA #1:
    // Se aplican los valores de RESET y se espera un tiempo
    // para que el módulo se inicialice. Luego se aplica el
    // START_STB y se espera un tiempo para que el módulo
    // pueda responder. Se prueba el modo de escritura.
    #10 RESET = 0;
    #10 RESET = 1;
    #10; 
    START_STB = 1;
    RNW = 0;
    #2 START_STB = 0; 
    #400; 

    // PRUEBA #2:
    // Se aplica el START_STB y se espera un tiempo para que
    // el módulo pueda responder. Se prueba el modo de lectura.
    START_STB = 1;
    RNW = 1;
    #2 START_STB = 0;
    #400;

    // PRUEBA #3:
    // Se aplica el START_STB y se espera un tiempo para que
    // el módulo pueda responder. Se prueba que se responda correctamente
    // cuando la dirección del master no coincide con la dirección del slave.
    I2c_addr_master = 7'b1111111;
    START_STB = 1;
    RNW = 1;
    #2 START_STB = 0;

    // Finaliza la simulación luego de 500 unidades de tiempo
    #500 $finish;  
end

// Generador de reloj
always begin
    #1 CLK = ~CLK;
end

endmodule