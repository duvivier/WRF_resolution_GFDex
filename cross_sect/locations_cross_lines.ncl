;***************************************
; PROGRAM DESCRIPTION: This makes spatial plots of where cross section
;                      transects will be located
; INPUT DATA: WRF output of any resolution
; OUTPUT DATA: spatial plot of cross section locations
; CREATORS: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***************************************

begin
;MANUAL INPUTS
dir1 = "/data3/duvivier/CASE_STUDY/cross_sect/"
outdir = "./"
fname1 = "wrf-2007-02-21-15_10km"
title1 = "WRF_Continuous"
date1 = "2007-02-21-15"
varcode = "Wind"

; BEGIN SCRIPT
; Check for input information:
  if(.not.any(isvar("dir1").and.isvar("fname1") \
              .and.isvar("title1").and.isvar("date1") \
              .and.isvar("varcode") \
              )) then
    print("Can't find all input information!")
;    exit
  end if

; set outdir and fout names
outdir = "./"
fout   = outdir+"line_tests"
; set if this is a zoomed plot or the whole domain
zoom = False
whole_dom = True

; determine if var1 is met or wrf data:
  fname1_ch  = stringtochar(fname1)            ; read first input name
  fname1_tag = chartostring(fname1_ch(0:2))    ; get first three letters to check type of input
; update titles to remove underscores:
  title1 = str_sub_str(title1,"_"," ")

  print("Processing cross section plots for "+varcode+" "+date1)

;;;;;;;;;;
; Use varcode to set variable information
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
  if (varcode.eq."Wind") then
    vartitle1 = "Wind Speed"
    invar0 = "u_10m_tr"
    invar00 = "v_10m_tr"
    invar1 = "u_tr_e"
    invar11 ="v_tr_e"
    vartype = "3d"
    cmaptype = "wind"
    unit = "m/s"
    find_speed = True
  end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."wind") then
    cmin0 = 0
    cmax0 = 35
    clev0 = 5.
    cmin1 = -55
    cmax1 = 55.
    clev1 = 5
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart0        = 2                 ; start at color- spatial
    spreadend0          = 21                ; end at color
    spreadstart1        = 23                ; start at color- cross section
    spreadend1          = 45                ; end at color
    colormap            = "winds.alice"
  end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be on eta levels
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Loading wrf data")

; load in the two files. the directories and filenames were specified in the c-shell wrapper
  f1 = addfile(dir1 + fname1 + ".nc","r")

; get the latitude and longitude data and dimensions, later used to plot the entire domain
  lat2d  = f1->lat
  lon2d  = f1->lon
  eta    = f1->eta
  n_eta = dimsizes(eta)
  dimll = dimsizes(lat2d)
  nlat = dimll(0)
  nlon = dimll(1)

; get the 2d variable (for spatial  plot)
  var0 = f1->$invar0$(time|0,south_north|:,west_east|:)
  var0@lat2d = lat2d
  var0@lon2d = lon2d

; if looking at wind
  if(isvar("find_speed").and.(find_speed))then
    var00 = f1->$invar00$(time|0,south_north|:,west_east|:)
    u = var0     ; get u and v vectors for vectors on spatial map
    v = var00
    u@lat2d  = lat2d
    u@lon2d  = lon2d
    v@lat2d  = lat2d
    v@lon2d  = lon2d

    var0 = sqrt(var0^2+var00^2)
    var0 @long_name = "Wind Speed at 10m"
    var0@lat2d  = lat2d
    var0@lon2d  = lon2d
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Horizontally Interpolate to cross section line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set start and end lons and lats
; GFDX Cross section - Northern leg
    st_latA = 62.0
    st_lonA = -42.0
    ed_latA = 62.0
    ed_lonA = -40.0

; GFDX Cross section - Southern leg
    st_latB = 60.1
    st_lonB = -43.1
    ed_latB = 59.25
    ed_lonB = -40.0

; Off tip- get smeared out part
    st_latC = 60.5
    st_lonC = -48.0
    ed_latC = 58.5
    ed_lonC = -41.0

; Off tip- dying jet
    st_latD = 60.0
    st_lonD = -50.0
    ed_latD = 56.0
    ed_lonD = -45.0

