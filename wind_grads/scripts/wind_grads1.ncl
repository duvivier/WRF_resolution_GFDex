;***************************************
; PROGRAM DESCRIPTION: This NCL script "final version" plots WRF and Quikscat winds and ERA-I spatial winds
; INPUT DATA: Quikscat text files, processed from Matlab, and WRF output at 4 resolutions, ERA-I .nc files
; OUTPUT DATA: Panel plot of QuikSCAT, ERA-I, and WRF surface wind data
; Note: These plots are zoomed and at each data set's native resolution
;       This script is for 21 February
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; assign some info to start
name = "21FEB"
day = "2007-02-21"
hr = "07UTC"
pass = "asc"
fname1 = "wrf-" + day + "-07"
e_name = "erai_sfc-" + day + "-06"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; getting correct directories
    dir0 = "/data3/duvivier/NCAR/DATA/" + name + "/Quikscat/"
    dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_10km/"
    dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_25km/"
    dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_50km/"
    dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_100km/"
    dir5 = "/data3/duvivier/NCAR/DATA/" + name + "/era_i/"

    title0 = "QuikSCAT"
    title1 = "WRF_10"
    title2 = "WRF_25km"
    title3 = "WRF_50km"
    title4 = "WRF_100km"
    title5 = "ERA-I"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "Wind_grad1-" + day + "_" +hr 

; set up WRF wind variables
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_tr"
    invar2 ="v_10m_tr"
    vartype = "2d"
    find_speed = True

; Set the contour interval for each winds
    cmin1 = 0
    cmax1 = 44.
    clev1 = 4.
    stride1             = 1                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1 = 2
    spreadend1 = 254
    colormap            = "WhiteYellowOrangeRed"

  print("Running Wind figs for qs and wrf-" + day)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in quikscat files and variables
;;;;;;;;;;
  print("Loading QuikSCAT")

  header = 0
  ncol = 170

  lat2d_0 = readAsciiTable(dir0+"Quikscat_lat2d.txt",ncol,"float",header)
  lon2d_0 = readAsciiTable(dir0+"Quikscat_lon2d.txt",ncol,"float",header)

  var1_0  = readAsciiTable(dir0 + "Quikscat_" + pass + "_u.txt",ncol,"float",header)
  var2_0  = readAsciiTable(dir0 + "Quikscat_" + pass + "_v.txt",ncol,"float",header)

  var1_0@_FillValue = -999.
  var1_0@lat2d = lat2d_0
  var1_0@lon2d = lon2d_0
  var1_0@units = "m s-1"
  copy_VarMeta(var1_0, var2_0)

  speed_0 = sqrt(var1_0^2 + var2_0^2)
  copy_VarMeta(var1_0, speed_0)


;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

; first wrf file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  var1_1  = f1->$invar1$(time|0,south_north|:,west_east|:)
  var2_1  = f1->$invar2$(time|0,south_north|:,west_east|:)
  speed_1 = sqrt(var1_1^2 + var2_1^2)
  hgt1 = f1->Z_sfc(south_north|:,west_east|:)

  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1
  copy_VarMeta(var1_1, var2_1)
  copy_VarMeta(var1_1, speed_1)

