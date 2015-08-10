use v6;

use Player;

use Test;

plan 1;

subtest {
    plan 2;

    dies-ok { Player.new() },
        'Creating new player with no params throws exception';

    lives-ok { Player.new(name => 'Bob') },
        'Creating new player with name works';
}
