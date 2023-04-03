;***************************************
; PROGRAM DESCRIPTION: This NCL script plots MODIS sst
; INPUT DATA: MODIS 8 day composite .hdf files 
; OUTPUT DATA: Plot of MODIS sst
; CREATOR: Alice DuVivier - November 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
  date = "2007-03-06_2007-03-13"
  zoom = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; getting correct directories
    dir1 = "/data3/duvivier/NCAR/MODIS_data/composite_8d/"
    fname1 = "MODIS_SST_" + date + "_smi"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "sst_modis_" + date

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

; first wrf file
  f1 = addfile(dir1 + fname1 + ".hdf","r")  ; Load first wrf file
  var1 = f1->l3m_data
;  var1@_FillValue = 65535  ; specified from file
  slope = var1@Slope
  int   = var1@Intercept
  
  ; calculate sst from equation given in metadata
  sst = (slope * var1) + int
  sst@units = "deg C"

  ; make lat and lon arrays
  ; Northernmost lat = 90 ; Southernmost lat = -90
  ; Westernomost lon = -180; Easternmost lon = 180
  ; Step (for each) = 0.08333334
  dim_lat = 2160         ; total lats = 2160
  dim_lon = 4320         ; total lons = 4320

  lat = fspan(90, -90, dim_lat)
  lon = fspan(-180, 180, dim_lon)

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
  sst_sub = sst(228:408, 1464:1930)
  lat2d_sub = lat2d(228:408, 1464:1930)
  lon2d_sub = lon2d(228:408, 1464:1930)

  delete(sst)
  delete(lat2d)
  delete(lon2d)

  sst = sst_sub
  sst@_FillValue = 9.96921e+36
  sst = where(sst .lt. 30, sst, sst@_FillValue)

  ; assign metadata
  sst@lat2d = lat2d_sub
  sst@lon2d = lon2d_sub
  sst@units = "deg C"

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
  res@mpMaxLatF                   = 67.              ; set the maximum latitude
  res@mpMinLonF                   = -57.0            ; set the minimum longitude
  res@mpMaxLonF                   = -30.0            ; set the maximum longitude
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
  opts0@tiMainString               = "SST (deg C)"

  cplot0a = gsn_csm_contour_map(wks, sst , opts0)      ; create ascending plot
  plot(0) = cplot0a                                    ; make panel section

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "MODIS Satellite SST (4microns- night) 8 day composite  " + date

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