; second wrf file
  f2 = addfile(dir2 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  var1_2  = f2->$invar1$(time|0,south_north|:,west_east|:)
  var2_2  = f2->$invar2$(time|0,south_north|:,west_east|:)
  speed_2 = sqrt(var1_2^2 + var2_2^2)
  hgt2 = f2->Z_sfc(south_north|:,west_east|:)

  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2
  copy_VarMeta(var1_2, var2_2)
  copy_VarMeta(var1_2, speed_2)

; third wrf file
  f3 = addfile(dir3 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  var1_3  = f3->$invar1$(time|0,south_north|:,west_east|:)
  var2_3  = f3->$invar2$(time|0,south_north|:,west_east|:)
  speed_3 = sqrt(var1_3^2 + var2_3^2)
  hgt3 = f3->Z_sfc(south_north|:,west_east|:)

  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3
  copy_VarMeta(var1_3, var2_3)
  copy_VarMeta(var1_3, speed_3)

; fourth wrf file
  f4 = addfile(dir4 + fname1 + ".nc","r")  ; Load first wrf file
  lat2d_4 = f4->lat
  lon2d_4 = f4->lon
  var1_4  = f4->$invar1$(time|0,south_north|:,west_east|:)
  var2_4  = f4->$invar2$(time|0,south_north|:,west_east|:)
  speed_4 = sqrt(var1_4^2 + var2_4^2)
  hgt4 = f4->Z_sfc(south_north|:,west_east|:)

  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4
  copy_VarMeta(var1_4, var2_4)
  copy_VarMeta(var1_4, speed_4)

;;;;;;;;;;
; load in era files and variables
;;;;;;;;;;
  print("Loading era_i")

  f5 = addfile(dir5 + e_name + ".nc","r")  ; Load first wrf file
  lat1d_5 = f5->g4_lat_0
  lon1d_5 = f5->g4_lon_1
  var1_5  = f5->10U_GDS4_SFC(:,:)
  var2_5  = f5->10V_GDS4_SFC(:,:)
  speed_5 = sqrt(var1_5^2 + var2_5^2)
 ; copy_VarMeta(var1_5, speed_5)
  speed_5@units = "m s-1"

  ; make lat and lon 2d arrays
  dims = dimsizes(speed_5)
  dim_lat = dims(0) ; lats
  dim_lon = dims(1) ; lons

  lat2d_5 = new((/dim_lat, dim_lon/), "float")
  lon2d_5 = new((/dim_lat, dim_lon/), "float")

  do i = 0, dim_lon-1
    lat2d_5(:,i) = lat1d_5
  end do

  do j = 0, dim_lat-1
    lon2d_5(j,:) = lon1d_5
  end do

  speed_5@lat2d = lat2d_5
  speed_5@lon2d = lon2d_5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Subset data by lat/lon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  test = new((/1/), "float")
  print("Subsetting data of interest")
  fill = test@_FillValue

; subset data where 56<lat<70 and -54<lon<-20
; for true values, make the subset array the value from the average, for false values make it the fill value so it won't go into summed values
  ; file 0
  ; QuikSCAT has already been subset for the region.

  ; file 1
  speed_1_sub = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20. .and. hgt1 .eq. 0 , speed_1, fill)

  speed_1_sub@_FillValue = fill
  speed_1_sub@lat2d = lat2d_1
  speed_1_sub@lon2d = lon2d_1

  ; file 2
  speed_2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20. .and. hgt2 .eq. 0 , speed_2, fill)

  speed_2_sub@_FillValue = fill
  speed_2_sub@lat2d = lat2d_2
  speed_2_sub@lon2d = lon2d_2

  ; file 3
  speed_3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20. .and. hgt3 .eq. 0 , speed_3, fill)

  speed_3_sub@_FillValue = fill
  speed_3_sub@lat2d = lat2d_3
  speed_3_sub@lon2d = lon2d_3

  ; file 4
  speed_4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20. .and. hgt4 .eq. 0 , speed_4, fill)

  speed_4_sub@_FillValue = fill
  speed_4_sub@lat2d = lat2d_4
  speed_4_sub@lon2d = lon2d_4

  ; file 5
  speed_5_sub = where(lat2d_5 .gt. 56. .and. lat2d_5 .lt. 70. .and. lon2d_5 .gt. 306. .and. lon2d_5 .lt. 340., speed_5, fill)

  speed_5_sub@_FillValue = fill

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Print and find location of maximum wind speed over water
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; file 0
  max0 = max(speed_0)
  print("Maximum wind speed for "+title0+" is: "+max0)
  
  dum = ndtooned(speed_0)
  dsizes=dimsizes(speed_0)
  indices = ind_resolve(ind(dum.eq.max0),dsizes)
  ind0_0 = indices(0,0)
  ind1_0 = indices(0,1)
  print("Latitude: "+lat2d_0(ind0_0,ind1_0))
  print("Longitude: "+lon2d_0(ind0_0,ind1_0))
  delete(dum)
  delete(dsizes)
  delete(indices)

  ; file 1
  max1 = max(speed_1_sub)
  print("Maximum wind speed for "+title1+" is: "+max1)
  
  dum = ndtooned(speed_1_sub)
  dsizes=dimsizes(speed_1_sub)
  indices = ind_resolve(ind(dum.eq.max1),dsizes)
  ind0_1 = indices(0,0)
  ind1_1 = indices(0,1)
  print("Latitude: "+lat2d_1(ind0_1,ind1_1))
  print("Longitude: "+lon2d_1(ind0_1,ind1_1))
  delete(dum)
  delete(dsizes)
  delete(indices)

  ; file 2
  max2 = max(speed_2_sub)
  print("Maximum wind speed for "+title2+" is: "+max2)
  
  dum = ndtooned(speed_2_sub)
  dsizes=dimsizes(speed_2_sub)
  indices = ind_resolve(ind(dum.eq.max2),dsizes)
  ind0_2 = indices(0,0)
  ind1_2 = indices(0,1)
  print("Latitude: "+lat2d_2(ind0_2,ind1_2))
  print("Longitude: "+lon2d_2(ind0_2,ind1_2))
  delete(dum)
  delete(dsizes)
  delete(indices)

  ; file 3
  max3 = max(speed_3_sub)
  print("Maximum wind speed for "+title3+" is: "+max3)
  
  dum = ndtooned(speed_3_sub)
  dsizes=dimsizes(speed_3_sub)
  indices = ind_resolve(ind(dum.eq.max3),dsizes)
  ind0_3 = indices(0,0)
  ind1_3 = indices(0,1)
  print("Latitude: "+lat2d_3(ind0_3,ind1_3))
  print("Longitude: "+lon2d_3(ind0_3,ind1_3))
  delete(dum)
  delete(dsizes)
  delete(indices)

  ; file 4
  max4 = max(speed_4_sub)
  print("Maximum wind speed for "+title4+" is: "+max4)
  
  dum = ndtooned(speed_4_sub)
  dsizes=dimsizes(speed_4_sub)
  indices = ind_resolve(ind(dum.eq.max4),dsizes)
  ind0_4 = indices(0,0)
  ind1_4 = indices(0,1)
  print("Latitude: "+lat2d_4(ind0_4,ind1_4))
  print("Longitude: "+lon2d_4(ind0_4,ind1_4))
  delete(dum)
  delete(dsizes)
  delete(indices)

  ; file 5
  max5 = max(speed_5_sub)
  print("Maximum wind speed for "+title5+" is: "+max5)
  
  dum = ndtooned(speed_5_sub)
  dsizes=dimsizes(speed_5_sub)
  indices = ind_resolve(ind(dum.eq.max5),dsizes)
  ind0_5 = indices(0,0)
  ind1_5 = indices(0,1)
  print("Latitude: "+lat2d_5(ind0_5,ind1_5))
  print("Longitude: "+lon2d_5(ind0_5,ind1_5))
  delete(dum)
  delete(dsizes)
  delete(indices)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for "+day)

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")

  plot = new(6, graphic)

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
  res@mpGeophysicalLineThicknessF = 1.5               ; Make continents thinner

