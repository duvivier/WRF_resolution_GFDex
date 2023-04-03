;***************************************
; Alice DuVivier - Feb 2011: Modified fourpanel to regrid wrf domains and plot comparison plot 
; Output: comparison of resolution terrain and two text files of indicies and weights for interpolation
;
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
;for testing purposes
dir2 = "/data3/duvivier/NCAR/21FEB/wrf_10km/"
outdir = "./"
fname2 = "geo_em.d01"
title2 = "WRF_10"
varcode = "hgt"

; Check for input information:
  if(.not.any(isvar("dir2") \
              .and.isvar("fname2") \
              .and.isvar("title2") \
              .and.isvar("varcode") \
              )) then
    print("Can't find all input information!")
  end if

; update titles to remove underscores:
  title2a = str_sub_str(title2,"_"," ")

; set outdir and fout names
outdir = "./"
fout   = outdir+"terrain_AGU"


;;;;;;;;;;
; add data
;;;;;;;;;;

; Load higher resolution info lat/lon
  f2 = addfile(dir2 + fname2 + ".nc","r")
  hgt2d_2 = f2->HGT_M(0,:,:)
  lat2d_2 = f2->XLAT_M(0,:,:)
  lon2d_2 = f2->XLONG_M(0,:,:)

; Assign lat and lon to original file (file2)
  hgt2d_2@lat2d = lat2d_2
  hgt2d_2@lon2d = lon2d_2

  dims_2 = dimsizes(lat2d_2)     ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

;;;;;;;;;;
; Plotting
;;;;;;;;;;
 
;wks = gsn_open_wks("x11",fout)
  wks = gsn_open_wks("ps" ,fout)

  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"Terrain",additional_colors)

  plot = new(1, graphic)


; Set the contour interval for terrain
    cmin1 = 0.
    cmax1 = 3500.
    clev1 = 50.
    stride1             = 10                 ; label stride
    spreadstart1        = 1                  ; start at color
    spreadend1          = 100                ; end at color
   
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
; Add stuff for cross section line
;;;;;;;;;;;;;
  ; Irminger Sea
  lat0 = 63.
  lon0 = -35.
  ; Labrador Sea
  lat1 = 63.
  lon1 = -60.
  ; Greenland Sea
  lat2 = 75.
  lon2 = 0.
  ; Norwegian Sea
  lat3 = 67.
  lon3 = 0.
  ; Denmark Strait
  lat4 = 67.
  lon4 = -27. 
  ; Cape Farewell
  lat5 = 59.5
  lon5 = -41.
  ; Geikie Plateau
  lat6 = 69.
  lon6 = -23.3

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
   txres@txFontHeightF             = 0.01 

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
  opts@tiMainString               = "Terrain Height (m)" ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
  cplot2 = gsn_csm_contour_map(wks, hgt2d_2, opts)      ; create second plot

  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks, cplot2, "Irminger Sea", lon0, lat0, txres)

  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks, cplot2, "Labrador Sea", lon1, lat1, txres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot2, "Greenland Sea", lon2, lat2, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot2, "Norwegian Sea", lon3, lat3, txres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks, cplot2, "Denmark Strait", lon4, lat4, txres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks, cplot2, "Cape ~C~  Farewell", lon5, lat5, txres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks, cplot2, "Geikie ~C~ Plateau", lon6, lat6, txres)

  dum7 = new(1, graphic)      ; make dummy variable
  dum7 = gsn_add_polyline(wks,cplot2,(/box_min_lon,box_min_lon/), (/box_min_lat, box_max_lat/), lnres)
  
  dum8 = new(1, graphic)      ; make dummy variable
  dum8 = gsn_add_polyline(wks,cplot2,(/box_min_lon,box_max_lon/), (/box_max_lat, box_max_lat/), lnres)

  dum9 = new(1, graphic)      ; make dummy variable
  dum9 = gsn_add_polyline(wks,cplot2,(/box_max_lon,box_max_lon/), (/box_max_lat, box_min_lat/), lnres)

  dum10 = new(1, graphic)      ; make dummy variable
  dum10 = gsn_add_polyline(wks,cplot2,(/box_max_lon,box_min_lon/), (/box_min_lat, box_min_lat/), lnres)



  plot(0) = cplot2                              ; make panel section of this plot


 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = "WRF Model Simulations Full Domain (10km res.)"

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
  delete(opts)

;;;;;;;;;;;;;;;;;;;;;; END script
end
