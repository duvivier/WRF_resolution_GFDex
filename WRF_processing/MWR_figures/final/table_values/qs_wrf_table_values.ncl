;***************************************
; PROGRAM DESCRIPTION: This NCL script Finds max and mean wind and flux values
; INPUT DATA: WRF output at four resolutions, Quikscat processed files
; OUTPUT DATA: Text files with max and mean wind and flux values
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
;; assign some info to start
;name = "21FEB"
;day = "2007-02-21"
;hr = "07UTC"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set file names based on qs pass
if (hr.eq."07UTC") then
  pass = "asc"
  fname1 = "wrf-" + day + "-07"
end if
if (hr .eq."22UTC") then
  pass = "des"
  fname1 = "wrf-" + day + "-22"
end if

; getting correct directories
    dir0 = "/data3/duvivier/NCAR/DATA/" + name + "/Quikscat/"
    dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_10km/"
    dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_25km/"
    dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_50km/"
    dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_100km/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "table_values" + day + "_" +hr 

; set up WRF variables
    invar1 = "u_10m_tr"
    invar2 = "v_10m_tr"
    invar3 = "SHFlx"
    invar4 = "LHFlx"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in quikscat files and variables
;;;;;;;;;;
  header = 0
  ncol = 170

  lat2d_0 = readAsciiTable(dir0+"Quikscat_lat2d.txt",ncol,"float",header)
  lon2d_0 = readAsciiTable(dir0+"Quikscat_lon2d.txt",ncol,"float",header)

  var1_0  = readAsciiTable(dir0 + "Quikscat_" + pass + "_u.txt",ncol,"float",header)
  var1_0@_FillValue = -999
  var2_0  = readAsciiTable(dir0 + "Quikscat_" + pass + "_v.txt",ncol,"float",header)
  var2_0@_FillValue = -999
  speed_0 = sqrt(var1_0^2 + var2_0^2)
  
  var1_0@lat2d = lat2d_0
  var1_0@lon2d = lon2d_0
  var1_0@units = "m s-1"
  copy_VarMeta(var1_0, var2_0)
  copy_VarMeta(var1_0, speed_0)

;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

; first wrf file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  var1_1  = f1->$invar1$(time|0,south_north|:,west_east|:)
  var2_1  = f1->$invar2$(time|0,south_north|:,west_east|:)
  speed_1 = sqrt(var1_1^2 + var2_1^2)
  sh_1    = f1->$invar3$(time|0,south_north|:,west_east|:)
  lh_1    = f1->$invar4$(time|0,south_north|:,west_east|:)

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1
  copy_VarMeta(var1_1, var2_1)
  copy_VarMeta(var1_1, speed_1)

  sh_1@lat2d = lat2d_1
  sh_1@lon2d = lon2d_1
  lh_1@lat2d = lat2d_1
  lh_1@lon2d = lon2d_1

  ; land mask data for values
  f1_geo = addfile("/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_10km.nc", "r")
  land1 = f1_geo->LANDMASK(Time|0,south_north|:,west_east|:)


; second wrf file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var1_2  = f2->$invar1$(time|0,south_north|:,west_east|:)
  var2_2  = f2->$invar2$(time|0,south_north|:,west_east|:)
  speed_2 = sqrt(var1_2^2 + var2_2^2)
  sh_2    = f2->$invar3$(time|0,south_north|:,west_east|:)
  lh_2    = f2->$invar4$(time|0,south_north|:,west_east|:)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2
  copy_VarMeta(var1_2, var2_2)
  copy_VarMeta(var1_2, speed_2)

  sh_2@lat2d = lat2d_2 
  sh_2@lon2d = lon2d_2
  lh_2@lat2d = lat2d_2
  lh_2@lon2d = lon2d_2

  ; land mask data for values
  f2_geo = addfile("/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_25km.nc", "r")
  land2 = f2_geo->LANDMASK(Time|0,south_north|:,west_east|:)


; third wrf file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var1_3  = f3->$invar1$(time|0,south_north|:,west_east|:)
  var2_3  = f3->$invar2$(time|0,south_north|:,west_east|:)
  speed_3 = sqrt(var1_3^2 + var2_3^2)
  sh_3    = f3->$invar3$(time|0,south_north|:,west_east|:)
  lh_3    = f3->$invar4$(time|0,south_north|:,west_east|:)

  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3
  copy_VarMeta(var1_3, var2_3)
  copy_VarMeta(var1_3, speed_3)

  sh_3@lat2d = lat2d_3
  sh_3@lon2d = lon2d_3
  lh_3@lat2d = lat2d_3
  lh_3@lon2d = lon2d_3

  ; land mask data for values
  f3_geo = addfile("/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_50km.nc", "r")
  land3 = f3_geo->LANDMASK(Time|0,south_north|:,west_east|:)


; fourth wrf file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->lat
  lon2d_4 = f4->lon
  var1_4  = f4->$invar1$(time|0,south_north|:,west_east|:)
  var2_4  = f4->$invar2$(time|0,south_north|:,west_east|:)
  speed_4 = sqrt(var1_4^2 + var2_4^2)
  sh_4    = f4->$invar3$(time|0,south_north|:,west_east|:)
  lh_4    = f4->$invar4$(time|0,south_north|:,west_east|:)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4
  copy_VarMeta(var1_4, var2_4)
  copy_VarMeta(var1_4, speed_4)

  sh_4@lat2d = lat2d_4
  sh_4@lon2d = lon2d_4
  lh_4@lat2d = lat2d_4
  lh_4@lon2d = lon2d_4

  ; land mask data for values
  f4_geo = addfile("/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_100km.nc", "r")
  land4 = f4_geo->LANDMASK(Time|0,south_north|:,west_east|:)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Subset data by lat/lon
