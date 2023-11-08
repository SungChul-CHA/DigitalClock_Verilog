# Digital Clock with Verilog

## top module 분석

- clk_wiz_0 (output clk, input reset, output locked, input clk)<br>
  locked : output clk이 안정하면 0, 불안정 하면 1 -> lock이 1이면 회로 전체 리셋

- gen_counter_en (parameter SIZE) (input clk, input reset, output pulse)<br>
  input clk이 SIZE 만큼 지나가면 1 clk 짜리 pulse 생성

- [debounce](https://github.com/SungChul-CHA/Uart_Verilog#debouncer)

- dec7 (input dec_in, output dec_out)<br>
  dec_in : 0부터 9까지 input 숫자. dec_out : 7-segment 데이터
  ![7segment](https://media.parallax.com/wp-content/uploads/2020/07/13155129/350-00027a-600x600.png.webp)

- mode 버튼 눌리면 다음 state로 넘어감
  0 : default
  1 : time
  2 : stop watch
  3 : timer
  4 : alarm

---

## 동작 구성

### 0. DEFAULT_ST

> 100MHz 짜리를 6MHz 짜리의 clk_6mhz 로 나눔

> clk_6mhz로 1Hz 짜리 clock_en 펄스 생성

> clock_en 마다 sec0 증가
>
> sec0이 9이고 다음 pulse에서
> sec1_en 펄스 발생하고 sec0 0으로 초기화
>
> sec1_en 펄스 뜨면 바로 sec1 1 증가
>
> sec1 5이고 다음 sec1_en에서
> min0_en 펄스 발생하고 sec1 0으로 초기화
>
> min0_en 펄스 뜨면 바로 min0 1 증가
>
> min0 9이고 다음 min0_en에서
> min1_en 펄스 발생하고 min0 0으로 초기화
>
> min1_en 펄스 뜨면 바로 min1 1 증가
>
> min1 5이고 다음 min1_en에서
> hrs0_en 펄스 발생하고 min1 0으로 초기화
>
> hrs0_en 펄스 뜨면 바로 hrs0 1 증가
>
> hrs0 9이고 다음 hrs0_en에서
> hrs1_en 펄스 발생하고 hrs0 0으로 초기화
>
> hrs1_en 펄스 뜨면 바로 hrs1 1 증가
>
> hrs1 2이고 hrs0 3이고 다음 hrs0_en에서
> hrs1 0, hrs0 0으로 초기화

![timing](./study/time_trans.jpeg)
