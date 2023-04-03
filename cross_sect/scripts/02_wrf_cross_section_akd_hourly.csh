#! /bin/tcsh -f

# Script to cycle through all sorts of WRF plots!
# Alice DuVivier - Sept.2010
#################################################

set maindir = '/data3/duvivier/NCAR/21FEB/' # go from scripts file back to the data files
set date = ('200702')

# set the constants for the year, month, hour of forecast, and domain
set yyyy = '2007'
set mm =  '02'
set ndays = ('31' '28' '31' '30' '31' '30' '31' '31' '30' '31' '30' '31')

set hours =  ('00' '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11'\
	      '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23')

##############
# Choose Files
##############
set shrt_t1 = 'wrf_100km' # enter driving reanalysis title here (options: era_i -> Era interim data for met_em files, wrf_type for different wrf runs)
set title1 = 'WRF_100'  # enter full title of driving reanalysis here to be used in the ncl script

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
    set outdir = $maindir'cross_sect/' 
    #mkdir $outdir

    set wrftype = $shrt_t1'/'
    set timetype = 'hourly_'$date[$ym]'/'
    mkdir {$outdir}{$wrftype}
    mkdir {$outdir}{$wrftype}{$timetype}

    set typeout1 = 'avg_ps/'
    set typeout2 = 'avg_png/'
    mkdir {$outdir}{$wrftype}{$timetype}{$typeout1}
    mkdir {$outdir}{$wrftype}{$timetype}{$typeout2}
    
    echo 'Now running for '$outdir$wrftype

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
    
##############
# Loop through days and forecast hours
##############
set d = 21   #Look only at 21th day
#while ($d <= $ndays[$mm])  # loop to go through days
    while ($d <= 21)
	if ($d <= 9) then
	    set dd = $zero$d
	else
	    set dd = $d
	endif

set h = 1
    while ($h <= 24)   # sub loop to go through forecast hours
	set hh = $hours[$h]

set date1  = $yyyy'-'$mm'-'$dd'-'$hh        # this date is used to call files and also in the plot titles
    
    #echo $date1  # echo date for testing purposes
   
###############
## Set input file names and directory paths
###############
    if ($tag1 == 'wrf_') then
	set fname1 = 'wrf-'$date1
	set dir1 = $maindir'data/'$shrt_t1'/wrf_cont/wrfout.d01/post_processed/'    
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
	   ./wrf_cross_section_akd_hourly.ncl

##############
# Rename output and send to a output directory
##############
	if ($q < 10) then
	    set varnum = $zero$q
	else
	    set varnum = $q
	endif

	mv $varcode[$q]_{$title1}_cross_section$linecode[$r]_{$date1}.ps  {$outdir}{$wrftype}{$timetype}{$typeout1}'/'{$varnum}_{$varcode[$q]}_{$title1}_cross_section$linecode[$r]_{$date1}.ps
	mv $varcode[$q]_{$title1}_cross_section$linecode[$r]_{$date1}.png  {$outdir}{$wrftype}{$timetype}{$typeout2}'/'{$varnum}_{$varcode[$q]}_{$title1}_cross_section$linecode[$r]_{$date1}.png	


@ h++
end
@ d++
end
#@ ym ++
#end
@ r++
end
@ q++
end


















