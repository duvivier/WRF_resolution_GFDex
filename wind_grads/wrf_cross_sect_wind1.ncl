;***************************************
; PROGRAM DESCRIPTION: This NCL script makes cross section plots of WRF data
; INPUT DATA: WRF output at four resolutions and ERA-I data from met-em file
; OUTPUT DATA: Panel plot of total wind speed for each resolution
; Note: This script works only for 21 February
; CREATORS: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***************************************
begin
; assign some info to start
name = "21FEB"
day = "2007-02-21"
hr = "07UTC"
pass = "asc"
fname1 = "wrf-" + day + "-07"
e_name = "erai_sfc-" + day + "-06"
cross_type = "1"

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

  delete(lat1d_5)
  delete(lon1d_5)

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
  speed_2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20. .and. hgt2 .lt. 0.5 , speed_2, fill)

  speed_2_sub@_FillValue = fill
  speed_2_sub@lat2d = lat2d_2
  speed_2_sub@lon2d = lon2d_2

  ; file 3
  speed_3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20. .and. hgt3 .lt. 0.5 , speed_3, fill)

  speed_3_sub@_FillValue = fill
  speed_3_sub@lat2d = lat2d_3
  speed_3_sub@lon2d = lon2d_3

  ; file 4
  speed_4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20. .and. hgt4 .lt. 0.5 , speed_4, fill)

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
; Horizontally Interpolate to cross section lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set cressman radius based on resolution of wrf output
     cressrad_0 = 25.
     cressrad_1 = 10.            
     cressrad_2 = 25.            
     cressrad_3 = 50.            
     cressrad_4 = 101.
     cressrad_5 = 101.  ; same as 10km resolution

;;;;;;;;;;;;;
; QScat
;;;;;;;;;;;;;
  st_lat0 = 58.875
  st_lon0 = -44.825
  ed_lat0 = 58.
  ed_lon0 = -43.
  npts0 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat0, st_lon0, ed_lat0, ed_lon0, npts0, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 

   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist_0 = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist_0(i) = km
     km = km + space
   end do
   dist_0!0 = "Horizontal"
   dist_0@units = "km" 
   delete(i)
   delete(space)

print("Interpolating to cross section line " + title0)
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  ; get 1D lats and lons and sfc windspeed
  lat1d_0 = ndtooned(lat2d_0)
  lon1d_0 = ndtooned(lon2d_0)
  speed_1d_0 = ndtooned(speed_0)
