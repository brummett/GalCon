use v6;

use Planet;
use Player;

my Int $max_x = 10;
my Int $max_y = 10;

class Location {
    has Int $.x = die 'x is required';
    has Int $.y = die 'y is required';
    has Planet $.planet;

    method Str {
        my $owner = $.planet.owner;
        $owner //= 'no one';
        return "Location: ($.x, $.y), $.planet ";
    }

    method distance_to(Location $other) returns Int {
        my $a = abs(self.x - $other.x);
        my $b = abs(self.y - $other.y);
        return ceiling(sqrt($a ** 2 + $b ** 2));
    }
}

class Map {
    has Location @.locations;
    has Location %!planet_name_to_location;

    multi method new(Planet :@planets!, Owner :@players!) {
        my %picked_locations;
        my @locations = @planets.map: { create_location_for_planet($_) };
        my $self = callwith(locations => @locations);
        $self.assign_player_planets(@players);
        return $self;
    }

    multi method new(Location :@location!) {
        callsame;
    }

    sub create_location_for_planet(Planet $planet) returns Location {
        state Bool %picked_locations;

        loop {
            my $x = ( ^$max_x ).pick;
            my $y = ( ^$max_y ).pick;
            my $coord_str = "{$x}:{$y}";
            unless (%picked_locations{$coord_str}) {
                %picked_locations{$coord_str} = True;
                return Location.new(x => $x, y => $y, planet => $planet);
            }
        }
    }

    sub validate_num_planets(Int $num_planets is rw where * > 0)  {
        my $possible_locations = $max_x * $max_y;
        if ($possible_locations < $num_planets) {
            $num_planets = $possible_locations;
        }
    }

    method assign_player_planets(Player @players!) {
        my $player_count = @players.elems;
        for @players Z self.locations.pick($player_count) -> ($player, $location) {
            $location.planet.owner = $player;
        }
    }

    method location_for_planet_name(Str $name!) returns Location {
        unless (%!planet_name_to_location) {
            for @.locations -> $location {
                if ($location.planet.name eq $name) {
                    return $location;
                }
            }
        }
        return %!planet_name_to_location{$name} || Location;
    }
}
