;***************************************
; PROGRAM DESCRIPTION: This NCL script plots the 95th percentile wind values
;             from longterm files at four WRF resolutions.
; INPUT DATA: Four WRF output files at native resolution that are concatenated
;             monthly files
; OUTPUT DATA: Four panel plot of 95th percent value at native resolutions
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
dir1 = "/ptmp/duvivier/FEBMAR/wrf_10km/wrf_cont/catted/"
dir2 = "/ptmp/duvivier/FEBMAR/wrf_25km/wrf_cont/catted/"
dir3 = "/ptmp/duvivier/FEBMAR/wrf_50km/wrf_cont/catted/"
dir4 = "/ptmp/duvivier/FEBMAR/wrf_100km/wrf_cont/catted/"

fname1 = "wrf-200701-cat"
fname2 = "wrf-200702-cat"
fname3 = "wrf-200703-cat"

varcode = "Windsurf"

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_longterm_95"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

  print("Running longterm avg at all resolutions")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information

 if (varcode.eq."Windsurf") then
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_tr"
    invar11 ="v_10m_tr"
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

;; first wrf file
  f1_feb = addfile(dir1 + fname2 + ".nc","r")  ; Load first wrf file
  f1_mar = addfile(dir1 + fname3 + ".nc","r")  ; Load first wrf file
  var1_feb  = f1_feb->$invar1$(time|:,south_north|:,west_east|:)
  var1_mar  = f1_mar->$invar1$(time|:,south_north|:,west_east|:)
  var11_feb  = f1_feb->$invar11$(time|:,south_north|:,west_east|:)
  var11_mar  = f1_mar->$invar11$(time|:,south_north|:,west_east|:)
  
  lat2d_1 = f1_feb->lat
  lon2d_1 = f1_feb->lon
  var1_feb@lat2d = lat2d_1
  var1_feb@lon2d = lon2d_1
  dims1 = dimsizes(lat2d_1)
  nlat_1 = dims1(0)
  nlon_1 = dims1(1)

; second wrf file
  f2_feb = addfile(dir2 + fname2 + ".nc","r")  ; Load first wrf file
  f2_mar = addfile(dir2 + fname3 + ".nc","r")  ; Load first wrf file
  var2_feb  = f2_feb->$invar1$(time|:,south_north|:,west_east|:)
  var2_mar  = f2_mar->$invar1$(time|:,south_north|:,west_east|:)
  var22_feb  = f2_feb->$invar11$(time|:,south_north|:,west_east|:)
  var22_mar  = f2_mar->$invar11$(time|:,south_north|:,west_east|:)

  lat2d_2 = f2_feb->lat
  lon2d_2 = f2_feb->lon
  var2_feb@lat2d = lat2d_2
  var2_feb@lon2d = lon2d_2
  dims2 = dimsizes(lat2d_2)
  nlat_2 = dims2(0)
  nlon_2 = dims2(1)

; third wrf file
  f3_feb = addfile(dir3 + fname2 + ".nc","r")  ; Load first wrf file
  f3_mar = addfile(dir3 + fname3 + ".nc","r")  ; Load first wrf file
  var3_feb  = f3_feb->$invar1$(time|:,south_north|:,west_east|:)
  var3_mar  = f3_mar->$invar1$(time|:,south_north|:,west_east|:)
  var33_feb  = f3_feb->$invar11$(time|:,south_north|:,west_east|:)
  var33_mar  = f3_mar->$invar11$(time|:,south_north|:,west_east|:)
  
  lat2d_3 = f3_feb->lat
  lon2d_3 = f3_feb->lon
  var3_feb@lat2d = lat2d_3
  var3_feb@lon2d = lon2d_3
  dims3 = dimsizes(lat2d_3)
  nlat_3 = dims3(0)
  nlon_3 = dims3(1)

