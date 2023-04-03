
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
day = "2007-03-02-18"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set file names based on qs pass
fname1 = "met-" + day

; getting correct directories
    dir1 = "/data3/duvivier/NCAR/AGU/slp_plots/met_verify_02MAR/wrf_10km/met_post_processed/"
    dir2 = "/data3/duvivier/NCAR/AGU/slp_plots/met_verify_02MAR/wrf_25km/met_post_processed/"
    dir3 = "/data3/duvivier/NCAR/AGU/slp_plots/met_verify_02MAR/wrf_50km/met_post_processed/"
    dir4 = "/data3/duvivier/NCAR/AGU/slp_plots/met_verify_02MAR/wrf_100km/met_post_processed/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "slp_compare_met_" + day 

; set up flux variables
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"

; set contour plot levels
  ; for fluxes
    cmin1 =  950.
    cmax1 =  1050.
    clev1 =  5.
    stride1             = 4                 ; label stride
    plotlines1           = True             ; lines for reg plot
    cntype1              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74               ; end at color
    colormap            = "slp_anoms.dave"

  print("Running Flux figs for met-" + day)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in met files and variables
;;;;;;;;;;
  print("Loading met")

; first met file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  var1_1  = f1->$invar1$(time|0,south_north|:,west_east|:)

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1

; second met file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var1_2  = f2->$invar1$(time|0,south_north|:,west_east|:)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2

; third met file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var1_3  = f3->$invar1$(time|0,south_north|:,west_east|:)

  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3

; fourth met file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->lat
  lon2d_4 = f4->lon
  var1_4  = f4->$invar1$(time|0,south_north|:,west_east|:)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4

; mask land above 500m
  terr1 = f1->Z_sfc(:,:)
  var1_1_masked = mask(var1_1, terr1 .gt. 1000, 0)
  copy_VarMeta(var1_1, var1_1_masked)

  terr2 = f2->Z_sfc(:,:)
  var1_2_masked = mask(var1_2, terr2 .gt. 1000, 0)
  copy_VarMeta(var1_2, var1_2_masked)

  terr3 = f3->Z_sfc(:,:)
  var1_3_masked = mask(var1_3, terr3 .gt. 1000, 0)
  copy_VarMeta(var1_3, var1_3_masked)

  terr4 = f4->Z_sfc(:,:)
  var1_4_masked = mask(var1_4, terr4 .gt. 1000, 0)
  copy_VarMeta(var1_4, var1_4_masked)

  delete(var1_1)
  delete(var1_2)
  delete(var1_3)
  delete(var1_4)
  var1_1 = var1_1_masked
  var1_2 = var1_2_masked
  var1_3 = var1_3_masked
  var1_4 = var1_4_masked

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
  res@mpGeophysicalLineThicknessF = 1.5               ; Continent line thickness


  ; set contour resources for fluxes
  flres                             = res
  
  flres@cnFillMode                  = cntype1
  flres@cnFillOn                    = True              ; turn on filled contours
  flres@gsnSpreadColors             = True              ; use full colormap
  flres@gsnSpreadColorStart         = spreadstart1      ; start at color specified 
  flres@gsnSpreadColorEnd           = spreadend1        ; end at color specified 
  flres@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  flres@cnMinLevelValF              = cmin1             ; set min contour level specified above
  flres@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  flres@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  flres@cnLinesOn                   = plotlines1        ; contour lines specified above
  flres@cnLineLabelsOn              = plotlines1        ; line labels on specified above
  flres@cnMissingValFillColor       = "grey"          ; missing value color
  flres@cnMissingValFillPattern     = 0                 ; fill in
  flres@tiMainFontHeightF           = 0.013
  flres@lbLabelBarOn                = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - met 10km plot
;;;;;;;;;;;;;

  opts0                            = flres
  opts0@tiMainString               = "MET-ERAI(10km) "

  cplot0a = gsn_csm_contour_map(wks, var1_1 , opts0)      ; create ascending plot
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - met 25km plot
;;;;;;;;;;;;;

  opts1                            = flres
  opts1@tiMainString               = "MET-ERAI(25km) "

  cplot1a = gsn_csm_contour_map(wks, var1_2 , opts1)      ; create ascending plot
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - met 50km plot
;;;;;;;;;;;;;

  opts2                            = flres
  opts2@tiMainString               = "MET-ERAI(50km) "

  cplot2a = gsn_csm_contour_map(wks, var1_3 , opts2)      ; create ascending plot
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - met 100km plot
;;;;;;;;;;;;;

  opts3                            = flres
  opts3@tiMainString               = "MET-ERAI(100km) "

  cplot3a = gsn_csm_contour_map(wks, var1_4 , opts3)      ; create ascending plot
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "MET-ERAI " + vartitle1 + " (masked above 1000m) " + day

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
