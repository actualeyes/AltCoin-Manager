package AltCoin::Manager;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

use LWP::UserAgent;
use JSON;
use WebService::Cryptsy;

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

sub get_cryptsy_market_id {
    my ($self, $symbol) = @_;
    
    my $market_ids = $self->cryptsy_market_ids();
    my $market_id = $market_ids->{$symbol};

    return $market_id;
    
}

sub get_current_price {
    my ($self, $args) = @_;

    my $symbol = $args->{symbol};
    my $market_id = $self->get_cryptsy_market_id($symbol);

    my $crypt = WebService::Cryptsy->new;
    my $market_data = $crypt->singlemarketdata( $market_id )
        or die "Error: $crypt";

    return $market_data->{markets}->{uc($symbol)}->{lasttradeprice};
}


__PACKAGE__->meta->make_immutable;

1;
