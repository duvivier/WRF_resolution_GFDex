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
cressrad      = 70.7  ; cressman radius in km (100->10km)

; inputs for file
dir1 = "/data3/duvivier/CASE_STUDY/change_terrain_wrf10/"
outdir = "./"
fname1 = "geo_em.d01_100km"     ; file with original grid
fname2 = "geo_em.d01_10km"     ; file with grid to interpolate to
title1 = "WRF_100"
title2 = "WRF_10"
varcode = "hgt"

; BEGIN SCRIPT

; set outdir and fout names
outdir = "./"
fout   = outdir+"geo_em.d01_new"

title1a = "WRF10 with 100km terrain"
title2a = "WRF10"

;;;;;;;;;;
; add data
;;;;;;;;;;

; Load lower resolution topography:
  f1 = addfile(dir1 + fname1 + ".nc","r")
  hgt2d_1_M = f1->HGT_M(0,:,:)
  hgt2d_1_U = f1->HGT_U(0,:,:)
  hgt2d_1_V = f1->HGT_V(0,:,:)
  lat2d_1_M = f1->XLAT_M(0,:,:)
  lon2d_1_M = f1->XLONG_M(0,:,:)
  lat2d_1_U = f1->XLAT_U(0,:,:)
  lon2d_1_U = f1->XLONG_U(0,:,:)
  lat2d_1_V = f1->XLAT_V(0,:,:)
  lon2d_1_V = f1->XLONG_V(0,:,:)  

  ; convert arrays to 1D for regridding
  lat1d_1_M = ndtooned(lat2d_1_M) 
  lon1d_1_M = ndtooned(lon2d_1_M)
  lat1d_1_U = ndtooned(lat2d_1_U) 
  lon1d_1_U = ndtooned(lon2d_1_U)
  lat1d_1_V = ndtooned(lat2d_1_V) 
  lon1d_1_V = ndtooned(lon2d_1_V)
  hgt1d_1_M = ndtooned(hgt2d_1_M)
  hgt1d_1_U = ndtooned(hgt2d_1_U)
  hgt1d_1_V = ndtooned(hgt2d_1_V)

; Load higher resolution info lat/lon
  f2 = addfile(dir1 + fname2 + ".nc","r")
  hgt2d_2_M = f2->HGT_M(0,:,:)
  hgt2d_2_U = f2->HGT_U(0,:,:)
  hgt2d_2_V = f2->HGT_V(0,:,:)
  lat2d_2_M = f2->XLAT_M(0,:,:)
  lon2d_2_M = f2->XLONG_M(0,:,:)
  lat2d_2_U = f2->XLAT_U(0,:,:)
  lon2d_2_U = f2->XLONG_U(0,:,:)
  lat2d_2_V = f2->XLAT_V(0,:,:)
  lon2d_2_V = f2->XLONG_V(0,:,:) 

  lat1d_2_M = ndtooned(lat2d_2_M) 
  lon1d_2_M = ndtooned(lon2d_2_M)
  lat1d_2_U = ndtooned(lat2d_2_U) 
  lon1d_2_U = ndtooned(lon2d_2_U)
  lat1d_2_V = ndtooned(lat2d_2_V) 
  lon1d_2_V = ndtooned(lon2d_2_V)

  ; make dummy array for fill value
  dum = new((/1/),"float")
  fill = dum@_FillValue


