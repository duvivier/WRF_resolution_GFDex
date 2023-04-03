;***************************************
; PROGRAM DESCRIPTION: This NCL script finds data values at particular WRF
;             indicies that correspond to AWS lat and lons
; INPUT DATA: One WRF output files at native resolution and
;             concatenated into a monthly file
; OUTPUT DATA: Text file of WRF values at an AWS location
; NOTE: This script must have which location specified for the different AWS
;       This script differs from 'text_wrf_data_find_inds.ncl' because it 
;       specifices which indicies to use for each resolution
; CREATOR: Alice DuVivier - October 2010
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; below codes are for testing purposes
dir1 = "/data3/duvivier/NCAR/21FEB/wrf_10km/"
fname1 = "wrf-2007-02"
shrt_t1 = "wrf_10"           

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  f1 = addfile(dir1 + fname1 + ".nc","r")
; get lat and lon data
  lat2d  = f1->lat
  lon2d  = f1->lon
  dimll  = dimsizes(lat2d)
  nlat   = dimll(0)
  nlon   = dimll(1)


; break down times for nicer plots later
  year = f1->year
  month = f1->month
  day = f1->day
  hour = f1->hour

  tind = dimsizes(year)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set AWS locations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AWS_lats  = (/60.050, 61.933, 59.983, 60.717, 61.167/)
AWS_lons  = (/-43.167, -42.067, -45.2, -46.05, -45.417/)
AWS_elevs = (/"75m", "39m" , "16m", "34m", "31m"/)
AWS_locs  = (/"PrC", "Ike", "Ang", "Qaq", "Nar"/)
;Prins Christian - E;Ikerminarsuk - E;Angisoq - W;Qaqortoq - W;Narsarsuaq- W
n_stn = dimsizes(AWS_locs)

; indices for each AWS station - predetermined using "plots*" script
inds = new((/n_stn,2/),"integer")

if (shrt_t1 .eq. "wrf_100") then
  inds(:,0) = (/9, 11, 9, 10, 10/)
  inds(:,1) = (/13, 14, 11, 10, 11/)
end if
if (shrt_t1 .eq. "wrf_50") then
  inds(:,0) = (/20, 23, 19, 20, 22/)
  inds(:,1) = (/26, 28, 23, 23, 24/)
end if
if (shrt_t1 .eq. "wrf_25") then
  inds(:,0) = (/38, 47, 39, 42, 44/)
  inds(:,1) = (/51, 55, 46, 46, 47/)
end if
if (shrt_t1 .eq. "wrf_10") then
  inds(:,0) = (/95, 116, 97, 105, 109/)
  inds(:,1) = (/128, 138, 117, 115, 118/)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load variables - just at location of AWS of interest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

do j = 0, n_stn - 1

  ; get AWS information for text files
  AWS_lat = AWS_lats(j)
  AWS_lon = AWS_lons(j)
  AWS_elev = AWS_elevs(j)
  loc = AWS_locs(j)

  ; get indicies for first AWS station from array above
  ind0 = inds(j,0)
  ind1 = inds(j,1)

 ; load sea level pressure (hPa)
  slp = f1->slp(time|:,{south_north|ind0}, {west_east|ind1})           

 ; load 2m temperature (C)
  t2m = f1->T_2m(time|:,{south_north|ind0}, {west_east|ind1})          

 ; load u speed (m/s)
  u = f1->u_10m_tr(time|:,{south_north|ind0}, {west_east|ind1})        

 ; load v speed (m/s)
  v = f1->v_10m_tr(time|:,{south_north|ind0}, {west_east|ind1})        

  ; find wind speed
  wnd_spd = sqrt(u^2 + v^2)
  wnd_spd!0 = "time"
  wnd_spd@long_name = "Net Wind Speed"
  wnd_spd@units = "m/s"

  ; find wind dir
  r2d = 45.0/atan(1.0)

  wnd_dir = atan2(u,v)*r2d+180
  copy_VarMeta(wnd_spd, wnd_dir)
  wnd_dir@long_name = "Wind Direction"
  wnd_dir@units = "Degrees"

 ; load terrain height (m)
  hgt = f1->Z_sfc
  hgt@lat2d = lat2d
  hgt@lon2d = lon2d

  WRF_elev = f1->Z_sfc({south_north|ind0}, {west_east|ind1}) 

 ; get actual WRF lat and lon
  WRF_lat = lat2d({south_north|ind0}, {west_east|ind1})
  WRF_lon = lon2d({south_north|ind0}, {west_east|ind1})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Write text file 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  index = 0          ; set first index
  do i = 0,tind -1

    ; choose year, month, day, hour position
    yy = year(time|i)
    mm = month(time|i)
    dd = day (time|i)
    hh = hour(time|i)

    ; choose data to write
    slp_1 = slp(time|i)
    temp_1 = t2m (time|i)
    wnd_spd_1 = wnd_spd(time|i)
    wnd_dir_1 = wnd_dir(time|i)


    if (index.eq.0) then                ; set header for the output text file
      header1 = loc+" "+shrt_t1+\
      " (WRF: lat"+WRF_lat+", lon"+WRF_lon+", elev"+WRF_elev+")"+\
      " (AWS: lat"+AWS_lat+", lon"+AWS_lon+", elev"+AWS_elev+")"
      header2 = "year    month     day     hour      slp(hpa)    temp(C)     wnd_spd(m/s)    wnd_dir(deg)"
      header = array_append_record(header1,header2,0)
      output = header
    end if

    a1 = sprintf("%10.0f",yy)+sprintf("%10.0f",mm)+\
         sprintf("%10.0f",dd)+sprintf("%10.0f",hh)+\
         sprintf("%10.4f",slp_1)+sprintf("%10.4f",temp_1)+\
         sprintf("%10.4f",wnd_spd_1)+sprintf("%10.4f",wnd_dir_1)

    newoutput = array_append_record(output,a1,0)  ; append new output (a1) to prev. outputs(output)
    delete(output)
    output = newoutput                            ; set output as newly appended list of statistics
    delete(newoutput)

    index = index + 1                             ; increase the index

  end do

  ; set outdir and fout names
  outdir = "./"
  fout   = outdir+shrt_t1+"_stats_"+loc

  asciiwrite(fout+".txt",output)  ; write the text to an output file with name fout
  delete(output)
end do

  
end





