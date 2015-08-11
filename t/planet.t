use v6;

use Planet;
use Player;

use Test;

plan 5;

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

subtest {
    plan 5;

    my $planet = Planet.new(troops => 5);
    is $planet.withdraw_troops(1), 1, 'Withdraw 1';
    is $planet.troops, 4, 'planet now has 4 troops';

    dies-ok { $planet.withdraw_troops(99) }, 'Cannot withdraw 99';

    is $planet.withdraw_troops(4), 4, 'Withdraw 4';
    is $planet.troops, 0, 'Planet has 0 troops';
}, 'troops';

subtest {
    plan 13;

    my $owner = Owner.new(name => 'Bob');
    my $planet = Planet.new(name => 'Foo', troops => 5, owner => $owner);
    my $wrong_dest_fleet = Fleet.new(owner => $owner, destination => 'Bar', troops => 3, distance => 0);
    dies-ok { $planet.land_fleet($wrong_dest_fleet) }, 'Cannot land a fleet with the wrong destination';

    my $wrong_distance_fleet = Fleet.new(owner => $owner, destination => 'Foo', troops => 3, distance => 1);
    dies-ok { $planet.land_fleet($wrong_distance_fleet) }, 'Cannot land a fleet with positive distance';

    my $friendly = Fleet.new(owner => $owner, destination => 'Foo', troops => 3, distance => 0);
    ok $planet.land_fleet($friendly), 'land friendly fleet';
    is $planet.troops, 8, 'added troops';

    my $other_owner = Owner.new(name => 'Fred');
    my $foe_1 = Fleet.new(owner => $other_owner, destination => 'Foo', troops => 3, distance => 0);
    ok $planet.land_fleet($foe_1), 'land foe fleet';
    is $planet.troops, 5, 'subtracted troops';
    is $planet.owner, $owner, 'planet owned by original owner';

    my $foe_2 = Fleet.new(owner => $other_owner, destination => 'Foo', troops => 5, distance => 0);
    ok $planet.land_fleet($foe_2), 'land second foe fleet';
    is $planet.troops, 0, 'subtracted troops';
    is $planet.owner, $owner, 'planet still owned by original owner';

    my $foe_3 = Fleet.new(owner => $other_owner, destination => 'Foo', troops => 5, distance => 0);
    ok $planet.land_fleet($foe_3), 'land third foe fleet';
    is $planet.troops, 5, 'subtracted troops';
    is $planet.owner, $other_owner, 'planet owned by new owner';
}, 'land_fleet';

subtest {
    plan 6;

    my $unowned = Planet.new(troops => 5, production => 5);
    ok ! $unowned.produce, 'produce on an unowned planet returns false';
    is $unowned.troops, 5, 'did not add troops';

    my $owner = Player.new(name => 'Bob');
    my $planet = Planet.new(troops => 0, production => 5, owner => $owner);
    is $planet.produce, 5, 'produce';
    is $planet.troops, 5, 'has 5 troops';

    is $planet.produce, 10, 'produce again';
    is $planet.troops, 10, 'has 10 troops';
}, 'production';
