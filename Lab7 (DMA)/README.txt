cpu_tb의 clk, br, bg, interupt_CON, interupt_EX, memory의 wave form을 찍어보면 204650ns 부터 external device에서 interupt_EX가 켜지고, 그와 동시에 BR이 켜지게 된다.
하지만 현재 D_cache의 cache_line이 memory를 접근중이기 때문에, 이 memory 접근이 끝마친 후인 204850ns부터 BG가 1이 되고, external device의 동작이 시작된다.
그 후 6cycle마다 4word가 external device의 값이 memory에 적히는 것을 memory의 16'h14부터 확인해보면 알수 있다.
이렇게 총 3번의 반복을 통해 external device의 모든 data가 memory에 쓰이는 것을 확인할 수 있다. 
이때, 16'h14, 16'h18, 16'h1c를 시작 메모리 주소로하여 4개씩 적히게 된다.
그 후 BR과 BG가 206650ns에 동시에 0이 되는 것을 알 수 있다. 
그후, interupt_CON이 켜지는 것을 알 수 있다.