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

; inputs from cshell file
name = "21FEB"
day = "2007-02-21"
whr = "14"
ehr = "12"
varcode = "Froude"
cross_type = "1"

; BEGIN SCRIPT
; getting correct directories
dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_10km/"
dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_25km/"
dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_50km/"
dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_100km/"

; set if this is a zoomed plot or the whole domain
   zoom = True
   whole_dom = False
; set if want eta level spacing plotted along side of cross section
   plot_eta = True

; set outdir and fout names
   outdir = "./"
   fout   = outdir+varcode+"_MWR_cross_section"+cross_type+"_"+day+"_"+whr+"_"+ehr

  print("Processing cross section plots for "+varcode+" "+day)

;;;;;;;;;;
; Use varcode to set variable information
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
  if (varcode.eq."Froude") then
    vartitle1 = "Total Wind Speed at Cross Section"
    invar1 = "u_tr_e"
    invar2 = "v_tr_e"
    invar3 = "Th_e"
    vartype = "3d"
    cmaptype = "froude"
    unit = " "
    find_speed = True
  end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."froude") then
    cmin1 = 0
    cmax1 = 1.
    clev1 = 0.1
    stride1             = 2                  ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart1        = 2                  ; start at color- cross section
    spreadend1          = 11                 ; end at color
    colormap            = "temp_diff_18lev"
  end if
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be on eta levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Loading wrf data")
;;;;;;;;;;;;;
; first wrf file (10km)
;;;;;;;;;;;;;
  f1 = addfile(dir1 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
  lat2d_1  = f1->lat
  lon2d_1  = f1->lon
  eta_1    = f1->eta
  n_eta_1  = dimsizes(eta_1)
  n_eta = n_eta_1 - 1  ; for loops later.
  Z_sfc_1  = f1->Z_sfc(south_north|:,west_east|:)
  Z_e_1    = f1->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
  var1_1  = f1->$invar1$(time|0,eta|:,south_north|:,west_east|:)
  var2_1  = f1->$invar2$(time|0,eta|:,south_north|:,west_east|:)
  var3_1  = f1->$invar3$(time|0,eta|:,south_north|:,west_east|:)

;;;;;;;;;;;;;
; second wrf file (25km)
;;;;;;;;;;;;;
  f2 = addfile(dir2 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
  lat2d_2  = f2->lat
  lon2d_2  = f2->lon
  eta_2    = f2->eta
  n_eta_2  = dimsizes(eta_2)
  Z_sfc_2  = f2->Z_sfc(south_north|:,west_east|:)
  Z_e_2    = f2->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
  var1_2  = f2->$invar1$(time|0,eta|:,south_north|:,west_east|:)
  var2_2  = f2->$invar2$(time|0,eta|:,south_north|:,west_east|:)
  var3_2  = f2->$invar3$(time|0,eta|:,south_north|:,west_east|:)

;;;;;;;;;;;;;
; third wrf file (50km)
;;;;;;;;;;;;;
  f3 = addfile(dir3 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
  lat2d_3  = f3->lat
  lon2d_3  = f3->lon
  eta_3    = f3->eta
  n_eta_3  = dimsizes(eta_3)
  Z_sfc_3  = f3->Z_sfc(south_north|:,west_east|:)
  Z_e_3    = f3->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
  var1_3  = f3->$invar1$(time|0,eta|:,south_north|:,west_east|:)
  var2_3  = f3->$invar2$(time|0,eta|:,south_north|:,west_east|:)
  var3_3  = f3->$invar3$(time|0,eta|:,south_north|:,west_east|:)
  
;;;;;;;;;;;;;
; fourth wrf file (100km)
;;;;;;;;;;;;;
  f4 = addfile(dir4 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
  lat2d_4  = f4->lat
  lon2d_4  = f4->lon
  eta_4    = f4->eta
  n_eta_4  = dimsizes(eta_4)
  Z_sfc_4  = f4->Z_sfc(south_north|:,west_east|:)
  Z_e_4    = f4->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
  var1_4  = f4->$invar1$(time|0,eta|:,south_north|:,west_east|:)
  var2_4  = f4->$invar2$(time|0,eta|:,south_north|:,west_east|:)
  var3_4  = f4->$invar3$(time|0,eta|:,south_north|:,west_east|:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Horizontally Interpolate to cross section line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set start and end lons and lats
; npts is cross section specific to give 2km horiz resolution
; GFDX Cross section - Northern leg
  if (cross_type .eq. "1") then
    st_lat = 62.0
    st_lon = -45.0
;    st_lon = -43.0
;    st_lon = -42.0
    ed_lat = 62.0
    ed_lon = -40.0
    npts = 140
;    npts = 78
;    npts   = 54
  end if
; GFDX Cross section - Southern leg
  if (cross_type .eq. "2") then
    st_lat = 60.1
    st_lon = -43.1
    ed_lat = 59.25
    ed_lon = -40.0
    npts   = 101
  end if

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat, st_lon, ed_lat, ed_lon, npts, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space = length@spacing       ; the spacing of the points in integer km 
   n_cross = dimsizes(lats)

  ; create distance array to plot values
   dist = new((/n_cross/),"float")
   km = 0.
   do i = 0, n_cross-1
     dist(i) = km
     km = km + space
   end do
   dist!0 = "Horizontal"
   dist@units = "km" 
   delete(i)

; set cressman radius based on resolution of wrf output
     cressrad_1 = 10.            
     cressrad_2 = 25.            
     cressrad_3 = 50.            
     cressrad_4 = 101.

print("Interpolating to cross section line")
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

; get 1D lats and lons
  lat1d_1 = ndtooned(lat2d_1)
  lon1d_1 = ndtooned(lon2d_1)

  lat1d_2 = ndtooned(lat2d_2)
  lon1d_2 = ndtooned(lon2d_2)

  lat1d_3 = ndtooned(lat2d_3)
  lon1d_3 = ndtooned(lon2d_3)

  lat1d_4 = ndtooned(lat2d_4)
  lon1d_4 = ndtooned(lon2d_4)

; get 1D surface arrays
  Z_sfc_1d_1 = ndtooned(Z_sfc_1)
  Z_sfc_sub_1  = new((/n_cross/),"float")

  Z_sfc_1d_2 = ndtooned(Z_sfc_2)
  Z_sfc_sub_2  = new((/n_cross/),"float")

  Z_sfc_1d_3 = ndtooned(Z_sfc_3)
  Z_sfc_sub_3  = new((/n_cross/),"float")

  Z_sfc_1d_4 = ndtooned(Z_sfc_4)
  Z_sfc_sub_4  = new((/n_cross/),"float")

; preallocate arrays for subset of each variable
  var1_sub_1   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_1    = new((/n_eta_1,n_cross/),"float") 
 
  var1_sub_2   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_2    = new((/n_eta_1,n_cross/),"float")

  var1_sub_3   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_3    = new((/n_eta_1,n_cross/),"float")

  var1_sub_4   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_4    = new((/n_eta_1,n_cross/),"float")

  if (isvar("find_speed").and.(find_speed)) then
    var2_sub_1 = new((/n_eta_1,n_cross/),"float")
    var2_sub_2 = new((/n_eta_1,n_cross/),"float")
    var2_sub_3 = new((/n_eta_1,n_cross/),"float")
    var2_sub_4 = new((/n_eta_1,n_cross/),"float")

    var3_sub_1 = new((/n_eta_1,n_cross/),"float")
    var3_sub_2 = new((/n_eta_1,n_cross/),"float")
    var3_sub_3 = new((/n_eta_1,n_cross/),"float")
    var3_sub_4 = new((/n_eta_1,n_cross/),"float")
  end if

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_1 = gc_latlon(lats(i),lons(i),lat1d_1, lon1d_1, 2, 4)  
    dist_rad_2 = gc_latlon(lats(i),lons(i),lat1d_2, lon1d_2, 2, 4) 
    dist_rad_3 = gc_latlon(lats(i),lons(i),lat1d_3, lon1d_3, 2, 4) 
    dist_rad_4 = gc_latlon(lats(i),lons(i),lat1d_4, lon1d_4, 2, 4) 

   ; if the great circle yields some NaNs (topography related, etc), deal with these
    if (any(isnan_ieee(dist_rad_1))) then       
      nreplacements = num(isnan_ieee(dist_rad_1))  ; find index of NaN
      replace_ieeenan(dist_rad_1,0.,0)             ; replace the NaN with 0
      print("file 1: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if
    if (any(isnan_ieee(dist_rad_2))) then       
      nreplacements = num(isnan_ieee(dist_rad_2))  ; find index of NaN
      replace_ieeenan(dist_rad_2,0.,0)             ; replace the NaN with 0
      print("file 2: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if
    if (any(isnan_ieee(dist_rad_3))) then       
      nreplacements = num(isnan_ieee(dist_rad_3))  ; find index of NaN
      replace_ieeenan(dist_rad_3,0.,0)             ; replace the NaN with 0
      print("file 3: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if
    if (any(isnan_ieee(dist_rad_4))) then       
      nreplacements = num(isnan_ieee(dist_rad_4))  ; find index of NaN
      replace_ieeenan(dist_rad_4,0.,0)             ; replace the NaN with 0
      print("file 4: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad_1).gt.cressrad_1) then        
      print("file 1: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if
    if (min(dist_rad_2).gt.cressrad_2) then        
      print("file 2: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if
    if (min(dist_rad_3).gt.cressrad_3) then        
      print("file 3: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if
    if (min(dist_rad_4).gt.cressrad_4) then        
      print("file 4: Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    ; get indicies and weights of points
    indicies_1 = ind(dist_rad_1.lt.cressrad_1)    ; indicies where distance is in cressman radius
    weight_1 = (cressrad_1^2 - dist_rad_1(indicies_1)^2) / (cressrad_1^2 + dist_rad_1(indicies_1)^2)  ; assign weights

    indicies_2 = ind(dist_rad_2.lt.cressrad_2)    ; indicies where distance is in cressman radius
    weight_2 = (cressrad_2^2 - dist_rad_2(indicies_2)^2) / (cressrad_2^2 + dist_rad_2(indicies_2)^2)  ; assign weights

    indicies_3 = ind(dist_rad_3.lt.cressrad_3)    ; indicies where distance is in cressman radius
    weight_3 = (cressrad_3^2 - dist_rad_3(indicies_3)^2) / (cressrad_3^2 + dist_rad_3(indicies_3)^2)  ; assign weights

    indicies_4 = ind(dist_rad_4.lt.cressrad_4)    ; indicies where distance is in cressman radius
    weight_4 = (cressrad_4^2 - dist_rad_4(indicies_4)^2) / (cressrad_4^2 + dist_rad_4(indicies_4)^2)  ; assign weights

    ; calculate surface height subsets
    Z_sfc_sub_1(i)  = sum(Z_sfc_1d_1(indicies_1)*weight_1)/sum(weight_1)
    Z_sfc_sub_2(i)  = sum(Z_sfc_1d_2(indicies_2)*weight_2)/sum(weight_2)
    Z_sfc_sub_3(i)  = sum(Z_sfc_1d_3(indicies_3)*weight_3)/sum(weight_3)
    Z_sfc_sub_4(i)  = sum(Z_sfc_1d_4(indicies_4)*weight_4)/sum(weight_4)

    ; calculate the new variable and geopotential heights
    do j = 0, n_eta-1 
   
      ; flatten the eta level of interest 
      var1_1d_1 = ndtooned(var1_1(j,:,:))    
      Z_e_1d_1  = ndtooned(Z_e_1(j,:,:))

      var1_1d_2 = ndtooned(var1_2(j,:,:))    
      Z_e_1d_2  = ndtooned(Z_e_2(j,:,:))

      var1_1d_3 = ndtooned(var1_3(j,:,:))    
      Z_e_1d_3  = ndtooned(Z_e_3(j,:,:))

      var1_1d_4 = ndtooned(var1_4(j,:,:))    
      Z_e_1d_4  = ndtooned(Z_e_4(j,:,:))

      ; calculate new array for variable and geopZ
      var1_sub_1(j,i) =  sum(var1_1d_1(indicies_1)*weight_1)/sum(weight_1)
      Z_e_sub_1(j,i)  =  sum(Z_e_1d_1(indicies_1)*weight_1)/sum(weight_1)

      var1_sub_2(j,i) =  sum(var1_1d_2(indicies_2)*weight_2)/sum(weight_2)
      Z_e_sub_2(j,i)  =  sum(Z_e_1d_2(indicies_2)*weight_2)/sum(weight_2)

      var1_sub_3(j,i) =  sum(var1_1d_3(indicies_3)*weight_3)/sum(weight_3)
      Z_e_sub_3(j,i)  =  sum(Z_e_1d_3(indicies_3)*weight_3)/sum(weight_3)

      var1_sub_4(j,i) =  sum(var1_1d_4(indicies_4)*weight_4)/sum(weight_4)
      Z_e_sub_4(j,i)  =  sum(Z_e_1d_4(indicies_4)*weight_4)/sum(weight_4)

      if (isvar("find_speed").and.(find_speed)) then
        var2_1d_1 = ndtooned(var2_1(j,:,:))
        var2_sub_1(j,i) = sum(var2_1d_1(indicies_1)*weight_1)/sum(weight_1)
 
        var2_1d_2 = ndtooned(var2_2(j,:,:))
        var2_sub_2(j,i) = sum(var2_1d_2(indicies_2)*weight_2)/sum(weight_2)

        var2_1d_3 = ndtooned(var2_3(j,:,:))
        var2_sub_3(j,i) = sum(var2_1d_3(indicies_3)*weight_3)/sum(weight_3)

        var2_1d_4 = ndtooned(var2_4(j,:,:))
        var2_sub_4(j,i) = sum(var2_1d_4(indicies_4)*weight_4)/sum(weight_4)

        delete(var2_1d_1)
        delete(var2_1d_2)
        delete(var2_1d_3)
        delete(var2_1d_4)

       var3_1d_1 = ndtooned(var3_1(j,:,:))
        var3_sub_1(j,i) = sum(var3_1d_1(indicies_1)*weight_1)/sum(weight_1)
 
        var3_1d_2 = ndtooned(var3_2(j,:,:))
        var3_sub_2(j,i) = sum(var3_1d_2(indicies_2)*weight_2)/sum(weight_2)

        var3_1d_3 = ndtooned(var3_3(j,:,:))
        var3_sub_3(j,i) = sum(var3_1d_3(indicies_3)*weight_3)/sum(weight_3)

        var3_1d_4 = ndtooned(var3_4(j,:,:))
        var3_sub_4(j,i) = sum(var3_1d_4(indicies_4)*weight_4)/sum(weight_4)

        delete(var3_1d_1)
        delete(var3_1d_2)
        delete(var3_1d_3)
        delete(var3_1d_4)
      end if

      delete(var1_1d_1)
      delete(Z_e_1d_1)
      delete(var1_1d_2)
      delete(Z_e_1d_2)
      delete(var1_1d_3)
      delete(Z_e_1d_3)
      delete(var1_1d_4)
      delete(Z_e_1d_4)

    end do

    delete(indicies_1)
    delete(weight_1)
    delete(indicies_2)
    delete(weight_2)
    delete(indicies_3)
    delete(weight_3)
    delete(indicies_4)
    delete(weight_4)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(var1_1, var1_sub_1)
  copy_VarAtts(var1_2, var1_sub_2)
  copy_VarAtts(var1_3, var1_sub_3)
  copy_VarAtts(var1_4, var1_sub_4)
  copy_VarAtts(Z_e_1, Z_e_sub_1)
  copy_VarAtts(Z_e_2, Z_e_sub_2)
  copy_VarAtts(Z_e_3, Z_e_sub_3)
  copy_VarAtts(Z_e_4, Z_e_sub_4)
  copy_VarAtts(Z_sfc_1, Z_sfc_sub_1)
  copy_VarAtts(Z_sfc_2, Z_sfc_sub_2)
  copy_VarAtts(Z_sfc_3, Z_sfc_sub_3)
  copy_VarAtts(Z_sfc_4, Z_sfc_sub_4)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate wind par and perp to cross section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (isvar("find_speed").and.(find_speed)) then
  pi = 3.14159265
  r2d = 45.0/atan(1.0)

   ; get wind direction
    wd_1 = atan2(var1_sub_1,var2_sub_1)*r2d+180        
    wd_1@long_name = "Wind Direction"
    wd_1@units = "degrees"
    wd_1!0 = "eta"                           ; name dimensions
    wd_1!1 = "distance"
   
    wd_2 = atan2(var1_sub_2,var2_sub_2)*r2d+180        
    wd_3 = atan2(var1_sub_3,var2_sub_3)*r2d+180        
    wd_4 = atan2(var1_sub_4,var2_sub_4)*r2d+180
    copy_VarMeta(wd_1, wd_2)
    copy_VarMeta(wd_1, wd_3)
    copy_VarMeta(wd_1, wd_4)

   ; get net wind speed 
    ws_1 = sqrt(var1_sub_1^2 + var2_sub_1^2)
    ws_1@units = "m s-1"
    ws_1@long_name = "Wind Speed"
    ws_1@standard_name = "wind speed"

    ws_2 = sqrt(var1_sub_2^2 + var2_sub_2^2)
    ws_3 = sqrt(var1_sub_3^2 + var2_sub_3^2)
    ws_4 = sqrt(var1_sub_4^2 + var2_sub_4^2)
    copy_VarMeta(ws_1, ws_2)
    copy_VarMeta(ws_1, ws_3)
    copy_VarMeta(ws_1, ws_4)

    ; get rid of unused data
    delete(var2_sub_1)
    delete(var2_sub_2)
    delete(var2_sub_3)
    delete(var2_sub_4)

   ; get wind heading
    wd_head_1 = wd_1                            ; preallocate wind direction array
    wd_head_1@long_name = "Wind Direction Heading"

    wd_head_2 = wd_2                            ; preallocate wind direction array
    wd_head_3 = wd_3                            ; preallocate wind direction array
    wd_head_4 = wd_4                            ; preallocate wind direction array

    do aa = 0,n_eta-1  ; loop through eta levels
      do bb = 0,n_cross-1  ; loop through distances
        x_1 = wd_1(aa,bb)-180.0   ; subtract 180 degrees from wind dir to get heading
        if (x_1 .lt.0.0) then
          wd_head_1(aa,bb) = x_1+360.0
        else
          wd_head_1(aa,bb) = x_1
        end if
        delete(x_1)
      end do
    end do 

    do aa = 0,n_eta-1  ; loop through eta levels
      do bb = 0,n_cross-1  ; loop through distances
        x_2 = wd_2(aa,bb)-180.0   ; subtract 180 degrees from wind dir to get heading
        if (x_2 .lt.0.0) then
          wd_head_2(aa,bb) = x_2+360.0
        else
          wd_head_2(aa,bb) = x_2
        end if
        delete(x_2)
      end do
    end do 

    do aa = 0,n_eta-1  ; loop through eta levels
      do bb = 0,n_cross-1  ; loop through distances
        x_3 = wd_3(aa,bb)-180.0   ; subtract 180 degrees from wind dir to get heading
        if (x_3 .lt.0.0) then
          wd_head_3(aa,bb) = x_3+360.0
        else
          wd_head_3(aa,bb) = x_3
        end if
        delete(x_3)
      end do
    end do 

    do aa = 0,n_eta-1  ; loop through eta levels
      do bb = 0,n_cross-1  ; loop through distances
        x_4 = wd_4(aa,bb)-180.0   ; subtract 180 degrees from wind dir to get heading
        if (x_4 .lt.0.0) then
          wd_head_4(aa,bb) = x_4+360.0
        else
          wd_head_4(aa,bb) = x_4
        end if
        delete(x_4)
      end do
    end do 

  ; get cross section heading
    ed = n_cross-1       ; position of the end of the cross section
    dist_tot = length    ; total length of cross section in km

    del_lat = ed_lat - st_lat ; find the change in latitude degrees
    lat_dist = 111.5*del_lat  ; find the change in latitude in km
                              ; assumes 1deg Lat = 111.5km at 65N
                              ; a neg. value means lat decreasing over the cross section
                              ; calc. of heading (below) correctly interpets either sign

    cr_head = acos(lat_dist/dist_tot)*(180/pi)  ; this is the cross section heading

    alpha_1 = (cr_head - wd_head_1)*(pi/180)        ; angle between the headings in radians
    alpha_2 = (cr_head - wd_head_2)*(pi/180)
    alpha_3 = (cr_head - wd_head_3)*(pi/180)
    alpha_4 = (cr_head - wd_head_4)*(pi/180)

    parl_wind_1 = ws_1   ; preallocate parallel wind component
    perp_wind_1 = ws_1   ; preallocate perpendicular wind component

    parl_wind_2 = ws_2
    perp_wind_2 = ws_2 
    parl_wind_3 = ws_3
    perp_wind_3 = ws_3
    parl_wind_4 = ws_4
    perp_wind_4 = ws_4

    aa = 0
    bb = 0
    cc = 0
    do aa = 0,n_eta-1  ; loop through eta levels 
      do bb = 0,n_cross-1  ; loop through distances
        parl_wind_1(aa,bb) = ws_1(aa,bb)*cos(alpha_1(aa,bb))    ; positive values are left to right
        perp_wind_1(aa,bb) = ws_1(aa,bb)*sin(alpha_1(aa,bb))    ; positive values are into the cross sect

        parl_wind_2(aa,bb) = ws_2(aa,bb)*cos(alpha_2(aa,bb))
        perp_wind_2(aa,bb) = ws_2(aa,bb)*sin(alpha_2(aa,bb))
        parl_wind_3(aa,bb) = ws_3(aa,bb)*cos(alpha_3(aa,bb))
        perp_wind_3(aa,bb) = ws_3(aa,bb)*sin(alpha_3(aa,bb))
        parl_wind_4(aa,bb) = ws_4(aa,bb)*cos(alpha_4(aa,bb))
        perp_wind_4(aa,bb) = ws_4(aa,bb)*sin(alpha_4(aa,bb))
      end do
    end do

    delete(var1_sub_1)
    delete(var1_sub_2)
    delete(var1_sub_3)
    delete(var1_sub_4)


    if (varcode .eq. "TotWind")
      var1_sub_1 = ws_1
      var1_sub_2 = ws_2
      var1_sub_3 = ws_3
      var1_sub_4 = ws_4
    end if
    if (varcode .eq. "PerpWind")
      var1_sub_1 = perp_wind_1
      var1_sub_2 = perp_wind_2
      var1_sub_3 = perp_wind_3
      var1_sub_4 = perp_wind_4
    end if
    ; for froude number use wind parallel to cross section (into the barrier)
    if (varcode .eq. "ParlWind")
      var1_sub_1 = parl_wind_1
      var1_sub_2 = parl_wind_2
      var1_sub_3 = parl_wind_3
      var1_sub_4 = parl_wind_4
    end if

  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate Froude number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Calculating Froude number for resolutions")
  g = 9.80665

  ; calcualte mountain heights for each resolution
  mtn_1 = max(Z_sfc_sub_1)
  mtn_2 = max(Z_sfc_sub_2)
  mtn_3 = max(Z_sfc_sub_3)
  mtn_4 = max(Z_sfc_sub_4)

  ; preallocate arrays for new froude data
  fr_data_1 = new((/n_eta_1,n_cross/),"float")
  fr_data_2 = new((/n_eta_1,n_cross/),"float")
  fr_data_3 = new((/n_eta_1,n_cross/),"float")
  fr_data_4 = new((/n_eta_1,n_cross/),"float")

  ; FIRST FILE
  print("Calculating Froude number for first file")
  ; Loop through cross section points and find froude number
  c = 0
  do a = 0,n_cross-1
    ; if the first eta level is at the highest mountain then no flow is blocked
    if (Z_e_sub_1(0,a) .gt. mtn_1)
          ; above mountain! Froude number >1
      do k = 0,n_eta_1 - 1
        fr_data_1(k,a) = 5
      end do

    ; flow is being blocked if first eta level is below mtn height
    else
      x = 0
      ; Determine the first eta level (x) above mtn height
      do while (Z_e_sub_1(x,a) .le. mtn_1)
        x = x+1
      end do
    
      ; x = first level above mtn. interpolate x to mtn.
      D_hgt = Z_e_sub_1(x-1,a)   ;; the height of the eta level below the height to interpolate to
      E_hgt = Z_e_sub_1(x,a)     ;; the height of the eta level above the height to interpolate to
      total_dist = E_hgt - D_hgt ;; the total distance between the eta levels surrounding the height to interpolate to 

      ; potential temperature gradient
      ; determine if pot temp increases with height
      if (var3_sub_1(x,a) .gt. var3_sub_1(x-1,a)) then
        wt = (mtn_1-D_hgt)/total_dist  ;; a weighting factor 
        var3_sub_1(x,a) = var3_sub_1(x-1,a)+((var3_sub_1(x,a)-var3_sub_1(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_1)/total_dist
        var3_sub_1(x,a) = var3_sub_1(x,a)+((var3_sub_1(x-1,a)-var3_sub_1(x,a))*wt)
      end if  
   
      ; parallel wind gradient
      ; determine if wind increases with height
      if (parl_wind_1(x,a) .gt. parl_wind_1(x-1,a)) then 
        wt = (mtn_1-D_hgt)/total_dist  ;; a weighting factor 
        parl_wind_1(x,a) = parl_wind_1(x-1,a)+((parl_wind_1(x,a)-parl_wind_1(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_1)/total_dist
        parl_wind_1(x,a) = parl_wind_1(x,a)+((parl_wind_1(x-1,a)-parl_wind_1(x,a))*wt)
      end if 

      Z_e_sub_1(x,a) = mtn_1
      
      do b=0, x-1
        do j=b, x-1

          ; make summation for froude calculation
          if(j.eq.b) then
            fr_sum=(((var3_sub_1(j+1,a)+var3_sub_1(j,a))/2)-var3_sub_1(b,a))*(Z_e_sub_1(j+1,a)-Z_e_sub_1(j,a))
          else
            fr_sum=(((var3_sub_1(j+1,a)+var3_sub_1(j,a))/2)-var3_sub_1(b,a))*(Z_e_sub_1(j+1,a)-Z_e_sub_1(j,a))+fr_sum
          end if
        end do

        ; if fr_sum<0 then it means we had unstable air, so the Froude number >1
        if (fr_sum .le. 0) then
          fr_data_1(b,a) = 5
        else
        ; check if wind is blowing into the cross section
          if(parl_wind_1(b,a).lt.0) then
            fr_data_1(b,a)=-parl_wind_1(b,a)/sqrt((g*fr_sum)/var3_sub_1(b,a))
          else  ; if wind not blowing into cross section then set the value < 0
            fr_data_1(b,a) = 5.
;            fr_data_1(b,a)=-.5
          end if
        end if

        fr_sum=0  ; set sum to zero for next iteration
      end do

      ; above mountain! Froude number >1
      do kk = x,n_eta_1 -1
        fr_data_1(kk,a) = 5
      end do
    end if
  end do
  delete(k)
  delete(kk)
  delete(b)
  delete(j)

  ; SECOND FILE
  print("Calculating Froude number for second file")
  ; Loop through cross section points and find froude number
  c = 0
  do a = 0,n_cross-1
    ; if the first eta level is at the highest mountain then no flow is blocked
    if (Z_e_sub_2(0,a) .gt. mtn_2)
          ; above mountain! Froude number >1
      do k = 0,n_eta_1 - 1
        fr_data_2(k,a) = 5
      end do

    ; flow is being blocked if first eta level is below mtn height
    else
      x = 0
      ; Determine the first eta level (x) above mtn height
      do while (Z_e_sub_2(x,a) .le. mtn_2)
        x = x+1
      end do
    
      ; x = first level above mtn. interpolate x to mtn.
      D_hgt = Z_e_sub_2(x-1,a)   ;; the height of the eta level below the height to interpolate to
      E_hgt = Z_e_sub_2(x,a)     ;; the height of the eta level above the height to interpolate to
      total_dist = E_hgt - D_hgt ;; the total distance between the eta levels surrounding the height to interpolate to 

      ; potential temperature gradient
      ; determine if pot temp increases with height
      if (var3_sub_2(x,a) .gt. var3_sub_2(x-1,a)) then
        wt = (mtn_2-D_hgt)/total_dist  ;; a weighting factor 
        var3_sub_2(x,a) = var3_sub_2(x-1,a)+((var3_sub_2(x,a)-var3_sub_2(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_2)/total_dist
        var3_sub_2(x,a) = var3_sub_2(x,a)+((var3_sub_2(x-1,a)-var3_sub_2(x,a))*wt)
      end if  
   
      ; parallel wind gradient
      ; determine if wind increases with height
      if (parl_wind_2(x,a) .gt. parl_wind_2(x-1,a)) then 
        wt = (mtn_2-D_hgt)/total_dist  ;; a weighting factor 
        parl_wind_2(x,a) = parl_wind_2(x-1,a)+((parl_wind_2(x,a)-parl_wind_2(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_2)/total_dist
        parl_wind_2(x,a) = parl_wind_2(x,a)+((parl_wind_2(x-1,a)-parl_wind_2(x,a))*wt)
      end if 

      Z_e_sub_2(x,a) = mtn_2
      
      do b=0, x-1
        do j=b, x-1

          ; make summation for froude calculation
          if(j.eq.b) then
            fr_sum=(((var3_sub_2(j+1,a)+var3_sub_2(j,a))/2)-var3_sub_2(b,a))*(Z_e_sub_2(j+1,a)-Z_e_sub_2(j,a))
          else
            fr_sum=(((var3_sub_2(j+1,a)+var3_sub_2(j,a))/2)-var3_sub_2(b,a))*(Z_e_sub_2(j+1,a)-Z_e_sub_2(j,a))+fr_sum
          end if
        end do

        ; if fr_sum<0 then it means we had unstable air, so the Froude number >1
        if (fr_sum .le. 0) then
          fr_data_2(b,a) = 5
        else
        ; check if wind is blowing into the cross section
          if(parl_wind_2(b,a).lt.0) then
            fr_data_2(b,a)=-parl_wind_2(b,a)/sqrt((g*fr_sum)/var3_sub_2(b,a))
          else  ; if wind not blowing into cross section then set the value < 0
            fr_data_2(b,a)=5.
;            fr_data_2(b,a)=-.5
          end if
        end if

        fr_sum=0  ; set sum to zero for next iteration
      end do

      ; above mountain! Froude number >1
      do kk = x,n_eta_1 -1
        fr_data_2(kk,a) = 5
      end do
    end if
  end do
  delete(k)
  delete(kk)
  delete(b)
  delete(j)

  ; THIRD FILE
  print("Calculating Froude number for third file")
  ; Loop through cross section points and find froude number
  c = 0
  do a = 0,n_cross-1
    ; if the first eta level is at the highest mountain then no flow is blocked
    if (Z_e_sub_3(0,a) .gt. mtn_3)
          ; above mountain! Froude number >1
      do k = 0,n_eta_1 - 1
        fr_data_3(k,a) = 5
      end do

    ; flow is being blocked if first eta level is below mtn height
    else
      x = 0
      ; Determine the first eta level (x) above mtn height
      do while (Z_e_sub_3(x,a) .le. mtn_3)
        x = x+1
      end do
    
      ; x = first level above mtn. interpolate x to mtn.
      D_hgt = Z_e_sub_3(x-1,a)   ;; the height of the eta level below the height to interpolate to
      E_hgt = Z_e_sub_3(x,a)     ;; the height of the eta level above the height to interpolate to
      total_dist = E_hgt - D_hgt ;; the total distance between the eta levels surrounding the height to interpolate to 

      ; potential temperature gradient
      ; determine if pot temp increases with height
      if (var3_sub_3(x,a) .gt. var3_sub_3(x-1,a)) then
        wt = (mtn_3-D_hgt)/total_dist  ;; a weighting factor 
        var3_sub_3(x,a) = var3_sub_3(x-1,a)+((var3_sub_3(x,a)-var3_sub_3(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_3)/total_dist
        var3_sub_3(x,a) = var3_sub_3(x,a)+((var3_sub_3(x-1,a)-var3_sub_3(x,a))*wt)
      end if  
   
      ; parallel wind gradient
      ; determine if wind increases with height
      if (parl_wind_3(x,a) .gt. parl_wind_3(x-1,a)) then 
        wt = (mtn_3-D_hgt)/total_dist  ;; a weighting factor 
        parl_wind_3(x,a) = parl_wind_3(x-1,a)+((parl_wind_3(x,a)-parl_wind_3(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_3)/total_dist
        parl_wind_3(x,a) = parl_wind_3(x,a)+((parl_wind_3(x-1,a)-parl_wind_3(x,a))*wt)
      end if 

      Z_e_sub_3(x,a) = mtn_3
      
      do b=0, x-1
        do j=b, x-1

          ; make summation for froude calculation
          if(j.eq.b) then
            fr_sum=(((var3_sub_3(j+1,a)+var3_sub_3(j,a))/2)-var3_sub_3(b,a))*(Z_e_sub_3(j+1,a)-Z_e_sub_3(j,a))
          else
            fr_sum=(((var3_sub_3(j+1,a)+var3_sub_3(j,a))/2)-var3_sub_3(b,a))*(Z_e_sub_3(j+1,a)-Z_e_sub_3(j,a))+fr_sum
          end if
        end do

        ; if fr_sum<0 then it means we had unstable air, so the Froude number >1
        if (fr_sum .le. 0) then
          fr_data_3(b,a) = 5
        else
        ; check if wind is blowing into the cross section
          if(parl_wind_3(b,a).lt.0) then
            fr_data_3(b,a)=-parl_wind_3(b,a)/sqrt((g*fr_sum)/var3_sub_3(b,a))
          else  ; if wind not blowing into cross section then set the value < 0
            fr_data_3(b,a) = 5.
;            fr_data_3(b,a)=-.5
          end if
        end if

        fr_sum=0  ; set sum to zero for next iteration
      end do
  
      ; above mountain! Froude number >1
      do kk = x,n_eta_1 -1
        fr_data_3(kk,a) = 5
      end do
    end if
  end do
  delete(k)
  delete(kk)
  delete(b)
  delete(j)

  ; FOURTH FILE
  print("Calculating Froude number for fourth file")
  ; Loop through cross section points and find froude number
  c = 0
  do a = 0,n_cross-1
    ; if the first eta level is at the highest mountain then no flow is blocked
    if (Z_e_sub_4(0,a) .gt. mtn_4)
          ; above mountain! Froude number >1
      do k = 0,n_eta_1 - 1
        fr_data_4(k,a) = 5
      end do

    ; flow is being blocked if first eta level is below mtn height
    else
      x = 0
      ; Determine the first eta level (x) above mtn height
      do while (Z_e_sub_4(x,a) .le. mtn_4)
        x = x+1
      end do
    
      ; x = first level above mtn. interpolate x to mtn.
      D_hgt = Z_e_sub_4(x-1,a)   ;; the height of the eta level below the height to interpolate to
      E_hgt = Z_e_sub_4(x,a)     ;; the height of the eta level above the height to interpolate to
      total_dist = E_hgt - D_hgt ;; the total distance between the eta levels surrounding the height to interpolate to 

      ; potential temperature gradient
      ; determine if pot temp increases with height
      if (var3_sub_4(x,a) .gt. var3_sub_4(x-1,a)) then
        wt = (mtn_4-D_hgt)/total_dist  ;; a weighting factor 
        var3_sub_4(x,a) = var3_sub_4(x-1,a)+((var3_sub_4(x,a)-var3_sub_4(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_4)/total_dist
        var3_sub_4(x,a) = var3_sub_4(x,a)+((var3_sub_4(x-1,a)-var3_sub_4(x,a))*wt)
      end if  
   
      ; parallel wind gradient
      ; determine if wind increases with height
      if (parl_wind_4(x,a) .gt. parl_wind_4(x-1,a)) then 
        wt = (mtn_4-D_hgt)/total_dist  ;; a weighting factor 
        parl_wind_4(x,a) = parl_wind_4(x-1,a)+((parl_wind_4(x,a)-parl_wind_4(x-1,a))*wt)
      else
        wt = (E_hgt-mtn_4)/total_dist
        parl_wind_4(x,a) = parl_wind_4(x,a)+((parl_wind_4(x-1,a)-parl_wind_4(x,a))*wt)
      end if 

      Z_e_sub_4(x,a) = mtn_4
      
      do b=0, x-1
        do j=b, x-1

          ; make summation for froude calculation
          if(j.eq.b) then
            fr_sum=(((var3_sub_4(j+1,a)+var3_sub_4(j,a))/2)-var3_sub_4(b,a))*(Z_e_sub_4(j+1,a)-Z_e_sub_4(j,a))
          else
            fr_sum=(((var3_sub_4(j+1,a)+var3_sub_4(j,a))/2)-var3_sub_4(b,a))*(Z_e_sub_4(j+1,a)-Z_e_sub_4(j,a))+fr_sum
          end if
        end do

        ; if fr_sum<0 then it means we had unstable air, so the Froude number >1
        if (fr_sum .le. 0) then
          fr_data_4(b,a) = 5
        else
        ; check if wind is blowing into the cross section
          if(parl_wind_4(b,a).lt.0) then
            fr_data_4(b,a)=-parl_wind_4(b,a)/sqrt((g*fr_sum)/var3_sub_4(b,a))
          else  ; if wind not blowing into cross section then set the value < 0
            fr_data_4(b,a)=5.
;            fr_data_4(b,a)=-.5
          end if
        end if

        fr_sum=0  ; set sum to zero for next iteration
      end do
  
      ; above mountain! Froude number >1
      do kk = x,n_eta_1 -1
        fr_data_4(kk,a) = 5
      end do
    end if
  end do
  delete(k)
  delete(kk)
  delete(b)
  delete(j)

  ; Reassign data for vertical interpolation and plotting
  var1_sub_1 = fr_data_1
  var1_sub_2 = fr_data_2
  var1_sub_3 = fr_data_3
  var1_sub_4 = fr_data_4

  var1_sub_1@units = " "
  var1_sub_1@long_name = "Froude number"
  var1_sub_1@standard_name = "Froude"

  copy_VarMeta(var1_sub_1, var1_sub_2)
  copy_VarMeta(var1_sub_1, var1_sub_3)
  copy_VarMeta(var1_sub_1, var1_sub_4)

print("Froude numbers calculated")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Vertical Interpolation to heights
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; create vertical spacing in meters
  hgts = ispan(0,4000,10)   ; modified to compare with Renfrew paper
  n_hgts = dimsizes(hgts)

print("Interpolating to height")

  ; create data at points and heights
  data_hgt_1 = new((/dimsizes(hgts),n_cross/),"float")
  data_hgt_1!0 = "Height"
  data_hgt_1!1 = "Horizontal"
  data_hgt_1&Height = hgts
  data_hgt_1&Horizontal = dist
  data_hgt_1@_FillValue = -999
  data_hgt_1@units = var1_sub_1@units
  data_hgt_1@long_name = var1_sub_1@long_name+" Interpolated"
  data_hgt_1@standard_name = var1_sub_1@standard_name

  data_hgt_2 = new((/dimsizes(hgts),n_cross/),"float")
  data_hgt_3 = new((/dimsizes(hgts),n_cross/),"float")
  data_hgt_4 = new((/dimsizes(hgts),n_cross/),"float")
  copy_VarMeta(data_hgt_1, data_hgt_2)
  copy_VarMeta(data_hgt_1, data_hgt_3)
  copy_VarMeta(data_hgt_1, data_hgt_4)

;; Loop through to to interpolate a value to each point in the data_hgt array
 do d=0, n_cross-1                   ; Loop through each point along distance
   do h=0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub_1(d) .lt. hgts(h)) then    ; If height to interp. to is above surface proceed
       f=0                                  ; if not, fill data_hgt with a missing value
       if (Z_e_sub_1(f,d) .lt. hgts(h)) then  ; If height to interp. to  is above first eta level proceed
                                            ; if not, fill data_hgt with a missing value
         
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub_1(f,d) .lt. hgts(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do

         A_hgt = Z_e_sub_1(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub_1(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgts(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to

         ; if variable increases with height linearly interp.
         if (var1_sub_1(f,d) .gt. var1_sub_1(f-1,d)) then  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           data_hgt_1(h,d) = var1_sub_1(f-1,d)+((var1_sub_1(f,d)-var1_sub_1(f-1,d))*wt)

         ; if variable decreases with height linearly interp.
         else                                  
           wt = (B_hgt-C_hgt)/total_dist
           data_hgt_1(h,d) = var1_sub_1(f,d)+((var1_sub_1(f-1,d)-var1_sub_1(f,d))*wt)
         end if
       else
         data_hgt_1(h,d)= -999
       end if
    else
      data_hgt_1(h,d) = -999
    end if
  end do
    ; Counter
    if(d%10.eq.0) then
      print("file1: created vert levels for "+d+" of "+n_cross)
    end if
 end do

; second file interpolate
 do d=0, n_cross-1                   ; Loop through each point along distance
   do h=0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub_2(d) .lt. hgts(h)) then    ; If height to interp. to is above surface proceed
       f=0                                  ; if not, fill data_hgt with a missing value
       if (Z_e_sub_2(f,d) .lt. hgts(h)) then  ; If height to interp. to  is above first eta level proceed
                                            ; if not, fill data_hgt with a missing value
         
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub_2(f,d) .lt. hgts(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do

         A_hgt = Z_e_sub_2(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub_2(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgts(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to

         ; if variable increases with height linearly interp.
         if (var1_sub_2(f,d) .gt. var1_sub_2(f-1,d)) then  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           data_hgt_2(h,d) = var1_sub_2(f-1,d)+((var1_sub_2(f,d)-var1_sub_2(f-1,d))*wt)

         ; if variable decreases with height linearly interp.
         else                                  
           wt = (B_hgt-C_hgt)/total_dist
           data_hgt_2(h,d) = var1_sub_2(f,d)+((var1_sub_2(f-1,d)-var1_sub_2(f,d))*wt)
         end if
       else
         data_hgt_2(h,d)= -999
       end if
    else
      data_hgt_2(h,d) = -999
    end if
  end do
    ; Counter
    if(d%10.eq.0) then
      print("file2: created vert levels for "+d+" of "+n_cross)
    end if
 end do

; third file interpolate
 do d=0, n_cross-1                   ; Loop through each point along distance
   do h=0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub_3(d) .lt. hgts(h)) then    ; If height to interp. to is above surface proceed
       f=0                                  ; if not, fill data_hgt with a missing value
       if (Z_e_sub_3(f,d) .lt. hgts(h)) then  ; If height to interp. to  is above first eta level proceed
                                            ; if not, fill data_hgt with a missing value
         
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub_3(f,d) .lt. hgts(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do

         A_hgt = Z_e_sub_3(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub_3(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgts(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to

         ; if variable increases with height linearly interp.
         if (var1_sub_3(f,d) .gt. var1_sub_3(f-1,d)) then  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           data_hgt_3(h,d) = var1_sub_3(f-1,d)+((var1_sub_3(f,d)-var1_sub_3(f-1,d))*wt)

         ; if variable decreases with height linearly interp.
         else                                  
           wt = (B_hgt-C_hgt)/total_dist
           data_hgt_3(h,d) = var1_sub_3(f,d)+((var1_sub_3(f-1,d)-var1_sub_3(f,d))*wt)
         end if
       else
         data_hgt_3(h,d)= -999
       end if
    else
      data_hgt_3(h,d) = -999
    end if
  end do
    ; Counter
    if(d%10.eq.0) then
      print("file3: created vert levels for "+d+" of "+n_cross)
    end if
 end do

; fourth file interpolate
 do d=0, n_cross-1                   ; Loop through each point along distance
   do h=0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub_4(d) .lt. hgts(h)) then    ; If height to interp. to is above surface proceed
       f=0                                  ; if not, fill data_hgt with a missing value
       if (Z_e_sub_4(f,d) .lt. hgts(h)) then  ; If height to interp. to  is above first eta level proceed
                                            ; if not, fill data_hgt with a missing value
         
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub_4(f,d) .lt. hgts(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do

         A_hgt = Z_e_sub_4(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub_4(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgts(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to

         ; if variable increases with height linearly interp.
         if (var1_sub_4(f,d) .gt. var1_sub_4(f-1,d)) then  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           data_hgt_4(h,d) = var1_sub_4(f-1,d)+((var1_sub_4(f,d)-var1_sub_4(f-1,d))*wt)

         ; if variable decreases with height linearly interp.
         else                                  
           wt = (B_hgt-C_hgt)/total_dist
           data_hgt_4(h,d) = var1_sub_4(f,d)+((var1_sub_4(f-1,d)-var1_sub_4(f,d))*wt)
         end if
       else
         data_hgt_4(h,d)= -999
       end if
    else
      data_hgt_4(h,d) = -999
    end if
  end do
    ; Counter
    if(d%10.eq.0) then
      print("file4: created vert levels for "+d+" of "+n_cross)
    end if
 end do

;;;;;;;;;;
; Get eta level spacing
;;;;;;;;;;
 if (isvar("plot_eta").and.(plot_eta))then
  ; to be plotted along the cross section to give idea of eta level spacing
   eta_levs_1 = new((/n_eta/),"float")
   eta_levs_2 = new((/n_eta/),"float")
   eta_levs_3 = new((/n_eta/),"float")
   eta_levs_4 = new((/n_eta/),"float")

   ypos     = new((/n_eta/),"float")
   
   do n = 0,n_eta-1
     temp1 = avg(Z_e_sub_1(n,:))
     eta_levs_1(n) = temp1
     temp2 = avg(Z_e_sub_2(n,:))
     eta_levs_2(n) = temp2
     temp3 = avg(Z_e_sub_3(n,:))
     eta_levs_3(n) = temp3
     temp4 = avg(Z_e_sub_4(n,:))
     eta_levs_4(n) = temp4

     ypos(n) = dist(n_cross-1)
     delete(temp1)
     delete(temp2)
     delete(temp3)
     delete(temp4)
   end do
 end if


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
; Plot 0 - WRF(10km) cross section
;;;;;;;;;;;;;

   opts1 = opts
   opts1@tiMainString              = "WRF (10km) - " + day + " " + whr + "UTC" 

   cplot1 = gsn_csm_contour(wks,data_hgt_1,opts1)

   if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
     dum4 = new(1, graphic)
     dum4 = gsn_add_polymarker(wks, cplot1, ypos, eta_levs_1, polyres)
   end if

   plot(0) = cplot1

;;;;;;;;;;;;;
; Plot 1 - WRF(25km) cross section
;;;;;;;;;;;;;

   opts2 = opts
   opts2@tiMainString              = "WRF (25km) - " + day + " " + whr + "UTC"

  cplot2 = gsn_csm_contour(wks,data_hgt_2,opts2)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum5 = new(1, graphic)
    dum5 = gsn_add_polymarker(wks, cplot2, ypos, eta_levs_2, polyres)
  end if

  plot(1) = cplot2

;;;;;;;;;;;;;
; Plot 2 - WRF(50km) cross section
;;;;;;;;;;;;;

   opts3 = opts
   opts3@tiMainString              = "WRF (50km) - " + day + " " + whr + "UTC"


  cplot3 = gsn_csm_contour(wks,data_hgt_3,opts3)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum6 = new(1, graphic)
    dum6 = gsn_add_polymarker(wks, cplot3, ypos, eta_levs_3, polyres)
  end if

  plot(2) = cplot3

;;;;;;;;;;;;;
; Plot 3 - WRF(100km) cross section
;;;;;;;;;;;;;

   opts4 = opts
   opts4@tiMainString              = "WRF (100km) - " + day + " " + whr + "UTC"

  cplot4 = gsn_csm_contour(wks,data_hgt_4,opts4)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum7 = new(1, graphic)
    dum7 = gsn_add_polymarker(wks, cplot4, ypos, eta_levs_4, polyres)
  end if

  plot(3) = cplot4

;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;

 titlef = "WRF froude number at cross section"

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

