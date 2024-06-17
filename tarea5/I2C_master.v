/*

    Archivo: I2C_master.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 17 de junio de 2024

    Descripción: Archivo que contiene el módulo master_i2c, el cual se encarga de transmitir los datos
    a los slaves a través del sistema de comunicación I2C.

    El módulo master_i2c se encarga de transmitir los datos a los slaves a través del sistema de comunicación
    I2C. Este módulo se encarga de transmitir los datos a los slaves y de recibir los datos solicitados
    por los slaves.

*/


// Declaracion de variables 
module master_i2c (
    input wire CLK,
    input wire RESET,
    input wire RNW,
    input wire [6:0] I2c_addr_master,
    input wire [15:0] Wr_data_master,
    output reg [15:0] Rd_data_master,  
    input wire START_STB,
    output reg SDA_OUT,
    output reg SDA_OE,
    input wire SDA_IN,
    output reg SCL
);

// Variables utilizadas en la maquina de estados

// Señal para el estado actual de la máquina de estados
reg [5:0] actual_state, next_state;  

// Señal para el próximo valor de SDA
reg Prox_SDA_out, Prox_SDA_oe;

// Señal para el próximo dato a escribir en el maestro
reg [15:0] Prox_rd_data_master;

// Parametros utilizados en la maquina de estados
parameter Start_IDLE = 6'b000001;
parameter Confirm_address = 6'b000010;
parameter Waiting_received_writing = 6'b000100;
parameter Waiting_received_reading = 6'b001000;
parameter WRITE = 6'b010000; 
parameter READ = 6'b100000;

// Count clock se utiliza para manejar el reloj de las transacciones
reg [1:0] Count_clock;

// Variables intermedias utilizadas para terminar las transacciones
reg [3:0] Bit_counter;
reg number_transaction = 0; 


