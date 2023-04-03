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
fname1 = "wrfout_d01_" + day + "_07"
e_name = "erai_sfc-" + day + "-06"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; getting correct directories
    dir0 = "/data3/duvivier/NCAR/DATA/" + name + "/Quikscat/"
    dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir5 = "/data3/duvivier/NCAR/DATA/" + name + "/era_i/"

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "Wind_Vorticity_qs_wrf_era-" + day + "_" +hr 

; Set the contour interval for each winds
    cmin1 = 0.
    cmax1 = 44.
    clev1 = 4.
    stride1             = 1                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1 = 2
    spreadend1 = 254
    colormap1            = "WhiteYellowOrangeRed"


; Set the contour interval for relative vorticity
    cmin2 = -20.
    cmax2 = 20.
    clev2 = 2.
    stride2             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart2 = 2
    spreadend2 = 254
    colormap2            = "BlueYellowRed"

; set fill value
    test = new((/1/), "float")
    fill = test@_FillValue
    delete(test)

  print("Running Vorticity figs for qs and wrf-" + day)

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
  var2_0@_FillValue = -999.

  ; try to linearly interpolate the missing U and V values
  ; says put missing values for boundaries (0) and don't interpolate more than 3 consecutive missing values
  opt = (/0,3/)
  dims = dimsizes(var1_0)
  nlat = dims(0)
  nlon = dims(1)

  ; preallocate new arrays with interpolated values
  var1_0_new = new((/nlat,nlon/),"float")
  var2_0_new = new((/nlat,nlon/),"float")

  do i = 0,nlat-1
    sub1 = var1_0(i,:)
    sub1@_FillValue = -999.
    var1_0_new(i,:) = linmsg(sub1,opt)

    sub2 = var2_0(i,:)
    sub2@_FillValue = -999.
    var2_0_new(i,:) = linmsg(sub2,opt)

    delete(sub1)
    delete(sub2)
  end do

  ; get 10m wind speed and components
  U10_0 = var1_0_new
  V10_0 = var2_0_new
  speed_0 = sqrt(U10_0^2.+V10_0^2.)

  var1_0 = var1_0_new
  var2_0 = var2_0_new
  delete(var1_0_new)
  delete(var2_0_new)
  delete(dims)
  delete(nlat)
  delete(nlon)

  ; calculate relative vorticity for QS
  lat1d_0 = lat2d_0(:,0)
  lon1d_0 = lon2d_0(0,:)

  vr = uv2vr_cfd(var1_0,var2_0,lat1d_0,lon1d_0,0)
  delete(var1_0)
  delete(var2_0)
  delete(lat1d_0)
  delete(lon1d_0)

  ; multiply relative vorticity by 10^5
  var1_0 = vr*(10.^5.)
  var1_0@_units = "10-5 s-1"
  var1_0@_description = "Relative vorticity at surface"
  var1_0@lat2d = lat2d_0
  var1_0@lon2d = lon2d_0  
  delete(vr)

  copy_VarMeta(var1_0,speed_0)
  copy_VarMeta(var1_0,U10_0)
  copy_VarMeta(var1_0,V10_0)

;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

; first wrf file
  f1 = addfile(dir1 + fname1 + "_10km.nc","r")  ; Load first wrf file
  lat2d_1 = f1->XLAT(0,:,:)
  lon2d_1 = f1->XLONG(0,:,:)
  HGT1 = f1->HGT(0,:,:)
  U1 = f1->U
  V1 = f1->V
  MSFU1 = f1->MAPFAC_U
  MSFV1 = f1->MAPFAC_V
  MSFM1 = f1->MAPFAC_M
  COR1 = f1->F
  DX1 = f1@DX
  DY1 = f1@DY

  avo1 = wrf_avo(U1,V1,MSFU1,MSFV1, MSFM1, COR1, DX1, DY1, 0)
  ; only look at surface layer(lowest eta level) to get relative vorticity
  var1_1 = (avo1(0,0,:,:)*(10.^-5.)) - COR1(0,:,:)
  var1_1 = var1_1/(10.^-5.)
  var1_1@_units = "10-5 s-1"
  var1_1@_description = "Relative vorticity at surface"
  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1

  ; get 10m wind speed and direction
  U10_1 = f1->U10(0,:,:)
  V10_1 = f1->V10(0,:,:)
  speed_1 = sqrt(U10_1^2.+V10_1^2.)
  copy_VarMeta(var1_1,U10_1)
  copy_VarMeta(var1_1,V10_1)
  copy_VarMeta(var1_1,speed_1)
  
  ; delete unnecessary large vars
  delete(U1)
  delete(V1)
  delete(avo1)

