use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Recipe::Image',
    license             => 'perl',
    dist_author         => 'Dai Okabayashi <bayashi@cpan.org>',
    dist_version_from   => 'lib/WWW/Recipe/Image.pm',
    requires => {
        'Test::More' => 0,
        'Carp'       => 0,
    },
    add_to_cleanup      => [ 'WWW-Recipe-Image-*' ],
);

$builder->create_build_script();
