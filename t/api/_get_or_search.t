#!perl

use strict;
use warnings;
use Test::More tests => 10;
use Test::Fatal;

use t::lib::Functions;

{
    no warnings qw<redefine once>;

    *MetaCPAN::API::_search = sub {
        my ( $self, $type, $arg, $params ) = @_;
        ::isa_ok( $self, 'MetaCPAN::API' );
        ::is( $type, 'type', 'Correct type' );
        ::is_deeply( $arg, { hello => 'world' }, 'Correct arg' );
        ::is_deeply( $params, { this => 'that' }, 'Correct params' );
    };

    *MetaCPAN::API::_get = sub {
        my ( $self, $type, $arg ) = @_;
        ::isa_ok( $self, 'MetaCPAN::API' );
        ::is( $type, 'typeB', 'Correct type in _get' );
        ::is( $arg, 'argb', 'Correct arg in _get' );
    };
}

my $mc = mcpan();
can_ok( $mc, '_get_or_search' );

# if arg is hash, it should call _search with it
$mc->_get_or_search( 'type', { hello => 'world' }, { this => 'that' } );

# if not, check for arg and call _get
$mc->_get_or_search( 'typeB', 'argb' );

# make arg fail check
like(
    exception { $mc->_get_or_search( 'type', 'B%h' ) },
    qr/^type: invalid args/,
    'Failed execution',
);

