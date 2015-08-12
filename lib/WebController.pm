use v6;

use Bailador;

# Much of this is lifted from the main Bailador module and allows the
# caller to use OO syntax to create routes with .get, .post, etc

class WebController::ReturnException is Exception {
    has @.values;
}

class WebController is Bailador::App {
    method new {
        my $self = callsame;
        my $file = callframe(0).file;
        my $slash = $file.rindex('/');
        if $slash {
            $self.location = $file.substr(0, $file.rindex('/')) ~ '/../';
        } else {
            $self.location = '.';
        }
        return $self;
    }

    sub route_to_regex($route) {
        $route.split('/').map({
            my $r = $_;
            if $_.substr(0, 1) eq ':' {
                $r = q{(<-[\/\.]>+)};
            }
            $r
        }).join("'/'");
    }

    sub parse_route(Str $route) {
        my $r = route_to_regex($route);
        return "/ ^ $r \$ /".EVAL;
    }

    method get(Pair $x) {
        my $p = parse_route($x.key) => $x.value;
        self.add_route: 'GET', $p;
        return $x;
    }

    method post(Pair $x) is export {
        my $p = parse_route($x.key) => $x.value;
        self.add_route: 'POST', $p;
        return $x;
    }

    method put(Pair $x) is export {
        my $p = parse_route($x.key) => $x.value;
        self.add_route: 'PUT', $p;
        return $x;
    }

    method delete(Pair $x) is export {
        my $p = parse_route($x.key) => $x.value;
        self.add_route: 'DELETE', $p;
        return $x;
    }

#    method request { self.context.request }
    method status(Int $code) { self.response.code = $code }
    method header(Str $name, Cool $value) {
        self.response.headers{$name} = ~$value;
    }
    method content_type(Str $type) {
        self.response.headers<Context-Type> = $type;
    }

    method dispatch($env) {
        self.context.env = $env;
        my ($r, $match) = self.find_route($env);

        if $r {
            self.status(200);
            if $match {
                self.response.content = $r.value.(|$match.list);
            } else {
                self.response.content = $r.value.();
            }
        }

        return self.response;
    }

    method return(*@values) {
        die WebController::ReturnException.new(values => @values);
    }

    method run($port = 3000) {
say "running controller on port $port";
        try {
            given HTTP::Easy::PSGI.new(:host<0.0.0.0>, :$port) {
say "new server $_";
                .app(sub ($env) { self.dispatch($env).psgi });
                say "Starting web server at: http://0.0.0.0:$port";
                .run;
            }
            CATCH {
say "got exception";
                when WebController::ReturnException {
say "was a ReturnException";
                    return $_.values;
                }
                default {
say "was someting else";
                    $_.rethrow;
                }
            }
        }
    }
}
