const std = @import("std");

pub fn build(b: *std.Build) void {
    const extracter = b.addExecutable(.{
        .name = "step1_extract",
        .root_source_file = b.path("tools/step1_extract.zig"),
        .target = b.host,
    });

    const generator = b.addExecutable(.{
        .name = "step2_generator",
        .root_source_file = b.path("tools/step2_generate.zig"),
        .target = b.host,
    });

    const step1 = b.addRunArtifact(extracter);
    step1.addFileArg(b.path("src/foo.c"));
    const foo_header = step1.addOutputFileArg("foo.generated.h");

    const step2 = b.addRunArtifact(generator);
    step2.addFileArg(foo_header);
    const rpc_bindings_header = step2.addOutputFileArg("foo.rpc_bindings.h");

    // dummy installs so that output state is visible..
    b.getInstallStep().dependOn(&b.addInstallFileWithDir(foo_header, .header, "foo.generated.h").step);
    b.getInstallStep().dependOn(&b.addInstallFileWithDir(rpc_bindings_header, .header, "foo.rpc_bindings.h").step);
}
