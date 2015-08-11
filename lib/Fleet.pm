use v6;

use Owner;

class Fleet {
    has Owner $.owner;
    has Int $.troops where * > 0;
    has Str $.destination where *.chars;
    has Int $.distance where * >= 0;
}
