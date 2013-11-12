package NCC;

use strict;
use warnings;
use Import::Into;
use Moose ();

my %warpsigs;

sub import {
	my ( undef, @args ) = @_;
	my $target = caller;
	$warpsigs{$target} = [@args];
	_energize($target);
}

sub _warpcore {
	my $file = $_[0];
	( my $module = $file ) =~ s/\//::/g;
	$module =~ s/\.pm$//g;
	if (my @matches = grep { $module =~ m/^${_}::/ } sort { length($b) <=> length($a) } keys %warpsigs) {
		_energize($module,$matches[0]);
	}
	CORE::require( $file );
}

sub _energize {
	my ( $target, $warpsig ) = @_;
	Moose->import::into($target);
}

BEGIN {
	*CORE::GLOBAL::require = sub { _warpcore(@_) };
}

1;
