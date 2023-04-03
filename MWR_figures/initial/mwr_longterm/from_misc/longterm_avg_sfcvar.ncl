;***************************************
; PROGRAM DESCRIPTION: This NCL script plots averages from long term files
;                      from four WRF resolutions
; INPUT DATA: Four WRF output files at native resolution that are concatenated
;             monthly files
; OUTPUT DATA: Four panel plot of average at each resolution
; Note: This can be looped with 01_wrffourpanel_akd_hourly.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Matt Higgins
;          Modified by Alice DuVivier - February 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
;for testing purposes
dir1 = "/ptmp/duvivier/FEBMAR/wrf_10km/wrf_cont/catted/"
dir2 = "/ptmp/duvivier/FEBMAR/wrf_25km/wrf_cont/catted/"
dir3 = "/ptmp/duvivier/FEBMAR/wrf_50km/wrf_cont/catted/"
dir4 = "/ptmp/duvivier/FEBMAR/wrf_100km/wrf_cont/catted/"

fname1 = "wrf-200701-cat"
fname2 = "wrf-200702-cat"
fname3 = "wrf-200703-cat"

varcode = "SH"

; set outdir and fout names
outdir = "./"
fout   = outdir+"mwr_"+varcode+"_longterm_avg_scale2"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

  print("Running longterm avg at all resolutions")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
  precip_add = False ; normal by default averaging
; Which variables need to be loaded?
  if (varcode.eq."SH") then
    vartitle1 = "Sensible Heat Flux at Sur"
    invar1 = "SHFlx"
    vartype = "2d"
    cmaptype = "shflux"
    met_not_avail = True  ; SH data not in met
  end if
  if (varcode.eq."LH") then
    vartitle1 = "Latent Heat Flux at Sur"
    invar1 = "LHFlx"
    vartype = "2d"
    cmaptype = "lhflux"
    met_not_avail = True  ; LH data not in met
  end if

; Set the contour interval for each input variable   
  if (cmaptype.eq."shflux") then
;    cmin1 =  -400.
;    cmax1 =  400.
;    clev1 =  50.
    cmin1 =  -600.
    cmax1 =  600.
    clev1 =  50.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 255               ; end at color
    colormap            = "BlueYellowRed"
  end if
  if (cmaptype.eq."lhflux") then
;    cmin1 =  -400.
;    cmax1 =  400.
;    clev1 =  50.
    cmin1 =  -600.
    cmax1 =  600.
    clev1 =  50.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 255               ; end at color
    colormap            = "BlueYellowRed"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

;; first wrf file
  f1_feb = addfile(dir1 + fname2 + ".nc","r")  ; Load first wrf file
  f1_mar = addfile(dir1 + fname3 + ".nc","r")  ; Load first wrf file
  var1_feb  = f1_feb->$invar1$(time|:,south_north|:,west_east|:)
  var1_mar  = f1_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_1 = f1_feb->lat
  lon2d_1 = f1_feb->lon
  var1_feb@lat2d = lat2d_1
  var1_feb@lon2d = lon2d_1
  dims1 = dimsizes(lat2d_1)
  nlat_1 = dims1(0)
  nlon_1 = dims1(1)

  ; land mask data for values
  f1_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.10km.nc", "r")
  land1 = f1_geo->LANDMASK(Time|0,south_north|:,west_east|:)


; second wrf file
  f2_feb = addfile(dir2 + fname2 + ".nc","r")  ; Load first wrf file
  f2_mar = addfile(dir2 + fname3 + ".nc","r")  ; Load first wrf file
  var2_feb  = f2_feb->$invar1$(time|:,south_north|:,west_east|:)
  var2_mar  = f2_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_2 = f2_feb->lat
  lon2d_2 = f2_feb->lon
  var2_feb@lat2d = lat2d_2
  var2_feb@lon2d = lon2d_2
  dims2 = dimsizes(lat2d_2)
  nlat_2 = dims2(0)
  nlon_2 = dims2(1)

  ; land mask data for values
  f2_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.25km.nc", "r")
  land2 = f2_geo->LANDMASK(Time|0,south_north|:,west_east|:)


