use v6;

use Planet;
use Player;

use Test;

plan 2;

subtest {
    plan 7;

    my $planet = Planet.new();
    ok $planet, 'Create a planet';
    ok $planet.name, 'Planet has a name';
    ok $planet.troops, 'Planet has some troops';
    ok $planet.production, 'Planet has production';
    ok !($planet.owner), 'Planet has no owner';

    my $other_planet = Planet.new();
    ok $other_planet, 'Create another planet';
    isnt $planet.name, $other_planet.name, 'Planet names differ';
}, 'Constructor';

subtest {
    plan 5;

    my $planet = Planet.new();
    dies-ok { $planet.name = 'Bob' }, 'Cannot change name';
    dies-ok { $planet.production = 100 }, 'Cannot change production';
    lives-ok { $planet.troops = 100 }, 'troops is changable';

    my $player = Player.new(name => 'Bob');
    lives-ok { $planet.owner = $player }, 'owner is changable';
    dies-ok { $planet.owner = Player }, 'cannot unset owner';
}, 'Accessors';
