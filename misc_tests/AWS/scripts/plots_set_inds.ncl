;***************************************
; PROGRAM DESCRIPTION: This NCL script finds indicies of WRF cells near
;             AWS lat and lons
; INPUT DATA: One WRF output files at native resolution
; OUTPUT DATA: Plot of AWS locations and grid cells at resolution
; NOTE: This script differs from 'plots_find_inds.ncl' because the 
;       WRF indicies have been shifted to better match terrain elevation
; CREATOR: Alice DuVivier - October 2010
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; below codes are for testing purposes
dir1 = "/data3/duvivier/NCAR/21FEB/wrf_25km/"
fname1 = "wrf-2007-02"
shrt_t1 = "wrf_25"          

; set outdir and fout names
outdir = "./"
fout   = outdir+shrt_t1+"_AWS_locs2"
zoom = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  f1 = addfile(dir1 + fname1 + ".nc","r")
; get lat and lon data
  lat2d  = f1->lat
  lon2d  = f1->lon
  dimll  = dimsizes(lat2d)
  nlat   = dimll(0)
  nlon   = dimll(1)

 ; load terrain height (m)
  hgt = f1->Z_sfc
  hgt@lat2d = lat2d
  hgt@lon2d = lon2d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set AWS locations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AWS_lats = (/60.050, 61.933, 59.983, 60.717, 61.167/)
AWS_lons = (/-43.167, -42.067, -45.2, -46.05, -45.417/)
AWS_locs = (/"PrC", "Ike", "Ang", "Qaq", "Nar"/)
AWS_elev = (/"75m", "39m" , "16m", "34m", "31m"/)
AWS_elevs = "AWS "+AWS_elev

key_lats = (/62., 61., 60.,59., 58./)
key_lons = (/-54., -54., -54., -54., -54./)

n_stn = dimsizes(AWS_lats)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lat/Lon index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Narrow down data to particular lat/lon position for evaluation
; Lat and lon are uploaded from cshell script

inds = new((/n_stn,2/),"integer")

if ( shrt_t1 .eq. "wrf_100") then
  inds(:,0) = (/9, 11, 9, 10, 10/)
  inds(:,1) = (/13, 14, 11, 10, 11/)
end if
if ( shrt_t1 .eq. "wrf_50") then
  inds(:,0) = (/20, 23, 19, 20, 22/)
  inds(:,1) = (/26, 28, 23, 23, 24/)
end if
if ( shrt_t1 .eq. "wrf_25") then
  inds(:,0) = (/38, 47, 39, 42, 44/)
  inds(:,1) = (/51, 55, 46, 46, 47/)
end if
if ( shrt_t1 .eq. "wrf_10") then
  inds(:,0) = (/95, 116, 97, 105, 109/)
  inds(:,1) = (/128, 138, 117, 115, 118/)
end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WRF lat/lon arrays
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WRF_lats = new((/n_stn/),"float")
WRF_lons = new((/n_stn/),"float")
WRF_elev = new((/n_stn/),"float")

do j = 0,n_stn-1

  WRF_lats(j) = lat2d({south_north|inds(j,0)},{west_east|inds(j,1)})
  WRF_lons(j)= lon2d({south_north|inds(j,0)},{west_east|inds(j,1)})
  
  WRF_elev(j) = hgt({south_north|inds(j,0)},{west_east|inds(j,1)})
  
end do

  WRF_elevs = "WRF "+flt2string(WRF_elev)+"m"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Make plot of height and location of AWS and WRF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","forestgreen"/)
  gsn_merge_colormaps(wks,"Terrain",additional_colors)
  clevels = ispan(0,200,5)

  plot = new(1, graphic)

