const reg = @import("stm32f401xe.zig");

const SysTick_Type = extern struct {
    CTRL: u32, // Offset: 0x000 (R/W)  SysTick Control and Status Register
    LOAD: u32, // Offset: 0x004 (R/W)  SysTick Reload Value Register
    VAL: u32, // Offset: 0x008 (R/W)  SysTick Current Value Register
    CALIB: u32, // Offset: 0x00C (R/ )  SysTick Calibration Register
};

const SysTick: *volatile SysTick_Type = @ptrFromInt(reg.SYSTICK_BASE);

pub fn Init(ticks: u32) void {
    SysTick.CTRL = 0;
    SysTick.LOAD = ticks;
    SysTick.VAL = 0;

    SysTick.CTRL |= reg.SYSTICK_CTRL_ENABLE | reg.SYSTICK_CTRL_TICKINT;
}
