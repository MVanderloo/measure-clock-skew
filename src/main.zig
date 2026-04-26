const std = @import("std");
const Io = std.Io;

const measure_clock_skew = @import("measure_clock_skew");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // stdout stuff
    var stdout_buffer: [4096]u8 = undefined;
    var stdout_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);

    // clock stuff
    const clock = std.Io.Clock.real;
    const monotonic_clock = std.Io.Clock.boot;
    const offset = clock.now(io).toMicroseconds();

    std.log.info("Starting measurement at {d}", .{offset});

    var queue_buffer: [1000000]i64 = undefined;
    var times: std.Io.Queue(i64) = .init(&queue_buffer);

    var writer = try io.concurrent(write_queue, .{ io, &times, &stdout_writer.interface });
    defer writer.cancel(io) catch {};

    while (true) {
        const wall_time = clock.now(io).toMicroseconds();
        const monotonic_time = monotonic_clock.now(io).toMicroseconds();
        try times.putOne(io, wall_time - monotonic_time - offset);
        try std.Io.sleep(io, std.Io.Duration.fromMicroseconds(1000), monotonic_clock);
    }
}

/// Reads times from the queue and writes them to writer
fn write_queue(io: Io, queue: *Io.Queue(i64), writer: *Io.Writer) !void {
    var int_buffer: [1000000]i64 = undefined;
    var write_buffer: [32]u8 = undefined;

    while (true) {
        const item_count = queue.get(io, &int_buffer, 0) catch |err| switch (err) {
            error.Canceled => {
                try writer.flush();
                return;
            },
            else => return err,
        };

        for (int_buffer[0..item_count]) |duration_us| {
            const len = std.fmt.printInt(write_buffer[0..], duration_us, 10, .lower, .{});
            write_buffer[len] = '\n';
            _ = try writer.write(write_buffer[0 .. len + 1]);
        }

        try writer.flush();
    }
}