; second wrf file
  f2 = addfile(dir2 + fname1 + "_25km.nc","r")  ; Load first wrf file
  lat2d_2 = f2->XLAT(0,:,:) 
  lon2d_2 = f2->XLONG(0,:,:)
  HGT2 = f2->HGT(0,:,:)
  U2 = f2->U
  V2 = f2->V
  MSFU2 = f2->MAPFAC_U
  MSFV2 = f2->MAPFAC_V
  MSFM2 = f2->MAPFAC_M
  COR2 = f2->F
  DX2 = f2@DX
  DY2 = f2@DY

  avo2 = wrf_avo(U2,V2,MSFU2,MSFV2, MSFM2, COR2, DX2, DY2, 0)
  ; only look at surface layer(lowest eta level) to get relative vorticity
  var1_2 = (avo2(0,0,:,:)*(10.^-5.)) - COR2(0,:,:)
  var1_2 = var1_2/(10.^-5.)
  var1_2@_units = "10-5 s-1"
  var1_2@_description = "Relative vorticity at surface"
  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2

  ; get 10m wind speed and direction
  U10_2 = f2->U10(0,:,:)
  V10_2 = f2->V10(0,:,:)
  speed_2 = sqrt(U10_2^2.+V10_2^2.)
  copy_VarMeta(var1_2,U10_2)
  copy_VarMeta(var1_2,V10_2)
  copy_VarMeta(var1_2,speed_2)
  
  ; delete unnecessary large vars
  delete(U2)
  delete(V2)
  delete(avo2)

; third wrf file
  f3 = addfile(dir3 + fname1 + "_50km.nc","r")  ; Load first wrf file
  lat2d_3 = f3->XLAT(0,:,:) 
  lon2d_3 = f3->XLONG(0,:,:)
  HGT3 = f3->HGT(0,:,:)
  U3 = f3->U
  V3 = f3->V
  MSFU3 = f3->MAPFAC_U
  MSFV3 = f3->MAPFAC_V
  MSFM3 = f3->MAPFAC_M
  COR3 = f3->F
  DX3 = f3@DX
  DY3 = f3@DY

  avo3 = wrf_avo(U3,V3,MSFU3,MSFV3, MSFM3, COR3, DX3, DY3, 0)
  ; only look at surface layer(lowest eta level) to get relative vorticity
  var1_3 = (avo3(0,0,:,:)*(10.^-5.)) - COR3(0,:,:)
  var1_3 = var1_3/(10.^-5.)
  var1_3@_units = "10-5 s-1"
  var1_3@_description = "Relative vorticity at surface"
  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3

  ; get 10m wind speed and direction
  U10_3 = f3->U10(0,:,:)
  V10_3 = f3->V10(0,:,:)
  speed_3 = sqrt(U10_3^2.+V10_3^2.)
  copy_VarMeta(var1_3,U10_3)
  copy_VarMeta(var1_3,V10_3)
  copy_VarMeta(var1_3,speed_3)
  
  ; delete unnecessary large vars
  delete(U3)
  delete(V3)
  delete(avo3)

