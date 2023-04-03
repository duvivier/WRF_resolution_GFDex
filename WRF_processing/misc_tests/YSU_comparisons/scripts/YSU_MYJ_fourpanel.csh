#! /bin/tcsh -f

#################################################
# PROGRAM DESCRIPTION: This script cycles through WRF and Quikscat 
#                      comparison plots including resolution and satellite pass
# INPUT DATA: Specify date of comparison
# OUTPUT DATA: the information is sent to "qs_threepanel_akd_hourly.ncl" where plots are created
# CREATOR: Alice DuVivier - April 2011
#################################################

# BEGIN SCRIPT
# set the arrays for case study days
set names = ('21FEB' '02MAR' '05MAR')
set dates = ('2007-02-21' '2007-03-02' '2007-03-05')
set hours =  ('07' '08' '12' '13' '14' '15' '22')

set title1 = 'WRF_10-ysu'
set title2 = 'WRF_10-myj'

##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output
set varcode  =   ('SLP' 'Windsurf' 'T2m' 'Q2m' 'SH' 'LH')

##############
# Make directories for output
##############
    set maindir = '/data3/duvivier/NCAR/YSU_comparisons/'

    set outdir = $maindir'fourpanel_plots'
    mkdir -p $outdir
    
    set typeout1 = '/png'
    set typeout2 = '/ps'
   
    mkdir $outdir$typeout1
    mkdir $outdir$typeout2

##############
# start loops
set zero = '0'
##############
# Loop through days and forecast hours
##############
set q = 1
while ($q <= 6)

set h = 1
while ($h <= 7)  # loop to go through hours

set d = 1
while ($d <= 3)   # sub loop to go through case study days
   
##############
# Set input file names and directory paths
##############
set date1 = $dates[$d]'-'$hours[$h]
set fname1 = 'wrf-'$date1
set fname2 = $fname1

#echo $date1
#echo $fname1
#echo $fname2

set dir1 = '/data3/duvivier/NCAR/'$names[$d]'/YSU_basic/wrf_10km/'
set dir2 = '/data3/duvivier/NCAR/'$names[$d]'/wrf_10km/'

#echo $dir1
#echo $dir2

echo $varcode[$q]

##############
# Input into ncl
##############
	echo 'Processing plots'
	ncl 'dir1           = "'$dir1'"'\
	    'dir2           = "'$dir2'"'\
	    'fname1         = "'$fname1'"' \
	    'fname2         = "'$fname2'"' \
	    'title1         = "'$title1'"' \
	    'title2         = "'$title2'"' \
	    'date1          = "'$date1'"' \
	    'varcode        = "'$varcode[$q]'"' \
	   ysu_myj_wrffourpanel_akd.ncl

@ d++
end
@ h++
end
@ q++
end


##############
# move output
##############
mv *.png $outdir$typeout1
mv *.ps  $outdir$typeout2


















