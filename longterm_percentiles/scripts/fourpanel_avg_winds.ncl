;***************************************
; PROGRAM DESCRIPTION: This NCL script plots the average values and 
;             difference values from longterm files at two WRF resolutions.
; INPUT DATA: Two WRF output files at native resolution that are concatenated
;             monthly files
; OUTPUT DATA: Four panel plot of average value at second file's resolution
; Note: This script is designed to find the average WIND values
; CREATOR: Alice DuVivier - February 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
title1 = "WRF_100"
name1  = "wrf_100km"

title2 = "WRF_10"
name2  = "wrf_10km"

;for testing purposes
dir1 = "/ptmp/duvivier/FEBMAR/"+name1+ "/wrf_cont/catted/"
dir2 = "/ptmp/duvivier/FEBMAR/"+name2+ "/wrf_cont/catted/"

fname1 = "wrf-200701-cat"
fname2 = "wrf-200702-cat"
fname3 = "wrf-200703-cat"

varcode = "Windsurf"

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_fourpanel_longterm_avg_"+title1+title2
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

; Specify index and weight arrays using input
; the arrays must be in the present directory
ind_in = "./indicies_"+title1+"_to_"+title2
wgt_in = "./weights_"+title1+"_to_"+title2


  print("Running longterm avg at all resolutions")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information

 if (varcode.eq."Windsurf") then
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_tr"
    invar11 ="v_10m_tr"
    vartype = "2d"
    cmaptype = "wind"
    find_speed = True
    met_not_avail = True  ; wind data not in met
 end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin1 = 0
    cmax1 = 18.
    clev1 = 2.
    cmin2 = -6.
    cmax2 = 6.
    clev2 = 2.
    clevd = clev1*2
    stride1             = 1                 ; label stride
    stride2             = 1                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 18                ; end at color
    spreadstart2        = 20                ; start at color
    spreadend2          = 42                ; end at color
    colormap           = "winds.alice2"
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
  var11_feb  = f1_feb->$invar11$(time|:,south_north|:,west_east|:)
  var11_mar  = f1_mar->$invar11$(time|:,south_north|:,west_east|:)
  
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
  var22_feb  = f2_feb->$invar11$(time|:,south_north|:,west_east|:)
  var22_mar  = f2_mar->$invar11$(time|:,south_north|:,west_east|:)

  lat2d_2 = f2_feb->lat
  lon2d_2 = f2_feb->lon
  var2_feb@lat2d = lat2d_2
  var2_feb@lon2d = lon2d_2
  dims2 = dimsizes(lat2d_2)
  nlat_2 = dims2(0)
  nlon_2 = dims2(1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Performing data processing: concatenating, averaging")
;;;;;;;;;;;;;
; If winds, find wind speed variable
;;;;;;;;;;;;
; first wrf file
  var1_feb_spd = sqrt(var1_feb^2 + var11_feb^2)
  var1_mar_spd = sqrt(var1_mar^2 + var11_mar^2)

; second wrf file
  var2_feb_spd = sqrt(var2_feb^2 + var22_feb^2)
  var2_mar_spd = sqrt(var2_mar^2 + var22_mar^2)

;;;;;;;;;;;;;
; Make arrays for full data sets with both feb and mar
;;;;;;;;;;;;
  ; get time dimensions for february and march
  dim_feb = dimsizes(var1_feb)
  t_feb = dim_feb(0)
  dim_mar = dimsizes(var1_mar)
  t_mar = dim_mar(0)
  t_tot = t_feb + t_mar

; make new arrays and fill them with old data
; first wrf file
  var1_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_tot(0:t_feb-1, :, :) = var1_feb
     var1_tot(t_feb:t_tot-1, :, :) = var1_mar

  var11_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var11_tot(0:t_feb-1, :, :) = var11_feb
     var11_tot(t_feb:t_tot-1, :, :) = var11_mar

  var1_spd_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_spd_tot(0:t_feb-1, :, :) = var1_feb_spd
     var1_spd_tot(t_feb:t_tot-1, :, :) = var1_mar_spd

; second wrf file
  var2_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_tot(0:t_feb-1, :, :) = var2_feb
     var2_tot(t_feb:t_tot-1, :, :) = var2_mar

  var22_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var22_tot(0:t_feb-1, :, :) = var22_feb
     var22_tot(t_feb:t_tot-1, :, :) = var22_mar

  var2_spd_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_spd_tot(0:t_feb-1, :, :) = var2_feb_spd
     var2_spd_tot(t_feb:t_tot-1, :, :) = var2_mar_spd

;;;;;;;;;;;;;
; Average over time dimension
;;;;;;;;;;;;
  ; time average and keep meta data
; first wrf file
  var1_avg     = dim_avg_n_Wrap(var1_tot, 0)
  var11_avg    = dim_avg_n_Wrap(var11_tot, 0)
  var1_spd_avg = dim_avg_n_Wrap(var1_spd_tot, 0)

; second wrf file
  var2_avg     = dim_avg_n_Wrap(var2_tot, 0)
  var22_avg    = dim_avg_n_Wrap(var22_tot, 0)
  var2_spd_avg = dim_avg_n_Wrap(var2_spd_tot, 0)

;;;;;;;;;;;;;
; Assign meta data
;;;;;;;;;;;;
  var1_avg@lat2d = lat2d_1
  var1_avg@lon2d = lon2d_1
  copy_VarMeta(var1_avg, var11_avg)
  copy_VarMeta(var1_avg, var1_spd_avg)

  var2_avg@lat2d = lat2d_2
  var2_avg@lon2d = lon2d_2
  copy_VarMeta(var2_avg, var22_avg)
  copy_VarMeta(var2_avg, var2_spd_avg)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  dims_2 = dimsizes(lat2d_2)     ; get lat/lon dimensions from high res domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we              ; get total number of points in high res domain
  nlat = n_sn                   ; used in plots
  nlon = n_we                   ; used in plots

;;;;;;;;;;
; load in weight and index arrays
;;;;;;;;;;
  print("Loading weight and index arrays")

; create weights and appropriate indicies for Cressman interpolation
  max_indicies = 5                    ; maximum number of points that can be included in weighted avg 

; load in arrays of indicies and weights
  ncol = 1   ; number of columns
  nrow =624030     ; number of rows
  header = 0 ; number of header lines

  inds_in = readAsciiTable(ind_in+".txt",ncol,"integer",header)  ; read in ascii as float to get statistics
  wgts_in = readAsciiTable(wgt_in+".txt",ncol,"float",header)  ; read in ascii as float to get statistics

  ; flatten arrays of weights and indicies
  interp_ind = onedtond(inds_in,(/n_tot,max_indicies/))
  interp_ind!0 = title2+"_index"                      ; name the dimensions of the array
  interp_ind!1 = title1+"_indicies"  
  
  interp_wgt = onedtond(wgts_in,(/n_tot,max_indicies/))
  interp_wgt!0 = title2+"_index"
  interp_wgt!1 = title1+"_weightings"

;;;;;;;;;;
; interpolate the variables
;;;;;;;;;; 
  print("Interpolating "+title1+" to  "+title2)

  var1_1d = ndtooned(var1_avg)          ; convert data from first file to 1D array
  var11_1d = ndtooned(var11_avg)
  var2_1d = ndtooned(var2_avg)          ; convert data from second file to 1D array
  var3_1d = ndtooned(var1_spd_avg)      ; average low res speed

  var1_1d_new = new(dimsizes(var2_1d),"float")
  var1_2d_new = new(dimsizes(var2_avg),"float")
  var11_1d_new = new(dimsizes(var2_1d),"float")
  var11_2d_new = new(dimsizes(var2_avg),"float")
  var3_1d_new = new(dimsizes(var2_1d),"float")   ; average variable
  var3_2d_new = new(dimsizes(var2_avg),"float")
 
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
      inds@_FillValue = -999
    wgt  = weights(0:num_wgt-1)
      wgt@_FillValue = -999
 
    var1_1d_new(i) = sum(var1_1d(inds)*wgt)/sum(wgt)
    var11_1d_new(i) = sum(var11_1d(inds)*wgt)/sum(wgt)
    var3_1d_new(i) = sum(var3_1d(inds)*wgt)/sum(wgt)
 
    delete(inds)
    delete(wgt)

    ; Counter
    if(i%1000.eq.0) then
      print("interpolated "+i+" of "+n_tot)
    end if
  end do

  var1_2d_new = onedtond(var1_1d_new,(/nlat,nlon/))
  copy_VarMeta(var2_avg,var1_2d_new)
  var11_2d_new = onedtond(var11_1d_new,(/nlat,nlon/))
  copy_VarMeta(var22_avg,var11_2d_new)
  var3_2d_new = onedtond(var3_1d_new,(/nlat,nlon/))
  copy_VarMeta(var2_spd_avg,var3_2d_new)

;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
    ; Find difference information
    u_diff = var2_avg - var1_2d_new
    v_diff = var22_avg - var11_2d_new

    u_diff@lat2d = lat2d_2
    u_diff@lon2d = lon2d_2
    v_diff@lat2d = lat2d_2
    v_diff@lon2d = lon2d_2

    ; Rename winds to plot them as vectors
    var1_vec = var1_2d_new         
    var11_vec = var11_2d_new
    var2_vec = var2_avg
    var22_vec = var22_avg

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" "+title1+" min: "+min(var3_2d_new)+"  max: "+max(var3_2d_new)) 
  print(vartitle1+" "+title2+" min: "+min(var2_spd_avg)+"  max: "+max(var2_spd_avg))

