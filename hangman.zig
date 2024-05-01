const std = @import("std");

fn get_input(guesses: i32)!i64 {
    // This part talks to the keyboard to get your guess.
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [10]u8 = undefined;

    // The computer asks you to guess a number.
    try stdout.print("({d}) Guess a number between 1 and 100: ",.{guesses});

    // If you press 'x', the game ends.
    if (try stdin.readUntilDelimiterOrEof(buf[0..],'\n')) |user_input| {
        if (std.mem.eql(u8, user_input,"x")) {
            return error.Exit;
        } else {
            // If you guess a number, the computer tries to understand it.
            const x = std.fmt.parseInt(i64, user_input, 10);
            return x;
        }
    } else {
        // If you don't guess anything, the game asks you to try again.
        return error.InvalidParam;
    }
}

pub fn main()!void {
    // This is where the game starts.
    const stdout = std.io.getStdOut().writer();

    // The computer picks a secret number.
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    const value = prng.random().intRangeAtMost(i64, 1, 100);

    // You start guessing.
    var winCon = false;
    var guesses: i32 = 0;

    while (true) {
        guesses = guesses + 1;

        // You guess a number.
        const guess = get_input(guesses) catch |err| {
            // If you guess 'x', the game ends.
            switch (err) {
                error.InvalidCharacter => {
                    // If you guess something that's not a number, the game asks you to guess again.
                    try stdout.print("\x1b[31mPlease enter a number.\x1b[0m\n",.{});
                    continue;
                },
                error.Exit => break,
                else => return err
            }
        };

        // The computer checks if your guess is right.
        if (guess == value) {
            winCon = true;
            break;
        }

        // If your guess is too high or too low, the computer tells you.
        const message = if (guess < value) "\x1b[33mlow\x1b[0m" else "\x1b[31mhigh\x1b[0m";
        try stdout.print("{d} is too {s}.\n",.{guess, message});
    }

    // If you guess right, the computer celebrates with you!
    if (winCon) {
        try stdout.print("\x1b[32m({d}) Right The number was {d}.\x1b[0m",.{guesses, value});
    } else {
        // If you don't guess right, the game ends.
        try stdout.print("Bye!",.{});
    }
}

