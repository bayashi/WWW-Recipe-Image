package WWW::Recipe::Image;

use Carp qw/croak/;
use URI;
use Web::Scraper;

use Moose;
use Moose::Util::TypeConstraints;

subtype 'Uri'
    => as 'Object'
    => where {
        $_->isa('URI')
    }
;

coerce 'Uri'
    => from 'Str'
    => via {
        URI->new($_)
    }
;

has 'url' => (
    is       => 'rw',
    isa      => 'Uri',
    required => 1,
    coerce   => 1,
);

has 'images' => (
    is       => 'rw',
    isa      => 'Maybe[Ref]',
    lazy_build  => 1,
);

has 'steps' => (
    is       => 'ro',
    isa      => 'Maybe[Ref]',
    lazy_build  => 1,
);

has 'complete' => (
    is       => 'ro',
    isa      => 'Maybe[URI]',
    lazy_build  => 1,
);

has 'cookpad_com' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!id('main-photo')/img!, complete  => '@src';
            process qq!#steps>>.image>img!,   'steps[]' => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'erecipe_woman_excite_co_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!#material>.body>.text>>a>img!, complete  => '@src';
            process qq!.recipe_img!,                  'steps[]' => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_ajinomoto_co_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!/html/body/form/div/table[2]/tr[2]/td/table[2]/tr/td/img!,
                complete => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_kewpie_co_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!.main-img img!, complete => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_kikkoman_co_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!/html/body/table/tr/td/table/tr[2]/td/table/tr[2]/td[2]/table[2]/tr/td/img!, 
                complete => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'recipe_gourmet_yahoo_co_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!.recipe-photo img!,  complete  => '@src';
            process qq!.howto-photo a img!, 'steps[]' => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_kyounoryouri_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!#recipeImgFlame .recipe_img!, complete => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_recipe_nestle_co_jp' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!#Alltagshtmlplaceholdercontrol1 .mvbg p img!,
                complete => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_bob-an_com' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!#recipe-detail p img!,
                complete => '@src';
            result 'complete', 'steps';
        }
    }
);

has 'www_yamasa_com' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper {
            process qq!.m_recipe_details_1_2 img!,
                complete => '@src';
            process qq!.m_recipe_details_3_8 img!, 'steps[]' => '@src';
            result 'complete', 'steps';
        }
    }
);


no Moose;

__PACKAGE__->meta->make_immutable;


our $VERSION = '0.0.3';

sub _is_support {
    my $self = shift;

    my ($url) = ($self->url =~ m!
                                ^http://
                                (
                                cookpad\.com/recipe/.+
                                |erecipe\.woman\.excite\.co\.jp/detail/.+
                                |www\.ajinomoto\.co\.jp/recipe/condition/menu/.+
                                |www\.kewpie\.co\.jp/recipes/recipe/.+
                                |www\.kikkoman\.co\.jp/homecook/search/.+
                                |recipe\.gourmet\.yahoo\.co\.jp/[A-Z]\d+/
                                |www\.kyounoryouri\.jp/recipe/\d+_.+\.html
                                |www\.recipe\.nestle\.co\.jp/recipe/\d+_\d+/\d+
                                |www\.bob\-an\.com/recipe/OutputMain\.asp\?KeyNo\=\d+
                                |www\.yamasa\.com/mama/recipe/details/[^\.]+\.html
                                )
                                !x);
    return $self->url->host if $url;
}

sub BUILD {
    my $self = shift;

    my $host = $self->_is_support or croak 'url is no support.';
    $host =~ s/\./_/g;

    $self->images( $self->$host->scrape( URI->new($self->url) ) );

    return $self;
}

sub _build_images {
    my $self = shift;

    $self->{images};
}

sub _build_steps {
    my $self = shift;
    $self->images->{steps} if $self->images->{steps};
}

sub _build_complete {
    my $self = shift;
    $self->images->{complete} if $self->images->{complete};
}

1;

__END__


=head1 NAME

WWW::Recipe::Image - [One line description]


=head1 SYNOPSIS

    use WWW::Recipe::Image;
    use Data::Dumper;

    my $recipe = WWW::Recipe::Image->new(
        url => 'http://cookpad.com/recipe/429493',
    );
    my @images = $recipe->images;
    print Dumper \@images;


=head1 METHOD

=over

=item new(I<$arg>)

constructor

=item method_name

description of method

=back


=head1 AUTHOR

Copyright (c) 2009, Dai Okabayashi C<< <bayashi@cpan.org> >>


=head1 LICENCE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut

