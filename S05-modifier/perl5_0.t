use v6;

use Test;

plan 17;

# Really really really minimal s:P5//// and m:P5 tests. Please add more!!

#L<S05/Modifiers/"The extended syntax">

unless "a" ~~ m:P5/a/ {
  skip_rest "skipped tests - P5 regex support appears to be missing";
  exit;
}

my $foo = "foo";
$foo ~~ s:Perl5{f}=q{b};
is($foo, "boo", 'substitute regexp works');
unless $foo eq "boo" {
  skip_rest "Skipping test which depend on a previous failed test";
}

my $bar = "barrrr";
$bar ~~ s:Perl5:g{r+}=q{z};
is($bar, "baz", 'substitute regexp works with :g modifier');

my $path = "/path//to///a//////file";
$path ~~ s:Perl5:g{/+} = '/';
is($path, "/path/to/a/file", 'substitute regexp works with :g modifier');

my $baz = "baz";
$baz ~~ s:Perl5{.(a)(.)}=qq{$1$0p};
is($baz, "zap", 'substitute regexp with capturing variables works');

my $bazz = "bazz";
$bazz ~~ s:Perl5:g{(.)}=qq{x$0};
is($bazz, "xbxaxzxz", 'substitute regexp with capturing variables works with :g');

my $bad = "1   ";
$bad ~~ s:Perl5:g/\s*//;
is($bad, "1", 'Zero width replace works with :g');

{
	my $r;
	temp $_ = 'heaao';
	s:Perl5 /aa/ll/ && ($r = $_);
	is $r, 'hello', 's/// in boolean context properly defaults to $_', :todo<bug>;
}

my $str = "http://foo.bar/";
ok(($str ~~ m:Perl5/http:\/\//), "test the regular expression escape");

# returns the count of matches in scalar
my $vals = "hello world" ~~ m:P5:g/(\w+)/;
is($vals, 2, 'returned two values in the match');

# return all the strings we matched
my @vals = "hello world" ~~ m:P5:g/(\w+)/;
is(+@vals, 2, 'returned two values in the match');
is(@vals[0], 'hello', 'returned correct first value in the match');
is(@vals[1], 'world', 'returned correct second value in the match');


=begin pod

$0 should not be defined.

Pcre is doing the right thing:
  $ pcretest
...
    re> /a|(b)/
  data> a
   0: a
  data>
so it looks like a pugs-pcre interface bug.

=end pod

"a" ~~ m:Perl5/a|(b)/;
is($0, undef, 'An unmatched capture should be false.');
my $str = "http://foo.bar/";
ok(($str ~~ m:Perl5 {http{0,1}}));

my $rule = '\d+';
ok('2342' ~~ m:P5/$rule/, 'interpolated rule applied successfully');

my $rule2 = 'he(l)+o';
ok('hello' ~~ m:P5/$rule2/, 'interpolated rule applied successfully');

my $rule3 = 'r+';
my $subst = 'z';
my $bar = "barrrr"; 
$bar ~~ s:P5:g{$rule3}=qq{$subst}; 
is($bar, "baz", 'variable interpolation in substitute regexp works with :g modifier');

my $a = 'a:';
$a ~~ s:P5 [(..)]=qq[{uc $0}];
is($a, 'A:', 'closure interpolation with qq[] as delimiter');

my $b = 'b:';
$b ~~ s:P5{(..)} = uc $0;
is($b, 'B:', 'closure interpolation with no delimiter');

{
        diag "Now going to test numbered match variable.";
        "asdfg/" ~~ m:P5 {^(\w+)?/(\w+)?}; $1 ?? "true" !! "false";

        ok !$1, "Test the status of non-matched number match variable (1)";
}

{
        "abc" ~~ m:P5/^(doesnt_match)/;

        ok !$1, "Test the status of non-matched number match variable (2)";
}

my $rule = rx:P5/\s+/;
isa_ok($rule, 'Regex');

ok("hello world" ~~ $rule, '... applying rule object returns true');
ok(!("helloworld" ~~ $rule), '... applying rule object returns false (correctly)');