; set contour resources
  res@cnFillMode                  = cntype
  res@cnFillOn                    = True              ; turn on filled contours
  res@gsnSpreadColors             = True              ; use full colormap
  res@gsnSpreadColorStart         = spreadstart1      ; start at color specified 
  res@gsnSpreadColorEnd           = spreadend1        ; end at color specified 
  res@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF              = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  res@cnLinesOn                   = plotlines         ; contour lines specified above
  res@cnLineLabelsOn              = plotlines         ; line labels on specified above
  res@cnMissingValFillColor       = "grey"          ; missing value color
  res@cnMissingValFillPattern     = 0                 ; fill in
  res@tiMainFontHeightF           = 0.017
  res@lbLabelBarOn                = False             ; turn off individual label bars

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

  ; polyres for markers
  gridpolyres               = True
  
  gridpolyres@gsMarkerIndex = 1
  gridpolyres@gsMarkerSizeF = 0.020
  gridpolyres@gsMarkerColor = "black"

; set line res to show cross section line
  lnres                            = True
   lnres@gsLineThicknessF          = 2.5
   lnres@gsLineColor               = "black"

;;;;;;;;;;;;;
; Plot 0 - QuikSCAT plot
;;;;;;;;;;;;;
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
  st_lat0 = 58.875
  st_lon0 = -44.825
  ed_lat0 = 58.
  ed_lon0 = -43.
  npts0 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat0, st_lon0, ed_lat0, ed_lon0, npts0, 4)
   print("Length "+title0+" cross section: "+length)
   delete(length)

  opts0                            = res
  opts0@tiMainString               = "QuikSCAT (0.25 deg) - " + day + " " + hr

  cplot0a = gsn_csm_contour_map(wks, speed_0 , opts0)      ; create ascending plot
