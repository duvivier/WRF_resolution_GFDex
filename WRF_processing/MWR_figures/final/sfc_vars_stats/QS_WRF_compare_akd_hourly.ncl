;***************************************
; PROGRAM DESCRIPTION: This NCL script plots quikscat and WRF winds
; INPUT DATA: Quikscat text files, from Matlab,
;             WRF output file at any resolution,
;             text files (run using cress_regrid_wrf-to-quikscat.ncl) of 
;             weights and indicies to regridding WRF
; OUTPUT DATA: Zoomed panel plot of quikscat winds, WRF winds, and difference,
;              text files of statistics between QS and WRF
; Note: This is looped with cshell script 06_Quikscat.csh
; CREATOR: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - FOR TESTING THE SCRIPT
; set incoming directory information
;dir1 = "/data3/duvivier/NCAR/21FEB/wrf_10km/"
;dir2 = "/data3/duvivier/NCAR/Quikscat/21FEB/"
;fname1 = "wrf-2007-02-21-22"
;fname2 = "Quikscat_"
;title1 = "WRF_10"
;title2 = "Quikscat"
;date1 = "2007-02-21-22"
;pass = "asc"


; BEGIN SCRIPT
; want vectors on plots or no?
vectors = True

; set necessary file input names using input variables
  ind_in = "/data3/duvivier/NCAR/Quikscat/txt_files_regridding/indicies_"+title1+"_to_"+title2
  wgt_in = "/data3/duvivier/NCAR/Quikscat/txt_files_regridding/weights_"+title1+"_to_"+title2

  lat = dir2 + fname2 + "lat2d.txt"
  lon = dir2 + fname2 + "lon2d.txt"
  invar_a = dir2 + fname2 + pass + "_u.txt"
  invar_b = dir2 + fname2 + pass + "_v.txt"
  invar_c = dir2 + fname2 + pass + "_mask.txt"
  invar_d = dir2 + fname2 + pass + "_time.txt"

; set outdir and fout names
outdir = "./"
fout_plots  = outdir + title1+"_to_"+title2+"_"+date1
fout_stats  = outdir + title1+"_to_"+title2+"_"+date1+"_stats"
title1 = str_sub_str(title1,"_"," ")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Loading "+title1+" and "+title2)
;;;;;;;;;;
; load in wrf file and data
;;;;;;;;;;

  f1 = addfile(dir1 + fname1 + ".nc","r")
  wrf_u_2d = f1->u_10m_tr(time|0,south_north|:,west_east|:)
  wrf_v_2d = f1->v_10m_tr(time|0,south_north|:,west_east|:)

  wrf_speed_2d = sqrt(wrf_u_2d^2 + wrf_v_2d^2)

;;;;;;;;;;
; load in Quikscat data
;;;;;;;;;;
  header = 0
  ;ncol = 110   ; specified from Matlab data
  ncol = 170
  
  qs_u_2d = readAsciiTable(invar_a,ncol,"float",header)
  qs_v_2d = readAsciiTable(invar_b,ncol,"float",header)
  qs_mask = readAsciiTable(invar_c,ncol,"float",header)
  qs_time_all = readAsciiTable(invar_d,ncol,"float",header)

  lat2d_2 = readAsciiTable(lat,ncol,"float",header)
  lon2d_2 = readAsciiTable(lon,ncol,"float",header)

  ; assign lat/lon data to u and v
  qs_u_2d@lat2d = lat2d_2
  qs_u_2d@lon2d = lon2d_2
  qs_u_2d!0 = "south_north"
  qs_u_2d!1 = "west_east"
  qs_u_2d@coordinates = "lat lon"
  qs_u_2d@units = "m s-1"
  qs_u_2d@long_name = "eastward wind"

  copy_VarMeta(qs_u_2d, qs_v_2d)
  qs_v_2d@long_name = "northward wind"

  ; calculate Quikscat wind speed
  qs_speed_2d = sqrt(qs_u_2d^2+qs_v_2d^2)
  copy_VarMeta(qs_u_2d, qs_speed_2d)
  qs_speed_2d@long_name = "Total Wind Speed"

  ; calculate Quikscat swath time
  qs_time = round(avg(qs_time_all)*24.,3)

  ; calculate dimensions
  dims_2 = dimsizes(lat2d_2)    ; get lat/lon dimensions from second domain
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

  qs_u_1d = ndtooned(qs_u_2d)

  wrf_u_1d = ndtooned(wrf_u_2d)        ; convert data from wrf to 1D array
  wrf_v_1d = ndtooned(wrf_v_2d)
  wrf_speed_1d = ndtooned(wrf_speed_2d)

  wrf_u_1d_new = new(dimsizes(qs_u_1d),"float")
  wrf_v_1d_new = new(dimsizes(qs_u_1d),"float")
  wrf_speed_1d_new = new(dimsizes(qs_u_1d),"float")

  wrf_u_2d_new = new(dimsizes(qs_u_2d),"float")
  wrf_v_2d_new = new(dimsizes(qs_v_2d),"float")
  wrf_speed_2d_new = new(dimsizes(qs_speed_2d), "float")

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
    
    wrf_u_1d_new(i) = sum(wrf_u_1d(inds)*wgt)/sum(wgt)
    wrf_v_1d_new(i) = sum(wrf_v_1d(inds)*wgt)/sum(wgt)
    wrf_speed_1d_new(i) = sum(wrf_speed_1d(inds)*wgt)/sum(wgt)

    delete(inds)
    delete(wgt)

    ; Counter
    if(i%1000.eq.0) then
      print("interpolated "+i+" of "+n_tot)
    end if

  end do

  wrf_u_2d_new = onedtond(wrf_u_1d_new,(/nlat,nlon/))
  copy_VarMeta(qs_u_2d,wrf_u_2d_new)
  wrf_v_2d_new = onedtond(wrf_v_1d_new,(/nlat,nlon/))
  copy_VarMeta(qs_v_2d,wrf_v_2d_new)

  wrf_speed_2d_new = onedtond(wrf_speed_1d_new, (/nlat,nlon/))
  copy_VarMeta(qs_speed_2d, wrf_speed_2d_new)

