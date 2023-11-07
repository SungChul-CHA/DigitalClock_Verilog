# Digital Clock with Verilog

## top module 분석

- clk_wiz_0 (output clk, input reset, output locked, input clk)
  locked : output clk이 안정하면 0, 불안정 하면 1 -> lock이 1이면 회로 전체 리셋

- gen_counter_en (parameter SIZE) (input clk, input reset, output pulse)
  input clk이 SIZE 만큼 지나가면 1 clk 짜리 pulse 생성

- [debounce](https://github.com/SungChul-CHA/Uart_Verilog#debouncer)

- dec7 (input dec_in, output dec_out)
  dec_in : 0부터 9까지 input 숫자. dec_out : 7-segment 데이터
  ![7segment](https://media.parallax.com/wp-content/uploads/2020/07/13155129/350-00027a-600x600.png.webp)
