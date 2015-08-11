use v6;

use Fleet;
use Player;

use Test;
plan 1;

subtest {
    plan 1;

    my $owner = Player.new(name => 'Bob');
    my $fleet = Fleet.new(owner => $owner,
                          troops => 5,
                          destination => 'somewhere',
                          distance => 5);
    ok $fleet, 'Create fleet';
}, 'constructor';
