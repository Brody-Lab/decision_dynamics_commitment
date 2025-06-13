#!/usr/bin/perl

#
# Log file in the current directory to append cvs update output to
#
$logfile = 'CVSAutoUpdate.log';

##############################################################################
#  dirs variable
##############################################################################
#  Modify the below @dirs to selectively add/remove directories from the
#  auto-update list.
#
#  NB: The directories in this list end up getting updated *recursively* 
#  (like cvs update does).
#
#  NB2: To make a directory *not* be recursive, you need to append a '.' to
#       it as a path component.  So for instance to update 'Protocols' but 
#       none of its subdirectories, you would notate that as: 'Protocols/.'
#
#  NB3: Make sure to preserve the perl list syntax by adding the comma after 
#       each directory string or else this script will crash due to bad
#       syntax!
#
##############################################################################
@dirs = (
         '.', # Just the base ExperPort/ directory, not updated recursively
#             @thingy1',
#             '@thingy2',
#             'Analysis',
#             'Data',
#             'Docs',
#             'FakeRP',
#             'FromBehaviorRoom',
         'FakeRP/invokeWrapper.m', 
         'HandleParam',
         'Modules', 
         'Plugins',
         'Protocols/QuadSamp.m', 
         'Protocols/@quadsampobj',
         'Protocols/QuadSamp3.m', 
         'Protocols/@quadsamp3obj',
         'Protocols/Classical2AFC_Solo.m',
         'Protocols/@classical2afc_soloobj',
         'Protocols/Solo_WaterValve2.m',
         'Protocols/@solo_watervalve2obj',
         'Protocols/Newclassical.m',
         'Protocols/@newclassicalobj',
         'Protocols/Multipokes.m',
         'Protocols/@multipokesobj',
	 'Protocols/@duration_discobj',
	 'Protocols/@dual_discobj',
'Protocols/@protocolobj',
#             'RTLinuxServer',
#             'Settings',
         'SoloUtility',
#             'UiClasses',
#             'Utility',
#             'bin',
#             'data',
         'soundtools',
         );
##############################################################################
#  /dirs variable
##############################################################################


##############################################################################
# Actual program below -- do not modify
##############################################################################

sub IsWindows         
{
    return $^O =~ /Win32/i;
}

$pathsep = '/';
if (IsWindows()) {
    $pathsep = '\\\\';
}

sub baseName($)
{
    $arg = shift;
    @comps = split /$pathsep/,$arg;
    $ret = "";
    if (scalar (@comps)) {
        $ret = $comps[$#comps];
    }
    return $ret;
}

sub dirName($)
{
    $arg = shift;
    @c = split $pathsep,$arg;
    if (scalar (@c)) {
        pop @c;
        $ret = join $pathsep,@c;
        if (!length($ret)) { $ret = $pathsep; }
        return $ret;
    }
    return "";
}

chdir(dirName($0));

if (scalar @ARGV == 0) {
    # special initial case, update ourselves
    $ret = system('cvs update -P ' . baseName($0));
    defined($ret) || die "could not run cvs: $?"; 
    !$ret || die "cvs returned error status $ret"; 
    exec ("perl",$0,"doIt") or die "could not run $0: $?";
    exit 0;
}

open LOG,'>>',$logfile;
print LOG "-------------------------------------------------------------\n";
print LOG "CVS Auto Update: " . (scalar(localtime) . "\n");
print LOG "-------------------------------------------------------------\n";

foreach my $dir (@dirs) {    
    $recurs = 1;
    if (IsWindows()) {
       $dir =~ s!/!$pathsep!g;  # replace '/' with '\' in paths if windows
    }
    @comps = split(/$pathsep/, $dir); 
    if ($comps[$#comps] eq '.') {
        undef $recurs; # don't recurse if last path component is '.'
    }
    $cmd = "cvs update -d -P " . ( !$recurs ? "-l " : "" ) . $dir;
    print LOG $cmd . "\n";
    if (IsWindows()) { 
        print LOG `$cmd`; # do the command, outputting what it spits back to LOG    
    } else { # unix, mac
        print LOG `$cmd 2>&1` # redirect stderr to stdout so it gets loggeed
    }
}

exit 0;
