;***************************************
; PROGRAM DESCRIPTION: This NCL script calculate and plots 
;                      bulk transfer coefficients
; INPUT DATA: Two WRF output files of different resolutions, 
;             text files for weights and indicies
; OUTPUT DATA: Panel plot of of transfer coefficients
; Note: No cshell is written to loop this. Inputs are specified manually below.
; CREATOR: Alice DuVivier - February 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
dir1 = "/data3/duvivier/CASE_STUDY/misc_tests/flux_tests/"
dir2 = "/data3/duvivier/CASE_STUDY/misc_tests/flux_tests/"
fname1 = "wrf-2007-02-21-15_100km"     ; file with original grid
fname2 = "wrf-2007-02-21-15_10km"     ; file with grid to interpolate to
title1 = "WRF_100"
title2 = "WRF_10"
date1 = "2007-02-21-15"
varcode = "Ch"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_"+title1+"_"+title2+"_"+date1

; set weight and index file names
ind_in = "indicies_"+title1+"_to_"+title2
wgt_in = "weights_"+title1+"_to_"+title2

; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")

  print("Running Fourpanel for "+title1+" to  "+title2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Which variables need to be loaded?
   if (varcode.eq."Ch") then  ; bulk coeff for sensible heat
    vartitle1 = "Bulk Coefficient For Sensible Heat Flux"
    invar0 = "SHFlx"
    invar1 = "slp"
    invar2 = "T_sfc"     ; pot temp at surface = temp (Poisson's equation)
    invar3 = "Th_e"      ; use a potential temperature gradient
    invar4 = "u_10m_tr"  ; use 10m winds
    invar5 = "v_10m_tr"
;    invar3 = "T_e"
;    invar4 = "u_tr_e"
;    invar5 = "v_tr_e"
    cmaptype = "coeff"
    sen_coeff = True
    mask_500 = True
  end if
  if (varcode.eq."Ce") then  ; bulk coeff for sensible heat
    vartitle1 = "Bulk Coefficient For Latent Heat Flux"
    invar0 = "LHFlx"
    invar1 = "slp"
    invar2 = "T_sfc"
    invar3 = "T_e"
    invar4 = "u_10m_tr"  ; use 10m winds
    invar5 = "v_10m_tr"
;    invar4 = "u_tr_e"
;    invar5 = "v_tr_e"
    invar6 = "q_e"
    cmaptype = "coeff"
    lat_coeff = True
    mask_500 = True
 end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."coeff") then
    cmin1 = -0.005
    cmax1 = 0.005
    clev1 = 0.001
    cmin2 = -0.001
    cmax2 = 0.001
    clev2 = 0.0005
    clevd = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 103                ; end at color
    spreadstart2        = 2                ; start at color
    spreadend2          = 103 
    colormap            = "BrownBlue"
  end if


  title0 = title1+" and "+title2            ; make a title string for the overlay plot
  title3 = title2+" - "+title1              ; make a title string for the difference plot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set constants
  R  = 287.   ; 287  J/kg*K
  cp = 1004.  ; 1004 J/kg*K
  lv = 2.5E6  ; 2.5E6 J/kg

;;;;;;;;;;
; load in two wrf files
;;;;;;;;;;

  f1 = addfile(dir1 + fname1 + ".nc","r")
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  
  f2 = addfile(dir2 + fname2 + ".nc","r")
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon

  dims_2 = dimsizes(lat2d_2)     ; get lat/lon dimensions from second domain
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
  max_indicies = 5                                     ; maximum number of points that can be included in weighted avg 

; load in arrays of indicies and weights
  ncol = 1   ; number of columns
  header = 0 ; number of header lines

  inds_in = readAsciiTable(dir1+ind_in+".txt",ncol,"integer",header)  ; read in ascii as float to get statistics
  wgts_in = readAsciiTable(dir1+wgt_in+".txt",ncol,"float",header)  ; read in ascii as float to get statistics

  interp_ind = onedtond(inds_in,(/n_tot,max_indicies/))
  interp_ind!0 = title2+"_index"                      ; name the dimensions of the array
  interp_ind!1 = title1+"_indicies"  
  
  interp_wgt = onedtond(wgts_in,(/n_tot,max_indicies/))
  interp_wgt!0 = title2+"_index"
  interp_wgt!1 = title1+"_weightings"


;;;;;;;;;;
; load in wrf variables
;;;;;;;;;;
  print("Loading "+title1+" and "+title2)

 ; Get first file's variable info
   var0a_2d = f1->$invar0$(time|0,south_north|:,west_east|:)         ; load the flux info
   var1a_2d = f1->$invar1$(time|0,south_north|:,west_east|:)         ; load the slp info
   var2a_2d = f1->$invar2$(time|0,south_north|:,west_east|:)         ; load the surface temp
   var3a_2d = f1->$invar3$(time|0,eta|0,south_north|:,west_east|:)   ; load the air temp
   var4a_2d = f1->$invar4$(time|0,south_north|:,west_east|:)   ; load the u wind
   var5a_2d = f1->$invar5$(time|0,south_north|:,west_east|:)   ; load the v wind
;   var4a_2d = f1->$invar4$(time|0,eta|0,south_north|:,west_east|:)   ; load the u wind
;   var5a_2d = f1->$invar5$(time|0,eta|0,south_north|:,west_east|:)   ; load the v wind

 ; Get second file's variable info
   var0b_2d = f2->$invar0$(time|0,south_north|:,west_east|:)         ; load the flux info
   var1b_2d = f2->$invar1$(time|0,south_north|:,west_east|:)         ; load the slp info
   var2b_2d = f2->$invar2$(time|0,south_north|:,west_east|:)         ; load the surface temp
   var3b_2d = f2->$invar3$(time|0,eta|0,south_north|:,west_east|:)   ; load the air temp
   var4b_2d = f2->$invar4$(time|0,south_north|:,west_east|:)   ; load the u wind
   var5b_2d = f2->$invar5$(time|0,south_north|:,west_east|:)   ; load the v wind
;   var4b_2d = f2->$invar4$(time|0,eta|0,south_north|:,west_east|:)   ; load the u wind
;   var5b_2d = f2->$invar5$(time|0,eta|0,south_north|:,west_east|:)   ; load the v wind

   if(isvar("lat_coeff").and.(lat_coeff))then  
     var6a_2d = f1->$invar6$(time|0,eta|0,south_north|:,west_east|:) ; load the air q
     var6b_2d = f2->$invar6$(time|0,eta|0,south_north|:,west_east|:) 
   end if

;;;;;;;;;;
; Calculate bulk coefficients
;;;;;;;;;;
; set the fill value
dum = new((/1,1/),"float")
fill = dum@_FillValue

;;;; Sensible Heat Flux Coefficient
   if(isvar("sen_coeff").and.(sen_coeff))then
     var1a_2d = var1a_2d*100.  ; convert hPa to Pa
     var1a_2d@units = "Pa"
     var1b_2d = var1b_2d*100.
     var1b_2d@units = "Pa"

     rhoa = var1a_2d/(R*var2a_2d)    ;calculate surface density
     rhob = var1b_2d/(R*var2b_2d)

     var2a_2d = var2a_2d*(100000./var1a_2d)^(R/cp) ; covert surf temp to surf pot temp
     var2b_2d = var2b_2d*(100000./var1b_2d)^(R/cp)
   
     w_spd_a = sqrt(var4a_2d^2+var5a_2d^2) ; Convert to net wind speed 
     w_spd_b = sqrt(var4b_2d^2+var5b_2d^2) 

     tgrad_a = (var2a_2d -var3a_2d)
     denom_a = (rhoa*cp*w_spd_a*tgrad_a)
    ; How to deal with zeros in the denominator - if exist
     denom_a = where(denom_a .eq. 0, fill, denom_a)
     var1_2d = var0a_2d/denom_a
     copy_VarCoords(var0a_2d,var1_2d)
     var1_2d@long_name = "Sensible Heat Flux Bulk Transfer Coefficient"
     var1_2d@standard_name = "Sen_Bulk_Coeff"

     tgrad_b = (var2b_2d -var3b_2d)
     denom_b = (rhob*cp*w_spd_b*tgrad_b)
    ; How to deal with zeros in the denominator - if exist
     denom_b = where(denom_b .eq. 0, fill, denom_b)
     var2_2d = var0b_2d/denom_b
     copy_VarCoords(var0b_2d,var2_2d)
     var2_2d@long_name = "Sensible Heat Flux Bulk Transfer Coefficient"
     var2_2d@standard_name = "Sen_Bulk_Coeff"   

   end if

;;;; Latent Heat Flux Coefficient
   if(isvar("lat_coeff").and.(lat_coeff))then
   ; First calculate the surface mixing ratio using surface temperature
    ; Get SLP for calculation (hPa)
    slp_a = var1a_2d
    slp_b = var1b_2d

    ; Calculate surface density
    rhoa = (slp_a*100.)/(R*var2a_2d)    
    rhob = (slp_b*100.)/(R*var2b_2d)

    ; Convert surface temp to Celsius 
    var2a_2d = var2a_2d-273.15
    var2b_2d = var2b_2d-273.15
    var2a_2d@units = "C"
    var2b_2d@units = "C"

   ;File 1- Calculate surface mixing ratio
    satvp_1 = 0.6112*exp((17.67*var2a_2d)/(243.5+var2a_2d))*10.0 ; Saturation vap. press in hPa
    satmr_1 = 0.622*(satvp_1/(slp_a-satvp_1)) ; Saturation mixing ratio in kg/kg
    var7a_2d = satmr_1
    copy_VarMeta(var6a_2d,var7a_2d)
    var7a_2d@long_name = "Surface Saturation Mixing Ratio - Water Vapor"
    delete(var7a_2d@eta)

   ;File 2- Calculate surface mixing ratio
    satvp_2 = 0.6112*exp((17.67*var2b_2d)/(243.5+var2b_2d))*10.0 ; Saturation vap. press in hPa
    satmr_2 = 0.622*(satvp_2/(slp_b-satvp_2)) ; Saturation mixing ratio in kg/kg
    var7b_2d = satmr_2
    copy_VarMeta(var6b_2d,var7b_2d)
    var7b_2d@long_name = "Surface Saturation Mixing Ratio - Water Vapor"
    delete(var7b_2d@eta)
 
  ; Now calculate bulk transfer coefficients
    var1a_2d = var1a_2d*100.  ; convert hPa to Pa
    var1a_2d@units = "Pa"
    var1b_2d = var1b_2d*100.
    var1b_2d@units = "Pa"
   
    w_spd_a = sqrt(var4a_2d^2+var5a_2d^2) ; Convert to net wind speed 
    w_spd_b = sqrt(var4b_2d^2+var5b_2d^2) 

   ; First file bulk coeff
    qgrad_a   = (var7a_2d - var6a_2d)
    denom_a = (rhoa*lv*w_spd_a*qgrad_a)
    ; How to deal with zeros in the denominator - if exist
     denom_a = where(denom_a .eq. 0, fill, denom_a)
     var1_2d = var0a_2d/denom_a
     copy_VarCoords(var0a_2d,var1_2d)
     var1_2d@long_name = "Latent Heat Flux Bulk Transfer Coefficient"
     var1_2d@standard_name = "Lat_Bulk_Coeff"

  ; Second file bulk coeff
    qgrad_b   = (var7b_2d - var6b_2d) 
    denom_b = (rhob*lv*w_spd_b*qgrad_b)
    ; How to deal with zeros in the denominator - if exist
     denom_b = where(denom_b .eq. 0, fill, denom_b)
     var2_2d = var0b_2d/denom_b
     copy_VarCoords(var0b_2d,var2_2d)
     var2_2d@long_name = "Latent Heat Flux Bulk Transfer Coefficient"
     var2_2d@standard_name = "Lat_Bulk_Coeff"
   
end if

;;;;;;;;;;
; interpolate the variable
;;;;;;;;;; 
  print("Interpolating "+title1+" to  "+title2)

  var1_1d = ndtooned(var1_2d)          ; convert data from first file to 1D array
  var2_1d = ndtooned(var2_2d)          ; convert data from second file to 1D array 

  var1_1d_new = new(dimsizes(var2_1d),"float")
  var1_2d_new = new(dimsizes(var2_2d),"float")

  do i = 0, n_tot-1

    indicies = interp_ind(i,:)
    indicies@_FillValue = -999

    num_ind      = num(.not.ismissing(indicies))
    
    weights = interp_wgt(i,:)
    weights@_FillValue = -999

    num_wgt      = num(.not.ismissing(weights))
      if(num_ind.ne.num_wgt) then
        print("Loaded different numbers of weight and indicies!")
        exit
      end if
    inds = indicies(0:num_ind-1)
    wgt  = weights(0:num_wgt-1)
   
    var1_1d_new(i) = sum(var1_1d(inds)*wgt)/sum(wgt)

    delete(inds)
    delete(wgt)

    ; Counter
    if(i%1000.eq.0) then
      print("interpolated "+i+" of "+n_tot)
    end if

  end do


  var1_2d_new = onedtond(var1_1d_new,(/nlat,nlon/))
  copy_VarMeta(var2_2d,var1_2d_new)

  var1 = var1_2d_new
  var2 = var2_2d

;;;;;;;;;;
; manipulate arrays as needed
;;;;;;;;;; 
; check if the data needs a mask above 500m terrain height.
; This uses the terrain height from the high res wrf file and masks both files with it
  if (isvar("mask_500").and.(mask_500)) then
    print("Masking land for plot above 500m.")
    terr = f2->Z_sfc(:,:)
    var1_masked = mask(var1,terr.gt.500,0)
    var2_masked = mask(var2,terr.gt.500,0)
    copy_VarMeta(var1,var1_masked)
    delete(var1)
    var1 = var1_masked
    copy_VarMeta(var2,var2_masked)
    delete(var2)
    var2 = var2_masked
  end if


; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" "+title1+" min: "+min(var1)+"  max: "+max(var1)) 
  print(vartitle1+" "+title2+" min: "+min(var2)+"  max: "+max(var2))

