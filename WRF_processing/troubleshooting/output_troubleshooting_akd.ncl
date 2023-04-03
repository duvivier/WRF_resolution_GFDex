;***************************************
; Alice DuVivier - Nov. 2010: modified fourpanel to test wrfoutput for inconsistancies
;
; Designed to be used for wrfoutput, not necessarily met input
; outputs single figures for each varcode
; designed to be deleted after checking for any problems
;
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
;for testing purposes
;dir1 = "/data3/duvivier/ARSC/data/wrf_cont/wrfout.d01/post_processed/"
;fname1 = "wrf-2007-02-21-12"
;title1 = "WRF_Continuous"
;date1 = "2007-02-21-12"
;varcode = "SST"

; Check for input information:
  if(.not.any(isvar("dir1") \
              .and.isvar("fname1").and.isvar("title1") \
              .and.isvar("date1") .and.isvar("varcode") \
              )) then
    print("Can't find all input information!")
;    exit
  end if

; determine if var1 is met or wrf data:
  fname1_ch  = stringtochar(fname1)            ; read first input name
  fname1_tag = chartostring(fname1_ch(0:2))    ; get first three letters to check type of input
  title1 = str_sub_str(title1,"_"," ")         ; update titles to remove underscores:

  print("Processing output test figure for "+varcode+" "+date1)

; get process month from incoming date
  date1_ch = stringtochar(date1)
  month1 = stringtointeger(chartostring(date1_ch(4:5)))
  month2 = month1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Choosing Variables and plot options:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
  precip_add = False ; normal by default averaging
; Which variables need to be loaded?
  if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"
    vartype = "2d"
    cmaptype = "pressure"
    mask_500 = True
  end if
  if (varcode.eq."Z850") then
    vartitle1 = "Z at 850 mb"
    invar1 = "Z_p"
    preslev = 850
    vartype = "3d"
    cmaptype = "geopotential_low"
  end if
  if (varcode.eq."Z500") then
    vartitle1 = "Z at 500 mb"
    invar1 = "Z_p"
    preslev = 500
    vartype = "3d"
    cmaptype = "geopotential_mid"
  end if
  if (varcode.eq."Z300") then
    vartitle1 = "Z at 300 mb"
    invar1 = "Z_p"
    preslev = 300
    vartype = "3d"
    cmaptype = "geopotential_high"
  end if
 if (varcode.eq."Windsurf") then
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_gr"
    invar11 ="v_10m_gr"
    vartype = "2d"
    cmaptype = "wind"
    find_speed = True
    met_not_avail = True  ; wind data not in met
  end if
  if (varcode.eq."Wind850") then
    vartitle1 = "Wind Speed at 850mb"
    invar1 = "u_gr_p"
    invar11 ="v_gr_p"
    preslev = 850
    vartype = "3d"
    cmaptype = "wind"
    find_speed = True
    met_not_avail = True  ; wind data not in met
  end if
  if (varcode.eq."Wind500") then
    vartitle1 = "Wind Speed at 500mb"
    invar1 = "u_gr_p"
    invar11 ="v_gr_p"
    preslev = 500
    vartype = "3d"
    cmaptype = "wind"
    find_speed = True
    met_not_avail = True  ; wind data not in met
  end if
  if (varcode.eq."Wind300") then
    vartitle1 = "Wind Speed at 300mb"
    invar1 = "u_gr_p"
    invar11 ="v_gr_p"
    preslev = 300
    vartype = "3d"
    cmaptype = "wind"
    find_speed = True
    met_not_avail = True  ; wind data not in met
  end if
  if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2 m"
    invar1 = "T_2m"
    vartype = "2d"
    cmaptype = "temperature"
  end if  
  if (varcode.eq."SST") then
    vartitle1 = "SST"
    if (fname1_tag.eq."met") then
      invar1 = "T_sfc"     ; confusing plot otherwise, as metgrid SST 
      mask_land = True     ; is surf temp and inclues land and sea ice values
    else
       invar1 = "SST"
    end if
    vartype = "2d"
    convert_to_C = True
    mask_land = True
    cmaptype = "temperature"
  end if
  if (varcode.eq."ice") then
    vartitle1 = "Sea Ice Fraction"
    invar1 = "SeaIce"
    vartype = "2d"
    cmaptype = "ice"
  end if
  if (varcode.eq."alb") then
    vartitle1 = "Albedo"
    invar1 = "albedo"
    vartype = "2d"
    cmaptype = "alb"
    met_not_avail = True  ; albedo data not in met
  end if
  if (varcode.eq."swf") then
    vartitle1 = "Surface Downwelling Shortwave Flux"
    invar1 = "SW_d"
    vartype = "2d"
    cmaptype = "rad"
    met_not_avail = True  ; shortwave data not in met
  end if
  if (varcode.eq."lwf") then
    vartitle1 = "Surface Downwelling Longwave Flux"
    invar1 = "LW_d"
    vartype = "2d"
    cmaptype = "rad"
    met_not_avail = True  ; longwave data not in met
  end if

