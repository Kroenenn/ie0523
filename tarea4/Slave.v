/*

    Archivo: Slave.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 31 de mayo de 2024

    Descripción: Archivo que contiene el módulo Slave, el cual se encarga de recibir los datos
    transmitidos por el Master a través del sistema de comunicación SPI.

    El módulo Slave se encarga de recibir los datos transmitidos por el Master a través del sistema
    de comunicación SPI. Este módulo se encarga de recibir los datos transmitidos por el Master y de
    enviar los datos solicitados por el Master.

*/

module slave_receptor (
    input wire start_transaction,
    input wire CKP,
    input wire CPH,
    input wire MOSI,
    input wire SCK,
    output reg MISO,
    input wire SS,
    input wire CLK
);
reg [1:0] actual_state, next_state; // Esto es para el estado actual y el siguiente
reg [15:0] Data_register, Prox_Data_register; // Esto es para el registro de datos actual y el siguiente
reg [7:0] Data1 = 8'b00000100; // Datos de prueba
reg [7:0] Data2 = 8'b00000010;
reg data_begin_data_register = 0; // Bandera para saber si se ha cargado el registro de datos
reg [4:0] Bit_counter; // Contador de bits
wire chosen_SCK; // Esta es la señal de reloj escogida
wire [1:0] MODO; // Modo de operación
wire end_protocol; // Bandera para saber si se ha terminado el protocolo
assign end_protocol = Bit_counter == 5'b10001; // Se termina el protocolo cuando se llega al limite
assign MODO = {CKP, CPH}; // Se asigna el modo de operación
assign chosen_SCK = (MODO == 0 || MODO == 3) ? SCK : ~SCK; // Se escoge el reloj, se utiliza el reloj normal si el modo es 0 o 3, de lo contrario se utiliza el inverso

parameter IDLE = 2'b00;
parameter TRANSACTION_PROCESS = 2'b01;

// Control de estados y preparación de datos usando CLK
always @(posedge CLK) begin
        //FLIP-FLOPS
        Prox_Data_register = Data_register; // Cargar datos de Data_register en Prox_Data_register, esto es para preparar el próximo dato
        next_state = actual_state; // Cargar el estado actual en el siguiente estado, esto es para mantener el estado actual

        case(actual_state)
            IDLE: begin
                Bit_counter = 0; 
                if (start_transaction && SS == 0) begin // Esta condicion evalua si se ha iniciado una transacción y si el SS está activo
                    next_state = TRANSACTION_PROCESS; 
                end else begin
                    next_state = IDLE;
                end
            end
            TRANSACTION_PROCESS: begin
                if (Bit_counter == 0) begin
                    MISO = Data_register[15]; // Establecer MISO directamente desde Data_register, ya que el primer bit es el más significativo
                end else begin
                    MISO = Data_register[15]; // Establecer MISO directamente desde Data_register
                    Prox_Data_register = {Data_register, MOSI}; // En este caso se prepara el próximo dato porque ya se ha establecido el MISO
                end
                if (end_protocol && SS == 1) begin // Esta condición evalua si se ha terminado el protocolo y si el SS está inactivo
                    next_state = IDLE; // Se regresa al estado IDLE
                    Bit_counter = 0; // Se reinicia el contador de bits
                end
            end
        endcase

end

// Manejo de datos en chosen_SCK
always @(posedge chosen_SCK) begin
    if (start_transaction == 0) begin // Si no se ha iniciado una transacción se reinicia el contador de bits
        actual_state <= IDLE;
        Bit_counter <= 0;
        MISO <= 0;
        if (data_begin_data_register == 0) begin // Si no se ha cargado el registro de datos se carga con los datos de prueba Data1 y Data2
            Data_register <= {Data1, Data2};
            data_begin_data_register <= 1; 
        end
    end else begin
        actual_state <= TRANSACTION_PROCESS; // Si se ha iniciado una transacción se cambia al estado TRANSACTION_PROCESS
        Data_register <= Prox_Data_register;  // Cargar datos de Prox_Data_register
        MISO <= Prox_Data_register[15];  // Establecer MISO directamente desde Prox_Data_register
        Prox_Data_register <= {Prox_Data_register[14:0], MOSI};  // Preparar próximo dato
        Bit_counter <= Bit_counter + 1;
        if (end_protocol && SS == 1) begin // Si se ha terminado el protocolo y el SS está inactivo se regresa al estado IDLE
            actual_state <= IDLE;
            Bit_counter <= 0;
        end
    end
end

endmodule