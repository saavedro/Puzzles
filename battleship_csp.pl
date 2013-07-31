#!/bin/perl

use strict;
use warnings;

my $DEBUG = 1;

# The board - domains:
# s - single t -double, u-triple, w-quatro
# 8 t1 t1 s1 t2 t2 u1 u1 u1
# 7 s2 w1 t3 t3 u2 u2 u2 t6
# 6 s3 w1 s4 u3 u3 u3 s5 t6
# 5 t4 w1 s6 t5 t5 s7 t7 t8
# 4 t4 w1 w2 w2 w2 w2 t7 t8
# 3 s8 s9 t8 t8 sa sb u5 u6
# 2 sc w3 w3 w3 w3 tb u5 u6
# 1 u4 u4 u4 ta ta tb u5 u6
#   a  b  c  d  e  f  g  h
# Variables:
# 4 x s
# 3 x t
# 2 x u
# 1 x w
#
my ($board_size_x, $board_size_y) = (8,8);
my @board_definition = qw( 
	t1 t1 s1 t2 t2 u1 u1 u1 
	s2 w1 t3 t3 u2 u2 u2 t6 
	s3 w1 s4 u3 u3 u3 s5 t6 
	t4 w1 s6 t5 t5 s7 t7 t8 
	t4 w1 w2 w2 w2 w2 t7 t8 
	s8 s9 t8 t8 sa sb u5 u6
	sc w3 w3 w3 w3 tb u5 u6 
	u4 u4 u4 ta ta tb u5 u6 
);

my $s_count = 4; # four 1 sizers
my $t_count = 3; # 2 sizers
my $u_count = 2; # 3 sizers
my $w_count = 1; # 4 sizers

sub get_sizer_domain_list ($){
	my $sizer = shift;
	return undef unless $sizer =~ m/^[s|t|u|w]$/;
	my %domain;
	for my $board_field (grep {m/$sizer/} @board_definition){
		my ($file_number) = ($board_field =~ m/$sizer(.*)/);
		$domain{$file_number} = 1;
	}
	return keys %domain
}

print join(',', get_sizer_domain_list('s'), "\n");
print join(',', get_sizer_domain_list('t'), "\n");
print join(',', get_sizer_domain_list('u'), "\n");
print join(',', get_sizer_domain_list('w'), "\n");

