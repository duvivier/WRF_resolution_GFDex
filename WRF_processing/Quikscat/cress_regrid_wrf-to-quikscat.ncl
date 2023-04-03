;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRF grid to 
;                      rectilinear Quikscat grid using Cressman weighting
; INPUT DATA: WRF geo_em.d01.nc file 
;             and Quikscat text files lat2d.txt and lon2d.txt
; OUTPUT DATA: two text files of the grid indicies and weights 
;              for a particular WRF resolution regridded to Quikscat
; Note: This does not have a cshell script for looping. Manual inputs below
; CREATOR: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; MANUAL INPUTS
; Adjust these parameters as needed:
; (area of influence for weighting)
cressrad      = 9.5   ; cressman radius in km (10km->Qs)
;cressrad      = 24.  ; cressman radius in km (25km->Qs)
;cressrad      = 45.  ; cressman radius in km (50km->Qs)
;cressrad      = 95.  ; cressman radius in km (100km->Qs)

; input file information
dir1 = "/data3/duvivier/NCAR/"
dir2 = "/data3/duvivier/NCAR/"
outdir = "./"
fname1 = "21FEB/wrf_10km/geo_em.d01"     ; file with original grid
fname2  = "Quikscat/qs_data/21FEB/Quikscat_lat2d"
fname22 = "Quikscat/qs_data/21FEB/Quikscat_lon2d"
title1 = "WRF_10"
title2 = "Quikscat"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"  
fout1   = outdir+"indicies_"+title1+"_to_"+title2      ; Name 1D array of indicies and weights
fout2   = outdir+"weights_"+title1+"_to_"+title2

print("Interpolating from "+title1+" to  "+title2)

;;;;;;;;;;
; add data
;;;;;;;;;;

; Load WRF lat/lon: 
  f1 = addfile(dir1 + fname1 + ".nc","r")
  lat2d_1 = f1->XLAT_M(0,:,:)
  lon2d_1 = f1->XLONG_M(0,:,:)
  
  lat1d_1 = ndtooned(lat2d_1)  ; convert all arrays to 1D
  lon1d_1 = ndtooned(lon2d_1)

; Load Quikscat lat/lon:
  ;ncol = 110                  ; specified from MatLab data
  ncol = 170
  header = 0                  ; no header lines

  lat2d_2 = readAsciiTable(dir2 + fname2 + ".txt",ncol,"float",header)
  lon2d_2 = readAsciiTable(dir2 + fname22 + ".txt",ncol,"float",header)

  lat1d_2 = ndtooned(lat2d_2)
  lon1d_2 = ndtooned(lon2d_2)

  dims_2 = dimsizes(lat2d_2)     ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we               ; get total number of points in high res domain

;;;;;;;;;;
; regrid the first file to second file resolution
;;;;;;;;;;

; create weights and appropriate indicies for Cressman interpolation
  max_indices = 5                                     ; maximum number of points that can be included in weighted avg 
  interp_ind = new((/n_tot,max_indices/), "integer")  ; make array to put index values in
  interp_ind!0 = "old_index"                          ; name the dimensions of the array
  interp_ind!1 = "new_indices"
  interp_wgt = new((/n_tot,max_indices/), "float")    ; make array for weights
  interp_wgt!0 = "old_index"
  interp_wgt!1 = "new_weightings"

; run loop
  index = 0          ; set first index
  do i = 0, n_tot-1

   ; get great circle distance between the different grids in km
     dist = gc_latlon(lat1d_2(i),lon1d_2(i),lat1d_1,lon1d_1,2,4) 

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist))) then       
      nreplacements = num(isnan_ieee(dist))  ; find index of NaN
      replace_ieeenan(dist,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print that there were replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work (all points outside sphere of influence.)
    if (min(dist).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist.lt.cressrad)    ; find the indicies where the distance is within the cressman radius
    weight = (cressrad^2 - dist(indicies)^2) / (cressrad^2 + dist(indicies)^2)  ; give each index a weight

  ; save calculated indicies and weighting factors for future use
    n_indicies = dimsizes(indicies)
    interp_ind(i,0:n_indicies-1) = (/indicies/)  ; put the indicies affecting each new grid point into an array for later
    interp_wgt(i,0:n_indicies-1) = (/weight/)    ; put the weights for each point into an array for later 
    delete(indicies)
    delete(weight)

;;;;;;;
; counter
;;;;;;;

    if(i%100.eq.0) then
      print("created weighting "+i+" of "+n_tot)
    end if

    index = index + 1                             ; increase the index
  end do

;;;;;;  
; write weights and indices files
;;;;;;

  asciiwrite(fout1+".txt",interp_ind)  ; write indices to text file
  asciiwrite(fout2+".txt",interp_wgt)  ; write weights to text file

;;;;;;;;;;;;;;;;;;;;;; END script
end
