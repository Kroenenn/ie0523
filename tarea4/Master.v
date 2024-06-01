/*

    Archivo: Master.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 31 de mayo de 2024

    Descripción: Archivo que contiene el módulo Master, el cual se encarga de transmitir los datos
    a los slaves a través del sistema de comunicación SPI.

    El módulo Master se encarga de transmitir los datos a los slaves a través del sistema de comunicación
    SPI. Este módulo se encarga de transmitir los datos a los slaves y de recibir los datos solicitados
    por los slaves.

*/

module master_transmisor (
    input wire start_transaction,
    input wire CKP,
    input wire CPH,
    input wire CLK,
    input wire Reset,
    input wire MISO,
    output reg MOSI,
    output reg SCK,
    output reg CS
);
reg [1:0] actual_state, next_state; // Esto es para el estado actual y el siguiente
reg [15:0] Data_register, Prox_Data_register; // Esto es para el registro de datos actual y el siguiente
reg [7:0] Data1 = 8'b00000110, Data1_newdata; // Datos de prueba
reg [7:0] Data2 = 8'b00000000, Data2_newdata;
reg [4:0] Bit_counter; // Contador de bits
wire end_protocol; // Bandera para saber si se ha terminado el protocolo
assign end_protocol = Bit_counter == 5'b10001; // Se termina el protocolo cuando se llega al limite
wire chosen_SCK; // Esta es la señal de reloj escogida
wire [1:0] MODO; // Modo de operación
assign MODO = {CKP, CPH}; // Se asigna el modo de operación
assign chosen_SCK = (MODO == 0 || MODO == 3) ? SCK : ~SCK; // Se escoge el reloj, se utiliza el reloj normal si el modo es 0 o 3, de lo contrario se utiliza el inverso


// Generacion de el reloj de 1/4 de frecuencia
reg CLK_div2;
reg [1:0] Count_clock;

parameter IDLE = 2'b00;
parameter TRANSACTION_PROCESS = 2'b01;

always @(posedge CLK) begin
    if (Reset == 1) begin  // Funcionamiento normal cuando Reset es alto
        actual_state <= next_state; // Actualizar el estado actual
        CLK_div2 <= ~CLK_div2; // Generar un reloj de 1/4 de frecuencia
        Count_clock <= Count_clock + 1; // Contar los ciclos de reloj
    end else begin  // Resetear todo cuando Reset es bajo
        actual_state <= IDLE;
        CLK_div2 <= 0;
        Count_clock <= 0;
        Data_register <= {Data1, Data2};
        MOSI <= 0;
        Bit_counter <= 0;
    end
end 
always @(posedge chosen_SCK) begin // Manejo de datos en chosen_SCK, esto es para el envio de datos
    if (start_transaction == 0) begin // Si no se ha iniciado una transacción se reinicia el contador de bits
        Bit_counter <= 0; 
    end else begin
        Bit_counter <= Bit_counter + 1; // Se incrementa el contador de bits
        Data_register <= Prox_Data_register; // Se carga el próximo dato en el registro de datos
    end
end

always @(*) begin // Esto es para el control de estados y preparación de datos usando CLK
    Prox_Data_register = Data_register; // Cargar datos de Data_register en Prox_Data_register, esto es para preparar el próximo dato
    next_state = actual_state; // Cargar el estado actual en el siguiente estado, esto es para mantener el estado actual

    case(actual_state) // Caso para el control de estados
        IDLE: begin
            Data1_newdata = Data_register[15:8]; // Se cargan los datos de prueba en Data1_newdata y Data2_newdata
            Data2_newdata = Data_register[7:0]; // Esto es para poder modificar los datos de prueba
            Bit_counter = 0;  // Se reinicia el contador de bits
            CS = 1; // Se activa el CS
            if (CKP) begin // Se activa el reloj de acuerdo al modo de operación
                SCK = 1;
            end else begin
                SCK = 0;
            end
            if (start_transaction && end_protocol == 0) begin // Esta condicion evalua si se ha iniciado una transacción y si no se ha terminado el protocolo
                next_state = TRANSACTION_PROCESS;
            end else begin
                next_state = IDLE;
            end
        end
        TRANSACTION_PROCESS: begin  // Proceso de transacción
            CS = 0;   // Se desactiva el CS
            SCK = Count_clock[1]; // Se activa el reloj de acuerdo al modo de operación
            if (Bit_counter == 0) begin // Se establece el MISO
                    MOSI = Data_register[15]; // Establecer MOSI directamente desde Data_register, ya que el primer bit es el más significativo
                end else begin
                    MOSI = Data_register[15]; // Establecer MOSI directamente desde Data_register
                    Prox_Data_register = {Data_register, MISO}; // En este caso se prepara el próximo dato porque ya se ha establecido el MOSI
                end
            if (end_protocol) begin // Esta condición evalua si se ha terminado el protocolo
                next_state = IDLE;
            end
        end
    endcase
end
endmodule