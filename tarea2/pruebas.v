/* 
Controlador automatizado de acceso a estacionamiento con contraseña y compuerta.

Hecho por: Oscar Porras Silesky
Fecha de entrega: 13 de Abril de 2024

Archivo: pruebas.v
*/


// Modulo de verificacion de contraseña
module passwordSystem(
    input wire clock,           // Entrada: Señal de reloj
    input wire [7:0] P,         // Entrada: Contraseña proporcionada
    input wire sensor_arrival,  // Entrada: Sensor que detecta la llegada de un vehículo
    input wire p_enter,         // Entrada: Señal de confirmación de entrada de contraseña
    input wire sensor_parked,   // Entrada: Sensor de vehículo estacionado
    input wire reset,           // Entrada: Señal de reset
    output reg S_L,             // Salida: Señal de validez de la contraseña
    output reg A_P              // Salida: Alarma por intentos fallidos
);

    localparam rightPass = 8'b00101010; // Carné: C16042, ajustado con la especificación k
    reg [2:0] attempt_count = 0; // Contador de intentos fallidos

    // Inicialización de las salidas
    initial begin
        S_L = 0;
        A_P = 0;
        attempt_count = 0;
    end


    // Bloque always para la lógica secuencial de verificación de contraseña
always @(posedge clock) begin
    if (reset) begin
        // Lógica de reset: Inicializa las salidas y el contador de intentos
        S_L <= 0;
        A_P <= 0;
        attempt_count <= 0;
    end else begin
        
        if (sensor_parked && !sensor_arrival && P == rightPass) begin
            // Si el vehículo ya entró, bajar la señal de validez de la contraseña
            S_L <= 0;
        end else if (sensor_arrival && p_enter) begin
            // Revisa la contraseña cuando se presiona 'enter'
            if (P == rightPass) begin
                // Contraseña correcta
                S_L <= 1;
                attempt_count <= 0;
                A_P <= 0;
            end else begin
                // Contraseña incorrecta
                S_L <= 0;
                attempt_count <= attempt_count + 1;
                if (attempt_count >= 2) begin

                    // Activar alarma después de 3 o mas intentos fallidos, 6 por los ciclos de reloj
                    A_P <= 1;
                end
            end
        end else begin
            // Mantener el estado actual si no se cumplen las condiciones anteriores
            S_L <= S_L;
            A_P <= A_P;
            attempt_count <= attempt_count;
        end
    end
end
endmodule

// Módulo de control de la compuerta
module gateSystem(
    input wire clock,          // Añadir señal de reloj
    input wire S_L,            // Entrada: Señal de validez de la contraseña
    input wire sensor_arrival, // Entrada: Sensor de llegada de vehículo
    input wire sensor_parked,  // Entrada: Sensor de vehículo estacionado
    input wire reset,          // Entrada: Señal de reset
    output reg G_O,            // Salida: Acción de la compuerta (abrir)
    output reg G_C,            // Salida: Estado de la compuerta (cerrar)
    output reg B,              // Salida: Señal de bloqueo del sistema
    output reg A_B             // Salida: Alarma de bloqueo
);

    // Estado inicial de la compuerta, el bloqueo y la alarma de bloqueo
    initial begin
        G_O = 0;
        G_C = 0;
        B = 0;
        A_B = 0;
    end


    // Bloque always para la lógica secuencial de control de la compuerta
    always @(posedge clock) begin
        if (reset) begin
        // Lógica de reset: Inicializa las salidas del sistema de la compuerta
        G_O <= 0;
        G_C <= 0;
        B <= 0;
        A_B <= 0;
        end else begin
            if (S_L) begin
                G_O <= 1; // Abrir la compuerta si la contraseña es válida
                G_C <= 0;
                B <= 0;
                A_B <= 0;
            end else if (sensor_arrival && sensor_parked) begin
                B <= 1;
                A_B <= 1;
                G_O <= 0; // No se intenta abrir la compuerta durante el bloqueo
                G_C <= 1; // Asumimos que la compuerta se cierra en estado de bloqueo
            end else if (!sensor_parked) begin
                G_C <= 0;
            end else if (sensor_parked) begin 
                G_C <= 1; // Cierra la compuerta si el vehículo está estacionado
                G_O <= 0;
            end 
        end
    end
endmodule