;;;;;;;;;;
; manipulate data
;;;;;;;;;; 

  ; mask data where Quikscat didn't get retreivals
  wrf_speed_masked = mask(wrf_speed_2d_new, qs_mask .eq. 0, False)
    delete(wrf_speed_2d)
  wrf_speed_2d = wrf_speed_masked
  copy_VarMeta(qs_speed_2d, wrf_speed_2d)

  wrf_u_masked = mask(wrf_u_2d_new, qs_mask .eq. 0, False)
  wrf_u = wrf_u_masked
  copy_VarMeta(qs_u_2d, wrf_u)

  wrf_v_masked = mask(wrf_v_2d_new, qs_mask .eq. 0, False)
  wrf_v = wrf_v_masked
  copy_VarMeta(qs_v_2d, wrf_v)

  ; Find difference between data
  diff = wrf_speed_2d - qs_speed_2d
  copy_VarMeta(qs_speed_2d, diff)
  
  u_diff = wrf_u - qs_u_2d
  v_diff = wrf_v - qs_v_2d
  copy_VarMeta(qs_u_2d, u_diff)
  copy_VarMeta(qs_v_2d, v_diff)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Calculating domain-avg stats for "+title2+" and "+title1)
;;;;;;;;;;
; calculate stats
;;;;;;;;;; 

  ; get necessary info on file size
  mask_1d = ndtooned(qs_mask)
  dum = ind(mask_1d .eq. 1)          ; only consider "good" data in avg
  tot_pts = dimsizes(dum)

  ; calculate averages
  wrf_avg  = avg(wrf_speed_2d)
  qs_avg   = avg(qs_speed_2d)
  
  ; calculate bias
  bias_2d =  wrf_speed_2d - qs_speed_2d
  BIAS = avg(bias_2d)

  ; calculate mae
  mae_bias = abs(bias_2d)
  MAE = avg(mae_bias)
 
  ; sq_bias = bias^2
  sum_sq_bias = sum(bias_2d^2)
  RMSE =  sqrt(sum_sq_bias/(tot_pts))

  ; calculate correlation
  CORR = escorc(ndtooned(wrf_speed_2d), ndtooned(qs_speed_2d))

