const std = @import("std");

fn askUser()!i64 {
    var buf: [10]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Guess a number between 1 and 100: ",.{});
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        return std.fmt.parseInt(i64, user_input, 10);
    } else {
        return error.InvalidParam;
    }
}

pub fn main()!void {
    var prng = std.rand.DefaultPrng.init(std.time.milliTimestamp());
    const value = prng.random().intRangeAtMost(i64, 1, 100);
    const guess = try askUser();
    if (guess == value) {
        std.debug.print("That's right!\n",.{});
    } else {
        std.debug.print("Wrong guess. The number was {}\n",.{value});
    }
}