; Create array to interpolate terrain to
  hgt2d_new_M = new(dimsizes(hgt2d_2_M), "float") 
  hgt1d_new_M = ndtooned(hgt2d_new_M)

  hgt2d_new_U = new(dimsizes(hgt2d_2_U), "float") 
  hgt1d_new_U = ndtooned(hgt2d_new_U)

  hgt2d_new_V = new(dimsizes(hgt2d_2_V), "float") 
  hgt1d_new_V = ndtooned(hgt2d_new_V)

  dims= dimsizes(hgt2d_2_M)     ; get lat/lon dimensions from second domain
  n_sn = dims(0)              ; get south/north points
  n_we = dims(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

;;;;;;;;;;
; regrid the WRF10 terrain(M points)
;;;;;;;;;;
print("Looping through 10km points and calculating new height - M points")
; Create array to interpolate terrain to
  hgt2d_new_M = new(dimsizes(hgt2d_2_M), "float") 
  hgt1d_new_M = ndtooned(hgt2d_new_M)

  dims= dimsizes(hgt2d_2_M)     ; get lat/lon dimensions from second domain
  n_sn = dims(0)              ; get south/north points
  n_we = dims(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

; run loop
  index = 0          ; set first index
  do i = 0, n_tot-1

   ; get great circle distance between the different grids in km
     dist = gc_latlon(lat1d_2_M(i),lon1d_2_M(i),lat1d_1_M,lon1d_1_M,2,4) 

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist))) then       
      nreplacements = num(isnan_ieee(dist))  ; find index of NaN
      replace_ieeenan(dist,fill,0)             ; replace the NaN with 0
     ; print that there were replacements made
      print("replaced "+nreplacements+" NaN(s) with fill value at i = "+i) 
    end if

    ; set index to be the 100km grid point nearest to the 10km point
    min_dist = min(dist)
    ;print("Minimum distance: "+min_dist)
    indicies = ind(dist.eq.min_dist)
    ind0 = indicies(0)  ; in case there is more than one point

    ; set new 10km height that is equal to the height from 100km resolution
    hgt1d_new_M(i) = hgt1d_1_M(ind0)

    ; delete variables needed for next loop
    delete(ind0)
    delete(indicies)
    delete(min_dist)
    delete(dist)

    ; counter
    if(i%100.eq.0) then
      print("new terrain for "+i+" of "+n_tot)
    end if

    index = index + 1                             ; increase the index
  end do

  ; make new 2d height array (newly interpolated)
  hgt2d_new_M = onedtond(hgt1d_new_M,(/n_sn,n_we/))
  ; make new 3d array that matches orig size
  hgt_new_M = new((/1,n_sn,n_we/),"float") 
  hgt_new_M(0,:,:)=hgt2d_new_M

  delete(dims)
  delete(n_sn)
  delete(n_we)
  delete(n_tot)

;;;;;;;;;;
; regrid the WRF10 terrain(U points)
;;;;;;;;;;
print("Looping through 10km points and calculating new height - U points")
; Create array to interpolate terrain to
  hgt2d_new_U = new(dimsizes(hgt2d_2_U), "float") 
  hgt1d_new_U = ndtooned(hgt2d_new_U)

  dims= dimsizes(hgt2d_2_U)     ; get lat/lon dimensions from second domain
  n_sn = dims(0)              ; get south/north points
  n_we = dims(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

; run loop
  index = 0          ; set first index
  do i = 0, n_tot-1

   ; get great circle distance between the different grids in km
     dist = gc_latlon(lat1d_2_U(i),lon1d_2_U(i),lat1d_1_U,lon1d_1_U,2,4) 

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist))) then       
      nreplacements = num(isnan_ieee(dist))  ; find index of NaN
      replace_ieeenan(dist,fill,0)             ; replace the NaN with 0
     ; print that there were replacements made
      print("replaced "+nreplacements+" NaN(s) with fill value at i = "+i) 
    end if

    ; set index to be the 100km grid point nearest to the 10km point
    min_dist = min(dist)
    ;print("Minimum distance: "+min_dist)
    indicies = ind(dist.eq.min_dist)
    ind0 = indicies(0)  ; in case there is more than one point

    ; set new 10km height that is equal to the height from 100km resolution
    hgt1d_new_U(i) = hgt1d_1_U(ind0)

    ; delete variables needed for next loop
    delete(ind0)
    delete(indicies)
    delete(min_dist)
    delete(dist)

    ; counter
    if(i%100.eq.0) then
      print("new terrain for "+i+" of "+n_tot)
    end if

    index = index + 1                             ; increase the index
  end do

  ; make new 2d height array (newly interpolated)
  hgt2d_new_U = onedtond(hgt1d_new_U,(/n_sn,n_we/))
  ; make new 3d array that matches orig size
  hgt_new_U = new((/1,n_sn,n_we/),"float") 
  hgt_new_U(0,:,:)=hgt2d_new_U

  delete(dims)
  delete(n_sn)
  delete(n_we)
  delete(n_tot)

