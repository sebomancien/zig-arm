const reg = @import("stm32f401xe.zig");

const Register = extern struct {
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

pub const Gpio = struct {
    pub const Port = enum { porta, portb, portc, portd, porte, porth };

    pub const Mode = enum(u2) {
        input = 0b00,
        output = 0b01,
        alternateFunction = 0b10,
        analog = 0b11,
    };

    port: *volatile Register,
    pin: u4,

    pub fn init(port: Port, pin: u4, mode: Mode) Gpio {
        const gpio = Gpio{
            .port = switch (port) {
                .porta => @ptrFromInt(reg.GPIOA_BASE),
                .portb => @ptrFromInt(reg.GPIOB_BASE),
                .portc => @ptrFromInt(reg.GPIOC_BASE),
                .portd => @ptrFromInt(reg.GPIOD_BASE),
                .porte => @ptrFromInt(reg.GPIOE_BASE),
                .porth => @ptrFromInt(reg.GPIOH_BASE),
            },
            .pin = pin,
        };
        gpio.setMode(mode);
        return gpio;
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

    pub fn setAf(self: Gpio, af: u4) void {
        const idx: u1 = if (self.pin < 8) 0 else 1;
        const shift: u5 = @as(u5, self.pin % 8) * 4;
        self.port.AFR[idx] = (self.port.AFR[idx] & ~(@as(u32, 0xF) << shift)) | (@as(u32, af) << shift);
    }
};