; fourth wrf file
  f4 = addfile(dir4 + fname1 + "_100km.nc","r")  ; Load first wrf file
  lat2d_4 = f4->XLAT(0,:,:) 
  lon2d_4 = f4->XLONG(0,:,:)
  HGT4 = f4->HGT(0,:,:)
  U4 = f4->U
  V4 = f4->V
  MSFU4 = f4->MAPFAC_U
  MSFV4 = f4->MAPFAC_V
  MSFM4 = f4->MAPFAC_M
  COR4 = f4->F
  DX4 = f4@DX
  DY4 = f4@DY

  avo4 = wrf_avo(U4,V4,MSFU4,MSFV4, MSFM4, COR4, DX4, DY4, 0)
  ; only look at surface layer(lowest eta level) to get relative vorticity
  var1_4 = (avo4(0,0,:,:)*(10.^-5.)) - COR4(0,:,:)
  var1_4 = var1_4/(10.^-5.)
  var1_4@_units = "10-5 s-1"
  var1_4@_description = "Relative vorticity at surface"
  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4
  
  ; get 10m wind speed and direction
  U10_4 = f4->U10(0,:,:)
  V10_4 = f4->V10(0,:,:)
  speed_4 = sqrt(U10_4^2.+V10_4^2.)
  copy_VarMeta(var1_4,U10_4)
  copy_VarMeta(var1_4,V10_4)
  copy_VarMeta(var1_4,speed_4)

  ; delete unnecessary large vars
  delete(U4)
  delete(V4)
  delete(avo4)

;;;;;;;;;;
; load in era files and variables
;;;;;;;;;;
  print("Loading era_i")

  f5 = addfile(dir5 + e_name + ".nc","r")  ; Load first wrf file
  lat1d_5 = f5->g4_lat_0
  lon1d_5 = f5->g4_lon_1
  var1_5  = f5->10U_GDS4_SFC(:,:)
  var2_5  = f5->10V_GDS4_SFC(:,:)
  HGT5 = f5->LSM_GDS4_SFC  ; Land/Sea Mask
  dum = var1_5 ; this is for assigning metadata later

  ; need to reverse the latitude arrays
  dims = dimsizes(var1_5)
  nlat = dims(0)
  nlon = dims(1)

  ; flip the lat array
  ; preallocate new lat array with interpolated values
  lat1d_5_new = new((/nlat/),"float")

  do i = 0,nlat-1
    ; need to flip the lat order (1st --> last)
    k = (nlat-1)-i    
    lat1d_5_new(i) = lat1d_5(k)
  end do
  delete(i)
  delete(k)

  ; rename array
  lat1d_5 = lat1d_5_new
  delete(lat1d_5_new)

  ; flip the u and v arrays
  ; preallocate new u and varrays with interpolated values
  var1_5_new = new((/nlat,nlon/),"float")
  var2_5_new = new((/nlat,nlon/),"float")
  HGT5_new = new((/nlat,nlon/),"float")

  do j = 0,nlon-1
    ; for u and v arrays, go through by lon and subset to flip
    sub1 = var1_5(:,j) ; u
    sub2 = var2_5(:,j) ; v
    subh = HGT5(:,j) ; Height
    do i = 0,nlat-1
      ; need to flip the lat order (1st --> last)
      k = (nlat-1)-i    
      ; replace u and v data with flipped data
      var1_5_new(i,j) = sub1(k)
      var2_5_new(i,j) = sub2(k)
      HGT5_new(i,j) = subh(k)
      delete(k)
    end do
    delete(sub1)
    delete(sub2)
    delete(subh)
  end do

  ; rename u and v arrays
  delete(var1_5)
  var1_5 = var1_5_new
  copy_VarMeta(dum, var1_5)
  delete(var2_5)
  var2_5 = var2_5_new
  copy_VarMeta(dum, var2_5)

  delete(dims)
  delete(nlat)
  delete(nlon)

  ; get 10m wind speed and components
  U10_5 = var1_5
  V10_5 = var2_5
  speed_5 = sqrt(U10_5^2.+V10_5^2.)
  copy_VarMeta(dum,speed_5)

  ; calculate relative vorticity for QS
  vr = uv2vr_cfd(var1_5,var2_5,lat1d_5,lon1d_5,0)

  ; multiply relative vorticity by 10^5
  var1_5 = vr*(10.^5.)
  var1_5@_units = "10-5 s-1"
  delete(var1_5@units)
  var1_5@_description = "Relative vorticity at surface"
  fill2 = var1_5@_FillValue

  delete(var2_5)
  delete(vr)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Mask out land 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  var1_1 = where(HGT1 .lt. 5., var1_1, fill)
  var1_1@_FillValue = fill

  var1_2 = where(HGT2 .lt. 5., var1_2, fill)
  var1_2@_FillValue = fill

  var1_3 = where(HGT3 .lt. 5., var1_3, fill)
  var1_3@_FillValue = fill

  var1_4 = where(HGT4 .lt. 5., var1_4, fill)
  var1_4@_FillValue = fill

  var1_5 = where(HGT5 .eq. 0., var1_5, fill2)
  var1_5@_FillValue = fill2
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for "+day)

  colormaps = (/colormap1, colormap2/)

  wks = gsn_open_wks("ps" ,fout)
  gsn_define_colormap(wks,colormap(0))
