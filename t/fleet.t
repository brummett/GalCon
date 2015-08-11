use v6;

use Fleet;
use Player;

use Test;
plan 2;

subtest {
    plan 1;

    my $owner = Player.new(name => 'Bob');
    my $fleet = Fleet.new(owner => $owner,
                          troops => 5,
                          destination => 'somewhere',
                          distance => 5);
    ok $fleet, 'Create fleet';
}, 'constructor';

subtest {
    plan 6;

    my $owner = Player.new(name => 'Bob');
    my $fleet = Fleet.new(owner => $owner,
                          troops => 5,
                          destination => 'somewhere',
                          distance => 3);
    is $fleet.move, 2, 'move';
    is $fleet.distance, 2, 'moved to 2';

    is $fleet.move, 1, 'move again';
    is $fleet.distance, 1, 'moved to 1';

    is $fleet.move, 0, 'move again';
    is $fleet.distance, 0, 'moved to 0';
}, 'move';
