;***************************************
; PROGRAM DESCRIPTION: This NCL script plots WRF and MODIS sst
; INPUT DATA: MODIS 8 day composite .hdf files 
;             and WRF output file at any resolution,
;             text files (run using cress_regrid_wrf-to-quikscat.ncl) of 
;             weights and indicies to regridding WRF
; OUTPUT DATA: Panel plot of MODIS and WRF sst and difference
; CREATOR: Alice DuVivier - November 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - FOR TESTING THE SCRIPT
; set incoming directory information
dir1 = "/data3/duvivier/NCAR/06MAR/wrf_10km/"
dir2 = "/data3/duvivier/NCAR/MODIS_data/composite_8d/"
date1 = "2007-03-06"
date2 = "2007-03-06_2007-03-13"

fname1 = "wrf-" + date1 + "-07"
fname2 = "MODIS_SST_" + date2 + "_smi"
title1 = "WRF_10"
title2 = "MODIS"


; BEGIN SCRIPT

; set necessary file input names using input variables
  ind_in = "/data3/duvivier/NCAR/MODIS_data/indicies_"+title1+"_to_"+title2
  wgt_in = "/data3/duvivier/NCAR/MODIS_data/weights_"+title1+"_to_"+title2

; set outdir and fout names
outdir = "./"
fout  = outdir + title1+"_to_"+title2+"_"+date1+"_composite8d"
title1 = str_sub_str(title1,"_"," ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Loading "+title1+" and "+title2)
;;;;;;;;;;
; load in wrf file and data
;;;;;;;;;;

  f1 = addfile(dir1 + fname1 + ".nc","r")
  wrf_sst_2d = f1->SST(time|0,south_north|:,west_east|:)
  ; convert to deg C
  wrf_sst_2d = wrf_sst_2d - 273.15

;;;;;;;;;;
; load in MODIS data
;;;;;;;;;;

  f2 = addfile(dir2 + fname2 + ".hdf","r")  ; Load first wrf file
  var_tmp = f2->l3m_data
;  var1@_FillValue = 65535  ; specified from file
  slope = var_tmp@Slope
  int   = var_tmp@Intercept
  
  ; calculate sst from equation given in metadata
  mod_sst = (slope * var_tmp) + int
  mod_sst@units = "deg C"
  delete(var_tmp)

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
  mod_sst_sub = mod_sst(228:408, 1464:1930)
  lat2d_sub = lat2d(228:408, 1464:1930)
  lon2d_sub = lon2d(228:408, 1464:1930)

  delete(mod_sst)
  delete(lat2d)
  delete(lon2d)

  mod_sst_2d = mod_sst_sub
  mod_sst_2d@_FillValue = 9.96921e+36
  mod_sst_2d = where(mod_sst_2d .lt. 30, mod_sst_2d, mod_sst_2d@_FillValue)

  ; assign metadata
  mod_sst_2d@lat2d = lat2d_sub
  mod_sst_2d@lon2d = lon2d_sub
  mod_sst_2d@units = "deg C"

  ; calculate dimensions
  dims_2 = dimsizes(lat2d_sub)    ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we             ; get total number of points in high res domain
  nlat = n_sn                   ; used in plots
  nlon = n_we                   ; used in plots

;;;;;;;;;;
; load in weight and index arrays
;;;;;;;;;;

  print("Loading weight and index arrays")

; create weights and appropriate indicies for Cressman interpolation
  max_indicies = 5                              ; maximum number of points for weighted avg

; load in arrays of indicies and weights
  ncol = 1   ; number of columns
  header = 0 ; number of header lines

  inds_in = readAsciiTable(ind_in+".txt",ncol,"integer",header)  ; read in ascii as float to get statistics
  wgts_in = readAsciiTable(wgt_in+".txt",ncol,"float",header)  ; read in ascii as float to get statistics

  interp_ind = onedtond(inds_in,(/n_tot,max_indicies/))
  interp_ind!0 = title2+"_index"                      ; name the dimensions of the array
  interp_ind!1 = title1+"_indicies"  
  
  interp_wgt = onedtond(wgts_in,(/n_tot,max_indicies/))
  interp_wgt!0 = title2+"_index"
  interp_wgt!1 = title1+"_weightings"

;;;;;;;;;;
; interpolate the variable
;;;;;;;;;; 
  print("Interpolating "+title1+" to  "+title2)

  mod_sst_1d = ndtooned(mod_sst_2d)

  wrf_sst_1d = ndtooned(wrf_sst_2d)        ; convert data from wrf to 1D array

  wrf_sst_1d_new = new(dimsizes(mod_sst_1d),"float")

  wrf_sst_2d_new = new(dimsizes(mod_sst_2d),"float")

; Do loop to calculate indicies and weights
  do i = 0, n_tot-1

    indicies = interp_ind(i,:)
    num_ind      = num(.not.ismissing(indicies))
    
    weights = interp_wgt(i,:)
    num_wgt      = num(.not.ismissing(weights))
      if(num_ind.ne.num_wgt) then
        print("Loaded different numbers of weight and indicies!")
        exit
      end if
    inds = indicies(0:num_ind-1)
    wgt  = weights(0:num_wgt-1)
    
    wrf_sst_1d_new(i) = sum(wrf_sst_1d(inds)*wgt)/sum(wgt)

    delete(inds)
    delete(wgt)

    ; Counter
    if(i%1000.eq.0) then
      print("interpolated "+i+" of "+n_tot)
    end if

  end do

  wrf_sst_2d_new = onedtond(wrf_sst_1d_new,(/nlat,nlon/))
  copy_VarMeta(mod_sst_2d,wrf_sst_2d_new)

