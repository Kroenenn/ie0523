/*

    Archivo: pruebas.v
    Autor: Oscar Porras Silesky C16042
    Fecha: 18 de mayo de 2024

    Descripción: Archivo que contiene el módulo ATMController, el cual se encarga de simular el funcionamiento
    de un cajero automático, el cual recibe una tarjeta, un pin y una transacción
    (retiro o depósito) y se encarga
    de realizar la transacción correspondiente. Si el pin es incorrecto, se
    permite un máximo de 3 intentos, luego de los cuales se bloquea la tarjeta.
    Se puede realizar un retiro de dinero, en cuyo caso se verifica que el monto
    a retirar no sea mayor al balance actual. Si el monto a retirar es mayor al
    balance, se activa la señal de FONDOS_INSUFICIENTES. Si el monto a retirar
    es menor o igual al balance, se resta el monto al balance y se activa la señal
    de ENTREGAR_DINERO. También se puede realizar un depósito de dinero, en cuyo
    caso se suma el monto al balance y se activa la señal de ENTREGAR_DINERO.

*/


module ATMController (
    input wire CLK,
    input wire RESET,
    input wire TARJETA_RECIBIDA,
    input wire [15:0] PIN,
    input wire [3:0] DIGITO,
    input wire DIGITO_STB,
    input wire TIPO_TRANS,
    input wire [31:0] MONTO,
    input wire MONTO_STB,
    output reg BALANCE_ACTUALIZADO,
    output reg ENTREGAR_DINERO,
    output reg FONDOS_INSUFICIENTES,
    output reg PIN_INCORRECTO,
    output reg ADVERTENCIA,
    output reg BLOQUEO
);
//Declaración de variables intermedias
reg [5:0] state, next_state;
reg [63:0] balance, next_balance;
reg m_stb_previous, next_m_stb_previous;
//Necesarios para el PIN
reg [15:0] pin_entered, next_pin_entered;
reg [2:0] pin_digits, next_pin_digits;
reg [1:0] pin_attempts, next_pin_attempts;

//Numero del estado 
parameter IDLE = 6'b000001; //Estado inicial, eperando tarjeta 
parameter VERIFY_PIN = 6'b000010; //Estado esperando pin correcto
parameter PROCESS_TRANSACTION = 6'b000100; //Esperando tipo de transaccion
parameter WITHDRAWAL = 6'b001000; //Tipo de transaccion retiro, esperando monto
parameter DEPOSIT = 6'b010000; //Tipo de transaccion deposito
parameter BLOCKED = 6'b100000; //Bloqueo, estado de bloqueo por 3 intentos fallidos

