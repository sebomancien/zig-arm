const app = @import("main.zig");

extern var _sidata: u8;
extern var _sdata: u8;
extern var _edata: u8;
extern var _sbss: u8;
extern var _ebss: u8;

export fn Default_Handler() noreturn {
    while (true) {}
}

export fn Reset_Handler() noreturn {
    const data_len = @intFromPtr(&_edata) - @intFromPtr(&_sdata);
    @memcpy(
        @as([*]u8, @ptrCast(&_sdata))[0..data_len],
        @as([*]const u8, @ptrCast(&_sidata))[0..data_len],
    );

    const bss_len = @intFromPtr(&_ebss) - @intFromPtr(&_sbss);
    @memset(@as([*]u8, @ptrCast(&_sbss))[0..bss_len], 0);

    app.main();
    while (true) {}
}

export const g_pfnVectors linksection(".isr_vector") = blk: {
    const H = ?*const anyopaque;
    const dh: H = @ptrCast(&Default_Handler);
    const rh: H = @ptrCast(&Reset_Handler);
    const sh: H = @ptrCast(&app.SysTick_Handler);
    break :blk [_]H{
        @ptrFromInt(0x20018000), // 0:  SP (_estack = ORIGIN(RAM) + LENGTH(RAM))
        rh,                      // 1:  Reset
        dh,                      // 2:  NMI
        dh,                      // 3:  HardFault
        dh,                      // 4:  MemManage
        dh,                      // 5:  BusFault
        dh,                      // 6:  UsageFault
        null, null, null, null,  // 7-10: Reserved
        dh,                      // 11: SVCall
        dh,                      // 12: DebugMon
        null,                    // 13: Reserved
        dh,                      // 14: PendSV
        sh,                      // 15: SysTick
        dh,                      // 16: WWDG
        dh,                      // 17: PVD
        dh,                      // 18: TAMP_STAMP
        dh,                      // 19: RTC_WKUP
        dh,                      // 20: FLASH
        dh,                      // 21: RCC
        dh,                      // 22: EXTI0
        dh,                      // 23: EXTI1
        dh,                      // 24: EXTI2
        dh,                      // 25: EXTI3
        dh,                      // 26: EXTI4
        dh,                      // 27: DMA1_Stream0
        dh,                      // 28: DMA1_Stream1
        dh,                      // 29: DMA1_Stream2
        dh,                      // 30: DMA1_Stream3
        dh,                      // 31: DMA1_Stream4
        dh,                      // 32: DMA1_Stream5
        dh,                      // 33: DMA1_Stream6
        dh,                      // 34: ADC
        null, null, null, null,  // 35-38: Reserved
        dh,                      // 39: EXTI9_5
        dh,                      // 40: TIM1_BRK_TIM9
        dh,                      // 41: TIM1_UP_TIM10
        dh,                      // 42: TIM1_TRG_COM_TIM11
        dh,                      // 43: TIM1_CC
        dh,                      // 44: TIM2
        dh,                      // 45: TIM3
        dh,                      // 46: TIM4
        dh,                      // 47: I2C1_EV
        dh,                      // 48: I2C1_ER
        dh,                      // 49: I2C2_EV
        dh,                      // 50: I2C2_ER
        dh,                      // 51: SPI1
        dh,                      // 52: SPI2
        dh,                      // 53: USART1
        dh,                      // 54: USART2
        null,                    // 55: Reserved
        dh,                      // 56: EXTI15_10
        dh,                      // 57: RTC_Alarm
        dh,                      // 58: OTG_FS_WKUP
        null, null, null, null,  // 59-62: Reserved
        dh,                      // 63: DMA1_Stream7
        null,                    // 64: Reserved
        dh,                      // 65: SDIO
        dh,                      // 66: TIM5
        dh,                      // 67: SPI3
        null, null, null, null,  // 68-71: Reserved
        dh,                      // 72: DMA2_Stream0
        dh,                      // 73: DMA2_Stream1
        dh,                      // 74: DMA2_Stream2
        dh,                      // 75: DMA2_Stream3
        dh,                      // 76: DMA2_Stream4
        null, null, null,        // 77-79: Reserved
        null, null, null,        // 80-82: Reserved
        dh,                      // 83: OTG_FS
        dh,                      // 84: DMA2_Stream5
        dh,                      // 85: DMA2_Stream6
        dh,                      // 86: DMA2_Stream7
        dh,                      // 87: USART6
        dh,                      // 88: I2C3_EV
        dh,                      // 89: I2C3_ER
        null, null, null, null,  // 90-93: Reserved
        null, null, null,        // 94-96: Reserved
        dh,                      // 97: FPU
        null, null,              // 98-99: Reserved
        dh,                      // 100: SPI4
    };
};
