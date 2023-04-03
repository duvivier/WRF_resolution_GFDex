#! /bin/tcsh -f

# Script to cycle through all sorts of WRF plots!
# Alice DuVivier - Sept.2010
#################################################
##############
# Choose Data
##############
# list data to compare
set types1 =   ('YSU_char0.15' 'YSU_char0.15')
set types2 =   ('YSU_char0.185' 'MYJ_char0.15')

##############
# Choose Dates
##############
# list what date to analyze
set names  =   ('21FEB' '02MAR')
set dates  =   ('2007-02-21-15' '2007-03-02-12')

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('Q' 'TotWind' 'ParlWind' 'PerpWind')

##############
# Choose cross section lines
##############
# list what cross section line(s) you want the ncl script to output
set linecode  =   ('1' '2')

##############
# Make directories for output
##############
set maindir = '/data3/duvivier/NCAR/YSU_comparisons/cross_sect/'

    set outdir = $maindir'figures/cross_plots/'
    mkdir -p $outdir
    
##############
# Start loops
##############
set zero = '0'
# start dataset loop
set t = 1
    set type1 = $types1[$t]
    set type2 = $types2[$t]

# start date loop
set d = 1
    while ($d <= 2)
   echo $varcode[$q]$linecode[$r] 

    set name = $names[$d]
    set date = $dates[$d]

# start variable loop
set q = 1  # change this value to change which type of plot to start with
    while ($q <= 4) # var loop

# start cross section line loop
set r = 1  # change this value to change which cross section line to look at
    while ($r <= 2)   # line loop

    echo $varcode[$q]$linecode[$r] 
   
###############
## Input into ncl
###############
	echo 'Processing plots for '$varcode[$q]' '$date' Cross Section Line '$linecode[$r]
	ncl 'name           = "'$name'"'\
	    'date           = "'$date'"' \
	    'varcode        = "'$varcode[$q]'"' \
            'cross_type     = "'$linecode[$r]'"'\
            'type1          = "'$type1'"'\
            'type2          = "'$type2'"'\
	   ./wrf_cross_bl_compare.ncl

##############
# Rename output and send to a output directory
##############
	   mv *.png $outdir
	   rm *.ps
	

@ r++
end
@ q++
end
@ d++
end
@ t++
end


















