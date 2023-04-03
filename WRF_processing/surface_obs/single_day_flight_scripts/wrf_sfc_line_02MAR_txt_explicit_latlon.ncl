;***************************************
; PROGRAM DESCRIPTION: This NCL script makes text files of  surface variables
;                      by interpolating to a specified transect line using
;                      cressman weighting
; INPUT DATA: WRF output of any resolution at a particular output time
; OUTPUT DATA: text files with chosen surface values along transect
; Notes: This script is specific for 02MAR 2007 GFDex flights
; CREATORS: Alice DuVivier - June 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
;MANUAL INPUTS - for testing purposes
; MUST MANUALLY CHANGE RESOLUTION HERE
dir1 = "/data3/duvivier/NCAR/DATA/02MAR/MYJ_char0.15/wrf_10km/"
fname1 = "wrf-2007-03-02-14"
title1 = "WRF_10"
date1 = "2007-03-02-14"

; BEGIN SCRIPT
; set outdir and fout names
   outdir = "./"
   fout   = outdir+title1+"_myj0.15_sfc_obs_"+date1


; set cressman radius based on resolution of wrf output
   if (title1 .eq. "WRF_10") then
     cressrad = 10.            
   end if
   if (title1 .eq. "WRF_25") then
     cressrad = 25.            
   end if
   if (title1 .eq. "WRF_50") then
     cressrad = 50.            
   end if
   if (title1 .eq. "WRF_100") then
     cressrad = 100.            
   end if

  print("Processing surface obs for "+date1)

;;;;;;;;;;
; Use varcode to set variable information
;;;;;;;;;;
; Which variables need to be loaded?
invar0 = "SeaIce"            ; sea ice fraction
invar1 = "T_2m"              ; 2m Temp
invar2 = "q_2m"              ; 2m Mixing ratio
invar3 = "T_sfc"             ; surface temperature
invar4 = "LHFlx"             ; latent heat flux at surface
invar5 = "SHFlx"             ; sensible heat flux at surface
invar6 = "u_star"            ; friction velocity
invar7 = "u_10m_tr"          ; 10m u wind
invar8 = "v_10m_tr"          ; 10m v wind
invar9 = "Z_sfc"             ; surface elevation
invar10 = "slp"              ; sea level pressure


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be 2D surface data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Loading wrf data")

; load in the two files. the directories and filenames were specified in the c-shell wrapper
  f1 = addfile(dir1 + fname1 + ".nc","r")

; get the latitude and longitude data and dimensions, later used to plot the entire domain
  lat2d  = f1->lat
  lon2d  = f1->lon

; get the 2d variables 
  var0 = f1->$invar0$(time|0,south_north|:,west_east|:)
  var1 = f1->$invar1$(time|0,south_north|:,west_east|:)
  var2 = f1->$invar2$(time|0,south_north|:,west_east|:)
  var3 = f1->$invar3$(time|0,south_north|:,west_east|:)
  var4 = f1->$invar4$(time|0,south_north|:,west_east|:)
  var5 = f1->$invar5$(time|0,south_north|:,west_east|:)
  var6 = f1->$invar6$(time|0,south_north|:,west_east|:)
  var7 = f1->$invar7$(time|0,south_north|:,west_east|:)
  var8 = f1->$invar8$(time|0,south_north|:,west_east|:)
  var9 = f1->$invar9$(south_north|:,west_east|:)
  var10 = f1->$invar10$(time|0,south_north|:,west_east|:)

  ; convert T2m to K from Celsius
  var1 = var1 +273.15
  var1@units = "K"

  ; convert mixing ratio to g/kg
  var2 = var2*1000.
  var2@units = "g kg-1"

  ; find 10m wind speed
  var7 = sqrt(var7^2 + var8^2)
  var7@long_name = "10m Wnd Spd"
  var7@standard_name = "10m_wnd"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Horizontally Interpolate to cross section line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set explicit list of lats and lons for the particular flight
; These are taken directly from the GFDex flight on this day
lats = (/67.05, 67.19, 67.25, 67.14, 67.03, 66.92, 66.81, 66.69, 66.56, 66.43, 66.3, 66.18, 66.06, 65.95, 65.82, 65.69, 65.56, 65.44, 65.31, 65.15/)

lons = (/-22.82, -22.95, -23.63, -23.87, -24.10, -24.31, -24.52, -24.69, -24.86, -25.03, -25.18, -25.38, -25.6, -25.79, -25.96, -26.12, -26.29, -26.46, -26.62, -26.83/)

