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
dir1 = "/data3/duvivier/NCAR/MODIS_data/composite_8d/data/"
title1 = "MODIS"
date1 = "2007-02-26_2007-03-05"
fname1 = title1 + "_SST_" + date1 + "_smi"

; BEGIN SCRIPT
; set outdir and fout names
   outdir = "./"
   fout   = outdir + title1+"_sfc_obs_02MAR"


; set cressman radius based on resolution of wrf output
   cressrad = 9.

  print("Processing MODIS surface obs for "+date1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be 2D surface data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Loading wrf data")

; load in the two files. the directories and filenames were specified in the c-shell wrapper
  f1 = addfile(dir1 + fname1 + ".hdf","r")
  var_tmp = f1->l3m_data
;  var1@_FillValue = 65535  ; specified from file
  slope = var_tmp@Slope
  int   = var_tmp@Intercept
  
  ; calculate sst from equation given in metadata
  mod_sst = (slope * var_tmp) + int
  delete(var_tmp)

 ; make lat and lon arrays
  ; Northernmost lat = 90 ; Southernmost lat = -90
  ; Westernomost lon = -180; Easternmost lon = 180
  ; Step (for each) = 0.08333334
  dim_lat = 2160         ; total lats = 2160
  dim_lon = 4320         ; total lons = 4320

  lat = fspan(90, -90, dim_lat)
  lon = fspan(-180, 180, dim_lon)

  ; make lat and lon 2d arrays
  lat2d = new((/dim_lat, dim_lon/), "float")
  lon2d = new((/dim_lat, dim_lon/), "float")
  
  do i = 0, dim_lon-1
    lat2d(:,i) = lat
  end do

  do j = 0, dim_lat-1
    lon2d(j,:) = lon
  end do

  ; subset sst, lat, and lon for region of interest
  mod_sst_sub = mod_sst(228:408, 1464:1930)
  lat2d_sub = lat2d(228:408, 1464:1930)
  lon2d_sub = lon2d(228:408, 1464:1930)

  delete(mod_sst)
  delete(lat2d)
  delete(lon2d)

  mod_sst_2d = mod_sst_sub
  mod_sst_2d@_FillValue = 9.96921e+36
  mod_sst_2d = where(mod_sst_2d .lt. 30, mod_sst_2d, mod_sst_2d@_FillValue)
  mod_sst_2d = mod_sst_2d + 273.15   ; convert to K
  mod_sst_2d@units = "K"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Horizontally Interpolate to cross section line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set explicit list of lats and lons for the particular flight
; These are taken directly from the GFDex flight on this day
lats = (/67.05, 67.19, 67.25, 67.14, 67.03, 66.92, 66.81, 66.69, 66.56, 66.43, 66.3, 66.18, 66.06, 65.95, 65.82, 65.69, 65.56, 65.44, 65.31, 65.15/)

lons = (/-22.82, -22.95, -23.63, -23.87, -24.10, -24.31, -24.52, -24.69, -24.86, -25.03, -25.18, -25.38, -25.6, -25.79, -25.96, -26.12, -26.29, -26.46, -26.62, -26.83/)

n_cross = dimsizes(lats)

print("Interpolating to cross section line")
  lat1d = ndtooned(lat2d_sub)
  lon1d = ndtooned(lon2d_sub)

  ; preallocate arrays for subset of variables
  sst_sub   = new((/n_cross/),"float")
  
  ; flatten the data so the indices can be calculated
  sst_1d    = ndtooned(mod_sst_2d)

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

    ; calculate surface variables at cross section
    sst_sub(i)  = sum(sst_1d(indicies)*weight)/sum(weight)

    delete(indicies)
    delete(weight)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  ; reassign attributes
  copy_VarAtts(mod_sst_2d, sst_sub)

  sst_sub = where(ismissing(sst_sub), -999.9, sst_sub)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Write subset variables to a text file for plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header = "lats     lons    Tsurf(K)   "
output = header

do j = 0,n_cross-1

  a1 = sprintf("%10.4f",lats(j))+sprintf("%10.4f",lons(j))+\
         sprintf("%10.4f",sst_sub(j))

   newoutput = array_append_record(output, a1, 0)
   delete(output)
   output = newoutput
   delete(newoutput)

end do

asciiwrite(fout + ".txt",output)



;;;;;;;;;;;;;;;;;;;;;; END script
end

