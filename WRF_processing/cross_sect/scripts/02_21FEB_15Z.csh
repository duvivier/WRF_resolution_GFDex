#! /bin/tcsh -f

# Script to cycle through all sorts of WRF plots!
# Alice DuVivier - Sept.2010
#################################################

set maindir = '/data3/duvivier/NCAR/' # go from scripts file back to the data files
set date = ('200702')

# set the constants for the year, month, hour of forecast, and domain
set yyyy = '2007'
set mm =  '02'
set dd = '21'
set hh = '15'

set date1  = $yyyy'-'$mm'-'$dd'-'$hh        # this date is used to call files and also in the plot titles


##############
# Choose Files
##############
set shrt_t1 = 'wrf_50km' # enter driving reanalysis title here (options: era_i -> Era interim data for met_em files, wrf_type for different wrf runs)
set title1 = 'WRF_50'  # enter full title of driving reanalysis here to be used in the ncl script

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('PotTemp' 'Q' 'TotWind' 'ParlWind' 'PerpWind')

##############
# Choose cross section lines
##############
# list what cross section line(s) you want the ncl script to output
set linecode  =   ('1' '2' '3' '4' '5' '6')

##############
# Make directories for output
##############
set ym = 1
#while ($ym <=1)      # useful if looking at more than one month

    set wrftype = 'cross_sect/'$shrt_t1'_cross_sect/'
    mkdir {$maindir}{$wrftype}
    

    set typeout1 = 'avg_ps/'
    set typeout2 = 'avg_png/'
    mkdir {$maindir}{$wrftype}{$typeout1}
    mkdir {$maindir}{$wrftype}{$typeout2}
    
    echo 'Now running for '$maindir$wrftype

    set tag1 = `echo $shrt_t1 | cut -c1-4`

    #echo $tag1         #echo tags for testing purposes

##############
# Start loops
##############
# start variable loop
set zero = '0'
set q = 1  # change this value to change which type of plot to start with
    while ($q <= 5) # var loop

# start cross section line loop
set r = 1  # change this value to change which cross section line to look at
    while ($r <= 6)   # line loop

    #echo $varcode[$q]$linecode[$r] 
   
###############
## Set input file names and directory paths
###############
    if ($tag1 == 'wrf_') then
	set fname1 = 'wrf-'$date1
	set dir1 = $maindir'21FEB/'$shrt_t1'/'
    else
	echo 'Unknown tag:   '$tag1
    endif

    #echo $fname1                # echo fnames for testing purposes
    #echo $dir1                  # echo directories for testing purposes


###############
## Input into ncl
###############
	echo 'Processing plots for '$varcode[$q]' '$date1 'Cross Section Line '$linecode[$r]
	ncl 'dir1           = "'$dir1'"'\
	    'fname1         = "'$fname1'"' \
	    'title1         = "'$title1'"' \
	    'date1          = "'$date1'"' \
	    'varcode        = "'$varcode[$q]'"' \
            'cross_type     = "'$linecode[$r]'"'\
	   ./wrf_cross_section_21FEB.ncl

##############
# Rename output and send to a output directory
##############
	if ($q < 10) then
	    set varnum = $zero$q
	else
	    set varnum = $q
	endif

	mv $varcode[$q]_{$title1}_cross_section$linecode[$r]_{$date1}.ps  {$maindir}{$wrftype}{$typeout1}'/'{$varnum}_{$varcode[$q]}_{$title1}_cross_section$linecode[$r]_{$date1}.ps
	mv $varcode[$q]_{$title1}_cross_section$linecode[$r]_{$date1}.png  {$maindir}{$wrftype}{$typeout2}'/'{$varnum}_{$varcode[$q]}_{$title1}_cross_section$linecode[$r]_{$date1}.png	


@ r++
end
@ q++
end


















