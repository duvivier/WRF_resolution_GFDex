#! /bin/tcsh -f
#################################################
# PROGRAM DESCRIPTION: This script cycles through WRF output and makes
#                      comparison plots of two resolution WRF variables
# INPUT DATA: Specify dates of comparison
# OUTPUT DATA: the information is sent to "regrid_fourpanel_akd_hourly.ncl" where plots are created
# CREATOR: Alice DuVivier - April 2011
#################################################
set casestudy = '09MAR'

# set the constants for the year, month, hour of forecast, and domain
set yyyy = '2007'
set mm = '03'
set dd = '09'
set hours =  ('00' '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23')

##############
# Choose Files
##############
set shrt_t1 = 'wrf_50km' # enter lower resolution file info to be regridded
set title1 = 'WRF_50'    # enter full title 

set shrt_t2 = 'wrf_10km'   # enter high resolution file info that will be 
set title2 = 'WRF_10'      # enter full WRF title 

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('SLP' 'T2m' 'Q2m' 'LH' 'SH' 'ustar' 'Windsurf'\
		  'Qgrad' 'PTgrad' 'PTsurf' 'PTair' 'ice')

##############
# Make directories for output
##############
    set maindir = '/ptmp/duvivier/'

    set direct = './fourpanel_plots/' 
    mkdir $direct

    set compare = $shrt_t1'-v-'$shrt_t2'/'
    mkdir {$direct}{$compare}

    set typeout1 = 'avg_ps/'
    mkdir {$direct}{$compare}{$typeout1}

    set outdir = $direct$compare$typeout1
    
    echo 'Now running for '$outdir$compare

##############
# start loops
set zero = '0'
set q = 1  # change this value to change which type of plot to start with
while ($q <= 12) # var loop
##############
# Loop through forecast hours
##############
set h = 1
while ($h <= 24)   # sub loop to go through forecast hours
    set hh = $hours[$h]

    set date1  = $yyyy'-'$mm'-'$dd'-'$hh     # this date is used to call files 
    
    #echo $date1  # echo date for testing purposes
   
##############
# Set input file names and directory paths
##############
    # set input file names 
    set fname1 = 'wrf-'$date1
    set fname2 = 'wrf-'$date1
    
    # set input directories
    set dir1 = $maindir$casestudy'/'$shrt_t1'/wrf_cont/post_processed/'
    set dir2 = $maindir$casestudy'/'$shrt_t2'/wrf_cont/post_processed/'

    #echo $fname1                # echo fnames for testing purposes
    #echo $fname2
    #echo $dir1                  # echo directories for testing purposes
    #echo $dir2

##############
# Input into ncl
##############
	echo 'Processing plots for '$varcode[$q]' '$date1
	ncl 'dir1           = "'$dir1'"'\
	    'dir2           = "'$dir2'"'\
	    'fname1         = "'$fname1'"' \
	    'fname2         = "'$fname2'"' \
	    'title1         = "'$title1'"' \
	    'title2         = "'$title2'"' \
	    'date1          = "'$date1'"' \
	    'varcode        = "'$varcode[$q]'"' \
	   regrid_wrffourpanel_akd_hourly.ncl

##############
# Rename output and send to a output directory
##############
	if ($q < 10) then
	    set varnum = $zero$q
	else
	    set varnum = $q
	endif

	mv {$varcode[$q]}_{$title1}_{$title2}_{$date1}.ps  {$outdir}'/'{$varnum}_{$varcode[$q]}_{$title1}_{$title2}_{$date1}.ps

	
@ h++
end
@ q++
end


