; set contour resources
  cnres                            = True

    cnres@gsnFrame                    = False             ; Do not draw plot 
    cnres@gsnDraw                     = False             ; Do not advance fr
    cnres@gsnAddCyclic                = False             ; regional - not cyclic 
    cnres@gsnMaximize                 = True

    cnres@cnLinesOn                   = False              ; contour lines
    cnres@cnFillOn                    = True
    cnres@cnLineLabelsOn              = False             ; don't want labels
    cnres@cnInfoLabelOn               = False   ; Turn off annotations
    cnres@gsnAddCyclic                = False             ; regional - not cyclic
    cnres@gsnSpreadColors             = True              ; use full colormap
    cnres@gsnSpreadColorEnd           = 99               ; end at color  
    cnres@gsnSpreadColorStart           = 3               ; end at color
    cnres@cnLevelSelectionMode        = "ExplicitLevels"
    cnres@cnLevels                    = clevels
    cnres@tiMainString                = "AWS location "+shrt_t1
    cnres@lbLabelBarOn                = True
    cnres@tiMainFontHeightF           = 0.017
    cnres@lbLabelStride               = 4
    cnres@cnFillMode                  = "RasterFill"    

    cnres@mpProjection                = "Stereographic"   ; map projection
    cnres@mpCenterLonF                = -40.              ; set the center lat/lon
    cnres@mpCenterLatF                = 60.               ; set the lat/lon sides

 if (isvar("zoom").and.(zoom))then
  cnres@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  cnres@mpMinLatF                   = 58.              ; set the minimum latitude
  cnres@mpMaxLatF                   = 64.              ; set the maximum latitude
  cnres@mpMinLonF                   = -55.0            ; set the minimum longitude
  cnres@mpMaxLonF                   = -40.0            ; set the maximum longitude
else
  cnres@mpLimitMode                 = "Corners"         ; how to zoom in on map
  cnres@mpLeftCornerLatF            = lat2d(0,0)
  cnres@mpLeftCornerLonF            = lon2d(0,0)
  cnres@mpRightCornerLatF           = lat2d(nlat-1,nlon-1)
  cnres@mpRightCornerLonF           = lon2d(nlat-1,nlon-1)   
 end if

  ;res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  ;res@mpGridLineDashPattern       = 2                 ; Change dash pattern    
    cnres@mpFillOn                    = True
    cnres@mpGeophysicalLineColor      = "black" ; color of continents
    cnres@mpGeophysicalLineThicknessF = 0.75 ; make continents thinner
    cnres@pmTickMarkDisplayMode       = "Always"
    cnres@mpGridLatSpacingF           = 1
    cnres@mpGridLonSpacingF           = 1

; set poly marker resources for AWS and WRF points
   polyres1                         = True
   polyres1@gsMarkerIndex           = 16               ; polymarker style
   polyres1@gsMarkerSizeF           = 6.               ; polymarker size
   polyres1@gsMarkerColor           = "black"          ; polymarker color

   polyres2                         = True
   ;polyres2@gsMarkerIndex           = 16               ; polymarker style
   polyres2@gsMarkerSizeF           = 6.               ; polymarker size
   polyres2@gsMarkerColor           = "black"          ; polymarker color


; set poly text resources

   txres                           = True
   txres@txFontHeightF             =0.01

  map = gsn_csm_contour_map(wks,hgt, cnres)  ; create plot zero

  ; add in poly markers and text
  dum1 = new(1, graphic)
  dum1 = gsn_add_polymarker(wks, map, WRF_lons, WRF_lats, polyres1)
  
  dum2 = new(1, graphic)
  dum2 = gsn_add_polymarker(wks, map, AWS_lons, AWS_lats, polyres2)

  dum3 = new(n_stn, graphic)
  dum3 = gsn_add_text(wks, map, AWS_locs, AWS_lons-.5, AWS_lats, txres)

  dum4 = new(n_stn, graphic)
  dum4 = gsn_add_text(wks, map, AWS_locs, key_lons, key_lats, txres)

  dum5 = new(n_stn, graphic)
  dum5 = gsn_add_text(wks, map, AWS_elevs, key_lons, key_lats-.3, txres)

  dum6 = new(n_stn, graphic)
  dum6 = gsn_add_text(wks, map, WRF_elevs, key_lons, key_lats-.66, txres)

  plot(0) = map



; create final plot
  pnlres                            = True
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

;  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png";
  system(convert_cmd)

  
end





