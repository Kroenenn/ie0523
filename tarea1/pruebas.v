/* 
Controlador automatizado de acceso a estacionamiento con contraseña y compuerta.

Hecho por: Oscar Porras Silesky
Fecha de entrega: 13 de Abril de 2024

Archivo: pruebas.v
*/


// Modulo de verificacion de contraseña
module passwordSystem(
    input wire [7:0] P, // Entrada: Contraseña proporcionada
    input wire reset, // Entrada: Señal de reset para diferentes simulaciones
    input wire sensor_arrival, // Entrada: Sensor que detecta la llegada de un vehículo
    input wire p_enter, // Entrada: Señal de confirmación de entrada de contraseña
    input wire sensor_parked, // Entrada: Sensor de vehículo estacionado
    output reg S_L, // Salida: Señal de validez de la contraseña
    output reg A_P // Salida: Alarma por intentos fallidos
    
);

    localparam rightPass = 8'b00101010; // Carné: C16042, ajustado con la especificación k
    reg [2:0] attempt_count = 0; // Contador de intentos fallidos

    // Inicialización de las salidas
    initial begin
        S_L = 0;
        A_P = 0;
    end

    // Bloque always para la lógica combinacional de verificación de contraseña
    always @(*) begin
        $display("Time: %t, Reset: %b, Sensor Arrival: %b, Password: %b, SL: %b, AP: %b, Attempt Count: %d", $time, reset, sensor_arrival, P, S_L, A_P, attempt_count);
        if (reset) begin // Reset de la alarma y el contador
            attempt_count = 0;
            A_P = 0;
            S_L = 0;
        end else if (sensor_parked && !sensor_arrival && P == rightPass) begin
            // Si el vehículo ya entró, bajar la señal de validez de la contraseña
            S_L = 0;
        end else if (sensor_arrival && p_enter) begin // Revisa la contraseña cuando se presiona 'enter'
            if (P == rightPass) begin
                S_L = 1; // Contraseña correcta
                attempt_count = 0;
                A_P = 0;
            end else begin
                S_L = 0;
                attempt_count = attempt_count + 1; // Incrementar antes de verificar
                if (attempt_count >= 3) begin
                    A_P = 1; // Activar alarma después de 3 o mas intentos fallidos
                end
            end
        end

        S_L = S_L; // Asignaciones redundantes para evitar warnings
        A_P = A_P;
        attempt_count = attempt_count;
    end
endmodule

// Módulo de control de la compuerta
module gateSystem(
    input wire S_L, // Entrada: Señal de validez de la contraseña
    input wire sensor_arrival, // Entrada: Sensor de llegada de vehículo
    input wire sensor_parked, // Entrada: Sensor de vehículo estacionado
    


    output reg G_O, // Salida: Acción de la compuerta (abrir/cerrar)
    output reg G_C, // Salida: Estado de la compuerta (abierta/cerrada)
    output reg B, // Salida: Señal de bloqueo del sistema
    output reg A_B // Salida: Alarma de bloqueo
);

    // Estado inicial de la compuerta, el bloqueo y la alarma de bloqueo
    initial begin
        G_O = 0;
        G_C = 0;
        B = 0;
        A_B = 0;
    end


    // Bloque always para la lógica combinacional de control de la compuerta
    always @(*) begin
        $display("Time: %t, SL: %b, Sensor Arrival: %b, Sensor Parked: %b, G_O: %b, G_C: %b, B: %b, AB: %b", $time, S_L, sensor_arrival, sensor_parked, G_O, G_C, B, A_B);
        if (S_L) begin
            G_O = 1; // Abrir la compuerta si la contraseña es válida
            G_C = 0;
            B = 0;
            A_B = 0;
        end 
        else if (sensor_arrival && sensor_parked) begin // Si ambos sensores están activos, se activa el bloqueo
            B = 1;
            A_B = 1;
        end 
        else if (!sensor_parked) begin
            G_C = 0;
        end
        else if (sensor_parked) begin 
            G_C = 1; // Cierra la compuerta si el vehículo está estacionado
            G_O = 0;
        end
        else begin

            // Si se acaba de ingresar una contraseña correcta para desbloquear, resetear B y A_B
            if (S_L == 1) begin
                B = 0;
                A_B = 0;
            end
            
        end
    end
endmodule
