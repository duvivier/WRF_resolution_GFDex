#!/bin/tcsh -f

# script to choose files every 03 H and concatenate them
# this script assumes the default output was every 03H
###################################################################

echo 'Starting selection process:'


echo 'Loading files'

set wrf_type = 'wrf_cont'  # set which type of wrf files we are going through

set dir_in = '/data3/duvivier/ARSC/data/'$wrf_type'/wrfout.d01/post_processed'

set year = 2007
set month = 02

echo 'starting NCR cat commands'

    ncrcat 'wrf-'{$year}'-'{$month}*'.nc' 'wrf-'{$year}{$month}'-03H.nc'

echo 'moving 03H catted file'
    mv 'wrf-'{$year}{$month}'-03H.nc' $dir_in'/wrf_monthly'
 


