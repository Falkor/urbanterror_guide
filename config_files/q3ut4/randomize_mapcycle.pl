#!/usr/bin/perl -w

#####################################################
# File   : randomize_mapcycle.pl 
# Author : Sebastien VARRETTE <Sebastien.Varrette@uni.lu>
# 10 Apr 2009
#
# Description : 
#		See the man page for more information.
#
# Copyright (c) 2009 Sebastien VARRETTE (http://www-id.imag.fr/~svarrett/)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Sebastien VARRETTE                               \n
# <Sebastien.Varrette@uni.lu>                      \n
# University of Luxembourg                         \n
# 6, rue Richard Coudenhove-Kalergi                \n
# L-1359 Luxembourg                                \n
#####################################################
use strict;
use warnings;

# Used packages
use Getopt::Long;             # For command line management (long version)
use Term::ANSIColor;          # To send the ANSI color-change sequences to the user's terminal
use Pod::Usage;
use List::Util 'shuffle';
#use Data::Dumper;

# Generic variables
my $VERSION = '0.1';          # Script version
my $VERBOSE = 0;              # option variable for verbose mode with default value (false)
my $DEBUG   = 0;              # option variable for debug mode with default value (false)
my $QUIET   = 0;              # By default, display all informations
my $numargs = scalar(@ARGV);  # Number of arguments
my $command = `basename $0`;  # base command
chomp($command);

my $SIMULATION_MODE = 0;      # By default, don't simulate

# Parse command line
my $mapfile     = "/usr/local/games/urbanterror/q3ut4/mapcycle.txt";
my $mapfile_ref = "$mapfile".".ref";

my $getoptRes = GetOptions('mapfile|f=s' => \$mapfile,                 # mapcycle file
			   'ref|r=s'     => \$mapfile_ref,             # mapcycle file reference
			   'dry-run|n' => \$SIMULATION_MODE,           # Simulation mode
			   'verbose|v' => \$VERBOSE,                   # Verbose mode
			   'quiet|q'   => \$QUIET,                     # Quiet mode
			   'debug'     => sub { $DEBUG = 1; $VERBOSE = 1; },    #Debug mode
			   'help|h'    => sub { pod2usage(-exitval => 1,
							  -verbose => 2); },  # Show help
			   'version'   => sub { VERSION_MESSAGE(); exit(0); } #Show version
			  );

PRINT_ERROR_THEN_EXIT("Please check the format of the command-line $!")  
  unless ($getoptRes);
my @maps = ();

info("Mapcycle File ............. $mapfile\n" );
info("Reference Mapcycle File ... $mapfile_ref\n" );
open(MAPREF, "<", "$mapfile_ref") || die "cannot read $mapfile_ref: $!\n";
while (<MAPREF>) {
    @maps = (@maps, $_);
}
close(MAPREF);
info("Number of maps ............ " . scalar(@maps) . "\n");

my @randommaps = shuffle(@maps);

unless ($SIMULATION_MODE) {
    info("Randomizing $mapfile_ref to generate $mapfile\n");
    open(MAPS, ">", "$mapfile") || die "cannot write $mapfile: $!\n";
    foreach my $map (@randommaps) {
	chomp($map);
	print MAPS "$map\n"; 
    }
    close(MAPS);
}

########### ----- Sub routines  ----- ###########

######
# Print information in the following form: '[$2] $1' ($2='=>' if not submitted)
# usage: info(text [,title])
##
sub info {
    PRINT_ERROR_THEN_EXIT( '[' . (caller(0))[3] . '] missing text argument') unless @_;
    my $prefix = $_[1] ? $_[1] : '=>';
    print "$prefix $_[0]" unless $QUIET;
}

####
# Print script version
##
sub VERSION_MESSAGE {
    print <<EOF;
This is $command v$VERSION.
Copyright (c) 2009 Sebastien VARRETTE  (http://www-id.imag.fr/~svarrett/)
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
EOF
}

########## POD documentation ############
=pod

=head1 NAME

I<randomize_mapcycle.pl>, a nice script in perl to randomize mapcycle.txt 

=head1 SYNOPSIS

      ./randomize_mapcycle.pl [options] 

=head1 OPTIONS

The following options are available:

=over 12

=item B<--debug>

Debug mode. Display debugging information probably only relevant to me ;)

=item B<--dry-run   -n>

Simulate the operations to show what would have been done and/or transferred but do 
not perform any backend actions.

=item B<--help  -h>

Display a help screen and quit.

=item B<--mapfile MAP  -f MAP>

Set MAP as the mapcycle.txt file to be generated 
Default: /usr/local/games/urbanterror/q3ut4/mapcycle.txt

=item B<--quiet>

Quiet mode. Minimize the number of printed messages and don't ask questions. 
Very useful for invoking this script in a crontab yet use with caution has all 
operations will be performed without your interaction.

=item B<--ref MAP  -r MAP>

Set MAP as the reference mapcycle file that serves as input for this script 
(the entries of this file will be randomize to generate the final mapcycle.txt 
file. 
Default: /usr/local/games/urbanterror/q3ut4/mapcycle.txt.ref


=item B<--verbose  -v>

Verbose mode. Display more information

=item B<--version>

Display the version number then quit. 

=back

=head1 BUGS

Please report bugs to Sebastien VARRETTE <Sebastien.Varrette@uni.lu>

=head1 AUTHOR

Sebastien VARRETTE -- L<http://varrette.gforge.uni.lu/>

=head1 COPYRIGHT

This  is a free software. There is NO warranty; not even for
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut













