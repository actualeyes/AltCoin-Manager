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

has 'current_btc_price' => (
    is  => 'ro',
    isa => 'Num',
    default => sub {
        my ($self) = @_;
        return $self->get_current_price({ symbol => 'btc'});
    }
);

has 'balance_urls' => (
    is   => 'ro',
    isa  => 'HashRef[Str]',
    default => sub {
        {
            doge => "https://dogechain.info/chain/Dogecoin/q/addressbalance/",
            drk  => "http://chainz.cryptoid.info/drk/api.dws?q=getbalance&a=",
            
        };
    }
);

    
sub get_address_balance {
    my ($self, $args) = @_;
    
    my $address = $args->{address};
    my $symbol  = $args->{symbol};
    
    my $ua = LWP::UserAgent->new;
    $ua->timeout(25);
    my $url = $self->get_balance_url($symbol);
    
    my $response = $ua->get($url.$address);

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

sub get_balance_url {
    my ($self, $symbol) = @_;
    
    my $urls = $self->balance_urls();
    if (exists $urls->{$symbol}) {
        return $urls->{$symbol};
    } else {
        die "$symbol doesn't exist or is not supported\n";
    }

}

sub convert_to_usd {
    my ($self, $balance_in_btc) = @_;

    my $usd_per_btc = $self->get_current_price({ symbol => 'btc' });

    return ($balance_in_btc * $usd_per_btc );
}



__PACKAGE__->meta->make_immutable;

1;
