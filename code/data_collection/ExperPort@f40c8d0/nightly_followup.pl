#!/usr/bin/perl -w

use strict;

# Empties contents of runme_tonight.pl
# See nightly_runner.pl for documentation

open(IN, '>runme_tonight.pl') || die "$!";
print IN "#!/usr/bin/perl -w\n\nuse strict;\nprint \"Nothing tonight.\\n\"\n";
close(IN) || die "$!";

my $upd_cmd = "cvs update runme_tonight.pl";
my $commit_cmd = 'cvs commit -m "Bot: Reset file." runme_tonight.pl';
print `$upd_cmd`;
print `$commit_cmd`;
