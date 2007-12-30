package Text::CSV::Unicode;

# $Date: 2007-09-25 14:45:31 +0100 (Tue, 25 Sep 2007) $
# $Revision: 142 $
# $Source: $
# $URL: $

use 5.008;
use strict;
use warnings;
use Text::CSV;
use base qw(Text::CSV);

# PBP does not like "\042"
use charnames qw(:full);
my $quote = "\N{QUOTATION MARK}";
my $qqr   = qr{ $quote }msx;

our $VERSION = '0.06';

sub import {
    my $package = shift;
    my $version = $Text::CSV::VERSION;
    if ( $version =~ m{\A -1 , .* base\.pm}msx ) { undef $version }
    my $vstring = defined $version ? 'v' . $version : '(no version)';
    if ( $vstring ne 'v0.01' ) {
        warn "\n$package is intended as an extension of Text::CSV v0.01,",
          "\nthe only version released by Alan Citterman.\n",
          "It is not expected to work with Text::CSV $vstring",
          (
              !$version      ? ()
            : $version < 0.5 ? ' (unknown author)'
            : ",\nas released by Eduardo Rangel Thompson"
              . ",\nmarked on CPAN as '** UNAUTHORIZED RELEASE **'"
          ),
          ".\nTo suppress this warning,",
          " use 'use $package ()'\n\tor 'require $package'.\n\n";
    }
    return;
}

sub new {
    my $self = shift->SUPER::new();
    my %opts =
      ( @_ == 1 and ref $_[0] and ( ref $_[0] ) eq 'HASH' ) ? %{ $_[0] } : @_;
    $self->{'_CHAROK'} =
      $opts{binary}
      ? qr{\A \p{Print} }msx
      : qr{\A (?: \t | \P{Cntrl} ) }msx;    # was /^[\t\040-\176]/
    return $self;
}

# This subroutine is copied verbatim from Text::CSV Version 0.01
# and is Copyright (c) 1997 Alan Citterman.
# Robin Barker changed one line - marked RMB below
# - but then applied Perl Best Practices to code.

sub _bite {
    my ( $self, $line_ref, $piece_ref, $bite_again_ref ) = @_;
    my $in_quotes = 0;
    my $ok        = 0;
    ${$piece_ref}      = q{};
    ${$bite_again_ref} = 0;
    while (1) {
        if ( length( ${$line_ref} ) < 1 ) {

            # end of string...
            if ($in_quotes) {

                # end of string, missing closing double-quote...
            }
            else {

                # proper end of string...
                $ok = 1;
            }
            last;
        }
        if ( ${$line_ref} =~ m{\A $qqr }mosx ) {

            # double-quote...
            if ($in_quotes) {
                if ( length( ${$line_ref} ) == 1 ) {

                    # closing double-quote at end of string...
                    substr ${$line_ref}, 0, 1, q{};
                    $ok = 1;
                    last;
                }
                elsif ( ${$line_ref} =~ m{\A $qqr {2} }mosx ) {

                    # an embedded double-quote...
                    ${$piece_ref} .= $quote;
                    substr ${$line_ref}, 0, 2, q{};
                }
                elsif ( ${$line_ref} =~ m{\A $qqr , }mosx ) {

                    # closing double-quote followed by a comma...
                    substr ${$line_ref}, 0, 2, q{};
                    ${$bite_again_ref} = 1;
                    $ok = 1;
                    last;
                }
                else {

                    # double-quote, followed by undesirable character
                    # (bad character sequence)...
                    last;
                }
            }
            else {
                if ( length( ${$piece_ref} ) < 1 ) {

                    # starting double-quote at beginning of string
                    $in_quotes = 1;
                    substr ${$line_ref}, 0, 1, q{};
                }
                else {

                    # double-quote, outside of double-quotes
                    # (bad character sequence)...
                    last;
                }
            }
        }
        elsif ( ${$line_ref} =~ m{\A , }msx ) {

            # comma...
            if ($in_quotes) {

                # a comma, inside double-quotes...
                ${$piece_ref} .= substr ${$line_ref}, 0, 1, q{};
            }
            else {

                # a comma, which separates values...
                substr ${$line_ref}, 0, 1, q{};
                ${$bite_again_ref} = 1;
                $ok = 1;
                last;
            }
        }
        elsif ( ${$line_ref} =~ $self->{_CHAROK} ) {    # RMB: changed line

            # a tab, space, or printable...
            ${$piece_ref} .= substr ${$line_ref}, 0, 1, q{};
        }
        else {

            # an undesirable character...
            last;
        }
    }
    return $ok;
}
1;

__END__

=head1 NAME

Text::CSV::Unicode -    comma-separated values manipulation routines
                        with potentially wide character data

=head1 SYNOPSIS

 use Text::CSV::Unicode;

 $csv = Text::CSV::Unicode->new( { binary => 1 } );

 # then use methods from Text::CSV

=head1 DESCRIPTION

Text::CSV::Unicode provides facilities for the composition and
decomposition of comma-separated values, based on Text::CSV.
Text::CSV::Unicode allows for input with wide character data.

=head1 FUNCTIONS

=over 4

=item new

 $csv = Text::CSV->new( [{ binary => 1 }] );

This function may be called as a class or an object method.
It returns a reference to a newly created Text::CSV::Unicode object.
C<< binary => 0 >> allows the same ASCII input as Text::CSV and all
other input, while C<< binary => 1 >> allows for all printable Unicode
characters in the input (including \r and \n),

=back

=head1 SUBROUTINES/METHODS

None

=head1 DIAGNOSTICS

None

=head1 CONFIGURATION AND ENVIRONMENT

See HASH option to C<< ->new >>.

=head1 DEPENDENCIES

Text::CSV 0.01

perl 5.8.0

=head1 INCOMPATIBILITIES

None

=head1 BUGS AND LIMITATIONS

As slow as Text::CSV.

Cannot change separators and delimiters.

=head1 VERSION

0.06

=head1 AUTHOR

Robin Barker <rmbarker@cpan.org>

=head1 SEE ALSO

Text::CSV

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2007 Robin Barker.  All rights reserved.  This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

Text::CSV::Unicode::_bite is a direct copy of Text::CSV::_bite, except
as noted in the code.  The original code of Text::CSV::_bite is
Copyright (c) 1997 Alan Citterman.

=cut

