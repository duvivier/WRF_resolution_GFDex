#! /bin/tcsh -f
#################################################
# PROGRAM DESCRIPTION: This script cycles through WRF output and makes
#                      comparison plots of two resolution WRF variables
# INPUT DATA: Specify dates of comparison
# OUTPUT DATA: the information is sent to "regrid_fourpanel_akd_hourly.ncl" where plots are created
# CREATOR: Alice DuVivier - April 2011
#################################################

set maindir = '/data3/duvivier/NCAR/' # go from scripts file back to the data files
set date = ('200702')

# set the constants for the year, month, hour of forecast, and domain
set yyyy = '2007'
set mm =  '02'
set ndays = ('31' '28' '31' '30' '31' '30' '31' '31' '30' '31' '30' '31')
set hours =  ('00' '06' '12' '18')

##############
# Choose Files
##############
set shrt_t1 = 'wrf_cont' # enter driving reanalysis title here (options: era_i -> Era interim data for met_em files, wrf_type for different wrf runs)
set title1 = 'WRF_Continuous'  # enter full title of driving reanalysis here to be used in the ncl script

set shrt_t2 = 'wrf_nudg'   #enter wrf simulation info here (options: wrf_nudg, wrf_cont, wrf_fore)
set title2 = 'WRF_Spectral_Nudging' # enter full WRF title here to be used in the ncl script

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('SLP' 'Z850' 'Z700' 'Z500' 'Z300' \
		  'T2m' 'T850' 'T700' 'T500' 'T300' \
		  'Windsurf' 'Wind850' 'Wind700' 'Wind500' 'Wind300')

# Possible varcodes listed below:
#               ('SLP' 'Z850' 'Z700' 'Z500' 'Z300' \  
#		 'T2m' 'T850' 'T700' 'T500' 'T300'\
#                'Windsurf' 'Wind850' 'Wind700' 'Wind500' 'Wind300'\   
#                'Q2m' 'Q850' 'Q500' 'Q300' 'ice'  'SST' 'T_sfc' \
#                'precip' 'snow' 'alb'  'ustar' 'SH' 'LH')

##############
# Make directories for output
##############
set ym = 1
#while ($ym <=1)      # useful if looking at more than one month
    set outdir = $maindir'fourpanel_plots/' 
    mkdir $outdir

    set compare = $shrt_t1'-v-'$shrt_t2'/'
    set timetype = 'hourly_'$date[$ym]'/'
    mkdir {$outdir}{$compare}
    mkdir {$outdir}{$compare}
    mkdir {$outdir}{$compare}{$timetype}

    set typeout1 = 'avg_ps/'
    set typeout2 = 'avg_png/'
    mkdir {$outdir}{$compare}{$timetype}{$typeout1}
    mkdir {$outdir}{$compare}{$timetype}{$typeout2}
    
    echo 'Now running for '$outdir$compare

    set tag1 = `echo $shrt_t1 | cut -c1-4`
    set tag2 = `echo $shrt_t2 | cut -c1-4`

    #echo $tag1         #echo tags for testing purposes
    #echo $tag2

##############
# start loops
set zero = '0'
set q = 1  # change this value to change which type of plot to start with
while ($q <= 15) # var loop
##############
# Loop through days and forecast hours
##############
set d = 1
while ($d <= $ndays[$mm])  # loop to go through days
    if ($d <= 9) then
	set dd = $zero$d
    else
	set dd = $d
    endif

set h = 1
while ($h <= 4)   # sub loop to go through forecast hours
    set hh = $hours[$h]

set date1  = $yyyy'-'$mm'-'$dd'-'$hh        # this date is used to call files and also in the plot titles
    
    #echo $date1  # echo date for testing purposes
   
##############
# Set input file names and directory paths
##############
    if ($tag1 == 'era_') then
	set fname1 = 'met-'$date1      
	set dir1 = $maindir'data/'$shrt_t1'/metin.d01/post_processed/'    
    else if ($tag1 == 'wrf_') then
	set fname1 = 'wrf-'$date1
	set dir1 = $maindir'data/'$shrt_t1'/wrfout.d01/post_processed/'    
    else
	echo 'Unknown tag:   '$tag1
    endif

    if ($tag2 == 'era_') then
	set fname2 = 'met-'$date1 
	set dir2 = $maindir'data/'$shrt_t2'/metin.d01/post_processed/'    
    else if ($tag2 == 'wrf_') then            
	set fname2 = 'wrf-'$date1 
	set dir2 = $maindir'data/'$shrt_t2'/wrfout.d01/post_processed/'    
    else
	echo 'Unknown tag:   '$tag1
    endif

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

	mv $varcode[$q]_$date1.ps  {$outdir}{$compare}{$timetype}{$typeout1}'/'{$varnum}_{$varcode[$q]}_{$date1}.ps
	mv $varcode[$q]_$date1.png {$outdir}{$compare}{$timetype}{$typeout2}'/'{$varnum}_{$varcode[$q]}_{$date1}.png


	@ h++
	end
    @ d++
    end
#@ ym ++
#end
@ q++
end


















