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
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***************************************
begin
; assign some info to start
name = "05MAR" ;"21FEB"

if  (name .eq. "21FEB")then
  day = "2007-02-21"
  hr = "07UTC"
  pass = "asc"
  fname1 = "wrfout_d01_" + day + "_07"
  e_name = "erai_sfc-" + day + "-06"
end if
if  (name .eq. "05MAR")then
  day = "2007-03-05"
  hr = "22UTC"
  pass = "des"
  fname1 = "wrfout_d01_" + day + "_22"
  e_name = "erai_sfc-2007-03-06-00" ; next day at 00Z
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; getting correct directories
    dir0 = "/data3/duvivier/NCAR/DATA/" + name + "/Quikscat/"
    dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 
    dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/orig_wrf/" 

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "curltau_wrf_era-" + day + "_" +hr 

; Set the contour interval for each winds
    cmin1 = -2.
    cmax1 = 2.
    clev1 = 0.1
    stride1             = 4                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1 = 2
    spreadend1 = 254
    colormap            = "BlueYellowRed"

; set fill value
    fl = new((/1/), "float")
    fill = fl@_FillValue

  print("Running Windstress curl figs for qs and wrf-" + day)

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
  time = 0
  R = 287.   ; 287J/K*kg

  print("Calculating windstress curl for first file")
; first wrf file
  f1 = addfile(dir1 + fname1 + "_10km.nc","r")  ; Load first wrf file
  COR = f1->F
  lat2d_1 = f1->XLAT(0,:,:)
  lon2d_1 = f1->XLONG(0,:,:)
  HGT1 = f1->HGT(0,:,:)

  ; get necessary vars for calculation
  press = wrf_user_getvar(f1,"p",time)
  temp = wrf_user_getvar(f1,"tk",time)
  U = f1->U
  V = f1->V
  MSFU = f1->MAPFAC_U
  MSFV = f1->MAPFAC_V
  MSFM = f1->MAPFAC_M
  DX = f1@DX
  DY = f1@DY

  ; calculate the drag coefficient for surface
  UST = f1->UST(0,:,:)
  U10 = f1->U10(0,:,:)
  V10 = f1->V10(0,:,:)
  spd = sqrt(U10^2+V10^2)
  cd = (UST/spd)^2
  delete(UST)
  delete(spd)
  delete(U10)
  delete(V10)

  ; Calculate taux and tauy  --> taux = (cd*p/R*T)*U^2
  loop = dimsizes(press)
  vert = loop(0)  ; just vertical looping
  sn = loop(1)
  we = loop(2)
  dum = new((/loop/),"float")  ; dummy variable for the multiplier
  taux = U
  tauy = V

  do i = 0,vert-1
    dum(i,:,:) = (cd*press(i,:,:))/(R*temp(i,:,:))
  end do
  ; get tauy
  do j = 0,sn-2
    ; need to multiply V*abs(V) because otherwise won't have direction info
    tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)*abs(V(0,:,j,:)))
;   tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)^2)
  end do
  ; get taux
  do k = 0,we-2
    ; need to multiply U*abs(U) because otherwise won't have direction info
    taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)*abs(U(0,:,:,k)))
;   taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)^2)
  end do
  delete(loop)
  delete(vert)
  delete(sn)
  delete(we)

  ; calculate curl of taux and tauy
  avo = wrf_avo(taux,tauy,MSFU,MSFV, MSFM, COR, DX, DY, 0)
  ; only look at surface layer(lowest eta level) and subtract coriolis
  var1_1 = (avo(0,0,:,:)*(10.^-5.)) - COR(0,:,:)
  var1_1 = var1_1*(1000.)*(100.)
  var1_1@_units = "10-2 N/km"
  var1_1@_description = "Windstress curl at surface"
  var1_1@lat2d = lat2d_1
  var1_1@lon2d = lon2d_1

  delete(MSFU)
  delete(MSFV)
  delete(MSFM)
  delete(COR)
  delete(DX)
  delete(DY)
  delete(U)
  delete(V)
  delete(press)
  delete(temp)
  delete(dum)
  delete(avo)
  delete(taux)
  delete(tauy)
  delete(cd)
  
 print("Calculating windstress curl for second file")
; second wrf file
  f2 = addfile(dir1 + fname1 + "_25km.nc","r")  ; Load first wrf file
  COR = f2->F
  lat2d_2 = f2->XLAT(0,:,:)
  lon2d_2 = f2->XLONG(0,:,:)
  HGT2 = f2->HGT(0,:,:)

  ; get necessary vars for calculation
  press = wrf_user_getvar(f2,"p",time)
  temp = wrf_user_getvar(f2,"tk",time)
  U = f2->U
  V = f2->V
  MSFU = f2->MAPFAC_U
  MSFV = f2->MAPFAC_V
  MSFM = f2->MAPFAC_M
  DX = f2@DX
  DY = f2@DY

  ; calculate the drag coefficient for surface
  UST = f2->UST(0,:,:)
  U10 = f2->U10(0,:,:)
  V10 = f2->V10(0,:,:)
  spd = sqrt(U10^2+V10^2)
  cd = (UST/spd)^2
  delete(UST)
  delete(spd)
  delete(U10)
  delete(V10)

  ; Calculate taux and tauy  --> taux = (cd*p/R*T)*U^2
  loop = dimsizes(press)
  vert = loop(0)  ; just vertical looping
  sn = loop(1)
  we = loop(2)
  dum = new((/loop/),"float")  ; dummy variable for the multiplier
  taux = U
  tauy = V

  do i = 0,vert-1
    dum(i,:,:) = (cd*press(i,:,:))/(R*temp(i,:,:))
  end do
  ; get tauy
  do j = 0,sn-2
    ; need to multiply V*abs(V) because otherwise won't have direction info
    tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)*abs(V(0,:,j,:)))
