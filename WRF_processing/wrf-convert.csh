#!/bin/tcsh -f

#
# Script to run through a given directory of wrf output and process
# each file.  Must have daily files as input.
#
###########################################################################


echo 'Loading files'

mkdir post_processed

set dir_in = './'
set dir_out = './post_processed/'

foreach wrfout_file(`ls -1 wrfout_d01_2007-02-*`)
    
    echo "Day:"$wrfout_file
    set year = `echo $wrfout_file | cut -c12-15`
    set month = `echo $wrfout_file | cut -c17-18`
    set day = `echo $wrfout_file | cut -c20-21`
    set hour = `echo $wrfout_file | cut -c23-24`
    set outfile = 'wrf-'$year'-'$month'-'$day'-'$hour'.nc'

ncl 'file_in="'{$wrfout_file}'"' 'file_out="'{$outfile}'"' \
    'dir_in="'{$dir_in}'"' 'dir_out="'{$dir_out}'"' \
    /home/duvivier/scripts/WRF_processing/wrfout_to_cf-AKD.ncl

set wrfyear = $year

end

echo "Starting ncrcat commands."
mkdir wrf_monthly
cd $dir_out


set month = ('01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12')

set m = 2
#while ($m <= 12)

# note that we do not skip any times at all
    ncrcat 'wrf-'{$wrfyear}'-'{$month[$m]}*'.nc' 'wrf-'{$wrfyear}{$month[$m]}'.nc'
    
    mv 'wrf-'{$wrfyear}{$month[$m]}'.nc' ../wrf_monthly
    echo 'wrf-'{$wrfyear}{$month[$m]}'.nc'

#    @ m ++
#end

echo "Nice job!"

cd ..
mkdir wrf_avg_mon

echo "create_daily_monthly.ncl started: `date`"
ncl /home/duvivier/scripts/WRF_processing/create_monthly_avg_simple.ncl
echo "create_daily_monthly.ncl ended: `date`"

mv wrf_monthly ./post_processed/
mv wrf_avg_mon ./post_processed/wrf_monthly

echo "Complete!"





