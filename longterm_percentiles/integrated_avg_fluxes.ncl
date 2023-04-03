;***************************************
; PROGRAM DESCRIPTION: This NCL script calculates the ocean cell integrated 
;                      average flux value for longterm WRF files
; INPUT DATA: Four WRF output files at native resolution that are concatenated
;             monthly files
; OUTPUT DATA: No output, but the screen prints the values calculated
; Note: This script is designed to find the FLUX values only
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

varcode = "SH"

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_longterm_integrated"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

  print("Running longterm avg at all resolutions")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
  if (varcode.eq."SH") then
    vartitle1 = "Sensible Heat Flux at Sur"
    invar1 = "SHFlx"
    vartype = "2d"
    cmaptype = "shflux"
    met_not_avail = True  ; SH data not in met
  end if
  if (varcode.eq."LH") then
    vartitle1 = "Latent Heat Flux at Sur"
    invar1 = "LHFlx"
    vartype = "2d"
    cmaptype = "lhflux"
    met_not_avail = True  ; LH data not in met
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Loading
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

;; first wrf file
  f1_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.10km.nc", "r")
  land1 = f1_geo->LANDMASK(Time|0,south_north|:,west_east|:)

  f1_feb = addfile(dir1 + fname2 + ".nc","r")  ; Load first wrf file
  f1_mar = addfile(dir1 + fname3 + ".nc","r")  ; Load first wrf file
  var1_feb  = f1_feb->$invar1$(time|:,south_north|:,west_east|:)
  var1_mar  = f1_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_1 = f1_feb->lat
  lon2d_1 = f1_feb->lon
  var1_feb@lat2d = lat2d_1
  var1_feb@lon2d = lon2d_1
  dims1 = dimsizes(lat2d_1)
  nlat_1 = dims1(0)
  nlon_1 = dims1(1)

; second wrf file
  f2_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.25km.nc", "r")
  land2 = f2_geo->LANDMASK(Time|0,south_north|:,west_east|:)

  f2_feb = addfile(dir2 + fname2 + ".nc","r")  ; Load first wrf file
  f2_mar = addfile(dir2 + fname3 + ".nc","r")  ; Load first wrf file
  var2_feb  = f2_feb->$invar1$(time|:,south_north|:,west_east|:)
  var2_mar  = f2_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_2 = f2_feb->lat
  lon2d_2 = f2_feb->lon
  var2_feb@lat2d = lat2d_2
  var2_feb@lon2d = lon2d_2
  dims2 = dimsizes(lat2d_2)
  nlat_2 = dims2(0)
  nlon_2 = dims2(1)

; third wrf file
  f3_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.50km.nc", "r")
  land3 = f3_geo->LANDMASK(Time|0,south_north|:,west_east|:)

  f3_feb = addfile(dir3 + fname2 + ".nc","r")  ; Load first wrf file
  f3_mar = addfile(dir3 + fname3 + ".nc","r")  ; Load first wrf file
  var3_feb  = f3_feb->$invar1$(time|:,south_north|:,west_east|:)
  var3_mar  = f3_mar->$invar1$(time|:,south_north|:,west_east|:)

  lat2d_3 = f3_feb->lat
  lon2d_3 = f3_feb->lon
  var3_feb@lat2d = lat2d_3
  var3_feb@lon2d = lon2d_3
  dims3 = dimsizes(lat2d_3)
  nlat_3 = dims3(0)
  nlon_3 = dims3(1)

; fourth wrf file
  f4_geo = addfile("/ptmp/duvivier/group/geo_em/geo_em.d01.100km.nc", "r")
  land4 = f4_geo->LANDMASK(Time|0,south_north|:,west_east|:)

  f4_feb = addfile(dir4 + fname2 + ".nc","r")  ; Load first wrf file
  f4_mar = addfile(dir4 + fname3 + ".nc","r")  ; Load first wrf file
  var4_feb  = f4_feb->$invar1$(time|:,south_north|:,west_east|:)
  var4_mar  = f4_mar->$invar1$(time|:,south_north|:,west_east|:)

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
; Make arrays for full data sets with both feb and mar
;;;;;;;;;;;;
  ; get time dimensions for february and march
  dim_feb = dimsizes(var4_feb)
  t_feb = dim_feb(0)
  dim_mar = dimsizes(var4_mar)
  t_mar = dim_mar(0)
  t_tot = t_feb + t_mar

  ; make new arrays and fill them with old data
  var1_tot = new((/t_tot, nlat_1, nlon_1/), "float")
     var1_tot(0:t_feb-1, :, :) = var1_feb
     var1_tot(t_feb:t_tot-1, :, :) = var1_mar

  var2_tot = new((/t_tot, nlat_2, nlon_2/), "float")
     var2_tot(0:t_feb-1, :, :) = var2_feb
     var2_tot(t_feb:t_tot-1, :, :) = var2_mar

  var3_tot = new((/t_tot, nlat_3, nlon_3/), "float")
     var3_tot(0:t_feb-1, :, :) = var3_feb
     var3_tot(t_feb:t_tot-1, :, :) = var3_mar

  var4_tot = new((/t_tot, nlat_4, nlon_4/), "float")
     var4_tot(0:t_feb-1, :, :) = var4_feb
     var4_tot(t_feb:t_tot-1, :, :) = var4_mar

