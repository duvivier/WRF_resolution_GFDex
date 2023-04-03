;***************************************
; PROGRAM DESCRIPTION: This NCL script makes spatial comparison plots between
;      WRF or ERA data
; INPUT DATA: WRF 50km 6-hourly output and ERA 50km 6-hourly input (in separate files)
; OUTPUT DATA: Postscript and pdf file of plots
; Note: The coresponding .csh script, wrffourpanel.csh, is needed
; to loop this script. 
; CREATORS: Mark Seefeldt - May 2009; Dave Porter - June 2009; Matt Higgins - 6 Jul 2009; Alice DuVivier - September 2010: Modified fourpanel for wind inputs
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
;for testing purposes
dir1 = "/data3/duvivier/NCAR/DATA/21FEB/wrf_10km_new_terrain/"
dir2 = "/data3/duvivier/NCAR/DATA/21FEB/wrf_10km/"
outdir = "./"
fname1 = "wrf-2007-02-21-07"
fname2 = "wrf-2007-02-21-07"
title1 = "WRF10 - 100km terrain"
title2 = "WRF10"
date1 = "2007-02-21-07"
varcode = "SH"


; Check for input information:
  if(.not.any(isvar("dir1").and.isvar("dir2") \
              .and.isvar("fname1").and.isvar("fname2") \
              .and.isvar("title1").and.isvar("title2") \
              .and.isvar("date1") .and.isvar("varcode") \
              )) then
    print("Can't find all input information!")
;    exit
  end if

; determine if var1 is met or wrf data:
  fname1_ch  = stringtochar(fname1)            ; read first input name
  fname1_tag = chartostring(fname1_ch(0:2))    ; get first three letters to check type of input
  fname2_ch  = stringtochar(fname2)            ; read second input name
  fname2_tag = chartostring(fname2_ch(0:2))    ; get first three letters to check type of input


; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")

; set outdir and fout names
outdir = "./"
fout   = outdir+varcode+"_terrain_compare_"+date1
zoom = True ; zoom in on plot

  print("Processing four panel graphs for "+varcode+" "+date1)


; get process month from incoming date
  date1_ch = stringtochar(date1)
  month1 = stringtointeger(chartostring(date1_ch(4:5)))
  month2 = month1

;;;;;;;;;;
; add data
;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
  precip_add = False ; normal by default averaging
