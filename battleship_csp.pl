#!/bin/env perl

use strict;
use warnings;
use 5.12.0;
use POSIX;
use Data::Dumper;

my $DEBUG = 0;

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


sub first {
	return shift
}


sub get_sizer_domain_list {
	my $sizer = shift;
	return undef unless $sizer =~ m/^[s|t|u|w]$/;
	my %domain;
	for my $board_field (grep {m/$sizer/} @board_definition){
		my ($file_number) = ($board_field =~ m/$sizer(.*)/);
		$domain{$sizer.$file_number} = 1;
	}
	return sort keys %domain
}

sub get_value_board_postions {
	my $value = shift;
	return undef unless defined($value);
	my @position_numbers = ();
	for my $board_field_nbr (0 .. @board_definition-1){
		next if $board_definition[$board_field_nbr] !~ m/$value/;
		push @position_numbers, $board_field_nbr;
	}
	return @position_numbers;
}

sub position_number_to_coordinate {
	my $position_nbr;
	my @coordinates;
	while( defined($position_nbr = shift)){
		if (($position_nbr >= @board_definition) or ($position_nbr < 0 )){
			# Index out of range
			next;
		}
		push @coordinates,  chr(ord('a') + ($position_nbr % $board_size_x )) . ($board_size_y-floor($position_nbr / $board_size_x));
	}
	return sort @coordinates if @coordinates > 1; # List of parameters
	return first @coordinates; # Only one param
}

sub get_position_neighbours {
	my $position_nbr;
	my %neighbours;
	while( defined($position_nbr = shift)){
		if (($position_nbr >= @board_definition) or ($position_nbr < 0 )){
			# Index out of range
			next;
		}
		my %borders;
		# West and East 
		$borders{-1} = $borders{1} = 1;
		# North line
		$borders{-$board_size_x-1} = $borders{-$board_size_x} = $borders{-$board_size_x+1} = 1;
		# South Line
		$borders{$board_size_x-1} = $borders{$board_size_x} = $borders{$board_size_x+1} = 1;
		# Conditions
		# Upper row
		if ($position_nbr < $board_size_x ) {
			$borders{-$board_size_x-1} = $borders{-$board_size_x} = $borders{-$board_size_x+1} = 0;
		}
		#Bottom row
		if ($position_nbr >= ($board_size_y-1)*$board_size_x ) {
			$borders{$board_size_x-1} = $borders{$board_size_x} = $borders{$board_size_x+1} = 0;
		}
		# Left column
		if ($position_nbr % $board_size_x eq 0) {
			$borders{$board_size_x-1} = $borders{-$board_size_x-1} = $borders{-1} = 0;
		}
		# Right column
		if ($position_nbr % $board_size_x eq $board_size_x-1) {
			$borders{$board_size_x+1} = $borders{-$board_size_x+1} = $borders{1} = 0;
		}
		for my $neigbour (grep {$borders{$_}} keys %borders){
			$neighbours{$position_nbr + $neigbour} = 1;
		}
        $neighbours{$position_nbr} = 1; # File itself
	}
	return sort keys %neighbours if keys %neighbours > 1; # List of parameters
	return first keys %neighbours; # Only one param
}

sub domain_for_used_values {
	my @used_values = (@_);

	my %variable_pool;
	for my $domain_variable (map {get_sizer_domain_list($_)} ('s','t','u','w')){
		$variable_pool{$domain_variable} = 1;
	}

	my %value_dependency;
	for my $value (keys %variable_pool){
		my %related_values = ();
		for my $constrained_number ( get_position_neighbours get_value_board_postions($value)) {
			$related_values{$board_definition[$constrained_number]} = 1;	
		}
		#$value_dependency{$value} = [grep {! m/$value/} keys %related_values];
		$value_dependency{$value} = [keys %related_values];
	}
	for my $used_value (@used_values) {
		for my $constrained_value (@{$value_dependency{$used_value}}){
			$variable_pool{$constrained_value} = 0;
		}
	}
	return grep {$variable_pool{$_}} keys %variable_pool;
	
}
sub domain_for_variable {
	my ($variable, @values) = (@_);
	return grep {m/$variable/} @values
}

#say join(':', domain_for_variable('w',domain_for_used_values('s1')));
#say join(':', domain_for_used_values('w1'));

#say join(":", grep {$variable_pool{$_}} keys %variable_pool);

# Main logic
# Select unasigned variable (MCV) Most constrained variable
# Select value for that variable (LCV) Least constraining value
# if now value possible backtrack.
#

sub assigment_step {
	my (@variables) = (@_);
    say "variables: @variables" if $DEBUG;
	my @unasigned_variables = grep { m/[?]/} @variables;
    say "unasigned variables: @unasigned_variables" if $DEBUG;
    return @variables if (scalar @unasigned_variables eq 0); # nothing to do

	my @assigned_variables = grep {!m/[?]/} @variables;
    my @return_variables;

    # At this moment get first one, leter it would be good to have MCV 
    my $selected_variable = shift @unasigned_variables;
    say "\$selected_variable $selected_variable" if $DEBUG;

    # Another simply take first, that take best heuristic...
    say "domain for variable: " . join(":",domain_for_variable(substr($selected_variable,0,1),domain_for_used_values(@assigned_variables))) if $DEBUG;

    for my $selected_value (domain_for_variable(substr($selected_variable,0,1),domain_for_used_values(@assigned_variables))){
        @return_variables = assigment_step( @assigned_variables, $selected_value, @unasigned_variables );
        if (! grep {m/[?]/} @return_variables) { # All values set
            return @return_variables; # Short circuit for found solution
        }
    }
    return @variables;
}

sub solve_the_puzzle {
	my @variables;
	push @variables, "w?" for (1 .. $w_count); 
	push @variables, "u?" for (1 .. $u_count); 
	push @variables, "t?" for (1 .. $t_count); 
	push @variables, "s?" for (1 .. $s_count); 

    say "stp variables: @variables";
	my @result = assigment_step(@variables);

}

say join (":", solve_the_puzzle());

__END__

=head1 Battleship CSP solver

	Script for Scientifical American Puzzle 07.13 issue

=cut

=head1 Synopsis

	Specify the board in description in:
	$board_size_x, $board_size_y - board dimensions
	@board_definitions - board definition

=head2 Inner Functions

=over 

=item first()

	Function returns first element of array, nothing more.


=item get_sizer_domain_list()

	Description


=item get_value_board_postions()

	Description


=item position_number_to_coordinate()

 	Description

=back

=cut