; third wrf file
  f3_feb = addfile(dir3 + fname2 + ".nc","r")  ; Load first wrf file
  f3_mar = addfile(dir3 + fname3 + ".nc","r")  ; Load first wrf file
  var3_feb  = f3_feb->$invar1$(time|:,south_north|:,west_east|:)
  var3_mar  = f3_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_3 = f3_feb->lat
  lon2d_3 = f3_feb->lon
  var3_feb@lat2d = lat2d_3
  var3_feb@lon2d = lon2d_3
  dims3 = dimsizes(lat2d_3)
  nlat_3 = dims3(0)
  nlon_3 = dims3(1)

  ; land mask data for values
  f3_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.50km.nc", "r")
  land3 = f3_geo->LANDMASK(Time|0,south_north|:,west_east|:)


; fourth wrf file
  f4_feb = addfile(dir4 + fname2 + ".nc","r")  ; Load first wrf file
  f4_mar = addfile(dir4 + fname3 + ".nc","r")  ; Load first wrf file
  var4_feb  = f4_feb->$invar1$(time|:,south_north|:,west_east|:)
  var4_mar  = f4_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_4 = f4_feb->lat
  lon2d_4 = f4_feb->lon
  var4_feb@lat2d = lat2d_4
  var4_feb@lon2d = lon2d_4
  dims4 = dimsizes(lat2d_4)
  nlat_4 = dims4(0)
  nlon_4 = dims4(1)

  ; land mask data for values
  f4_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.100km.nc", "r")
  land4 = f4_geo->LANDMASK(Time|0,south_north|:,west_east|:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Performing data processing: concatenating, averaging")

;;;;;;;;;;;;;
; Make arrays for full data sets with both feb and mar
;;;;;;;;;;;;
  ; get time dimensions for february and march
  dim_feb = dimsizes(var4_feb)
  t_feb = dim_feb(0)
  dim_mar = dimsizes(var4_mar)
  t_mar = dim_mar(0)
  t_tot = t_feb + t_mar

  ; make new arrays and fill them with old data
  var1_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_tot(0:t_feb-1, :, :) = var1_feb
     var1_tot(t_feb:t_tot-1, :, :) = var1_mar
  delete(var1_feb)
  delete(var1_mar)

  var2_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_tot(0:t_feb-1, :, :) = var2_feb
     var2_tot(t_feb:t_tot-1, :, :) = var2_mar
  delete(var2_feb)
  delete(var2_mar)

  var3_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_tot(0:t_feb-1, :, :) = var3_feb
     var3_tot(t_feb:t_tot-1, :, :) = var3_mar
  delete(var3_feb)
  delete(var3_mar)

  var4_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_tot(0:t_feb-1, :, :) = var4_feb
     var4_tot(t_feb:t_tot-1, :, :) = var4_mar
  delete(var4_feb)
  delete(var4_mar)

;;;;;;;;;;;;;
; Average over time dimension
;;;;;;;;;;;;
  ; time average and keep meta data
  var1_avg = dim_avg_n_Wrap(var1_tot, 0)
  var2_avg = dim_avg_n_Wrap(var2_tot, 0)
  var3_avg = dim_avg_n_Wrap(var3_tot, 0)
  var4_avg = dim_avg_n_Wrap(var4_tot, 0)

  delete(var1_tot)
  delete(var2_tot)
  delete(var3_tot)
  delete(var4_tot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Create text file of subset data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Subset data by lat/lon
;;;;;;;;;;;;
  print("Subsetting data of interest")
  fill = var1_avg@_FillValue

; subset data where 56<lat<70 and -54<lon<-20
; for true values, make the subset array the value from the average, for false values make it the fill value so it won't go into summed values

  ; file 1
  var1_sub = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., var1_avg, fill)
  var1_sub@_FillValue = fill

  ; file 2
  var2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., var2_avg, fill)
  var2_sub@_FillValue = fill

  ; file 3
  var3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., var3_avg, fill)
  var3_sub@_FillValue = fill

  ; file 4
  var4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., var4_avg, fill)
  var4_sub@_FillValue = fill

