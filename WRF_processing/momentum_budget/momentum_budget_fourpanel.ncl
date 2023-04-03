;***************************************
; PROGRAM DESCRIPTION: This NCL script plots momentum budget terms
; INPUT DATA: Momentum budget files created previously with 'momentum_budget_calc.ncl'
; OUTPUT DATA: Panel plot of momentum budget terms for each resolution
; Note: These plots are zoomed and at each data set's native resolution
; at the moment they do not plot vectors, but adding vectors should be trivial
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
date = "2007-03-05-22"
varcode = "PGF"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set file name
  fname0 = "momentum_budget_grid-wrf_10km-" + date
  fname1 = "momentum_budget_grid-wrf_25km-" + date
  fname2 = "momentum_budget_grid-wrf_50km-" + date
  fname3 = "momentum_budget_grid-wrf_100km-" + date

; getting correct directories
    dir0 = "/data3/duvivier/NCAR/momentum_budget/budget_files/"
    outdir = "./"
    fout   = outdir + "momentum_budget_" + varcode + "_" + date

; set up variables
  if (varcode.eq."PGF") then
    vartitle1 = "Pressure Gradient"
    invar0 = "pg_mag"
    invar1 = "pg_u"
    invar2 = "pg_v"
  end if
  if (varcode.eq."COR") then
    vartitle1 = "Coriolis"
    invar0 = "cf_mag"
    invar1 = "cf_u"
    invar2 = "cf_v"
  end if
  if (varcode.eq."ADVECT") then
    vartitle1 = "Advection"
    invar0 = "advection_mag"
    invar1 = "advection_u"
    invar2 = "advection_v"
  end if
  if (varcode.eq."CUR") then
    vartitle1 = "Curvature"
    invar0 = "curvature_mag"
    invar1 = "curvature_u"
    invar2 = "curvature_v"
  end if
  if (varcode.eq."FRIC") then
    vartitle1 = "Friction"
    invar0 = "friction_mag"
    invar1 = "friction_u"
    invar2 = "friction_v"
  end if
  if (varcode.eq."DDT") then
    vartitle1 = "Acceleration"
    invar0 = "d_dt_mag"
    invar1 = "du_dt"
    invar2 = "dv_dt"
  end if


; Set the contour interval for each winds
    cmin1               = 0.
    cmax1               = 0.01
    clev1               = 0.001
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1        = 2
    spreadend1          = 254
    colormap            = "WhiteBlueGreenYellowRed"
    units               = "m s-2"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading data for momentum term " + varcode)

; first momentum file
  f0 = addfile(dir0 + fname0 + ".nc","r")  ; Load first wrf file
  lat2d_0 = f0->lat
  lon2d_0 = f0->lon
  var0_0  = f0->$invar0$(:,:)
  var1_0  = f0->$invar1$(:,:)
  var2_0  = f0->$invar2$(:,:)

  var0_0@lat2d = lat2d_0
  var0_0@lon2d = lon2d_0
  var0_0@units = units
  copy_VarMeta(var0_0, var1_0)
  copy_VarMeta(var0_0, var2_0)

