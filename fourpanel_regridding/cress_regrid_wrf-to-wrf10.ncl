;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and another spacing
; OUTPUT DATA: two text files of indicies and weights for interpolation,
;              a plot of the terrain of each WRF domain and the difference
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
; (area of influence for weighting)
cressrad      = 24.  ; cressman radius in km (25->10km)
;cressrad      = 45.  ; cressman radius in km (50->10km)
;cressrad      = 95.  ; cressman radius in km (100->10km)

; inputs for file
dir1 = "/data3/duvivier/NCAR/fourpanel_regridding/"
dir2 = "/data3/duvivier/NCAR/fourpanel_regridding/"
outdir = "./"
fname1 = "geo_em.d01_25km"     ; file with original grid
fname2 = "geo_em.d01_10km"     ; file with grid to interpolate to
title1 = "WRF_25"
title2 = "WRF_10"
varcode = "hgt"

; BEGIN SCRIPT
; Check for input information:
  if(.not.any(isvar("dir1").and.isvar("dir2") \
              .and.isvar("fname1").and.isvar("fname2") \
              .and.isvar("title1").and.isvar("title2") \
              .and.isvar("varcode") \
              )) then
    print("Can't find all input information!")
  end if

; update titles to remove underscores:
  title1a = str_sub_str(title1,"_"," ")
  title2a = str_sub_str(title2,"_"," ")

; set outdir and fout names
outdir = "./"
fout   = outdir+"terrain_"+title1+"_and_"+title2

  print("Interpolating from "+title1a+" to  "+title2a)


;;;;;;;;;;
; add data
;;;;;;;;;;

; Load lower resolution topography:
  f1 = addfile(dir1 + fname1 + ".nc","r")
  hgt2d_1 = f1->HGT_M(0,:,:)
  lat2d_1 = f1->XLAT_M(0,:,:)
  lon2d_1 = f1->XLONG_M(0,:,:)
  
  lat1d_1 = ndtooned(lat2d_1)  ; convert all arrays to 1D
  lon1d_1 = ndtooned(lon2d_1)
  hgt1d_1 = ndtooned(hgt2d_1)

; Load higher resolution info lat/lon
  f2 = addfile(dir2 + fname2 + ".nc","r")
  hgt2d_2 = f2->HGT_M(0,:,:)
  lat2d_2 = f2->XLAT_M(0,:,:)
  lon2d_2 = f2->XLONG_M(0,:,:)

  lat1d_2 = ndtooned(lat2d_2)
  lon1d_2 = ndtooned(lon2d_2)

; Create array to interpolate terrain to
  hgt2d_new = new(dimsizes(lat2d_2), "float") 
  hgt1d_new = ndtooned(hgt2d_new)

  dims_2 = dimsizes(lat2d_2)     ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

;;;;;;;;;;
; regrid the first file to second file resolution
;;;;;;;;;;

; create weights and appropriate indicies for Cressman interpolation
  max_indices = 5                                     ; maximum number of points that can be included in weighted avg 
  interp_ind = new((/n_tot,max_indices/), "integer")  ; make array to put index values in
  interp_ind!0 = "old_index"                          ; name the dimensions of the array
  interp_ind!1 = "new_indices"
  interp_wgt = new((/n_tot,max_indices/), "float")    ; make array for weights
  interp_wgt!0 = "old_index"
  interp_wgt!1 = "new_weightings"