;;;;;;;;;;;;;
; Mask out land points
;;;;;;;;;;;;
  print("Masking land points for fluxes")
  ; can use False or 0 as last argument to set it to a fill value

  var1_masked = mask(var1_sub, land1 .eq. 1, False)
  var2_masked = mask(var2_sub, land2 .eq. 1, False)
  var3_masked = mask(var3_sub, land3 .eq. 1, False)
  var4_masked = mask(var4_sub, land4 .eq. 1, False)

;;;;;;;;;;;;;
; Write to a text file
;;;;;;;;;;;;
; THIS IS NOT AT ALL EFFICIENT, BUT WAS EASIEST FOR NOW

head = "Average Table values for " + varcode + " February and March 2007"

a1 = "WRF10 max " + varcode + ": " + max(var1_masked) + " and avg: " + avg(var1_masked) + "  [W/m2]"
output1 = array_append_record(head, a1, 0)

a2 = "WRF25 max " + varcode + ": " + max(var2_masked) + " and avg: " + avg(var2_masked) + "  [W/m2]"
output2 = array_append_record(output1, a2, 0)

a3 = "WRF50 max " + varcode + ": " + max(var3_masked) + " and avg: " + avg(var3_masked) + "  [W/m2]"
output3 = array_append_record(output2, a3, 0)

a4 = "WRF100 max " + varcode + ": " + max(var4_masked) + " and avg: " + avg(var4_masked) + "  [W/m2]"
output4 = array_append_record(output3, a4, 0)

asciiwrite(fout + ".txt", output4)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; plot averages only
  print("Processing monthly average graphs for " + varcode)

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
  
  flres@cnFillMode                  = cntype
  flres@cnFillOn                    = True              ; turn on filled contours
  flres@gsnSpreadColors             = True              ; use full colormap
  flres@gsnSpreadColorStart         = spreadstart1      ; start at color specified 
  flres@gsnSpreadColorEnd           = spreadend1        ; end at color specified 
  flres@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  flres@cnMinLevelValF              = cmin1             ; set min contour level specified above
  flres@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  flres@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  flres@cnLinesOn                   = plotlines        ; contour lines specified above
  flres@cnLineLabelsOn              = plotlines        ; line labels on specified above
  flres@cnMissingValFillColor       = "grey"          ; missing value color
  flres@cnMissingValFillPattern     = 0                 ; fill in
  flres@tiMainFontHeightF           = 0.017
  flres@lbLabelBarOn                = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = flres
  opts0@tiMainString               = "WRF (10km) - February and March, 2007 "

  cplot0a = gsn_csm_contour_map(wks, var1_avg , opts0)      ; create contour plot
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;

  opts1                            = flres
  opts1@tiMainString               = "WRF (25km) - February and March, 2007 "

  cplot1a = gsn_csm_contour_map(wks, var2_avg , opts1)      ; create contour plot
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;

  opts2                            = flres
  opts2@tiMainString               = "WRF (50km) - February and March, 2007 "

  cplot2a = gsn_csm_contour_map(wks, var3_avg , opts2)      ; create contour plot
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;

  opts3                            = flres
  opts3@tiMainString               = "WRF (100km) - February and March, 2007 "

  cplot3a = gsn_csm_contour_map(wks, var4_avg , opts3)      ; create contour plot
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;
    title_fin = "WRF average " + varcode + " for February and March, 2007"

  if (varcode.eq."SH") then
    delete(title_fin)
    title_fin = "WRF Sensible Heat Flux at Surface (+Upward) - average values"
  end if
  if (varcode.eq."LH") then
    delete(title_fin)
    title_fin = "WRF Latent Heat Flux at Surface (+Upward) - average values"
  end if

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




  gsn_panel(wks,(/plot/),(/1,4/),pnlres)               ; create final panel plot

;  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

;  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script

end


