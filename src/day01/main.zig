const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    const len = comptime blk: {
        // without this, it will fail with
        // error: evaluation exceeded 1000 backwards branches
        @setEvalBranchQuota(100000);
        var i: usize = 0;
        var it = std.mem.tokenizeScalar(u8, input, '\n');
        while (it.next()) |_| {
            i += 1;
        }
        break :blk i;
    };

    // part 1
    var leftArr: [len]i32 = .{0} ** len;
    var rightArr: [len]i32 = .{0} ** len;

    var i: usize = 0;
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var split = std.mem.split(u8, line, "   ");
        const left = try std.fmt.parseInt(i32, split.next().?, 10);
        const right = try std.fmt.parseInt(i32, split.next().?, 10);
        leftArr[i] = left;
        rightArr[i] = right;
        i += 1;
    }

    std.mem.sort(i32, &leftArr, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, &rightArr, {}, comptime std.sort.asc(i32));

    var dist: usize = 0;
    for (0..len) |j| {
        dist += @abs(leftArr[j] - rightArr[j]);
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("{d}\n", .{dist});

    // part 2
    var rightMap = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);
    defer rightMap.deinit();
    for (rightArr) |elem| {
        const key = elem;
        const value = rightMap.get(key) orelse 0;
        try rightMap.put(key, value + 1);
    }

    var sim: i32 = 0;
    for (leftArr) |elem| {
        const value = rightMap.get(elem) orelse 0;
        sim += elem * value;
    }
    try stdout.print("{d}\n", .{sim});

    try bw.flush();
}