; fourth wrf file
  f4_feb = addfile(dir4 + fname2 + ".nc","r")  ; Load first wrf file
  f4_mar = addfile(dir4 + fname3 + ".nc","r")  ; Load first wrf file
  var4_feb  = f4_feb->$invar1$(time|:,south_north|:,west_east|:)
  var4_mar  = f4_mar->$invar1$(time|:,south_north|:,west_east|:)
  var44_feb  = f4_feb->$invar11$(time|:,south_north|:,west_east|:)
  var44_mar  = f4_mar->$invar11$(time|:,south_north|:,west_east|:)
  
  lat2d_4 = f4_feb->lat
  lon2d_4 = f4_feb->lon
  var4_feb@lat2d = lat2d_4
  var4_feb@lon2d = lon2d_4
  dims4 = dimsizes(lat2d_4)
  nlat_4 = dims4(0)
  nlon_4 = dims4(1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Performing data processing: concatenating, averaging")
;;;;;;;;;;;;;
; If winds, find wind speed variable
;;;;;;;;;;;;
; first wrf file
  var1_feb_spd = sqrt(var1_feb^2 + var11_feb^2)
  var1_mar_spd = sqrt(var1_mar^2 + var11_mar^2)

; second wrf file
  var2_feb_spd = sqrt(var2_feb^2 + var22_feb^2)
  var2_mar_spd = sqrt(var2_mar^2 + var22_mar^2)

; third wrf file
  var3_feb_spd = sqrt(var3_feb^2 + var33_feb^2)
  var3_mar_spd = sqrt(var3_mar^2 + var33_mar^2)

; fourth wrf file
  var4_feb_spd = sqrt(var4_feb^2 + var44_feb^2)
  var4_mar_spd = sqrt(var4_mar^2 + var44_mar^2)


;;;;;;;;;;;;;
; Make arrays for full data sets with both feb and mar
;;;;;;;;;;;;
  ; get time dimensions for february and march
  dim_feb = dimsizes(var4_feb)
  t_feb = dim_feb(0)
  dim_mar = dimsizes(var4_mar)
  t_mar = dim_mar(0)
  t_tot = t_feb + t_mar

; make new arrays and fill them with old data
; first wrf file
  var1_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_tot(0:t_feb-1, :, :) = var1_feb
     var1_tot(t_feb:t_tot-1, :, :) = var1_mar

  var11_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var11_tot(0:t_feb-1, :, :) = var11_feb
     var11_tot(t_feb:t_tot-1, :, :) = var11_mar

  var1_spd_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_spd_tot(0:t_feb-1, :, :) = var1_feb_spd
     var1_spd_tot(t_feb:t_tot-1, :, :) = var1_mar_spd

; second wrf file
  var2_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_tot(0:t_feb-1, :, :) = var2_feb
     var2_tot(t_feb:t_tot-1, :, :) = var2_mar

  var22_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var22_tot(0:t_feb-1, :, :) = var22_feb
     var22_tot(t_feb:t_tot-1, :, :) = var22_mar

  var2_spd_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_spd_tot(0:t_feb-1, :, :) = var2_feb_spd
     var2_spd_tot(t_feb:t_tot-1, :, :) = var2_mar_spd

; third wrf file
  var3_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_tot(0:t_feb-1, :, :) = var3_feb
     var3_tot(t_feb:t_tot-1, :, :) = var3_mar

  var33_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var33_tot(0:t_feb-1, :, :) = var33_feb
     var33_tot(t_feb:t_tot-1, :, :) = var33_mar

  var3_spd_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_spd_tot(0:t_feb-1, :, :) = var3_feb_spd
     var3_spd_tot(t_feb:t_tot-1, :, :) = var3_mar_spd

; fourth wrf file
  var4_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_tot(0:t_feb-1, :, :) = var4_feb
     var4_tot(t_feb:t_tot-1, :, :) = var4_mar

  var44_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var44_tot(0:t_feb-1, :, :) = var44_feb
     var44_tot(t_feb:t_tot-1, :, :) = var44_mar

  var4_spd_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_spd_tot(0:t_feb-1, :, :) = var4_feb_spd
     var4_spd_tot(t_feb:t_tot-1, :, :) = var4_mar_spd
;;;;;;;;;;;;;
; Get 95th percentiles of variables
;;;;;;;;;;;;
; get value of 95% along time coordinate
  tmp0 = ((95./100.)*t_tot)+0.5      ; add 0.5 to make sure it will be 95% or greater
  tmp1 = round(tmp0, 3)              ; get integer index of 95% value

  ; find 95% highest values
print("finding 95% value for file1")
  var1_spd_95 = new((/nlat_1, nlon_1/), "float")  
  do i = 0, nlat_1 - 1
    do j = 0, nlon_1 - 1
      tmp2 = var1_spd_tot(:,i,j)       ; take one dimensional slice of data (through time)
      tmp3 = tmp2                  ; make array to sort
      qsort(tmp3)                  ; sort values in first grid cell
      var1_spd_95(i,j) = tmp3(tmp1)    ; assign 95% value to new array
      
      delete(tmp2)
      delete(tmp3)
    end do
  end do

print("finding 95% value for file2")
  var2_spd_95 = new((/nlat_2, nlon_2/), "float")  
  do i = 0, nlat_2 - 1
    do j = 0, nlon_2 - 1
      tmp2 = var2_spd_tot(:,i,j)       ; take one dimensional slice of data (through time)
      tmp3 = tmp2                  ; make array to sort
      qsort(tmp3)                  ; sort values in first grid cell
      var2_spd_95(i,j) = tmp3(tmp1)    ; assign 95% value to new array
      
      delete(tmp2)
      delete(tmp3)
    end do
  end do

print("finding 95% value for file3")
  var3_spd_95 = new((/nlat_3, nlon_3/), "float")  
  do i = 0, nlat_3 - 1
    do j = 0, nlon_3 - 1
      tmp2 = var3_spd_tot(:,i,j)       ; take one dimensional slice of data (through time)
      tmp3 = tmp2                  ; make array to sort
      qsort(tmp3)                  ; sort values in first grid cell
      var3_spd_95(i,j) = tmp3(tmp1)    ; assign 95% value to new array
      
      delete(tmp2)
      delete(tmp3)
    end do
  end do

print("finding 95% value for file4")
  var4_spd_95 = new((/nlat_4, nlon_4/), "float")  
  do i = 0, nlat_4 - 1
    do j = 0, nlon_4 - 1
      tmp2 = var4_spd_tot(:,i,j)       ; take one dimensional slice of data (through time)
      tmp3 = tmp2                  ; make array to sort
      qsort(tmp3)                  ; sort values in first grid cell
      var4_spd_95(i,j) = tmp3(tmp1)    ; assign 95% value to new array
      
      delete(tmp2)
      delete(tmp3)
    end do
  end do


delete(tmp0)
delete(tmp1)

;;;;;;;;;;;;;
; Assign meta data
;;;;;;;;;;;;
  var1_spd_95@lat2d = lat2d_1
  var1_spd_95@lon2d = lon2d_1
  var1_spd_95@units = units0

  var2_spd_95@lat2d = lat2d_2
  var2_spd_95@lon2d = lon2d_2
  var2_spd_95@units = units0

  var3_spd_95@lat2d = lat2d_3
  var3_spd_95@lon2d = lon2d_3
  var3_spd_95@units = units0

  var4_spd_95@lat2d = lat2d_4
  var4_spd_95@lon2d = lon2d_4
  var4_spd_95@units = units0

;;;;;;;;;;;;;
; Get 95th percentiles of u and v variables
;;;;;;;;;;;;
; get 95% and 5% values  along time coordinate (should be representative of westerly and easterly winds)
  tmpa = ((95./100.)*t_tot)+0.5      ; add 0.5 to make sure it will be 95% or more (means westerly/southerly)
  tmpb = ((5./100.)*t_tot)-0.5       ; sub 0.5 to make sure it will be 5% or lower (means easterly/northerly)
  tmpaa = round(tmpa, 3)              ; get integer index of 95% value
  tmpbb = round(tmpb, 3)

print("finding 95% value for file1 u and v")
  var1_95 = new((/nlat_1, nlon_1/), "float")
  var11_95 = new((/nlat_1, nlon_1/), "float")

  do i = 0, nlat_1 - 1
    do j = 0, nlon_1 - 1
      tmp1 = var1_tot(:,i,j)       ; take 1D slice of u component
      tmp11 = var11_tot(:,i,j)     ; take 1D slice of v component

      tmp1_a = tmp1                ; make u array to sort
      tmp11_b = tmp11              ; make v array to sort

      qsort(tmp1_a)                ; sort u values in first grid cell
      qsort(tmp11_b)               ; sort v values in first grid cell

      a = abs(tmp1_a(tmpaa))            ; get 95% value of u
      b = abs(tmp1_a(tmpbb))            ; get 5% value of u

      aa = abs(tmp11_b(tmpaa))          ; get 95% value of v
      bb = abs(tmp11_b(tmpbb))          ; get 5% value of v


      if (a .gt. b) then
        var1_95(i,j) = tmp1_a(tmpaa)
      else
        var1_95(i,j) = tmp1_a(tmpbb)
      end if

      if (aa .gt. bb) then
        var11_95(i,j) = tmp11_b(tmpaa)
      else
        var11_95(i,j) = tmp11_b(tmpbb)
      end if

      delete(tmp1)
      delete(tmp11)
      delete(tmp1_a)
      delete(tmp11_b)

    end do
  end do

print("finding 95% value for file2 u and v")
  var2_95 = new((/nlat_2, nlon_2/), "float")
  var22_95 = new((/nlat_2, nlon_2/), "float")

  do i = 0, nlat_2 - 1
    do j = 0, nlon_2 - 1
      tmp1 = var2_tot(:,i,j)       ; take 1D slice of u component
      tmp11 = var22_tot(:,i,j)     ; take 1D slice of v component

      tmp1_a = tmp1                ; make u array to sort
      tmp11_b = tmp11              ; make v array to sort

      qsort(tmp1_a)                ; sort u values in first grid cell
      qsort(tmp11_b)               ; sort v values in first grid cell

      a = abs(tmp1_a(tmpaa))            ; get 95% value of u
      b = abs(tmp1_a(tmpbb))            ; get 5% value of u

      aa = abs(tmp11_b(tmpaa))          ; get 95% value of v
      bb = abs(tmp11_b(tmpbb))          ; get 5% value of v


      if (a .gt. b) then
        var2_95(i,j) = tmp1_a(tmpaa)
      else
        var2_95(i,j) = tmp1_a(tmpbb)
      end if

      if (aa .gt. bb) then
        var22_95(i,j) = tmp11_b(tmpaa)
      else
        var22_95(i,j) = tmp11_b(tmpbb)
      end if

      delete(tmp1)
      delete(tmp11)
      delete(tmp1_a)
      delete(tmp11_b)

    end do
  end do

print("finding 95% value for file3 u and v")
  var3_95 = new((/nlat_3, nlon_3/), "float")
  var33_95 = new((/nlat_3, nlon_3/), "float")

  do i = 0, nlat_3 - 1
    do j = 0, nlon_3 - 1
      tmp1 = var3_tot(:,i,j)       ; take 1D slice of u component
      tmp11 = var33_tot(:,i,j)     ; take 1D slice of v component

      tmp1_a = tmp1                ; make u array to sort
      tmp11_b = tmp11              ; make v array to sort

      qsort(tmp1_a)                ; sort u values in first grid cell
      qsort(tmp11_b)               ; sort v values in first grid cell

      a = abs(tmp1_a(tmpaa))            ; get 95% value of u
      b = abs(tmp1_a(tmpbb))            ; get 5% value of u

      aa = abs(tmp11_b(tmpaa))          ; get 95% value of v
      bb = abs(tmp11_b(tmpbb))          ; get 5% value of v


      if (a .gt. b) then
        var3_95(i,j) = tmp1_a(tmpaa)
      else
        var3_95(i,j) = tmp1_a(tmpbb)
      end if

      if (aa .gt. bb) then
        var33_95(i,j) = tmp11_b(tmpaa)
      else
        var33_95(i,j) = tmp11_b(tmpbb)
      end if

      delete(tmp1)
      delete(tmp11)
      delete(tmp1_a)
      delete(tmp11_b)

    end do
  end do

print("finding 95% value for file4 u and v")
  var4_95 = new((/nlat_4, nlon_4/), "float")
  var44_95 = new((/nlat_4, nlon_4/), "float")

  do i = 0, nlat_4 - 1
    do j = 0, nlon_4 - 1
      tmp1 = var4_tot(:,i,j)       ; take 1D slice of u component
      tmp11 = var44_tot(:,i,j)     ; take 1D slice of v component

      tmp1_a = tmp1                ; make u array to sort
      tmp11_b = tmp11              ; make v array to sort

      qsort(tmp1_a)                ; sort u values in first grid cell
      qsort(tmp11_b)               ; sort v values in first grid cell

      a = abs(tmp1_a(tmpaa))            ; get 95% value of u
      b = abs(tmp1_a(tmpbb))            ; get 5% value of u

      aa = abs(tmp11_b(tmpaa))          ; get 95% value of v
      bb = abs(tmp11_b(tmpbb))          ; get 5% value of v


      if (a .gt. b) then
        var4_95(i,j) = tmp1_a(tmpaa)
      else
        var4_95(i,j) = tmp1_a(tmpbb)
      end if

      if (aa .gt. bb) then
        var44_95(i,j) = tmp11_b(tmpaa)
      else
        var44_95(i,j) = tmp11_b(tmpbb)
      end if

      delete(tmp1)
      delete(tmp11)
      delete(tmp1_a)
      delete(tmp11_b)

    end do
  end do

;;;;;;;;;;;;;
; Assign meta data
;;;;;;;;;;;;
  var1_95@lat2d = lat2d_1
  var1_95@lon2d = lon2d_1
  var11_95@lat2d = lat2d_1
  var11_95@lon2d = lon2d_1

  var2_95@lat2d = lat2d_2
  var2_95@lon2d = lon2d_2
  var22_95@lat2d = lat2d_2
  var22_95@lon2d = lon2d_2

  var3_95@lat2d = lat2d_3
  var3_95@lon2d = lon2d_3
  var33_95@lat2d = lat2d_3
  var33_95@lon2d = lon2d_3  

  var4_95@lat2d = lat2d_4
  var4_95@lon2d = lon2d_4
  var44_95@lat2d = lat2d_4
  var44_95@lon2d = lon2d_4 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; plot averages only
  print("Processing monthly average graphs for " + varcode)

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
  opts0@tiMainString               = "WRF(10km) "

  cplot0a = gsn_csm_contour_map(wks, var1_spd_95 , opts0)      ; create contour plot
  cplot0b = gsn_csm_vector(wks, var1_95, var11_95, vcres)
  overlay(cplot0a, cplot0b)  
  plot(0) = cplot0a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - WRF 25km plot
;;;;;;;;;;;;;

  opts1                            = flres
  opts1@tiMainString               = "WRF(25km) "

  cplot1a = gsn_csm_contour_map(wks, var2_spd_95, opts1)      ; create contour plot
  cplot1b = gsn_csm_vector(wks, var2_95, var22_95, vcres)
  overlay(cplot1a, cplot1b)
  plot(1) = cplot1a                                         ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - WRF 50km plot
;;;;;;;;;;;;;

  opts2                            = flres
  opts2@tiMainString               = "WRF(50km) "

  cplot2a = gsn_csm_contour_map(wks, var3_spd_95, opts2)      ; create contour plot
  cplot2b = gsn_csm_vector(wks, var3_95, var33_95, vcres)
  overlay(cplot2a, cplot2b)
  plot(2) = cplot2a 

;;;;;;;;;;;;;
; Plot 3 - WRF 100km plot
;;;;;;;;;;;;;

  opts3                            = flres
  opts3@tiMainString               = "WRF(100km) "

  cplot3a = gsn_csm_contour_map(wks, var4_spd_95 , opts3)      ; create contour plot
  cplot3b = gsn_csm_vector(wks, var4_95, var44_95, vcres)
  overlay(cplot3a, cplot3b)
  plot(3) = cplot3a   

;;;;;;;;;;;;;
; Final Plot
;;;;;;;;;;;;;

   title_fin = "WRF 95% wind speed for February and March, 2007"

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
;  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
;  pnlres@pmLabelBarHeightF          = 0.075             ; set height of labelbar
;  pnlres@pmLabelBarWidthF           = 0.65




  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

;  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

;  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script

end


