/*

    Archivo: I2C_slave.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 17 de junio de 2024

    Descripción: Archivo que contiene el módulo slave_i2c, el cual se encarga de recibir los datos
    de los masters a través del sistema de comunicación I2C.

    El módulo slave_i2c se encarga de recibir los datos de los masters a través del sistema de comunicación
    I2C. Este módulo se encarga de recibir los datos de los masters y de transmitir los datos solicitados
    por los masters.

*/

// Declaracion de variables
module slave_i2c(
    input wire CLK,         
    input wire RESET,       
    output SDA_IN,    
    input wire SDA_OE,      
    input wire [15:0] Rd_data_slave,
    output reg [15:0] Wr_data_slave, 
    input wire [6:0] I2c_addr_slave, 
    input wire SDA_OUT,      
    input wire SCL
    );

// Parametros para la maquina de estados
parameter START = 4'b0001; 
parameter COMPARING_ADDRESS = 4'b0010;
parameter WRITE = 4'b0100;
parameter READ = 4'b1000;

//Contador de bits
reg [3:0] Bit_counter;

// Señal para el estado actual de la máquina de estados
reg [3:0] actual_state, next_state;

// Señal para almacenar la dirección comparada y la próxima dirección a comparar
reg [6:0] Compare_address, Prox_compare_address;

// Señal para el próximo valor de SDA
reg Prox_sdain;

// Señal para el próximo dato a escribir en el esclavo
reg [15:0] Prox_wr_data_slave; 

// Señal para el número de transacciones
reg number_transaction = 0; 

// Señal para SDA de entrada
wire SDA_IN;

// Asignar el valor negado de sdain a SDA_IN
assign SDA_IN = ~sdain;

// Señal para SDA interna
reg sdain;

// Bloque siempre activado por el flanco positivo de CLK
always @(posedge CLK) begin
    // Si se activa la señal de reset, establecer el estado actual a START
    if (!RESET) begin 
        actual_state <= START;
    end else begin
        // De lo contrario, actualizar el estado actual al siguiente estado
        actual_state <= next_state;
    end
    
    // Si el estado actual es START, inicializar la dirección comparada a 0
    if (actual_state == START) begin
        Compare_address <= 16'b0000000000000000;
    end
end

// Bloque siempre activado por el flanco positivo de SCL
always @(posedge SCL) begin
    // Si se activa RESET, se reinician los contadores y señales a cero
    if (!RESET) begin
        Bit_counter <= 0;
        Compare_address <= 0; 
        sdain <= 0; 
        Wr_data_slave <= 0; 
    end else begin      
        // De lo contrario, se incrementa el contador de bits y se actualizan las señales intermedias
        Bit_counter <= Bit_counter + 1;
        Compare_address <= Prox_compare_address;
        sdain <= Prox_sdain;
        Wr_data_slave <= Prox_wr_data_slave;
    end
end 

