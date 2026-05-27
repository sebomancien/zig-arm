const SysTick = @import("systick.zig");
const Gpio = @import("gpio.zig").Gpio;
const Uart = @import("uart.zig").Uart;

var led: Gpio = undefined;
var uart_tx: Gpio = undefined;
var uart: Uart = undefined;

pub export fn main() void {
    led = Gpio.init(.porta, 5, .output);
    uart_tx = Gpio.init(.porta, 2, .alternateFunction);
    uart_tx.setAf(7);

    uart = Uart.init(.usart2, 115_200, 16_000_000);

    led.clear();

    SysTick.Init(800_000);

    while (true) {}
}

pub export fn SysTick_Handler() void {
    led.toggle();
    uart.write("a");
}
