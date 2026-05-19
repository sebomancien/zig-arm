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
                .a => @ptrFromInt(reg.GPIOA_BASE),
                .b => @ptrFromInt(reg.GPIOB_BASE),
                .c => @ptrFromInt(reg.GPIOC_BASE),
                .d => @ptrFromInt(reg.GPIOD_BASE),
                .e => @ptrFromInt(reg.GPIOE_BASE),
                .h => @ptrFromInt(reg.GPIOH_BASE),
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
