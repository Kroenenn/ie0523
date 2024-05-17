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
        //Primer estado, valor binario 3'b000
        IDLE: begin
            if (TARJETA_RECIBIDA == 1) begin
                next_state = VERIFY_PIN;
                next_pin_entered = 0;
            end else begin
                next_state = IDLE;
            end
        end
        //Segundo estado, valor binario 3'b001
        //Se revisan las condiciones de PIN, es decir, si es correcto, incorrecto, si se pone en alto
        //advertencia, si se pone en alto bloqueo, si aumenta intentos
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
        //Tercer estado, valor binario 3'b010
        //Se espera PROCESS_TRANSACTION
        PROCESS_TRANSACTION: begin
            if (TIPO_TRANS == 1) begin
                next_state = WITHDRAWAL;
            end else begin
                next_state = DEPOSIT;
            end
        end
        //Cuarto estado, 3'b011
        //Hace las operaciones de retiro, hace la comparacion entre monto y retiro, enciende las 
        //señales BALANCE_ACTUALIZADO, FONDOS_INSUFICIENTES, ENTREGAR_DINERO dependiendo de las condiciones
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
        //Quinto estado, 3'b111
        //Suma monto y deposito, si se actualiza entonces se prende BALANCE_ACTUALIZADO
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
        //Sexto estado, 3'b101
        //El sistema esta en un estado de bloqueo, hasta que se mande la señal de 
        //reinicio no se podran hacer mas operaciones.
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