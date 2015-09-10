use v6;

use WebController;
use Player;
use Map;

enum GameState <setup waitplayers running>;

class GameController is WebController {
    has Int $!num_players;
    has Int $!num_planets;
    has Map $!game_map;
    has Int %!player_names;  # values are which player number that name is
    has Int $!current_num_players = 0;
    has GameState $!game_state = setup;
    has Str $!asset_base_path = resolve_asset_base_path();

    method new {
        my $self = callsame;

        # Game setup
        $self.get: '/' => sub { $self.entry };
        $self.post: '/setup_game' => sub { $self.receive_setup_game() };
        $self.post: '/add_player/:player_num' => sub ($n) { $self.add_player($n) };
        $self.get: '/waiting/:player_num' => sub ($n) { $self.waiting($n) };

        # Loading the game board
        $self.get: '/play/:player_num' => sub ($n) { $self.load_game_board($n) };
        $self.get: / '/assets/' (\S+)/ => sub ($thing) { $self.get_asset($thing) };

        return $self;
    }

    method entry() {
        given $!game_state {
            when setup { self.render_setup_game }
            when waitplayers { self.enter_name }
            when running { self.start_game }
            default { die "unknown game state $!game_state" }
        }
    }

    method start_game() {
        my @tmpl_args = { num_players => $!num_players };
        self.render('game_already_started.tt', @tmpl_args);
    }

    method render_setup_game() {
        self.template('setup_game.tt', @);
    }

    method receive_setup_game() {
        $!game_state = waitplayers;
        $!num_players = self.request.params<num_players>.Int;
        $!num_planets = self.request.params<num_planets>.Int;
        self.redirect('/');
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
        } else {
            %!player_names{$player_name} = $player_num.Int;
            self.status(303);
            self.header('Content-Type', 'text/html');
            self.header('Location', "/waiting/$player_num");
            #self.waiting($player_num);
        }
    }

    method waiting($player_num) {
        if self.ready_to_start($player_num) {
            $!game_map //= create_game_map(:$!num_planets, :%!player_names);
            $!game_state = running;
            self.redirect("/play/$player_num");
        } else {
            my @tmpl_args = { num_players => $!current_num_players,
                              waiting_on_players => self.waiting_on_number_of_players,
                            };
            self.template('waiting_for_players.tt', @tmpl_args);
        }
    }

    sub create_game_map(Int :$num_planets, Int :%player_names) {
        my @planets = Planet.new() for (1 .. $num_planets);
        my @players = Player.new(name => $_) for %player_names.keys;
        return Map.new(:@planets, :@players);
    }

    method ready_to_start($) returns Bool {
        return %!player_names.elems >= $!num_players;
    }

    method waiting_on_number_of_players() returns Int {
        return $!num_players - $!current_num_players;
    }

    method name_for_player_number($player_num) {
        for %!player_names.kv -> $name, $num {
            return $name if $num == $player_num;
        }
        die "No name for player number $player_num";
    }

    method load_game_board($player_num) {
        unless ($!game_state == running) {
            return self.redirect('/');
        }

        my @tmpl_args = {
            player_num => $player_num,
            player_name => self.name_for_player_number($player_num),
            max_x => $!game_map.max_x,
            max_y => $!game_map.max_y,
        };
        self.template('load_game_board.tt', @tmpl_args);
    }

    sub resolve_asset_base_path () returns Str {
        my $file = callframe(0).file;
        return $file.substr(0, $file.rindex('/')) ~ '/../assets/';
    }

    my %content-types = js      => 'application/javascript',
                        css     => 'test/css',
                        html    => 'text/html',
                        DEFAULT => 'test/plain',
            ;
    method get_asset(Str $thing) {
        my $ext = $thing.substr(0, $thing.rindex('.'));
        my $type = %content-types{$ext} || %content-types<DEFAULT>;

        my $path = $*SPEC.catpath(Str, $!asset_base_path, $thing);
        try {
            self.header('Content-Type', $type);
            $path.IO.slurp();
            CATCH {
                when /'Failed to open file'/ {
                    self.status(404);
                    self.header('Content-Type', 'text/plain');
                    return "File $path not found";
                }
                default { die $_ }
            }
        }
    }
}

