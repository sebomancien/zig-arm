const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const exe = b.addExecutable(.{
        .name = "blink.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.addAssemblyFile(b.path("startup.s"));
    exe.setLinkerScript(b.path("linker.ld"));

    // Minimize runtime footprint
    exe.root_module.strip = true;
    exe.root_module.single_threaded = true;
    exe.link_function_sections = true;
    exe.link_data_sections = true;
    exe.link_gc_sections = true;
    exe.entry = .{ .symbol_name = "Reset_Handler" };

    b.installArtifact(exe);

    const bin = exe.addObjCopy(.{ .format = .bin });
    const installBin = b.addInstallBinFile(bin.getOutput(), "blink.bin");
    b.getInstallStep().dependOn(&installBin.step);
}
