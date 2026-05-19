const RCC = @import("rcc.zig");
const SysTick = @import("systick.zig");
const Gpio = @import("gpio.zig").Gpio;

const led = Gpio.init(.a, 5);

pub export fn main() void {
    RCC.EnableGPIOA();

    led.setMode(.output);
    led.clear();

    SysTick.Init(800000);

    while (true) {}
}

pub export fn SysTick_Handler() void {
    led.toggle();
}