; assign 2d lat and lon attributes for plotting:
  var1@lat2d  = lat2d_2
  var1@lon2d  = lon2d_2
  var2@lat2d  = lat2d_2
  var2@lon2d  = lon2d_2

; create difference file
diff = var2 - var1
  diff@lat2d  = lat2d_2
  diff@lon2d  = lon2d_2
  copy_VarMeta(var2,diff)
  
  print(vartitle1+" diff min: "+min(diff)+"      max: "+max(diff))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  print("Processing four panel graphs for "+varcode+" "+date1)

  ;wks = gsn_open_wks("x11",fout)
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
  res@mpMaxLatF                   = 67.              ; set the maximum latitude
  res@mpMinLonF                   = -57.0            ; set the minimum longitude
  res@mpMaxLonF                   = -30.0            ; set the maximum longitude
 end if

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "forestgreen"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner
  

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

  cplot1 = gsn_csm_contour_map(wks,var1,opts)  ; create plot of first contours
  cplot1b = gsn_csm_contour(wks,var2,opts2)    ; create plot of second contours
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
  opts@tiMainString               = title1            ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  
  ;plot(1) = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  
  cplot2 = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;

; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2            ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, var2, opts)      ; create fourth plot
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

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  plot(2) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = date1+" "+vartitle1+": "+title1+" and "+title2  

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot
  
;  convert_cmd = "convert -density 300 "+fout+".ps -resize 30% -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(var1)
  delete(var2)
  delete(convert_cmd)
  delete(lgres)
  delete(res)
  delete(pnlres)
  delete(diff)
  delete(opts)



;;;;;;;;;;;;;;;;;;;;;; END script
end


