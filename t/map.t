use v6;

use Map;
use Planet;

use Test;
plan 5;

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

subtest {
    plan 15;

    my %player_names = Bob => 'Bob', Fred => 'Fred';
    my @location_coords = ( ('One', 0, 0), ('Two', 1, 0), ('Three', 2, 0) );

    my %planets;
    my Location @locations = do for @location_coords -> $planet_name, $x, $y {
            my $planet = Planet.new(name => $planet_name, troops => 5);
            %planets{$planet_name} = $planet;
            Location.new(x => $x, y => $y, planet => $planet);
        };

    my $map = Map.new(locations => @locations);

    my $fleet_1 = $map.new_fleet(source => 'One',
                                 destination => 'Two',
                                 count => 2);
    ok $fleet_1, 'Create fleet';
    is $fleet_1.troops, 2, 'Fleet troops';
    is $fleet_1.distance, 1, 'distance is 1';
    is %planets{'One'}.troops, 3, 'Source planet deducted troops';
    is %planets{'Two'}.troops, 5, 'Destination planet did not deduct troops';
    is $map.fleets.elems, 1, 'map has 1 fleet';

    my $fleet_2 = $map.new_fleet(source => 'Two',
                                 destination => 'Two',
                                 count => 2);
    ok $fleet_2, 'create fleet 2';
    is $fleet_2.distance, 0, 'distance is 0';
    is $map.fleets[0], $fleet_2, 'First fleet is fleet 2';
    is $map.fleets[1], $fleet_1, 'Second fleet fleet 1';

    my $fleet_3 = $map.new_fleet(source => 'Three',
                                 destination => 'One',
                                 count => 2);
    ok $fleet_3, 'create fleet 3';
    is $fleet_3.distance, 2, 'distance is 2';
    is $map.fleets[0], $fleet_2, 'First fleet is fleet 2';
    is $map.fleets[1], $fleet_1, 'Second fleet is fleet 1';
    is $map.fleets[2], $fleet_3, 'Third fleet is fleet 3';
}, 'new_fleet';

subtest {
    plan 7;
    my $map = Map.new(locations => ());

    my @landing_fleets = $map.fleets_landing_this_turn;
    is @landing_fleets.elems, 0, 'no fleets landing with empty list';

    my @fleets = (0, 0, 0).map: { Fleet.new(distance => $_, troops => 1, destination => 'foo') };
    $map.fleets.push(@fleets);
    @landing_fleets = $map.fleets_landing_this_turn();
    is @landing_fleets.elems, @fleets.elems, 'All fleets are landing';
    is $map.fleets.elems, 0, 'No fleets left on the map';

    @fleets = (0, 0, 1, 4, 6).map: { Fleet.new(distance => $_, troops => 1, destination => 'foo') };
    $map.fleets.push(@fleets);
    @landing_fleets = $map.fleets_landing_this_turn();
    is @landing_fleets.elems, 2, 'Two fleets landing this turn';
    is $map.fleets.elems, 3, '3 fleets left on the map';

    @landing_fleets = $map.fleets_landing_this_turn();
    is @landing_fleets.elems, 0, 'no fleets landing with all positive distances';
    is $map.fleets.elems, 3, '3 fleets still on the map';
}, 'fleets_landing_this_turn';
