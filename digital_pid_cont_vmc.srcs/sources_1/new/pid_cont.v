`timescale 1ns / 1ps

//clock generation
module clk_gen( input clk, output adc_clk, output sw_clk);
    reg [1:0] count1 = 0;
    reg [9:0] count2 = 0;
    reg div_clk1 = 0;
    reg div_clk2 = 0;
    always@(posedge clk)
    begin
        if(count1 == 3) count1 <= 0;
        else count1 <= count1+1;
        if(count1<=1) div_clk1 <= 1;
        else div_clk1 <= 0;
        
        if(count2 == 499) count2 <= 0;
        else count2 <= count2+1;
        if(count2<=249) div_clk2 <= 1;
        else div_clk2 <= 0;
        
    end
    assign sw_clk = div_clk2;
    assign adc_clk = div_clk1;
endmodule

//refernce voltage
module v_ref(input clk, output signed [9:0] v_ref);
    parameter V1 = 10'sb0001100110;
    parameter V2 = 10'sb0010011010;
    reg V_clk = 0;
    reg [22:0] count = 0;
    always@(posedge clk)
    begin
        count <= count +1;
        if(count == 999999)
        begin
            V_clk <= ~V_clk;
            count <= 0;
        end
    end
    assign v_ref = V_clk ? V1 : V2;
endmodule

//PID controller
module PID(
    input clk,
    input signed [9:0] in,
    output signed [11:0] OUT
);
    // Gains (Fixed-point representations)
    localparam signed [11:0] Kpd = 12'sb000_101100010; //Q3.9
    localparam signed [11:0] Kid = 12'sb000_000010110; //Q3.9
    localparam signed [11:0] Kdd = 12'sb010_110010010; //Q3.9
    
    reg signed [9:0] error_voltage = 0;
    reg signed [9:0] err_prev = 0;
    reg signed [21:0] integral_prev = 0;

    // --- Proportional Controller ---
    wire signed [21:0] MUL1_temp;
    //wire signed [11:0] MUL1;
    assign MUL1_temp = error_voltage * Kpd; //Q4.18
   // assign MUL1 = {MUL1_temp[18:7]};

    // --- Differential Controller ---
    wire signed [9:0] MUL3a; 
    wire signed [21:0] MUL3b;
    //wire signed [11:0] MUL3;
    assign MUL3a = error_voltage - err_prev; //Q1.9
    assign MUL3b = MUL3a * Kdd;             //Q4.18
   // assign MUL3 = {MUL3b[18:7]};

    // --- Integral Controller ---
    wire signed [21:0] MUL2a;
    wire signed [21:0] MUL2b;
    wire signed [21:0] MUL2;
   
    
    localparam signed [21:0] MAX = 22'sb0000_001111111110000000;
    localparam signed [21:0] MIN = 22'sb0000_000000000010000000;
    
    assign MUL2a = error_voltage * Kid;
    assign MUL2b = MUL2a + integral_prev;
    //assign MUL2c = MUL2b[18:7];
    
    // Saturation logic for Integral term
    assign MUL2 = (MUL2b > MAX) ? MAX : ((MUL2b < MIN) ? MIN : MUL2b);
   

    // --- Summer Block ---
    wire signed [21:0] sum_a;
    assign sum_a = MUL1_temp + MUL2 + MUL3b; //Q4.18
    
    wire signed [21:0] SUM;
    assign SUM = (sum_a > MAX) ? MAX : ((sum_a < MIN) ? MIN : sum_a);
   
    
    assign OUT = {SUM[21],SUM[17:7]}; // truncation from Q4.18 to Q1.11

    always @(posedge clk) begin
        err_prev = error_voltage;
        integral_prev = MUL2;
        error_voltage = in;
    end

endmodule


//PWM using output of PID and sawtooth
module PWM(input clk, input signed [11:0] v_control, output pwm );
    reg signed [11:0] count = 0;
    reg duty = 0;
    always@(posedge clk)
    begin
        
        if(count == 499)
        begin
            count<=0;
        end
        else count <= count+1;
        
        if(count < v_control)
        begin
            duty <= 1;
        end
        else duty <=0;
        
    end
    
    assign pwm = duty;
endmodule

module Buck(input clk, input signed [ 9:0] adc_data2, output clk_adc, output pwm, output FCCM , output EN) ;
    assign FCCM = 1;
    assign EN = 1;
    wire signed [9:0] error;
    wire signed [9:0] Vref;
    wire sw_clk;
    
    clk_gen c(clk,clk_adc,sw_clk);
    
    v_ref vr(clk,Vref);
    assign error = Vref - adc_data2;
    
    wire signed [11:0] v_control;
    PID p(sw_clk,error,v_control);
    
    PWM d(clk,v_control,pwm);
endmodule