;***************************************
; PROGRAM DESCRIPTION: This NCL script makes cross section plots of WRF data
; INPUT DATA: WRF output at four resolutions and ERA-I data from met-em file
; OUTPUT DATA: Panel plot of equivalent potential temperature for each resolution
; Note: This script works only for 2 March
; CREATORS: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin

; inputs from cshell file
name = "02MAR"
day = "2007-03-02"
whr = "12"
ehr = "12"
varcode = "EPotTemp"
cross_type = "2"

; BEGIN SCRIPT
; getting correct directories
dir1 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_10km/"
dir2 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_25km/"
dir3 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_50km/"
dir4 = "/data3/duvivier/NCAR/DATA/" + name + "/wrf_100km/"
dir5 = "/data3/duvivier/NCAR/DATA/" + name + "/era_i/"

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
  if (varcode.eq."EPotTemp") then
    vartitle1 = "Equivalent Potential Temperature"
    invar2 = "p_e"
    invar3 = "q_e"
    invar4 = "Th_e"
    invar5 = "T_e"
    vartype = "3d"
    cmaptype = "epottemp"
    unit = "K"
    find_equiv = True
  end if


; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."epottemp") then
    cmin1 = 254.
    cmax1 =290.
    clev1 = 2
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill" 
    spreadstart1        = 22                ; start at color- cross section
    spreadend1          = 65                ; end at color 
    colormap            = "temp64_anoms.dave"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be on eta levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set constants
R = 287.          ; [J/kg K] 
cp = 1004.        ; [J/kg K]
Lv = 2.5 * 10.^6  ; [J/kg]


