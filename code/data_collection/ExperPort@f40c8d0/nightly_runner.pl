#!/usr/bin/perl -w

use strict;

# nightly_runner.pl
# Executes the contents of the Perl script "runme_tonight.pl" and then empties its contents.
# Sample use case:
# ----------------
# Suppose you are going to start training 5 new rats tomorrow and need to call a "cvs update -d" on their directories on all CNMC machines.
# To do this, you:
# 1. Put the necessary code in "runme_tonight" (e.g. my $cmd = "cvs update -d newRat"; print `$cmd`; )
# 2. Update runme_tonight.pl in CVS (which is in ExperPort/) and commit.
#
# What happens:
# -------------
# 1. nightly_runner.pl will first run "runme_tonight.pl" on all machines at 4:30am. 
# 2. nightly_followup.pl will empty the contents of runme_tonight.pl at 6:00am and will update this new, empty file on CVS.
#
# To install on a set of machines:
# ---------------------------------
# 1. Have the Windows scheduler run "nightly_runner.pl" at 4:30am every morning on ALL machines.
# 2. DO NOT schedule "nightly_followup.pl" to run. It will only be run once by a Solo administrator on a central machine.
# 
my $runfile = 'runme_tonight.pl';
system("perl $runfile");
