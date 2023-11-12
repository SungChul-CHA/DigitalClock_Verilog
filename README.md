# Digital Clock

## Target Board

ZedBoard Zynq Evaluation and Development Kit
Zynq-7000 SoC

---

## FSM 구상

|       <b>FSM 1안</b>       |
| :------------------------: |
| ![FSM1](study/image-2.png) |

|       <b>FSM 2안</b>        |
| :-------------------------: |
| ![FSM2](study/image-3.png)) |

---

## 동작 구상 1안

- seg_data의 LSB 점은 시, 분, 초 구분하는 점으로 사용
- a_INT Flag 0으로 설정. interrupt Flag 1로 뜨면 ALARM_ST 로 넘어감.
- btn[4] 누르면 모든 데이터 초기화, IDLE_ST로 이동.

### 조정 모드

> btn[0] 누르면 커서가 왼쪽으로 이동.<br>
> 해당 digit의 seg_com에 0.5초동안 1 (불들어오고) 0.5초동안 0 넣어서 불꺼지는 깜빡임 발생<br>
> btn[1] 누르면 커서 있는 숫자 증가.<br>
> btn[2] 누르면 들어왔던 상태로 되돌아감<br>
> btn[3] 누르면 들어왔던 상태의 다음 상태로 넘어감<br>

### 시계 모드

> btn[0], btn[1], btn[2] 모두 같은 동작.<br>
> 상기 버튼을 1초 이상 누르면 조정 모드로 state 넘어감.<br>
> btn[3] 누르면 다음 state로 넘어감<br>

### 스탑워치 모드

> watch Flag이 0일때, btn[0] 누르면 flag 1로 올리고 stop watch 시작, led 동작<br>
> watch Flag이 1일때, btn[0] 누르면 flag 0으로 내리고 stop watch 멈춤, led 멈춤<br>
> watch Flag이 0이고 lap Flag이 0일때, btn[1] 누르면 stop watch 초기화, led 꺼짐<br>
> watch Flag이 1이고 lap Flag이 0일때, btn[1] 누르면 보여주는 값 고정하고 백그라운드에서 스탑워치 동작, lap Flag 1로<br>
> lap Flag이 1일때, btn[1] 누르면 lap flag 0으로 내리고 현재 stop watch 값 보여줌.<br>
> btn[2] 누르면 IDLE_ST 로 돌아감.<br>
> btn[3] 누르면 다음 state<br>

### 타이머 모드

> t_INT Flag이 1일때, btn[0]=btn[1]=btn[2]=btn[3] 누르면 타이머 종료, t_Int Flag 0으로 내림.<br>
> seg_data가 00:00:00 일때 btn[0] 누르면 아무 동작 안함<br>
> timer Flag 1일때, btn[0] 누르면 타이머 중지, timer Flag 0으로 내림<br>
> 그 외 btn[0] 누르면 타이머 시작, timer Flag 1로 올림<br>
> btn[1] 누르면 타이머 0으로 리셋, timer Flag 0으로 내림<br>
> btn[2] 1초 이상 누르면 조정 모드로 state 넘어감.<br>
> timer Flag이 0일때, btn[3] 누르면 다음 state로 넘어감.<br>

### 알람 모드

> a_INT Flag 1로 떴을 때, btn[0] = btn[1] = btn[2] = btn[3] 알람 종료, interrupt Flag 0으로 내려감<br>
> alarm Flag = 0일때, btn[0] = btn[1] 1초 이상 누르면 알람 켜짐<br>
> alarm Flag = 1일때, btn[0] = btn[1] 1초 이상 누르면 알람 꺼짐<br>
> btn[2] 1초 이상 누르면 조정 모드로 state 넘어감, alarm Flag 1로 올림<br>
> btn[3] 누르면 다음 state로 넘어감<br>

---

## 동작 구상 2안

- 1안에서 알람이나 타이머가 울리는 상태를 INT_ST로 state를 추가한 모델

---

## 7-Segment