; Which variables need to be loaded?
 if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"
    invar2 = "slp"
    vartype = "2d"
    cmaptype = "pressure"
    mask_500 = True
 end if
 if (varcode.eq."Windsurf") then
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_tr"
    invar11 ="v_10m_tr"
    invar2 = "u_10m_tr"
    invar22 = "v_10m_tr"
    vartype = "2d"
    cmaptype = "wind"
    find_speed = True
    met_not_avail = True  ; wind data not in met
 end if
 if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2 m"
    invar1 = "T_2m"
    invar2 = "T_2m"
    vartype = "2d"
    cmaptype = "temperature"
    mask_500 = True
 end if
 if (varcode.eq."PTsurf") then
    vartitle1 = "Potential Temperature at surface"
    invar1 = "T_sfc"
    invar2 = "T_sfc"
    vartype = "2d"
    cmaptype = "pottemperature"
    mask_500 = True
    convert_to_PT = True
 end if 
 if (varcode.eq."PTair") then
    vartitle1 = "Potential Temperature at lowest eta level"
    invar1 = "Th_e"
    invar2 = "Th_e"
    vartype = "3d"
    cmaptype = "pottemperature"
    mask_500 = True
 end if
 if (varcode.eq."PTgrad") then
    vartitle1 = "Potential Temperature Gradient (PTsurf-PTair)"
    invar1 = "T_sfc"
    invar11 = "Th_e"
    invar2 = "T_sfc"
    invar22 = "Th_e"
    vartype = "2d"  ; this is only sort of true
    cmaptype = "temp_grad"
    find_grad = True
    t_grad = True
    mask_500 = True
    met_not_avail = True  ; gradient data not in met
  end if
  if (varcode.eq."Q2m") then
    vartitle1 = "Mixing Ratio at 2 m"
    invar1 = "q_2m"
    invar2 = "q_2m"
    vartype = "2d"
    cmaptype = "mix_rad"
  end if
  if (varcode.eq."Qgrad") then
    vartitle1 = "Mixing Ratio Gradient (Q(Tsurf)-Qair)"
    invar1 = "T_sfc"
    invar11 ="q_e"
    invar2 = "T_sfc"
    invar22 = "q_e"
    vartype = "2d"  ; this is only sort of true
    cmaptype = "mix_grad"
    q_grad = True  ; set flag for calculating q at surface
    find_grad = True
    mask_500 = True
    met_not_avail = True  ; gradient data not in met
  end if
  if (varcode.eq."ustar") then
    vartitle1 = "Friction Velocity"
    invar1 = "u_star"
    invar2 = "u_star"
    vartype = "2d"
    cmaptype = "u_star"
    met_not_avail = True  ; ustar data not in met
  end if
  if (varcode.eq."SH") then
    vartitle1 = "Sensible Heat Flux at Sur"
    invar1 = "SHFlx"
    invar2 = "SHFlx"
    vartype = "2d"
    cmaptype = "shflux"
    met_not_avail = True  ; SH data not in met
  end if
  if (varcode.eq."LH") then
    vartitle1 = "Latent Heat Flux at Sur"
    invar1 = "LHFlx"
    invar2 = "LHFlx"
    vartype = "2d"
    cmaptype = "lhflux"
    met_not_avail = True  ; LH data not in met
  end if
  if (varcode.eq."ice") then
    vartitle1 = "Sea Ice Fraction"
    invar1 = "SeaIce"
    invar2 = "SeaIce"
    vartype = "2d"
    cmaptype = "ice"
  end if
  if (varcode.eq."HGT") then
    vartitle1 = "Terrain height"
    invar1 = "Z_sfc"
    invar2 = "Z_sfc"
    vartype = "1d"
    cmaptype = "terr"
  end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1 = 950
    cmax1 = 1050.
    clev1 = 5.
    cmin2 = -10.
    cmax2 = 10.
    clev2 = 2.
    clevd = clev1*2
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."wind") then
    cmin1 = 0
    cmax1 = 35.
    clev1 = 5.
    cmin2 = -10.
    cmax2 = 10.
    clev2 = 2.
    clevd = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 21                ; end at color
    spreadstart2        = 23                ; start at color
    spreadend2          = 45                ; end at color
    colormap            = "winds.alice"
  end if
  if (cmaptype.eq."temperature") then
    cmin1 = -60.
    cmax1 = 20.
    clev1 = 4.
    cmin2 = -10.
    cmax2 = 10.
    clev2 = 2.
    clevd = clev1
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 107 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."pottemperature") then
    cmin1 = 250.
    cmax1 = 290.
    clev1 = 2.
    cmin2 = -6.
    cmax2 = 6.
    clev2 = 1.
    clevd = clev1
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 107 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."temp_grad") then
    cmin1 = -14.
    cmax1 = 14.
    clev1 = 2.
    cmin2 = -10.
    cmax2 = 10.
    clev2 = 2.
    clevd = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 67                 ; start at color
    spreadend1          = 107                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 107 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1 =  0.
    cmax1  = 0.01
    clev1 =  0.002
    cmin2 = -0.001
    cmax2 =  0.001
    clev2 =  0.0005
    clevd = clev1
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."mix_grad") then
    cmin1 = -0.005
    cmax1 = 0.005
    clev1 = 0.001
    cmin2 = -0.001
    cmax2 = 0.001
    clev2 = 0.0005
    clevd = clev1
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "RasterFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 103                ; end at color
    spreadstart2        = 2                ; start at color
    spreadend2          = 103 
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."u_star") then
    cmin1 =  0.
    cmax1 =  2.5
    clev1 =  .1
    cmin2 = -1.
    cmax2 =  1.
    clev2 =  .1
    clevd = clev1*4
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 21               ; end at color
    spreadstart2        = 23                 ; start at color
    spreadend2          = 45               ; end at color
    colormap            = "winds.alice"
  end if
  if (cmaptype.eq."shflux") then
    cmin1 =  -400.
    cmax1 =  400.
    clev1 =  50.
    cmin2 = -400.
    cmax2 =  400.
    clev2 =  50.
    clevd = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"      ; type of fill for contours 
    spreadstart1        = 2                 ; start at color
    spreadend1          = 255               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 255               ; end at color
    colormap            = "BlueYellowRed"
  end if
  if (cmaptype.eq."lhflux") then
    cmin1 =  -400.
    cmax1 =  400.
    clev1 =  50.
    cmin2 = -400.
    cmax2 =  400.
    clev2 =  50.
    clevd = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"      ; type of fill for contours
    spreadstart1        = 2                 ; start at color
    spreadend1          = 255               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 255               ; end at color
    colormap            = "BlueYellowRed"
  end if
  if (cmaptype.eq."ice") then
    cmin1 =  0.
    cmax1 =  1.
    clev1 =  0.05
    cmin2 = -1.
    cmax2 =  1.
    clev2 =  0.10
    clevd = clev1*2
    stride1             = 2                 ; label stride
    stride2             = 2
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 22                ; end at color
    spreadstart2        = 24                ; start at color
    spreadend2          = 46                ; end at color
    colormap            = "seaice.alice"
  end if
  if (cmaptype.eq."terr") then
    cmin1 =  0.
    cmax1 =  4000.
    clev1 =  50.
    cmin2 = -500.
    cmax2 =  500.
    clev2 =  25.
    clevd = clev2
    stride1             = 10                 ; label stride
    stride2             = 10
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "RasterFill"
    spreadstart1        = 3                 ; start at color
    spreadend1          = 68                ; end at color
    spreadstart2        = 102                ; start at color
    spreadend2          = 124                ; end at color
    colormap            = "terrain.alice"
  end if

  title0 = title1+" and "+title2            ; make a title string for the overlay plot
  title3 = title2+" - "+title1              ; make a title string for the difference plot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data manipulation:

; load in the two files. the directories and filenames were specified in the c-shell wrapper
  f1 = addfile(dir1 + fname1 + ".nc","r")
  f2 = addfile(dir2 + fname2 + ".nc","r")

  if (vartype.eq."2d") then
    ; Get first file's variable info
    if (isfilevar(f1,invar1)) then
      var1_3d = f1->$invar1$
      var1 = var1_3d(0,:,:) ; extracting just the first time step
      if (isvar("find_speed").and.(find_speed))then  ; wind needs v component
        var11_3d = f1->$invar11$
        var11 = var11_3d(0,:,:)
      end if
      if (isvar("find_grad").and.(find_grad))then    ; gradients need var at first eta level
        var11_3d = f1->$invar11$(time|:,eta|0,south_north|:,west_east|:)
        var11 = var11_3d(0,:,:)
      end if
    end if
    ; Get second file's variable info
    if (isfilevar(f2,invar2)) then
      var2_3d = f2->$invar2$
      var2 = var2_3d(0,:,:)
      if (isvar("find_speed").and.(find_speed))then
        var22_3d = f2->$invar22$
        var22 = var22_3d(0,:,:)
      end if
      if (isvar("find_grad").and.(find_grad))then
        var22_3d = f2->$invar22$(time|:,eta|0,south_north|:,west_east|:)
        var22 = var22_3d(0,:,:)
      end if
    end if
  end if

; get the latitude and longitude data and dimensions, later used to plot the entire domain
  lat2d  = f1->lat
  lon2d  = f1->lon
  dimll = dimsizes(lat2d)
  nlat = dimll(0)
  nlon = dimll(1)

;;;;;;;;;;
; manipulate arrays as needed - post interpolation
;;;;;;;;;;
; check if the data needs a mask above 500m terrain height.
; This uses the terrain height from the high res wrf file and masks both files with it
  if (isvar("mask_500").and.(mask_500)) then
    print("Masking land for plot above 500m.")
    terr = f2->Z_sfc(:,:)
    var1_masked = mask(var1,terr.gt.500,0)
    var2_masked = mask(var2,terr.gt.500,0)
    copy_VarMeta(var1,var1_masked)
    delete(var1)
    var1 = var1_masked
    copy_VarMeta(var2,var2_masked)
    delete(var2)
    var2 = var2_masked
  end if

; for wind plots, must have u and v data to find differences and speeds
  if (isvar("find_speed").and.(find_speed)) then
    ; Find difference information
    u_diff = var2 - var1
    v_diff = var22 - var11

    u_diff@lat2d = lat2d
    u_diff@lon2d = lon2d
    v_diff@lat2d = lat2d
    v_diff@lon2d = lon2d

    ; Rename winds to plot them as vectors
    var1_vec = var1         
    var11_vec = var11
    var2_vec = var2
    var22_vec = var22

    var1_vec@lat2d = lat2d
    var1_vec@lon2d = lon2d
    var11_vec@lat2d = lat2d
    var11_vec@lon2d = lon2d
    var2_vec@lat2d = lat2d
    var2_vec@lon2d = lon2d
    var22_vec@lat2d = lat2d
    var22_vec@lon2d = lon2d

    ; find wind speed
    var1 = sqrt(var1^2+var11^2)
    var2 = sqrt(var2^2+var22^2)
    var1@long_name = "Net Wind Speed"
    var1@standard_name = "Wind Speed"
    copy_VarMeta(var1,var2)
  end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" "+title1+" min: "+min(var1)+"  max: "+max(var1)) 
  print(vartitle1+" "+title2+" min: "+min(var2)+"  max: "+max(var2))