; loop to check if there is met data to compare with
  if (isvar("met_not_avail").and.(met_not_avail).and.(fname1_tag.eq."met")) then
    print("Metgrid data not available!")
   end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."pressure") then
    cmin1 = 950
    cmax1 = 1050.
    clev1 = 5.
    stride1             = 4                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."wind") then
    cmin1 = 0
    cmax1 = 20.
    clev1 = 2.
    stride1             = 2                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1 = -61.
    cmax1 = 20.
    clev1 = 3.
    stride1             = 6                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 108 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."geopotential_low") then
    cmin1 = 1000.
    cmax1 = 1540.
    clev1 = 20.
    stride1             = 8                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
  if (cmaptype.eq."geopotential_mid") then
    cmin1 = 5000.
    cmax1 = 5500.
    clev1 = 20.
    stride1             = 8                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
  if (cmaptype.eq."geopotential_high") then
    cmin1 = 8300.
    cmax1 = 9000.
    clev1 = 25.
    stride1             = 8                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if
  if (cmaptype.eq."ice") then
    cmin1 =  0.
    cmax1 =  1.
    clev1 =  0.05
    stride1             = 2                 ; label stride
    plotlines           = False             ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 22                ; end at color
    spreadstart2        = 24                ; start at color
    spreadend2          = 65                ; end at color
    colormap            = "seaice"
  end if
  if (cmaptype.eq."alb") then
    cmin1 =  0.
    cmax1 =  1.
    clev1 =  .05
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 101               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 101               ; end at color
    colormap            = "BlAqGrYeOrRe"
  end if
  if (cmaptype.eq."rad") then
    cmin1 =  0.
    cmax1 =  400.
    clev1 =  25.
    stride1             = 2                 ; label stride
    plotlines           = True              ; lines for reg plot
    spreadstart1        = 2                 ; start at color
    spreadend1          = 102               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
  end if

  outdir  = "./"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Loading and manipulation:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; load in the two files. the directories and filenames were specified in the c-shell wrapper
  f1 = addfile(dir1 + fname1 + ".nc","r")

if (isvar("find_speed").and.(find_speed))then
  f11 = addfile(dir1 + fname1 + ".nc","r")
end if

; get the latitude and longitude data and dimensions, later used to plot the entire domain
  lat2d  = f1->lat
  lon2d  = f1->lon
  dimll = dimsizes(lat2d)
  nlat = dimll(0)
  nlon = dimll(1)

; 2d vars:
; If statements check to see if variable is 2d and 'isfilevar' is an ncl function that checks if the input variable (invar1) resides in the input files. If it does, the input variable is loaded.
  if (vartype.eq."2d") then
    if (isfilevar(f1,invar1)) then
      var1_3d = f1->$invar1$
      var1 = var1_3d(0,:,:)
      if (isvar("find_speed").and.(find_speed))then
      var11_3d = f11->$invar11$
      var11 = var11_3d(0,:,:)
      end if
    end if
  end if

; 3d vars:
; If statements check to to see if variable is 3d  and 'isfilevar' is an ncl function that checks if the input variable (invar1) resides in the input file. If it does, the input variable is loaded.
  if (vartype.eq."3d")
    var1_4d = f1->$invar1$(time|:,{pressure|preslev},south_north|:,west_east|:)
    var1 = var1_4d(0,:,:) ; already selected correct pressure level
    if (isvar("find_speed").and.(find_speed)) then
    var11_4d = f11->$invar11$(time|:,{pressure|preslev},south_north|:,west_east|:)
    var11 = var11_4d(0,:,:)
    end if
    delete(preslev) ; delete the pressure level designated so the script can loop through other variables
  end if

; for temperature inputs this loop converts the variable to Celsius from Kelvin. The string "convert_to_C" was set to be true in earlier variable loops for temperature
  if (isvar("convert_to_C").and.(convert_to_C)) then
    var1 = var1 - 273.15
    var1@units = "C"
   end if

