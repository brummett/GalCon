use v6;

use Planet;

use Test;

plan 2;

subtest {
    plan 6;

    my $planet = Planet.new();
    ok $planet, 'Create a planet';
    ok $planet.name, 'Planet has a name';
    ok $planet.troops, 'Planet has some troops';
    ok $planet.production, 'Planet has production';

    my $other_planet = Planet.new();
    ok $other_planet, 'Create another planet';
    isnt $planet.name, $other_planet.name, 'Planet names differ';
}, 'Constructor';

subtest {
    plan 3;

    my $planet = Planet.new();
    dies-ok { $planet.name = 'Bob' }, 'Cannot change name';
    dies-ok { $planet.production = 100 }, 'Cannot change production';
    lives-ok { $planet.troops = 100 }, 'troops is changable';
}
