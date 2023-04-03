;***************************************
; PROGRAM DESCRIPTION: This NCL script plots averages from long term files
;                      from four WRF resolutions
; INPUT DATA: Four WRF output files at native resolution that are concatenated
;             monthly files
; OUTPUT DATA: Four panel plot of average at each resolution
; Note: This can be looped with 01_wrffourpanel_akd_hourly.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Matt Higgins
;          Modified by Alice DuVivier - February 2011
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
fout   = outdir+"mwrf_"+varcode+"_longterm_95"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

  print("Running longterm 95 at all resolutions")

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

  ; land mask data for values
  f1_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.10km.nc", "r")
  land1 = f1_geo->LANDMASK(Time|0,south_north|:,west_east|:)


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

  ; land mask data for values
  f2_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.25km.nc", "r")
  land2 = f2_geo->LANDMASK(Time|0,south_north|:,west_east|:)


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

  ; land mask data for values
  f3_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.50km.nc", "r")
  land3 = f3_geo->LANDMASK(Time|0,south_north|:,west_east|:)


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

  ; land mask data for values
  f4_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.100km.nc", "r")
  land4 = f4_geo->LANDMASK(Time|0,south_north|:,west_east|:)

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
  delete(var1_feb)
  delete(var1_mar)

  var11_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var11_tot(0:t_feb-1, :, :) = var11_feb
     var11_tot(t_feb:t_tot-1, :, :) = var11_mar
  delete(var11_feb)
  delete(var11_mar)

  var1_spd_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_spd_tot(0:t_feb-1, :, :) = var1_feb_spd
     var1_spd_tot(t_feb:t_tot-1, :, :) = var1_mar_spd
  delete(var1_feb_spd)
  delete(var1_mar_spd)


; second wrf file
  var2_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_tot(0:t_feb-1, :, :) = var2_feb
     var2_tot(t_feb:t_tot-1, :, :) = var2_mar
  delete(var2_feb)
  delete(var2_mar)

  var22_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var22_tot(0:t_feb-1, :, :) = var22_feb
     var22_tot(t_feb:t_tot-1, :, :) = var22_mar
  delete(var22_feb)
  delete(var22_mar)

  var2_spd_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_spd_tot(0:t_feb-1, :, :) = var2_feb_spd
     var2_spd_tot(t_feb:t_tot-1, :, :) = var2_mar_spd
  delete(var2_feb_spd)
  delete(var2_mar_spd)

; third wrf file
  var3_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_tot(0:t_feb-1, :, :) = var3_feb
     var3_tot(t_feb:t_tot-1, :, :) = var3_mar
  delete(var3_feb)
  delete(var3_mar)

  var33_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var33_tot(0:t_feb-1, :, :) = var33_feb
     var33_tot(t_feb:t_tot-1, :, :) = var33_mar
  delete(var33_feb)
  delete(var33_mar)

  var3_spd_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_spd_tot(0:t_feb-1, :, :) = var3_feb_spd
     var3_spd_tot(t_feb:t_tot-1, :, :) = var3_mar_spd
  delete(var3_feb_spd)
  delete(var3_mar_spd)

; fourth wrf file
  var4_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_tot(0:t_feb-1, :, :) = var4_feb
     var4_tot(t_feb:t_tot-1, :, :) = var4_mar
  delete(var4_feb)
  delete(var4_mar)

  var44_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var44_tot(0:t_feb-1, :, :) = var44_feb
     var44_tot(t_feb:t_tot-1, :, :) = var44_mar
  delete(var44_feb)
  delete(var44_mar)

  var4_spd_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_spd_tot(0:t_feb-1, :, :) = var4_feb_spd
     var4_spd_tot(t_feb:t_tot-1, :, :) = var4_mar_spd
  delete(var4_feb_spd)
  delete(var4_mar_spd)


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
  
  delete(var1_spd_tot)

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

  delete(var2_spd_tot)

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

  delete(var3_spd_tot)

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

  delete(var4_spd_tot)

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

  delete(var1_tot)
  delete(var11_tot)

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

  delete(var2_tot)
  delete(var22_tot)

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

  delete(var3_tot)
  delete(var33_tot)

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

  delete(var4_tot)
  delete(var44_tot)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create text file of subset data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Subset data by lat/lon
;;;;;;;;;;;;
  print("Subsetting data of interest")
  fill = var1_95@_FillValue

; subset data where 56<lat<70 and -54<lon<-20
; for true values, make the subset array the value from the average, for false values make it the fill value so it won't go into summed values

  ; file 1
  var1_sub = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., var1_spd_95, fill)
  var1_sub@_FillValue = fill

  ; file 2
  var2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., var2_spd_95, fill)
  var2_sub@_FillValue = fill

  ; file 3
  var3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., var3_spd_95, fill)
  var3_sub@_FillValue = fill

  ; file 4
  var4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., var4_spd_95, fill)
  var4_sub@_FillValue = fill

;;;;;;;;;;;;;
; Mask out land points
;;;;;;;;;;;;
  print("Masking land points for fluxes")
  ; can use False or 0 as last argument to set it to a fill value

  var1_masked = mask(var1_sub, land1 .eq. 1, False)
  var2_masked = mask(var2_sub, land2 .eq. 1, False)
  var3_masked = mask(var3_sub, land3 .eq. 1, False)
  var4_masked = mask(var4_sub, land4 .eq. 1, False)

;;;;;;;;;;;;;
; Write to a text file
;;;;;;;;;;;;
; THIS IS NOT AT ALL EFFICIENT, BUT WAS EASIEST FOR NOW

head = "95 Table values for " + varcode + " February and March 2007"

a1 = "WRF10 max " + varcode + ": " + max(var1_masked) + " and avg: " + avg(var1_masked) + "  [m/s]"
output1 = array_append_record(head, a1, 0)

a2 = "WRF25 max " + varcode + ": " + max(var2_masked) + " and avg: " + avg(var2_masked) + "  [m/s]"
output2 = array_append_record(output1, a2, 0)

a3 = "WRF50 max " + varcode + ": " + max(var3_masked) + " and avg: " + avg(var3_masked) + "  [m/s]"
output3 = array_append_record(output2, a3, 0)

a4 = "WRF100 max " + varcode + ": " + max(var4_masked) + " and avg: " + avg(var4_masked) + "  [m/s]"
output4 = array_append_record(output3, a4, 0)

asciiwrite(fout + ".txt", output4)


;;;;;;;;;;;;;;;;;;;;;; END script

end


