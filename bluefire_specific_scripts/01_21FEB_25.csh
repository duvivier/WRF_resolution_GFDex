#! /bin/tcsh -f

# Script to cycle through all sorts of WRF plots!
# Alice DuVivier - Sept.2010
#################################################

set maindir = '/ptmp/duvivier/' # go from scripts file back to the data files
set date = '200702'
set casestudy = '06MAR'

# set the constants for the year, month, hour of forecast, and domain
set yyyy = '2007'
set mm =  '03'
set ndays = ('31' '28' '31' '30' '31' '30' '31' '31' '30' '31' '30' '31')

set hours =  ('00' '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11'\
	      '12' '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23')

##############
# Choose Files
##############
set shrt_t1 = 'wrf_25km' # enter driving reanalysis title here (options: era_i -> Era interim data for met_em files, wrf_type for different wrf runs)
set title1 = 'WRF_25'  # enter full title of driving reanalysis here to be used in the ncl script

set shrt_t2 = 'wrf_10km'   #enter wrf simulation info here (options: wrf_nudg, wrf_cont, wrf_fore)
set title2 = 'WRF_10' # enter full WRF title here to be used in the ncl script

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('SLP' 'T2m' 'Q2m' 'LH' 'SH' 'ustar' 'Windsurf' 'Qgrad' 'PTgrad' 'PTsurf' 'PTair' 'ice')


##############
# Make directories for output
##############
set ym = 1
#while ($ym <=1)      # useful if looking at more than one month
    set outdir = $maindir'fourpanel/' 
    mkdir $outdir

    set compare = $shrt_t1'-v-'$shrt_t2'/'
    mkdir {$outdir}{$compare}

    set typeout1 = 'avg_ps/'
    set typeout2 = 'avg_png/'
    mkdir {$outdir}{$compare}{$typeout1}
    mkdir {$outdir}{$compare}{$typeout2}
    
    echo 'Now running for '$outdir$compare

    set tag1 = `echo $shrt_t1 | cut -c1-4`
    set tag2 = `echo $shrt_t2 | cut -c1-4`

#    echo $tag1         #echo tags for testing purposes
#    echo $tag2


##############
# start loops
set zero = '0'
set q = 11  # change this value to change which type of plot to start with
while ($q <= 12) # var loop
##############
# Loop through days and forecast hours
##############
set d = 6   #Look only at 21th day
#while ($d <= $ndays[$mm])  # loop to go through days
while ($d <= 6)
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
   
##############
# Set input file names and directory paths
##############

set fname1 = 'wrf-'$date1
set dir1 = $maindir$casestudy'/'$shrt_t1'/wrf_cont/post_processed/'    
         
set fname2 = 'wrf-'$date1 
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
	   ./regrid_wrffourpanel_akd_hourly.ncl

##############
# Rename output and send to a output directory
##############
	if ($q < 10) then
	    set varnum = $zero$q
	else
	    set varnum = $q
	endif

	mv $varcode[$q]_{$title1}_{$title2}_{$date1}.ps  {$outdir}{$compare}{$typeout1}'/'{$varnum}_{$varcode[$q]}_{$title1}_{$title2}_{$date1}.ps
	mv $varcode[$q]_{$title1}_{$title2}_{$date1}.png {$outdir}{$compare}{$typeout2}'/'{$varnum}_{$varcode[$q]}_{$title1}_{$title2}_{$date1}.png


	@ h++
	end
    @ d++
    end
#@ ym ++
#end
@ q++
end


















