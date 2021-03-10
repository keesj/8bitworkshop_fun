
/*
A clock divider in Verilog, using the cascading
flip-flop method.
*/

module delay
  #(parameter START_VALUE=10)
  (input clk,
  input rst,
  input en,
  output rdy,
  output busy);

  reg [31:0] counter =0;
  
  assign busy = counter > 0;
  
  always @(posedge clk) begin
    rdy <= 0; // ready is only ever high for a single sample
    if(rst) begin
      counter <= 0;
    end else begin
      if (en) begin
        counter <= START_VALUE;
      end else begin
        if (counter > 0) begin
          counter <= counter -1;
        end else begin
          rdy <= 1'b1;
        end
      end
    end
  end
endmodule

module clock_divider(
  input clk,
  input reset,
  output reg swim,
  output reg rst_line
);

  // simple ripple clock divider
  
  initial begin
    rst_line = 1'b0;
  end
  
  parameter STATE_IDLE=0, STATE_INITIAL_DOWN=1,STATE_1KHZ=2,STATE_2KHZ=3;
  
  reg idle_delay_en = 1'b0;
  wire idle_delay_rdy;
  wire busy;
  delay #(.START_VALUE(4)) idle_delay (
    .clk(clk),
    .rst(rst),
    .en(idle_delay_en),
    .rdy(idle_delay_rdy),
    .busy(busy)
  );
   
  reg [1:0] state= 2'b00;
  reg [5:0] counter =0;
  always @(posedge clk) begin
    idle_delay_en <= 1'b0;
    
    if (reset) begin
      swim <= 0;
      state <= STATE_IDLE;
    end else begin
      case(state) 
        STATE_IDLE: begin
          state <= STATE_INITIAL_DOWN;
          if (!busy) begin
          	idle_delay_en <= 1'b1;
          end
          
          if (idle_delay_rdy) begin
            state <= STATE_INITIAL_DOWN;
            counter <= 5;
            rst_line <= 1'b1;
          end
        end
        STATE_INITIAL_DOWN: begin
          counter <= counter -1;
          if (counter == 0) begin
            state <= STATE_1KHZ;
            counter <= 5;
          end
        end
        STATE_1KHZ: begin
          counter <= counter -1;
          if (counter == 0) begin
            state <= STATE_2KHZ;
            counter <= 5;
          end
        end
        STATE_2KHZ: begin
          counter <= counter -1;
          if (counter == 0) begin
            state <= STATE_IDLE;
            counter <= 5;
            rst_line <= 1'b0;
          end
        end     
      endcase      
    end
  end
endmodule
