const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("blockchain", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "demo-blockchain",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "blockchain", .module = mod },
            },
        }),
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Executa a demo da blockchain");
    run_step.dependOn(&run_cmd.step);

    const mod_tests = b.addTest(.{ .root_module = mod });
    const test_step = b.step("test", "Executa os testes");
    test_step.dependOn(&b.addRunArtifact(mod_tests).step);

    // Shared library (C ABI) for the Go playground API.
    const eng = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "blockchain_engine",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/c_api.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "blockchain", .module = mod },
            },
        }),
    });
    b.installArtifact(eng);
    const eng_step = b.step("engine", "Build shared library blockchain_engine");
    eng_step.dependOn(&b.addInstallArtifact(eng, .{}).step);
}