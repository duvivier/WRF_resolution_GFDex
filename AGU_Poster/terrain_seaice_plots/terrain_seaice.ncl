;***************************************
; PROGRAM DESCRIPTION: This NCL script plots terrain from the geo_em files
; INPUT DATA: geo_em.d01 files for four WRF resolutions
; OUTPUT DATA: Terrain comparison for other
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
name = "21FEB"
day = "2007-02-21"
hr = "07UTC"
fname1 = "geo_em.d01.nc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set file names based on qs pass
if (hr.eq."07UTC") then
  fname2 = "wrf-" + day + "-07"
end if
if (hr .eq."22UTC") then
  fname2 = "wrf-" + day + "-22"
end if

; getting correct directories
    ; for terrain data (from geo_em file)
    dir1 = "/data3/duvivier/NCAR/21FEB/wrf_10km/"
    dir2 = "/data3/duvivier/NCAR/21FEB/wrf_25km/"
    dir3 = "/data3/duvivier/NCAR/21FEB/wrf_50km/"
    dir4 = "/data3/duvivier/NCAR/21FEB/wrf_100km/"

    ; for seaice data (by day/hour)
    dir11 = "/data3/duvivier/NCAR/" + name + "/wrf_10km/"
    dir22 = "/data3/duvivier/NCAR/" + name + "/wrf_25km/"
    dir33 = "/data3/duvivier/NCAR/" + name + "/wrf_50km/"
    dir44 = "/data3/duvivier/NCAR/" + name + "/wrf_100km/"


; set outdir and fout names
    outdir = "./"
    fout   = outdir + "terrain_seaice_compare_" + day

; set up flux variables
    invar1 = "HGT_M"
    invar2 = "LANDMASK"
    invar3 = "SeaIce"

; set contour plot levels
  ; for terrain
    cmin1 =  0.
    cmax1 =  2000.
    clev1 =  50.
    stride1             = 4                 ; label stride
    plotlines1           = False             ; lines for reg plot
    cntype1              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 3                 ; start at color
    spreadend1          = 68               ; end at color
    colormap            = "terrain.seaice.alice"

  ; for seaice
    cmin2 =  0.
    cmax2 =  1.
    clev2 =  0.2
    stride2             = 2                 ; label stride
    plotlines2           = False             ; lines for reg plot
    cntype2              = "AreaFill"
    spreadstart2        = 126                 ; start at color
    spreadend2          = 140                ; end at color


  print("Running Terrain figs for wrf")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

; first wrf file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_1 = f1->XLAT_M(Time|0,south_north|:,west_east|:)
  lon2d_1 = f1->XLONG_M(Time|0,south_north|:,west_east|:)
  var1_1  = f1->$invar1$(Time|0,south_north|:,west_east|:)  ; Height
  var2_1  = f1->$invar2$(Time|0,south_north|:,west_east|:)  ; LandMask

  f11 = addfile(dir11 + fname2 + ".nc","r")  ; Load first wrf file
  var3_1  = f11->$invar3$(time|0,south_north|:,west_east|:)

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1
  var3_1@lat2d = lat2d_1
  var3_1@lon2d = lon2d_1

; second wrf file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->XLAT_M(Time|0,south_north|:,west_east|:)
  lon2d_2 = f2->XLONG_M(Time|0,south_north|:,west_east|:)
  var1_2  = f2->$invar1$(Time|0, south_north|:,west_east|:)
  var2_2  = f2->$invar2$(Time|0,south_north|:,west_east|:)

  f22 = addfile(dir22 + fname2 + ".nc","r")  ; Load first wrf file
  var3_2  = f22->$invar3$(time|0,south_north|:,west_east|:)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2
  var3_2@lat2d = lat2d_2
  var3_2@lon2d = lon2d_2

; third wrf file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->XLAT_M(Time|0,south_north|:,west_east|:)
  lon2d_3 = f3->XLONG_M(Time|0,south_north|:,west_east|:)
  var1_3  = f3->$invar1$(Time|0, south_north|:,west_east|:)
  var2_3  = f3->$invar2$(Time|0,south_north|:,west_east|:)

  f33 = addfile(dir33 + fname2 + ".nc","r")  ; Load first wrf file
  var3_3  = f33->$invar3$(time|0,south_north|:,west_east|:)

  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3
  var3_3@lat2d = lat2d_3
  var3_3@lon2d = lon2d_3

