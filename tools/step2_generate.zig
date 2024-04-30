const std = @import("std");

pub fn main() !void {
    const argv = std.os.argv;
    if (argv.len < 3) return error.TooFewArguments;
    const input_file_path = std.mem.span(argv[1]);
    const output_file_path = std.mem.span(argv[2]);

    var input_file = try std.fs.cwd().openFile(input_file_path, .{});
    defer input_file.close();

    var output_file = try std.fs.cwd().createFile(output_file_path, .{});
    defer output_file.close();

    const reader = input_file.reader();

    try output_file.writeAll("/* expensive RPC wrappers generated for\n\n");

    while (true) {
        const byte: u8 = reader.readByte() catch |err| switch (err) {
            error.EndOfStream => break,
            else => |e| return e,
        };

        try output_file.writer().writeByte(byte);
        std.time.sleep(20 * 1000 * 1000); // this is expensive!
    }

    try output_file.writeAll("\n\n*/\n");
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
