;***************************************
; PROGRAM DESCRIPTION: This NCL script plots GHRSST sst on a day
; INPUT DATA: GHRSST data
; OUTPUT DATA: Plot of sst data for the day
; Note: No cshell is written to loop this. Inputs are specified manually below.
; CREATOR: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin

; MANUAL INPUTS
; set name of file you want:
dir1 = "/data3/duvivier/NCAR/GHRSST_data/"
date1 = "20070221_night"
; set if this is a zoomed plot or the whole domain
zoom = True

; BEGINNING OF SCRIPT 
; set outdir and fout names
outdir = "./"
fout   = outdir+"sst_"+date1

; load file:
 print("Loading sst data")

f1 = addfile(dir1 + date1 + ".nc", "r")
sst = f1->sea_surface_temperature(0,:,:)

lat = f1->lat
dim_lat = dimsizes(lat)
lon = f1->lon
dim_lon = dimsizes(lon)

; make lat and lon 2d arrays
lat2d = new((/dim_lat, dim_lon/), "float")
lon2d = new((/dim_lat, dim_lon/), "float")

do i = 0, dim_lon-1
  lat2d(:,i) = lat
end do

do j = 0, dim_lat-1
  lon2d(j,:) = lon
end do

; subset sst, lat, and lon for region of interest
sst_sub = sst(456:816, 2928:3864)
lat2d_sub = lat2d(456:816, 2928:3864)
lon2d_sub = lon2d(456:816, 2928:3864)


delete(sst)
delete(lat2d)
delete(lon2d)

; get correct sst data using scale value
sst = sst_sub * 0.01 
sst@units = "deg C"
; this is Celsius, to convert to Kelvin add 273.15

; assign lat and lon data
sst@lat2d = lat2d_sub
sst@lon2d = lon2d_sub

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  print("Now making sst plot.")

  ; set max and min values for plot
  cmin0 = -4.
  cmax0 = 12.
  clev0 = 1.
  stride              = 4                     ; label stride
  plotlines           = False                  ; lines for reg plot
  cntype              = "RasterFill"
  spreadstart0        = 10                 ; start at color- spatial
  spreadend0          = 65                ; end at color
  colormap = "temp64_anoms.dave"

  ; open workstation
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(1, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired

  ; set general domain resources
 ; res@gsnRightString              = ""
 ; res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set for Greenland
  res@mpCenterLatF                = 60.               ; -----set for Greenland

 if (isvar("zoom").and.(zoom))then
  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude
  res@mpMaxLatF                   = 70.              ; set the maximum latitude
  res@mpMinLonF                   = -54.0            ; set the minimum longitude
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude
 end if

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5               ; Make continents thinner

; set contour resources
  res@cnFillMode                  = cntype
  res@cnFillOn                    = True              ; turn on filled contours
  res@gsnSpreadColors             = True              ; use full colormap
  res@gsnSpreadColorStart         = spreadstart0      ; start at color specified 
  res@gsnSpreadColorEnd           = spreadend0        ; end at color specified 
  res@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF              = cmin0             ; set min contour level specified above
  res@cnMaxLevelValF              = cmax0             ; set max contour level specified above
  res@cnLevelSpacingF             = clev0             ; set contour spacing specified above
  res@cnLinesOn                   = plotlines         ; contour lines specified above
  res@cnLineLabelsOn              = plotlines         ; line labels on specified above
  res@cnMissingValFillColor       = "gray50"          ; missing value color
  res@cnMissingValFillPattern     = 0                 ; fill in
  res@tiMainFontHeightF           = 0.013
  res@lbLabelBarOn                = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - ascending pass
;;;;;;;;;;;;;

  opts0                            = res
  opts0@tiMainString               = " SST (deg C)"

  cplot0a = gsn_csm_contour_map(wks, sst , opts0)      ; create ascending plot
  plot(0) = cplot0a                                    ; make panel section

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "GHSST Satellite SST for  " + date1

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
  pnlres@lbLabelStride              = stride

  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot


  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script

end
