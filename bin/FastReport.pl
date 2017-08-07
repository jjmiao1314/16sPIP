#!/usr/bin/perl
# 
#    FastReport.pl
#    Fast model unknown pathogen predictive results report.
#    
#    FastReport.pl -l <sample.species.155pathogens> -o <outFile> -t <top> -s <basicStatistics>
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my ($list,$helpAsked,$outFile,$baseS);
my $top;

GetOptions(
			"h|help" => \$helpAsked,
			"s|basicStatistics=s" => \$baseS,
			"o|outputFile=s" => \$outFile,
			"l|list=s" => \$list,
			"t|top=i" => \$top,
);
if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($list)) {
	prtError("No input files are provided");
}
if(!defined($outFile)){
	my ($name,$dir)=fileparse($list);
	my $name_id=(split /\./,$name)[0];
	$outFile=$dir."/".$name_id.".pathogen.fast.report";
}

open(S,"<$baseS")or die "can not open file: $baseS\n";
my $readNum;
my $matchNum;
while(my $line=<S>){
	if($line=~/Read Num:\s*(\d+)/){
		$readNum=$1;
	}
	if($line=~/Match Num:\s*(\d+)/){
		$matchNum=$1;
	}
}
close S;

open(L,"<$list")or die "can not open file: $list\n";
my %pathon;
while(my $l=<L>){
	chomp($l);
	my @s2=split /\t/,$l;
	if($pathon{$s2[3]}){
		$pathon{$s2[3]}++;
	}
	else{
		$pathon{$s2[3]}=1;
	}
}

open(O,">$outFile")or die "can not open file: $outFile\n";
print O "\t\t\tDetection of 155 Unknown Pathogens Based on 16S rDNA\n\n\n";
my $data=`date`;
print O "Date: $data\n";
print O "\n";
print O "Note 1: This report is of scientific interest only and is not intended for clinical diagnosis of any nature.\n";
print O "Note 2: This test is only for the Chinese national statutory 155 kinds of pathogens, temporarily not cover other rare or new pathogens.\n";
print O "\n\n";
print O "#======================================================================#\n";
print O "#                                Summary                               #\n";
print O "#======================================================================#\n";
print O "\n";
open(S,"<$baseS")or die "can not open file: $baseS\n";
print O <S>;
print O "Unmatch Num: ",$readNum-$matchNum,"\n";
print O "\n\n";
print O "#======================================================================#\n";
print O "#                            Test results                              #\n";
print O "#                  The sample contains comparable strains.             #\n";
print O "#======================================================================#\n";
print O "\n";
print O "Species\tMatch Num\tPercentage\n";
foreach my $k (sort {$pathon{$b} <=> $pathon{$a}}keys %pathon) {
	my $pp=sprintf("%.3f",$pathon{$k}/$readNum*100);
	print O "$k\t$pathon{$k}\t$pp\n";
}

close S;
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
	print "### sample.species.155pathogens (Required)\n";
	print "  -l | list <Input file name>\n";
	print "\n";
	print "### Other options [Optional]\n";
	print "  -h | -help\n";
	print "    Prints this help\n";
	print "### summary (Required)\n";
	print "  -s | basicStatistics <summary>\n";
	print "\n";
	print "--------------------------------- Output Options ---------------------------------\n";
	print "### Output the highest abundance of the top n species [Optional]\n";
	print "  -t | -top <int>\n";
	print "  -o | -outputFile <Output file name>\n";
	print "    default: By default, output file will be stored where the input file is\n";
	print "\n";
}



