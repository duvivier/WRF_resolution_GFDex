#! /bin/tcsh -f

# Script to cycle through WRF stats text files
# Matt Higgins - 14 Aug 2009  - looped through dates and comparison arrays
# Alice DuVivier - Oct 2010
################################################

set maindir = '/data3/duvivier/ARSC/' # go from scripts file back to the data files
set date       = ('200702')  # set year month here for what is being processed
set hourtype = ('-03H' '-06H') # this is used for choosing the right concatenated file. 
# 03H is data every 3 hours (wrf files) and 06H is data every 6 hours
set index = 2      # Make sure index of hourtype and hourstep match!


##############
# Choose Files - Requires 3 inputs (reanalysis, two WRF runs)
##############
# for directory structure, file input names, and title creation
set shrt_t0 = 'era_i' # enter driving reanalysis title here (options: era_i)
set title0 = 'ERA_Interim'  # enter full title of driving reanalysis

set shrt_t1 = 'wrf_cont' # enter wrf simulation (options: wrf_nudg, wrf_cont, wrf_fore)
set title1 = 'WRF_Continuous'  # enter full WRF title

set shrt_t2 = 'wrf_nudg'   #enter wrf simulation info here (options: wrf_nudg, wrf_cont, wrf_fore)
set title2 = 'WRF_Spectral_Nudging' # enter full WRF title

set en_mems = 3    # enter number of inputs 

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =  ('SLP' 'Z850' 'Z700' 'Z500' 'Z300' \
		  'T2m' 'T850' 'T700' 'T500' 'T300')

# Possible varcodes listed below (winds don't work for era data):
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
# Make directories for input and output
##############
    set type = 'stats/'
    set timetype = 'month_'$date[$d]'_points'$hourtype[$index]'/'
    
    # set in- directories
    set compare1 = $shrt_t0'-v-'$shrt_t1'/'
    set indir1 = {$maindir}{$type}'text/'{$compare1}{$timetype}
    set compare2 = $shrt_t0'-v-'$shrt_t2'/'
    set indir2 = {$maindir}{$type}'text/'{$compare2}{$timetype}

#echo $indir1
#echo $indir2

    # create out- directories
    set outtype = {$maindir}{$type}'plots/' 
    mkdir $outtype
    set outdir = {$outtype}{$timetype} 
    mkdir $outdir

    set typeout1 = 'avg_ps/'
    set typeout2 = 'avg_png/'
    set typeout3 = 'text/'
    mkdir {$outdir}{$typeout1}
    mkdir {$outdir}{$typeout2}
    mkdir {$outdir}{$typeout3}
    
    # set tags for finding proper inputs
    set tag0 = `echo $shrt_t0 | cut -c1-4`
    set tag1 = `echo $shrt_t1 | cut -c1-4`
    set tag2 = `echo $shrt_t2 | cut -c1-4`
 
##############
# Loop through variables
##############
set q = 1
while ($q <= 11) 

##############
# Set input and output file names and directory paths
##############
    # names of input files
    set fname1 = $varcode[$q]'_'$shrt_t0'_'$shrt_t1'_'$date[$d]'_Lat'$AWS_lat'_Lon'$AWS_lon'_stats'
    set fname2 = $varcode[$q]'_'$shrt_t0'_'$shrt_t2'_'$date[$d]'_Lat'$AWS_lat'_Lon'$AWS_lon'_stats'
    
    set fname3 = $varcode[$q]'_'$date[$d]'_Lat'$AWS_lat'_Lon'$AWS_lon'_stats'  # name of output file

##############
# Process plots
##############
echo 'Processing stats plots for '$fname1 ' and '$fname2

	ncl 'indir1         = "'$indir1'"'\
	    'indir2         = "'$indir2'"'\
	    'fname1         = "'$fname1'"' \
	    'fname2         = "'$fname2'"' \
	    'fname3         = "'$fname3'"' \
	    'title0         = "'$title0'"' \
	    'title1         = "'$title1'"' \
	    'title2         = "'$title2'"' \
	    'shrt_t0        = "'$shrt_t0'"' \
	    'shrt_t1        = "'$shrt_t1'"' \
	    'shrt_t2        = "'$shrt_t2'"' \
	    'date1          = "'$date[$d]'"' \
	    'varcode        = "'$varcode[$q]'"' \
	    'en_mems        = "'$en_mems'"'\
	    'AWS_lat        = "'$AWS_lat'"'\
	    'AWS_lon        = "'$AWS_lon'"'\
	    wrfstats_akd_points_plots.ncl

##############
# Send to a output directory
##############	
	mv {$fname3}.ps {$outdir}{$typeout1}'/'{$fname3}.ps
	mv {$fname3}.png {$outdir}{$typeout2}'/'{$fname3}.png
	mv {$fname3}.txt {$outdir}{$typeout3}'/'{$fname3}.txt
	
    @ q ++
    end
@ d++
end