;;;;;;;;;;;;
  print("Subsetting data of interest")
  fill = speed_1@_FillValue

; subset data where 56<lat<70 and -54<lon<-20
; for true values, make the subset array the value from the average, for false values make it the fill value so it won't go into summed values

  ; file 1
  speed_1_sub = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., speed_1, fill)
  sh_1_sub    = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., sh_1, fill)
  lh_1_sub    = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., lh_1, fill)

  speed_1_sub@_FillValue = fill
  lh_1_sub@_FillValue = fill
  sh_1_sub@_FillValue = fill

  ; file 2
  speed_2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., speed_2, fill)
  sh_2_sub    = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., sh_2, fill)
  lh_2_sub    = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., lh_2, fill)

  speed_2_sub@_FillValue = fill
  lh_2_sub@_FillValue = fill
  sh_2_sub@_FillValue = fill

  ; file 3
  speed_3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., speed_3, fill)
  sh_3_sub    = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., sh_3, fill)
  lh_3_sub    = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., lh_3, fill)

  speed_3_sub@_FillValue = fill
  lh_3_sub@_FillValue = fill
  sh_3_sub@_FillValue = fill

  ; file 4
  speed_4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., speed_4, fill)
  sh_4_sub    = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., sh_4, fill)
  lh_4_sub    = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., lh_4, fill)

  speed_4_sub@_FillValue = fill
  lh_4_sub@_FillValue = fill
  sh_4_sub@_FillValue = fill


;;;;;;;;;;;;;
; Mask out land points
;;;;;;;;;;;;
  print("Masking land points for fluxes")
  ; can use False or 0 as last argument to set it to a fill value

  speed1_masked = mask(speed_1_sub, land1 .eq. 1, False)
  lh1_masked    = mask(lh_1_sub, land1 .eq. 1, False)
  sh1_masked    = mask(sh_1_sub, land1 .eq. 1, False)

  speed2_masked = mask(speed_2_sub, land2 .eq. 1, False)
  lh2_masked    = mask(lh_2_sub, land2 .eq. 1, False)
  sh2_masked    = mask(sh_2_sub, land2 .eq. 1, False)

  speed3_masked = mask(speed_3_sub, land3 .eq. 1, False)
  lh3_masked    = mask(lh_3_sub, land3 .eq. 1, False)
  sh3_masked    = mask(sh_3_sub, land3 .eq. 1, False)

  speed4_masked = mask(speed_4_sub, land4 .eq. 1, False)
  lh4_masked    = mask(lh_4_sub, land4 .eq. 1, False)
  sh4_masked    = mask(sh_4_sub, land4 .eq. 1, False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Write to a text file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; THIS IS NOT AT ALL EFFICIENT, BUT WAS EASIEST FOR NOW

head = "Table values for " + day + " " + hr

a1 = "Quikscat max wind: " + max(speed_0) + " and avg wind: " + avg(speed_0) + "  [m/s]"
output1 = array_append_record(head, a1, 0)

a2 = "WRF10 max wind: " + max(speed1_masked) + " and avg wind: " + avg(speed1_masked) + "  [m/s]"
output2 = array_append_record(output1, a2, 0)

a3 = "WRF10 max LHFlx: " + max(lh1_masked) + " and avg LHFlx: " + avg(lh1_masked) + "  [W/m2]"
output3 = array_append_record(output2, a3, 0)

a4 = "WRF10 max SHFlx: " + max(sh1_masked) + " and avg SHFlx: " + avg(sh1_masked) + "  [W/m2]"
output4 = array_append_record(output3, a4, 0)

a5 = "WRF25 max wind: " + max(speed2_masked) + " and avg wind: " + avg(speed2_masked) + "  [m/s]"
output5 = array_append_record(output4, a5, 0)

a6 = "WRF25 max LHFlx: " + max(lh2_masked) + " and avg LHFlx: " + avg(lh2_masked) + "  [W/m2]"
output6 = array_append_record(output5, a6, 0)

a7 = "WRF25 max SHFlx: " + max(sh2_masked) + " and avg SHFlx: " + avg(sh2_masked) + "  [W/m2]"
output7 = array_append_record(output6, a7, 0)

a8 = "WRF50 max wind: " + max(speed3_masked) + " and avg wind: " + avg(speed3_masked) + "  [m/s]"
output8 = array_append_record(output7, a8, 0)

a9 = "WRF50 max LHFlx: " + max(lh3_masked) + " and avg LHFlx: " + avg(lh3_masked) + "  [W/m2]"
output9 = array_append_record(output8, a9, 0)

a10 = "WRF50 max SHFlx: " + max(sh3_masked) + " and avg SHFlx: " + avg(sh3_maskesd) + "  [W/m2]"
output10 = array_append_record(output9, a10, 0)

a11 = "WRF100 max wind: " + max(speed4_masked) + " and avg wind: " + avg(speed4_masked) + "  [m/s]"
output11 = array_append_record(output10, a11, 0)

a12 = "WRF100 max LHFlx: " + max(lh4_masked) + " and avg LHFlx: " + avg(lh4_masked) + "  [W/m2]"
output12 = array_append_record(output11, a12, 0)

a13 = "WRF100 max SHFlx: " + max(sh4_masked) + " and avg SHFlx: " + avg(sh4_masked) + "  [W/m2]"
output13 = array_append_record(output12, a13, 0)


asciiwrite(fout + ".txt", output13)

;;;;;;;;;;;;;;;;;;;;;; END script
end
