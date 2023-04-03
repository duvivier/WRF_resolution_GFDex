;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and 100km spacing
; OUTPUT DATA: plot of the terrain at 10km and labels for locations,
;              difference plot of wrf100 and wrf10 terrain height along southeast coast.
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; inputs for file
dir1 = "/data3/duvivier/NCAR/DATA/geo_em/"
outdir = "./"
fname1 = "geo_em.d01_100km"     
fname2 = "geo_em.d01_50km"     
fname3 = "geo_em.d01_25km"     
fname4 = "geo_em.d01_10km"     
title1 = "WRF_100"
title2 = "WRF_50"
title3 = "WRF_25"
title4 = "WRF_10"
varcode = "hgt"

; BEGIN SCRIPT

; set outdir and fout names
outdir = "./"
fout   = outdir+"terrain_gradients"

;;;;;;;;;;
; add data
;;;;;;;;;;

; Load 1st file topography
  f1 = addfile(dir1 + fname1 + ".nc","r")
  hgt2d_1 = f1->HGT_M(0,:,:)
  lat2d_1 = f1->XLAT_M(0,:,:)
  lon2d_1 = f1->XLONG_M(0,:,:)
  
; Load 2nd file topography
  f2 = addfile(dir1 + fname2 + ".nc","r")
  hgt2d_2 = f2->HGT_M(0,:,:)
  lat2d_2 = f2->XLAT_M(0,:,:)
  lon2d_2 = f2->XLONG_M(0,:,:)

; Load 3rd file topography
  f3 = addfile(dir1 + fname3 + ".nc","r")
  hgt2d_3 = f3->HGT_M(0,:,:)
  lat2d_3 = f3->XLAT_M(0,:,:)
  lon2d_3 = f3->XLONG_M(0,:,:)
  
; Load 4th file topography
  f4 = addfile(dir1 + fname4 + ".nc","r")
  hgt2d_4 = f4->HGT_M(0,:,:)
  lat2d_4 = f4->XLAT_M(0,:,:)
  lon2d_4 = f4->XLONG_M(0,:,:)

  dimll = dimsizes(lat2d_1)
  nlat = dimll(0)
  nlon = dimll(1)

  test = new((/nlat/), "float")

;;;;;;;;;;;;;
; Subset data by lat/lon
;;;;;;;;;;;;
  print("Subsetting data of interest")
  fill = test@_FillValue

; subset data where 56<lat<70 and -54<lon<-20
; for true values, make the subset array the value from the average, for false values make it the fill value so it won't go into summed values

  ; file 1
  hgt1_sub = where(lat2d_1 .gt. 56. .and. lat2d_1 .lt. 70. .and. lon2d_1 .gt. -54. .and. lon2d_1 .lt. -20., hgt2d_1, fill)

  hgt1_sub@_FillValue = fill
  hgt1_sub@lat2d = lat2d_1
  hgt1_sub@lon2d = lon2d_1

 ; file 2
  hgt2_sub = where(lat2d_2 .gt. 56. .and. lat2d_2 .lt. 70. .and. lon2d_2 .gt. -54. .and. lon2d_2 .lt. -20., hgt2d_2, fill)

  hgt2_sub@_FillValue = fill
  hgt2_sub@lat2d = lat2d_2
  hgt2_sub@lon2d = lon2d_2

  ; file 3
  hgt3_sub = where(lat2d_3 .gt. 56. .and. lat2d_3 .lt. 70. .and. lon2d_3 .gt. -54. .and. lon2d_3 .lt. -20., hgt2d_3, fill)

  hgt3_sub@_FillValue = fill
  hgt3_sub@lat2d = lat2d_3
  hgt3_sub@lon2d = lon2d_3

 ; file 4
  hgt4_sub = where(lat2d_4 .gt. 56. .and. lat2d_4 .lt. 70. .and. lon2d_4 .gt. -54. .and. lon2d_4 .lt. -20., hgt2d_4, fill)

  hgt4_sub@_FillValue = fill
  hgt4_sub@lat2d = lat2d_4
  hgt4_sub@lon2d = lon2d_4

;;;;;;;;;;;;
; Get maximum heights and location
;;;;;;;;;;;;
  ; file 1
  max1 = max(hgt1_sub)
  print("Maximum terrain height for "+title1+" is: "+max1)
return
  loc0 = ind(hgt1_sub.eq.max1)

;  lat_sub = where(hgt1_sub .eq. max1, lat2d_1,fill)
;  print(lat_sub)
;  loc1 = ind(hgt1_sub .eq. max1) 
;  i10 = loc1(0)
;  i11 = loc1(1)
;  print("Lat: "+lat2d_1(i10,i11))

  ; file 2
  max2 = max(hgt2_sub)
  print("Maximum terrain height for "+title2+" is: "+max2)

  ; file 3
  max3 = max(hgt3_sub)
  print("Maximum terrain height for "+title3+" is: "+max3)

  ; file 4
  max4 = max(hgt4_sub)
  print("Maximum terrain height for "+title4+" is: "+max4)

;;;;;;;;;;;;;;;;;;;;;; END script
end
