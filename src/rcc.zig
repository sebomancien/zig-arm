const reg = @import("stm32f401xe.zig");

const RCC_TypeDef = extern struct {
    CR: u32, // RCC clock control register,                                  Address offset: 0x00
    PLLCFGR: u32, // RCC PLL configuration register,                              Address offset: 0x04
    CFGR: u32, // RCC clock configuration register,                            Address offset: 0x08
    CIR: u32, // RCC clock interrupt register,                                Address offset: 0x0C
    AHB1RSTR: u32, // RCC AHB1 peripheral reset register,                          Address offset: 0x10
    AHB2RSTR: u32, // RCC AHB2 peripheral reset register,                          Address offset: 0x14
    AHB3RSTR: u32, // RCC AHB3 peripheral reset register,                          Address offset: 0x18
    RESERVED0: u32, // Reserved, 0x1C
    APB1RSTR: u32, // RCC APB1 peripheral reset register,                          Address offset: 0x20
    APB2RSTR: u32, // RCC APB2 peripheral reset register,                          Address offset: 0x24
    RESERVED1: [2]u32, // Reserved, 0x28-0x2C
    AHB1ENR: u32, // RCC AHB1 peripheral clock register,                          Address offset: 0x30
    AHB2ENR: u32, // RCC AHB2 peripheral clock register,                          Address offset: 0x34
    AHB3ENR: u32, // RCC AHB3 peripheral clock register,                          Address offset: 0x38
    RESERVED2: u32, // Reserved, 0x3C
    APB1ENR: u32, // RCC APB1 peripheral clock enable register,                   Address offset: 0x40
    APB2ENR: u32, // RCC APB2 peripheral clock enable register,                   Address offset: 0x44
    RESERVED3: [2]u32, // Reserved, 0x48-0x4C
    AHB1LPENR: u32, // RCC AHB1 peripheral clock enable in low power mode register, Address offset: 0x50
    AHB2LPENR: u32, // RCC AHB2 peripheral clock enable in low power mode register, Address offset: 0x54
    AHB3LPENR: u32, // RCC AHB3 peripheral clock enable in low power mode register, Address offset: 0x58
    RESERVED4: u32, // Reserved, 0x5C
    APB1LPENR: u32, // RCC APB1 peripheral clock enable in low power mode register, Address offset: 0x60
    APB2LPENR: u32, // RCC APB2 peripheral clock enable in low power mode register, Address offset: 0x64
    RESERVED5: [2]u32, // Reserved, 0x68-0x6C
    BDCR: u32, // RCC Backup domain control register,                          Address offset: 0x70
    CSR: u32, // RCC clock control & status register,                         Address offset: 0x74
    RESERVED6: [2]u32, // Reserved, 0x78-0x7C
    SSCGR: u32, // RCC spread spectrum clock generation register,               Address offset: 0x80
    PLLI2SCFGR: u32, // RCC PLLI2S configuration register,                           Address offset: 0x84
    RESERVED7: [1]u32, // Reserved, 0x88
    DCKCFGR: u32, // RCC Dedicated Clocks configuration register,                 Address offset: 0x8C
};

const RCC: *volatile RCC_TypeDef = @ptrFromInt(reg.RCC_BASE);

pub fn EnableGPIOA() void {
    RCC.AHB1ENR |= reg.RCC_AHB1ENR_GPIOAEN;
}
