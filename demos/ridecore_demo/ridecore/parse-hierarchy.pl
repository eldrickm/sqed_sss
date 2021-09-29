#!/usr/bin/env perl

use strict;
use warnings;
use Verilog::Netlist;
use Getopt::Long;

# read in top level module
my $top = ''; 
my $list = '';
GetOptions ('top=s' => \$top, 'list=s' => \$list);

# Setup options so files can be found
use Verilog::Getopt;
my $opt = new Verilog::Getopt;
$opt->parameter( "+incdir+verilog",
		 "-f",$list,
#                 "-y","verilog",

               );

# prepare netlist
my $nl = new Verilog::Netlist (options => $opt,);
foreach my $file ($top) {
   $nl->read_file (filename=>$file);
}

# read in any sub modules
$nl->link();
$nl->lint();
$nl->exit_if_error();

print "Module names in netlist:\n";
for my $mod ( $nl->modules() ) {
   print $mod->name(), "\n";
}
print "\n";

for my $mod ( $nl->top_modules_sorted() ) {
   show_hier($mod, '', '', '');
}

sub show_hier {
   # Recursively descend through module hierarchy,
   # printing each module name and full hierarchical
   # specifier, all module port names, and all
   # instance port connections.
   my $mod      = shift;
   my $indent   = shift;
   my $hier     = shift;
   my $cellname = shift;
   if ($cellname) {
       $hier .= ".$cellname";
   }
   else {
       $hier = $mod->name();
   }
   print "${indent}ModuleName=", $mod->name(), "  HierInstName=$hier\n";
   $indent .= '   ';

   for my $sig ($mod->ports_sorted()) {
       print $indent, 'PortDir=', sigdir($sig->direction()), ' PortName=', $sig->name(), "\n";
   }

   for my $cell ($mod->cells_sorted()) {
       for my $pin ($cell->pins_sorted()) {
           print $indent, ' PinName=', $pin->name(), ' NetName=', $pin->netname(), "\n";
       }

       show_hier($cell->submod(), $indent, $hier, $cell->name()) if $cell->submod();
   }
}

sub sigdir {
   # Change "in"  to "input"
   # Change "out" to "output"
   my $dir = shift;
   return ($dir eq 'inout') ? $dir : $dir . 'put';
}