// Logica combinacional
always @(*) begin
    // Inicializar el siguiente estado con el estado actual
    next_state = actual_state;

    // Inicializar la próxima señal de SDA con la señal de SDA actual
    Prox_sdain = sdain; 

    // Inicializar la próxima dirección a comparar con la dirección comparada actual
    Prox_compare_address = Compare_address;

    // Inicializar los próximos datos a escribir con los datos a escribir actuales
    Prox_wr_data_slave = Wr_data_slave;

    // Comienzo de la maquina de estados
    case (actual_state)
        // Comienza el estado 0001
        // Este estado es el encargado de manejar la lógica de inicio
        // cuando termina se va al estado de comparación de direcciones

        START: begin 
            sdain = 0; 
            number_transaction = 0; 
            if (SCL == 1 && SDA_OUT == 0) begin // Si SCL es 1 y SDA_OUT es 0, se cumple la condición de inicio
                Bit_counter = 0; 
                next_state = COMPARING_ADDRESS; 
            end
        end
        // Comienza el estado 0010
        // Este estado es el encargado de manejar la lógica de comparación
        // de direcciones, cuando termina se va a los estados de escritura o lectura

        COMPARING_ADDRESS: begin
            // La linea de abajo se encarga de comparar la dirección del slave con la dirección recibida
            if (SDA_OE == 1 && Compare_address != I2c_addr_slave) begin
                // Si es así, se incrementa el contador de bits y se actualiza la próxima dirección a comparar
                if (Bit_counter <= 7)begin
                    Prox_compare_address = {Compare_address, SDA_OUT};
                end
            end  
            // Si la dirección del slave es igual a la dirección recibida, se cumple la condición
            if (Compare_address == I2c_addr_slave && Bit_counter == 4'b1001) begin 
                // Si SDA_OUT es 0, se va al estado de escritura
                if (SDA_OUT == 0) begin
                    next_state = WRITE;
                    Bit_counter = 0; 
                end
                // Si SDA_OUT es 1, se va al estado de lectura
                if (SDA_OUT == 1) begin
                    next_state = READ;
                    sdain = 1; // Se establece sdain en 1 ya que es un estado de lectura 
                    Bit_counter = 0; 
                end
            end
            // Si la dirección del slave es diferente a la dirección recibida, se vuelve al estado de inicio
            // y se reinician los contadores
            if (Compare_address != I2c_addr_slave && Bit_counter == 4'b1001) begin
                next_state = START;
            end
        end
        // Comienza el estado 0100
        // Este estado es el encargado de manejar los valores en
        // el estado de escritura, cuando termina vuelve al inicio

        WRITE: begin 
            // La linea valida si Bit_counter es igual a 0, si es así, se establece sdain en 1
            if (Bit_counter == 4'b0000) begin
                sdain = 1; 
            end else begin
                sdain = 0; 
            end
            // La línea valida si Bit_counter es menor a 9 y number_transaction es igual a 0
            // Si es así, se concatenan los valores de Wr_data_slave y SDA_OUT
            if (Bit_counter < 4'b1001 && number_transaction == 0) begin
                Prox_wr_data_slave = {Wr_data_slave, SDA_OUT};
            end
            // La linea valida si Bit_counter es menor a 9 y number_transaction es igual a 1
            // Si es así, se concatenan los valores de Wr_data_slave y SDA_OUT
            if (Bit_counter < 4'b1001 && number_transaction == 1 && Bit_counter > 4'b0000) begin
                Prox_wr_data_slave = {Wr_data_slave, SDA_OUT};
            end
            // La linea valida si Bit_counter es igual a 9 y number_transaction es igual a 0
            if (Bit_counter == 4'b1001) begin
                // sdain se establece en 1 aqúi ya que es un estado de escritura 
                sdain = 1;
                // Si number_transaction es igual a 0, se reinician los contadores y se establece number_transaction en 1
                if (number_transaction == 0) begin
                    Bit_counter = 0;
                    number_transaction = 1; 
                end
                // Si SCL es 1, number_transaction es igual a 1, SDA_OUT es igual a 1, se vuelve al estado de inicio
                if (SCL == 1 && SDA_OUT == 1 && number_transaction == 1) begin
                    next_state = START; 
                end
            end
        end
        // Comienza el estado 1000
        // Este estado es el encargado de manejar los valores en
        // el estado de lectura, cuando termina vuelve al inicio

        READ: begin
            // La linea valida si Bit_counter es menor a 9 y number_transaction es igual a 0 y Bit_counter es mayor a 0
            if (Bit_counter < 4'b1001 && number_transaction == 0 && Bit_counter > 4'b0000) begin
                sdain = Rd_data_slave[16-Bit_counter];  // Esto lo que hace es que se lea el dato de la dirección del slave
                                                        // para que se pueda leer el dato de la dirección del master
            end
            // La linea valida si Bit_counter es menor a 9 y number_transaction es igual a 1
            if (Bit_counter < 4'b1001 && number_transaction == 1) begin
                sdain = Rd_data_slave[8-Bit_counter]; // Esto lo que hace es que se lea el dato de la dirección del slave
                                                      // para que se pueda leer el dato de la dirección del master
            end
            // Si se llega a Bit_counter igual a 9,
            if (Bit_counter == 4'b1001) begin
                // y que number_transaction sea igual a 0, se reinician los contadores y se establece number_transaction en 1
                if (number_transaction == 0) begin
                    Bit_counter = 0;
                    number_transaction = 1;
                end
            end
            // Si Bit_counter es igual a 9, number_transaction es igual a 1, SCL es igual a 1 y SDA_OUT es igual a 1
            // se vuelve al estado de inicio
            if (Bit_counter == 4'b1001 && number_transaction == 1) begin
                    if (SCL == 1 && SDA_OUT == 1 && number_transaction == 1) begin
                        next_state = START; 
                    end
            end
        end
    endcase
end

endmodule