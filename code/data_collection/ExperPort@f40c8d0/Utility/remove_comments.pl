#!/usr/bin/perl -w

# Removes in-line Matlab comments from any specified file.
# Note: This script must be in the same directory as the file in question.
# Specifically, the script removes any string starting with '%%%' till the end of the line.
#
# Note: If the input file has multi-line comments, each line of the comment must have three percentage signs, otherwise the comment will not be removed.
#
# Example of a correct multi-line comment:
# myb = 3;    %%% Notice how each line of this comment
#             %%% has three % signs
# fprintf(1, '%i', 1) %%% This comment will go, but the fprintf statement will stay.
# 
# Command-line Usage: 
# perl remove_comments.pl myfile.m
# The comments will be removed from "myfile.m" and the cleaned file will be named "myfile_CLEANED.m".
#
# This script is useful in cases where complicated autoset strings require comments for debugging purposes, but comments need to be removed before inserting the code in autoset processors.

use strict;

my $fname = shift;

open(IN, $fname) || die "$!";
$fname =~ s/\.m$/_CLEANED.m/;
open(OUT, '>' . $fname) || die "$!";

while (<IN>) {
chomp;
  if ($_ =~ /^(.*?)(%%%)(.*)$/) {
    print OUT $1 . "\n";
  }
  else {
    print OUT $_ ."\n";
  }
};

close(IN) || die "$!";
close(OUT) || die "$!";
