#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use FindBin qw($Bin);
use lib "$Bin/lib";

use_ok('MyApp');
use_ok('MyApp::Test');

my $obj = MyApp::Test->new( bla => 2 );

isa_ok($obj,"MyApp::Test");
is($obj->bla,2,"Constructor value");
is($obj->bla(3),3,"Setter return value");
is($obj->bla,3,"New value");

done_testing;
