const reg = @import("stm32f401xe.zig");

pub const Port = extern struct {
    MODER: u32, // GPIO port mode register,               Address offset: 0x00
    OTYPER: u32, // GPIO port output type register,        Address offset: 0x04
    OSPEEDR: u32, // GPIO port output speed register,       Address offset: 0x08
    PUPDR: u32, // GPIO port pull-up/pull-down register,  Address offset: 0x0C
    IDR: u32, // GPIO port input data register,         Address offset: 0x10
    ODR: u32, // GPIO port output data register,        Address offset: 0x14
    BSRR: u32, // GPIO port bit set/reset register,      Address offset: 0x18
    LCKR: u32, // GPIO port configuration lock register, Address offset: 0x1C
    AFR: [2]u32, // GPIO alternate function registers,     Address offset: 0x20-0x24
};

pub const Pin = u4;

pub const PORTA: *volatile Port = @ptrFromInt(reg.GPIOA_BASE);
pub const PORTB: *volatile Port = @ptrFromInt(reg.GPIOB_BASE);
pub const PORTC: *volatile Port = @ptrFromInt(reg.GPIOC_BASE);
pub const PORTD: *volatile Port = @ptrFromInt(reg.GPIOD_BASE);
pub const PORTE: *volatile Port = @ptrFromInt(reg.GPIOE_BASE);
pub const PORTH: *volatile Port = @ptrFromInt(reg.GPIOH_BASE);

pub const Mode = enum(u2) {
    Input = 0b00,
    Output = 0b01,
    AlternateFunction = 0b10,
    Analog = 0b11,

    const Mask: Mode = .Analog;
};

pub fn SetMode(port: *volatile Port, pin: Pin, mode: Mode) void {
    const shift: u5 = @as(u5, pin) << 1;
    port.MODER &= ~(@as(u32, @intFromEnum(Mode.Mask)) << shift);
    port.MODER |= @as(u32, @intFromEnum(mode)) << shift;
}

pub fn Read(port: *volatile Port, pin: Pin) bool {
    return (port.IDR & ((@as(u32, 1) << pin))) != 0;
}

pub fn Set(port: *volatile Port, pin: Pin) void {
    port.ODR |= @as(u32, 1) << pin;
}

pub fn Clear(port: *volatile Port, pin: Pin) void {
    port.ODR &= ~(@as(u32, 1) << pin);
}

pub fn Toggle(port: *volatile Port, pin: Pin) void {
    port.ODR ^= @as(u32, 1) << pin;
}

pub fn Write(port: *volatile Port, pin: Pin, value: bool) void {
    if (value) {
        Set(port, pin);
    } else {
        Clear(port, pin);
    }
}