; second momentum file
  f1 = addfile(dir0 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  var0_1  = f1->$invar0$(:,:)
  var1_1  = f1->$invar1$(:,:)
  var2_1  = f1->$invar2$(:,:)

  var0_1@lat2d = lat2d_1
  var0_1@lon2d = lon2d_1
  var0_1@units = units
  copy_VarMeta(var0_1, var1_1)
  copy_VarMeta(var0_1, var2_1)

; third momentum file
  f2 = addfile(dir0 + fname2 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var0_2  = f2->$invar0$(:,:)
  var1_2  = f2->$invar1$(:,:)
  var2_2  = f2->$invar2$(:,:)

  var0_2@lat2d = lat2d_2
  var0_2@lon2d = lon2d_2
  var0_2@units = units
  copy_VarMeta(var0_2, var1_2)
  copy_VarMeta(var0_2, var2_2)

; fourth momentum file
  f3 = addfile(dir0 + fname3 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var0_3  = f3->$invar0$(:,:)
  var1_3  = f3->$invar1$(:,:)
  var2_3  = f3->$invar2$(:,:)

  var0_3@lat2d = lat2d_3
  var0_3@lon2d = lon2d_3
  var0_3@units = units
  copy_VarMeta(var0_3, var1_3)
  copy_VarMeta(var0_3, var2_3)

;;;;;;;;;;
; rotate vectorial variables for plotting
;;;;;;;;;;
  ; set constants
  cen_long = -36.
  cone = 1
  rpd = 3.14159265/180.

  ; first momentum file
  longca = lon2d_0-cen_long
  longca = where(longca .gt. 180., longca-360., longca)
  longca = where(longca .lt. -180., longca+360., longca)
  longcb = longca
  longcb = where(lat2d_0 .lt. 0., -longca*cone*rpd, longcb)
  longcb = where(lat2d_0 .ge. 0., longca*cone*rpd, longcb)

  longca = cos(longcb)
  longcb = sin(longcb)

  var1_0_rot = var2_0*longcb + var1_0*longca
  var2_0_rot = var2_0*longca - var1_0*longcb
  copy_VarMeta(var1_0, var1_0_rot)
  copy_VarMeta(var2_0, var2_0_rot)

  delete(longca)
  delete(longcb)

  ; second momentum file
  longca = lon2d_1-cen_long
  longca = where(longca .gt. 180., longca-360., longca)
  longca = where(longca .lt. -180., longca+360., longca)
  longcb = longca
  longcb = where(lat2d_1 .lt. 0., -longca*cone*rpd, longcb)
  longcb = where(lat2d_1 .ge. 0., longca*cone*rpd, longcb)

  longca = cos(longcb)
  longcb = sin(longcb)

  var1_1_rot = var2_1*longcb + var1_1*longca
  var2_1_rot = var2_1*longca - var1_1*longcb
  copy_VarMeta(var1_1, var1_1_rot)
  copy_VarMeta(var2_1, var2_1_rot)

  delete(longca)
  delete(longcb)

  ; third momentum file
  longca = lon2d_2-cen_long
  longca = where(longca .gt. 180., longca-360., longca)
  longca = where(longca .lt. -180., longca+360., longca)
  longcb = longca
  longcb = where(lat2d_2 .lt. 0., -longca*cone*rpd, longcb)
  longcb = where(lat2d_2 .ge. 0., longca*cone*rpd, longcb)

  longca = cos(longcb)
  longcb = sin(longcb)

  var1_2_rot = var2_2*longcb + var1_2*longca
  var2_2_rot = var2_2*longca - var1_2*longcb
  copy_VarMeta(var1_2, var1_2_rot)
  copy_VarMeta(var2_2, var2_2_rot)

  delete(longca)
  delete(longcb)

  ; fourth momentum file
  longca = lon2d_3-cen_long
  longca = where(longca .gt. 180., longca-360., longca)
  longca = where(longca .lt. -180., longca+360., longca)
  longcb = longca
  longcb = where(lat2d_3 .lt. 0., -longca*cone*rpd, longcb)
  longcb = where(lat2d_3 .ge. 0., longca*cone*rpd, longcb)

  longca = cos(longcb)
  longcb = sin(longcb)

  var1_3_rot = var2_3*longcb + var1_3*longca
  var2_3_rot = var2_3*longca - var1_3*longcb
  copy_VarMeta(var1_3, var1_3_rot)
  copy_VarMeta(var2_3, var2_3_rot)

  delete(longca)
  delete(longcb)

print("force vectors rotated")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for " + varcode + " on " + date)

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")

  plot = new(4, graphic)

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
  res@cnMissingValFillColor       = "white"          ; missing value color
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
  vcres@vcRefMagnitudeF            = 0.002               ; set vector reference magnitude
  vcres@vcRefLengthF               = 0.01              ; length of vector (larger = longer)
  ;vcres@vcMinDistanceF             = 0.02              ; vector spacing (smaller = more dense)
  vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder
  vcres@vcRefAnnoOn                = False             ; no legend for vectors
 
;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = res
  opts0@tiMainString               = "WRF (10km) - " + date

  cplot0a = gsn_csm_contour_map(wks, var0_0 , opts0)      ; create ascending plot
;    cplot0b = gsn_csm_vector(wks, var1_0, var2_0, vcres)
;    overlay(cplot0a,cplot0b)
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;

  opts1                            = res
  opts1@tiMainString               = "WRF (25km) - " + date

  cplot1a = gsn_csm_contour_map(wks, var0_1 , opts1)      ; create ascending plot
;    cplot1b = gsn_csm_vector(wks, var1_1, var2_1, vcres)
;    overlay(cplot1a,cplot1b)
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;

  opts2                            = res
  opts2@tiMainString               = "WRF (50km) - " + date

  cplot2a = gsn_csm_contour_map(wks, var0_2 , opts2)      ; create ascending plot
;    cplot2b = gsn_csm_vector(wks, var1_2, var2_2, vcres)
;    overlay(cplot2a,cplot2b)
  plot(2) = cplot2a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;

  opts3                            = res
  opts3@tiMainString               = "WRF (100km) - " + date

  cplot3a = gsn_csm_contour_map(wks, var0_3 , opts3)      ; create ascending plot
;    cplot3b = gsn_csm_vector(wks, var1_3, var2_3, vcres)
;    overlay(cplot3a,cplot3b)
  plot(3) = cplot3a                                         ; make panel section of this plot


;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF Surface Momentum Budget " + vartitle1 + " term - " +date

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

  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


;;;;;;;;;;;;;;;;;;;;;; END script
end