;  speed_1d_0 = ndtooned(speed_0_sub)

  ; preallocate arrays for subset of each variable
  speed_sub_0   = new((/n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_0 = gc_latlon(lats(i),lons(i),lat1d_0, lon1d_0, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_0))) then       
      nreplacements = num(isnan_ieee(dist_rad_0))  ; find index of NaN
      replace_ieeenan(dist_rad_0,0.,0)             ; replace the NaN with 0
      print("file 0: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_0).gt.cressrad_0) then        
      print("file 0: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_0 = ind(dist_rad_0.lt.cressrad_0)    ; indicies where distance is in cressman radius
    weight_0 = (cressrad_0^2 - dist_rad_0(indicies_0)^2) / (cressrad_0^2 + dist_rad_0(indicies_0)^2)  ; assign weights

    ; calculate 10m wind values
    speed_sub_0(i) = sum(speed_1d_0(indicies_0)*weight_0)/sum(weight_0)

    delete(indicies_0)
    delete(weight_0)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  delete(n_cross)
  delete(length)
  delete(lats)
  delete(lons)
  delete(interp_ind)
  delete(interp_wgt)

;;;;;;;;;;;;;
; WRF 10km
;;;;;;;;;;;;;
; these have been adjusted so that they match the highest gradient
 st_lat1 = lat2d_1(ind0_1-3,ind1_1+7)
  st_lon1 = lon2d_1(ind0_1-3,ind1_1+7)
  ed_lat1 = st_lat1 - 0.875
  ed_lon1 = st_lon1 + 1.825
  npts1 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat1, st_lon1, ed_lat1, ed_lon1, npts1, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 

   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist_1 = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist_1(i) = km
     km = km + space
   end do
   dist_1!0 = "Horizontal"
   dist_1@units = "km" 
   delete(i)
   delete(space)

print("Interpolating to cross section line " + title1)
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  ; get 1D lats and lons and sfc windspeed
  lat1d_1 = ndtooned(lat2d_1)
  lon1d_1 = ndtooned(lon2d_1)
  speed_1d_1 = ndtooned(speed_1_sub)

  ; preallocate arrays for subset of each variable
  speed_sub_1   = new((/n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_1 = gc_latlon(lats(i),lons(i),lat1d_1, lon1d_1, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_1))) then       
      nreplacements = num(isnan_ieee(dist_rad_1))  ; find index of NaN
      replace_ieeenan(dist_rad_1,0.,0)             ; replace the NaN with 0
      print("file 0: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_1).gt.cressrad_1) then        
      print("file 0: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_1 = ind(dist_rad_1.lt.cressrad_1)    ; indicies where distance is in cressman radius
    weight_1 = (cressrad_1^2 - dist_rad_1(indicies_1)^2) / (cressrad_1^2 + dist_rad_1(indicies_1)^2)  ; assign weights

    ; calculate 10m wind values
    speed_sub_1(i) = sum(speed_1d_1(indicies_1)*weight_1)/sum(weight_1)

    delete(indicies_1)
    delete(weight_1)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do
  delete(n_cross)
  delete(length)
  delete(lats)
  delete(lons)
  delete(interp_ind)
  delete(interp_wgt)

;;;;;;;;;;;;;
; WRF 25km
;;;;;;;;;;;;;
  st_lat2 = lat2d_2(ind0_2,ind1_2)
  st_lon2 = lon2d_2(ind0_2,ind1_2)
  ed_lat2 = st_lat2 - 0.875
  ed_lon2 = st_lon2 + 1.825
  npts2 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat2, st_lon2, ed_lat2, ed_lon2, npts2, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 

   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist_2 = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist_2(i) = km
     km = km + space
   end do
   dist_2!0 = "Horizontal"
   dist_2@units = "km" 
   delete(i)
   delete(space)

print("Interpolating to cross section line " + title2)
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  ; get 1D lats and lons and sfc windspeed
  lat1d_2 = ndtooned(lat2d_2)
  lon1d_2 = ndtooned(lon2d_2)
  speed_1d_2 = ndtooned(speed_2_sub)

  ; preallocate arrays for subset of each variable
  speed_sub_2   = new((/n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_2 = gc_latlon(lats(i),lons(i),lat1d_2, lon1d_2, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_2))) then       
      nreplacements = num(isnan_ieee(dist_rad_2))  ; find index of NaN
      replace_ieeenan(dist_rad_2,0.,0)             ; replace the NaN with 0
      print("file 0: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_2).gt.cressrad_2) then        
      print("file 0: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_2 = ind(dist_rad_2.lt.cressrad_2)    ; indicies where distance is in cressman radius
    weight_2 = (cressrad_2^2 - dist_rad_2(indicies_2)^2) / (cressrad_2^2 + dist_rad_2(indicies_2)^2)  ; assign weights

    ; calculate 10m wind values
    speed_sub_2(i) = sum(speed_1d_2(indicies_2)*weight_2)/sum(weight_2)

    delete(indicies_2)
    delete(weight_2)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do
  delete(n_cross)
  delete(length)
  delete(lats)
  delete(lons)
  delete(interp_ind)
  delete(interp_wgt)

;;;;;;;;;;;;;
; WRF 50km
;;;;;;;;;;;;;
  st_lat3 = lat2d_3(ind0_3,ind1_3)
  st_lon3 = lon2d_3(ind0_3,ind1_3)
  ed_lat3 = st_lat3 - 0.875
  ed_lon3 = st_lon3 + 1.825
  npts3 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat3, st_lon3, ed_lat3, ed_lon3, npts3, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 

   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist_3 = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist_3(i) = km
     km = km + space
   end do
   dist_3!0 = "Horizontal"
   dist_3@units = "km" 
   delete(i)
   delete(space)

print("Interpolating to cross section line " + title3)
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  ; get 1D lats and lons and sfc windspeed
  lat1d_3 = ndtooned(lat2d_3)
  lon1d_3 = ndtooned(lon2d_3)
  speed_1d_3 = ndtooned(speed_3_sub)

  ; preallocate arrays for subset of each variable
  speed_sub_3   = new((/n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_3 = gc_latlon(lats(i),lons(i),lat1d_3, lon1d_3, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_3))) then       
      nreplacements = num(isnan_ieee(dist_rad_3))  ; find index of NaN
      replace_ieeenan(dist_rad_3,0.,0)             ; replace the NaN with 0
      print("file 0: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_3).gt.cressrad_3) then        
      print("file 0: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_3 = ind(dist_rad_3.lt.cressrad_3)    ; indicies where distance is in cressman radius
    weight_3 = (cressrad_3^2 - dist_rad_3(indicies_3)^2) / (cressrad_3^2 + dist_rad_3(indicies_3)^2)  ; assign weights

    ; calculate 10m wind values
    speed_sub_3(i) = sum(speed_1d_3(indicies_3)*weight_3)/sum(weight_3)

    delete(indicies_3)
    delete(weight_3)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do
  delete(n_cross)
  delete(length)
  delete(lats)
  delete(lons)
  delete(interp_ind)
  delete(interp_wgt)

;;;;;;;;;;;;;
; WRF 100km
;;;;;;;;;;;;;
  st_lat4 = lat2d_4(ind0_4,ind1_4)
  st_lon4 = lon2d_4(ind0_4,ind1_4)
  ed_lat4 = st_lat4 - 0.875
  ed_lon4 = st_lon4 + 1.825
  npts4 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat4, st_lon4, ed_lat4, ed_lon4, npts4, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 

   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist_4 = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist_4(i) = km
     km = km + space
   end do
   dist_4!0 = "Horizontal"
   dist_4@units = "km" 
   delete(i)
   delete(space)

print("Interpolating to cross section line " + title4)
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  ; get 1D lats and lons and sfc windspeed
  lat1d_4 = ndtooned(lat2d_4)
  lon1d_4 = ndtooned(lon2d_4)
  speed_1d_4 = ndtooned(speed_4_sub)

  ; preallocate arrays for subset of each variable
  speed_sub_4   = new((/n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_4 = gc_latlon(lats(i),lons(i),lat1d_4, lon1d_4, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_4))) then       
      nreplacements = num(isnan_ieee(dist_rad_4))  ; find index of NaN
      replace_ieeenan(dist_rad_4,0.,0)             ; replace the NaN with 0
      print("file 0: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_4).gt.cressrad_4) then        
      print("file 0: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_4 = ind(dist_rad_4.lt.cressrad_4)    ; indicies where distance is in cressman radius
    weight_4 = (cressrad_4^2 - dist_rad_4(indicies_4)^2) / (cressrad_4^2 + dist_rad_4(indicies_4)^2)  ; assign weights

    ; calculate 10m wind values
    speed_sub_4(i) = sum(speed_1d_4(indicies_4)*weight_4)/sum(weight_4)

    delete(indicies_4)
    delete(weight_4)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do
  delete(n_cross)
  delete(length)
  delete(lats)
  delete(lons)
  delete(interp_ind)
  delete(interp_wgt)

;;;;;;;;;;;;;
; ERA-I
;;;;;;;;;;;;;
  st_lat5 = lat2d_5(ind0_5,ind1_5)
  st_lon5 = lon2d_5(ind0_5,ind1_5)
  ed_lat5 = st_lat5 - 0.875
  ed_lon5 = st_lon5 + 1.825
  npts5 = 72

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat5, st_lon5, ed_lat5, ed_lon5, npts5, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 

   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist_5 = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist_5(i) = km
     km = km + space
   end do
   dist_5!0 = "Horizontal"
   dist_5@units = "km" 
   delete(i)
   delete(space)

print("Interpolating to cross section line " + title5)
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  ; get 1D lats and lons and sfc windspeed
  lat1d_5 = ndtooned(lat2d_5)
  lon1d_5 = ndtooned(lon2d_5)
  speed_1d_5 = ndtooned(speed_5_sub)

  ; preallocate arrays for subset of each variable
  speed_sub_5   = new((/n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_5 = gc_latlon(lats(i),lons(i),lat1d_5, lon1d_5, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_5))) then       
      nreplacements = num(isnan_ieee(dist_rad_5))  ; find index of NaN
      replace_ieeenan(dist_rad_5,0.,0)             ; replace the NaN with 0
      print("file 0: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_5).gt.cressrad_5) then        
      print("file 0: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_5 = ind(dist_rad_5.lt.cressrad_5)    ; indicies where distance is in cressman radius
    weight_5 = (cressrad_5^2 - dist_rad_5(indicies_5)^2) / (cressrad_5^2 + dist_rad_5(indicies_5)^2)  ; assign weights

    ; calculate 10m wind values
    speed_sub_5(i) = sum(speed_1d_5(indicies_5)*weight_5)/sum(weight_5)

    delete(indicies_5)
    delete(weight_5)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do
  delete(n_cross)
  delete(length)
  delete(lats)
  delete(lons)
  delete(interp_ind)
  delete(interp_wgt)

return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Plotting cross section of "+vartitle1)
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

 plot = new(6, graphic)    ; one cross section plot and one spatial plot

;;;;;;;;;;;;;
; Cross Section Plot Resources
;;;;;;;;;;;;;

 opts                              = True              ; plot mods desired
;  opts@gsnRightString              = ""
  opts@gsnLeftString               = ""
  opts@gsnFrame                    = False             ; Do not draw plot 
  opts@gsnDraw                     = False             ; Do not advance frame
  opts@gsnXAxisIrregular2Linear    = True
  opts@gsnYAxisIrregular2Linear    = True

  opts@vpWidthF                    = 1.0
  opts@vpHeightF                   = 0.5

  opts@cnFillMode                  = "AreaFill"
  opts@cnFillOn                    = True              ; Turn on filled contours
  opts@gsnSpreadColors             = True              ; use full colormap
  opts@gsnSpreadColorStart         = spreadstart1      ; start at color specified for variable
  opts@gsnSpreadColorEnd           = spreadend1        ; end at color specified for variable
  opts@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF              = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  opts@cnLinesOn                   = True              ; contour lines specified above  
  opts@cnLineLabelsOn              = True              ; line labels on specified above
  opts@cnInfoLabelOn               = False
  opts@cnMissingValFillColor       = "gray85"          ; missing value color
  opts@cnMissingValFillPattern     = 0                 ; fill in 
  
  opts@tiMainFontHeightF           = 0.03
  opts@tiXAxisString               = "Distance (km)"
  opts@tiXAxisOffsetYF             = 0.00
  opts@tiYAxisString               = "Height (m)"
  opts@tiXAxisFontHeightF          = 0.025             ; set font size for x axis
  opts@tmXBLabelFontHeightF        = 0.025             ; set tick mark label size for x axis
  opts@tiYAxisFontHeightF          = 0.025             ; set font size for y axis
  opts@tmYLLabelFontHeightF        = 0.025             ; set tick mark label size for y axis

  opts@lbLabelBarOn                = False             ; turn off individual label bars

  opts@tmXBMode                    = "Automatic"      ; specify the tick label spacing myself
  opts@tmXBMinorOn                 = True              
  opts@tmXBMinorPerMajor           = 5

; set polyres to show eta levels
   polyres                         = True
   polyres@gsMarkerIndex           = 16               ; polymarker style
   polyres@gsMarkerSizeF           = 4.               ; polymarker size
   polyres@gsMarkerColor           = "black"          ; polymarker color

;;;;;;;;;;;;;
; Plot 0 - observations (leave blank)
;;;;;;;;;;;;;
   opts0                           = True              ; plot mods desired
   ;opts0@gsnLeftString             = ""
   opts0@gsnFrame                  = False             ; Do not draw plot 
   opts0@gsnDraw                   = False             ; Do not advance frame
   opts0@tiMainString              = "GFDex - " + day + "UTC"
   opts0@tiMainFontHeightF         = 0.03
   opts0@vpWidthF                  = 1.0
   opts0@vpHeightF                 = 0.5

   cplot0 = gsn_blank_plot(wks,opts0)
   ;cplot0  = gsn_open_wks(wks,"blank")
   plot(0) = cplot0

;;;;;;;;;;;;;
; Plot 1 - WRF(10km) cross section
;;;;;;;;;;;;;

   opts1 = opts
   opts1@tiMainString              = "WRF (10km) - " + day 

   cplot1 = gsn_csm_contour(wks,data_hgt_1,opts1)

   if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
     dum4 = new(1, graphic)
     dum4 = gsn_add_polymarker(wks, cplot1, ypos, eta_levs_1, polyres)
   end if

   plot(1) = cplot1

;;;;;;;;;;;;;
; Plot 2 - WRF(25km) cross section
;;;;;;;;;;;;;

   opts2 = opts
   opts2@tiMainString              = "WRF (25km) - " + day 

  cplot2 = gsn_csm_contour(wks,data_hgt_2,opts2)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum5 = new(1, graphic)
    dum5 = gsn_add_polymarker(wks, cplot2, ypos, eta_levs_2, polyres)
  end if

  plot(2) = cplot2

;;;;;;;;;;;;;
; Plot 3 - WRF(50km) cross section
;;;;;;;;;;;;;

   opts3 = opts
   opts3@tiMainString              = "WRF (50km) - " + day 


  cplot3 = gsn_csm_contour(wks,data_hgt_3,opts3)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum6 = new(1, graphic)
    dum6 = gsn_add_polymarker(wks, cplot3, ypos, eta_levs_3, polyres)
  end if

  plot(3) = cplot3

;;;;;;;;;;;;;
; Plot 4 - WRF(100km) cross section
;;;;;;;;;;;;;

   opts4 = opts
   opts4@tiMainString              = "WRF (100km) - " + day 

  cplot4 = gsn_csm_contour(wks,data_hgt_4,opts4)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum7 = new(1, graphic)
    dum7 = gsn_add_polymarker(wks, cplot4, ypos, eta_levs_4, polyres)
  end if

  plot(4) = cplot4

;;;;;;;;;;;;;
; Plot 5 - ERA-I cross section
;;;;;;;;;;;;;

   opts5 = opts
   opts5@tiMainString              = "ERA-Interim (1.5 deg) - " + day + " " + ehr + "UTC"

  cplot5 = gsn_csm_contour(wks,data_hgt_5,opts5)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum8 = new(1, graphic)
    dum8 = gsn_add_polymarker(wks, cplot5, ypos, eta_levs_5, polyres)
  end if

  plot(5) = cplot5


;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;

 titlef = "GFDex, WRF, and ERA-Interim total wind speed at cross section"

  pnlres                            = True
  pnlres@txString                   = titlef           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.01
  ;pnlres@gsnPanelRowSpec            = True
  ;pnlres@gsnPanelCenter             = False
  ;pnlres@gsnPanelRight              = True
  gsn_panel(wks,plot,(/2,3/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(convert_cmd)
  delete(opts)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script
end

