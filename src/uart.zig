const MMIO = @import("stm32f401xe.zig");
const RCC = @import("rcc.zig");
const register = @import("register.zig");

pub const Access = register.Access;
pub const FieldSpec = register.FieldSpec;
pub const Reg = register.Reg;

const SR_Fields = struct {
    pub const PE = FieldSpec{ .offset = 0, .width = 1, .access = .ro };
    pub const FE = FieldSpec{ .offset = 1, .width = 1, .access = .ro };
    pub const NF = FieldSpec{ .offset = 2, .width = 1, .access = .ro };
    pub const ORE = FieldSpec{ .offset = 3, .width = 1, .access = .ro };
    pub const IDLE = FieldSpec{ .offset = 4, .width = 1, .access = .ro };
    pub const RXNE = FieldSpec{ .offset = 5, .width = 1, .access = .rc_w0 };
    pub const TC = FieldSpec{ .offset = 6, .width = 1, .access = .rc_w0 };
    pub const TXE = FieldSpec{ .offset = 7, .width = 1, .access = .ro };
    pub const LBD = FieldSpec{ .offset = 8, .width = 1, .access = .rc_w0 };
    pub const CTS = FieldSpec{ .offset = 9, .width = 1, .access = .rc_w0 };
};

const DR_Fields = struct {
    pub const DR = FieldSpec{ .offset = 0, .width = 9, .access = .rw };
};

const BRR_Fields = struct {
    pub const DIV_Fraction = FieldSpec{ .offset = 0, .width = 4, .access = .rw };
    pub const DIV_Mantissa = FieldSpec{ .offset = 4, .width = 12, .access = .rw };
};

const CR1_Fields = struct {
    pub const SBK = FieldSpec{ .offset = 0, .width = 1, .access = .rw };
    pub const RWU = FieldSpec{ .offset = 1, .width = 1, .access = .rw };
    pub const RE = FieldSpec{ .offset = 2, .width = 1, .access = .rw };
    pub const TE = FieldSpec{ .offset = 3, .width = 1, .access = .rw };
    pub const IDLEIE = FieldSpec{ .offset = 4, .width = 1, .access = .rw };
    pub const RXNEIE = FieldSpec{ .offset = 5, .width = 1, .access = .rw };
    pub const TCIE = FieldSpec{ .offset = 6, .width = 1, .access = .rw };
    pub const TXEIE = FieldSpec{ .offset = 7, .width = 1, .access = .rw };
    pub const PEIE = FieldSpec{ .offset = 8, .width = 1, .access = .rw };
    pub const PS = FieldSpec{ .offset = 9, .width = 1, .access = .rw };
    pub const PCE = FieldSpec{ .offset = 10, .width = 1, .access = .rw };
    pub const WAKE = FieldSpec{ .offset = 11, .width = 1, .access = .rw };
    pub const M = FieldSpec{ .offset = 12, .width = 1, .access = .rw };
    pub const UE = FieldSpec{ .offset = 13, .width = 1, .access = .rw };
    pub const OVER8 = FieldSpec{ .offset = 15, .width = 1, .access = .rw };
};

const CR2_Fields = struct {
    pub const ADD = FieldSpec{ .offset = 0, .width = 4, .access = .rw };
    pub const LBDL = FieldSpec{ .offset = 5, .width = 1, .access = .rw };
    pub const LBDIE = FieldSpec{ .offset = 6, .width = 1, .access = .rw };
    pub const LBCL = FieldSpec{ .offset = 8, .width = 1, .access = .rw };
    pub const CPHA = FieldSpec{ .offset = 9, .width = 1, .access = .rw };
    pub const CPOL = FieldSpec{ .offset = 10, .width = 1, .access = .rw };
    pub const CLKEN = FieldSpec{ .offset = 11, .width = 1, .access = .rw };
    pub const STOP = FieldSpec{ .offset = 12, .width = 2, .access = .rw };
    pub const LINEN = FieldSpec{ .offset = 14, .width = 1, .access = .rw };
};

const CR3_Fields = struct {
    pub const EIE = FieldSpec{ .offset = 0, .width = 1, .access = .rw };
    pub const IREN = FieldSpec{ .offset = 1, .width = 1, .access = .rw };
    pub const IRLP = FieldSpec{ .offset = 2, .width = 1, .access = .rw };
    pub const HDSEL = FieldSpec{ .offset = 3, .width = 1, .access = .rw };
    pub const NACK = FieldSpec{ .offset = 4, .width = 1, .access = .rw };
    pub const SCEN = FieldSpec{ .offset = 5, .width = 1, .access = .rw };
    pub const DMAR = FieldSpec{ .offset = 6, .width = 1, .access = .rw };
    pub const DMAT = FieldSpec{ .offset = 7, .width = 1, .access = .rw };
    pub const RTSE = FieldSpec{ .offset = 8, .width = 1, .access = .rw };
    pub const CTSE = FieldSpec{ .offset = 9, .width = 1, .access = .rw };
    pub const CTSIE = FieldSpec{ .offset = 10, .width = 1, .access = .rw };
    pub const ONEBIT = FieldSpec{ .offset = 11, .width = 1, .access = .rw };
};

const GTPR_Fields = struct {
    pub const PSC = FieldSpec{ .offset = 0, .width = 8, .access = .rw };
    pub const GT = FieldSpec{ .offset = 8, .width = 8, .access = .rw };
};

const Register = extern struct {
    SR: Reg(SR_Fields),
    DR: Reg(DR_Fields),
    BRR: Reg(BRR_Fields),
    CR1: Reg(CR1_Fields),
    CR2: Reg(CR2_Fields),
    CR3: Reg(CR3_Fields),
    GTPR: Reg(GTPR_Fields),
};

pub const Uart = struct {
    pub const Instance = enum { usart1, usart2, usart6 };

    instance: *volatile Register,

    pub fn init(instance: Instance, baudrate: u32, pclk_hz: u32) Uart {
        const uart = Uart{
            .instance = switch (instance) {
                .usart1 => blk: {
                    RCC.EnableUSART1();
                    break :blk @ptrFromInt(MMIO.USART1_BASE);
                },
                .usart2 => blk: {
                    RCC.EnableUSART2();
                    break :blk @ptrFromInt(MMIO.USART2_BASE);
                },
                .usart6 => blk: {
                    RCC.EnableUSART6();
                    break :blk @ptrFromInt(MMIO.USART6_BASE);
                },
            },
        };
        uart.instance.CR1.write(0);
        uart.instance.BRR.write((pclk_hz + baudrate / 2) / baudrate);
        uart.instance.CR1.modify(.{ .UE = 1, .TE = 1, .RE = 1 });
        return uart;
    }

    fn readByte(self: Uart) u8 {
        while (self.instance.SR.get(.RXNE) == 0) {}
        return @as(u8, @truncate(self.instance.DR.get(.DR)));
    }

    fn writeByte(self: Uart, byte: u8) void {
        while (self.instance.SR.get(.TXE) == 0) {}
        self.instance.DR.write(byte);
    }

    pub fn read(self: Uart, data: []u8) void {
        for (data) |*byte| byte.* = self.readByte();
    }

    pub fn write(self: Uart, data: []const u8) void {
        for (data) |byte| self.writeByte(byte);
    }

    pub fn isTxReady(self: Uart) bool {
        return self.instance.SR.get(.TXE) != 0;
    }

    pub fn isRxReady(self: Uart) bool {
        return self.instance.SR.get(.RXNE) != 0;
    }

    pub fn flushTx(self: Uart) void {
        while (self.instance.SR.get(.TC) == 0) {}
    }
};