n_cross = dimsizes(lats)

print("Interpolating to cross section line")
  lat1d = ndtooned(lat2d)
  lon1d = ndtooned(lon2d)

  Z_sfc_1d = ndtooned(var9)
  Z_sfc_sub  = new((/n_cross/),"float")

  ; preallocate arrays for subset of variables
  var0_sub   = new((/n_cross/),"float")
  var1_sub   = new((/n_cross/),"float")
  var2_sub   = new((/n_cross/),"float")
  var3_sub   = new((/n_cross/),"float")
  var4_sub   = new((/n_cross/),"float")
  var5_sub   = new((/n_cross/),"float")
  var6_sub   = new((/n_cross/),"float")
  var7_sub   = new((/n_cross/),"float")
  var8_sub   = new((/n_cross/),"float")
  
  ; flatten the data so the indices can be calculated
  var0_1d    = ndtooned(var0)
  var1_1d    = ndtooned(var1)
  var2_1d    = ndtooned(var2)
  var3_1d    = ndtooned(var3)
  var4_1d    = ndtooned(var4)  
  var5_1d    = ndtooned(var5)
  var6_1d    = ndtooned(var6)
  var7_1d    = ndtooned(var7)
  var8_1d    = ndtooned(var10)


; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from line to points on grid
    dist_rad = gc_latlon(lats(i),lons(i),lat1d, lon1d, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist_rad))) then       
      nreplacements = num(isnan_ieee(dist_rad))  ; find index of NaN
      replace_ieeenan(dist_rad,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist_rad.lt.cressrad)    ; indicies where distance is in cressman radius
    weight = (cressrad^2 - dist_rad(indicies)^2) / (cressrad^2 + dist_rad(indicies)^2)  ; give each index a weight

    ; calculate surface height subset
    Z_sfc_sub(i)  = sum(Z_sfc_1d(indicies)*weight)/sum(weight)
    var0_sub(i)   = sum(var0_1d(indicies)*weight)/sum(weight)
    var1_sub(i)   = sum(var1_1d(indicies)*weight)/sum(weight)
    var2_sub(i)   = sum(var2_1d(indicies)*weight)/sum(weight)
    var3_sub(i)   = sum(var3_1d(indicies)*weight)/sum(weight)
    var4_sub(i)   = sum(var4_1d(indicies)*weight)/sum(weight)
    var5_sub(i)   = sum(var5_1d(indicies)*weight)/sum(weight)
    var6_sub(i)   = sum(var6_1d(indicies)*weight)/sum(weight)
    var7_sub(i)   = sum(var7_1d(indicies)*weight)/sum(weight)
    var8_sub(i)   = sum(var8_1d(indicies)*weight)/sum(weight)

    delete(indicies)
    delete(weight)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  ; reassign attributes
  copy_VarAtts(var9, Z_sfc_sub)
  copy_VarAtts(var0, var0_sub)
  copy_VarAtts(var1, var1_sub)
  copy_VarAtts(var2, var2_sub)
  copy_VarAtts(var3, var3_sub)
  copy_VarAtts(var4, var4_sub)
  copy_VarAtts(var5, var5_sub)
  copy_VarAtts(var6, var6_sub)
  copy_VarAtts(var7, var7_sub)
  copy_VarAtts(var10 ,var8_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Write subset variables to a text file for plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header = "lats     lons    elev(m)   SeaIce(1=ice)    T2m(K)    Q2m(g/kg)   Tsurf(K)   LHFlx(W/m2)   SHFlx(W/m2)  ustar(m/s)   10mwind(m/s)    slp(hPa) "
output = header

do j = 0,n_cross-1

  a1 = sprintf("%10.4f",lats(j))+sprintf("%10.4f",lons(j))+\
         sprintf("%10.4f",Z_sfc_sub(j))+sprintf("%10.4f",var0_sub(j))+\
         sprintf("%10.4f",var1_sub(j))+sprintf("%10.4f",var2_sub(j))+\
         sprintf("%10.4f",var3_sub(j))+sprintf("%10.4f",var4_sub(j))+\
         sprintf("%10.4f",var5_sub(j))+sprintf("%10.4f",var6_sub(j))+\
         sprintf("%10.4f",var7_sub(j))+sprintf("%10.4f",var8_sub(j))

   newoutput = array_append_record(output, a1, 0)
   delete(output)
   output = newoutput
   delete(newoutput)

end do

asciiwrite(fout + ".txt",output)



;;;;;;;;;;;;;;;;;;;;;; END script
end