;;;;;;;;;;
; regrid the WRF10 terrain(V points)
;;;;;;;;;;
print("Looping through 10km points and calculating new height - V points")
; Create array to interpolate terrain to
  hgt2d_new_V = new(dimsizes(hgt2d_2_V), "float") 
  hgt1d_new_V = ndtooned(hgt2d_new_V)

  dims= dimsizes(hgt2d_2_V)     ; get lat/lon dimensions from second domain
  n_sn = dims(0)              ; get south/north points
  n_we = dims(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

; run loop
  index = 0          ; set first index
  do i = 0, n_tot-1

   ; get great circle distance between the different grids in km
     dist = gc_latlon(lat1d_2_V(i),lon1d_2_V(i),lat1d_1_V,lon1d_1_V,2,4) 

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist))) then       
      nreplacements = num(isnan_ieee(dist))  ; find index of NaN
      replace_ieeenan(dist,fill,0)             ; replace the NaN with 0
     ; print that there were replacements made
      print("replaced "+nreplacements+" NaN(s) with fill value at i = "+i) 
    end if

    ; set index to be the 100km grid point nearest to the 10km point
    min_dist = min(dist)
    ;print("Minimum distance: "+min_dist)
    indicies = ind(dist.eq.min_dist)
    ind0 = indicies(0)  ; in case there is more than one point

    ; set new 10km height that is equal to the height from 100km resolution
    hgt1d_new_V(i) = hgt1d_1_V(ind0)

    ; delete variables needed for next loop
    delete(ind0)
    delete(indicies)
    delete(min_dist)
    delete(dist)

    ; counter
    if(i%100.eq.0) then
      print("new terrain for "+i+" of "+n_tot)
    end if

    index = index + 1                             ; increase the index
  end do

  ; make new 2d height array (newly interpolated)
  hgt2d_new_V = onedtond(hgt1d_new_V,(/n_sn,n_we/))
  ; make new 3d array that matches orig size
  hgt_new_V = new((/1,n_sn,n_we/),"float") 
  hgt_new_V(0,:,:)=hgt2d_new_V

  delete(dims)
  delete(n_sn)
  delete(n_we)
  delete(n_tot)

;;;;;;;;;;;;
; Write new geo_em height field
;;;;;;;;;;;;;
  ; reload geo_em file to re-write the hgt fields
  fnew = addfile(dir1 + fname2 + ".nc","w")
  fnew->HGT_M(0,:,:)=(/hgt_new_M/)
  fnew->HGT_U(0,:,:)=(/hgt_new_U/)
  fnew->HGT_V(0,:,:)=(/hgt_new_V/)

;;;;;;  
; Get data for plotting
;;;;;;
  ; assign lat and lon to new file
  hgt2d_new_M@lat2d = lat2d_2_M
  hgt2d_new_M@lon2d = lon2d_2_M
  copy_VarMeta(hgt2d_2_M,hgt2d_new_M)

; Assign lat and lon to original file (file2)
  hgt2d_2_M@lat2d = lat2d_2_M
  hgt2d_2_M@lon2d = lon2d_2_M

; make difference array
  diff = hgt2d_2_M - hgt2d_new_M
  diff@lat2d = lat2d_2_M
  diff@lon2d = lon2d_2_M
  copy_VarMeta(hgt2d_2_M,diff)

  title0 = title1a+" and "+title2a            ; make a title string for the overlay plot
  title3 = title2a+" - "+title1a              ; make a title string for the difference plot

  print(title1a+" Terrain min: "+min(hgt2d_2_M)+"  max: "+max(hgt2d_2_M)) 
  print(title2a+" Terrain min: "+min(hgt2d_new_M)+"  max: "+max(hgt2d_new_M))
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
      
  cplot2 = gsn_csm_contour_map(wks, hgt2d_new_M, opts)      ; create second plot
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;

; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2            ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, hgt2d_2_M, opts)      ; create fourth plot
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
