const RCC = @import("rcc.zig");
const SysTick = @import("systick.zig");
const GPIO = @import("gpio.zig");

const LED_PORT = GPIO.PORTA;
const LED_PIN: u8 = 5;

export fn main() void {
    RCC.EnableGPIOA();

    GPIO.SetMode(LED_PORT, LED_PIN, .Output);
    GPIO.Clear(LED_PORT, LED_PIN);

    SysTick.Init(800000);

    while (true) {}
}

export fn SysTick_Handler() void {
    GPIO.Toggle(LED_PORT, LED_PIN);
}
