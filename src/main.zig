const std = @import("std");
const bedrock = @import("bedrock.zig");

// IF YOU WANT TO CHANGE THE PATTERN, DO THAT HERE!
// Layers along Y, rows along Z, columns along X
// const pattern: []const []const []const ?bedrock.Block = &.{&.{
//     &.{ .other, .other, .other, .other, .bedrock, .other, .other },
//     &.{ .other, .other, .bedrock, .other, .other, .other, .other },
//     &.{ .other, .other, .other, .bedrock, .other, .other, .bedrock },
    
//     &.{ .other, .bedrock, .other, .other, .bedrock, .other, .other },
//     &.{ .bedrock, .other, .other, .bedrock, .other, .other, .other },
//     &.{ .other, .other, .other, .other, .other, .other, .other },
//     &.{ .other, .bedrock, .other, .other, .other, .other, .other },
//     &.{ .bedrock, .bedrock, .other, .bedrock, .other, .other, .other },
// }};

const pattern: []const []const []const ?bedrock.Block = &.{&.{
    &.{ .other, .other, .other, .other, .bedrock, .other, .other },
    &.{ .other, .other, .bedrock, .other, .other, .other, .other },
    &.{ .other, .other, .other, .bedrock, .other, .other, .bedrock },
    
    &.{ .other, .bedrock, .other, .other, .bedrock, .other, .other },
    &.{ .bedrock, .other, .other, .bedrock, .other, .other, .other },
    &.{ .other, .other, .other, .other, .other, .other, .other },
    &.{ .other, .bedrock, .other, .other, .other, .other, .other },
    &.{ .bedrock, .bedrock, .other, .bedrock, .other, .other, .other },
}};

//        -Z
//
//   -X    O     +X
//
//        +Z

const seed: i64 = 8809845658733832902;
const range: i32 = 200000;
const threadN: i32 = 4;

pub fn main() anyerror!void {
    const finder = bedrock.PatternFinder{
        .gen = bedrock.GradientGenerator.overworldFloor(seed),
        .pattern = pattern,
    };

    var Threads: [threadN*threadN]std.Thread = undefined;

    for (0..threadN) |x| {
        for (0..threadN) |z| {
            const thread = try std.Thread.spawn(.{}, searchThread, .{ finder, x, z });
            Threads[z*threadN + x] = thread;
        }
    }

    for (Threads) |thread| {
        thread.join();
    }
}

fn searchThread(finder: bedrock.PatternFinder, x: usize, z: usize) void {
    const patternLen: i32 = if (pattern[0][0].len > pattern[0].len) pattern[0][0].len else pattern[0][0].len;
    finder.search(
        .{
            .x = -range + @as(i32, @intCast(x)) * 2 * @divFloor(range, threadN) - patternLen,
            .y = -60,
            .z = -range + @as(i32, @intCast(z)) * 2 * @divFloor(range, threadN) - patternLen,
        },
        .{
            .x = -range + (@as(i32, @intCast(x)) + 1) * 2 * @divFloor(range, threadN) + patternLen,
            .y = -60,
            .z = -range + (@as(i32, @intCast(z)) + 1) * 2 * @divFloor(range, threadN) + patternLen,
        },
        {},
        reportResult,
        null,
    );
}

fn reportResult(_: void, p: bedrock.Point) void {
    std.debug.print("{} {} {}\n", .{ p.x, p.y, p.z });
}