;  gsn_merge_colormaps(wks,colormap,"grey")

  plot = new(12, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

 res                             = True              ; plot mods desired

 ; set general domain resources
  res@gsnRightString              = ""
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

; set contour resources for wind
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
  res@tiMainFontHeightF           = 0.025
  res@tiMainFontThicknessF        = 1.5
  res@lbLabelBarOn                = False             ; turn off individual label bars

; set contour resources for relative vorticity
  res2 = res
  delete(res2@gsnSpreadColorStart)
  delete(res2@gsnSpreadColorEnd)
  delete(res2@cnMinLevelValF)
  delete(res2@cnMaxLevelValF)
  delete(res2@cnLevelSpacingF)
  res2@gsnSpreadColorStart         = spreadstart2      ; start at color specified 
  res2@gsnSpreadColorEnd           = spreadend2        ; end at color specified 
  res2@cnMinLevelValF              = cmin2             ; set min contour level specified above
  res2@cnMaxLevelValF              = cmax2             ; set max contour level specified above
  res2@cnLevelSpacingF             = clev2             ; set contour spacing specified above

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
  vcres@vcLineArrowThicknessF      = 2.0               ; thickness of vector arrows (larger = bolder
 
 ; set vector legend resources
  vcres@vcRefAnnoOrthogonalPosF    = -0.2              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.99               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "20 m s~S~-1~N~"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2On         = False              ; turn on bottom vector label string
  vcres@vcRefAnnoFontHeightF       = 0.02

; WIND PLOTS
;;;;;;;;;;;;;
; Plot 0 - QuikSCAT plot
;;;;;;;;;;;;;

  opts0                            = res
  opts0@tiMainString               = "a)      WS: QuikSCAT (0.25 deg) - " + hr

  cplot0a = gsn_csm_contour_map(wks, speed_0 , opts0)      ; create ascending plot
    cplot0b = gsn_csm_vector(wks, U10_0, V10_0, vcres)
    overlay(cplot0a,cplot0b)
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 10km plot
;;;;;;;;;;;;;

  opts1                            = res
  opts1@tiMainString               = "b)       WS: WRF (10 km) - " + hr

  cplot1a = gsn_csm_contour_map(wks, speed_1 , opts1)      ; create ascending plot
    cplot1b = gsn_csm_vector(wks, U10_1, V10_1, vcres)
    overlay(cplot1a,cplot1b)
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 25km plot
;;;;;;;;;;;;;

  opts2                            = res
  opts2@tiMainString               = "c)       WS: WRF (25 km) - " + hr

  cplot2a = gsn_csm_contour_map(wks, speed_2 , opts2)      ; create ascending plot
    cplot2b = gsn_csm_vector(wks, U10_2, V10_2, vcres)
    overlay(cplot2a,cplot2b)
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 50km plot
;;;;;;;;;;;;;

  opts3                            = res
  opts3@tiMainString               = "d)       WS: WRF (50 km) - " + hr

  cplot3a = gsn_csm_contour_map(wks, speed_3 , opts3)      ; create ascending plot
    cplot3b = gsn_csm_vector(wks, U10_3, V10_3, vcres)
    overlay(cplot3a,cplot3b)
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Plot 4 - WRF 100km plot
;;;;;;;;;;;;;

  opts4                            = res
  opts4@tiMainString               = "e)       WS: WRF (100 km) - " + hr

  cplot4a = gsn_csm_contour_map(wks, speed_4 , opts4)      ; create ascending plot
    cplot4b = gsn_csm_vector(wks, U10_4, V10_4, vcres)
    overlay(cplot4a,cplot4b)
  plot(4) = cplot4a   

;;;;;;;;;;;;;
; Plot 5 - Era-I plot
;;;;;;;;;;;;;

  opts5                            = res
  opts5@tiMainString               = "f)    WS: ERA-Interim (1.5 deg) - 06UTC"

  cplot5a = gsn_csm_contour_map(wks, speed_5 , opts5)      ; create ascending plot
    cplot5b = gsn_csm_vector(wks, U10_5, V10_5, vcres)
    overlay(cplot5a,cplot5b)
  plot(5) = cplot5a

; RELATIVE VORTICITY PLOTS
;;;;;;;;;;;;;
; Plot 6 - QuikSCAT plot
;;;;;;;;;;;;;

  opts6                            = res2
  opts6@tiMainString               = "g)       RV: QuikSCAT (0.25 deg) - " + hr

  cplot6a = gsn_csm_contour_map(wks, var1_0 , opts6)      ; create ascending plot
  plot(6) = cplot6a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 7 - WRF 10km plot
;;;;;;;;;;;;;

  opts7                            = res2
  opts7@tiMainString               = "h)       RV: WRF (10 km) - " + hr

  cplot7a = gsn_csm_contour_map(wks, var1_1 , opts7)      ; create ascending plot
  plot(7) = cplot7a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 8 - WRF 25km plot
;;;;;;;;;;;;;

  opts8                            = res2
  opts8@tiMainString               = "i)       RV: WRF (25 km) - " + hr

  cplot8a = gsn_csm_contour_map(wks, var1_2 , opts8)      ; create ascending plot
  plot(8) = cplot8a 

;;;;;;;;;;;;;
; Plot 9 - WRF 50km plot
;;;;;;;;;;;;;

  opts9                            = res2
  opts9@tiMainString               = "j)       RV: WRF (50 km) - " + hr

  cplot9a = gsn_csm_contour_map(wks, var1_3 , opts9)      ; create ascending plot
  plot(9) = cplot9a   

;;;;;;;;;;;;;
; Plot 10 - WRF 100km plot
;;;;;;;;;;;;;

  opts10                            = res2
  opts10@tiMainString               = "k)       RV: WRF (100 km) - " + hr

  cplot10a = gsn_csm_contour_map(wks, var1_4 , opts10)      ; create ascending plot

  plot(10) = cplot10a   

;;;;;;;;;;;;;
; Plot 11 - Era-I plot
;;;;;;;;;;;;;

  opts11                            = res2
  opts11@tiMainString               = "l)    RV: ERA-Interim (1.5 deg) - 06UTC"

  cplot11a = gsn_csm_contour_map(wks, var1_5 , opts11)      ; create ascending plot
  plot(11) = cplot11a

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "QuikSCAT, WRF, and ERA-Interim - "+day+" ~C~ wind speed (m s~S~-1~N~) and relative vorticity (10~S~-5~N~ s~S~-1~N~) "

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
  pnlres@lbLabelFontHeightF         = 0.015              ; label bar font size
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@pmLabelBarWidthF           = 0.8

  gsn_panel(wks,(/plot/),(/4,3/),pnlres)               ; create final panel plot

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