;;;;;;;;;;;;;
; Average over time dimension
;;;;;;;;;;;;
  ; time average and keep meta data
  var1_avg = dim_avg_n_Wrap(var1_tot, 0)
  var2_avg = dim_avg_n_Wrap(var2_tot, 0)
  var3_avg = dim_avg_n_Wrap(var3_tot, 0)
  var4_avg = dim_avg_n_Wrap(var4_tot, 0)

  fill = var1_avg@_FillValue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Find total subset area fluxes (integrated)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;
; Subset data by lat/lon
;;;;;;;;;;;;
  print("Subsetting data of interest")
; subset data where 56<lat<70 and -54<lon<-20
; for true values, make the subset array the value from the average, for false values make it the fill value so it won't go into summed values

  var1_sub = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., var1_avg, fill)

  var2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., var2_avg, fill)

  var3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., var3_avg, fill)

  var4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., var4_avg, fill)


;;;;;;;;;;;;;
; Mask out land points
;;;;;;;;;;;;
  print("Masking land points for fluxes")
  ; can use False or 0 as last argument to set it to a fill value

  var1_masked = mask(var1_sub,land1 .eq. 1 ,False)
  copy_VarMeta(var1_avg,var1_masked)

  var2_masked = mask(var2_sub,land2 .eq. 1 ,False)
  copy_VarMeta(var2_avg,var2_masked)

  var3_masked = mask(var3_sub,land3 .eq. 1 ,False)
  copy_VarMeta(var3_avg,var3_masked)

  var4_masked = mask(var4_sub,land4 .eq. 1 ,False)
  copy_VarMeta(var4_avg,var4_masked)

;;;;;;;;;;;;;
; Multiply values by the area of grid cells for each simulation
;;;;;;;;;;;;
   ; !!!!!!  UPDATE: DON'T MULTIPLY BY AREA: it's simpler just to sum the fluxes and divide by the total number of ocean grid points going into the sum

;  print("multiplying by grid area")

;  var1_W = var1_masked ;* (10.*10.) * (1000.*1000.)   ; W/m2 * (km*km) * (1000m/km * 1000m/km)
;  var2_W = var2_masked ;* (25.*25.) * (1000.*1000.)
;  var3_W = var3_masked ;* (50.*50.) * (1000.*1000.)
;  var4_W = var4_masked ;* (100.*100.) * (1000.*1000.)

;;;;;;;;;;;;;
; Find total number of gridcells going into summation
;;;;;;;;;;;;
  print("find total number of grid cells going into sum")

  var1_pts = num(.not.ismissing(var1_masked))
  var2_pts = num(.not.ismissing(var2_masked))
  var3_pts = num(.not.ismissing(var3_masked))
  var4_pts = num(.not.ismissing(var4_masked))

;;;;;;;;;;;;;
; Summing over all ocean grid cells
;;;;;;;;;;;;
  print("summing fluxes and dividing by total number of cells")

  var1_int = sum(var1_masked)/ var1_pts
  var2_int = sum(var2_masked)/ var2_pts
  var3_int = sum(var3_masked)/ var3_pts
  var4_int = sum(var4_masked)/ var4_pts


  print ("The 10km area integrated average " + varcode + " flux (W/m2) is: " + max(var1_int))
  print ("The 25km area integrated average " + varcode + " flux (W/m2) is: " + max(var2_int))
  print ("The 50km area integrated average " + varcode + " flux (W/m2) is: " + max(var3_int))
  print ("The 100km area integrated average " + varcode + " flux (W/m2) is: " + max(var4_int))

;;;;;;;;;;;;;;;;;;;;;; END script

end


