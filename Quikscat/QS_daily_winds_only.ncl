;***************************************
; PROGRAM DESCRIPTION: This NCL script plots the quikscat winds on a day
; INPUT DATA: Quikscat text files, processed from Matlab, of ascending and descending passes
; OUTPUT DATA: Panel plot of ascending and descending data
; Note: No cshell is written to loop this. Inputs are specified manually below.
; CREATOR: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin

; MANUAL INPUTS
; set name of file you want:
dir1 = "/data3/duvivier/NCAR/Quikscat/qs_data/21FEB/"
date1 = "2007-03-21"
; set if this is a zoomed plot or the whole domain
zoom = False
whole_dom = True

; BEGINNING OF SCRIPT 
; set outdir and fout names
outdir = "./"
fout   = outdir+"Quikscat_"+date1

; load file:
 print("Loading Quikscat text files")

header = 0
; ncol = 110 ; for tj only   ; specified from Matlab data
ncol = 170
  
  f1_u_asc  = readAsciiTable(dir1+"Quikscat_asc_u.txt",ncol,"float",header)
  f1_v_asc  = readAsciiTable(dir1+"Quikscat_asc_v.txt",ncol,"float",header)

  f1_u_des  = readAsciiTable(dir1+"Quikscat_des_u.txt",ncol,"float",header)
  f1_v_des  = readAsciiTable(dir1+"Quikscat_des_v.txt",ncol,"float",header)

  speed_asc = sqrt(f1_u_asc^2+f1_v_asc^2)
  speed_des = sqrt(f1_u_des^2+f1_v_des^2)

  f1_time_asc = readAsciiTable(dir1+"Quikscat_asc_time.txt",ncol,"float",header)
  f1_time_des = readAsciiTable(dir1+"Quikscat_des_time.txt",ncol,"float",header)

  time_asc = round(avg(f1_time_asc)*24.,3)
  time_des = round(avg(f1_time_des)*24.,3)

  lat2d = readAsciiTable(dir1+"Quikscat_lat2d.txt",ncol,"float",header)
  lat1d = lat2d(:,0)
  lon2d = readAsciiTable(dir1+"Quikscat_lon2d.txt",ncol,"float",header)
  lon1d = lon2d(0,:)
  
  speed_asc!0 = "south_north"
  speed_asc!1 = "west_east"
  speed_asc@coordinates = "lat lon"
  speed_asc@units = "m s-1"
  speed_asc@long_name = "Total Wind Speed"
  speed_asc@lat2d = lat2d
  speed_asc@lon2d = lon2d

  copy_VarMeta(speed_asc, speed_des)
  copy_VarMeta(speed_asc, f1_u_asc)
  copy_VarMeta(speed_asc, f1_v_asc)
  copy_VarMeta(speed_des, f1_u_des)
  copy_VarMeta(speed_des, f1_v_des) 

; get the dimensions of our array.  we need this to set nice map limits
dimml = dimsizes(lat2d)
  nlat = dimml(0)
  nlon = dimml(1)
  print("Our dimensions are "+nlat+" by "+nlon)


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
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(2, graphic)

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
  
 if (isvar("whole_dom").and.(whole_dom))then
  res@mpLimitMode                 = "Corners"
  res@mpLeftCornerLatF            = lat2d(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d(0,0)
  res@mpRightCornerLatF           = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d(nlat-1,nlon-1)
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
  res@cnMissingValFillPattern     = 0                 ; fill in
  res@tiMainFontHeightF           = 0.013
  res@lbLabelBarOn                = False             ; turn off individual label bars

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
; Plot 0 - ascending pass
;;;;;;;;;;;;;

  opts0                            = res
  opts0@tiMainString               = "Ascending Pass - "+time_asc+" UTC"

  cplot0a = gsn_csm_contour_map(wks, speed_asc , opts0)      ; create ascending plot
    cplot0b = gsn_csm_vector(wks, f1_u_asc, f1_v_asc, vcres)
    overlay(cplot0a,cplot0b)
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - descending pass
;;;;;;;;;;;;;

  opts1                            = res
  opts1@tiMainString               = "Descending Pass - "+time_des+" UTC"

  cplot1a = gsn_csm_contour_map(wks, speed_des , opts1)      ; create descending plot
    cplot1b = gsn_csm_vector(wks, f1_u_des, f1_v_des, vcres)
    overlay(cplot1a,cplot1b)
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "Quikscat Satellite Winds using NASA DIRTH for "+date1

  pnlres                            = True
  pnlres@gsnPaperOrientation        = "landscape"       ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@txString                   = title_fin           ; set title for whole panel plot.
  pnlres@txFontHeightF              = 0.013

  ; set label bar resources
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbLabelStride              = stride
;  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
;  pnlres@pmLabelBarHeightF          = 0.075             ; set height of labelbar
;  pnlres@pmLabelBarWidthF           = 0.65

  ; set vector legend resources
;  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
;  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
;  pnlres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
;  pnlres@vcRefAnnoString1On         = True              ; turn on top vector label string
;  pnlres@vcRefAnnoString2           = "25 m/s"          ; label vector legend bottom string
;  pnlres@vcRefAnnoString2On         = True              ; turn on bottom vector label string


;return

  gsn_panel(wks,(/plot/),(/2,1/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

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
