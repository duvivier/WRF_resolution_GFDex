;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and 100km spacing
; OUTPUT DATA: plot of the terrain at 10km and labels for locations,
;              difference plot of wrf100 and wrf10 terrain height along southeast coast.
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; MANUAL INPUTS
; (area of influence for weighting)
cressrad      = 95.  ; cressman radius in km (100->10km)

; inputs for file
dir1 = "/data3/duvivier/NCAR/DATA/geo_em/"
dir2 = "/data3/duvivier/NCAR/DATA/geo_em/"
outdir = "./"
fname1 = "geo_em.d01_100km"     ; file with original grid
fname2 = "geo_em.d01_10km"     ; file with grid to interpolate to
title1 = "WRF_100"
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

;;;;;;;
; counter
;;;;;;;

    if(i%100.eq.0) then
      print("created weighting "+i+" of "+n_tot)
    end if

    index = index + 1                             ; increase the index
  end do

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
  wks = gsn_open_wks("ps" ,fout)

  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"terrain.alice",additional_colors)

  plot = new(2, graphic)


; Set the contour interval for terrain only plot
    cmin1               = 0.
    cmax1               = 3500.
    clev1               = 50.
    ;cmin2               = -1000.
    ;cmax2               = 1000.
    ;clev2               = 100.  
    cmin2               = -500.
    cmax2               = 500.
    clev2               = 25.
    stride1             = 10                 ; label stride for terrain plot
    stride2             = 5                 ; label stride for diff plot
    spreadstart1        = 1                  ; start at color
    spreadend1          = 100                ; end at color
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
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---changed by akd for Greenland
  res@mpCenterLatF                = 60.               ; -----changed by akd for Greenland
 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
  res@cnFillMode                  = "AreaFill"
  res@lbLabelFontHeightF          = 0.015              ; label bar font size

;;;;;;;;;;;;;
; Add stuff for cross section line
;;;;;;;;;;;;;
  ; Irminger Sea
  lat0 = 63.5
  lon0 = -34.
  ; Labrador Sea
  lat1 = 63.
  lon1 = -59.
  ; Greenland Sea
  lat2 = 75.
  lon2 = 0.
  ; Norwegian Sea
  lat3 = 67.
  lon3 = -3.
  ; Denmark Strait
  lat4 = 66.5
  lon4 = -26.25 
  ; Cape Farewell
  lat5 = 59.0
  lon5 = -40.
  ; Geikie Plateau
  lat6 = 69.0
  lon6 = -23.

  box_min_lat = 56.0
  box_max_lat = 70.0
  box_min_lon = -54.0
  box_max_lon = -20.0

; set line res to show cross section line
  lnres                            = True
   lnres@gsLineThicknessF          = 2.0
   lnres@gsLineColor               = "black"

; set text res to show start and end of cross section
   txres                           = True
   txres@txFontHeightF             = 0.013 
   txres@txFontThicknessF          = 2.0

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  opts@mpLeftCornerLatF            = lat2d_2(0,0)     ; set the lat/lon sides
  opts@mpLeftCornerLonF            = lon2d_2(0,0)
  opts@mpRightCornerLatF           = lat2d_2(n_sn-1,n_we-1) ;- 2
  opts@mpRightCornerLonF           = lon2d_2(n_sn-1,n_we-1)

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
  opts@tiMainString               = "a)    Terrain Height (m): " + title2a  ; title string 
  opts@tiMainFontHeightF          = 0.014
  opts@tiMainFontThicknessF       = 1.5
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
  cplot0 = gsn_csm_contour_map(wks, hgt2d_2, opts)      ; create second plot

  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks, cplot0, "Irminger ~C~ Sea", lon0, lat0, txres)

  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks, cplot0, "Labrador ~C~ Sea", lon1, lat1, txres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot0, "Greenland ~C~ Sea", lon2, lat2, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot0, "Norwegian ~C~ Sea", lon3, lat3, txres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks, cplot0, "Denmark ~C~  Strait", lon4, lat4, txres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks, cplot0, "Cape ~C~  Farewell", lon5, lat5, txres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks, cplot0, "Geikie ~C~ Plateau", lon6, lat6, txres)

;  dum7 = new(1, graphic)      ; make dummy variable
;  dum7 = gsn_add_polyline(wks,cplot0,(/box_min_lon,box_min_lon/), (/box_min_lat, box_max_lat/), lnres)
;  
;  dum8 = new(1, graphic)      ; make dummy variable
;  dum8 = gsn_add_polyline(wks,cplot0,(/box_min_lon,box_max_lon/), (/box_max_lat, box_max_lat/), lnres)
;
;  dum9 = new(1, graphic)      ; make dummy variable
;  dum9 = gsn_add_polyline(wks,cplot0,(/box_max_lon,box_max_lon/), (/box_max_lat, box_min_lat/), lnres)
;
;  dum10 = new(1, graphic)      ; make dummy variable
;  dum10 = gsn_add_polyline(wks,cplot0,(/box_max_lon,box_min_lon/), (/box_min_lat, box_min_lat/), lnres)

  plot(0) = cplot0                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - terrain difference
;;;;;;;;;;;;;
; for the different plots
  opts2                             = res
  opts2@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  opts2@mpLeftCornerLatF            = lat2d_2(0,0)     ; set the lat/lon sides
  opts2@mpLeftCornerLonF            = lon2d_2(0,0)
  opts2@mpRightCornerLatF           = lat2d_2(n_sn-1,n_we-1) ;- 2
  opts2@mpRightCornerLonF           = lon2d_2(n_sn-1,n_we-1)

  ;opts2@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  ;opts2@mpMinLatF                   = 56.              ; set the minimum latitude 
  ;opts2@mpMaxLatF                   = 70.              ; set the maximum latitude 
  ;opts2@mpMinLonF                   = -54.0            ; set the minimum longitude 
  ;opts2@mpMaxLonF                   = -20.0            ; set the maximum longitude

  opts2@cnFillOn                   = True              ; turn on filled contours
  opts2@gsnSpreadColors            = True              ; use full colormap
  opts2@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  opts2@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts2@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts2@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts2@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts2@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts2@cnMissingValFillColor      = "gray85"          ; missing value color
  opts2@cnMissingValFillPattern    = 0                 ; fill in
  opts2@tiMainString               = "b)   Terrain Height Difference (m) : " + title3
  opts2@tiMainFontHeightF          = 0.014
  opts2@tiMainFontThicknessF       = 1.5
  opts2@lbLabelStride              = stride2
  opts2@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts2@pmLabelBarHeightF          = 0.075             ; set height of labelbar

  cplot1 = gsn_csm_contour_map(wks, diff, opts2)
  plot(1) = cplot1

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
 ;  title5 = "WRF Model Simulations Full Domain"

  pnlres                            = True
  ;pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,2/),pnlres)               ; create final panel plot
  
  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)
  delete(opts)

;;;;;;;;;;;;;;;;;;;;;; END script
end
