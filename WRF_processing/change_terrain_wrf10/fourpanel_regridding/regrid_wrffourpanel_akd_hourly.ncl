;***************************************
; PROGRAM DESCRIPTION: This NCL script plots comparisons between 
;                      2D variables from two WRF resolutions
; INPUT DATA: Two WRF output files at native resolution,text files for
;             weights and indicies made from cress_regrid_wrf-to-wrf10.ncl
; OUTPUT DATA: Four panels of specified variable at regridded resolution
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
; MANUAL INPUTS - for testing purposes
; inputs for file
dir1 = "./"
dir2 = "./"
fname1 = "geo_em.d01_100km"     ; file with original grid
fname2 = "geo_em.d01_10km_lowres"     ; file with grid to interpolate to
title1 = "WRF_100"
title2 = "WRF_10"
varcode ="HGT"

; set if this is a zoomed plot or the whole domain
zoom = False
whole_dom = True

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_"+title1+"_to_"+title2+"_terrain"

; set weight and index file names
ind_in = "./indicies_"+title1+"_to_"+title2
wgt_in = "./weights_"+title1+"_to_"+title2

title2 = "WRF_10 - 100km terrain"

; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")

  print("Running Fourpanel for "+title1+" to  "+title2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
  if (varcode.eq."HGT") then
    vartitle1 = "Terrain height"
    invar1 = "HGT_M"
    invar2 = "HGT_M"
    vartype = "1d"
    cmaptype = "terr"
  end if


; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."terr") then
    cmin1 =  0.
    cmax1 =  4000.
    clev1 =  50.
    cmin2 = -500.
    cmax2 =  500.
    clev2 =  25.
    clevd = clev2
    stride1             = 10                 ; label stride
    stride2             = 10
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"
    spreadstart1        = 3                 ; start at color
    spreadend1          = 68                ; end at color
    spreadstart2        = 102                ; start at color
    spreadend2          = 124                ; end at color
    colormap            = "terrain.alice"
  end if


  title0 = title1+" and "+title2            ; make a title string for the overlay plot
  title3 = title2+" - "+title1              ; make a title string for the difference plot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
; load in two wrf files
;;;;;;;;;;

  f1 = addfile(dir1 + fname1 + ".nc","r")
  lat2d_1 = f1->XLAT_M(0,:,:)
  lon2d_1 = f1->XLONG_M(0,:,:)
  
  f2 = addfile(dir2 + fname2 + ".nc","r")
  lat2d_2 = f2->XLAT_M(0,:,:)
  lon2d_2 = f2->XLONG_M(0,:,:)


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

  inds_in = readAsciiTable(ind_in+".txt",ncol,"integer",header)  ; read in ascii as float to get statistics
  wgts_in = readAsciiTable(wgt_in+".txt",ncol,"float",header)  ; read in ascii as float to get statistics

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

; 1d vars (terrain height)
  if (vartype.eq."1d") then
    var1_2d = f1->HGT_M(0,:,:)
    var2_2d = f2->HGT_M(0,:,:)
  end if

  var1_2d@lat2d = lat2d_1
  var1_2d@lon2d = lon2d_1

print("Loaded variables")

;return
;;;;;;;;;;
; interpolate the variable
;;;;;;;;;; 
  print("Interpolating "+title1+" to  "+title2)

  var1_1d = ndtooned(var1_2d)          ; convert data from first file to 1D array
  var2_1d = ndtooned(var2_2d)          ; convert data from second file to 1D array 

  var1_1d_new = new(dimsizes(var2_1d),"float")
  var1_2d_new = new(dimsizes(var2_2d),"float")
 
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
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
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
  print("Processing four panel graphs for "+varcode)

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
  res@mpMaxLatF                   = 68.              ; set the maximum latitude 
  res@mpMinLonF                   = -55.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -18.0            ; set the maximum longitude 
  ;res@mpMinLatF                   = 56.              ; set the minimum latitude (tip jet only)
  ;res@mpMaxLatF                   = 67.              ; set the maximum latitude (tj only)
  ;res@mpMinLonF                   = -57.0            ; set the minimum longitude (tj only)
  ;res@mpMaxLonF                   = -30.0            ; set the maximum longitude (tj only)
 end if

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
  opts@tiMainString               = title0            ; set title for plot. designated above as both input names
  opts@tiMainFontHeightF          = 0.013
  opts@cnInfoLabelOn              = False
  opts@cnLineLabelFontColor       = opts@cnLineColor  ; set the contour labels to be the same as the contour line color
  opts@cnLineLabelBackgroundColor = "Transparent"     ; set the background behind contour labels to be transparent
  opts@cnFillMode                 = "AreaFill"

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
  
  cplot2 = gsn_csm_contour_map(wks, var1_2d, opts)      ; create second plot
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

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  plot(2) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = vartitle1+": "+title1+" and "+title2  

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