;    cplot0b = gsn_csm_vector(wks, var1_0, var2_0, vcres)
;    overlay(cplot0a,cplot0b)
    dum0 = gsn_add_polymarker(wks,cplot0a,lon2d_0(ind0_0,ind1_0),lat2d_0(ind0_0,ind1_0),gridpolyres)
    dum0a = gsn_add_polyline(wks,cplot0a,(/st_lon0,ed_lon0/), (/st_lat0, ed_lat0/), lnres)
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 10km plot
;;;;;;;;;;;;;
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
; modified to add 5 indexes to get better gradient measurement
  st_lat1 = lat2d_1(ind0_1-3,ind1_1+7)
  st_lon1 = lon2d_1(ind0_1-3,ind1_1+7)
  ed_lat1 = st_lat1 - 0.875
  ed_lon1 = st_lon1 + 1.825
  npts1 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat1, st_lon1, ed_lat1, ed_lon1, npts1, 4)
   print("Length "+title1+" cross section: "+length)
   delete(length)

  opts1                            = res
  opts1@tiMainString               = "WRF (10 km) - " + day + " " + hr

  cplot1a = gsn_csm_contour_map(wks, speed_1 , opts1)      ; create ascending plot
;    cplot1b = gsn_csm_vector(wks, var1_1, var2_1, vcres)
;    overlay(cplot1a,cplot1b)
    dum1 = gsn_add_polymarker(wks,cplot1a,lon2d_1(ind0_1-3,ind1_1+7),lat2d_1(ind0_1-3,ind1_1+7),gridpolyres)
    dum1a = gsn_add_polyline(wks,cplot1a,(/st_lon1,ed_lon1/), (/st_lat1, ed_lat1/), lnres)
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 25km plot
;;;;;;;;;;;;;
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
  st_lat2 = lat2d_2(ind0_2,ind1_2)
  st_lon2 = lon2d_2(ind0_2,ind1_2)
  ed_lat2 = st_lat2 - 0.875
  ed_lon2 = st_lon2 + 1.825
  npts2 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat2, st_lon2, ed_lat2, ed_lon2, npts2, 4)
   print("Length "+title2+" cross section: "+length)
   delete(length)

  opts2                            = res
  opts2@tiMainString               = "WRF (25 km) - " + day + " " + hr

  cplot2a = gsn_csm_contour_map(wks, speed_2 , opts2)      ; create ascending plot
;    cplot2b = gsn_csm_vector(wks, var1_2, var2_2, vcres)
;    overlay(cplot2a,cplot2b)
    dum2 = gsn_add_polymarker(wks,cplot2a,lon2d_2(ind0_2,ind1_2),lat2d_2(ind0_2,ind1_2),gridpolyres)
    dum2a = gsn_add_polyline(wks,cplot2a,(/st_lon2,ed_lon2/), (/st_lat2, ed_lat2/), lnres)

  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 50km plot
