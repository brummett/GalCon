use v6;

use WebController;

class SetupController is WebController {
    has Int $.num_players = 2;
    has Str %!player_names;
    has Int $!current_num_players = 0;
    has Bool $!started = False;

    method new {
        my $self = callsame;
        $self.get: '/' => sub { $self.enter_name };
        $self.post: '/add_player/:player_num' => sub ($player_num) { $self.add_player($player_num) };
        $self.get: '/waiting_for_players' => sub { $self.waiting_for_players };
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
        if (%!player_names{$player_name}) {
            my @tmpl_args = { player_number => $player_num, dup_name => $player_name};
            self.template: 'enter_name.tt', @tmpl_args;
        } elsif ($!current_num_players >= $.num_players) {
            self.start_game();
        } else {
            my @tmpl_args = { num_players => $!num_players };
            self.template('waiting_for_players.tt', @tmpl_args);
        }
    }

    method start_game() {
        say "Starting game!";
    }
}


#60's Beetle https://www.youtube.com/watch?v=tPDLX0koXFs
#Whole engines and transmissions https://www.youtube.com/watch?v=rabJ5gDRCoE
#Concrete filled steel drum https://www.youtube.com/watch?v=C12pCVQFxIo
#Rebar scrap https://www.youtube.com/watch?v=Gh9Ossuae_Y
#Whole car https://www.youtube.com/watch?v=YZDngpTmpzQ