;   tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)^2)
  end do
  ; get taux
  do k = 0,we-2
    ; need to multiply U*abs(U) because otherwise won't have direction info
    taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)*abs(U(0,:,:,k)))
;   taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)^2)
  end do
  delete(loop)
  delete(vert)
  delete(sn)
  delete(we)

  ; calculate curl of taux and tauy
  avo = wrf_avo(taux,tauy,MSFU,MSFV, MSFM, COR, DX, DY, 0)
  ; only look at surface layer(lowest eta level) and subtract coriolis
  var1_2 = (avo(0,0,:,:)*(10.^-5.)) - COR(0,:,:)
  var1_2 = var1_2*(1000.)*100.
  var1_2@_units = "10-2 N/km"  
  var1_2@_description = "Windstress curl at surface"
  var1_2@lat2d = lat2d_2
  var1_2@lon2d = lon2d_2

  delete(MSFU)
  delete(MSFV)
  delete(MSFM)
  delete(COR)
  delete(DX)
  delete(DY)
  delete(U)
  delete(V)
  delete(press)
  delete(temp)
  delete(dum)
  delete(avo)
  delete(taux)
  delete(tauy)
  delete(cd)

 print("Calculating windstress curl for third file")
; third wrf file
  f3 = addfile(dir1 + fname1 + "_50km.nc","r")  ; Load first wrf file
  COR = f3->F
  lat2d_3 = f3->XLAT(0,:,:)
  lon2d_3 = f3->XLONG(0,:,:)
  HGT3 = f3->HGT(0,:,:)

  ; get necessary vars for calculation
  press = wrf_user_getvar(f3,"p",time)
  temp = wrf_user_getvar(f3,"tk",time)
  U = f3->U
  V = f3->V
  MSFU = f3->MAPFAC_U
  MSFV = f3->MAPFAC_V
  MSFM = f3->MAPFAC_M
  DX = f3@DX
  DY = f3@DY

  ; calculate the drag coefficient for surface
  UST = f3->UST(0,:,:)
  U10 = f3->U10(0,:,:)
  V10 = f3->V10(0,:,:)
  spd = sqrt(U10^2+V10^2)
  cd = (UST/spd)^2
  delete(UST)
  delete(spd)
  delete(U10)
  delete(V10)

  ; Calculate taux and tauy  --> taux = (cd*p/R*T)*U^2
  loop = dimsizes(press)
  vert = loop(0)  ; just vertical looping
  sn = loop(1)
  we = loop(2)
  dum = new((/loop/),"float")  ; dummy variable for the multiplier
  taux = U
  tauy = V

  do i = 0,vert-1
    dum(i,:,:) = (cd*press(i,:,:))/(R*temp(i,:,:))
  end do
  ; get tauy
  do j = 0,sn-2
    ; need to multiply V*abs(V) because otherwise won't have direction info
    tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)*abs(V(0,:,j,:)))
;   tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)^2)
  end do
  ; get taux
  do k = 0,we-2
    ; need to multiply U*abs(U) because otherwise won't have direction info
    taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)*abs(U(0,:,:,k)))
;   taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)^2)
  end do
  delete(loop)
  delete(vert)
  delete(sn)
  delete(we)

  ; calculate curl of taux and tauy
  avo = wrf_avo(taux,tauy,MSFU,MSFV, MSFM, COR, DX, DY, 0)
  ; only look at surface layer(lowest eta level) and subtract coriolis
  var1_3 = (avo(0,0,:,:)*(10.^-5.)) - COR(0,:,:) 
  var1_3 = var1_3*(1000.)*100.
  var1_3@_units = "10-2 N/km"   
  var1_3@_description = "Windstress curl at surface"
  var1_3@lat2d = lat2d_3
  var1_3@lon2d = lon2d_3

  delete(MSFU)
  delete(MSFV)
  delete(MSFM)
  delete(COR)
  delete(DX)
  delete(DY)
  delete(U)
  delete(V)
  delete(press)
  delete(temp)
  delete(dum)
  delete(avo)
  delete(taux)
  delete(tauy)
  delete(cd)
  
 print("Calculating windstress curl for fourth file")
