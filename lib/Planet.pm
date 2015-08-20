use v6;

use Owner;
use Fleet;

my Int $max_initial_troops = 10;
my Int $max_production = 10;
my Int $max_kill_pct = 40;

my Str @planet_names =
  < Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune
    Pluto Eris Sedna Orcus Ixion Makemake Haumea Quaoar Ceres Salacia Varuna
    Chaos Huya Rhadamanthus Typhon Deucalion Logos Ceto Borasisi Sila Nunam
    Teharonhiawako Altjira Bob Varda Somnus Manwë Echidna Weywot Zoe Phorcys
    Pabu Sawiskera Vanth Actaea Charon Hydra Nix Kerberos Kerberos Hiʻiaka
    Namaka Dysnomia Ilmarë Thorondor
    Luna Phobos Deimos
    Metis Adrastea Amalthea Thebe Io Europa Ganymede Callisto Themisto Leda
    Himalia Lysithea Elara Dia Carpo Euporie Thelxinoe Euanthe Helike Orthosie
    Iocaste Praxidike Harpalyke Mneme Hermippe Thyone Ananke Herse Aitne Kale
    Taygete Chaldene Erinome Aoede Kallichore Kalyke Carme Callirrhoe Eurydome
    Pasithee Kore Cyllene Eukelade Pasiphae Hegemone Arche Isonoe Sinope
    Sponde Autonoe Megaclite
    Pan Daphnis Atlas Prometheus Pandora Epimetheus Janus Aegaeon Mimas
    Methone Anthe Pallene Enceladus Tethys Telesto Calypso Dione Helene
    Polydeuces Rhea Titan Hyperion Iapetus Kiviuq Ijiraq Phoebe Paaliaq Skathi
    Albiorix Bebhionn Erriapus Skoll Siarnaq Tarqeq Greip Hyrrokkin Jarnsaxa
    Tarvos Mundilfari Bergelmir Narvi Suttungr Hati Farbauti Thrymr Aegir
    Bestla Fenrir Surtur Kari Ymir Loge Fornjot
    Cordelia Ophelia Bianca Cressida Desdemona Juliet Portia Rosalind Cupid
    Belinda Perdita Puck Mab Miranda Ariel Umbriel Titania Oberon Francisco
    Caliban Stephano Trinculo Sycorax Margaret Prospero Stebos Ferdinand Naiad
    Thalassa Despina Galatea Larissa Proteus Triton Nereid Halimede Sao
    Laomedeia Psamathe Neso
  >.pick(*);

class Planet {
    has $.name = @planet_names.shift;
    has Int $.troops is rw where * >= 0 = (1 .. $max_initial_troops).pick;
    has Int $.production where * >= 0 = (0 .. $max_production).pick;
    has Int $.kill_pct where { $_ >= 1 } = (1 .. $max_kill_pct).pick;
    has Owner $.owner;

    method owner is rw {
        return Proxy.new:
            FETCH => sub ($) { return $!owner },
            STORE => sub ($, Owner:D $new_owner) {
                $!owner = $new_owner;
            };
    }

    method withdraw_troops(Int $count! where * > 0) returns Int {
        self.troops -= $count;
        return $count;
    }

    method land_fleet(Fleet $landing! where { $_.destination eq self.name and $_.distance <= 0 }) returns Bool {
        if ($landing.owner === self.owner) {
            $.troops += $landing.troops;

        } else {
            my Int $troops = $.troops;
            my Int $landing_troops = $landing.troops;
            while ($troops > 0 and $landing_troops > 0) {
                my @hits = ( 0 .. 99 ).pick($troops).grep: { $_ < $.kill_pct };
                my @landing_hits = ( 0 .. 99 ).pick($landing_troops).grep: { $_ < $landing.kill_pct };
                $troops -= @landing_hits.elems;
                $landing_troops -= @hits.elems;
            }
            if ($troops <= 0 and $landing_troops > 0) {
                $.owner = $landing.owner;
                $.troops = $landing_troops;
            } else {
                $.troops = $troops > 0 ?? $troops !! 0;
            }
        }
        return True;
    }

    method produce() {
        if self.owner {
            self.troops += self.production;
        }
    }

    method Str {
        my $owner = $.owner ?? $.owner.name !! '(no one)';
        return "$.name owned by $owner";
    }
}

