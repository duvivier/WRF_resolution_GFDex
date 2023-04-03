;***************************************
; PROGRAM DESCRIPTION: This NCL script makes cross section plots of WRF data
; INPUT DATA: WRF output of any resolution
; OUTPUT DATA: spatial plot of cross section location and cross section
; Note: loop this script with 02_21FEB_15Z.csh
; CREATORS: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
;MANUAL INPUTS - for testing purposes
dir1 = "/data3/duvivier/NCAR/21FEB/wrf_10km/"
fname1 = "wrf-2007-02-21-15"
title1 = "WRF_10"
date1 = "2007-02-21-15"
varcode = "TotWind"
cross_type = "2"         

; set if this is a zoomed plot or the whole domain
   zoom = True
   whole_dom = False
; set if want eta level spacing plotted along side of cross section
   plot_eta = True

; BEGIN SCRIPT
; Check for input information:
  if(.not.any(isvar("dir1").and.isvar("fname1") \
              .and.isvar("title1").and.isvar("date1") \
              .and.isvar("varcode") \
              )) then
    print("Can't find all input information!")
  end if

; set outdir and fout names
   outdir = "./"
   fout   = outdir+varcode+"_"+title1+"_cross_section"+cross_type+"_"+date1

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
     cressrad = 101.            
   end if
   
; update titles to remove underscores:
   title1 = str_sub_str(title1,"_"," ")

  print("Processing cross section plots for "+varcode+" "+date1)

;;;;;;;;;;
; Use varcode to set variable information
;;;;;;;;;;
; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
  if (varcode.eq."PotTemp") then
    vartitle1 = "Potential Temperature"
    invar0 = "Th_2m"
    invar1 = "Th_e"
    vartype = "3d"
    cmaptype = "pottemp"
    unit = "K"
  end if
  if (varcode.eq."Q") then
    vartitle1 = "Mixing Ratio"
    invar0 = "q_2m"
    invar1 = "q_e"
    vartype = "3d"
    cmaptype = "mixrad"
    unit = "kg kg-1"
  end if
  if (varcode.eq."TotWind") then
    vartitle1 = "Wind Speed"
    invar0 = "u_10m_tr"
    invar00 = "v_10m_tr"
    invar1 = "u_tr_e"
    invar11 ="v_tr_e"
    vartype = "3d"
    cmaptype = "totwind"
    unit = "m/s"
    find_speed = True
  end if
  if (varcode.eq."ParlWind") then
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
  if (varcode.eq."PerpWind") then
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
  if (cmaptype.eq."pottemp") then
    cmin0 = 270.
    cmax0 = 300.
    clev0 = 1.
    cmin1 = 270.
    cmax1 =300.
    clev1 = 1
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill" 
    spreadstart0        = 22                 ; start at color- spatial
    spreadend0          = 65                ; end at color
    spreadstart1        = 22                ; start at color- cross section
    spreadend1          = 65                ; end at color 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mixrad") then
    cmin0 = 0.
    cmax0 = 0.005
    clev0 = 0.001
    cmin1 = 0.
    cmax1 =0.005
    clev1 = 0.001
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill" 
    spreadstart0        = 2                 ; start at color- spatial
    spreadend0          = 103                ; end at color
    spreadstart1        = 2                ; start at color- cross section
    spreadend1          = 103                ; end at color 
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."totwind") then
    cmin0 = 0
    cmax0 = 48.
    clev0 = 2.
    cmin1 = 0
    cmax1 = 48.
    clev1 = 2.
    stride1             = 2                  ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "RasterFill"
    spreadstart0        = 2                  ; start at color- spatial
    spreadend0          = 21                 ; end at color
    spreadstart1        = 2                  ; start at color- cross section
    spreadend1          = 21                 ; end at color
    colormap            = "winds.alice"
  end if
  if (cmaptype.eq."wind") then
    cmin0 = 0
    cmax0 = 48
    clev0 = 2.
    cmin1 = -48
    cmax1 = 48.
    clev1 = 4
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

