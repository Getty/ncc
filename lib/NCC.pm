package NCC;
# ABSTRACT: True enterprise application framework

use strict;
use warnings;
use Class::Load ':all';
use Carp qw( croak );
use File::Temp qw( tempdir );
use File::Spec::Functions;
use File::Path qw( make_path );
use lib ();

our %WarpCores;
my %files;

my $tempdir = defined $ENV{'NCC_TEMPDIR'}
	? $ENV{'NCC_TEMPDIR'} : tempdir( CLEANUP => 1 );
lib->import($tempdir);

our %INCC;

sub import {
	my ( $class, @args ) = @_;
	my $target = caller;
	if (scalar @args == 1 && $args[0] eq 'import') {
		{
			no strict 'refs';
			*{$target.'::import'} = \&import;
		}
		return;
	}
	return if defined $WarpCores{$target};
	my $warpcore_class = $class.'::WarpCore';
	load_class($warpcore_class);
	croak "WarpCore can't be instantiated" unless $warpcore_class->can('new');
	croak "WarpCore needs at least an energize function" unless $warpcore_class->can('energize');
	$WarpCores{$target} = $warpcore_class->new(@args);
	$WarpCores{$target}->energize($target);
}

sub find_in_inc {
	my $file = $_[0];
	for (@INC) {
		my $inc = catfile($_,$file);
		return $inc if -f $inc;
	}
}

sub make_pm {
	my ( $module, $src_file, $target_file ) = @_;
	local $/;
	open my $src_fh, "<", $src_file or croak "could not open $src_file: $!";
	my $src = <$src_fh>;
	close $src_fh;
	my ( undef, $target_dir, undef ) = File::Spec->splitpath( $target_file );
	make_path($target_dir);
	open my $target_fh, ">", $target_file or croak "could not open $target_file: $!";
	print $target_fh "package ".$module.";\n\n\n";
	print $target_fh $src;
	print $target_fh "\n\n\n1;";
	close $target_fh;
}

sub engineering { $WarpCores{$_[0]} }

sub install_warpcore {
	my $file = $_[0];
	return CORE::require( $file ) if defined $files{$file} or $file !~ m/\.pm$/;
	$files{$file} = 1;
	( my $ncc_file = $file ) =~ s/\.pm$/.ncc/g;
	( my $module = $file ) =~ s/\//::/g;
	$module =~ s/\.pm$//g;
	if (my $ncc = find_in_inc($ncc_file)) {
		$INCC{$file} = $ncc;
		make_pm($module,$ncc,catfile($tempdir,$file));
	}
	my $has_warp;
	if (my @matches = grep { $module =~ m/^${_}::/ } sort { length($b) <=> length($a) } keys %WarpCores) {
		$WarpCores{$module} = $WarpCores{$matches[0]};
		$WarpCores{$module}->energize($module);
		$has_warp = 1;
	}
	CORE::require( $file );
	if ($has_warp && $WarpCores{$module}->can('enervate')) {
		$WarpCores{$module}->enervate($module);
	}
}

BEGIN {
	*CORE::GLOBAL::require = sub { install_warpcore(@_) };
}

1;