; assign 2d lat and lon attributes for plotting:
  var1@lat2d  = lat2d
  var1@lon2d  = lon2d
  var2@lat2d  = lat2d
  var2@lon2d  = lon2d

; create difference file
diff = var2 - var1
  diff@lat2d  = lat2d
  diff@lon2d  = lon2d
  copy_VarMeta(var2,diff)
  
  print(vartitle1+" diff min: "+min(diff)+"      max: "+max(diff))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
  print("Processing four panel graphs for "+varcode+" "+date1)

  ;wks = gsn_open_wks("x11",fout)
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(4, graphic)

;;;;;;;;;;;;;
; Set resources used for all plots
;;;;;;;;;;;;

  res                             = True              ; plot mods desired
  ;res@gsnRightString              = ""
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
  res@mpMaxLatF                   = 68.              ; set the maximum latitude 
  res@mpMinLonF                   = -55.0            ; set the minimum longitude 
  res@mpMaxLonF                   = -18.0            ; set the maximum longitude 
  ;res@mpMinLatF                   = 56.              ; set the minimum latitude (tip jet only)
  ;res@mpMaxLatF                   = 67.              ; set the maximum latitude (tj only)
  ;res@mpMinLonF                   = -57.0            ; set the minimum longitude (tj only)
  ;res@mpMaxLonF                   = -30.0            ; set the maximum longitude (tj only)
 end if

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5              ; Make continents thinner
  

; set vector resources if it's a wind plot
   if (isvar("find_speed").and.(find_speed)) then
   vcres                            = True
   vcres@gsnRightString             = ""
   vcres@gsnLeftString              = ""
   vcres@gsnFrame                   = False             ; Do not draw plot 
   vcres@gsnDraw                    = False             ; Do not advance fr
   vcres@gsnAddCyclic               = False             ; regional - not cyclic 
   vcres@vcGlyphStyle               = "LineArrow"
   vcres@vcRefMagnitudeF            = 25.               ; set vector reference magnitude
   vcres@vcRefLengthF               = 0.03              ; length of vector (larger = longer)
   vcres@vcMinDistanceF             = 0.04              ; vector spacing (smaller = more dense)
   vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder)
   ;vcres@vcFillArrowsOn             = False             ; get rid of the filled vectors
  
; vector legend placement
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "25 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string

  end if

;;;;;;;;;;;;;
; Plot 1 - overlay contours
;;;;;;;;;;;;;

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@cnLineColor                = "red"
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level. designated above for each variable of interest
  opts@cnMaxLevelValF             = cmax1             ; set max contour level. designated above
  opts@cnLevelSpacingF            = clevd           ; set contour spacing. designated above
  opts@tiMainString               = title0            ; set title for plot. designated above as both input names
  opts@tiMainFontHeightF          = 0.013
  opts@cnInfoLabelOn              = False
  opts@cnLineLabelFontColor       = opts@cnLineColor  ; set the contour labels to be the same as the contour line color
  opts@cnLineLabelBackgroundColor = "Transparent"     ; set the background behind contour labels to be transparent

; Plot 1 (overlay)
  opts2                            = opts             ; set options for the second contour set to be the same
  opts2@cnLineColor                = "blue"           ; specify second contour to be diff. color
  opts2@cnLineLabelFontColor       = opts2@cnLineColor
  opts2@gsnRightString             = ""

; reset and deletion options to prevent overwrites and warnings for overlay:
  delete(opts2@tiMainString)
  delete(opts2@mpProjection)
  delete(opts2@mpLimitMode)
  delete(opts2@mpCenterLonF)
  delete(opts2@mpCenterLatF)
  delete(opts2@mpGridAndLimbOn)
  delete(opts2@mpFillOn)
  delete(opts2@mpGridLineDashPattern)
  delete(opts2@mpGeophysicalLineColor)
  delete(opts2@mpGeophysicalLineThicknessF)