; run loop
  index = 0          ; set first index
  do i = 0, n_tot-1

   ; get great circle distance between the different grids in km
     dist = gc_latlon(lat1d_2(i),lon1d_2(i),lat1d_1,lon1d_1,2,4) 

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist))) then       
      nreplacements = num(isnan_ieee(dist))  ; find index of NaN
      replace_ieeenan(dist,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print that there were replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work (all points outside sphere of influence.)
    if (min(dist).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist.lt.cressrad)    ; find the indicies where the distance is within the cressman radius
    weight = (cressrad^2 - dist(indicies)^2) / (cressrad^2 + dist(indicies)^2)  ; give each index a weight
    hgt1d_new(i) = sum(hgt1d_1(indicies)*weight)/sum(weight)   ; get height at the new point based on weighted sum of surrounding points

  ; save calculated indicies and weighting factors for future use
    n_indicies = dimsizes(indicies)
    interp_ind(i,0:n_indicies-1) = (/indicies/)  ; put the indicies affecting each new grid point into an array for later
    interp_wgt(i,0:n_indicies-1) = (/weight/)    ; put the weights for each point into an array for later 
    delete(indicies)
    delete(weight)

;;;;;;  
; write output files - complicated and slow way
;;;;;;

;    if (index.eq.0) then                ; set header for the output text file
;      header_a = "ind1       ind2      ind3      ind4       ind5"
;      output_a = header_a
;      header_b = "wgt1       wgt2      wgt3      wgt4       wgt5"
;      output_b = header_b
;    end if

;    ; write index and weight outputs to 0 decimal points
;    a1 = sprintf("%10.0f",interp_ind(i,0))+sprintf("%10.0f",interp_ind(i,1))+\
;         sprintf("%10.0f",interp_ind(i,2))+sprintf("%10.0f",interp_ind(i,3))+\
;         sprintf("%10.0f",interp_ind(i,4))
;    
;    newoutput_a = array_append_record(output_a,a1,0)  ; append new output (a1) to previous outputs(output)
;    delete(output_a)
;    output_a = newoutput_a                            ; set output as newly appended list of statistics
;    delete(newoutput_a)

;    b1 = sprintf("%10.6f",interp_wgt(i,0))+sprintf("%10.6f",interp_wgt(i,1))+\
;         sprintf("%10.6f",interp_wgt(i,2))+sprintf("%10.6f",interp_wgt(i,3))+\
;         sprintf("%10.6f",interp_wgt(i,4)) 
;    
;    newoutput_b = array_append_record(output_b,b1,0)  ; append new output (a1) to previous outputs(output)
;    delete(output_b)
;    output_b = newoutput_b                            ; set output as newly appended list of statistics
;    delete(newoutput_b)

;;;;;;;
; counter
;;;;;;;

    if(i%100.eq.0) then
      print("created weighting "+i+" of "+n_tot)
    end if

    index = index + 1                             ; increase the index
  end do

;;;;;;  
; write weights and indices files
;;;;;;
  ;fout1   = outdir+"indicies_"+title1+"_to_"+title2     ; FOR SLOW WAY 
  ;fout2   = outdir+"weights_"+title1+"_to_"+title2
  ;asciiwrite(fout1+".txt",output_a)  ; write indices to text file
  ;asciiwrite(fout2+".txt",output_b)  ; write weights to text file
  
  fout1   = outdir+"indicies_"+title1+"_to_"+title2      ; MAKES 1D ARRAY OF indicies and weights
  fout2   = outdir+"weights_"+title1+"_to_"+title2
  asciiwrite(fout1+".txt",interp_ind)  ; write indices to text file
  asciiwrite(fout2+".txt",interp_wgt)  ; write weights to text file
;;;;;;  
; data manipulation
;;;;;;
; remove data >= 500m
;  hgt1d_new         = where(hgt1d_new.ge.500,hgt1d_new@_FillValue,hgt1d_new)
;  hgt1d_new_low_ind = ind(.not.ismissing(hgt1d_new))
;  dims1             = dimsizes(hgt1d_new_low_ind)
;  print("there are "+dims1+" points below 500m")

; make new 2d height array (newly interpolated)
  hgt2d_new = onedtond(hgt1d_new,(/n_sn,n_we/))
  hgt2d_new@lat2d = lat2d_2
  hgt2d_new@lon2d = lon2d_2
  copy_VarMeta(hgt2d_2,hgt2d_new)

; Assign lat and lon to original file (file2)
  hgt2d_2@lat2d = lat2d_2
  hgt2d_2@lon2d = lon2d_2

; make difference array
  diff = hgt2d_2 - hgt2d_new
  diff@lat2d = lat2d_2
  diff@lon2d = lon2d_2
  copy_VarMeta(hgt2d_2,diff)

  title0 = title1a+" and "+title2a            ; make a title string for the overlay plot
  title3 = title2a+" - "+title1a              ; make a title string for the difference plot

  print(title1a+" Terrain min: "+min(hgt2d_2)+"  max: "+max(hgt2d_2)) 
  print(title2a+" Terrain min: "+min(hgt2d_new)+"  max: "+max(hgt2d_new))
  print(title3+" Terrain min: "+min(diff)+"  max: "+max(diff))

;;;;;;;;;;
; Plotting
;;;;;;;;;;
 
;wks = gsn_open_wks("x11",fout)
  wks = gsn_open_wks("ps" ,fout)

  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"terrain.alice",additional_colors)

  plot = new(4, graphic)


; Set the contour interval for terrain
    cmin1 = 0.
    cmax1 = 4000.
    clev1 = 50.
    cmin2 = -1000.
    cmax2 = 1000.
    clev2 = 25.
    stride1             = 10                 ; label stride
    stride2             = 10                 ; label stride for diff plot
    spreadstart1        = 3                 ; start at color
    spreadend1          = 68                ; end at color
    spreadstart2        = 102                ; start at color - difference plot
    spreadend2          = 124               ; end at color
   
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  res@mpCenterLonF                = -36.              ; set the center lat/lon  ---changed by akd for Greenland
  res@mpCenterLatF                = 68.               ; -----changed by akd for Greenland
  res@mpLeftCornerLatF            = lat2d_2(0,0) ;-2       ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d_2(0,0)
  res@mpRightCornerLatF           = lat2d_2(n_sn-1,n_we-1) ;- 2
  res@mpRightCornerLonF           = lon2d_2(n_sn-1,n_we-1) 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
;  res@cnInfoLabelOn               = True              ; Turn off annotations 
  res@cnFillMode                  = "CellFill"
  
;;;;;;;;;;;;;
; Plot 1 - overlay contours
;;;;;;;;;;;;;
  ; SKIPPED BECAUSE IT WOULD LOOK WEIRD
 

;;;;;;;;;;;;;
; Plot 2 - fname1
;;;;;;;;;;;;;

  opts                            = res               ; reset options
  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = title1a            ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
  cplot2 = gsn_csm_contour_map(wks, hgt2d_new, opts)      ; create second plot
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;

; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2            ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, hgt2d_2, opts)      ; create fourth plot
  plot(3) = cplot4                              ; make panel section of this plot
  delete(opts)


;;;;;;;;;;;;;
; Plot 3 - difference 
;;;;;;;;;;;;; 

  opts                            = res
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = title3            ; set title for difference plot (title2-title1)
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

; changing some vector resources for difference plot

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  plot(0) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = "Terrain comparison between: "+title1a+" (interpolated) and "+title2a  

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
  delete(convert_cmd)
  delete(res)
  delete(pnlres)
  delete(diff)
  delete(opts)

;;;;;;;;;;;;;;;;;;;;;; END script
end
