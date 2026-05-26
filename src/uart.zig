const reg = @import("stm32f401xe.zig");

const Register = extern struct {
    SR: u32,
    DR: u32,
    BRR: u32,
    CR1: u32,
    CR2: u32,
    CR3: u32,
    GTPR: u32,
};

const usart1: *volatile Register = @ptrFromInt(reg.USART1_BASE);
const usart2: *volatile Register = @ptrFromInt(reg.USART2_BASE);
const usart6: *volatile Register = @ptrFromInt(reg.USART6_BASE);

pub const Uart = struct {
    pub const Instance = enum { usart1, usart2, usart6 };

    // SR bits
    const srRxne: u32 = 1 << 5; // Read data register not empty
    const srTxe: u32 = 1 << 7; // Transmit data register empty
    const srTc: u32 = 1 << 6; // Transmission complete

    // CR1 bits
    const cr1Re: u32 = 1 << 2; // Receiver enable
    const cr1Te: u32 = 1 << 3; // Transmitter enable
    const cr1Ue: u32 = 1 << 13; // USART enable

    instance: *volatile Register,

    pub fn init(instance: Instance, baudrate: u32, pclk_hz: u32) Uart {
        const uart = Uart{
            .instance = switch (instance) {
                .usart1 => usart1,
                .usart2 => usart2,
                .usart6 => usart6,
            },
        };
        uart.instance.CR1 = 0;
        uart.instance.BRR = (pclk_hz + baudrate / 2) / baudrate;
        uart.instance.CR1 = cr1Ue | cr1Te | cr1Re;
        return uart;
    }

    fn readByte(self: Uart) u8 {
        while ((self.instance.SR & srRxne) == 0) {}
        return @truncate(self.instance.DR);
    }

    fn writeByte(self: Uart, byte: u8) void {
        while ((self.instance.SR & srTxe) == 0) {}
        self.instance.DR = byte;
    }

    pub fn read(self: Uart, data: []u8) void {
        for (data) |*byte| byte.* = self.readByte();
    }

    pub fn write(self: Uart, data: []const u8) void {
        for (data) |byte| self.writeByte(byte);
    }

    pub fn isTxReady(self: Uart) bool {
        return (self.instance.SR & srTxe) != 0;
    }

    pub fn isRxReady(self: Uart) bool {
        return (self.instance.SR & srRxne) != 0;
    }

    pub fn flushTx(self: Uart) void {
        while ((self.instance.SR & srTc) == 0) {}
    }
};
