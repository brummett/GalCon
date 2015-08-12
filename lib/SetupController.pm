use v6;

use WebController;
use Player;

class SetupController is WebController {
    has Int $.num_players = 2;
    has Int %!player_names;  # values are which player number that name is
    has Int $!current_num_players = 0;

    method new {
        my $self = callsame;
        $self.get: '/' => sub { $self.enter_name };
        $self.post: '/add_player/:player_num' => sub ($n) { $self.add_player($n) };
        $self.get: '/waiting/:player_num' => sub ($n) { $self.waiting($n) };
        return $self;
    }

    method enter_name () {
        say "Player $!current_num_players entering the game";
        my @tmpl_args = { player_number => $!current_num_players++ };
        self.template: 'enter_name.tt', @tmpl_args;
    }

    method add_player(Cool $player_num) {
        my $player_name = self.request.params<player_name>;
        say "Adding player number $player_num named $player_name";
        if (%!player_names{$player_name}:exists) {
            my @tmpl_args = { player_number => $player_num, dup_name => $player_name};
            self.template: 'enter_name.tt', @tmpl_args;
        } elsif (self.ready_to_start) {
            self.start_game();
        } else {
            %!player_names{$player_name} = $player_num.Int;
            self.status(303);
            self.header('Content-Type', 'text/html');
            self.header('Location', "/waiting/$player_num");
        }
    }

    method ready_to_start() returns Bool {
        return %!player_names.elems >= $.num_players;
    }

    method waiting($player_num) {
        if (self.ready_to_start) {
            self.start_game();
        } else {
            my @tmpl_args = { num_players => $!current_num_players,
                              waiting_on_players => $.num_players - $!current_num_players,
                            };
            self.template('waiting_for_players.tt', @tmpl_args);
        }
    }

    method start_game() {
        say "Starting game!";
        my Player @players;
        for %!player_names.kv -> $name, $player_num {
            @players[$player_num] = Player.new(name => $name);
        }
        self.return(@players);
    }
}