; Barrier winds
    st_latE = 60.0
    st_lonE = -42.75
    ed_latE = 63.25
    ed_lonE = -41.0

; Along jet- off tip
    st_latF = 57.0
    st_lonF = -51.0
    ed_latF = 60.0
    ed_lonF = -42.75

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Plotting cross section of "+vartitle1)

 ;wks = gsn_open_wks("x11",fout)
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","forestgreen"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

 plot = new(1, graphic)    ; one cross section plot and one spatial plot
    title0              = var0@long_name+": Spatial"

;;;;;;;;;;;;;
; Spatial Plot Resources
;;;;;;;;;;;;;
 res                             = True              
;  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set for Greenland
  res@mpCenterLatF                = 60.               ; -----set for Greenland

 if (isvar("whole_dom").and.(whole_dom))then
  res@mpLimitMode                 = "Corners"	      ; how to zoom in on map
  res@mpLeftCornerLatF            = lat2d(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d(0,0)
  res@mpRightCornerLatF           = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d(nlat-1,nlon-1)
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
  res@mpGeophysicalLineColor      = "forestgreen"     ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart0      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend0        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin0             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax0            ; set max contour level specified above
  res@cnLevelSpacingF            = clev0             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in
  res@tiMainString               = title0            ; title string specified from cshell
  res@tiMainFontHeightF          = 0.013
  res@lbLabelStride              = stride1
  res@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  res@pmLabelBarHeightF          = 0.075             ; set height of labelbar

; set line res to show cross section line
  lnres                            = True
   lnres@gsLineThicknessF          = 2.5
   lnres@gsLineColor               = "black"

; set vector resources for spatial plot if it's a wind plot
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
   vcres@vcLineArrowThicknessF      = 1.0               ; thickness of vector arrow (larger = bolder)
   vcres@vcFillArrowsOn             = False             ; get rid of the filled vectors
  
; vector legend placement
   vcres@vcRefAnnoOrthogonalPosF    = -0.02              ; vector vertical legend placement
   vcres@vcRefAnnoParallelPosF      = 0.95               ; vector horizontal legend placement
   vcres@vcRefAnnoString1           = "Wind Speed"      ; label vector legend top string
   vcres@vcRefAnnoString1On         = True              ; turn on top vector label string
   vcres@vcRefAnnoString2           = "25 m/s"          ; label vector legend bottom string
   vcres@vcRefAnnoString2On         = True              ; turn on bottom vector label string
   end if


;;;;;;;;;;;;;
; Plot 1 - spatial plot
;;;;;;;;;;;;;
  cplot0 = gsn_csm_contour_map(wks, var0, res)
      
  if (isvar("find_speed").and.(find_speed)) then        ; overlay vectors
    cplot0b = gsn_csm_vector(wks, u, v, vcres)
    overlay(cplot0,cplot0b)
  end if

;; add in line showing where cross section is located 
  dumA = new(1, graphic)      ; make dummy variable
  dumA = gsn_add_polyline(wks,cplot0,(/st_lonA,ed_lonA/), (/st_latA, ed_latA/), lnres)

  dumB = new(1,graphic)
  dumB = gsn_add_polyline(wks,cplot0,(/st_lonB,ed_lonB/), (/st_latB, ed_latB/), lnres)

  dumC = new(1,graphic)
  dumC = gsn_add_polyline(wks,cplot0,(/st_lonC,ed_lonC/), (/st_latC, ed_latC/), lnres)

  dumD = new(1,graphic)
  dumD = gsn_add_polyline(wks,cplot0,(/st_lonD,ed_lonD/), (/st_latD, ed_latD/), lnres)

  dumE = new(1,graphic)
  dumE = gsn_add_polyline(wks,cplot0,(/st_lonE,ed_lonE/), (/st_latE, ed_latE/), lnres)

  dumF = new(1,graphic)
  dumF = gsn_add_polyline(wks,cplot0,(/st_lonF,ed_lonF/), (/st_latF, ed_latF/), lnres)

 plot(0) = cplot0


;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;


  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(res)
  delete(pnlres)

 if (isvar("find_speed").and.(find_speed)) then
  delete(vcres)
 end if


;;;;;;;;;;;;;;;;;;;;;; END script
end

