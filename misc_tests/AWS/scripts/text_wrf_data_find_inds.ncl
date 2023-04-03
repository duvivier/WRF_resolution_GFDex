;***************************************
; PROGRAM DESCRIPTION: This NCL script finds data values at particular WRF
;             indicies that correspond to AWS lat and lons
; INPUT DATA: One WRF output files at native resolution and
;             concatenated into a monthly file
; OUTPUT DATA: Text file of WRF values at an AWS location
; NOTE: This script must have which location specified for the different AWS
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
location = "1"

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
  if (location .eq. "1") then  ;Prins Christian - E
    AWS_lat = 60.050
    AWS_lon = -43.167
    AWS_elev = 75.0
    loc = "Prc"
  end if
  if (location .eq. "2") then  ;Ikerminarsuk - E
    AWS_lat = 61.933
    AWS_lon = -42.067
    AWS_elev = 39.0
    loc = "Ike"
  end if
  if (location .eq. "3") then  ;Angisoq - W
    AWS_lat = 59.983
    AWS_lon = -45.2
    AWS_elev = 16.0
    loc = "Ang"
  end if
  if (location .eq. "4") then  ;Qaqortoq - W
    AWS_lat = 60.717
    AWS_lon = -46.05
    AWS_elev = 34.0
    loc = "Qaq"
  end if
  if (location .eq. "5") then  ;Narsarsuaq- W
    AWS_lat = 61.167
    AWS_lon = -45.417
    AWS_elev = 31.0
    loc = "Nar"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lat/Lon index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Narrow down data to particular lat/lon position for evaluation
; Lat and lon are uploaded from cshell script

  indices = getind_latlon2d(lat2d,lon2d,AWS_lat,AWS_lon)
  ind1 = indices(0,0)  ; get specific indicies for the latitude chosen
  ind2 = indices(0,1)  ; get specific indicies for the longitude chosen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load variables - just at location of AWS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

 ; load sea level pressure (hPa)
  slp = f1->slp(time|:,{south_north|ind1}, {west_east|ind2})           

 ; load 2m temperature (C)
  t2m = f1->T_2m(time|:,{south_north|ind1}, {west_east|ind2})          

 ; load u speed (m/s)
  u = f1->u_10m_tr(time|:,{south_north|ind1}, {west_east|ind2})        

 ; load v speed (m/s)
  v = f1->v_10m_tr(time|:,{south_north|ind1}, {west_east|ind2})        

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

  WRF_elev = f1->Z_sfc({south_north|ind1}, {west_east|ind2}) 

 ; get actual WRF lat and lon
  WRF_lat = lat2d({south_north|ind1}, {west_east|ind2})
  WRF_lon = lon2d({south_north|ind1}, {west_east|ind2})

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

  
end





