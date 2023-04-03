;***************************************
; Plot Greenland Domains and grid point indicies
;
; Matt Higgins - 23 Nov 2010
; Alice DuVivier - Jan 2011
;
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin

  domain_title = "Multiple Grid Comparison of Greenland"

; 50km grid
  dir1           = "/data3/duvivier/NCAR/"
  outdir         = dir1
  fgeo1          = addfile(dir1+"50km/geo_em.d01.nc", "r")
  hgt1           = fgeo1->HGT_M(0,:,:)

  mpCenterLon    = fgeo1@STAND_LON

  lat2d_1        = fgeo1->XLAT_M(0,:,:)
  lon2d_1        = fgeo1->XLONG_M(0,:,:)
  dimll          = dimsizes(lat2d_1)
  nlat_1         = dimll(0)
  nlon_1         = dimll(1)
  hgt1@lat2d     = lat2d_1
  hgt1@lon2d     = lon2d_1

  print(max(hgt1))
  print(min(hgt1))

  maxvar = 2200.  ; what are these from?
  minvar = 0.
  clevels = fspan(minvar,maxvar,40)

; Plotting:

  wks = gsn_open_wks("ps" ,"green_d01+d02+d03")
;  wks = gsn_open_wks("x11" ,"green_d01+d02+d03")
  additional_colors = (/"gray85","yellow", "purple", "red", "blue"/)
  gsn_merge_colormaps(wks,"Terrain",additional_colors)

  cnres                            = True
  cnres@gsnFrame                   = False             ; Do not draw plot 
  cnres@gsnDraw                    = False             ; Do not advance fr
  cnres@gsnMaximize                = True    ; Maximize plot in frame

  cnres@cnLinesOn                   = False              ; contour lines
  cnres@cnMissingValFillColor       = "gray85"
  cnres@cnFillOn                    = True
  cnres@cnLineLabelsOn              = False             ; don't want labels
  cnres@cnInfoLabelOn               = False   ; Turn off annotations
  cnres@gsnAddCyclic                = False             ; regional - not cyclic
  cnres@gsnLeftString               = ""
  cnres@gsnRightString              = ""
  cnres@gsnSpreadColors             = True              ; use full colormap
  cnres@gsnSpreadColorEnd           = 99               ; end at color  
  cnres@gsnSpreadColorStart           = 3               ; end at color
  cnres@cnLevelSelectionMode        = "ExplicitLevels"
  cnres@cnLevels                    = clevels
  cnres@tiMainString                = domain_title
  cnres@lbLabelBarOn                = True
  cnres@tiMainFontHeightF           = 0.017
  cnres@lbLabelStride               = 4
  cnres@cnFillMode                  = "CellFill"    

  res                             = cnres
;  res                             = True
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  res@mpCenterLonF                = mpCenterLon       ; set the center lat/lon
  res@mpCenterLatF                = 60.               ; set the lat/lon sides

  res@mpLeftCornerLatF            = lat2d_1(0,0)
  res@mpLeftCornerLonF            = lon2d_1(0,0)
  res@mpRightCornerLatF           = lat2d_1(nlat_1-1,nlon_1-1)
  res@mpRightCornerLonF           = lon2d_1(nlat_1-1,nlon_1-1)

  ;res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  ;res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True
  res@mpGeophysicalLineColor      = "yellow" ; color of continents
  res@mpGeophysicalLineThicknessF = 0.75 ; make continents thinner
  res@pmTickMarkDisplayMode       = "Always"
  res@mpGridLatSpacingF           = 1
  res@mpGridLonSpacingF           = 1


  map = gsn_csm_contour_map(wks,hgt1, res)  ; create plot zero
  getvalues map@contour
    "cnLevels" : levels
  end getvalues
  res@lbLabelStrings = sprintf("%4.0f",levels)
  map = gsn_csm_contour_map(wks,hgt1, res)  ; create plot zero

;;;;;;;;;;;;;;;;;;;;;;;;;;;

