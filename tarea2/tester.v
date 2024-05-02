
/*
    Archivo: tester.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 13 de Abril de 2024

    Descripción: Tester para el sistema de control de acceso de una compuerta de estacionamiento.
*/


module tester(

    input wire G_O,
    input wire G_C,
    input wire B,
    input wire A_B,
    input wire A_P,

    output reg [7:0] P,
    output reg reset,
    output reg sensor_arrival,
    output reg sensor_parked,
    output reg p_enter
);

    localparam rightPass = 8'b00101010; // Contraseña correcta según carnet C16042
    localparam wrongPass = 8'b01111111; // Contraseña incorrecta de ejemplo
    localparam wrongPass2 = 8'b11110111; // Contraseña incorrecta de ejemplo
    localparam wrongPass3 = 8'b11011111; // Contraseña incorrecta de ejemplo

    // Inicializa las señales de prueba
    initial begin
        // Inicializa todas las señales
        P = 0;
        reset = 1; // Activa el reset al comienzo para inicializar el sistema en un estado conocido
        sensor_arrival = 0;
        sensor_parked = 0;
        p_enter = 0;

        #10 reset = 0; // Desactiva el reset después de un tiempo para permitir que el sistema comience a funcionar

        // Prueba #1: Funcionamiento normal básico
        #10 sensor_arrival = 1; // Simula la llegada de un vehículo
        #10 P = rightPass; // Envía la contraseña correcta
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 sensor_arrival = 0; // Simula que el vehículo ya no está llegando
        #10 sensor_parked = 1; // Simula el estacionamiento del vehículo
        #80;// Fin de la primera prueba

        // Prueba #2: Ingreso de pin incorrecto menos de 3 veces
        P = 0; // Inicializa la contraseña con un valor no válido
        #20 sensor_parked = 0; // Simula que el vehículo ya no está estacionado
        #100
        #20 sensor_arrival = 1; // Otro vehículo llega
        #10 P = wrongPass; // Intento incorrecto #1
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 P = wrongPass2; // Intento incorrecto #2
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 P = rightPass; // Ahora la contraseña correcta
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 sensor_arrival = 0;
        #10 sensor_parked = 1; // Simula el estacionamiento del vehículo
        #80;// Fin de la segunda prueba


        // Prueba #3: Ingreso de pin incorrecto 3 o más veces
        P = 0; // Inicializa la contraseña con un valor no válido
        #20 sensor_parked = 0; // Simula que el vehículo ya no está estacionado
        #100
        #20 sensor_arrival = 1; // Otro vehículo llega
        #10 P = wrongPass; // Intento incorrecto #1
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso

        #10 P = wrongPass; // Intento incorrecto #2
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso

        #10 P = wrongPass; // Intento incorrecto #3, debería activar alarma
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso

        #30
        #10 P = rightPass; // Contraseña correcta, resetea la alarma
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso

        #10 sensor_arrival = 0;
        #10 sensor_parked = 1; // Simula el estacionamiento del vehículo
        #120;// Fin de la tercera prueba

        

        // Prueba #4: Alarma de bloqueo
        sensor_parked = 0; // apagado para siguiente prueba
        P = 0; // Inicializa la contraseña con un valor no válido
        #100

        #20 sensor_arrival = 1; // Otro vehículo llega
        #10 sensor_parked = 1; // Ambos sensores activos, debería causar bloqueo
        #10 P = wrongPass; // Contraseña incorrecta, el bloqueo permanece
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 P = rightPass; // Contraseña correcta, debería desbloquear el sistema
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 sensor_arrival = 0;

        #80 sensor_parked = 0; // Simula que el vehículo ya no está estacionado

        

        #5 P = 0;
        #10 sensor_arrival = 1; // Simula la llegada de un vehículo
        #10 P = rightPass; // Envía la contraseña correcta
        #5 p_enter = 1; // Pulso corto para 'enter'
        #5 p_enter = 0; // Fin del pulso
        #10 sensor_arrival = 0; // Simula que el vehículo ya no está llegando
        #10 sensor_parked = 1; // Simula el estacionamiento del vehículo
        #10 reset = 1;
        #10 reset = 0;
        P = 0;
        #40 sensor_parked = 0;
        
        #80;// Fin de la cuarta prueba
    end


endmodule
