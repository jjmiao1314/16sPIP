#!/usr/bin/perl
#Authors : JiaojiaoMiao

use warnings;
use strict;

my $f=$ARGV[0];
my $f2=$ARGV[1];
my $o=$ARGV[2];

open(F,"<$f")or die "can not open file: $f \n";
open(F2,"<$f2")or die "can not open file: $f2\n";
open(O,">$o")or die "can not open file: $o\n";

my %p;
while(my $l=<F>){
chomp($l);
my @s=split /\t/,$l;
my @s2=split "\,",$s[-1];
foreach my $k(@s2){
$p{$k}=$s[0];
}
}

while(my $l2=<F2>){
my @s3=split /\t/,$l2;
if($p{$s3[0]}){
$s3[$#s3]=$p{$s3[0]};
my $line=join "\t",@s3;
print O "$line\n";
}
else{
print O "$l2";
}
}

close F;
close F2;
close O;



