;***************************************
; PROGRAM DESCRIPTION: This NCL script plots the 95th percentile wind values
;             from longterm QuikSCAT files
; INPUT DATA: QuikSCAT files concatenated into monthly files
; OUTPUT DATA: Plot of 95th percent value at native resolution
; Note: This script is designed to find the 95th percentile WIND values
; CREATOR: Alice DuVivier - February 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
;for testing purposes
dir1 = "/data3/duvivier/NCAR/Quikscat/"
fname1 = "Quikscat_FebMar_2007"
varcode = "Windsurf"

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_longterm_95_QuikSCAT"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

  print("Running longterm 95 Quikscat")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information

 if (varcode.eq."Windsurf") then
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u"
    invar11 ="v"
    vartype = "2d"
    cmaptype = "wind"
    units0 = "m s-1"
    find_speed = True
    met_not_avail = True  ; wind data not in met
 end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin1 = 0
    cmax1 = 32.
    clev1 = 4.
    stride1             = 1                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 254                ; end at color
    colormap            = "WhiteYellowOrangeRed"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

;; Quikscat file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load first wrf file
  var1   = f1->$invar1$
  var11  = f1->$invar11$
  
  lat2d = f1->lat2d
  lon2d = f1->lon2d
  dims1 = dimsizes(var1)
  nlon = dims1(0)
  nlat = dims1(1)
  ntime = dims1(2)

  var1@lat2d = lat2d
  var1@lon2d = lon2d
  var1@_FillValue = -999

  copy_VarMeta(var1, var11)

  spd = sqrt(var1^2 + var11^2)
  copy_VarMeta(var1, spd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Performing data processing: averaging")

;; SET THE LIMIT FOR HOW MANY GOOD OR BAD OBS HERE
; need to only average when there are enough values
; 25% of obs --> 30 "good" data points, 88 "bad
;  lim = 88
; 50% of obs --> 59 "good" data points, 59 "bad"
  lim = 59
; 75% of obs --> 89 "good" data points, 29 "bad"
;  lim = 29
; 90% of obs --> 106 "good" data points, 12 "bad"
;  lim = 12


;;;;;;;;;;;;;
; Get 95th percentiles of variables
;;;;;;;;;;;;

  ; find 95% highest values
print("finding 95% value for file1")
  var1_95 = new((/nlon, nlat/), "double")
  var1_95@_FillValue = -999
  var11_95 = new((/nlon, nlat/), "double")
  var11_95@_FillValue = -999
  spd_95 = new((/nlon, nlat/), "double")
  spd_95@_FillValue = -999


  do i = 0, nlon - 1
    do j = 0, nlat - 1
      dum1 = var1(i,j,:)
      bad = ind(ismissing(dum1))
      len = dimsizes(bad)
      dum2 = var11(i,j,:)
      dum3 = spd(i,j,:)

      if (len .gt. lim) then
        var1_95(i,j) = -999
        var11_95(i,j) = -999
        spd_95(i,j) = -999
      else
        qsort(dum1)
        qsort(dum2)
        qsort(dum3)

        inds = ind(dum1 .ne. -999)
        nind = dimsizes(inds)
        tmp0 = ((95./100.) * nind) + 0.5  ; make sure it is over 95% value
        tmp1 = round(tmp0, 3) - 1         ; take away 1 (make sure it isn't bigger than array)
        tmp2 = ((5./100.) * nind) - 0.5   ; make sure it is 5% or lower
        tmp3 = round(tmp2, 3)             ; make sure it isn't negative

        ; do stuff for vectors only        
        data1 = dum1(inds)
        data2 = dum2(inds)

        a = abs(data1(tmp1)) ; get 95% value of u
        b = abs(data1(tmp3)) ; get 5% value of u
        aa = abs(data2(tmp1)) ; get 95% value of v
        bb = abs(data2(tmp3)) ; get 5% value of v
       
        if (a .gt. b) then
          var1_95(i,j) = data1(tmp1)
        else
          var1_95(i,j) = data1(tmp3)
        end if

        if (aa .gt. bb) then
          var11_95(i,j) = data2(tmp1)
        else
          var11_95(i,j) = data2(tmp3)
        end if  
 
        delete(a)
        delete(aa)
        delete(b)
        delete(bb)

        ; do stuff for speed only
        data3 = dum3(inds)
        spd_95(i,j) = data3(tmp1)

        delete(inds)
        delete(nind)
        delete(tmp0)
        delete(tmp1)
        delete(tmp2)
        delete(tmp3)
        delete(data1)
        delete(data2)
        delete(data3)
      end if

      delete(dum1)
      delete(dum2)
      delete(dum3)
      delete(bad)
      delete(len)
    end do
  end do

; assign meta data
copy_VarMeta(var1, var1_95)
copy_VarMeta(var11, var11_95)
copy_VarMeta(spd, spd_95)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; plot averages only
  print("Processing monthly average graphs for " + varcode)

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")
  plot = new(1, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

 res                             = True              ; plot mods desired

 ; set general domain resources
  ;res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set for Greenland
  res@mpCenterLatF                = 60.               ; -----set for Greenland

  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude
  res@mpMaxLatF                   = 70.              ; set the maximum latitude
  res@mpMinLonF                   = -54.0            ; set the minimum longitude
  res@mpMaxLonF                   = -20.0            ; set the maximum longitude

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5               ; Continent line thickness


  ; set contour resources for fluxes
  flres                             = res
  
  flres@cnFillMode                  = cntype
  flres@cnFillOn                    = True              ; turn on filled contours
  flres@gsnSpreadColors             = True              ; use full colormap
  flres@gsnSpreadColorStart         = spreadstart1      ; start at color specified 
  flres@gsnSpreadColorEnd           = spreadend1        ; end at color specified 
  flres@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  flres@cnMinLevelValF              = cmin1             ; set min contour level specified above
  flres@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  flres@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  flres@cnLinesOn                   = plotlines        ; contour lines specified above
  flres@cnLineLabelsOn              = plotlines        ; line labels on specified above
  flres@cnMissingValFillColor       = "grey"          ; missing value color
  flres@cnMissingValFillPattern     = 0                 ; fill in
  flres@tiMainFontHeightF           = 0.013
  flres@lbLabelBarOn                = False             ; turn off individual label bars

 ; set vector resources 
  vcres                            = True
  vcres@gsnRightString             = ""
  vcres@gsnLeftString              = ""
  vcres@gsnFrame                   = False             ; Do not draw plot 
  vcres@gsnDraw                    = False             ; Do not advance fr
  vcres@gsnAddCyclic               = False             ; regional - not cyclic 
  vcres@vcGlyphStyle               = "LineArrow"
  vcres@vcRefMagnitudeF            = 20.               ; set vector reference magnitude
  vcres@vcRefLengthF               = 0.03              ; length of vector (larger = longer)
  vcres@vcMinDistanceF             = 0.04              ; vector spacing (smaller = more dense)
  vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder
 
 ; set vector legend resources
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "20 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string

;;;;;;;;;;;;;
; Plot 0 - WRF 10km plot
;;;;;;;;;;;;;

  opts0                            = flres
  opts0@tiMainString               = "QuikSCAT (25km) "

  cplot0a = gsn_csm_contour_map(wks, spd_95 , opts0)      ; create contour plot
  cplot0b = gsn_csm_vector(wks, var1_95, var11_95, vcres)
  overlay(cplot0a, cplot0b)  
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "QuikSCAT 95% wind speed for February and March, 2007"

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
  pnlres@lbLabelStride              = stride1

  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script

end