; fourth wrf file
  f4 = addfile(dir1 + fname1 + "_100km.nc","r")  ; Load first wrf file
  COR = f4->F
  lat2d_4 = f4->XLAT(0,:,:)
  lon2d_4 = f4->XLONG(0,:,:)
  HGT4 = f4->HGT(0,:,:)

  ; get necessary vars for calculation
  press = wrf_user_getvar(f4,"p",time)
  temp = wrf_user_getvar(f4,"tk",time)
  U = f4->U
  V = f4->V
  MSFU = f4->MAPFAC_U
  MSFV = f4->MAPFAC_V
  MSFM = f4->MAPFAC_M
  DX = f4@DX
  DY = f4@DY

  ; calculate the drag coefficient for surface
  UST = f4->UST(0,:,:)
  U10 = f4->U10(0,:,:)
  V10 = f4->V10(0,:,:)
  spd = sqrt(U10^2+V10^2)
  cd = (UST/spd)^2
  delete(UST)
  delete(spd)
  delete(U10)
  delete(V10)

  ; Calculate taux and tauy  --> taux = (cd*p/R*T)*U^2
  loop = dimsizes(press)
  vert = loop(0)  ; just vertical looping
  sn = loop(1)
  we = loop(2)
  dum = new((/loop/),"float")  ; dummy variable for the multiplier
  taux = U
  tauy = V

  do i = 0,vert-1
    dum(i,:,:) = (cd*press(i,:,:))/(R*temp(i,:,:))
  end do
  ; get tauy
  do j = 0,sn-2
    ; need to multiply V*abs(V) because otherwise won't have direction info
    tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)*abs(V(0,:,j,:)))
;   tauy(0,:,j,:) = dum(:,j,:)*(V(0,:,j,:)^2)
  end do
  ; get taux
  do k = 0,we-2
    ; need to multiply U*abs(U) because otherwise won't have direction info
    taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)*abs(U(0,:,:,k)))
;   taux(0,:,:,k) = dum(:,:,k)*(U(0,:,:,k)^2)
  end do
  delete(loop)
  delete(vert)
  delete(sn)
  delete(we)

  ; calculate curl of taux and tauy
  avo = wrf_avo(taux,tauy,MSFU,MSFV, MSFM, COR, DX, DY, 0)
  ; only look at surface layer(lowest eta level) and subtract coriolis
  var1_4 = (avo(0,0,:,:)*(10.^-5.)) - COR(0,:,:)
  var1_4 = var1_4*(1000.)*100.
  var1_4@_units = "10-2 N/km" 
  var1_4@_description = "Windstress curl at surface"
  var1_4@lat2d = lat2d_4
  var1_4@lon2d = lon2d_4

  delete(MSFU)
  delete(MSFV)
  delete(MSFM)
  delete(COR)
  delete(DX)
  delete(DY)
  delete(U)
  delete(V)
  delete(press)
  delete(temp)
  delete(dum)
  delete(avo)
  delete(taux)
  delete(tauy)
  delete(cd)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing graphs for "+day)

  wks = gsn_open_wks("ps" ,fout)
  gsn_merge_colormaps(wks,colormap,"grey")

  plot = new(4, graphic)

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
  res@cnMissingValFillColor       = "white"          ; missing value color
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

;;;;;;;;;;;;;
; Plot 0 - QuikSCAT plot
;;;;;;;;;;;;;

;  opts0                            = res
;  opts0@tiMainString               = "QuikSCAT (0.25 deg) - " + day + " " + hr

;  cplot0a = gsn_csm_contour_map(wks, speed_0 , opts0)      ; create ascending plot
;    cplot0b = gsn_csm_vector(wks, var1_0, var2_0, vcres)
;    overlay(cplot0a,cplot0b)
;  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 10km plot
;;;;;;;;;;;;;

  opts1                            = res
  opts1@tiMainString               = "WRF (10 km) - " + day + " " + hr

  cplot1a = gsn_csm_contour_map(wks, var1_1 , opts1)      ; create ascending plot
  plot(0) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 25km plot
;;;;;;;;;;;;;

  opts2                            = res
  opts2@tiMainString               = "WRF (25 km) - " + day + " " + hr

  cplot2a = gsn_csm_contour_map(wks, var1_2 , opts2)      ; create ascending plot
  plot(1) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 50km plot
;;;;;;;;;;;;;

  opts3                            = res
  opts3@tiMainString               = "WRF (50 km) - " + day + " " + hr

  cplot3a = gsn_csm_contour_map(wks, var1_3 , opts3)      ; create ascending plot
  plot(2) = cplot3a   

;;;;;;;;;;;;;
; Plot 4 - WRF 100km plot
;;;;;;;;;;;;;

  opts4                            = res
  opts4@tiMainString               = "WRF (100 km) - " + day + " " + hr

  cplot4a = gsn_csm_contour_map(wks, var1_4 , opts4)      ; create ascending plot

  plot(3) = cplot4a   

;;;;;;;;;;;;;
; Plot 5 - Era-I plot
;;;;;;;;;;;;;

;  opts5                            = res
;  opts5@tiMainString               = "ERA-Interim (1.5 deg) - " + day + " 06UTC"

;  cplot5a = gsn_csm_contour_map(wks, speed_5 , opts5)      ; create ascending plot
;  plot(5) = cplot5a

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF windstresscurl (10~S~-2~N~ N km~S~-1~N~)"

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

  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

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
