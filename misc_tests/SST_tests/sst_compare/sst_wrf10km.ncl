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
;name = "21FEB"
;day = "2007-02-21"
;hr = "07UTC"


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

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "sst_wrf10km_" + day + "_" +hr

; set up flux variables
    vartitle1 = "Sea Surface Temperature"
    invar1 = "SST"

; set contour plot levels
  ; for fluxes
    cmin1 =  -4.
    cmax1 =  12.
    ;cmin1 =  270.
    ;cmax1 =  285.
    clev1 =  1.
    stride1             = 4                 ; label stride
    plotlines1           = True             ; lines for reg plot
    cntype1              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 10                 ; start at color
    spreadend1          = 65               ; end at color
    colormap            = "temp64_anoms.dave"

  print("Running Flux figs for wrf-" + day)
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
  var1_1  = f1->$invar1$(time|0,south_north|:,west_east|:)

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1

; mask land above 10m
  terr1 = f1->Z_sfc(:,:)
  var1_1_masked = mask(var1_1, terr1 .gt. 10., 0)
  copy_VarMeta(var1_1, var1_1_masked)

  delete(var1_1)
  var1_1 = var1_1_masked


; Convert K to Celsius
  var1_1 = var1_1 - 273.15

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for "+day)

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")
  plot = new(1, graphic)

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
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = flres
  opts0@tiMainString               = "WRF(10km) "

  cplot0a = gsn_csm_contour_map(wks, var1_1 , opts0)      ; create ascending plot
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF " + vartitle1 + "  " + day + "- "+ hr

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
