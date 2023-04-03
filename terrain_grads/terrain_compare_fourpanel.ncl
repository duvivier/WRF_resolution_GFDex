;***************************************
; PROGRAM DESCRIPTION: This NCL script "final version" plots WRF fluxes
; INPUT DATA: WRF output at 4 resolutions
; OUTPUT DATA: Panel plot WRF surface flux data at native resolutions
; Note: These plots are zoomed and at each data set's native resolution
; CREATOR: Alice DuVivier - March 2012
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
varcode = "hgt"

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
    dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_10km/"
    dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_25km/"
    dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_50km/"
    dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_100km/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + varcode + "_compare_wrf_" + day + "_" +hr

; set up flux variables
  if (varcode.eq."hgt") then
    vartitle1 = "Terrain height"
    invar1 = "Z_sfc"
  end if

; set contour plot levels
  ; for fluxes
    cmin1 =  0.
    cmax1 =  4000.
    clev1 =  50.
    stride1             = 10                 ; label stride
    plotlines1           = False             ; lines for reg plot
    cntype1              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 3                 ; start at color
    spreadend1          = 68               ; end at color
    colormap            = "terrain.alice"

  print("Running terrain figs for wrf-" + day)
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

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1

; second wrf file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var1_2  = f2->$invar1$(south_north|:,west_east|:)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2

; third wrf file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var1_3  = f3->$invar1$(south_north|:,west_east|:)

  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3

; fourth wrf file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->lat
  lon2d_4 = f4->lon
  var1_4  = f4->$invar1$(south_north|:,west_east|:)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4

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
  flres@tiMainFontHeightF           = 0.017
  flres@lbLabelBarOn                = False             ; turn off individual label bars

  ; polyres for markers
  gridpolyres               = True
  
  gridpolyres@gsMarkerIndex = 1
  gridpolyres@gsMarkerSizeF = 0.010
  gridpolyres@gsMarkerColor = "black"

  ; res for the polylines
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
  st_lat0 = 69.056
  st_lon0 = -36.7935
  ed_lat0 = 65.94
  ed_lon0 = -30.0
; set line res to show cross section line
  lnres                            = True
   lnres@gsLineThicknessF          = 2.5
   lnres@gsLineColor               = "black"


;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = flres
  opts0@tiMainString               = "WRF (10km) - "+ day + " " + hr

  cplot0a = gsn_csm_contour_map(wks, var1_1 , opts0)      ; create ascending plot
  dum0 = gsn_add_polymarker(wks,cplot0a,lon2d_1(192,170),lat2d_1(192,170),gridpolyres)
  dum0a = gsn_add_polyline(wks,cplot0a,(/st_lon0,ed_lon0/), (/st_lat0, ed_lat0/), lnres)

  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;

  opts1                            = flres
  opts1@tiMainString               = "WRF (25km) - "+ day + " " + hr

  cplot1a = gsn_csm_contour_map(wks, var1_2 , opts1)      ; create ascending plot
  dum1 = gsn_add_polymarker(wks,cplot1a,lon2d_2(77,67),lat2d_2(77,67),gridpolyres)  
  dum1a = gsn_add_polyline(wks,cplot1a,(/st_lon0,ed_lon0/), (/st_lat0, ed_lat0/), lnres)

  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;

  opts2                            = flres
  opts2@tiMainString               = "WRF (50km) - "+ day + " " + hr

  cplot2a = gsn_csm_contour_map(wks, var1_3 , opts2)      ; create ascending plot
  dum2 = gsn_add_polymarker(wks,cplot2a,lon2d_3(39,33),lat2d_3(39,33),gridpolyres)
  dum2a = gsn_add_polyline(wks,cplot2a,(/st_lon0,ed_lon0/), (/st_lat0, ed_lat0/), lnres)
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;

  opts3                            = flres
  opts3@tiMainString               = "WRF (100km) - " + day + " " + hr

  cplot3a = gsn_csm_contour_map(wks, var1_4 , opts3)      ; create ascending plot
  dum3 = gsn_add_polymarker(wks,cplot3a,lon2d_4(19,16),lat2d_4(19,16),gridpolyres)
  dum3a = gsn_add_polyline(wks,cplot3a,(/st_lon0,ed_lon0/), (/st_lat0, ed_lat0/), lnres)
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF " + vartitle1 + " (+Upward)"

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
