kt :: KernelTun(10.0.0.2/24);
s_client :: Socket("UDP", ADDR REMOTE_ADDR, PORT 5555);
s_server :: Socket("UDP", ADDR 0.0.0.0, PORT 5555);


s_server -> CheckIPHeader() -> kt;
kt -> CheckIPHeader() -> Queue(50) -> s_client;