dec_in : 0부터 9까지 input 숫자. dec_out : 7-segment 데이터
|<b>7-Segment</b> |
| :--: |
| ![7segment](https://media.parallax.com/wp-content/uploads/2020/07/13155129/350-00027a-600x600.png.webp)|

| dec_in |  dec_out   |
| :----: | :--------: |
|  0000  | 1111110, 0 |
|  0001  | 0110000, 0 |
|  0010  | 1101101, 0 |
|  0011  | 1111001, 0 |
|  0100  | 0110011, 0 |
|  0101  | 1011011, 0 |
|  0110  | 1011111, 0 |
|  0111  | 1110010, 0 |
|  1000  | 1111111, 0 |
|  1001  | 1111011, 0 |

---

## 시계 타이밍도 구상

![timing](./study/time_trans.jpeg)

---

## Digital Clock 동작

- defualt : Clock display
  SW0, SW1, SW3 : move to next mode(Stop Watch)
  push SW2 for 1 sec : setting mode(time setting)

  - SW0 : move cursor to left
    SW1 : increase time

- Stop Watch
  SW0 : start/stop
  SW1 : lap time/reset
  SW2 : move to last mode (Clock)
  SW3 : move to next mode (Timer)

- Timer
  SW0 : start/stop
  SW1 : reset
  push SW2 for 1 sec : setting mode(timer setting)

  - SW0 : move cursor to left
    SW1 : increase time
    SW3 : move to next mode (Alarm)

- Alarm
  SW0, SW1, SW2 : when alarm running turn off the alarm
  push SW2 for 1 sec : setting mode(alarm setting)
  - SW0 : move cursor to left
    SW1 : increase time
    push SW0, SW1 for 1 sec : set or unset an alarm

---

### Top module

#### inout signals

- input : 100MHZ clk, SW4 - reset, SW3 ~ SW0
- output : 8bit segment data, 6bit segment location, 8bit led

#### inner signals

toggle_2hz : toggle every 0.5 sec
btn_pulse : debounced switch pulse
btn_1s : debounced switch pulse but 1sec later
led_s : led out in Stop Watch state
led_t : led out in Timer state
led_a : led out in Alarm state

alarm_on : turn on when alarm is set
a_INT : turn to high when time matches to alarm time
t_INT : turn to high when timer done

enable : enable signal for each module
setting : signal that indicate on SETTING_ST for each module
enable[0], setting[0] : clock module
enable[1] : stop_watch module
enable[2], setting[1] : timer module
setting[2] : timer module

c_state : current state
0 : CLOCK_ST
1 : SWATCH_ST
2 : TIMER_ST
3 : ALARM_ST
4 : SETTING_ST

l_state : last state for setting mode
FPGA need to store last state before entering SETTING_ST to return when setting finish.

n_state : condition for move to other state

#### Operation

1. n_state changes depending on condition

- if (a_INT) -> ALARM_ST
- if (t_INT) -> TIMER_ST
- btns -> specific state

2. set seg_in depending on state
   seg_in : time data(4bit)

3. decode to segment data
   seg_out : segment data(7bit)

4. display seg_out as seg_data in condition of seg_com signal

5. display leds depends on c_state

##### seg_com

- move to left(right circular shift) with 600hz
- if (SETTING_ST) -> blink a number cursor on
  I used digit to make this function
- if (interrupt occur) -> blink whole number

##### digit

- 6bit signal to specify location of number
- SW0 : move to left(right circular shift)

---

### Clock module

- operate when enable is high
- hold the time when setting is high
- increase a number of time which digit is pointing when SETTING_ST

push SW2 for 1sec : go to setting mode
SW0 : move cursor to left under setting mode
SW1 : increase number under setting mode

#### inout signals

- output : time data (4bits)
- en : enable signal
- setting : indication for SETTING_ST or not
- digit : cursor
- up : SW0

#### inner signals

- sec1_en ~ hrs1_en : use as a carry

---

### Stop Watch module

- operate when en is high + busy rises to high
- show milli sec before 59:59:99
- Max time in countable 23:59:59
- There is lap time function on my code. So it could be hard if stop watch is running or not. To prevent such inconvenience, led will be move to left(right circular shift) while busy is high.

#### How to use

defualt : mm:ss:00(milli sec)
SW0 : start
SW0 : stop when busy
SW1 : reset when !busy
SW1 : lap when busy -> stop watch still running in background
SW1 : unlock the display when lap signal was high -> see the leds move or not

push SW2 for 1sec : go to setting mode
SW0 : move cursor to left under setting mode
SW1 : increase number under setting mode

#### inout signals

- en : enable
- time_out : time data(4 bits)
- led_out : led shape

#### inner signals

- sec0 ~ hrs1 : small time for milli sec
- sec0_b ~ hrs1_b : big time from 01:00:00 to 23:59:59
- **busy** : turn to high when stop watch is running
- **lap** : turn to high when you are watching lap time

---

### Timer module

- operate when en is high + busy rises to high
- SW0 : start/stop
- SW1 : reset

push SW2 for 1sec : go to setting mode
SW0 : move cursor to left under setting mode
SW1 : increase number under setting mode
