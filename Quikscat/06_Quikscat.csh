#! /bin/tcsh -f

#################################################
# PROGRAM DESCRIPTION: This script cycles through WRF and Quikscat 
#                      comparison plots including resolution and satellite pass
# INPUT DATA: Specify date of comparison
# OUTPUT DATA: the information is sent to "qs_threepanel_akd_hourly.ncl" where plots are created
# CREATOR: Alice DuVivier - April 2011
#################################################

# MANUALLY SPECIFY
set date = '21FEB'   # must manually specify this

# BEGIN SCRIPT
# set the constants for the year, month, hour of forecast, and domain
set hours =  ('07' '22')
set pass1 = ('asc' 'des')
set wrf1 = ('wrf_100km' 'wrf_50km' 'wrf_25km' 'wrf_10km')
set wrf2 = ('WRF_100' 'WRF_50' 'WRF_25' 'WRF_10')

##############
# Make directories for output
##############
    set maindir = '/data3/duvivier/NCAR/'

    set outdir = $maindir'Quikscat/QS_plots/'$date
    mkdir -p $outdir
   
    set typeout1 = '/avg_ps/'
    set typeout2 = '/avg_png/'
    set typeout3 = '/stats/'
    mkdir $outdir$typeout1
    mkdir $outdir$typeout2
    mkdir $outdir$typeout3

##############
# start loops
set zero = '0'
##############
# Loop through days and forecast hours
##############
set h = 1
while ($h <= 2)  # loop to go through hours

set n = 1
while ($n <= 4)   # sub loop to go through wrf types
   
##############
# Set input file names and directory paths
##############
# set wrf information
    set dir1 = $maindir$date'/'$wrf1[$n]'/'

    if ($date == '21FEB') then
	set date1 = '2007-02-21-'$hours[$h]
    else if ($date == '02MAR') then
	set date1 = '2007-03-02-'$hours[$h]
    else if ($date == '05MAR') then
	set date1 = '2007-03-05-'$hours[$h]
    else if ($date == '06MAR') then
	set date1 = '2007-03-06-'$hours[$h]
    else if ($date == '09MAR') then
	set date1 = '2007-03-09-'$hours[$h]
    endif

    set fname1 = 'wrf-'$date1
    echo $fname1

    set title1 = $wrf2[$n]

# set quikscat information
    set dir2 = $maindir'Quikscat/'$date'/'

    set pass = $pass1[$h]
    
    set fname2 = 'Quikscat_'

    set title2 = 'Quikscat'


##############
# Input into ncl
##############
	echo 'Processing plots for '$wrf2[$n]' '$date1
	ncl 'dir1           = "'$dir1'"'\
	    'dir2           = "'$dir2'"'\
	    'fname1         = "'$fname1'"' \
	    'fname2         = "'$fname2'"' \
	    'title1         = "'$title1'"' \
	    'title2         = "'$title2'"' \
	    'date1          = "'$date1'"' \
	    'pass           = "'$pass'"' \
	   QS_WRF_compare_akd_hourly.ncl

####
# move output

	mv {$title1}_to_{$title2}_{$date1}.ps  {$outdir}{$typeout1}'/'{$title1}_to_{$title2}_{$date1}.ps
	mv {$title1}_to_{$title2}_{$date1}.png {$outdir}{$typeout2}'/'{$title1}_to_{$title2}_{$date1}.png
	mv {$title1}_to_{$title2}_{$date1}_stats.txt {$outdir}{$typeout3}'/'{$title1}_to_{$title2}_{$date1}_stats.txt

@ n++
end
@ h++
end




















