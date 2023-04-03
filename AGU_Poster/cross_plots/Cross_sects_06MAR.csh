#! /bin/tcsh -f

# Script to cycle through all sorts of WRF plots!
# Alice DuVivier - Sept.2010
#################################################
set name = '06MAR'
set date = '2007-03-06-15'

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('PotTemp' 'Q' 'TotWind' 'ParlWind' 'PerpWind')

##############
# Choose cross section lines
##############
# list what cross section line(s) you want the ncl script to output
set linecode  =   ('1' '2')

##############
# Make directories for output
##############
set maindir = '/data3/duvivier/NCAR/AGU/'

    set outdir = $maindir'cross_plots'
    mkdir -p $outdir
    
    set typeout1 = '/png'
    set typeout2 = '/ps'
   
    mkdir $outdir$typeout1
    mkdir $outdir$typeout2

##############
# Start loops
##############
# start variable loop
set zero = '0'
set q = 1  # change this value to change which type of plot to start with
    while ($q <= 5) # var loop

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
	   ./wrf_cross_section_06MAR.ncl

##############
# Rename output and send to a output directory
##############
	

@ r++
end
@ q++
end


















