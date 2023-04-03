#! /bin/tcsh -f

# Script to cycle through all sorts of WRF plots!
# Alice DuVivier - Sept.2010
#################################################

set maindir = '/ptmp/duvivier/' # go from scripts file back to the data files
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

set shrt_t2 = 'wrf_10km'   #enter wrf simulation info here (options: wrf_nudg, wrf_cont, wrf_fore)
set title2 = 'WRF_10' # enter full WRF title here to be used in the ncl script


##############
# Make directories for output
##############
set ym = 1
#while ($ym <=1)      # useful if looking at more than one month
    set outdir = $maindir'flux_tests/' 

    set compare = $shrt_t1'-v-'$shrt_t2'/'
    set timetype = 'hourly_'$date[$ym]'/'
    mkdir {$outdir}{$compare}
    mkdir {$outdir}{$compare}{$timetype}

    set typeout1 = 'avg_ps/'
    set typeout2 = 'avg_png/'
    mkdir {$outdir}{$compare}{$timetype}{$typeout1}
    mkdir {$outdir}{$compare}{$timetype}{$typeout2}
    
    echo 'Now running for '$outdir$compare

    set tag1 = `echo $shrt_t1 | cut -c1-4`
    set tag2 = `echo $shrt_t2 | cut -c1-4`

#    echo $tag1         #echo tags for testing purposes
#    echo $tag2


##############
# start loops
set zero = '0'

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
    
#    echo $date1  # echo date for testing purposes
   
##############
# Set input file names and directory paths
##############

     set fname1 = 'wrf-'$date1
     set dir1 = $maindir'data/'$shrt_t1'/wrf_cont/wrfout.d01/post_processed/'    
        
     set fname2 = 'wrf-'$date1 
     set dir2 = $maindir'data/'$shrt_t2'/wrf_cont/wrfout.d01/post_processed/'    

   # echo $fname1                # echo fnames for testing purposes
   # echo $fname2
   # echo $dir1                  # echo directories for testing purposes
   # echo $dir2


##############
# Input into ncl
##############
	echo 'Processing plots for  '$date1
	ncl 'dir1           = "'$dir1'"'\
	    'dir2           = "'$dir2'"'\
	    'fname1         = "'$fname1'"' \
	    'fname2         = "'$fname2'"' \
	    'title1         = "'$title1'"' \
	    'title2         = "'$title2'"' \
	    'date1          = "'$date1'"' \
	   ./flux_recalc.ncl

##############
# Rename output and send to a output directory
##############


	mv Flux_diffs_{$title1}_{$title2}_{$date1}.ps  {$outdir}{$compare}{$timetype}{$typeout1}'/'Flux_diffs_{$title1}_{$title2}_{$date1}.ps
	mv Flux_diffs_{$title1}_{$title2}_{$date1}.png {$outdir}{$compare}{$timetype}{$typeout2}'/'Flux_diffs_{$title1}_{$title2}_{$date1}.png


	@ h++
	end
    @ d++
    end



















