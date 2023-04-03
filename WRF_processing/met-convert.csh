#! /bin/tcsh -f
#


echo 'Loading files'

mkdir ./post_processed

set dir_in = './'
set dir_out = './post_processed/'

foreach met_em_file (`ls -1 met_em.d01*`)

    echo "Let's go for: "$met_em_file
    set year  = `echo $met_em_file | cut -c12-15`
    set month = `echo $met_em_file | cut -c17-18`
    set day   = `echo $met_em_file | cut -c20-21`
    set hour  = `echo $met_em_file | cut -c23-24`
    set cf_file = 'met-'$year'-'$month'-'$day'-'$hour'.nc'
    echo $cf_file
    ncl 'file_in="'{$met_em_file}'"' 'file_out="'{$cf_file}'"'  \
        'dir_in="'{$dir_in}'"' 'dir_out="'{$dir_out}'"'  \
        /blhome/duvivier/scripts/WRF_processing/met_em_to_cf.ncl
    set metyear = $year
    set month   = $month

end

echo "Starting ncrcat commands."
mkdir met_monthly
cd $dir_out

    ncrcat 'met-'{$metyear}'-'{$month}*'.nc' 'met-'{$metyear}{$month}'.nc'
    
    mv 'met-'{$metyear}{$month}'.nc' ../met_monthly
    echo 'met-'{$metyear}{$month}'.nc'


echo "Nice job!"

cd ..
mkdir met_avg_mon

echo "create_daily_monthly.ncl started: `date`"
ncl /blhome/duvivier/scripts/WRF_processing/create_monthly_avg_simple.ncl
echo "create_daily_monthly.ncl ended: `date`"

echo "Complete!"
