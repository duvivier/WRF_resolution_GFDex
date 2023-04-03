#! /bin/tcsh -f

# Script to cycle through wrfoutput to check if it is running correctly
# set to run only 00Z hourly wrf output
# wrf file must be changed to cf compliant before hand 
# (add cf processing to this script later or just use non staggered data?)
#
# Alice DuVivier - Sept.2010
##########################################################################

# set the constants for the year, month, hour of forecast, and domain
set yyyy = '2007'
set mm =  '02'
set ndays = ('31' '28' '31' '30' '31' '30' '31' '31' '30' '31' '30' '31')
set hh = '12'  # this is set for 12Z checks because at that time there is shortwave flux. At 00Z it is dark so SW=0

# Set types of data to be input both long and short titles necessary for directory structure and proper naming of plots
set shrt_t1 = 'wrf_10km' # enter input type title here (options: era_i or  wrf_type for different wrf runs)
set title1 = 'WRF_10'  # enter full title of input
set tag1 = `echo $shrt_t1 | cut -c1-4`
    #echo $tag1         #echo tags for testing purposes

# Directory creation for inputs and outputs. Script is set to be run from a 'scripts' directory in the main 'ARSC' directory
set maindir = '/ptmp/duvivier/' 
set outdir = $maindir'troubleshooting/' 
set outmon = $yyyy'-'$mm

# list what variable(s) you want the ncl script to output (these are all the options)
    set varcode  =   ('SLP' 'Z500' \
		      'T2m' 'SST' 'ice' 'alb' 'swf' 'lwf'\
		      'Windsurf' 'Wind500')
# STARTING LOOPS
echo 'Now running troubleshooting plots for '$outdir$outmon

# start date loop to build file names, etc.
set zero = '0'
set d = 2
while ($d <= $ndays[$mm])  # loop to go through days
    if ($d <= 9) then
	set dd = $zero$d
    else
	set dd = $d
    endif

    set date  = $yyyy'-'$mm'-'$dd'-'$hh        # this date is used to call files and also in the plot titles
    #echo $date  # echo date for testing purposes

# these statements set the fname1, used in the ncl script to direct to the input file
    if ($tag1 == 'era_') then
	set fname1 = 'met-'$date      # if the tag is era_i set the fname1 (inputted to ncl) to met_em type file
	set dir1 = $maindir'data/'$shrt_t1'/metin.d01/post_processed/'    
    else if ($tag1 == 'wrf_') then
	set fname1 = 'wrf-'$date
	set dir1 = $maindir'FEBMAR/'$shrt_t1'/wrf_cont/post_processed/'    
    endif

   #echo $fname1            # echo fnames for testing purposes
   #echo $dir1              # echo directories for testing purposes


# loop to go through variable options
set q = 1  # change this value to change which type of plot to start with
while ($q <= 10) # this number needs to be less than or equal to the total number of variables possible in the list
# actual processing of plots
	echo 'Processing plots for '$varcode[$q]' '$date
	ncl 'dir1           = "'$dir1'"'\
	    'fname1         = "'$fname1'"' \
	    'title1         = "'$title1'"' \
	    'date1          = "'$date'"' \
	    'varcode        = "'$varcode[$q]'"' \
	   ./output_troubleshooting_akd.ncl

	if ($q < 10) then
	    set varnum = $zero$q
	else
	    set varnum = $q
	endif

@ q++
end
@ d ++
end















