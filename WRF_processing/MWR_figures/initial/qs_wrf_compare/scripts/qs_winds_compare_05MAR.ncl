;***************************************
; PROGRAM DESCRIPTION: This NCL script "final version" plots WRF and Quikscat winds and ERA-I spatial winds
; INPUT DATA: Quikscat text files, processed from Matlab, and WRF output at 4 resolutions, ERA-I .nc files
; OUTPUT DATA: Panel plot of QuikSCAT, ERA-I, and WRF surface wind data
; Note: These plots are zoomed and at each data set's native resolution
;       This script is for 5 March
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; assign some info to start
name = "05MAR"
day = "2007-03-05"
hr = "22UTC"
pass = "des"
fname1 = "wrf-" + day + "-22"
e_name = "erai_sfc-2007-03-06-00"

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for "+day)

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")

  plot = new(6, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

 res                             = True              ; plot mods desired

 ; set general domain resources
  ;res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set for Greenland
  res@mpCenterLatF                = 60.               ; -----set for Greenland

  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude
  res@mpMaxLatF                   = 70.              ; set the maximum latitude
  res@mpMinLonF                   = -54.0            ; set the minimum longitude
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5               ; Make continents thinner

; set contour resources
  res@cnFillMode                  = cntype
  res@cnFillOn                    = True              ; turn on filled contours
  res@gsnSpreadColors             = True              ; use full colormap
  res@gsnSpreadColorStart         = spreadstart1      ; start at color specified 
  res@gsnSpreadColorEnd           = spreadend1        ; end at color specified 
  res@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF              = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  res@cnLinesOn                   = plotlines         ; contour lines specified above
  res@cnLineLabelsOn              = plotlines         ; line labels on specified above
  res@cnMissingValFillColor       = "grey"          ; missing value color
  res@cnMissingValFillPattern     = 0                 ; fill in
  res@tiMainFontHeightF           = 0.017
  res@lbLabelBarOn                = False             ; turn off individual label bars

 ; set vector resources 
  vcres                            = True
  vcres@gsnRightString             = ""
  vcres@gsnLeftString              = ""
  vcres@gsnFrame                   = False             ; Do not draw plot 
  vcres@gsnDraw                    = False             ; Do not advance fr
  vcres@gsnAddCyclic               = False             ; regional - not cyclic 
  vcres@vcGlyphStyle               = "LineArrow"
  vcres@vcRefMagnitudeF            = 20.               ; set vector reference magnitude
  vcres@vcRefLengthF               = 0.03              ; length of vector (larger = longer)
  vcres@vcMinDistanceF             = 0.04              ; vector spacing (smaller = more dense)
  vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder
 
 ; set vector legend resources
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "20 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string

;;;;;;;;;;;;;
; Plot 0 - QuikSCAT plot
;;;;;;;;;;;;;

  opts0                            = res
  opts0@tiMainString               = "QuikSCAT (0.25 deg) - " + day + " " + hr

  cplot0a = gsn_csm_contour_map(wks, speed_0 , opts0)      ; create ascending plot
    cplot0b = gsn_csm_vector(wks, var1_0, var2_0, vcres)
    overlay(cplot0a,cplot0b)
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 10km plot
;;;;;;;;;;;;;

  opts1                            = res
  opts1@tiMainString               = "WRF (10 km) - " + day + " " + hr

  cplot1a = gsn_csm_contour_map(wks, speed_1 , opts1)      ; create ascending plot
    cplot1b = gsn_csm_vector(wks, var1_1, var2_1, vcres)
    overlay(cplot1a,cplot1b)
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 25km plot
;;;;;;;;;;;;;

  opts2                            = res
  opts2@tiMainString               = "WRF (25 km) - " + day + " " + hr

  cplot2a = gsn_csm_contour_map(wks, speed_2 , opts2)      ; create ascending plot
    cplot2b = gsn_csm_vector(wks, var1_2, var2_2, vcres)
    overlay(cplot2a,cplot2b)
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 50km plot
;;;;;;;;;;;;;

  opts3                            = res
  opts3@tiMainString               = "WRF (50 km) - " + day + " " + hr

  cplot3a = gsn_csm_contour_map(wks, speed_3 , opts3)      ; create ascending plot
    cplot3b = gsn_csm_vector(wks, var1_3, var2_3, vcres)
    overlay(cplot3a,cplot3b)
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Plot 4 - WRF 100km plot
;;;;;;;;;;;;;

  opts4                            = res
  opts4@tiMainString               = "WRF (100 km) - " + day + " " + hr

  cplot4a = gsn_csm_contour_map(wks, speed_4 , opts4)      ; create ascending plot
    cplot4b = gsn_csm_vector(wks, var1_4, var2_4, vcres)
    overlay(cplot4a,cplot4b)
  plot(4) = cplot4a   

;;;;;;;;;;;;;
; Plot 5 - Era-I plot
;;;;;;;;;;;;;

  opts5                            = res
  opts5@tiMainString               = "ERA-Interim (1.5 deg) - 2007-03-06 00UTC"

  cplot5a = gsn_csm_contour_map(wks, speed_5 , opts5)      ; create ascending plot
    cplot5b = gsn_csm_vector(wks, var1_5, var2_5, vcres)
    overlay(cplot5a,cplot5b)
  plot(5) = cplot5a

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "QuikSCAT, WRF, and ERA-Interim 10m winds"

  pnlres                            = True
  pnlres@gsnPaperOrientation        = "landscape"       ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@txString                   = title_fin           ; set title for whole panel plot.
  pnlres@txFontHeightF              = 0.013

  ; set label bar resources
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbLabelStride              = stride1

  gsn_panel(wks,(/plot/),(/2,3/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script
end