//Indicaciones del pin
always @(posedge CLK) begin
    if (RESET == 1'b0) begin
        state <= IDLE; 
        balance <= 32'h0AF0_0000;
        m_stb_previous <= 0;
        pin_attempts <= 0;
        pin_entered <= 0;
        pin_digits <= 0;
    end else begin
        state <= next_state;
        balance <= next_balance;
        m_stb_previous <= next_m_stb_previous;
        pin_attempts <= next_pin_attempts;
        pin_entered <= next_pin_entered;
        pin_digits <= next_pin_digits;

    end
end

always @(*) begin
    //Flip-Flops
    next_state = state;
    next_balance = balance;
    next_m_stb_previous = MONTO_STB;
    next_pin_attempts = pin_attempts;
    next_pin_entered = pin_entered;
    next_pin_digits = pin_digits;
    
    //Necesario inicializar las salidas
    BALANCE_ACTUALIZADO = 0;
    ENTREGAR_DINERO = 0;
    FONDOS_INSUFICIENTES = 0;
    PIN_INCORRECTO = 0;
    ADVERTENCIA = 0;
    BLOQUEO = 0;

    //Se empieza con la descripcion de la maquina de estados
    case (state)
        //Primer estado, valor binario 6'b000001
        // Este estado se encarga de esperar a que se inserte la tarjeta
        // si se inserta la tarjeta se va a VERIFY_PIN
        IDLE: begin
            if (TARJETA_RECIBIDA == 1) begin
                next_state = VERIFY_PIN;
                next_pin_entered = 0;
            end else begin
                next_state = IDLE;
            end
        end
        //Segundo estado, valor binario 6'b000010
        // Este estado se encarga de verificar el pin ingresado por el usuario
        // si el pin es correcto se va a PROCESS_TRANSACTION, si el pin es incorrecto
        // se aumenta el contador de intentos y se va a BLOCKED si se ingresan 3 intentos
        VERIFY_PIN: begin
            if (DIGITO_STB && pin_digits < 4) begin
                next_pin_entered = {pin_entered[11:0], DIGITO};
                next_pin_digits = pin_digits + 1;
            end
            if (pin_digits == 4) begin
                next_pin_digits = 0;
            end
            if (pin_digits == 4 && pin_entered != PIN) begin
                next_pin_attempts = pin_attempts + 1;
            end
            PIN_INCORRECTO = (pin_digits == 4 && pin_entered != PIN);
            ADVERTENCIA = PIN_INCORRECTO && (pin_attempts == 1) && (state == VERIFY_PIN);
            BLOQUEO = PIN_INCORRECTO && (pin_attempts == 2) && (state == VERIFY_PIN) || (pin_attempts >= 3) && (state == VERIFY_PIN);
            
            if (pin_entered == PIN) begin
                next_state = PROCESS_TRANSACTION;
            end else if (pin_attempts >= 3) begin
                next_state = BLOCKED;
            end else begin
                next_state = VERIFY_PIN;
            end
        end
        //Tercer estado, valor binario 6'b000100
        //Se espera PROCESS_TRANSACTION para hacer la transaccion
        // si es retiro se va a WITHDRAWAL, si es deposito se va a DEPOSIT
        PROCESS_TRANSACTION: begin
            if (TIPO_TRANS == 1) begin
                next_state = WITHDRAWAL;
            end else begin
                next_state = DEPOSIT;
            end
        end
        //Cuarto estado, 6'b001000
        // Este estado se encarga de hacer la transaccion de retiro, si el monto es mayor al balance
        // se prende la señal de FONDOS_INSUFICIENTES, si el monto es menor o igual al balance
        // se resta el monto al balance y se prende la señal de ENTREGAR_DINERO
        WITHDRAWAL: begin
            if (MONTO_STB == 1 && m_stb_previous == 0) begin
                if (MONTO <= balance) begin
                    next_balance = balance - MONTO;
                    ENTREGAR_DINERO = 1; 
                end else begin
                    FONDOS_INSUFICIENTES = 1;  
                end
            end
            if (next_balance != balance) begin
                BALANCE_ACTUALIZADO = 1;
            end
            if (TARJETA_RECIBIDA == 0) begin
                next_state = IDLE;
            end 
        end
        //Quinto estado, 6'b010000
        // Este estado se encarga de hacer la transaccion de deposito, si el monto es mayor a 0
        // se suma el monto al balance y se prende la señal de ENTREGAR_DINERO
        DEPOSIT: begin
            if (MONTO_STB == 1 && m_stb_previous == 0) begin
                next_balance = balance + MONTO;
            end
            if (next_balance != balance) begin
                BALANCE_ACTUALIZADO = 1;
            end 
            if (TARJETA_RECIBIDA == 0) begin
                next_state = IDLE;
            end 
        end
        //Sexto estado, 6'b100000
        // Este estado se encarga de bloquear la tarjeta si se ingresan 3 intentos fallidos
        BLOCKED: begin
            if (RESET == 0) begin
                next_state = IDLE;
            end else begin
                BLOQUEO = 1;
                next_state = BLOCKED;
            end
        end

        // Se hace un case default para el estado IDLE
        // en caso de que no se cumpla ninguna de las condiciones anteriores
        default: begin
            next_state = IDLE;
        end
    endcase
end
endmodule