if (isvar("whole_dom").and.(whole_dom))then
  delete(opts2@mpLeftCornerLonF)
  delete(opts2@mpLeftCornerLatF)
  delete(opts2@mpRightCornerLatF)
  delete(opts2@mpRightCornerLonF)
end if
if (isvar("zoom").and.(zoom))then
  delete(opts2@mpMaxLonF)
  delete(opts2@mpMinLonF)
  delete(opts2@mpMaxLatF)
  delete(opts2@mpMinLatF)
end if

  cplot1 = gsn_csm_contour_map(wks,var1,opts)  ; create plot of first contours
  cplot1b = gsn_csm_contour(wks,var2,opts2)    ; create plot of second contours
  overlay(cplot1,cplot1b)                       ; overlay contour 2 on contour 1. overlay plot wil have title cplot1
  plot(0) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(opts2)

; legend resources- for plot 1 overlay
  lgres                    = True
  lgres@lgLineColors       = (/"red","blue"/)   ; make the colors for the legend
  lgres@lgMonoDashIndex    = True               ; sets both contour lines to same dash type
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  lgres@vpWidthF           = 0.30               ; width of legend (NDC)
  lgres@vpHeightF          = 0.05               ; height of legend (NDC)
  lgres@lgLineDashSegLenF  = 0.01
  lgres@lgLabelFontHeightF = 0.03
  lgres@lgLineLabelStrings = (/"", ""/)         ; take of any automatic line labels
  lbid = gsn_create_legend(wks,2,(/title1, title2/),lgres)         ; create legend

; annotate first plot by adding legend
  amres                    = True
  amres@amParallelPosF     = 0.25	        ; move legend to the right
  amres@amOrthogonalPosF   = 0.60               ; move the legend down
  annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

;;;;;;;;;;;;;
; Plot 2 - fname1
;;;;;;;;;;;;;

  opts                            = res               ; reset options
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnLinesOn                  = plotlines         ; contour lines specified above
  opts@cnLineLabelsOn             = plotlines         ; line labels on specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = title1            ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  
  ;plot(1) = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  
  cplot2 = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot2b = gsn_csm_vector(wks, var1_vec, var11_vec, vcres)
    overlay(cplot2,cplot2b)
  end if
  plot(1) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 4 - fname2
;;;;;;;;;;;;;

; keep options the same as the for second plot because same field plotted
; make plot 4 next because options are the same
  opts@tiMainString               = title2            ; rename title for plot

  cplot4 = gsn_csm_contour_map(wks, var2, opts)      ; create fourth plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot4b = gsn_csm_vector(wks, var2_vec, var22_vec, vcres)
    overlay(cplot4,cplot4b)
  end if
  plot(3) = cplot4                              ; make panel section of this plot
  delete(opts)


;;;;;;;;;;;;;
; Plot 3 - difference 
;;;;;;;;;;;;; 

  opts                            = res
  opts@cnFillMode                 = cntype
  opts@cnFillOn                   = True
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart2      ; start at color specified above
  opts@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts@cnLinesOn                  = difflines         ; contour lines specified above
  opts@cnLineLabelsOn             = difflines
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  opts@tiMainString               = title3            ; set title for difference plot (title2-title1)
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride2
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075

; changing some vector resources for difference plot

   if (isvar("find_speed").and.(find_speed)) then
   vcres@vcRefMagnitudeF            = 5.               ; set vector reference magnitude
   vcres@vcRefAnnoString2           = "5 m/s"          ; label vector legend bottom string
   vcres@vcLineArrowHeadMaxSizeF    = 0.01
   end if

  cplot3 = gsn_csm_contour_map(wks, diff, opts)      ; create third plot
  if (isvar("find_speed").and.(find_speed)) then
    cplot3b = gsn_csm_vector(wks, u_diff, v_diff, vcres)
    overlay(cplot3,cplot3b)
  end if
  plot(2) = cplot3                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
   title5 = date1+" "+vartitle1+": "+title1+" and "+title2  

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot
  
;  convert_cmd = "convert -density 300 "+fout+".ps -resize 30% -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(var1)
  delete(var2)
  delete(convert_cmd)
  delete(lgres)
  delete(res)
  delete(pnlres)
  delete(diff)
  delete(opts)
 if (isvar("find_speed").and.(find_speed)) then
  delete(vcres)
 end if


;;;;;;;;;;;;;;;;;;;;;; END script
end

