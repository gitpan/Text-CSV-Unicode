# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 24;
BEGIN { use_ok('Text::CSV::Unicode') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $csv = Text::CSV::Unicode->new();

ok (! $csv->combine(),		'fail - missing argument');
ok (! $csv->combine('abc', "def\n", 'ghi'),
				'fail - bad character');

ok ($csv->combine('') && ($csv->string eq q("")),
				'succeed');
ok ($csv->combine('', '') && ($csv->string eq q("","")),
				'succeed');
ok ($csv->combine('', 'I said, "Hi!"', '') &&
    ($csv->string eq q("","I said, ""Hi!""","")),
				'succeed');

ok ($csv->combine('"', 'abc') && ($csv->string eq q("""","abc")),
				'succeed');
ok ($csv->combine('abc', '"') && ($csv->string eq q("abc","""")),
				'succeed');

ok ($csv->combine('abc', 'def', 'ghi') &&
    ($csv->string eq q("abc","def","ghi")),
				'succeed');
ok ($csv->combine("abc\tdef", 'ghi') &&
    ($csv->string eq qq("abc\tdef","ghi")),
				'succeed');

ok (! $csv->parse(),		'fail - missing argument');
ok (! $csv->parse('"abc'),	'fail - missing closing double-quote');
ok (! $csv->parse('ab"c'),	'fail - double-quote outside of double-quotes');
ok (! $csv->parse('"ab"c"'),	'fail - bad character sequence');
ok (! $csv->parse(qq("abc\nc")),'fail - bad character');
ok (! $csv->status(),		'fail - test 16 should have failed');

ok (($csv->parse(q(",")) and ($csv->fields())[0] eq ','),
				'success');

ok (($csv->parse(qq("","I said,\t""Hi!""","")) and
    ($csv->fields())[0] eq '' and
    ($csv->fields())[1] eq qq(I said,\t"Hi!") and
    ($csv->fields())[2] eq ''),	'success');

ok ($csv->status(),		'success - test 19 should have succeeded');

my $csv1 = Text::CSV::Unicode->new( { binary => 1 } );
ok ($csv1->parse(qq("abc\nc")),	'success - \n allowed');

ok ($csv1->status(),		'success - test 21 should have succeeded');

ok (($csv1->parse(qq("","I said,\n""Hi!""",""),1) and
    ($csv1->fields())[0] eq '' and
    ($csv1->fields())[1] eq qq(I said,\n"Hi!") and
    ($csv1->fields())[2] eq ''),'success - embedded \n');

ok ($csv1->status(),		'success - test 23 should have succeeded');

#
# empty subclass test
#
package Empty_Subclass;
@ISA = qw(Text::CSV::Unicode);

package main;
my $empty = Empty_Subclass->new();
ok (($empty->version() and $empty->parse('') and $empty->combine('')),
				'empty subclass test');

