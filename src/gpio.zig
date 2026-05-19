const reg = @import("stm32f401xe.zig");

const Register = struct {
    MODER: u32,
    OTYPER: u32,
    OSPEEDR: u32,
    PUPDR: u32,
    IDR: u32,
    ODR: u32,
    BSRR: u32,
    LCKR: u32,
    AFR: [2]u32,
};

const porta: *volatile Register = @ptrFromInt(reg.GPIOA_BASE);
const portb: *volatile Register = @ptrFromInt(reg.GPIOB_BASE);
const portc: *volatile Register = @ptrFromInt(reg.GPIOC_BASE);
const portd: *volatile Register = @ptrFromInt(reg.GPIOD_BASE);
const porte: *volatile Register = @ptrFromInt(reg.GPIOE_BASE);
const porth: *volatile Register = @ptrFromInt(reg.GPIOH_BASE);

pub const Gpio = struct {
    pub const Mode = enum(u2) {
        input = 0b00,
        output = 0b01,
        alternateFunction = 0b10,
        analog = 0b11,
    };

    pub const Port = enum { a, b, c, d, e, h };

    pub const Pin = u4;

    port: *volatile Register,
    pin: Pin,

    pub fn init(port: Port, pin: Pin) Gpio {
        return .{
            .port = switch (port) {
                .a => porta,
                .b => portb,
                .c => portc,
                .d => portd,
                .e => porte,
                .h => porth,
            },
            .pin = pin,
        };
    }

    pub fn setMode(self: Gpio, mode: Mode) void {
        const shift: u5 = @as(u5, self.pin) << 1;
        self.port.MODER = (self.port.MODER & ~(@as(u32, 0b11) << shift)) | (@as(u32, @intFromEnum(mode)) << shift);
    }

    pub fn read(self: Gpio) bool {
        return (self.port.IDR & (@as(u32, 1) << self.pin)) != 0;
    }

    pub fn set(self: Gpio) void {
        self.port.BSRR = @as(u32, 1) << self.pin;
    }

    pub fn clear(self: Gpio) void {
        self.port.BSRR = @as(u32, 1) << (@as(u5, self.pin) + 16);
    }

    pub fn toggle(self: Gpio) void {
        self.port.ODR ^= @as(u32, 1) << self.pin;
    }

    pub fn write(self: Gpio, value: bool) void {
        if (value) self.set() else self.clear();
    }
};
