#!/usr/bin/perl
# 
#    SamPairendResult.pl
#    Pick the best match results.
#    
#    SamPairendResult.pl -i <sam> -s <similarity> -l <species|genus|family|order|class|phylum|domain> -o <outFile>
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $file;
my $sim=99;
my $level="species";
my $helpAsked;
my $outFile;

GetOptions(
            "i|inputFile=s" => \$file,
			"h|help" => \$helpAsked,
			"s|similarity=f" => \$sim,
			"o|outputFile=s" => \$outFile,
			"l|level=s" => \$level,
);
if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($file)) {
	prtError("No input files are provided");
}
if(!defined($outFile)){
	$outFile=$file.".".$level;
}
open(F,"<$file")or die "can not open file: $file\n";
open(O,">$outFile")or die "can not open file: $outFile\n";
my (%p,%p2,%p3,%p4);
while (my $l=<F>) {
	if($l=~/^@|^\[/){
		next;
	}
	my @s=split /\t/,$l;
	if ($#s <11) {
		next;
	}
	if ($s[2] eq "*") {
		next;
	}
	my $mbase=0;
	my $abase=0;
	my $mdz="";
	if($s[5] eq "*"){
		next;
	}
	if($l=~/MD:Z:(\w+)/){
		$mdz=$1;
	}
	my $nameid=join "\t",$s[0],$s[2];
	if ($p{$nameid}) {
		my @s2=split /\D/,$s[5];
		push(@s2,(split /\D/,$p{$nameid}));
		my @s3;
		if($mdz=~/\d/){
			@s3=split /\D/,$mdz;
		}
		else{
			@s3=split /M/,$s[5];
		}
		if($p2{$nameid}=~/\d/){
			push(@s3,(split /\D/,$p2{$nameid}));
		}
		else{
			push(@s3,(split /M/,$p{$nameid}));
		}
		foreach my $mnum (@s3) {
			if($mnum=~/(\d+)$/){
				$mbase+=$1;
			}
		}
		foreach my $anum (@s2) {
			if($anum=~/(\d+)$/){
				$abase+=$1;
			}
		}
		my $sim2=$mbase/$abase*100;
		if($sim2<$sim){
			next;
		}
		if($p3{$s[0]}){
			if($p4{$s[0]}<$sim2){
				$p3{$s[0]}=$s[2];
				$p4{$s[0]}=$sim2;
			}
		}
		else{
			$p3{$s[0]}=$s[2];
			$p4{$s[0]}=$sim2;
		}
	}
	else{
		$p{$nameid}=$s[5];
		$p2{$nameid}=$mdz;
	}
}
foreach my $k (keys %p3) {
	print O "$k\t$p3{$k}\t$p4{$k}\n";
}

close F;
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
	print "### Input Bwa Pair_end match sam file (bwa mem index sample.1.fq sample.2.fq >sample.sam )(Required)\n";
	print "  -i | inputFile <Input file name>\n";
	print "\n";
	print "### Other options [Optional]\n";
	print "  -h | -help\n";
	print "    Prints this help\n";
	print "--------------------------------- Pick the best match result options ---------------------------------\n";
	print "### Input Read similarity with reference sequence,used to specify the identification of bacterial levels [Optional]\n";
	print "  -s | similarity <Floating>\n";
	print "    Generally considered: reads that were >99% identical to the reference sequence can be mapped to the species level, those >97% identical can be mapped to the genus level, and those >95% identical can be mapped to the family level\n";
	print "    default: 99\n";
	print "  -l | level <species|genus|family|order|class|phylum|domain>\n";
	print "    Specify the bacterial level: species|genus|family|order|class|phylum|domain\n";
	print "    default: species\n";
	print "\n";
	print "--------------------------------- Output Options ---------------------------------\n";
	print "  -o | -outputFile <Output file name>\n";
	print "    Output will generate the optimal match list file\n";
	print "    default: By default, output file will be stored where the input file is\n";
	print "\n";
	print "Example: \n";
	print "   perl SamSingleResult.pl -i sample.sam \n";
	print "   perl SamSingleResult.pl -i sample.sam -s 95 -l genus \n";
}


