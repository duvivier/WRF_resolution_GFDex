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
set names = ('21FEB' '02MAR' '05MAR' '06MAR' '09MAR')
set dates = ('2007-02-21' '2007-03-02' '2007-03-05' '2007-03-06' '2007-03-09')
set hours =  ('07UTC' '22UTC')

##############
# Make directories for output
##############
    set maindir = '/data3/duvivier/NCAR/AGU/'

    set outdir = $maindir'terrain_plots'
    mkdir -p $outdir
    
    set typeout1 = '/png'
    set typeout2 = '/ps'
   
    #mkdir $outdir$typeout1
    #mkdir $outdir$typeout2

##############
# start loops
set zero = '0'
##############
# Loop through days and forecast hours
##############
set h = 1
while ($h <= 2)  # loop to go through hours

set d = 1
while ($d <= 5)   # sub loop to go through case study days
   
##############
# Set input file names and directory paths
##############
set hr = $hours[$h]
set day = $dates[$d]
set name = $names[$d]

#echo $hr
#echo $day
#echo $name

##############
# Input into ncl
##############
	echo 'Processing plots'
	ncl 'hr           = "'$hr'"'\
	    'name         = "'$name'"'\
	    'day          = "'$day'"' \
	    seaice_only_geo_em.ncl


@ d++
end
@ h++
end


##############
# move output
##############
#mv *.png $outdir$typeout1
#mv *.ps  $outdir$typeout2


















