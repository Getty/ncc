package NCC::WarpCore;
# ABSTRACT: NCC Standard WarpCore (You can make your own)

use Moose;
use Import::Into;

has root => ( is => 'rw' );

sub energize {
  my ( $self, $target ) = @_;
  $self->root($target) unless defined $self->root;
  $self->import_moose($target);
}

sub import_moose { Moose->import::into($_[1]) }

sub enervate {
  my ( $self, $target ) = @_;
  $target->meta->make_immutable;
}

1;