; fourth wrf file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->XLAT_M(Time|0,south_north|:,west_east|:)
  lon2d_4 = f4->XLONG_M(Time|0,south_north|:,west_east|:)
  var1_4  = f4->$invar1$(Time|0, south_north|:,west_east|:)
  var2_4  = f4->$invar2$(Time|0,south_north|:,west_east|:)

  f44 = addfile(dir44 + fname2 + ".nc","r")  ; Load first wrf file
  var3_4  = f44->$invar3$(time|0,south_north|:,west_east|:)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4
  var3_4@lat2d = lat2d_4
  var3_4@lon2d = lon2d_4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Masking land below 10m
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Masking ocean for terrain plot based on geo_em LANDMASK 1=land")
  var1_1_masked = mask(var1_1, var2_1.eq.0, 0)
  copy_VarMeta(var1_1, var1_1_masked)

  var1_2_masked = mask(var1_2, var2_2.eq.0, 0)
  copy_VarMeta(var1_2, var1_2_masked)

  var1_3_masked = mask(var1_3, var2_3.eq.0, 0)
  copy_VarMeta(var1_3, var1_3_masked)

  var1_4_masked = mask(var1_4, var2_4.eq.0, 0)
  copy_VarMeta(var1_4, var1_4_masked)

  print("Masking land for seaice plot based on geo_em LANDMASK 0=sea")
  var3_1_masked = mask(var3_1, var2_1.eq.1, 0)
  copy_VarMeta(var3_1, var3_1_masked)

  var3_2_masked = mask(var3_2, var2_2.eq.1, 0)
  copy_VarMeta(var3_2, var3_2_masked)

  var3_3_masked = mask(var3_3, var2_3.eq.1, 0)
  copy_VarMeta(var3_3, var3_3_masked)

  var3_4_masked = mask(var3_4, var2_4.eq.1, 0)
  copy_VarMeta(var3_4, var3_4_masked)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for terrain and seaice ")

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")
  plot = new(4, graphic)

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

  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude
  res@mpMaxLatF                   = 70.              ; set the maximum latitude
  res@mpMinLonF                   = -54.0            ; set the minimum longitude
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5               ; Continent line thickness

  ; set contour resources for terrain
  terres                             = res
  
  terres@cnFillMode                  = cntype1
  terres@cnFillOn                    = True              ; turn on filled contours
  terres@gsnSpreadColors             = True              ; use full colormap
  terres@gsnSpreadColorStart         = spreadstart1      ; start at color specified 
  terres@gsnSpreadColorEnd           = spreadend1        ; end at color specified 
  terres@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  terres@cnMinLevelValF              = cmin1             ; set min contour level specified above
  terres@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  terres@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  terres@cnLinesOn                   = plotlines1        ; contour lines specified above
  terres@cnLineLabelsOn              = plotlines1        ; line labels on specified above
  terres@cnMissingValFillColor       = -1                ; missing value color
  terres@cnMissingValFillPattern     = 0                 ; fill in
  ;terres@tiMainFontHeightF           = 0.013
  terres@lbLabelBarOn                = False             ; turn off individual label bars

  ;set contour res for seaice
  iceres                            = True

  iceres@cnFillMode                 = cntype2
  iceres@cnFillOn                   = True              ; turn on filled contours
  iceres@gsnSpreadColors            = True              ; use full colormap
  iceres@gsnSpreadColorStart        = spreadstart2      ; start at color specified 
  iceres@gsnSpreadColorEnd          = spreadend2        ; end at color specified 
  iceres@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  iceres@cnMinLevelValF             = cmin2             ; set min contour level specified above
  iceres@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  iceres@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  iceres@cnLinesOn                  = plotlines2         ; contour lines specified above
  iceres@cnLineLabelsOn             = plotlines2         ; line labels on specified above
  iceres@cnMissingValFillColor      = -1          ; missing value color
  iceres@cnMissingValFillPattern    = 0                 ; fill in
  iceres@tiMainFontHeightF          = 0.013
  iceres@lbLabelBarOn               = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;
  opts0                            = terres
  opts0@tiMainString               = "WRF(10km) "
  cplot0a = gsn_csm_contour_map(wks,var1_1_masked, opts0)
  cplot0b = gsn_csm_contour(wks,var3_1_masked, iceres)
  overlay(cplot0a, cplot0b)
  
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;
  opts1                            = terres
  opts1@tiMainString               = "WRF(25km)"
  cplot1a = gsn_csm_contour_map(wks,var1_2_masked, opts1)
  cplot1b = gsn_csm_contour(wks,var3_2_masked, iceres)
  overlay(cplot1a, cplot1b)

  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;
  opts2                            = terres
  opts2@tiMainString               = "WRF(50km)"
  cplot2a = gsn_csm_contour_map(wks, var1_3_masked, opts2)
  cplot2b = gsn_csm_contour(wks,var3_3_masked, iceres)
  overlay(cplot2a, cplot2b)

  plot(2) = cplot2a                                         ; make panel section of this plot 

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;
  opts3                            = terres
  opts3@tiMainString               = "WRF(100km)"
  cplot3a = gsn_csm_contour_map(wks, var1_4_masked, opts3)
  cplot3b = gsn_csm_contour(wks,var3_4_masked, iceres)
  overlay(cplot3a, cplot3b)

  plot(3) = cplot3a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF terrain height (m)"

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
;  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
;  pnlres@pmLabelBarHeightF          = 0.075             ; set height of labelbar
;  pnlres@pmLabelBarWidthF           = 0.65




  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

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