;;;;;;;;;;;;;
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
  st_lat3 = lat2d_3(ind0_3,ind1_3)
  st_lon3 = lon2d_3(ind0_3,ind1_3)
  ed_lat3 = st_lat3 - 0.875
  ed_lon3 = st_lon3 + 1.825
  npts3 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat3, st_lon3, ed_lat3, ed_lon3, npts3, 4)
   print("Length "+title3+" cross section: "+length)
   delete(length)

  opts3                            = res
  opts3@tiMainString               = "WRF (50 km) - " + day + " " + hr

  cplot3a = gsn_csm_contour_map(wks, speed_3 , opts3)      ; create ascending plot
;    cplot3b = gsn_csm_vector(wks, var1_3, var2_3, vcres)
;    overlay(cplot3a,cplot3b)
    dum3 = gsn_add_polymarker(wks,cplot3a,lon2d_3(ind0_3,ind1_3),lat2d_3(ind0_3,ind1_3),gridpolyres)
    dum3a = gsn_add_polyline(wks,cplot3a,(/st_lon3,ed_lon3/), (/st_lat3, ed_lat3/), lnres)
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Plot 4 - WRF 100km plot
;;;;;;;;;;;;;
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
  st_lat4 = lat2d_4(ind0_4,ind1_4)
  st_lon4 = lon2d_4(ind0_4,ind1_4)
  ed_lat4 = st_lat4 - 0.875
  ed_lon4 = st_lon4 + 1.825
  npts4 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat4, st_lon4, ed_lat4, ed_lon4, npts4, 4)
   print("Length "+title4+" cross section: "+length)
   delete(length)

  opts4                            = res
  opts4@tiMainString               = "WRF (100 km) - " + day + " " + hr

  cplot4a = gsn_csm_contour_map(wks, speed_4 , opts4)      ; create ascending plot
;    cplot4b = gsn_csm_vector(wks, var1_4, var2_4, vcres)
;    overlay(cplot4a,cplot4b)
    dum4 = gsn_add_polymarker(wks,cplot4a,lon2d_4(ind0_4,ind1_4),lat2d_4(ind0_4,ind1_4),gridpolyres)
    dum4a = gsn_add_polyline(wks,cplot4a,(/st_lon4,ed_lon4/), (/st_lat4, ed_lat4/), lnres)
  plot(4) = cplot4a   

;;;;;;;;;;;;;
; Plot 5 - Era-I plot
;;;;;;;;;;;;;
  ;; add in line showing where cross section in future figures is located 
  ; lat and lons for polyline
  st_lat5 = lat2d_5(ind0_5,ind1_5)
  st_lon5 = lon2d_5(ind0_5,ind1_5)
  ed_lat5 = st_lat5 - 0.875
  ed_lon5 = st_lon5 + 1.825
  npts5 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat5, st_lon5, ed_lat5, ed_lon5, npts5, 4)
   print("Length "+title5+" cross section: "+length)
   delete(length)

  opts5                            = res
  opts5@tiMainString               = "ERA-Interim (1.5 deg) - " + day + " 06UTC"

  cplot5a = gsn_csm_contour_map(wks, speed_5 , opts5)      ; create ascending plot
;    cplot5b = gsn_csm_vector(wks, var1_5, var2_5, vcres)
;    overlay(cplot5a,cplot5b)
    dum5 = gsn_add_polymarker(wks,cplot5a,lon2d_5(ind0_5,ind1_5),lat2d_5(ind0_5,ind1_5),gridpolyres)
    dum5a = gsn_add_polyline(wks,cplot5a,(/st_lon5,ed_lon5/), (/st_lat5, ed_lat5/), lnres)
  plot(5) = cplot5a

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "QuikSCAT, WRF, and ERA-Interim 10m winds"

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

  gsn_panel(wks,(/plot/),(/2,3/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script
end