;;;;;;;;;;
; manipulate data
;;;;;;;;;; 

  ; mask data where MODIS doesn't have data
  wrf_sst_masked = mask(wrf_sst_2d_new, mod_sst_2d .eq. mod_sst_2d@_FillValue, False)
    delete(wrf_sst_2d)
  wrf_sst_2d = wrf_sst_masked
  copy_VarMeta(mod_sst_2d, wrf_sst_2d)

  ; Find difference between data
  diff = wrf_sst_2d - mod_sst_2d
  copy_VarMeta(mod_sst_2d, diff)
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Set plot information
;;;;;;;;;;;;
    cmin1 = -4.
    cmax1 = 12.
    clev1 = 1.
    cmin2 = -5.
    cmax2 = 5.
    clev2 = 1.
    clevd = clev1
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 10                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 107 
    colormap            = "temp64_anoms.dave"


  print("Processing four panel graphs for "+date1)

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(4, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
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
  res@mpMaxLatF                   = 68.              ; set the maximum latitude 
  res@mpMinLonF                   = -55.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -18.0            ; set the maximum longitude 

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
  
;;;;;;;;;;;;;
; Plot 1 - overlay contours
;;;;;;;;;;;;;

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@cnLineColor                = "red"
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level. designated above for each variable of interest
  opts@cnMaxLevelValF             = cmax1             ; set max contour level. designated above
  opts@cnLevelSpacingF            = clevd           ; set contour spacing. designated above
  opts@tiMainString               = title1 + " " + title2            ; set title for plot. designated above as both input names
  opts@tiMainFontHeightF          = 0.013
  opts@cnInfoLabelOn              = False
  opts@cnLineLabelFontColor       = opts@cnLineColor  ; set the contour labels to be the same as the contour line color
  opts@cnLineLabelBackgroundColor = "Transparent"     ; set the background behind contour labels to be transparent

; Plot 1 (overlay)
  opts2                            = opts             ; set options for the second contour set to be the same
  opts2@cnLineColor                = "blue"           ; specify second contour to be diff. color
  opts2@cnLineLabelFontColor       = opts2@cnLineColor
  opts2@gsnRightString             = ""

; reset and deletion options to prevent overwrites and warnings for overlay:
  delete(opts2@tiMainString)
  delete(opts2@mpProjection)
  delete(opts2@mpLimitMode)
  delete(opts2@mpCenterLonF)
  delete(opts2@mpCenterLatF)
  delete(opts2@mpGridAndLimbOn)
  delete(opts2@mpFillOn)
  delete(opts2@mpGridLineDashPattern)
  delete(opts2@mpGeophysicalLineColor)
  delete(opts2@mpGeophysicalLineThicknessF)
  delete(opts2@mpMaxLonF)
  delete(opts2@mpMinLonF)
  delete(opts2@mpMaxLatF)
  delete(opts2@mpMinLatF)

  cplot1 = gsn_csm_contour_map(wks,wrf_sst_2d,opts)  ; create plot of first contours
  cplot1b = gsn_csm_contour(wks,mod_sst_2d,opts2)    ; create plot of second contours
  overlay(cplot1,cplot1b)                       ; overlay contour 2 on contour 1. overlay plot wil have title cplot1
  plot(0) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(opts2)

; legend resources- for plot 1 overlay
  lgres                    = True
  lgres@lgLineColors       = (/"red","blue"/)   ; make the colors for the legend
  lgres@lgMonoDashIndex    = True               ; sets both contour lines to same dash type
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  lgres@vpWidthF           = 0.30               ; width of legend (NDC)
  lgres@vpHeightF          = 0.05               ; height of legend (NDC)
  lgres@lgLineDashSegLenF  = 0.01
  lgres@lgLabelFontHeightF = 0.03
  lgres@lgLineLabelStrings = (/"", ""/)         ; take of any automatic line labels
  lbid = gsn_create_legend(wks,2,(/title1, title2/),lgres)         ; create legend

; annotate first plot by adding legend
  amres                    = True
  amres@amParallelPosF     = 0.25	        ; move legend to the right
  amres@amOrthogonalPosF   = 0.60               ; move the legend down
  annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

;;;;;;;;;;;;;
; Plot 2 - fname1
;;;;;;;;;;;;;

  opts                            = res               ; reset options
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnLinesOn                  = plotlines         ; contour lines specified above
  opts@cnLineLabelsOn             = plotlines         ; line labels on specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = title1+ " " + date1              ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  
  
  cplot2 = gsn_csm_contour_map(wks, wrf_sst_2d, opts)      ; create second plot
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;

; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2 + " " + date2           ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, mod_sst_2d, opts)      ; create fourth plot
  plot(3) = cplot4                              ; make panel section of this plot
  delete(opts)


;;;;;;;;;;;;;
; Plot 3 - difference 
;;;;;;;;;;;;; 
  title3 = title1 + "-" + title2

  opts                            = res
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = title3            ; set title for difference plot (title2-title1)
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  plot(2) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = date1+" SST: "+title1+" and "+title2  

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot
  
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(lgres)
  delete(res)
  delete(pnlres)
  delete(diff)
  delete(opts)


;;;;;;;;;;;;;;;;;;;;;; END script
end
