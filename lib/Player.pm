use v6;

use Owner;

class Player is Owner {
    has Str $.name = die 'name is required';
}