; get the 3d variable (on eta levels!)
  var1 = f1->$invar1$(time|0,eta|:,south_north|:,west_east|:)

  if (isvar("find_speed").and.(find_speed)) then
    var11 = f1->$invar11$(time|0,eta|:,south_north|:,west_east|:)
  end if

; get terrain data
  Z_sfc = f1->Z_sfc(south_north|:,west_east|:)

; get geopotential height data
  Z_e = f1->Z_e(time|0,eta|:,south_north|:,west_east|:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Horizontally Interpolate to cross section line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set start and end lons and lats
; npts is cross section specific to give 2km horiz resolution
; GFDX Cross section - Northern leg
  if (cross_type .eq. "1") then
    st_lat = 62.0
    st_lon = -42.0
    ed_lat = 62.0
    ed_lon = -40.0
    npts   = 54
  end if
; GFDX Cross section - Southern leg
  if (cross_type .eq. "2") then
    st_lat = 60.1
    st_lon = -43.1
    ed_lat = 59.25
    ed_lon = -40.0
    npts   = 101
  end if
; Off tip- get smeared out part
  if (cross_type .eq. "3") then
    st_lat = 60.5
    st_lon = -48.0
    ed_lat = 58.5
    ed_lon = -41.0
    npts   = 229
  end if
; Off tip- dying jet
  if (cross_type .eq. "4") then
    st_lat = 60.0
    st_lon = -50.0
    ed_lat = 56.0
    ed_lon = -45.0
    npts   = 269
  end if
; Along Barrier winds
  if (cross_type .eq. "5") then
    st_lat = 60.0
    st_lon = -42.75
    ed_lat = 63.25
    ed_lon = -41.0
    npts   = 189
  end if
; Along jet- off tip
  if (cross_type .eq. "6") then
    st_lat = 57.0
    st_lon = -51.0
    ed_lat = 60.0
    ed_lon = -42.75
    npts   = 294
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

print("Interpolating to cross section line")
  max_indicies = 5
  interp_ind = new((/n_cross,max_indicies/),"integer")
  interp_wgt = new((/n_cross,max_indicies/),"float")

  lat1d = ndtooned(lat2d)
  lon1d = ndtooned(lon2d)

  Z_sfc_1d = ndtooned(Z_sfc)
  Z_sfc_sub  = new((/n_cross/),"float")

  ; preallocate arrays for subset of variables
  var1_sub   = new((/n_eta,n_cross/),"float")
  Z_e_sub    = new((/n_eta,n_cross/),"float") 
 
  if (isvar("find_speed").and.(find_speed)) then
    var11_sub = new((/n_eta,n_cross/),"float")
  end if

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

    ; calculate the new variable and geopotential heights
    do j = 0, n_eta-1
   
      ; flatten the eta level of interest 
      var1_1d = ndtooned(var1(j,:,:))    
      Z_e_1d  = ndtooned(Z_e(j,:,:))
      
      ; calculate new array for variable and geopZ
      var1_sub(j,i) =  sum(var1_1d(indicies)*weight)/sum(weight)
      Z_e_sub(j,i)  =  sum(Z_e_1d(indicies)*weight)/sum(weight)

      if (isvar("find_speed").and.(find_speed)) then
        var11_1d = ndtooned(var11(j,:,:))
        var11_sub(j,i) = sum(var11_1d(indicies)*weight)/sum(weight)
        delete(var11_1d)
      end if

      delete(var1_1d)
      delete(Z_e_1d)

    end do

    delete(indicies)
    delete(weight)

    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(var1, var1_sub)
  copy_VarAtts(Z_e, Z_e_sub)
  copy_VarAtts(Z_sfc, Z_sfc_sub)

;;;;;;;;;;
; Convert/manipulate variables
;;;;;;;;;;
  if (isvar("convert_to_C").and.(convert_to_C)) then
    var1_sub = var1_sub - 273.15
    var1_sub@units = "C"
  end if

if (isvar("find_speed").and.(find_speed)) then
  pi = 3.14159265
  r2d = 45.0/atan(1.0)

   ; get wind direction
    wd = atan2(var1_sub,var11_sub)*r2d+180        
    wd@long_name = "Wind Direction"
    wd@units = "degrees"
    wd!0 = "eta"                           ; name dimensions
    wd!1 = "distance"
   
   ; get net wind speed 
    ws = sqrt(var1_sub^2 + var11_sub^2)
    ws@units = "m s-1"
    ws@long_name = "Wind Speed"
    ws@standard_name = "wind speed"

   ; get wind heading
    wd_head = wd                            ; preallocate wind direction array
    wd_head@long_name = "Wind Direction Heading"

    do aa = 0,n_eta-1  ; loop through eta levels
      do bb = 0,n_cross-1  ; loop through distances
        x = wd(aa,bb)-180.0   ; subtract 180 degrees from wind dir to get heading
        if (x .lt.0.0) then
          wd_head(aa,bb) = x+360.0
        else
          wd_head(aa,bb) = x
        end if
        delete(x)
      end do
    end do 

  ; get cross section heading
    ed = n_cross-1       ; position of the end of the cross section
    dist_tot = length    ; total length of cross section in km

    del_lat = ed_lat - st_lat ; find the change in latitude degrees
    lat_dist = 111.5*del_lat  ; find the change in latitude in km
                              ; assumes 1deg Lat = 111.5km at 65N
                              ; a neg. value means lat decreasing over the cross section
                              ; calc. of heading (below) correctly interpets either sign

    cr_head = acos(lat_dist/dist_tot)*(180/pi)  ; this is the cross section heading
    alpha = (cr_head - wd_head)*(pi/180)        ; angle between the headings in radians

    parl_wind = ws   ; preallocate parallel wind component
    perp_wind = ws   ; preallocate perpendicular wind component

    aa = 0
    bb = 0
    cc = 0
    do aa = 0,n_eta-1  ; loop through eta levels
      do bb = 0,n_cross-1  ; loop through distances
        parl_wind(aa,bb) = ws(aa,bb)*cos(alpha(aa,bb))    ; positive values are left to right
        perp_wind(aa,bb) = ws(aa,bb)*sin(alpha(aa,bb))    ; positive values are into the cross sect
      end do
    end do

    delete(var1_sub)
    if (varcode .eq. "TotWind")
      var1_sub = ws
    end if
    if (varcode .eq. "PerpWind")
      var1_sub = perp_wind
    end if
    if (varcode .eq. "ParlWind")
      var1_sub = parl_wind
    end if

  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Vertical Interpolation to heights
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; create vertical spacing in meters
  hgts = ispan(0,5000,10)   ; modified to compare with Renfrew paper
  n_hgts = dimsizes(hgts)

print("Interpolating to height")

  ; create data at points and heights
  data_hgt = new((/dimsizes(hgts),n_cross/),"float")
  data_hgt!0 = "Height"
  data_hgt!1 = "Horizontal"
  data_hgt&Height = hgts
  data_hgt&Horizontal = dist
  data_hgt@_FillValue = -999
  data_hgt@units = var1_sub@units
  data_hgt@long_name = var1_sub@long_name+" Interpolated"
  data_hgt@standard_name = var1_sub@standard_name

;; Loop through to to interpolate a value to each point in the data_hgt array
 do d=0, n_cross-1                   ; Loop through each point along distance
   do h=0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub(d) .lt. hgts(h)) then    ; If height to interp. to is above surface proceed
       f=0                                  ; if not, fill data_hgt with a missing value
       if (Z_e_sub(f,d) .lt. hgts(h)) then  ; If height to interp. to  is above first eta level proceed
                                            ; if not, fill data_hgt with a missing value
         
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub(f,d) .lt. hgts(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do

         A_hgt = Z_e_sub(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgts(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to

         ; if variable increases with height linearly interp.
         if (var1_sub(f,d) .gt. var1_sub(f-1,d)) then  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           data_hgt(h,d) = var1_sub(f-1,d)+((var1_sub(f,d)-var1_sub(f-1,d))*wt)

         ; if variable decreases with height linearly interp.
         else                                  
           wt = (B_hgt-C_hgt)/total_dist
           data_hgt(h,d) = var1_sub(f,d)+((var1_sub(f-1,d)-var1_sub(f,d))*wt)
         end if
       else
         data_hgt(h,d)= -999
       end if
    else
      data_hgt(h,d) = -999
    end if
  end do
    ; Counter
    if(d%10.eq.0) then
      print("created vert levels for "+d+" of "+n_cross)
    end if
 end do

;;;;;;;;;;
; Get eta level spacing
;;;;;;;;;;
 if (isvar("plot_eta").and.(plot_eta))then
  ; to be plotted along the cross section to give idea of eta level spacing
   eta_levs = new((/n_eta/),"float")
   ypos     = new((/n_eta/),"float")
   
   do n = 0,n_eta-1
     temp = avg(Z_e_sub(n,:))
     eta_levs(n) = temp
     ypos(n) = dist(n_cross-1)
     delete(temp)
   end do
 end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print("Plotting cross section of "+vartitle1)

 ;wks = gsn_open_wks("x11",fout)
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","forestgreen"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

 plot = new(2, graphic)    ; one cross section plot and one spatial plot
    title0              = var0@long_name+": Spatial"
    title3              = var1_sub@long_name+": Cross Section"

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
  res@mpMaxLatF                   = 68.              ; set the maximum latitude
  res@mpMinLonF                   = -55.0            ; set the minimum longitude
  res@mpMaxLonF                   = -18.0            ; set the maximum longitude
  ;res@mpMinLatF                   = 56.              ; set the minimum latitude (tip jet only)
  ;res@mpMaxLatF                   = 67.              ; set the maximum latitude (tj only)
  ;res@mpMinLonF                   = -57.0            ; set the minimum longitude (tj only)
  ;res@mpMaxLonF                   = -30.0            ; set the maximum longitude (tj only)

 end if
  ;res@mpLimitMode                 = "LatLon"	      ; how to zoom in on map
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 1.5               ; Make continents thinner

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

; set text res to show start and end of cross section
   txres                           = True
   txres@txFontHeightF             = 0.01

; set vector resources for spatial plot if it's a wind plot
   if (isvar("find_speed").and.(find_speed)) then
  vcres                            = True
   vcres@gsnRightString             = ""
   vcres@gsnLeftString              = ""
   vcres@gsnFrame                   = False            ; Do not draw plot 
   vcres@gsnDraw                    = False            ; Do not advance fr
   vcres@gsnAddCyclic               = False            ; regional - not cyclic 
   vcres@vcGlyphStyle               = "LineArrow"
   vcres@vcRefMagnitudeF            = 25.              ; set vector reference magnitude
   vcres@vcRefLengthF               = 0.03             ; length of vector (larger = longer)
   vcres@vcMinDistanceF             = 0.04             ; vector spacing (smaller = more dense)
   vcres@vcLineArrowThicknessF      = 1.0              ; thickness of vector arrow (larger = bolder)
   vcres@vcFillArrowsOn             = False            ; get rid of the filled vectors
  
; vector legend placement
   vcres@vcRefAnnoOrthogonalPosF    = -0.02            ; vector vertical legend placement
   vcres@vcRefAnnoParallelPosF      = 0.95             ; vector horizontal legend placement
   vcres@vcRefAnnoString1           = "Wind Speed"     ; label vector legend top string
   vcres@vcRefAnnoString1On         = True             ; turn on top vector label string
   vcres@vcRefAnnoString2           = "25 m/s"         ; label vector legend bottom string
   vcres@vcRefAnnoString2On         = True             ; turn on bottom vector label string
   end if

;;;;;;;;;;;;;
; Cross Section Plot Resources
;;;;;;;;;;;;;

 opts                              = True              ; plot mods desired
;  opts@gsnRightString              = ""
  opts@gsnLeftString               = ""
  opts@gsnFrame                    = False             ; Do not draw plot 
  opts@gsnDraw                     = False             ; Do not advance frame
  opts@gsnXAxisIrregular2Linear    = True
  opts@gsnYAxisIrregular2Linear    = True

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
  opts@cnMissingValFillColor       = "gray85"          ; missing value color
  opts@cnMissingValFillPattern     = 0                 ; fill in 
  
  opts@tiMainString                = title3
  opts@tiMainFontHeightF           = 0.013
  opts@tiXAxisString               = "Distance (km)"
  opts@tiXAxisOffsetYF             = 0.07
  opts@tiYAxisString               = "Height (m)"
  opts@tiXAxisFontHeightF          = 0.015             ; set font size for x axis
  opts@tmXBLabelFontHeightF        = 0.015             ; set tick mark label size for x axis
  opts@tiYAxisFontHeightF          = 0.015             ; set font size for y axis
  opts@tmYLLabelFontHeightF        = 0.015             ; set tick mark label size for y axis

  opts@lbLabelStride               = stride1
  opts@pmLabelBarOrthogonalPosF    = 0.05              ; move label bar closer
  opts@pmLabelBarHeightF           = 0.075             ; set height of labelbar
  opts@lbTitleString               = unit
  opts@lbTitlePosition             = "Right"
  opts@lbTitleFontHeightF          = 0.01

  opts@tmXBMode                    = "Automatic"      ; specify the tick label spacing myself
  opts@tmXBMinorOn                 = True              
  opts@tmXBMinorPerMajor           = 5

; set polyres to show eta levels
   polyres                         = True
   polyres@gsMarkerIndex           = 16               ; polymarker style
   polyres@gsMarkerSizeF           = 4.               ; polymarker size
   polyres@gsMarkerColor           = "black"          ; polymarker color

;;;;;;;;;;;;;
; Plot 1 - spatial plot
;;;;;;;;;;;;;
  cplot0 = gsn_csm_contour_map(wks, var0, res)
      
  if (isvar("find_speed").and.(find_speed)) then        ; overlay vectors
    cplot0b = gsn_csm_vector(wks, u, v, vcres)
    overlay(cplot0,cplot0b)
  end if

;; add in line showing where cross section is located 
  dum = new(1, graphic)      ; make dummy variable
  dum = gsn_add_polyline(wks,cplot0,(/st_lon,ed_lon/), (/st_lat, ed_lat/), lnres)
  
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot0, "A", st_lon, st_lat, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot0, "B", ed_lon, ed_lat, txres)

 plot(0) = cplot0

;;;;;;;;;;;;;
; Plot 2 - cross section
;;;;;;;;;;;;;

  cplot1 = gsn_csm_contour(wks,data_hgt,opts)

  if (isvar("plot_eta").and.(plot_eta))then
   ;; add in eta level spacing at right side of cross section plot
    dum4 = new(1, graphic)
    dum4 = gsn_add_polymarker(wks, cplot1, ypos, eta_levs, polyres)
  end if

  plot(1) = cplot1

;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;

  title4 = date1+" "+title1+" "+vartitle1+" from ("+st_lat+"N,"+st_lon+"W) to ("+ed_lat+"N,"+ed_lon+"W)"

  pnlres                            = True
  pnlres@txString                   = title4           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,2/),pnlres)               ; create final panel plot

  convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(additional_colors)
  delete(convert_cmd)
  delete(res)
  delete(opts)
  delete(pnlres)
  delete(data_hgt)

 if (isvar("find_speed").and.(find_speed)) then
  delete(vcres)
 end if


;;;;;;;;;;;;;;;;;;;;;; END script
end

