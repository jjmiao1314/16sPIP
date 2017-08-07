#!/usr/bin/perl
# 
#    sensitiveReport.pl
#    sensitive model unknown pathogen predictive results report.
#    
#    sensitiveReport.pl -l <sample.species.155pathogens> -o <outFile> -t <basicStatistics> -g <sample.genus.list> -f <sample.family> -b <blastn.m6> -s <sample.comple.species>
#
### Authors : JiaojiaoMiao <jjmiao1314@163.com>

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
my ($list,$outFile,$helpAsked,$genus,$family,$statis,$blast,$species);

GetOptions(
			"h|help" => \$helpAsked,
			"t|basicStatistics=s" => \$statis,
			"o|outputFile=s" => \$outFile,
			"l|list=s" => \$list,
			"g|genus=s" => \$genus,
			"f|family=s" => \$family,
			"b|blast=s" => \$blast,
			"s|species=s" => \$species,
);

if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($list)|| !defined($genus) || !defined($family) || !defined($blast)) {
	prtError("No input files are provided");
}
if(!defined($outFile)){
	my ($name,$dir)=fileparse($list);
	my $name_id=(split /\./,$name)[0];
	$outFile=$dir."/".$name_id.".pathogen.sensitive.report";
}

open(S,"<$statis")or die "can not open file: $statis\n";
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
my %pathon_species;
my %pathon_id;

while(my $line=<L>){
	chomp($line);
	my @s=split /\t/,$line;
	$pathon_id{$s[0]}=$s[3];
	if($pathon_species{$s[3]}){
		$pathon_species{$s[3]}++;
	}
	else{
		$pathon_species{$s[3]}=1;
	}
}

close L;
open(B,"<$blast")or die "can not open file: $blast\n";
my %seq_eq;
my %seq_ne;
while(my $b=<B>){
	chomp($b);
	my @s2=split /\t/,$b;
	if($s2[2] < 97 ){
		next;
	}
	if($pathon_id{$s2[0]} eq $s2[-1]){
		if($seq_eq{$pathon_id{$s2[0]}}){
			$seq_eq{$pathon_id{$s2[0]}}++;
		}
		else{
			$seq_eq{$pathon_id{$s2[0]}}=1;
		}
	}
	else{
		if($seq_ne{$pathon_id{$s2[0]}}){
			$seq_ne{$pathon_id{$s2[0]}}++;
		}
		else{
			$seq_ne{$pathon_id{$s2[0]}}=1;
		}
	}
}
close B;

my %species_p;
my %genus_p;
my %family_p;
my $sp_num=&structure($species,\%species_p);
my $genus_num=&structure($genus,\%genus_p);
my $family_num=&structure($family,\%family_p);

open(O,">$outFile")or die "can not open file: $outFile \n";
print O "\t\t\tBased on 16S rDNA unknown pathogen test report\t\t\t\n\n";
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
open(S,"<$statis")or die "can not open file: $statis\n";
print O <S>;
print O "Unmatch Num: ",$readNum-$matchNum,"\n";
print O "\n\n";
print O "#======================================================================#\n";
print O "#                            Test results                              #\n";
print O "#                  The sample contains comparable strains.             #\n";
print O "#======================================================================#\n";
print O "\n";
print O "Species\tMatch Num\tPercentage\tScore\n";

foreach my $k (sort{$pathon_species{$b} <=> $pathon_species{$a}} keys %pathon_species) {
	if(!$seq_eq{$k}){
		$seq_eq{$k}=0;
	}
	if(!$seq_ne{$k}){
		$seq_ne{$k}=0;
	}
	my $pp=sprintf("%.3f",$pathon_species{$k}/$readNum*100);
	my $pp2=sprintf("%.3f",$seq_eq{$k}/($seq_eq{$k}+$seq_ne{$k})*100);
	print O "$k\t$pathon_species{$k}\t$pp\t$pp2\n";
}
print O "\n";
print O "#======================================================================#\n";
print O "#                      Bacterial structure                             #\n";
print O "#======================================================================#\n";
print O "\n";
print O "#####Species\n";
print O "\n";
print O "Species\tMatch Num\tPercentage\n";
foreach my $k2 (sort{$species_p{$b} <=> $species_p{$a}} keys %species_p) {
	print O "$k2\t$species_p{$k2}\t",sprintf("%.3f",$species_p{$k2}/$sp_num*100),"\n";
}
print O "\n";
print O "#####Genus\n";
print O "\n";
print O "Genus\tMatch Num\tPercentage\n";
foreach my $k3 (sort{$genus_p{$b} <=> $genus_p{$a}} keys %genus_p) {
	print O "$k3\t$genus_p{$k3}\t",sprintf("%.3f",$genus_p{$k3}/$genus_num*100),"\n";
}
print O "\n";
print O "#####Family\n";
print O "\n";
print O "Family\tMatch Num\tPercentage\n";
foreach my $k4 (sort{$family_p{$b} <=> $family_p{$a}} keys %family_p) {
	print O "$k4\t$family_p{$k4}\t",sprintf("%.3f",$family_p{$k4}/$family_num*100),"\n";
}
close O;

sub structure{
	my $file=shift;
	my $hash=shift;
	my $read_num=0;
	open(F,"<$file")or die "can not open file: $file\n";
	while(my $l=<F>){
		chomp($l);
		$read_num++;
		my @s=split /\t/,$l;
		if($hash->{$s[-1]}){
			$hash->{$s[-1]}++;
		}
		else{
			$hash->{$s[-1]}=1;
		}
	}
	close F;
	return($read_num);
}

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
	print "  -t | basicStatistics <summary>\n";
	print "\n";
	print "  -s | -species <species file name> \n";
	print "  -g | -genus <genus file name > \n";
	print "  -f | -family <family file name> \n";
	print "  -b | -blast <blastn m6 format file name> (Required) \n";
	print "--------------------------------- Output Options ---------------------------------\n";
	print "### Output the highest abundance of the top n species [Optional]\n";
	print "  -t | -top <int>\n";
	print "  -o | -outputFile <Output file name>\n";
	print "    default: By default, output file will be stored where the input file is\n";
	print "\n";
}