print("Loading wrf data")
;;;;;;;;;;;;;
; first wrf file (10km)
;;;;;;;;;;;;;
   f1 = addfile(dir1 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
   lat2d_1  = f1->lat
   lon2d_1  = f1->lon
   eta_1    = f1->eta
   n_eta_1  = dimsizes(eta_1)
   n_eta = n_eta_1 - 1  ; for loops later ; THIS HAS BEEN CHANGED FOR ERA I MET LEVELS
   siz1 = dimsizes(lat2d_1)
   nlat_1 = siz1(0)
   nlon_1 = siz1(1)

   Z_sfc_1  = f1->Z_sfc(south_north|:,west_east|:)
   Z_e_1    = f1->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
   var2_1  = f1->$invar2$(time|0,eta|:,south_north|:,west_east|:) ; get press[hPa]
   var3_1  = f1->$invar3$(time|0,eta|:,south_north|:,west_east|:) ; get mixrad[kg/kg]
   var4_1  = f1->$invar4$(time|0,eta|:,south_north|:,west_east|:) ; get pottemp[K]
   var5_1  = f1->$invar5$(time|0,eta|:,south_north|:,west_east|:) ; get temp[K]

   var3_1 = where(var3_1 .lt. 0, 0, var3_1)

  ; calculate equivalent potential temperature at each grid cell
   var1_1  = new((/n_eta, nlat_1, nlon_1/), "float")           ; preallocate epottemp array

   do i = 0, n_eta - 1               ; loop through eta levels
     do j = 0, nlat_1 - 1            ; loop through south_north
       do k = 0, nlon_1 - 1          ; loop through west_east
         p0  = var2_1 (i, j, k)      ; initial pressure
         q0  = var3_1 (i, j, k)      ; initial mixing ratio
         pt0 = var4_1 (i, j, k)      ; initial potential temperature
         t0  = var5_1 (i, j, k)      ; initial temperature
         
         q = 0.                      ; get loops started
         p1 = p0                      ; initial temperature is 1mb less than start
         t1 = t0
         do while ( q .le. q0)
           p2 = p1 - .2                 ; new press. (mb) is .2mb less than prev. pressure
           t2 = t1 * (p2/p1)^(R/cp)    ; new temp. (K) if lifted dry adiabatically
           t2_c = t2 - 273.15          ; convert temp to celsius for clausius clapyeron
           es = 0.6112 * exp((17.67*t2_c)/(t2_c + 243.5)) * 10.   ; get saturation vapor pressure (mb)
           q = 0.622 * (es/p2)         ; find saturation mixing ratio at new pressure level (kg/kg)
         
           ; if q is less than q0 then the loop will continue, if not it will go to calculate 
           ; equivalent potential temperature using the variables from the loop
           p1 = p2
           delete(p2)
           
         end do
         var1_1(i, j, k) =  pt0 * exp((Lv*q0)/(cp*t2))   ; this is equivalent potential temperature
         
         delete(t0)
         delete(p0)
         delete(q0)
         delete(pt0)
         delete(p1)
         delete(t2)
         delete(t2_c)
         delete(es)
         delete(q)

       end do
     end do
      print("created file 1 eta level "+i)
   end do

   delete(var2_1)
   delete(var3_1)
   delete(var4_1)
   delete(var5_1)

   var1_1@units = "K"
   var1_1@long_name = "Equivalent Potential Temperature at Eta Levels"
   var1_1@standard_name = "equiv_potential_temperature"   
  
   delete(i)
   delete(j)
   delete(k)

;;;;;;;;;;;;;
; second wrf file (25km)
;;;;;;;;;;;;;
   f2 = addfile(dir2 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
   lat2d_2  = f2->lat
   lon2d_2  = f2->lon
   eta_2    = f2->eta
   n_eta_2  = dimsizes(eta_2)
   siz2 = dimsizes(lat2d_2)
   nlat_2 = siz2(0)
   nlon_2 = siz2(1)

   Z_sfc_2  = f2->Z_sfc(south_north|:,west_east|:)
   Z_e_2    = f2->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
   var2_2  = f2->$invar2$(time|0,eta|:,south_north|:,west_east|:) ; get press[hPa]
   var3_2  = f2->$invar3$(time|0,eta|:,south_north|:,west_east|:) ; get mixrad[kg/kg]
   var4_2  = f2->$invar4$(time|0,eta|:,south_north|:,west_east|:) ; get pottemp[K]
   var5_2  = f2->$invar5$(time|0,eta|:,south_north|:,west_east|:) ; get temp[K]

   var3_2 = where(var3_2 .lt. 0, 0, var3_2)

  ; calculate equivalent potential temperature at each grid cell
   var1_2  = new((/n_eta, nlat_2, nlon_2/), "float")           ; preallocate epottemp array

   do i = 0, n_eta - 1               ; loop through eta levels
     do j = 0, nlat_2 - 1            ; loop through south_north
       do k = 0, nlon_2 - 1          ; loop through west_east
         p0  = var2_2 (i, j, k)      ; initial pressure
         q0  = var3_2 (i, j, k)      ; initial mixing ratio
         pt0 = var4_2 (i, j, k)      ; initial potential temperature
         t0  = var5_2 (i, j, k)      ; initial temperature
         
         q = 0.                      ; get loops started
         p1 = p0                      ; initial temperature is 1mb less than start
         t1 = t0
         do while ( q .le. q0)
           p2 = p1 - .2                 ; new press. (mb) is .2mb less than prev. pressure
           t2 = t1 * (p2/p1)^(R/cp)    ; new temp. (K) if lifted dry adiabatically
           t2_c = t2 - 273.15          ; convert temp to celsius for clausius clapyeron
           es = 0.6112 * exp((17.67*t2_c)/(t2_c + 243.5)) * 10.   ; get saturation vapor pressure (mb)
           q = 0.622 * (es/p2)         ; find saturation mixing ratio at new pressure level (kg/kg)
         
           ; if q is less than q0 then the loop will continue, if not it will go to calculate 
           ; equivalent potential temperature using the variables from the loop
           p1 = p2
           delete(p2)
           
         end do
         var1_2(i, j, k) =  pt0 * exp((Lv*q0)/(cp*t2))   ; this is equivalent potential temperature
         
         delete(t0)
         delete(p0)
         delete(q0)
         delete(pt0)
         delete(p1)
         delete(t2)
         delete(t2_c)
         delete(es)
         delete(q)

       end do
     end do
      print("created file 2 eta level "+i)
   end do

   delete(var2_2)
   delete(var3_2)
   delete(var4_2)
   delete(var5_2)

   var1_2@units = "K"
   var1_2@long_name = "Equivalent Potential Temperature at Eta Levels"
   var1_2@standard_name = "equiv_potential_temperature"   

   delete(i)
   delete(j)
   delete(k)

;;;;;;;;;;;;;
; third wrf file (50km)
;;;;;;;;;;;;;
   f3 = addfile(dir3 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
   lat2d_3  = f3->lat
   lon2d_3  = f3->lon
   eta_3    = f3->eta
   n_eta_3  = dimsizes(eta_3)
   siz3 = dimsizes(lat2d_3)
   nlat_3 = siz3(0)
   nlon_3 = siz3(1)

   Z_sfc_3  = f3->Z_sfc(south_north|:,west_east|:)
   Z_e_3    = f3->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
   var2_3  = f3->$invar2$(time|0,eta|:,south_north|:,west_east|:) ; get press[hPa]
   var3_3  = f3->$invar3$(time|0,eta|:,south_north|:,west_east|:) ; get mixrad[kg/kg]
   var4_3  = f3->$invar4$(time|0,eta|:,south_north|:,west_east|:) ; get pottemp[K]
   var5_3  = f3->$invar5$(time|0,eta|:,south_north|:,west_east|:) ; get temp[K]

   var3_3 = where(var3_3 .lt. 0, 0, var3_3)

  ; calculate equivalent potential temperature at each grid cell
   var1_3  = new((/n_eta, nlat_3, nlon_3/), "float")           ; preallocate epottemp array

   do i = 0, n_eta - 1               ; loop through eta levels
     do j = 0, nlat_3 - 1            ; loop through south_north
       do k = 0, nlon_3 - 1          ; loop through west_east
         p0  = var2_3 (i, j, k)      ; initial pressure
         q0  = var3_3 (i, j, k)      ; initial mixing ratio
         pt0 = var4_3 (i, j, k)      ; initial potential temperature
         t0  = var5_3 (i, j, k)      ; initial temperature
         
         q = 0.                      ; get loops started
         p1 = p0                      ; initial temperature is 1mb less than start
         t1 = t0
         do while ( q .le. q0)
           p2 = p1 - .2                 ; new press. (mb) is .2mb less than prev. pressure
           t2 = t1 * (p2/p1)^(R/cp)    ; new temp. (K) if lifted dry adiabatically
           t2_c = t2 - 273.15          ; convert temp to celsius for clausius clapyeron
           es = 0.6112 * exp((17.67*t2_c)/(t2_c + 243.5)) * 10.   ; get saturation vapor pressure (mb)
           q = 0.622 * (es/p2)         ; find saturation mixing ratio at new pressure level (kg/kg)
         
           ; if q is less than q0 then the loop will continue, if not it will go to calculate 
           ; equivalent potential temperature using the variables from the loop
           p1 = p2
           delete(p2)
           
         end do
         var1_3(i, j, k) =  pt0 * exp((Lv*q0)/(cp*t2))   ; this is equivalent potential temperature
         
         delete(t0)
         delete(p0)
         delete(q0)
         delete(pt0)
         delete(p1)
         delete(t2)
         delete(t2_c)
         delete(es)
         delete(q)

       end do
     end do
      print("created file 3 eta level "+i)
   end do

   delete(var2_3)
   delete(var3_3)
   delete(var4_3)
   delete(var5_3)

   var1_3@units = "K"
   var1_3@long_name = "Equivalent Potential Temperature at Eta Levels"
   var1_3@standard_name = "equiv_potential_temperature"   

   delete(i)
   delete(j)
   delete(k)

;;;;;;;;;;;;;
; fourth wrf file (100km)
;;;;;;;;;;;;;
   f4 = addfile(dir4 + "wrf-" + day + "-" + whr + ".nc","r")  ; Load first wrf file
   lat2d_4  = f4->lat
   lon2d_4  = f4->lon
   eta_4    = f4->eta
   n_eta_4  = dimsizes(eta_4)
   siz4 = dimsizes(lat2d_4)
   nlat_4 = siz4(0)
   nlon_4 = siz4(1)

   Z_sfc_4  = f4->Z_sfc(south_north|:,west_east|:)
   Z_e_4    = f4->Z_e(time|0,eta|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
   var2_4  = f4->$invar2$(time|0,eta|:,south_north|:,west_east|:) ; get press[hPa]
   var3_4  = f4->$invar3$(time|0,eta|:,south_north|:,west_east|:) ; get mixrad[kg/kg]
   var4_4  = f4->$invar4$(time|0,eta|:,south_north|:,west_east|:) ; get pottemp[K]
   var5_4  = f4->$invar5$(time|0,eta|:,south_north|:,west_east|:) ; get temp[K]

   var3_4 = where(var3_4 .lt. 0, 0, var3_4)

  ; calculate equivalent potential temperature at each grid cell
   var1_4  = new((/n_eta, nlat_4, nlon_4/), "float")           ; preallocate epottemp array

   do i = 0, n_eta - 1               ; loop through eta levels
     do j = 0, nlat_4 - 1            ; loop through south_north
       do k = 0, nlon_4 - 1          ; loop through west_east
         p0  = var2_4 (i, j, k)      ; initial pressure
         q0  = var3_4 (i, j, k)      ; initial mixing ratio
         pt0 = var4_4 (i, j, k)      ; initial potential temperature
         t0  = var5_4 (i, j, k)      ; initial temperature
         
         q = 0.                      ; get loops started
         p1 = p0                      ; initial temperature is 1mb less than start
         t1 = t0
         do while ( q .le. q0)
           p2 = p1 - .2                 ; new press. (mb) is .2mb less than prev. pressure
           t2 = t1 * (p2/p1)^(R/cp)    ; new temp. (K) if lifted dry adiabatically
           t2_c = t2 - 273.15          ; convert temp to celsius for clausius clapyeron
           es = 0.6112 * exp((17.67*t2_c)/(t2_c + 243.5)) * 10.   ; get saturation vapor pressure (mb)
           q = 0.622 * (es/p2)         ; find saturation mixing ratio at new pressure level (kg/kg)
         
           ; if q is less than q0 then the loop will continue, if not it will go to calculate 
           ; equivalent potential temperature using the variables from the loop
           p1 = p2
           delete(p2)
           
         end do
         var1_4(i, j, k) =  pt0 * exp((Lv*q0)/(cp*t2))   ; this is equivalent potential temperature
         
         delete(t0)
         delete(p0)
         delete(q0)
         delete(pt0)
         delete(p1)
         delete(t2)
         delete(t2_c)
         delete(es)
         delete(q)

       end do
     end do
      print("created file 4 eta level "+i)
   end do

   delete(var2_4)
   delete(var3_4)
   delete(var4_4)
   delete(var5_4)

   var1_4@units = "K"
   var1_4@long_name = "Equivalent Potential Temperature at Eta Levels"
   var1_4@standard_name = "equiv_potential_temperature"   

   delete(i)
   delete(j)
   delete(k)


print("Loading ERA-I data")
;;;;;;;;;;;;;
; ERA-I file (1.5deg) --> from 10km met_em files
;;;;;;;;;;;;;
   f5 = addfile(dir5 + "met_em.d01." + day + "-" + ehr + ".nc","r")  ; Load first wrf file
   lat2d_5  = lat2d_1         ; use lat and lon info from 10km file
   lon2d_5  = lon2d_1
   n_eta_5  = 38
   siz5 = dimsizes(lat2d_5)
   nlat_5 = siz5(0)
   nlon_5 = siz5(1)

   Z_sfc_5  = f5->HGT_M(Time|0,south_north|:,west_east|:)
   Z_e_5    = f5->GHT(Time|0,num_metgrid_levels|:,south_north|:,west_east|:)

  ; get 3D data for cross section plot
   press  = f5->PRES(Time|0,num_metgrid_levels|:,south_north|:,west_east|:) ; get press[Pa]
   rh     = f5->RH(Time|0,num_metgrid_levels|:,south_north|:,west_east|:)   ; get RH[%]
   temp   = f5->TT(Time|0,num_metgrid_levels|:,south_north|:,west_east|:)   ; get temp [K] 

   ; convert and get data as needed
   var2_5 = press /100.   ; convert pressure from Pa to hPa
   var5_5 = temp          ; assign temperature
   var4_5 = var5_5 * ((1000./var2_5)^(R/cp))  ; calculate pot temp [K]

   ; calculate mixing ratio variable
   t_c   = var5_5 - 273.15  ; convert temperature to celsius
   satvp = (0.6112 * exp((17.67 * t_c)/(t_c + 243.15))) * 10.  ; calculate satvp and convert units to hPa
   satmr = (0.622 * (satvp/var2_5)) ; calculate sat mix ratio using pressure and satvp
   var3_5 = (rh/100) * satmr        ; calcluate mix ratio using RH and satmr [kg/kg]

   delete(press)
   delete(rh)
   delete(temp)
   delete(t_c)
   delete(satvp)
   delete(satmr)

   var3_5 = where(var3_5 .lt. 0, 0, var3_5)  ; NOT SURE IF THIS IS NEEDED

  ; calculate equivalent potential temperature at each grid cell
   var1_5  = new((/n_eta, nlat_5, nlon_5/), "float")           ; preallocate epottemp array

   do i = 0, n_eta - 1               ; loop through eta levels
     do j = 0, nlat_5 - 1            ; loop through south_north
       do k = 0, nlon_5 - 1          ; loop through west_east
         p0  = var2_5 (i, j, k)      ; initial pressure
         q0  = var3_5 (i, j, k)      ; initial mixing ratio
         pt0 = var4_5 (i, j, k)      ; initial potential temperature
         t0  = var5_5 (i, j, k)      ; initial temperature
         
         q = 0.                      ; get loops started
         p1 = p0                      ; initial temperature is 1mb less than start
         t1 = t0
         do while ( q .le. q0)
           p2 = p1 - .2                 ; new press. (mb) is .2mb less than prev. pressure
           t2 = t1 * (p2/p1)^(R/cp)    ; new temp. (K) if lifted dry adiabatically
           t2_c = t2 - 273.15          ; convert temp to celsius for clausius clapyeron
           es = 0.6112 * exp((17.67*t2_c)/(t2_c + 243.5)) * 10.   ; get saturation vapor pressure (mb)
           q = 0.622 * (es/p2)         ; find saturation mixing ratio at new pressure level (kg/kg)
         
           ; if q is less than q0 then the loop will continue, if not it will go to calculate 
           ; equivalent potential temperature using the variables from the loop
           p1 = p2
           delete(p2)
           
         end do
         var1_5(i, j, k) =  pt0 * exp((Lv*q0)/(cp*t2))   ; this is equivalent potential temperature
         
         delete(t0)
         delete(p0)
         delete(q0)
         delete(pt0)
         delete(p1)
         delete(t2)
         delete(t2_c)
         delete(es)
         delete(q)

       end do
     end do
      print("created file 5 eta level "+i)
   end do

   delete(var2_5)
   delete(var3_5)
   delete(var4_5)
   delete(var5_5)

   var1_5@units = "K"
   var1_5@long_name = "Equivalent Potential Temperature at Eta Levels"
   var1_5@standard_name = "equiv_potential_temperature"   

   delete(i)
   delete(j)
   delete(k)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Horizontally Interpolate to cross section line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set start and end lons and lats
; npts is cross section specific to give 2km horiz resolution
; GFDX Cross section - Denmark Strait North
  if (cross_type .eq. "1") then
    st_lat = 69.0
    st_lon = -25.0
    ed_lat = 66.5
    ed_lon = -22.5
    npts   = 149
  end if
; GFDX Cross section - Denmark Strait South
  if (cross_type .eq. "2") then
    st_lat = 68.0
    st_lon = -30.0
    ed_lat = 65.0
    ed_lon = -27.0
    npts   = 180
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
     cressrad_5 = 10.  ; same as 10km resolution     

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

  lat1d_5 = ndtooned(lat2d_5)
  lon1d_5 = ndtooned(lon2d_5)

; get 1D surface arrays
  Z_sfc_1d_1 = ndtooned(Z_sfc_1)
  Z_sfc_sub_1  = new((/n_cross/),"float")

  Z_sfc_1d_2 = ndtooned(Z_sfc_2)
  Z_sfc_sub_2  = new((/n_cross/),"float")

  Z_sfc_1d_3 = ndtooned(Z_sfc_3)
  Z_sfc_sub_3  = new((/n_cross/),"float")

  Z_sfc_1d_4 = ndtooned(Z_sfc_4)
  Z_sfc_sub_4  = new((/n_cross/),"float")

  Z_sfc_1d_5 = ndtooned(Z_sfc_5)
  Z_sfc_sub_5  = new((/n_cross/),"float")

; preallocate arrays for subset of each variable
; THESE N_ETA DIMENSIONS HAVE BEEN CHANGED TO WORK WITH ERA-I
  var1_sub_1   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_1    = new((/n_eta_1,n_cross/),"float") 
 
  var1_sub_2   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_2    = new((/n_eta_1,n_cross/),"float")

  var1_sub_3   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_3    = new((/n_eta_1,n_cross/),"float")

  var1_sub_4   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_4    = new((/n_eta_1,n_cross/),"float")

  var1_sub_5   = new((/n_eta_1,n_cross/),"float")
  Z_e_sub_5    = new((/n_eta_1,n_cross/),"float")

; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from cross section line to grid points
    dist_rad_1 = gc_latlon(lats(i),lons(i),lat1d_1, lon1d_1, 2, 4)  
    dist_rad_2 = gc_latlon(lats(i),lons(i),lat1d_2, lon1d_2, 2, 4) 
    dist_rad_3 = gc_latlon(lats(i),lons(i),lat1d_3, lon1d_3, 2, 4) 
    dist_rad_4 = gc_latlon(lats(i),lons(i),lat1d_4, lon1d_4, 2, 4) 
    dist_rad_5 = gc_latlon(lats(i),lons(i),lat1d_5, lon1d_5, 2, 4)

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
    if (any(isnan_ieee(dist_rad_5))) then       
      nreplacements = num(isnan_ieee(dist_rad_5))  ; find index of NaN
      replace_ieeenan(dist_rad_5,0.,0)             ; replace the NaN with 0
      print("file 5: replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
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
   if (min(dist_rad_5).gt.cressrad_5) then        
      print("file 5: Minimum distance is greater than Cressman radius at i " + i) 
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

    indicies_5 = ind(dist_rad_5.lt.cressrad_5)    ; indicies where distance is in cressman radius
    weight_5 = (cressrad_5^2 - dist_rad_5(indicies_5)^2) / (cressrad_5^2 + dist_rad_5(indicies_5)^2)  ; assign weights

    ; calculate surface height subsets
    Z_sfc_sub_1(i)  = sum(Z_sfc_1d_1(indicies_1)*weight_1)/sum(weight_1)
    Z_sfc_sub_2(i)  = sum(Z_sfc_1d_2(indicies_2)*weight_2)/sum(weight_2)
    Z_sfc_sub_3(i)  = sum(Z_sfc_1d_3(indicies_3)*weight_3)/sum(weight_3)
    Z_sfc_sub_4(i)  = sum(Z_sfc_1d_4(indicies_4)*weight_4)/sum(weight_4)
    Z_sfc_sub_5(i)  = sum(Z_sfc_1d_5(indicies_5)*weight_5)/sum(weight_5)

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

      var1_1d_5 = ndtooned(var1_5(j,:,:))    
      Z_e_1d_5  = ndtooned(Z_e_5(j,:,:))
      
      ; calculate new array for variable and geopZ
      var1_sub_1(j,i) =  sum(var1_1d_1(indicies_1)*weight_1)/sum(weight_1)
      Z_e_sub_1(j,i)  =  sum(Z_e_1d_1(indicies_1)*weight_1)/sum(weight_1)

      var1_sub_2(j,i) =  sum(var1_1d_2(indicies_2)*weight_2)/sum(weight_2)
      Z_e_sub_2(j,i)  =  sum(Z_e_1d_2(indicies_2)*weight_2)/sum(weight_2)

      var1_sub_3(j,i) =  sum(var1_1d_3(indicies_3)*weight_3)/sum(weight_3)
      Z_e_sub_3(j,i)  =  sum(Z_e_1d_3(indicies_3)*weight_3)/sum(weight_3)

      var1_sub_4(j,i) =  sum(var1_1d_4(indicies_4)*weight_4)/sum(weight_4)
      Z_e_sub_4(j,i)  =  sum(Z_e_1d_4(indicies_4)*weight_4)/sum(weight_4)

      var1_sub_5(j,i) =  sum(var1_1d_5(indicies_5)*weight_5)/sum(weight_5)
      Z_e_sub_5(j,i)  =  sum(Z_e_1d_5(indicies_5)*weight_5)/sum(weight_5)

      delete(var1_1d_1)
      delete(Z_e_1d_1)
      delete(var1_1d_2)
      delete(Z_e_1d_2)
      delete(var1_1d_3)
      delete(Z_e_1d_3)
      delete(var1_1d_4)
      delete(Z_e_1d_4)
      delete(var1_1d_5)
      delete(Z_e_1d_5)

    end do

    delete(indicies_1)
    delete(weight_1)
    delete(indicies_2)
    delete(weight_2)
    delete(indicies_3)
    delete(weight_3)
    delete(indicies_4)
    delete(weight_4)
    delete(indicies_5)
    delete(weight_5)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(var1_1, var1_sub_1)
  copy_VarAtts(var1_2, var1_sub_2)
  copy_VarAtts(var1_3, var1_sub_3)
  copy_VarAtts(var1_4, var1_sub_4)
  copy_VarAtts(var1_5, var1_sub_5)
  copy_VarAtts(Z_e_1, Z_e_sub_1)
  copy_VarAtts(Z_e_2, Z_e_sub_2)
  copy_VarAtts(Z_e_3, Z_e_sub_3)
  copy_VarAtts(Z_e_4, Z_e_sub_4)
  copy_VarAtts(Z_e_5, Z_e_sub_5)
  copy_VarAtts(Z_sfc_1, Z_sfc_sub_1)
  copy_VarAtts(Z_sfc_2, Z_sfc_sub_2)
  copy_VarAtts(Z_sfc_3, Z_sfc_sub_3)
  copy_VarAtts(Z_sfc_4, Z_sfc_sub_4)
  copy_VarAtts(Z_sfc_5, Z_sfc_sub_5)

;;;;;;;;;;
; Convert/manipulate variables
;;;;;;;;;;

if (isvar("gkg").and.(gkg))then
  ; convert kg/kg to g/kg
  var1_sub_1 = var1_sub_1 * 1000.
  var1_sub_2 = var1_sub_2 * 1000.
  var1_sub_3 = var1_sub_3 * 1000.
  var1_sub_4 = var1_sub_4 * 1000.
  var1_sub_5 = var1_sub_5 * 1000.

end if


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
  data_hgt_5 = new((/dimsizes(hgts),n_cross/),"float")
  copy_VarMeta(data_hgt_1, data_hgt_2)
  copy_VarMeta(data_hgt_1, data_hgt_3)
  copy_VarMeta(data_hgt_1, data_hgt_4)
  copy_VarMeta(data_hgt_1, data_hgt_5)

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

; fifth file interpolate
 do d=0, n_cross-1                   ; Loop through each point along distance
   do h=0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub_5(d) .lt. hgts(h)) then    ; If height to interp. to is above surface proceed
       f=0                                  ; if not, fill data_hgt with a missing value
       if (Z_e_sub_5(f,d) .lt. hgts(h)) then  ; If height to interp. to  is above first eta level proceed
                                            ; if not, fill data_hgt with a missing value
         
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub_5(f,d) .lt. hgts(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do

         A_hgt = Z_e_sub_5(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub_5(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgts(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to

         ; if variable increases with height linearly interp.
         if (var1_sub_5(f,d) .gt. var1_sub_5(f-1,d)) then  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           data_hgt_5(h,d) = var1_sub_5(f-1,d)+((var1_sub_5(f,d)-var1_sub_5(f-1,d))*wt)

         ; if variable decreases with height linearly interp.
         else                                  
           wt = (B_hgt-C_hgt)/total_dist
           data_hgt_5(h,d) = var1_sub_5(f,d)+((var1_sub_5(f-1,d)-var1_sub_5(f,d))*wt)
         end if
       else
         data_hgt_5(h,d)= -999
       end if
    else
      data_hgt_5(h,d) = -999
    end if
  end do
    ; Counter
    if(d%10.eq.0) then
      print("file5: created vert levels for "+d+" of "+n_cross)
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
   eta_levs_5 = new((/n_eta/),"float")

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
     temp5 = avg(Z_e_sub_5(n,:))
     eta_levs_5(n) = temp5

     ypos(n) = dist(n_cross-1)
     delete(temp1)
     delete(temp2)
     delete(temp3)
     delete(temp4)
    delete(temp5)

   end do
 end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Plotting cross section of "+vartitle1)
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"grey"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

 plot = new(6, graphic)    ; one cross section plot and one spatial plot

;;;;;;;;;;;;;
; Cross Section Plot Resources
;;;;;;;;;;;;;

 opts                              = True              ; plot mods desired
  opts@gsnRightString              = ""
  opts@gsnLeftString               = ""
  opts@gsnFrame                    = False             ; Do not draw plot 
  opts@gsnDraw                     = False             ; Do not advance frame
  opts@gsnXAxisIrregular2Linear    = True
  opts@gsnYAxisIrregular2Linear    = True

  opts@vpWidthF                    = 1.0               ; set aspect ratio
  opts@vpHeightF                   = 0.55
;  opts@vpHeightF                   = 0.5

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
  opts@cnLineLabelFontHeightF      = 0.03
  opts@cnLineLabelFontThicknessF   = 1.5
  opts@cnInfoLabelOn               = False
  opts@cnMissingValFillColor       = "grey"          ; missing value color
  opts@cnMissingValFillPattern     = 0                 ; fill in 
  
  opts@tiMainFontHeightF           = 0.04
  opts@tiMainFontThicknessF        = 2.0
  ;opts@tiXAxisString               = "Distance (km)"
  ;opts@tiYAxisString               = "Height (m)"
  opts@tiXAxisOffsetYF             = 0.00
  opts@tiXAxisFontHeightF          = 0.04            ; set font size for x axis
  opts@tiXAxisFontThicknessF       = 1.5
  opts@tmXBLabelFontHeightF        = 0.04             ; set tick mark label size for x axis
  opts@tmXBLabelFontThicknessF     = 1.5
  opts@tiYAxisFontHeightF          = 0.04            ; set font size for y axis
  opts@tiYAxisFontThicknessF       = 1.5
  opts@tmYLLabelFontHeightF        = 0.04             ; set tick mark label size for y axis
  opts@tmYLLabelFontThicknessF     = 1.5

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
   opts0@gsnFrame                  = False             ; Do not draw plot 
   opts0@gsnDraw                   = False             ; Do not advance frame
   opts0@tiMainString              = "a)      GFDex - " + whr + "UTC"
   opts0@vpWidthF                  = 1.0
   opts0@vpHeightF                 = 0.5
   ;opts0@tiXAxisString             = "Distance (km)"
   opts0@tiYAxisString             = "Height (m)"
   opts0@tiXAxisFontHeightF        = 0.04
   opts0@tiYAxisFontHeightF        = 0.04

   cplot0 = gsn_blank_plot(wks,opts0)
   ;cplot0  = gsn_open_wks(wks,"blank")
   plot(0) = cplot0

;;;;;;;;;;;;;
; Plot 1 - WRF(10km) cross section
;;;;;;;;;;;;;

   opts1 = opts
   opts1@tiMainString              = "b)      WRF (10km) - " + whr + "UTC" 

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
   opts2@tiMainString              = "c)      WRF (25km) - " + whr + "UTC"

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
   opts3@tiMainString              = "d)      WRF (50km) - " + whr + "UTC"
   opts3@tiXAxisString             = "Distance (km)"
   opts3@tiYAxisString             = "Height (m)"

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
   opts4@tiMainString              = "e)      WRF (100km) - " + whr + "UTC"
   opts4@tiXAxisString             = "Distance (km)"

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
   opts5@tiMainString              = "f)      ERA-Interim (1.5 deg) - " + ehr + "UTC"
   opts5@tiXAxisString             = "Distance (km)"

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

 title_fin = "GFDex, WRF, and ERA-Interim equivalent potential temperature (K) at cross section - " + day

  pnlres                            = True
  pnlres@txString                   = title_fin        ; final title
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.013
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@pmLabelBarWidthF           = 0.8

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
