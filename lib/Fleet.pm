use v6;

use Owner;

class Fleet {
    has Owner $.owner;
    has Int $.troops where * > 0;
    has Str $.destination where *.chars;
    has Int $.distance is rw where * >= 0;
    has Int $.kill_pct where * >= 1;

    method move returns Int {
        self.distance -= 1;
    }
}