;;;;;;;;;;
; write to a file
;;;;;;;;;; 

    head  = " BIAS(wrf-qs)     MAE        RMSE         CORR"
    stats = sprintf("%10.4f",BIAS)+sprintf("%10.4f",MAE)+sprintf("%10.4f",RMSE)+sprintf("%10.4f",CORR) 
    output = array_append_record(head, stats, 0)   ; append stats to header

    asciiwrite(fout_stats+".txt", output)          ; write stats to txt file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  print("Now making Quikscat windspeed plot.")

  ; set max and min values for plot
  cmin0 = 0
  cmax0 = 48.
  clev0 = 2.
  stride              = clev0                  ; label stride
  plotlines           = False                  ; lines for reg plot
  cntype              = "RasterFill"
  spreadstart0        = 2                 ; start at color- spatial
  spreadend0          = 21                ; end at color
  colormap = "winds.alice"

  ; open workstation
  wks = gsn_open_wks("ps" ,fout_plots)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(3, graphic)

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
  
  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude
  res@mpMaxLatF                   = 68.
  res@mpMinLonF                   = -55.
  res@mpMaxLonF                   = -18.
  ;res@mpMaxLatF                   = 67.              ; set the maximum latitude
  ;res@mpMinLonF                   = -57.0            ; set the minimum longitude
  ;res@mpMaxLonF                   = -30.0            ; set the maximum longitude

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
  res@cnMissingValFillColor       = "gray85"          ; missing value color
  res@cnMissingValFillPattern     = 3                 ; fill in
  res@tiMainFontHeightF           = 0.013
  ;res@lbLabelBarOn                = False             ; turn off individual label bars
  res@tiMainFontHeightF           = 0.013
  res@lbLabelStride               = 2
  res@pmLabelBarOrthogonalPosF    = -0.01             ; move label bar closer
  res@pmLabelBarHeightF           = 0.075


 ; set vector resources 
  vcres                            = True
  vcres@gsnRightString             = ""
  vcres@gsnLeftString              = ""
  vcres@gsnFrame                   = False             ; Do not draw plot 
  vcres@gsnDraw                    = False             ; Do not advance fr
  vcres@gsnAddCyclic               = False             ; regional - not cyclic 
  vcres@vcGlyphStyle               = "LineArrow"
  vcres@vcRefMagnitudeF            = 25.               ; set vector reference magnitude
  vcres@vcRefLengthF               = 0.03              ; length of vector (larger = longer)
  vcres@vcMinDistanceF             = 0.04              ; vector spacing (smaller = more dense)
  vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder  ; set vector legend resources
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "25 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string

;;;;;;;;;;;;;
; Plot 0 - WRF
;;;;;;;;;;;;;

  opts0                            = res
  opts0@tiMainString               = title1+" interpolated to "+title2+" at "+qs_time+"UTC  ~C~     (uses "+title2+ " missing data mask)"

  cplot0a = gsn_csm_contour_map(wks, wrf_speed_2d , opts0)      ; create ascending plot
  if (isvar("vectors") .and. (vectors))then
    cplot0b = gsn_csm_vector(wks, wrf_u, wrf_v, vcres)
    overlay(cplot0a,cplot0b)
  end if
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - Quikscat
;;;;;;;;;;;;;

  opts1                            = res
  opts1@tiMainString               = title2+" at "+qs_time+"UTC"

  cplot1a = gsn_csm_contour_map(wks, qs_speed_2d , opts1)      ; create descending plot
  if (isvar("vectors") .and. (vectors)) then
    cplot1b = gsn_csm_vector(wks, qs_u_2d, qs_v_2d, vcres)
    overlay(cplot1a,cplot1b)
  end if
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - Difference
;;;;;;;;;;;;;

  opts2                            = res
  delete(opts2@cnMinLevelValF)
  delete(opts2@cnMaxLevelValF)
  delete(opts2@gsnSpreadColorStart)
  delete(opts2@gsnSpreadColorEnd)
  
  opts2@tiMainString               = title1+" - "+title2+" at "+qs_time+"UTC"
  opts2@cnMinLevelValF             = -16.             ; set min contour level specified above
  opts2@cnMaxLevelValF             = 16.              ; set max contour level specified above
  opts2@gsnSpreadColorStart        = 23                ; start at color specified above
  opts2@gsnSpreadColorEnd          = 45                ; end at color specified above
  
  vcres@vcRefMagnitudeF            = 5.               ; set vector reference magnitude
  vcres@vcRefAnnoString2           = "5 m/s"          ; label vector legend bottom string


  cplot2a = gsn_csm_contour_map(wks, diff , opts2)      ; create descending plot
  if (isvar("vectors") .and. (vectors))then
    cplot2b = gsn_csm_vector(wks, u_diff, v_diff, vcres)
    overlay(cplot2a,cplot2b)
  end if
  plot(2) = cplot2a                                         ; make panel section of this plot



;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = title1+"km and "+title2+" (NASA DIRTH):  10m winds for "+date1

  pnlres                            = True
  pnlres@gsnPaperOrientation        = "landscape"       ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@txString                   = title_fin           ; set title for whole panel plot.
  pnlres@txFontHeightF              = 0.013

  gsn_panel(wks,(/plot/),(/3,1/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout_plots+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout_plots+".png"

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
