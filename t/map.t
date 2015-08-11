use v6;

use Map;

use Test;

plan 1;

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
}, 'constructor';
