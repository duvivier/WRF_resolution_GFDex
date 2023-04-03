;***************************************
; PROGRAM DESCRIPTION: This NCL script "final version" plots WRF and Quikscat winds
; INPUT DATA: Quikscat text files, processed from Matlab, and WRF output at 4 resolutions
; OUTPUT DATA: Panel plot of QuikSCAT and WRF surface wind data
; Note: These plots are zoomed and at each data set's native resolution
; CREATOR: Alice DuVivier - July 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; assign some info to start
name = "09MAR"
day = "2007-03-09"
hr = "07UTC"
pass = "asc"
fname1 = "wrf-" + day + "-07"
e_name = "erai_sfc-" + day + "-06"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; getting correct directories
    dir0 = "/data3/duvivier/NCAR/DATA/" + name + "/Quikscat/"
    dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_10km/"
    dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_25km/"
    dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_50km/"
    dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_100km/"
    dir5 = "/data3/duvivier/NCAR/DATA/" + name + "/era_i/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "Windsurf_qs_wrf_era-" + day + "_" +hr 

; set up WRF wind variables
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_tr"
    invar2 ="v_10m_tr"
    vartype = "2d"
    find_speed = True

; Set the contour interval for each winds
    cmin1 = 0
    cmax1 = 44.
    clev1 = 4.
    stride1             = 1                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1 = 2
    spreadend1 = 254
    colormap            = "WhiteYellowOrangeRed"

  print("Running Wind figs for qs and wrf-" + day)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in quikscat files and variables
;;;;;;;;;;
  print("Loading QuikSCAT")

  header = 0
  ncol = 170

  lat2d_0 = readAsciiTable(dir0+"Quikscat_lat2d.txt",ncol,"float",header)
  lon2d_0 = readAsciiTable(dir0+"Quikscat_lon2d.txt",ncol,"float",header)

  var1_0  = readAsciiTable(dir0 + "Quikscat_" + pass + "_u.txt",ncol,"float",header)
  var2_0  = readAsciiTable(dir0 + "Quikscat_" + pass + "_v.txt",ncol,"float",header)

  var1_0@_FillValue = -999.
  var1_0@lat2d = lat2d_0
  var1_0@lon2d = lon2d_0
  var1_0@units = "m s-1"
  copy_VarMeta(var1_0, var2_0)

  speed_0 = sqrt(var1_0^2 + var2_0^2)
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

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1
  copy_VarMeta(var1_1, var2_1)
  copy_VarMeta(var1_1, speed_1)

; second wrf file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var1_2  = f2->$invar1$(time|0,south_north|:,west_east|:)
  var2_2  = f2->$invar2$(time|0,south_north|:,west_east|:)
  speed_2 = sqrt(var1_2^2 + var2_2^2)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2
  copy_VarMeta(var1_2, var2_2)
  copy_VarMeta(var1_2, speed_2)

; third wrf file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var1_3  = f3->$invar1$(time|0,south_north|:,west_east|:)
  var2_3  = f3->$invar2$(time|0,south_north|:,west_east|:)
  speed_3 = sqrt(var1_3^2 + var2_3^2)

  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3
  copy_VarMeta(var1_3, var2_3)
  copy_VarMeta(var1_3, speed_3)

; fourth wrf file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->lat
  lon2d_4 = f4->lon
  var1_4  = f4->$invar1$(time|0,south_north|:,west_east|:)
  var2_4  = f4->$invar2$(time|0,south_north|:,west_east|:)
  speed_4 = sqrt(var1_4^2 + var2_4^2)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4
  copy_VarMeta(var1_4, var2_4)
  copy_VarMeta(var1_4, speed_4)

;;;;;;;;;;
; load in era files and variables
;;;;;;;;;;
  print("Loading era_i")

  f5 = addfile(dir5 + e_name + ".nc","r")  ; Load first wrf file
  lat1d_5 = f5->g4_lat_0
  lon1d_5 = f5->g4_lon_1
  var1_5  = f5->10U_GDS4_SFC(:,:)
  var2_5  = f5->10V_GDS4_SFC(:,:)
  speed_5 = sqrt(var1_5^2 + var2_5^2)
  copy_VarMeta(var1_5, speed_5)
  speed_5@units = "m s-1"

  ; subset data for the boxed area
  ; lat :  70>lat>56
  ; lon:   -20(340)>lon>-56(306)

  lat_sub = lat1d_5(28:48)
  lon_sub = lon1d_5(436:483)
  speed_5_sub = speed_5(28:48, 436:483)

  print("Maximum subset ERA-I wind: " + max(speed_5_sub))
  print("Minimum subset ERA-I wind: " + min(speed_5_sub))
  print("Mean subset ERA-I wind: " + avg(speed_5_sub))


;;;;;;;;;;;;;;;;;;;;;; END script
end