; plot 25km domain:
  fgeo2                   = addfile(dir1+"/25km/geo_em.d01.nc", "r")
  lnres                   = True
  lnres@gsLineThicknessF  = 1.75
  lnres@gsLineColor       = "blue"

  lat2d_2        = fgeo2->XLAT_M(0,:,:)
  lon2d_2        = fgeo2->XLONG_M(0,:,:)
  dims2 = dimsizes(lat2d_2)

  hgt2           = fgeo2->HGT_M(0,:,:)
  hgt2@lat2d     = lat2d_2
  hgt2@lon2d     = lon2d_2

  print(max(hgt2))
  print(min(hgt2))

 ; res2 = cnres
 ; res2@lbLabelBarOn = False
 ; res2@gsnMaximize  = False

;  map2 = gsn_csm_contour(wks,hgt2, res2)  ; create plot zero
;  overlay(map,map2)

; plot blue outline of 25km domain
  dum8  = gsn_add_polyline(wks, map, lon2d_2(0,:), lat2d_2(0,:), lnres)
  dum9  = gsn_add_polyline(wks, map, lon2d_2(:,dims2(1)-1), lat2d_2(:,dims2(1)-1), lnres)
  dum10 = gsn_add_polyline(wks, map, lon2d_2(dims2(0)-1,:), lat2d_2(dims2(0)-1,:), lnres)
  dum11 = gsn_add_polyline(wks, map, lon2d_2(:,0), lat2d_2(:,0), lnres)



; plot 10km domain:
  fgeo3                   = addfile(dir1+"/10km/geo_em.d01.nc", "r")
  lnres                   = True
  lnres@gsLineThicknessF  = 1.75

  lat2d_3        = fgeo3->XLAT_M(0,:,:)
  lon2d_3        = fgeo3->XLONG_M(0,:,:)
  dims3 = dimsizes(lat2d_3)

  hgt3           = fgeo3->HGT_M(0,:,:)
  hgt3@lat2d     = lat2d_3
  hgt3@lon2d     = lon2d_3

  print(max(hgt3))
  print(min(hgt3))

 ; res3 = cnres
 ; res3@lbLabelBarOn = False
 ; res3@gsnMaximize  = False

;  map3 = gsn_csm_contour(wks,hgt3, res3)  ; create plot zero
;  overlay(map,map3)

; plot red outline of 1km domain
lnres@gsLineColor  = "red"

  dum22  = gsn_add_polyline(wks, map, lon2d_3(0,:), lat2d_3(0,:), lnres)
  dum23 = gsn_add_polyline(wks, map, lon2d_3(:,dims3(1)-1), lat2d_3(:,dims3(1)-1), lnres)
  dum24 = gsn_add_polyline(wks, map, lon2d_3(dims3(0)-1,:), lat2d_3(dims3(0)-1,:), lnres)
  dum25 = gsn_add_polyline(wks, map, lon2d_3(:,0), lat2d_3(:,0), lnres)

  draw(map)

;;;;;;;;;;;;;;;;;
;; Add gridpoints
;;;;;;;;;;;;;;;;;

gridpolyres               = True

gridpolyres@gsMarkerIndex = 1
gridpolyres@gsMarkerSizeF = 0.010
gridpolyres@gsMarkerColor = "black"

i=0
do while(i.le.73)
 j=0
 do while(j.le.68)
  gsn_polymarker(wks,map,lon2d_1(i,j),lat2d_1(i,j),gridpolyres)
  j=j+5
end do
 i=i+5
end do

textres               = True
textres@txFontHeightF = 0.005 

i=0
do while(i.le.73)
 j=0
 do while(j.le.68)
  ;text = i+","+j
  ;print(text)
  gsn_text(wks,map,i+","+j,lon2d_1(i,j),lat2d_1(i,j),textres)
  j=j+5
end do
 i=i+5
end do

; Second grid markers
gridpolyres@gsMarkerColor = "blue"

i=0
do while(i.le.146)
 j=0
 do while(j.le.136)
  gsn_polymarker(wks,map,lon2d_2(i,j),lat2d_2(i,j),gridpolyres)
  j=j+5
end do
 i=i+5
end do

; Third grid markers
gridpolyres@gsMarkerColor = "red"

i=0
do while(i.le.360)
 j=0
 do while(j.le.335)
  gsn_polymarker(wks,map,lon2d_3(i,j),lat2d_3(i,j),gridpolyres)
  j=j+5
end do
 i=i+5
end do


  frame(wks)

  convert_cmd = "convert -density 300 green_d01+d02+d03.ps -trim -bordercolor white -border 10 green_d01+d02+d03.png"
  system(convert_cmd)

  

end
