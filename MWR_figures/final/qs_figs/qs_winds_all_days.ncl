;***************************************
; PROGRAM DESCRIPTION: This NCL script plots all 5 case study QS wind days
; INPUT DATA: Quikscat text files, processed from Matlab
; OUTPUT DATA: Panel plot of QuikSCAT data with GFDex cross sections overlayed
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; assign daily info to start. The hours have been selected for interest.
    name0  = "21FEB"
    fname0 = "wrf-2007-02-21-07"
    pass0  = "asc"
    dir0   = "/data3/duvivier/NCAR/DATA/" + name0 + "/Quikscat/"
    
    name1  = "02MAR"
    fname1 = "wrf-2007-03-02-22"
    pass1  = "des"
    dir1   = "/data3/duvivier/NCAR/DATA/" + name1 + "/Quikscat/"

    name2  = "05MAR"
    fname2 = "wrf-2007-03-05-22"
    pass2  = "des"
    dir2   = "/data3/duvivier/NCAR/DATA/" + name2 + "/Quikscat/"

    name3  = "06MAR"
    fname3 = "wrf-2007-03-06-22"
    pass3  = "des"
    dir3   = "/data3/duvivier/NCAR/DATA/" + name3 + "/Quikscat/"

    name4  = "09MAR"
    fname4 = "wrf-2007-03-09-07"
    pass4  = "asc"
    dir4   = "/data3/duvivier/NCAR/DATA/" + name4 + "/Quikscat/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "QS_all_days"

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

  print("Running Wind figs for qs ")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in quikscat files and variables
;;;;;;;;;;
  header = 0
  ncol = 170

  lat2d = readAsciiTable(dir0+"Quikscat_lat2d.txt",ncol,"float",header)
  lon2d = readAsciiTable(dir0+"Quikscat_lon2d.txt",ncol,"float",header)

  dimml = dimsizes(lat2d)
  nlat = dimml(0)
  nlon = dimml(1)

  ; load QS day 1: 21FEB
  var1_0  = readAsciiTable(dir0 + "Quikscat_" + pass0 + "_u.txt",ncol,"float",header)
  var2_0  = readAsciiTable(dir0 + "Quikscat_" + pass0 + "_v.txt",ncol,"float",header)
  
  var1_0@lat2d = lat2d
  var1_0@lon2d = lon2d
  var1_0@units = "m s-1"
  var1_0@_FillValue = -999.
  copy_VarMeta(var1_0, var2_0)

  speed_0 = sqrt(var1_0^2 + var2_0^2)
  copy_VarMeta(var1_0, speed_0)

  ; load QS day 2: 02MAR
  var1_1  = readAsciiTable(dir1 + "Quikscat_" + pass1 + "_u.txt",ncol,"float",header)
  var2_1  = readAsciiTable(dir1 + "Quikscat_" + pass1 + "_v.txt",ncol,"float",header) 
  copy_VarMeta(var1_0, var1_1)
  copy_VarMeta(var1_1, var2_1)

  speed_1 = sqrt(var1_1^2 + var2_1^2)
  copy_VarMeta(var1_1, speed_1)

 ; load QS day 3: 05MAR
  var1_2  = readAsciiTable(dir2 + "Quikscat_" + pass2 + "_u.txt",ncol,"float",header)
  var2_2  = readAsciiTable(dir2 + "Quikscat_" + pass2 + "_v.txt",ncol,"float",header) 
  copy_VarMeta(var1_0, var1_2)
  copy_VarMeta(var1_2, var2_2)

  speed_2 = sqrt(var1_2^2 + var2_2^2)
  copy_VarMeta(var1_2, speed_2)

  ; load QS day 4: 06MAR
  var1_3  = readAsciiTable(dir3 + "Quikscat_" + pass3 + "_u.txt",ncol,"float",header)
  var2_3  = readAsciiTable(dir3 + "Quikscat_" + pass3 + "_v.txt",ncol,"float",header)
  copy_VarMeta(var1_0, var1_3)  
  copy_VarMeta(var1_3, var2_3)

  speed_3 = sqrt(var1_3^2 + var2_3^2)
  copy_VarMeta(var1_3, speed_3)

 ; load QS day 5: 09MAR
  var1_4  = readAsciiTable(dir4 + "Quikscat_" + pass4 + "_u.txt",ncol,"float",header)
  var2_4  = readAsciiTable(dir4 + "Quikscat_" + pass4 + "_v.txt",ncol,"float",header)
  copy_VarMeta(var1_0, var1_4)   
  copy_VarMeta(var1_4, var2_4)

  speed_4 = sqrt(var1_4^2 + var2_4^2)
  copy_VarMeta(var1_4, speed_4)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing all QS graphs")

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")

  plot = new(6, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

 res                             = True              ; plot mods desired

 ; set general domain resources
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set for Greenland
  res@mpCenterLatF                = 60.               ; -----set for Greenland

  ;res@mpLimitMode                 = "Corners"
  ;res@mpLeftCornerLatF            = lat2d(0,0)        ; set the lat/lon sides
  ;res@mpLeftCornerLonF            = lon2d(0,0)
  ;res@mpRightCornerLatF           = lat2d(nlat-1,nlon-1)
  ;res@mpRightCornerLonF           = lon2d(nlat-1,nlon-1)

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
  res@tiMainFontHeightF           = 0.025
  res@tiMainFontThicknessF        = 1.5
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
  vcres@vcLineArrowThicknessF      = 2.0               ; thickness of vector arrows (larger = bolder
 
 ; set vector legend resources
  vcres@vcRefAnnoOrthogonalPosF    = -0.2             ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.99              ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "20 m s~S~-1~N~"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2On         = False              ; turn on bottom vector label string
  vcres@vcRefAnnoFontHeightF       = 0.02

; set line res to show cross section line
  lnres                            = True
   lnres@gsLineThicknessF          = 4.0
   lnres@gsLineColor               = "black"

; set text res to show start and end of cross section
   txres                           = True
   txres@txFontHeightF             = 0.025

;;;;;;;;;;;;;
; Plot 0 - QuikSCAT 21FEB plot
;;;;;;;;;;;;;

  opts0                            = res
;  opts0@gsnLeftString              = "a)"
  opts0@tiMainString               = "a)       21 February, 2007 - 07UTC" 

  cplot0a = gsn_csm_contour_map(wks, speed_0 , opts0)      ; create ascending plot
    cplot0b = gsn_csm_vector(wks, var1_0, var2_0, vcres)
    overlay(cplot0a,cplot0b)

;; add in line showing where cross section in future figures is located 
; lat and lons for polyline
  st_lat0 = 60.1
  st_lon0 = -43.1
  ed_lat0 = 59.25
  ed_lon0 = -40.0 

  dum = new(1, graphic)      ; make dummy variable
  dum = gsn_add_polyline(wks,cplot0a,(/st_lon0,ed_lon0/), (/st_lat0, ed_lat0/), lnres)
  
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot0a, "A", st_lon0-.25, st_lat0+.5, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot0a, "B", ed_lon0+.5, ed_lat0-.25, txres)


  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - QuikSCAT 02MAR plot
;;;;;;;;;;;;;

  opts1                            = res
;  opts1@gsnLeftString              = "b)"
  opts1@tiMainString               = "b)       2 March, 2007 - 22UTC" 

  cplot1a = gsn_csm_contour_map(wks, speed_1 , opts1)      ; create ascending plot
    cplot1b = gsn_csm_vector(wks, var1_1, var2_1, vcres)
    overlay(cplot1a,cplot1b)

;; add in line showing where cross section in future figures is located 
; lat and lons for polyline
  st_lat1 = 68.0
  st_lon1 = -30.5
  ed_lat1 = 65.5
  ed_lon1 = -27.0

  dum4 = new(1, graphic)      ; make dummy variable
  dum4 = gsn_add_polyline(wks,cplot1a,(/st_lon1,ed_lon1/), (/st_lat1, ed_lat1/), lnres)
  
  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks, cplot1a, "A", st_lon1-.25, st_lat1+.5, txres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks, cplot1a, "B", ed_lon1+.5, ed_lat1-.25, txres)


  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - QuikSCAT 05MAR plot
