;***************************************
; PROGRAM DESCRIPTION: This NCL script recalculates and plots surface fluxes
; INPUT DATA: Two WRF output files of different resolutions,text files of
;             weights and indicies to regrid
; OUTPUT DATA: Panel plot of recalculated fluxes and differences
; Note: No cshell is written to loop this. Inputs are specified manually below.
; CREATOR: Alice DuVivier - February 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
dir1 = "/data3/duvivier/NCAR/flux_tests/"
dir2 = "/data3/duvivier/NCAR/flux_tests/"
fname1 = "wrf-2007-02-21-15_100km"     ; file with original grid
fname2 = "wrf-2007-02-21-15_10km"     ; file with grid to interpolate to
title1 = "WRF_100"
title2 = "WRF_10"
date1 = "2007-02-21-15"
; set if this is a zoomed plot or the whole domain
zoom = True
whole_dom = False

; BEGIN SCRIPT
; Check for input information:
  if(.not.any(isvar("dir1").and.isvar("dir2") \
              .and.isvar("fname1").and.isvar("fname2") \
              .and.isvar("title1").and.isvar("title2") \
              .and.isvar("date1"))) then
    print("Can't find all input information!")
;    exit
  end if

; set outdir and fout names
outdir = "./"
fout   = outdir+"Flux_diffs_"+title1+"_"+title2+"_"+date1

; set weight and index file names
ind_in = "indicies_"+title1+"_to_"+title2
wgt_in = "weights_"+title1+"_to_"+title2


; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")

  print("Running Flux recalcuations for "+title1+" to  "+title2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load files and variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set constants
  R  = 287.   ; 287  J/kg*K
  cp = 1004.  ; 1004 J/kg*K
  lv = 2.5E6  ; 2.5E6 J/kg

;;;;;;;;;;
; load in two wrf files
;;;;;;;;;;

  f1 = addfile(dir1 + fname1 + ".nc","r")
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  
  f2 = addfile(dir2 + fname2 + ".nc","r")
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon

  dims_2 = dimsizes(lat2d_2)     ; get lat/lon dimensions from second domain
  n_sn = dims_2(0)              ; get south/north points
  n_we = dims_2(1)              ; get west/east points
  n_tot = n_sn*n_we              ; get total number of points in high res domain
  nlat = n_sn                   ; used in plots
  nlon = n_we                   ; used in plots

;;;;;;;;;;
; load in weight and index arrays
;;;;;;;;;;
  print("Loading weight and index arrays")

; create weights and appropriate indicies for Cressman interpolation
  max_indicies = 5                                     ; maximum number of points that can be included in weighted avg 

; load in arrays of indicies and weights
  ncol = 1   ; number of columns
  header = 0 ; number of header lines

  inds_in = readAsciiTable(dir1+ind_in+".txt",ncol,"integer",header)  ; read in ascii as float to get statistics
  wgts_in = readAsciiTable(dir1+wgt_in+".txt",ncol,"float",header)  ; read in ascii as float to get statistics

  interp_ind = onedtond(inds_in,(/n_tot,max_indicies/))
  interp_ind!0 = title2+"_index"                      ; name the dimensions of the array
  interp_ind!1 = title1+"_indicies"  
  
  interp_wgt = onedtond(wgts_in,(/n_tot,max_indicies/))
  interp_wgt!0 = title2+"_index"
  interp_wgt!1 = title1+"_weightings"


;;;;;;;;;;
; load in variables from WRF files
;;;;;;;;;;
  print("Loading "+title1+" and "+title2)

  f1_SHflx = f1->SHFlx(time|0,south_north|:,west_east|:)             ; load SH flux
  f1_LHflx = f1->LHFlx(time|0,south_north|:,west_east|:)             ; load LH flux
  f1_slp   = f1->slp(time|0,south_north|:,west_east|:)               ; load slp
  f1_T_sfc = f1->T_sfc(time|0,south_north|:,west_east|:)             ; load surface temp
  f1_u     = f1->u_10m_tr(time|0,south_north|:,west_east|:)          ; load u 10m
  f1_v     = f1->v_10m_tr(time|0,south_north|:,west_east|:)          ; load v 10m 
  f1_q_air = f1->q_e(time|0,eta|0,south_north|:,west_east|:)         ; load mratio air
  f1_Th_air= f1->Th_e(time|0,eta|0,south_north|:,west_east|:)        ; load pot temp air

  f2_SHflx = f2->SHFlx(time|0,south_north|:,west_east|:)             ; load SH flux
  f2_LHflx = f2->LHFlx(time|0,south_north|:,west_east|:)             ; load LH flux
  f2_slp   = f2->slp(time|0,south_north|:,west_east|:)               ; load slp
  f2_T_sfc = f2->T_sfc(time|0,south_north|:,west_east|:)             ; load surface temp
  f2_u     = f2->u_10m_tr(time|0,south_north|:,west_east|:)          ; load u 10m
  f2_v     = f2->v_10m_tr(time|0,south_north|:,west_east|:)          ; load v 10m 
  f2_q_air = f2->q_e(time|0,eta|0,south_north|:,west_east|:)         ; load mratio air
  f2_Th_air= f2->Th_e(time|0,eta|0,south_north|:,west_east|:)        ; load pot temp air


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate necessary vars 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
; Pot temp grad
;;;;;;;;;;
  f1_slp = f1_slp*100.                                  ; convert hPa to Pa [Pa]
  f2_slp = f2_slp*100.

  f1_Th_sfc = f1_T_sfc*((100000./f1_slp)^(R/cp))        ; calculate surface pot temp [K]
  f2_Th_sfc = f2_T_sfc*((100000./f2_slp)^(R/cp))

  f1_tgrad = f1_Th_sfc - f1_Th_air                      ; calculate pot temp grad [K]
  f2_tgrad = f2_Th_sfc - f2_Th_air

;;;;;;;;;;
; Mix Ratio grad
;;;;;;;;;;

  f1_T_c = f1_T_sfc - 273.15                            ; convert surface temp to C
  f1_satvp = 0.6112*exp((17.67*f1_T_c)/(243.5+f1_T_c))*10.*100. ; calc satvp in Pa
  f1_q_sfc = 0.622*(f1_satvp/(f1_slp-f1_satvp))         ; Saturation mixing ratio [kg/kg]

  f2_T_c = f2_T_sfc - 273.15                            ; convert surface temp to C
  f2_satvp = 0.6112*exp((17.67*f2_T_c)/(243.5+f2_T_c))*10.*100. ; calc satvp in Pa
  f2_q_sfc = 0.622*(f2_satvp/(f2_slp-f2_satvp))         ; Saturation mixing ratio [kg/kg]

  f1_qgrad = f1_q_sfc - f1_q_air                        ; calculate mix ratio grad [kg/kg]
  f2_qgrad = f2_q_sfc - f2_q_air

;;;;;;;;;;
; wind speed
;;;;;;;;;;

  f1_wspd = sqrt(f1_u^2+f1_v^2)                       ; calcluate wind speed [m/s]
  f2_wspd = sqrt(f2_u^2+f2_v^2)

;;;;;;;;;;
; density surface air
;;;;;;;;;;

  f1_rho = f1_slp / (R*f1_T_sfc)                       ; calculate density [kg/m3]
  f2_rho = f2_slp / (R*f2_T_sfc)
  
;;;;;;;;;;
; Bulk transfer coefficients
;;;;;;;;;;

  dum1 = (f1_rho*cp*f1_wspd*f1_tgrad)
  denom1 = where(dum1 .eq. 0, -999, dum1)              ; deal with denom = 0
  f1_Ch = f1_SHflx/denom1                              ; calculate SH coeff [none]

  dum2 = (f2_rho*cp*f2_wspd*f2_tgrad)
  denom2 = where(dum2 .eq. 0, -999, dum2)              ; deal with denom = 0
  f2_Ch = f2_SHflx/denom2                              ; calculate SH coeff [none]

  delete(dum1)
  delete(dum2)

  dum1 = (f1_rho*lv*f1_wspd*f1_qgrad)
  denom1 = where(dum1 .eq. 0, -999, dum1)              ; deal with denom = 0
  f1_Ce = f1_LHflx/denom1                              ; calculate SH coeff [none]

  dum2 = (f2_rho*lv*f2_wspd*f2_qgrad)
  denom2 = where(dum2 .eq. 0, -999, dum2)              ; deal with denom = 0
  f2_Ce = f2_LHflx/denom2                              ; calculate SH coeff [none]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Interpolate variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Interpolating "+title1+" to  "+title2)

  ; convert f1 data to one dimension
  f1_SHflx_1d = ndtooned(f1_SHflx)
  f1_LHflx_1d = ndtooned(f1_LHflx)
  f1_qgrad_1d = ndtooned(f1_qgrad)
  f1_tgrad_1d = ndtooned(f1_tgrad)
  f1_u_1d     = ndtooned(f1_u)
  f1_v_1d     = ndtooned(f1_v)
  f1_Ch_1d    = ndtooned(f1_Ch)
  f1_Ce_1d    = ndtooned(f1_Ce)

  ; preallocate arrays for new 1d variables
  f2_1d = ndtooned(lat2d_2)

  f1_SHflx_1d_new = new(dimsizes(f2_1d),"float")
  f1_LHflx_1d_new = new(dimsizes(f2_1d),"float")
  f1_qgrad_1d_new = new(dimsizes(f2_1d),"float")
  f1_tgrad_1d_new = new(dimsizes(f2_1d),"float")
  f1_u_1d_new     = new(dimsizes(f2_1d),"float")
  f1_v_1d_new     = new(dimsizes(f2_1d),"float")
  f1_Ch_1d_new    = new(dimsizes(f2_1d),"float")
  f1_Ce_1d_new    = new(dimsizes(f2_1d),"float")

  ; preallocate arrays for new 2d variables
  f1_SHflx_new = new(dimsizes(lat2d_2),"float")
  f1_LHflx_new = new(dimsizes(lat2d_2),"float")
  f1_qgrad_new = new(dimsizes(lat2d_2),"float")
  f1_tgrad_new = new(dimsizes(lat2d_2),"float")
  f1_u_new     = new(dimsizes(lat2d_2),"float")
  f1_v_new     = new(dimsizes(lat2d_2),"float")
  f1_Ch_new    = new(dimsizes(lat2d_2),"float")
  f1_Ce_new    = new(dimsizes(lat2d_2),"float")

; Start do loop
  do i = 0, n_tot-1

    indicies = interp_ind(i,:)
    num_ind      = num(.not.ismissing(indicies))
    
    weights = interp_wgt(i,:)
    num_wgt      = num(.not.ismissing(weights))
      if(num_ind.ne.num_wgt) then
        print("Loaded different numbers of weight and indicies!")
        exit
      end if
    inds = indicies(0:num_ind-1)
    wgt  = weights(0:num_wgt-1)
    
    f1_SHflx_1d_new(i) = sum(f1_SHflx_1d(inds)*wgt)/sum(wgt)
    f1_LHflx_1d_new(i) = sum(f1_LHflx_1d(inds)*wgt)/sum(wgt)
    f1_qgrad_1d_new(i) = sum(f1_qgrad_1d(inds)*wgt)/sum(wgt)
    f1_tgrad_1d_new(i) = sum(f1_tgrad_1d(inds)*wgt)/sum(wgt)
    f1_u_1d_new(i)     = sum(f1_u_1d(inds)*wgt)/sum(wgt)
    f1_v_1d_new(i)     = sum(f1_v_1d(inds)*wgt)/sum(wgt)
    f1_Ch_1d_new(i)    = sum(f1_Ch_1d(inds)*wgt)/sum(wgt)
    f1_Ce_1d_new(i)    = sum(f1_Ce_1d(inds)*wgt)/sum(wgt)


    delete(inds)
    delete(wgt)

    ; Counter
    if(i%1000.eq.0) then
      print("interpolated "+i+" of "+n_tot)
    end if

  end do


; Redimensionalize newly interpolated data
 
  f1_SHflx_new = onedtond(f1_SHflx_1d_new,(/nlat,nlon/))
  f1_LHflx_new = onedtond(f1_LHflx_1d_new,(/nlat,nlon/))
  f1_qgrad_new = onedtond(f1_qgrad_1d_new,(/nlat,nlon/))
  f1_tgrad_new = onedtond(f1_tgrad_1d_new,(/nlat,nlon/))
  f1_u_new     = onedtond(f1_u_1d_new,(/nlat,nlon/))
  f1_v_new     = onedtond(f1_v_1d_new,(/nlat,nlon/))  
  f1_Ch_new    = onedtond(f1_Ch_1d_new,(/nlat,nlon/))
  f1_Ce_new    = onedtond(f1_Ce_1d_new,(/nlat,nlon/))

  f1_wspd_new = sqrt(f1_u_new^2 + f1_v_new^2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate flux values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;
; Calculate 10km-100km flux values
;;;;;;;;;; 

  ; to be used in denominators, so replace zeros with missing values
  diff_SH = f2_SHflx - f1_SHflx_new
    diff_SH = where(diff_SH .eq.0, -999, diff_SH)
  
  diff_LH = f2_LHflx - f1_LHflx_new
    diff_LH = where(diff_LH .eq.0, -999, diff_LH)

;;;;;;;;;;
; Calculate flux differences due to wind
;;;;;;;;;; 

  f2_SHflx_wnd = f2_rho*cp*f2_Ch*f2_tgrad*f1_wspd_new     ; calculate the "new" fluxes
  f2_LHflx_wnd = f2_rho*lv*f2_Ce*f2_qgrad*f1_wspd_new

  diff_SH_wnd = f2_SHflx - f2_SHflx_wnd                   ; get diff.for  wrf and calc flux
  diff_LH_wnd = f2_LHflx - f2_LHflx_wnd

  SH_wnd = (diff_SH_wnd/diff_SH)                     ; get ratio
  LH_wnd = (diff_LH_wnd/diff_LH)

;  SH_wnd = (diff_SH_wnd/diff_SH)*100.                     ; get percent difference
;  LH_wnd = (diff_LH_wnd/diff_LH)*100.

;;;;;;;;;;
; Calculate flux differences due to gradients
;;;;;;;;;; 

  f2_SHflx_grad = f2_rho*cp*f2_Ch*f2_wspd*f1_tgrad_new    ; calculate the "new" fluxes
  f2_LHflx_grad = f2_rho*lv*f2_Ce*f2_wspd*f1_qgrad_new

  diff_SH_grad = f2_SHflx - f2_SHflx_grad                 ; get diff.for  wrf and calc flux
  diff_LH_grad = f2_LHflx - f2_LHflx_grad

  SH_grad = (diff_SH_grad/diff_SH)                   ; get ratio
  LH_grad = (diff_LH_grad/diff_LH)

;  SH_grad = (diff_SH_grad/diff_SH)*100.                   ; get percent difference
;  LH_grad = (diff_LH_grad/diff_LH)*100.

;;;;;;;;;;
; Calculate flux differences due to transfer coeff
;;;;;;;;;; 

  f2_SHflx_bulk = f2_rho*cp*f2_tgrad*f2_wspd*f1_Ch_new    ; calculate the "new" fluxes
  f2_LHflx_bulk = f2_rho*lv*f2_qgrad*f2_wspd*f1_Ce_new

  diff_SH_bulk = f2_SHflx - f2_SHflx_bulk                 ; get diff.for  wrf and calc flux
  diff_LH_bulk = f2_LHflx - f2_LHflx_bulk

  SH_bulk = (diff_SH_bulk/diff_SH)                   ; get ratio
  LH_bulk = (diff_LH_bulk/diff_LH)

;  SH_bulk = (diff_SH_bulk/diff_SH)*100.                   ; get percent difference
;  LH_bulk = (diff_LH_bulk/diff_LH)*100.


;;;;;;;;;;
; mask all variables above 500m
;;;;;;;;;; 
; check if the data needs a mask above 500m terrain height.
; This uses the terrain height from the high res wrf file and masks both files with it
    print("Masking land for plot above 500m.")
    terr = f2->Z_sfc(:,:)

    SH_wnd = mask(SH_wnd, terr .gt. 500, False)  ; masks land ABOVE 500m
    LH_wnd = mask(LH_wnd, terr .gt. 500, False)

    SH_grad = mask(SH_grad, terr .gt. 500, False)
    LH_grad = mask(LH_grad, terr .gt. 500 ,False)

    SH_bulk = mask(SH_bulk, terr .gt. 500, False)
    LH_bulk = mask(LH_bulk, terr .gt. 500, False)

;;;;;;;;;;
; assign lat/lon and coordinate variables
;;;;;;;;;; 

    copy_VarCoords(lat2d_2, SH_wnd)
    copy_VarCoords(lat2d_2, LH_wnd)

    SH_wnd@lat2d = lat2d_2
    SH_wnd@lon2d = lon2d_2
    LH_wnd@lat2d = lat2d_2
    LH_wnd@lon2d = lon2d_2

    copy_VarCoords(lat2d_2, SH_grad)
    copy_VarCoords(lat2d_2, LH_grad)

    SH_grad@lat2d = lat2d_2
    SH_grad@lon2d = lon2d_2
    LH_grad@lat2d = lat2d_2
    LH_grad@lon2d = lon2d_2

    copy_VarCoords(lat2d_2, SH_bulk)
    copy_VarCoords(lat2d_2, LH_bulk)

    SH_bulk@lat2d = lat2d_2
    SH_bulk@lon2d = lon2d_2
    LH_bulk@lat2d = lat2d_2
    LH_bulk@lon2d = lon2d_2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  print("Processing flux % diff graphs for "+date1)

;;;;;;;;;;
; set contour limits for variables
;;;;;;;;;;
  cmin1 = -1.5
  cmax1 = 1.5
  clev1 = 0.25
;    cmin1 = -200.
;    cmax1 = 200.
;    clev1 = 25.
  stride1             = 1                 ; label stride
  plotlines           = False              ; lines for reg plot
  cntype              = "RasterFill"      ; type of contour fill
  spreadstart1        = 2                 ; start at color
  spreadend1          = 102                ; end at color
  colormap            = "BlWhRe"

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(6, graphic)

;;;;;;;;;;
; set plot titles
;;;;;;;;;;
    title_0 = "Sensible Heat Flux: test var = 10m wind"
    title_1 = "Latent Heat Flux: test var = 10m wind"
    title_2 = "Sensible Heat Flux: test var = pot. temp. grad."
    title_3 = "Latent Heat Flux: test var = mix. ratio grad."
    title_4 = "Sensible Heat Flux: test var = bulk coeff. Ch"
    title_5 = "Latent Heat Flux: test var = bulk coeff. Ce"

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set for Greenland
  res@mpCenterLatF                = 60.               ; -----set for Greenland
  
 if (isvar("whole_dom").and.(whole_dom))then
  res@mpLimitMode                 = "Corners"
  res@mpLeftCornerLatF            = lat2d_2(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d_2(0,0)
  res@mpRightCornerLatF           = lat2d_2(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d_2(nlat-1,nlon-1)
 end if

 if (isvar("zoom").and.(zoom))then
  res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpMinLatF                   = 56.              ; set the minimum latitude
  res@mpMaxLatF                   = 67.              ; set the maximum latitude
  res@mpMinLonF                   = -57.0            ; set the minimum longitude
  res@mpMaxLonF                   = -30.0            ; set the maximum longitude
 end if

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
  
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in missing values
  res@tiMainFontHeightF          = 0.011
  res@lbLabelBarOn               = False             ; turn off individual label bars

;;;;;;;;;;;;;
; Plot 0 - SH (wind)
;;;;;;;;;;;;;

  opts0                            = res               ; reset options
  opts0@tiMainString               = title_0
    
  cplot0 = gsn_csm_contour_map(wks, SH_wnd, opts0)     ; create plot
  plot(0) = cplot0                                     ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - LH (wind)
;;;;;;;;;;;;;

  opts1                            = res               ; reset options
  opts1@tiMainString               = title_1
    
  cplot1 = gsn_csm_contour_map(wks, LH_wnd, opts1)     ; create plot
  plot(1) = cplot1                                     ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - SH (tgrad)
;;;;;;;;;;;;;

  opts2                            = res               ; reset options
  opts2@tiMainString               = title_2
    
  cplot2 = gsn_csm_contour_map(wks, SH_grad, opts2)     ; create plot
  plot(2) = cplot2                                     ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 3 - LH (qgrad)
;;;;;;;;;;;;;

  opts3                            = res               ; reset options
  opts3@tiMainString               = title_3
    
  cplot3 = gsn_csm_contour_map(wks, LH_grad, opts3)     ; create plot
  plot(3) = cplot3                                     ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - SH (Bulk-Ch)
;;;;;;;;;;;;;

  opts4                            = res               ; reset options
  opts4@tiMainString               = title_4
    
  cplot4 = gsn_csm_contour_map(wks, SH_bulk, opts4)     ; create plot
  plot(4) = cplot4                                     ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 5 - LH (Bulk-Ce)
;;;;;;;;;;;;;

  opts5                            = res               ; reset options
  opts5@tiMainString               = title_5
    
  cplot5 = gsn_csm_contour_map(wks, LH_bulk, opts5)     ; create plot
  plot(5) = cplot5                                     ; make panel section of this plot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title_fin = "                     Sensible and Latent Heat Flux Difference Ratio- "+date1+" ~C~ (Flux "+title2+" - Flux "+title2+"("+title1+" test variable) / (Flux "+title2+" - Flux "+title1+"))"


;   title_fin = "                Sensible and Latent Heat Flux Percent Differences- "+date1+" ~C~ (Flux "+title2+" - Flux "+title2+"("+title1+" test variable) / (Flux "+title2+" - Flux "+title1+")) *100"

  pnlres                            = True
  pnlres@txString                   = title_fin           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbLabelStride              = stride1
;  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  pnlres@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  pnlres@pmLabelBarWidthF           = 0.65

  pnlres@gsnMaximize                = True
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/3,2/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)


;;;;;;;;;;;;;;;;;;;;;; END script
end