// Esta parte de la maquina de estados se activa por el flanco positivo de CLK
// y se encarga de actualizar el estado actual y el contador de clock
always @(posedge CLK) begin
    // Cuando se activa START_STB, se establece SDA_OUT en Prox_SDA_out
    if (START_STB) begin
        SDA_OUT = Prox_SDA_out;
    end
    // Si se activa RESET, se establece el estado actual en Start_IDLE y el contador de clock en 0
    if (RESET == 1'b0) begin 
        actual_state <= Start_IDLE;
        Count_clock <= 0;
    // De lo contrario, se actualiza el estado actual al siguiente estado y se incrementa el contador de clock
    end else begin
        actual_state <= next_state;
        Count_clock <= Count_clock + 1;
    end
end


// Esta parte de la maquina de estados se activa por el flanco positivo de SCL
// y se encarga de actualizar las señales de salida
always @(posedge SCL) begin
    // Si se activa RESET o START_STB, se establecen las variables en 0
   if (!RESET || START_STB) begin
     Bit_counter <= 0; 
     SDA_OE     <= 1;
     SDA_OUT <= 0;
     Rd_data_master <= 0; 
    // De lo contrario, se incrementa el contador de bits y se actualizan las señales de salida
   end else begin
     Bit_counter <= Bit_counter + 1; 
     SDA_OUT    <= Prox_SDA_out;
     SDA_OE     <= Prox_SDA_oe;
     Rd_data_master <= Prox_rd_data_master;
   end
 end


// Logica combinacional
always @(*) begin
    next_state = actual_state;
    Prox_SDA_oe = SDA_OE; 
    Prox_SDA_out = SDA_OUT;
    Prox_rd_data_master = Rd_data_master;

    // Comienzo de la maquina de estados

    case (actual_state)
        // Comienzo del estado 000001
        // En este caso se inicializan las variables y se espera el Start_stb
        // para comenzar la transaccion
        Start_IDLE: begin 
            SCL = 1; 
            Prox_SDA_oe = 1; 
            SDA_OUT = 1; 
            Bit_counter = 0; 
            number_transaction = 0; 
            // Si se activa START_STB, se establece SDA_OUT en 0 y se cambia al estado Confirm_address
            if (START_STB) begin 
                SDA_OUT = 0;  
                next_state = Confirm_address; 
            // De lo contrario, se mantiene en el estado Start_IDLE
            end else begin
                next_state = Start_IDLE; 
            end
        end
        // Comienzo del estado 000010
        // En este estado se confirma la direccion del slave y se espera el recibido
        // para comenzar la transaccion

        Confirm_address: begin 
            // Se establece el reloj derivado de Count_clock en SCL y se activa SDA_OE
            SCL = Count_clock[1];
            SDA_OE = 1; 
            // Si el contador de bits es menor o igual a 6, se establece Prox_SDA_out en la direccion del master
            if (Bit_counter <= 6) begin
                 Prox_SDA_out = I2c_addr_master[6-Bit_counter];
            end
            // Si el contador de bits es igual a 7, se establece Prox_SDA_out en RNW
            // RNW se usa para determinar si la transaccion es de lectura o escritura
            if (Bit_counter == 7) begin
                Prox_SDA_out = RNW;
            end
            // Si el contador de bits es igual a 8 y RNW es 0, se cambia al estado Waiting_received_writing
            if (!RNW && Bit_counter == 8) begin 
                next_state = Waiting_received_writing;    
            end 
            // Si el contador de bits es igual a 8 y RNW es 1, se cambia al estado Waiting_received_reading
            if (RNW && Bit_counter == 8) begin
                next_state = Waiting_received_reading;
            end 
        end
        // Comienzo del estado 000100
        // En este estado se espera el recibido de escritura para comenzar la escritura
        Waiting_received_writing: begin 
            Bit_counter = 0; 
            SCL = Count_clock[1];
            Prox_SDA_oe = 0;
            // Si SDA_IN es 0, se cambia al estado WRITE
            if (SDA_IN == 0) begin
                next_state = WRITE;
                Bit_counter = 0; 
            end
            // Si el contador de bits es igual a 15 y SDA_IN es 1, se cambia al estado Start_IDLE
            if (Bit_counter == 4'b1111 && SDA_IN == 1) begin
                next_state = Start_IDLE;
            end
        end
        // Comienzo del estado 001000
        // En este estado se espera el recibido de lectura para comenzar la lectura

        Waiting_received_reading: begin 
            SCL = Count_clock[1];
            Prox_SDA_oe = 0;
            // Si SDA_IN es 0, se cambia al estado READ
            if (SDA_IN == 0) begin
                next_state = READ;
                Bit_counter = 0; 
            end
            // Si el contador de bits es igual a 15 y SDA_IN es 1, se cambia al estado Start_IDLE
            if (Bit_counter == 4'b1111 && SDA_IN == 1) begin
                next_state = Start_IDLE;
            end
        end
        // Comienzo del estado 010000
        // En este estado se comienza la escritura de datos
        WRITE: begin 
            SCL = Count_clock[1];
            // Si el contador de bits es igual a 8 y number_transaction es 0, Prox_SDA_oe se establece en 0
            if (Bit_counter == 4'b1000 && number_transaction == 0) begin
                Prox_SDA_oe = 0;
            // De lo contrario, Prox_SDA_oe se establece en 1
            end else begin
                Prox_SDA_oe = 1;
            end
            // Si el contador de bits es menor a 8 y number_transaction es 0, se concatenan los valores de Wr_data_master en Prox_SDA_out
            // en ese caso se usa 15 - Bit_counter para que se pueda leer el dato de la dirección del slave
            if (Bit_counter < 4'b1000 && number_transaction == 0) begin
                Prox_SDA_out = Wr_data_master[15-Bit_counter];
            end
            // Si el contador de bits es menor a 8 y number_transaction es 1, se concatenan los valores de Wr_data_master en Prox_SDA_out
            // en ese caso se usa 7 - Bit_counter para que se pueda leer el dato de la dirección del slave, no se usa 15 
            // porque ya se leyó el dato de la dirección del slave
            if (Bit_counter < 4'b1000 && number_transaction == 1) begin
                Prox_SDA_out = Wr_data_master[7-Bit_counter];
            end
            // Si el contador de bits es igual a 9 y number_transaction es 0, se reinician los contadores y se establece number_transaction en 1
            if (Bit_counter == 4'b1001 && number_transaction == 0) begin 
                if (SDA_IN == 0) begin
                    Bit_counter = 0; 
                    number_transaction = 1; 
                end
            end
            // Si SCL es 1, number_transaction es 1, Bit_counter es 9 y SDA_IN es 0, se cambia al estado Start_IDLE
            if (SCL == 1 && number_transaction == 1 && Bit_counter == 4'b1001 && SDA_IN == 0) begin
                    SCL = 1; 
                    SDA_OUT =1;
                    next_state = Start_IDLE;
                    SDA_OE = 0; 
            end
        end
        // Comienzo del estado 100000
        // En este estado se comienza la lectura de datos
        READ: begin  
            SCL = Count_clock[1];
            // Si el contador de bits es igual a 8, Prox_SDA_oe se establece en 1 y Prox_SDA_out en 0
            if (Bit_counter == 4'b1000) begin
                Prox_SDA_out = 0;
                Prox_SDA_oe = 1;
            // De lo contrario, Prox_SDA_out se establece en 1 y Prox_SDA_oe en 0
            end else begin
                Prox_SDA_out = 1;
                Prox_SDA_oe = 0; 
            end
            // Si el contador de bits es menor a 9, number_transaction es 0 y Bit_counter es mayor a 0, se concatenan los valores de Rd_data_master en Prox_rd_data_master
            // Se usa ~SDA_IN para que se pueda leer el dato de la dirección del master
            if (Bit_counter < 4'b1001 && number_transaction == 0 && Bit_counter > 4'b0000) begin
                Prox_rd_data_master = {Rd_data_master, ~SDA_IN};
            end
            // Si el contador de bits es menor a 9, number_transaction es 1 y Bit_counter es mayor a 0, se concatenan los valores de Rd_data_master en Prox_rd_data_master
            // Se usa ~SDA_IN para que se pueda leer el dato de la dirección del master
            if (Bit_counter < 4'b1001 && number_transaction == 1 && Bit_counter > 4'b0000) begin
                Prox_rd_data_master = {Rd_data_master, ~SDA_IN};
            end
            // Si el contador de bits es igual a 9 y number_transaction es 0, se reinician los contadores y se establece number_transaction en 1
            if (Bit_counter == 4'b1001) begin
                Prox_SDA_out = 1;  
                if (number_transaction == 0) begin
                    Bit_counter = 0;
                    number_transaction = 1; 
                end
                // Si SCL es 1, number_transaction es igual a 1, y Bit_counter es igual a 9, se cambia al estado Start_IDLE
                if (SCL == 1 && number_transaction == 1 && Bit_counter == 4'b1001) begin
                    SCL = 1; 
                    Prox_SDA_out =1;
                    next_state = Start_IDLE;
                end
            end
        end
    endcase
end

endmodule