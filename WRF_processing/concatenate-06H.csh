#!/bin/tcsh -f

# script to choose files every 06 H and concatenate them
###################################################################

echo 'Starting selection process:'


echo 'Loading files'

set wrf_type = 'wrf_cont'  # set which type of wrf files we are going through

set dir_in = '/data3/duvivier/ARSC/data/'$wrf_type'/wrfout.d01/post_processed'
set dir_out = $dir_in'/temp/'

mkdir  $dir_out

foreach wrf_file(`ls -1 wrf-2007*.nc`)
    
    echo "Day:"$wrf_file
    set year = `echo $wrf_file | cut -c5-8`
    set month = 02    # could be changed or looped....
    set day = `echo $wrf_file | cut -c13-14`
    set hour = `echo $wrf_file | cut -c16-17`

#echo $hour

    if ($hour == '00') then
    cp  $wrf_file $dir_out$wrf_file
    endif

    if ($hour == '06') then
    cp  $wrf_file $dir_out$wrf_file
    endif

    if ($hour == '12') then
    cp  $wrf_file $dir_out$wrf_file
    endif

    if ($hour == '18') then
    cp  $wrf_file $dir_out$wrf_file
    endif


end

echo 'starting NCR cat commands'

cd $dir_out

set m = 02

    ncrcat 'wrf-'{$year}'-'{$month}*'.nc' 'wrf-'{$year}{$month}'-06H.nc'

echo 'moving 06H catted file'
    mv 'wrf-'{$year}{$month}'-06H.nc' $dir_in'/wrf_monthly'
 

cd $dir_in

rm -r ./temp
