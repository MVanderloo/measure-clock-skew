const std = @import("std");
const Io = std.Io;

const measure_clock_skew = @import("measure_clock_skew");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // clock stuff
    const clock = std.Io.Clock.real;
    const monotonic_clock = std.Io.Clock.boot;
    var int_buffer: [128]u8 = undefined;
    const start = clock.now(io).toMicroseconds();

    std.log.info("Starting measurement at %d\n", .{start});

    // stdout stuff
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    while (true) {
        const duration_us = clock.now(io).toMicroseconds() - start;
        const len = std.fmt.printInt(int_buffer[0..], duration_us, 10, .lower, .{});
        int_buffer[len] = '\n';
        _ = try stdout_writer.write(int_buffer[0 .. len + 1]);
        try std.Io.sleep(io, std.Io.Duration.fromMilliseconds(1), monotonic_clock);
    }

    try stdout_writer.flush();
}