; for wind plots, must have u and v data
; must rotate vectors and find speed  
  if (isvar("find_speed").and.(find_speed)) then
    
    ; rotate winds

    var1@_FillValue = -999999  ; u component of wind
    var1@lat2d = lat2d
    var1@lon2d = lon2d

    var11@_FillValue = -999999  ; v component of wind
    var11@lat2d = lat2d
    var11@lon2d = lon2d
  
    flat=lat2d
    flon=lon2d
    cen_long=-36.         ; THIS SHOULD BE THE CENTER LONGITUDE OF THE MODEL RUN, NOT THE PROJECTION
    cone=1
    rpd=3.14159265/180.

    longca=flon-cen_long
    longca=where(longca .gt. 180.,longca-360.,longca)
    longca=where(longca .lt. -180.,longca+360.,longca)

    longcb=longca
    longcb=where(flat .lt. 0., -longca*cone*rpd,longcb)
    longcb=where(flat .ge. 0.,longca*cone*rpd,longcb)

    longca = cos(longcb)
    longcb = sin(longcb)

    ; output each rotated winds
    var1_rot = var11(:,:)*longcb + var1(:,:)*longca
    var11_rot = var11(:,:)*longca - var1(:,:)*longcb

    var1_rot@lat2d = lat2d
    var1_rot@lon2d = lon2d
    var11_rot@lat2d = lat2d
    var11_rot@lon2d = lon2d

     ; find wind speed
     var1 = sqrt(var1^2+var11^2)
     var1@long_name = "Net Wind Speed"
  end if

; loop to check if the data needs a mask above 500m terrain height.
  if (isvar("mask_500").and.(mask_500)) then
    print("Masking land for SLP plot above 500m.")
    terr = f1->Z_sfc(:,:)
    var1_masked = mask(var1,terr.gt.500,0)
    copy_VarMeta(var1,var1_masked)
    delete(var1)
    var1 = var1_masked
  end if

; loop to check if the data is SST and if so to mask the land areas.
    ; Note: the "landmask" in WRF-world includes sea ice.  Therefore, we
    ; are masking NCEP data with a changing WRF landmask (because sea ice
    ; changes every time step). This is not an ideal solution, but should
    ; be good enough.
  if (isvar("mask_land").and.(mask_land)) then
    print("Masking land for SST plot.")
    landmask = f1->LandMask(0,:,:)
    var1_masked = mask(var1,landmask,0)
    copy_VarMeta(var1,var1_masked)
    delete(var1)
    var1 = var1_masked
  end if


; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print("All Data")
  print(vartitle1+" "+title1+" min: "+min(var1)+"  max: "+max(var1)) 

; add on 2d lat and lon attributes for plotting:
  var1@lat2d  = lat2d
  var1@lon2d  = lon2d

;return

;;;;;;;;;;;;;
; Plotting:
;;;;;;;;;;;;;

  ;wks = gsn_open_wks("x11",outdir + varcode+"_"+date1)
  wks = gsn_open_wks("ps" ,outdir + varcode+"_"+date1)
  additional_colors = (/"gray85", "forestgreen", "yellow"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

  plot = new(1, graphic)

; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---changed for Greenland
  res@mpCenterLatF                = 60.               ; -----changed for Greenland
  res@mpLeftCornerLatF            = lat2d(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d(0,0)
  res@mpRightCornerLatF           = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d(nlat-1,nlon-1)

  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "forestgreen"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

; set vector resources if it's a wind plot
   if (isvar("find_speed").and.(find_speed)) then
  vcres                            = True
  vcres@gsnFrame                   = False             ; Do not draw plot 
  vcres@gsnDraw                    = False             ; Do not advance fr
  vcres@gsnAddCyclic               = False             ; regional - not cyclic 
  vcres@vcGlyphStyle               = "CurlyVector"
  vcres@vcRefMagnitudeF            = 20.               ; set vector reference magnitude
  vcres@vcRefLengthF               = 0.03              ; length of vector (larger = longer)
  vcres@vcMinDistanceF             = 0.03              ; vector spacing (smaller = more dense)
  vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrows (larger = bolder)
  vcres@vcFillArrowsOn             = False             ; get rid of the filled vectors
  
; vector legend placement
  vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
  vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
  vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
  vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
  vcres@vcRefAnnoString2           = "20 m/s"          ; label vector legend bottom string
  vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string
  end if

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;

  opts                            = res               ; reset options
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
 ; opts@tiMainString               = title1            ; title string specified from cshell
  opts@tiMainFontHeightF          = 0.013
  opts@lbLabelStride              = stride1
  opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
  
  ;plot(1) = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  
  cplot = gsn_csm_contour_map(wks, var1, opts)      ; create second plot
  if (isvar("find_speed").and.(find_speed)) then
    cplotb = gsn_csm_vector(wks, var1_rot, var11_rot,vcres)
    overlay(cplot,cplotb)
  end if
  plot(0) = cplot                              ; make panel section of this plot

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
 title0 = date1+" Troubleshooting for "+title1   
 
  pnlres                            = True
  pnlres@txString                   = title0           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot
  

;  convert_cmd = "convert -density 300 "+outdir+varcode+"_"+date1+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+outdir+varcode+"_"+date1+".png"

;  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(var1)
;  delete(convert_cmd)
  delete(res)
  delete(pnlres)
  delete(opts)
if (isvar("find_speed").and.(find_speed)) then
  delete(vcres)
end if


;;;;;;;;;;;;;;;;;;;;;; END script
end
