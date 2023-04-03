#! /bin/tcsh -f

# Script to cycle through WRF outputs and give statistics in text file
# Matt Higgins - 14 Aug 2009  - looped through dates and comparison arrays
# Alice DuVivier - Oct 2010
################################################

set maindir = '/data3/duvivier/ARSC/' # go from scripts file back to the data files
set date       = ('200702')  # set year month here for what is being processed
set hourtype = ('-03H' '-06H') # this is used for choosing the right concatenated file. 
# 03H is data every 3 hours (wrf files) and 06H is data every 6 hours
set hourstep = ('3' '6')
set index = 2       # Make sure index of hourtype and hourstep match!

##############
# Choose Files
##############
# for directory structure and setting which files are to be compared (Matt used array loops)
set shrt_t1 = 'era_i' # enter driving reanalysis title here (options: era_i, wrf_type)
set title1 = 'ERA_interim'  # enter full title here

set shrt_t2 = 'wrf_cont'   #enter wrf simulation info here (options: wrf_nudg, wrf_cont, wrf_fore)
set title2 = 'WRF_Continuous' # enter full title here

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =  ('SLP' 'Z850' 'Z700' 'Z500' 'Z300' \
		  'T2m' 'T850' 'T700' 'T500' 'T300' \
		  'Windsurf_s' 'Wind850_s' 'Wind700_s' 'Wind500_s' 'Wind300_s' \
		  'Windsurf_d' 'Wind850_d' 'Wind700_d' 'Wind500_d' 'Wind300_d')

# Possible varcodes listed below:
#               ('SLP' 'Z850' 'Z700' 'Z500' 'Z300' \  
#		 'T2m' 'T850' 'T700' 'T500' 'T300'\
#                'Windsurf_s' 'Wind850_s' 'Wind700_s' 'Wind500_s' 'Wind300_s'\
#                'Windsurf_d' 'Wind850_d' 'Wind700_d' 'Wind500_d' 'Wind300_d'\   
#                'Q2m' 'Q850' 'Q500' 'Q300' 'ice'  'SST' 'T_sfc' \
#                'precip' 'snow' 'alb'  'ustar' 'SH' 'LH')

##############
# Choose Lat/Lon points
##############

set Latpoints = ('60.0' '66.6')
set Lonpoints = ('-43.5' '-37.7')
set AWS_hgt = ('10')
set AWS_elev = ('10') # used in hydrostatic appx

set AWS_lat = $Latpoints[1]  # choose which points to look at from array
set AWS_lon = $Lonpoints[1]

##############
set zero = '0'
set d = 1
while ($d <= 1)  # date loop. Useful if you have an array of more than one month
##############
# Make directories for output
##############
    set type = 'stats/'
    mkdir {$maindir}{$type}
    set outdir = {$maindir}{$type}'text/' 
    mkdir $outdir

    set compare = $shrt_t1'-v-'$shrt_t2'/'
    set timetype = 'month_'$date[$d]'_points'$hourtype[$index]'/'
    mkdir {$outdir}{$compare}
    mkdir {$outdir}{$compare}{$timetype}

    echo 'Now running for '$outdir$compare

    set tag1 = `echo $shrt_t1 | cut -c1-4`
    set tag2 = `echo $shrt_t2 | cut -c1-4`

    #echo $tag1
    #echo $tag2

##############
# Set input file names and directory paths
##############
    if ($tag1 == 'era_') then
	set fname1 = 'met-'$date[$d]$hourtype[$index]      
	set dir1 = $maindir'data/'$shrt_t1'/met_monthly/'    
    else if ($tag1 == 'wrf_') then
	set fname1 = 'wrf-'$date[$d]$hourtype[$index]
	set dir1 = $maindir'data/'$shrt_t1'/wrf_monthly/'    
    else
	echo 'Unknown tag: '$tag1
    endif

    if ($tag2 == 'era_') then
	set fname2 = 'met-'$date[$d]$hourtype[$index]
	set dir2 = $maindir'data/'$shrt_t2'/met_monthly/'    
    else if ($tag2 == 'wrf_') then            
	set fname2 = 'wrf-'$date[$d]$hourtype[$index]
	set dir2 = $maindir'data/'$shrt_t2'/wrf_monthly/'
    else
	echo 'Unknown tag:  '$tag2
    endif

    #echo $fname1            # echo fnames for testing purposes
    #echo $fname2
    #echo $dir1              # echo directories for testing purposes
    #echo $dir2

##############
# Loop through variables
##############
    set q = 1
    while ($q <= 33) # var loop
	echo 'Processing average for '$varcode[$q]' '$date[$d]' '$dir1

	ncl 'dir1           = "'$dir1'"'\
	    'dir2           = "'$dir2'"'\
	    'fname1         = "'$fname1'"' \
	    'fname2         = "'$fname2'"' \
	    'title1         = "'$title1'"' \
	    'title2         = "'$title2'"' \
	    'shrt_t1        = "'$shrt_t1'"' \
	    'shrt_t2        = "'$shrt_t2'"' \
	    'date1          = "'$date[$d]'"' \
	    'varcode        = "'$varcode[$q]'"' \
	    'AWS_lat        = "'$AWS_lat'"'\
	    'AWS_lon        = "'$AWS_lon'"'\
	    'hourstep       = "'$hourstep[$index]'"'\
	    wrfstats_akd_points_text.ncl


##############
# Send to a output directory
##############

	mv $varcode[$q]_{$shrt_t1}_{$shrt_t2}_$date[$d]_Lat{$AWS_lat}_Lon{$AWS_lon}_stats.txt \
	{$outdir}{$compare}{$timetype}'/'{$varcode[$q]}_{$shrt_t1}_{$shrt_t2}_{$date[$d]}_Lat{$AWS_lat}_Lon{$AWS_lon}_stats.txt
	
    @ q ++
    end
@ d++
end
