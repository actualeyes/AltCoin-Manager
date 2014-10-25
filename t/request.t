#!/usr/bin/perl -Iblib/lib -Iblib/arch -I../blib/lib -I../blib/arch
# 
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl request.t'

# Test file cr,eated outside of h2xs framework.
# Run this like so: `perl request.t'
#    <apallatto@actualeyes>     2014/10/22 16:07:24

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw( no_plan );
BEGIN { use_ok( AltCoin::Manager ); }
use Scalar::Util qw(looks_like_number);
#########################

# Insert your test code below, the Test::More module is used here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $altcoin_obj = AltCoin::Manager->new();

my $btc_market_data = $altcoin_obj->get_market_data({ symbol => 'btc'});

is($btc_market_data->{success}, 1,"Successfully pulled data");


my $btc_price = $btc_market_data->{current_price};
ok(looks_like_number($btc_price), "current btc price is a number");
my $drk_market_data = $altcoin_obj->get_market_data({symbol => 'drk'});

$drk_price = $drk_market_data->{current_price};
ok(looks_like_number($drk_price), "current drk price is a number");


