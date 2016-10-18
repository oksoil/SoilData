#!/bin/bash
# Bash Script to adjust SLNF, SRGF, and SLPF variables in DSSAT SOL file.
original_soil_file="OK.SOL"
slnf="0.2"
slpf="0.35"
# This one should be at least nine numbers separated with commas.
srgf="1,0.7,0.2,0.05,0.03,0.2,0.2,0.2,0.2"


awk -v slnf="${slnf}" -v slpf="${slpf}" -v srgf="${srgf}" '
	BEGIN{
		# create srgf_array by splitting the string srgf on commas
		split(srgf,srgf_array,",");
	} 
	# Main awk code
	# This is a long chain of "if, else if, ..."; probably could have
	# been a case statement instead
	{
		if($2=="SCOM"){
			# The next line has SLNF and SLPF
			snlfrow=NR+1; # current line + 1
			print $0;     # print the current line unchanged
		} else if(NR==snlfrow){
			# Replace SLNF and SLPF values of "1" with the desired value
			gsub(/^1$/,slnf,$6);  # substitute $6 with slnf if $6 is exactly equal to "1"
			gsub(/^1$/,slpf,$7);  # substitute $7 with slnf if $7 is exactly equal to "1"
			# Print all the fields with a witdth of 6
			for(i=1; i<=NF; i++){printf("%6s",$i);}
			printf("\n");
		} else if($2=="SLB"){
			# Next few rows until empty line have the
			# SRGF values we want to replace
			do_srgf=1; 
			count=0; 
			print $0;
		} else if($0 !~ /^\ *\t*$/ && $2!="SLB" && do_srgf==1) {
			# Replace SRGF values
			count++;
			gsub(/^1$/,srgf_array[count],$6);
			# Print all fields with a width of 6
			for(i=1; i<=NF; i++){printf("%6s",$i);}
			printf("\n");
		} else if($0 ~ /^\ *\t*$/) {
			# Turn off the flag to replace SRGF when we hit a blank line
			do_srgf=0;
			print $0;
		} else {
			# For any other line, just print it unchanged
			print $0;
		}
	}' ${original_soil_file}
