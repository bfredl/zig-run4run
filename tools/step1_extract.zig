const std = @import("std");

pub fn main() !void {
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const argv = std.os.argv;
    if (argv.len < 3) return error.TooFewArguments;
    const input_file_path = std.mem.span(argv[1]);
    const output_file_path = std.mem.span(argv[2]);

    var input_file = try std.fs.cwd().openFile(input_file_path, .{});
    defer input_file.close();

    var output_file = try std.fs.cwd().createFile(output_file_path, .{});
    defer output_file.close();

    const reader = input_file.reader();

    while (try reader.readUntilDelimiterOrEofAlloc(arena, '\n', 1024)) |line| {
        if (line.len >= 5 and std.mem.eql(u8, line[0..5], "void ")) {
            try output_file.writeAll(line);
            try output_file.writeAll(";\n");
        }
    }
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
