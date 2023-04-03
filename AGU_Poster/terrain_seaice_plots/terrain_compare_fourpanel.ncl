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
name = "21FEB"
day = "2007-02-21"
hr = "07UTC"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set file names based on qs pass
if (hr.eq."07UTC") then
  fname1 = "wrf-" + day + "-07"
end if
if (hr .eq."22UTC") then
  fname1 = "wrf-" + day + "-22"
end if

; getting correct directories
    dir1 = "/data3/duvivier/NCAR/" + name + "/wrf_10km/"
    dir2 = "/data3/duvivier/NCAR/" + name + "/wrf_25km/"
    dir3 = "/data3/duvivier/NCAR/" + name + "/wrf_50km/"
    dir4 = "/data3/duvivier/NCAR/" + name + "/wrf_100km/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "terrain_seaice_compare_wrf_" + day + "_" +hr

; set up flux variables
    invar1 = "Z_sfc"
    invar2 = "SeaIce"
    invar3 = "LandMask"

; set contour plot levels
  ; for fluxes
    cmin1 =  0.
    cmax1 =  2500.
    clev1 =  100.
    stride1             = 4                 ; label stride
    plotlines1           = False             ; lines for reg plot
    cntype1              = "AreaFill"      ; type of fill for contours 
    spreadstart1        = 4                 ; start at color
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


  print("Running Terrain figs for wrf-" + day)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

; first wrf file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  var1_1  = f1->$invar1$(south_north|:,west_east|:)
  var2_1  = f1->$invar2$(time|0,south_north|:,west_east|:)
  var3_1  = f1->$invar3$(time|0,south_north|:,west_east|:)

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1
  var2_1@lat2d = lat2d_1
  var2_1@lon2d = lon2d_1

; second wrf file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var1_2  = f2->$invar1$(south_north|:,west_east|:)
  var2_2  = f2->$invar2$(time|0,south_north|:,west_east|:)
  var3_2  = f2->$invar3$(time|0,south_north|:,west_east|:)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2
  var2_2@lat2d = lat2d_2
  var2_2@lon2d = lon2d_2

; third wrf file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var1_3  = f3->$invar1$(south_north|:,west_east|:)
  var2_3  = f3->$invar2$(time|0,south_north|:,west_east|:)
  var3_3  = f3->$invar3$(time|0,south_north|:,west_east|:)
  
  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3
  var2_3@lat2d = lat2d_3
  var2_3@lon2d = lon2d_3

; fourth wrf file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->lat
  lon2d_4 = f4->lon
  var1_4  = f4->$invar1$(south_north|:,west_east|:)
  var2_4  = f4->$invar2$(time|0,south_north|:,west_east|:)
  var3_4  = f4->$invar3$(time|0,south_north|:,west_east|:)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4
  var2_4@lat2d = lat2d_4
  var2_4@lon2d = lon2d_4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Masking land below 10m
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Masking land for terrain plot based on LandMask 1=land")
  var1_1_masked = mask(var1_1, var3_1.eq.0, 0)
  copy_VarMeta(var1_1, var1_1_masked)

  var1_2_masked = mask(var1_2, var3_2.eq.0, 0)
  copy_VarMeta(var1_2, var1_2_masked)

  var1_3_masked = mask(var1_3, var3_3.eq.0, 0)
  copy_VarMeta(var1_3, var1_3_masked)

  var1_4_masked = mask(var1_4, var3_4.eq.0, 0)
  copy_VarMeta(var1_4, var1_4_masked)

  print("Masking land for SeaIce plot above 0.0001m.")
  var2_1_masked = mask(var2_1, var1_1.gt.0.0001, 0)
  copy_VarMeta(var2_1, var2_1_masked)

  var2_2_masked = mask(var2_2, var1_2.gt.0.0001, 0)
  copy_VarMeta(var2_2, var2_2_masked)

  var2_3_masked = mask(var2_3, var1_3.gt.0.0001, 0)
  copy_VarMeta(var2_3, var2_3_masked)

  var2_4_masked = mask(var2_4, var1_4.gt.0.0001, 0)
  copy_VarMeta(var2_4, var2_4_masked)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for "+day)

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
  ;iceres@lbLabelBarOn               = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = terres
  opts0@tiMainString               = "WRF(10km) "
 
  cplot0a = gsn_csm_contour_map_overlay(wks, var1_1_masked, var2_1_masked, opts0, iceres)

  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;

  opts1                            = terres
  opts1@tiMainString               = "WRF(25km)"

  cplot1a = gsn_csm_contour_map_overlay(wks, var1_2_masked, var2_2_masked, opts1, iceres)

  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;

  opts2                            = terres
  opts2@tiMainString               = "WRF(50km)"

  cplot2a = gsn_csm_contour_map_overlay(wks, var1_3_masked, var2_3_masked, opts2, iceres)

  plot(2) = cplot2a                                         ; make panel section of this plot 

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;

  opts3                            = terres
  opts3@tiMainString               = "WRF(100km)"

  cplot3a = gsn_csm_contour_map_overlay(wks, var1_4_masked, var2_4_masked, opts3, iceres)

  plot(3) = cplot3a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF Terrain height(m) and Sea Ice Fraction (1=ice)"

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
