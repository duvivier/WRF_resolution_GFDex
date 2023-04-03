#! /bin/tcsh -f
#################################################
# PROGRAM DESCRIPTION: This script cycles through WRF
#                      comparison flux plots
# INPUT DATA: Specify date of comparison
# OUTPUT DATA: the information is sent to "qs_threepanel_akd_hourly.ncl" where plots are created
# CREATOR: Alice DuVivier - April 2011
#################################################

# BEGIN SCRIPT
# set the arrays for case study days
set names = ('21FEB' '02MAR' '05MAR' '06MAR' '09MAR')
set dates = ('2007-02-21' '2007-03-02' '2007-03-05' '2007-03-06' '2007-03-09')
set hours = ('07UTC' '22UTC')
set codes = ('SH' 'LH')

set varcode = $codes[1]

##############
# Make directories for output
##############
    
    set typeout1 = '/png'
    set typeout2 = '/ps'
   
##############
# Start loops of days, hours, variables
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
#echo $varcode

##############
# Input into ncl
##############
	echo 'Processing plots'
	ncl 'hr           = "'$hr'"'\
	    'name         = "'$name'"'\
	    'day          = "'$day'"' \
	    'varcode      = "'$varcode'"'\
	    ./flux_hires.ncl


@ d++
end
@ h++
end



















