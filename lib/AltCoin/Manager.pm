package AltCoin::Manager;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

use LWP::UserAgent;
use JSON;


has 'json' => (
    is => 'ro',
    isa => 'JSON',
    default => sub {
        JSON->new->allow_nonref;
    }
);

has 'cryptsy_market_ids' => (
    is      => 'ro',
    isa     => 'HashRef[Int]',
    default => sub {
        {
            btc  => 2,
            drk  => 155,
            doge => 132,
            xst  => 285,
            ltcd => 294,
        };
    }
);

sub get_address_balance {
    my ($self) = @_;
    
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    
    my $dogecoin_url = "https://dogechain.info/chain/Dogecoin/q/addressbalance";
    my $darkcoin_url =  "http://chainz.cryptoid.info/drk/api.dws?q=getbalance&a=";
    my $address = "XsBKcHceTzdKVuzqcnzHbHbKCPq2cWwmAS";
    my $response = $ua->get($darkcoin_url.$address);

    return $response->content;
    
}

sub get_market_data {
    my ($self, $args) = @_;
    
    my $symbol = $args->{symbol};
    my $market_ids = $self->cryptsy_market_ids();
    my $market_id = $market_ids->{$symbol};
    
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    
    my $response = $ua->get("http://pubapi1.cryptsy.com/api.php?method=singlemarketdata&marketid=$market_id");
    my $market_data = $self->json->decode($response->decoded_content);
    
    my $current_market_data = {
        success       => $market_data->{success},
        current_price => $market_data->{return}->{markets}->{uc($symbol)}->{lasttradeprice},
    };
    
    return $current_market_data;
        
}     

__PACKAGE__->meta->make_immutable;

1;
