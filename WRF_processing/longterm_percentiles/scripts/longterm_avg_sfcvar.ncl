;***************************************
; PROGRAM DESCRIPTION: This NCL script plots average surface variable values
;                       from long term files from four WRF resolutions
; INPUT DATA: Four WRF output files at native resolution that are concatenated
;             monthly files
; OUTPUT DATA: Four panel plot of average at each resolution
; Note: This script is designed to find the average SURFACE VAR values
; CREATOR:  Alice DuVivier - February 2011
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

varcode = "LH"

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_longterm_avg"
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
 if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"
    vartype = "2d"
    cmaptype = "pressure"
    mask_500 = True
 end if
 if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2 m"
    invar1 = "T_2m"
    vartype = "2d"
    cmaptype = "temperature"
    mask_500 = True
 end if
 if (varcode.eq."PTsurf") then
    vartitle1 = "Potential Temperature at surface"
    invar1 = "T_sfc"
    vartype = "2d"
    cmaptype = "pottemperature"
    mask_500 = True
    convert_to_PT = True
 end if 
 if (varcode.eq."PTair") then
    vartitle1 = "Potential Temperature at lowest eta level"
    invar1 = "Th_e"
    vartype = "3d"
    cmaptype = "pottemperature"
    mask_500 = True
 end if
  if (varcode.eq."Q2m") then
    vartitle1 = "Mixing Ratio at 2 m"
    invar1 = "q_2m"
    vartype = "2d"
    cmaptype = "mix_rad"
  end if
  if (varcode.eq."ustar") then
    vartitle1 = "Friction Velocity"
    invar1 = "u_star"
    vartype = "2d"
    cmaptype = "u_star"
    met_not_avail = True  ; ustar data not in met
  end if
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
  if (varcode.eq."ice") then
    vartitle1 = "Sea Ice Fraction"
    invar1 = "SeaIce"
    vartype = "2d"
    cmaptype = "ice"
  end if



; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1 = 950
    cmax1 = 1050.
    clev1 = 5.
    stride1             = 4                 ; label stride
    plotlines           = True              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1 = -60.
    cmax1 = 20.
    clev1 = 4.
    stride1             = 4                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."pottemperature") then
    cmin1 = 250.
    cmax1 = 290.
    clev1 = 2.
    stride1             = 4                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1 =  0.
    cmax1  = 0.01
    clev1 =  0.002
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."u_star") then
    cmin1 =  0.
    cmax1 =  2.5
    clev1 =  .1
    stride1             = 4                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 254               ; end at color
    colormap            = "WhiteYellowOrangeRed"
  end if
  if (cmaptype.eq."shflux") then
    cmin1 =  -200.
    cmax1 =  200.
    clev1 =  25.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 255               ; end at color
    colormap            = "BlueYellowRed"
  end if
  if (cmaptype.eq."lhflux") then
    cmin1 =  -200.
    cmax1 =  200.
    clev1 =  25.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 255               ; end at color
    colormap            = "BlueYellowRed"
  end if
  if (cmaptype.eq."ice") then
    cmin1 =  0.
    cmax1 =  1.
    clev1 =  0.05
    stride1             = 2                 ; label stride
    plotlines           = False             ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 22                ; end at color
    colormap            = "seaice.alice"
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

  var2_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_tot(0:t_feb-1, :, :) = var2_feb
     var2_tot(t_feb:t_tot-1, :, :) = var2_mar

  var3_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_tot(0:t_feb-1, :, :) = var3_feb
     var3_tot(t_feb:t_tot-1, :, :) = var3_mar

  var4_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_tot(0:t_feb-1, :, :) = var4_feb
     var4_tot(t_feb:t_tot-1, :, :) = var4_mar

;;;;;;;;;;;;;
; Average over time dimension
;;;;;;;;;;;;
  ; time average and keep meta data
  var1_avg = dim_avg_n_Wrap(var1_tot, 0)
  var2_avg = dim_avg_n_Wrap(var2_tot, 0)
  var3_avg = dim_avg_n_Wrap(var3_tot, 0)
  var4_avg = dim_avg_n_Wrap(var4_tot, 0)


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
  flres@tiMainFontHeightF           = 0.013
  flres@lbLabelBarOn                = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = flres
  opts0@tiMainString               = "WRF(10km) "

  cplot0a = gsn_csm_contour_map(wks, var1_avg , opts0)      ; create contour plot
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;

  opts1                            = flres
  opts1@tiMainString               = "WRF(25km) "

  cplot1a = gsn_csm_contour_map(wks, var2_avg , opts1)      ; create contour plot
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;

  opts2                            = flres
  opts2@tiMainString               = "WRF(50km) "

  cplot2a = gsn_csm_contour_map(wks, var3_avg , opts2)      ; create contour plot
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;

  opts3                            = flres
  opts3@tiMainString               = "WRF(100km) "

  cplot3a = gsn_csm_contour_map(wks, var4_avg , opts3)      ; create contour plot
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;
    title_fin = "WRF average " + varcode + " for February and March, 2007"

  if (varcode.eq."SH") then
    delete(title_fin)
    title_fin = "WRF Average Sensible Heat Flux at Surface (+Upward) for February and March, 2007"
  end if
  if (varcode.eq."LH") then
    delete(title_fin)
    title_fin = "WRF Average Latent Heat Flux at Surface (+Upward) for February and March, 2007"
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




  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

;  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

;  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script

end