;;;;;;;;;;;;;

  opts2                            = res
;  opts2@gsnLeftString              = "c)"
  opts2@tiMainString               = "c)       5 March, 2007 - 22UTC" 

  cplot2a = gsn_csm_contour_map(wks, speed_2 , opts2)      ; create ascending plot
    cplot2b = gsn_csm_vector(wks, var1_2, var2_2, vcres)
    overlay(cplot2a,cplot2b)

  plot(2) = cplot2a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 3 - QuikSCAT 06MAR plot
;;;;;;;;;;;;;

  opts3                            = res
;  opts3@gsnLeftString              = "d)"
  opts3@tiMainString               = "d)       6 March, 2007 - 22UTC" 

  cplot3a = gsn_csm_contour_map(wks, speed_3 , opts3)      ; create ascending plot
    cplot3b = gsn_csm_vector(wks, var1_3, var2_3, vcres)
    overlay(cplot3a,cplot3b)

;; add in line showing where cross section in future figures is located 
; lat and lons for polyline
  st_lat3 = 69.0
  st_lon3 = -26.0
  ed_lat3 = 69.5
  ed_lon3 = -19.0

  dum7 = new(1, graphic)      ; make dummy variable
  dum7 = gsn_add_polyline(wks,cplot3a,(/st_lon3,ed_lon3/), (/st_lat3, ed_lat3/), lnres)
  
  dum8 = new(1,graphic)
  dum8 = gsn_add_text(wks, cplot3a, "A", st_lon3-.25, st_lat3+.5, txres)

  dum9 = new(1,graphic)
  dum9 = gsn_add_text(wks, cplot3a, "B", ed_lon3+.5, ed_lat3-.25, txres)


  plot(3) = cplot3a                                         ; make panel section of this plot

;;;;;;;;;;;;
; Plot 4 - QuikSCAT 09MAR plot
;;;;;;;;;;;;;

  opts4                            = res
;  opts4@gsnLeftString              = "e)"
  opts4@tiMainString               = "e)       9 March, 2007 - 07UTC" 

  cplot4a = gsn_csm_contour_map(wks, speed_4 , opts4)      ; create ascending plot
    cplot4b = gsn_csm_vector(wks, var1_4, var2_4, vcres)
    overlay(cplot4a,cplot4b)

  plot(4) = cplot4a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "QuikSCAT satellite 10 m winds (m s~S~-1~N~)"

  pnlres                            = True
  pnlres@gsnPaperOrientation        = "landscape"       ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@txString                   = title_fin           ; set title for whole panel plot.
  pnlres@txFontHeightF              = 0.013
  pnlres@txFontThicknessF           = 2.0

  ; set label bar resources
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbLabelFontHeightF         = 0.015              ; label bar font size
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
