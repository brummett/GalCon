use v6;

use Map;
use Planet;

use Test;
plan 3;

subtest {
    plan 5;

    my $num_planets = 5;
    my %player_names = Bob => 'Bob', Fred => 'Fred';

    my Planet @planets = (1 .. $num_planets).map: { Planet.new() };
    my Player @players = %player_names.keys.map: { Player.new(name => $_) };
    my $map = Map.new(planets => @planets, players => @players);
    ok $map, 'Create map';

    my Location @locations = $map.locations;
    is @locations.elems, $num_planets, 'Location count';

    my %owned_planet_owners;
    for @locations -> $location {
        my Planet $planet = $location.planet;
        next unless $planet.owner;
        %owned_planet_owners{ $planet.owner.name }++;
    }
    is %owned_planet_owners.keys.elems, %player_names.keys.elems, 'number of planet owners';
    for %player_names.keys -> $name {
        is %owned_planet_owners{ $name }, 1, "Player $name has 1 planet";
    }
}, 'map constructor';

subtest {
    plan 6;

    my $num_planets = 5;
    my %player_names = Bob => 'Bob', Fred => 'Fred';

    my Planet @planets = (1 .. $num_planets).map: { Planet.new() };
    my Player @players = %player_names.keys.map: { Player.new(name => $_) };
    my $map = Map.new(planets => @planets, players => @players);

    for @planets -> $planet {
        my $location = $map.location_for_planet_name($planet.name);
        ok $location, "got location for { $planet.name }";
    }

    ok ! $map.location_for_planet_name('bogus'), 'bogus planet name has no location';
}, 'location_for_planet_name';

subtest {
    plan 8;

    my $origin = Location.new(x => 0, y => 0, planet => Planet.new);
    is $origin.distance_to($origin),
        0,
        'origin to self is 0';

    my $location_1 = Location.new(x => 1, y => 0, planet => Planet.new);
    is $location_1.distance_to($location_1),
        0,
        'location_1 to self is 0';
    is $origin.distance_to($location_1),
        1,
        'origin to (1, 0)';
    is $location_1.distance_to($origin),
        1,
        '(1, 0) to origin';

    my $location_1_1 = Location.new(x => 1, y => 1, planet => Planet.new);
    is $location_1_1.distance_to($location_1_1),
        0,
        '(1,1) to self is 0';
    is $origin.distance_to($location_1_1),
        2,
        'origin to (1,1) is 2';
    is $location_1_1.distance_to($origin),
        2,
        '(1,1) to origin is 2';
    is $location_1.distance_to($location_1_1),
        1,
        '(1,0) to (1,1) is 1';

}, 'location distance';