; create difference file
diff = var2_spd_avg - var3_2d_new
  diff@lat2d  = lat2d_2
  diff@lon2d  = lon2d_2
  
  print(vartitle1+" diff min: "+min(diff)+"      max: "+max(diff))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  print("Processing four panel graphs for "+varcode)

  ;wks = gsn_open_wks("x11",fout)
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(4, graphic)

; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")
  title0 = title1+" and "+title2            ; make a title string for the overlay plot
  title3 = title2+" - "+title1              ; make a title string for the difference plot
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
  
 if (isvar("whole_dom").and.(whole_dom))then
  res@mpLimitMode                 = "Corners"
  res@mpLeftCornerLatF            = lat2d_2(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d_2(0,0)
  res@mpRightCornerLatF           = lat2d_2(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d_2(nlat-1,nlon-1)
 end if

 if (isvar("zoom").and.(zoom))then
  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude 
  res@mpMaxLatF                   = 68.              ; set the maximum latitude 
  res@mpMinLonF                   = -55.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -18.0            ; set the maximum longitude 
 end if

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
  

; set vector resources if it's a wind plot
   if (isvar("find_speed").and.(find_speed)) then
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
   vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder)
  
; vector legend placement
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "25 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string

  end if

;;;;;;;;;;;;;
; Plot 1 - overlay contours
;;;;;;;;;;;;;

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@cnLineColor                = "red"
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level. designated above for each variable of interest
  opts@cnMaxLevelValF             = cmax1             ; set max contour level. designated above
  opts@cnLevelSpacingF            = clevd           ; set contour spacing. designated above
  opts@tiMainString               = title0            ; set title for plot. designated above as both input names
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
if (isvar("whole_dom").and.(whole_dom))then
  delete(opts2@mpLeftCornerLonF)
  delete(opts2@mpLeftCornerLatF)
  delete(opts2@mpRightCornerLatF)
  delete(opts2@mpRightCornerLonF)
end if
if (isvar("zoom").and.(zoom))then
  delete(opts2@mpMaxLonF)
  delete(opts2@mpMinLonF)
  delete(opts2@mpMaxLatF)
  delete(opts2@mpMinLatF)
end if

; cplot1 = gsn_csm_contour_map(wks,var1,opts)
  cplot1 = gsn_csm_contour_map(wks,var3_2d_new,opts)  ; create plot of first contours
  cplot1b = gsn_csm_contour(wks,var2_spd_avg,opts2)    ; create plot of second contours
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
  title11  = title1 +" (interpolated to "+title2+")"


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
  opts@tiMainString               = title11            ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  
  ;plot(1) = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  
  cplot2 = gsn_csm_contour_map(wks, var3_2d_new, opts)      ; create second plot
;  cplot2 = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot2b = gsn_csm_vector(wks, var1_vec, var11_vec, vcres)
    overlay(cplot2,cplot2b)
  end if
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;
; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2            ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, var2_spd_avg, opts)      ; create fourth plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot4b = gsn_csm_vector(wks, var2_vec, var22_vec, vcres)
    overlay(cplot4,cplot4b)
  end if
  plot(3) = cplot4                              ; make panel section of this plot
  delete(opts)


;;;;;;;;;;;;;
; Plot 3 - difference 
;;;;;;;;;;;;; 

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

; changing some vector resources for difference plot

   if (isvar("find_speed").and.(find_speed)) then
   vcres@vcRefMagnitudeF            = 5.               ; set vector reference magnitude
   vcres@vcRefAnnoString2           = "5 m/s"          ; label vector legend bottom string
   vcres@vcLineArrowHeadMaxSizeF    = 0.01
   end if

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot3b = gsn_csm_vector(wks, u_diff, v_diff, vcres)
    overlay(cplot3,cplot3b)
  end if
  plot(2) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = "95% " + vartitle1 + ": " + title1 + " and " + title2  

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(lgres)
  delete(res)
  delete(pnlres)
  delete(diff)
  delete(opts)
 if (isvar("find_speed").and.(find_speed)) then
  delete(vcres)
 end if


;;;;;;;;;;;;;;;;;;;;;; END script
end
