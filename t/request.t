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
use JSON;
use LWP::UserAgent;
#########################

# Insert your test code below, the Test::More module is used here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $altcoin_obj = AltCoin::Manager->new();
my $balance_urls = $altcoin_obj->balance_urls;

# Price testing
my $btc_price = $altcoin_obj->get_current_price({ symbol => 'btc'});

my $test_btc_price = get_altcoin_price('btc');
is($btc_price, $test_btc_price, "library and test btc price match");


my $drk_price= $altcoin_obj->get_current_price({symbol => 'drk'});
my $test_drk_price = get_altcoin_price('drk');
is($drk_price, $test_drk_price, "library and test drk price match");


# Test for doge account balance. 
my $doge_address = "DGyiBd4UtcYB69dW1hL5TrySMUyPg1KSkg";

print "Making doge api call with library\n";

my $doge_balance = $altcoin_obj->get_address_balance({
    address => $doge_address,
    symbol  => "doge",
});

my $doge_test_balance = get_test_balance({
    address => $doge_address,
    symbol  => 'doge', 
});

is($doge_balance, $doge_test_balance, "Proper doge balance pulled");

# Test converting doge to dollars 
my $doge_usd_value = $altcoin_obj->convert_to_usd($doge_balance);
my $doge_usd_value_test = ($btc_price * $doge_balance);
is($doge_usd_value, $doge_usd_value_test, "doge to usd conversion works properly");



sub get_altcoin_price {
    my ($symbol) = shift;
    
    my $market_id = $altcoin_obj->get_cryptsy_market_id($symbol);
    
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    print "Making $symbol altcoin price api call\n";
    
    my $response = $ua->get("http://pubapi1.cryptsy.com/api.php?method=singlemarketdata&marketid=$market_id");
    my $json = JSON->new->allow_nonref;
    
    my $market_data = $json->decode($response->decoded_content);
    
    return $market_data->{return}->{markets}->{uc($symbol)}->{lasttradeprice};
}     


sub get_test_balance {
    my ($args) = @_;

    my $symbol = $args->{symbol};
    my $address = $args->{address};
    
        
    my $url = $balance_urls->{$symbol};
    my $ua = LWP::UserAgent->new;
    $ua->timeout(25);
    print "making indepedent $symbol api call for test\n";
    
    my $response = $ua->get($url.$address);

    return $response->content;

}
