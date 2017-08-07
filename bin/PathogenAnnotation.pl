#!/usr/bin/perl
# 
#    PathogenAnnotation.pl
#    
#    PathogenAnnotation.pl -i <sample.species> -l <155pathogens.list> -o <outFile>
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $file;
my $list="../db/155pathogens.list";
my $outFile;
my $helpAsked;
#my $top=10;

GetOptions(
            "i|inputFile=s" => \$file,
			"h|help" => \$helpAsked,
			"o|outputFile=s" => \$outFile,
			"l|list=s" => \$list,
#			"t|top=i" => \$top,
);

if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($file)) {
	prtError("No input files are provided");
}
if(!defined($outFile)){
	$outFile=$file.".155pathogens";
}

open(F,"<$file")or die "can not open file:$file\n";
open(L,"<$list")or die "can not open file:$list\n";
open(O,">$outFile")or die "can not open file:$outFile\n";

my %pathong_name;
while(my $line=<L>){
	chomp($line);
	my $name=(split /\t/,$line)[0];
	my @s=split /\,/,((split /\t/,$line)[-1]);
	foreach my $p (@s) {
			$pathong_name{$p}=$name;
	}
}

while(my $line2=<F>){
	chomp($line2);
	my @s2=split /\t/,$line2;
	$s2[0]=~s/_/:/g;
	if($pathong_name{$s2[1]}){
		print O "$line2\t$pathong_name{$s2[1]}\n";
	}
	else{
		print O "$line2\tunclassify\n";
	}
}

close F;
close L;
close O;


sub prtError {
	my $errorm = $_[0];
	print STDERR "+======================================================================+\n";
	printf STDERR "|%-70s|\n", "  Error:";
	printf STDERR "|%-70s|\n", "       $errorm";
	print STDERR "+======================================================================+\n";
	prtUsage();
	exit;
}

sub prtErrorExit {
	my $errmsg = $_[0];
	print STDERR "Error:\t", $errmsg, "\n";
	exit;
}

sub prtUsage {
	print "\nUsage: perl $0 <options>\n";
	prtHelp();
}

sub prtHelp {
	print "\n$0 options:\n\n";
	print "### sample.species(Required)\n";
	print "  -i | inputFile <Input file name>\n";
	print "\n";
	print "### Other options [Optional]\n";
	print "  -h | -help\n";
	print "    Prints this help\n";
	print "--------------------------------- Pathogen Annotation options ---------------------------------\n";
	print "  -l | list <155pathogens.list>\n";
	print "\n";
	print "--------------------------------- Output Options ---------------------------------\n";
	print "  -o | -outputFile <Output file name>\n";
	print "    default: By default, output file will be stored where the input file is\n";
	print "\n";
}

