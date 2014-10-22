#!perl
use strict;
use warnings;
use Test::More;
eval{
    require Test::Pod::Coverage;
    VERSION Test::Pod::Coverage 1.00;
    import  Test::Pod::Coverage;
};
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage"
    if $@;
all_pod_coverage_ok();

# $Id: pod-coverage.t 191 2007-12-31 15:27:08Z rmb1 $
