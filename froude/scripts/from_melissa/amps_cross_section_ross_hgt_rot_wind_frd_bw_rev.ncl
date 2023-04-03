;--------------------------------------------------------------------;
;                                                                    ;
; PROGRAM: amps_plots                                                ;
; PROGRAM DESCRIPTION: This NCL script makes plots of the AMPS data  ;
; INPUT DATA: AMPS 6 km output                                       ;
; OUTPUT DATA: A postscript file of the requested plots              ;
; DATE: Started January 13, 2008                                     ;
;                                                                    ;
;--------------------------------------------------------------------;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load necessary libraries ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;;;;;;;;;;;;;;;;;
; Start program ;
;;;;;;;;;;;;;;;;;

begin


file_name = "/data3/marichar/wrf_15km/raw/200909/wrf_files/2009090500-f021-cf-ris.nc"


;; Create arrays of grid point indices for perpendicular
;; and parallel to the mountains to plot the cross section

;; Perpendicular to the mountains

; AMPS_i = (/220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240/)
; AMPS_j = (/220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240/)

;; Parallel to the mountains


; AMPS_i = (/235,234,233,232,231,230,229,228,227,226,225,224,222/)
; AMPS_j = (/222,224,226,228,229,230,232,233,234,235,236,237,238/)

;; CAD case study

;AMPS_i = (/220,222,224,226,228,230,232,234,236,238,240,242,244,246,248,250,252,254,256,258,260/)
;AMPS_j = (/225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245/)


;; Perpendicular to the mountains through area of mass build up

; AMPS_i = (/218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238/)
; AMPS_j = (/230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250/)

AMPS_i = (/46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66/)
AMPS_j = (/108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128/)

;AMPS_i = (/46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71/)
;AMPS_j = (/108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133/)

;; 1

; AMPS_i = (/220,222,224,226,228,230,232,234,236,238,240,242,244/)
; AMPS_j = (/231,230,229,228,227,226,225,224,223,222,221,220,219/)

;; 2

; AMPS_i = (/220,222,224,226,228,230,232,234,236,238,240,242,244/)
; AMPS_j = (/234,233,232,231,230,229,228,227,226,225,224,223,222/)

;; Create the array of heights to be interpolated to - these should be
;; estimated to be between the eta levels

;hgts = (/25.,65.,110.,170.,245.,330.,425.,530.,640.,750.,875.,1020.,1190.,1390.,1625.,1900.,2235.,2635.,3100.,3650.,4275.,4990.,5780.,6640.,7560.,8500.,9445.,10390.,11325.,12260.,13200.,14155./)

hgts = ispan(0,5000,1)

output_file = "/net/vardar/home/marichar/AMPS_cross_sections/plots/2009090500-f021"

wks_u = gsn_open_wks("ps",output_file+"_u_par_cross_section_hgts_rev")
wks_v = gsn_open_wks("ps",output_file+"_v_per_cross_section_hgts_rev")
wks_fr = gsn_open_wks("ps",output_file+"_fr_cross_section_hgts_rev")


res = True

;;;;; 
; Open the file that has the plotting data
;;;;;

 wrf=addfile(file_name,"r")          ; Loading the input file in read-only

; wrf=addfile("/data5/marichar/raw_200909_nc/2009090400/2009090400-f090-cf.nc","r")

;; Pull Valid Time information

year = wrf->year
month = wrf->month
day = wrf->day
hour = wrf->hour

;; Pull the data to be plotted - only pull the grid points that match the cross section

  u = wrf->u_gr_e(0,:,AMPS_i,AMPS_j)
  u@lat2d = wrf->lat
  u@lon2d = wrf->lon

  v = wrf->v_gr_e(0,:,AMPS_i,AMPS_j)
  v@lat2d = wrf->lat
  v@lon2d = wrf->lon

  wspd = u
  wspd = (/sqrt(u^2+v^2)/)
  wspd@lat2d = wrf->lat
  wspd@lon2d = wrf->lon

  r2d = 45.0/atan(1.0)

  wdir = wspd
  wdir = atan2(u,v)*r2d+180
  wdir@lat2d = wrf->lat
  wdir@lon2d = wrf->lon

;; Rotate the winds to u-parallel and v-perpendicular to the cross section

pi = 3.14159265

szs = dimsizes(wspd)

u_parallel = new((/szs(0),szs(1),szs(2)/),float)
v_perpendicular = new((/szs(0),szs(1),szs(2)/),float)

do vv=0, szs(1)-1

;print(vv)

if (vv .eq. 0) then

spd = wspd(:,vv,vv)
dir = wdir(:,vv,vv)

dy = AMPS_i(vv+1)-AMPS_i(vv)
dx = AMPS_j(vv+1)-AMPS_j(vv)

print(dx)
print(dy)

line_angle = (90*(pi/180.)) - atan2(dy,dx)
line_angle_2 = atan2(dy,dx)

print(line_angle*r2d)

do ww=0, szs(0)-1

if (dir(ww) .ge. 0 .and. dir(ww) .lt. 90) then
 angle = line_angle - (dir(ww)*(pi/180.))
 u_parallel(ww,vv,vv) = -spd(ww)*cos(angle)
 v_perpendicular(ww,vv,vv) = -spd(ww)*sin(angle)
end if

if (dir(ww) .ge. 90 .and. dir(ww) .lt. 180) then
 angle = line_angle_2 + ((dir(ww)-90)*(pi/180.))
 u_parallel(ww,vv,vv) = -spd(ww)*cos(angle)
 v_perpendicular(ww,vv,vv) = spd(ww)*sin(angle)
end if

if (dir(ww) .ge. 180 .and. dir(ww) .lt. 270) then
 angle = line_angle - ((dir(ww)-180)*((pi)/180.))
 u_parallel(ww,vv,vv) = spd(ww)*cos(angle)
 v_perpendicular(ww,vv,vv) = spd(ww)*sin(angle)
end if

if (dir(ww) .ge. 270 .and. dir(ww) .lt. 360) then
 angle = line_angle_2 + ((dir(ww)-270)*(pi/180.))
 u_parallel(ww,vv,vv) = spd(ww)*cos(angle)
 v_perpendicular(ww,vv,vv) = -spd(ww)*sin(angle)
end if

end do

end if

if (vv .ne. 0 .and. vv .ne. szs(1)-1) then

spd = wspd(:,vv,vv)
dir = wdir(:,vv,vv)

dy = AMPS_i(vv+1)-AMPS_i(vv-1)
dx = AMPS_j(vv+1)-AMPS_j(vv-1)

line_angle = (90*(pi/180.)) - atan2(dy,dx)

do wx=0, szs(0)-1

if (dir(wx) .ge. 0 .and. dir(wx) .lt. 90) then
 angle = line_angle - (dir(wx)*(pi/180.))
 u_parallel(wx,vv,vv) = -spd(wx)*cos(angle)
 v_perpendicular(wx,vv,vv) = -spd(wx)*sin(angle)
end if

if (dir(wx) .ge. 90 .and. dir(wx) .lt. 180) then
 angle = line_angle_2 + ((dir(wx)-90)*(pi/180.))
 u_parallel(wx,vv,vv) = -spd(wx)*cos(angle)
 v_perpendicular(wx,vv,vv) = spd(wx)*sin(angle)
end if

if (dir(wx) .ge. 180 .and. dir(wx) .lt. 270) then
 angle = line_angle + ((180-dir(wx))*((pi)/180.))
 u_parallel(wx,vv,vv) = spd(wx)*cos(angle)
 v_perpendicular(wx,vv,vv) = spd(wx)*sin(angle)
end if

if (dir(wx) .ge. 270 .and. dir(wx) .lt. 360) then
 angle = line_angle_2 + ((dir(wx)-270)*(pi/180.))
 u_parallel(wx,vv,vv) = spd(wx)*cos(angle)
 v_perpendicular(wx,vv,vv) = -spd(wx)*sin(angle)
end if

end do

end if

if (vv .eq. szs(1)-1) then

spd = wspd(:,vv,vv)
dir = wdir(:,vv,vv)

dy = AMPS_i(vv)-AMPS_i(vv-1)
dx = AMPS_j(vv)-AMPS_j(vv-1)

line_angle = (90*(pi/180.)) - atan2(dy,dx)

do wy=0, szs(0)-1

if (dir(wy) .ge. 0 .and. dir(wy) .lt. 90) then
 angle = line_angle - (dir(wy)*(pi/180.))
 u_parallel(wy,vv,vv) = -spd(wy)*cos(angle)
 v_perpendicular(wy,vv,vv) = -spd(wy)*sin(angle)
end if

if (dir(wy) .ge. 90 .and. dir(wy) .lt. 180) then
 angle = line_angle_2 + ((dir(wy)-90)*(pi/180.))
 u_parallel(wy,vv,vv) = -spd(wy)*cos(angle)
 v_perpendicular(wy,vv,vv) = spd(wy)*sin(angle)
end if

if (dir(wy) .ge. 180 .and. dir(wy) .lt. 270) then
 angle = line_angle + ((180-dir(wy))*((pi)/180.))
 u_parallel(wy,vv,vv) = spd(wy)*cos(angle)
 v_perpendicular(wy,vv,vv) = spd(wy)*sin(angle)
end if

if (dir(wy) .ge. 270 .and. dir(wy) .lt. 360) then
 angle = line_angle_2 + ((dir(wy)-270)*(pi/180.))
 u_parallel(wy,vv,vv) = spd(wy)*cos(angle)
 v_perpendicular(wy,vv,vv) = -spd(wy)*sin(angle)
end if

end do

end if

end do

  pot_t = wrf->Th_e(0,:,AMPS_i,AMPS_j)
  pot_t@lat2d = wrf->lat
  pot_t@lon2d = wrf->lon
 
  lat = wrf->lat
  lon = wrf->lon
  eta = wrf->eta

  Z_e = wrf->Z_e(0,:,AMPS_i,AMPS_j)
  Z_e@lat2d = lat
  Z_e@lon2d = lon

  Z_sfc = wrf->Z_sfc(AMPS_i,AMPS_j)
  Z_sfc@lat2d = lat
  Z_sfc@lon2d = lon

  sz = dimsizes(Z_e)  ;; sz(0) gives the number of eta levels

  fr_data = pot_t
  fr_data@lat2d = lat
  fr_data@lon2d = lon 
  fr_data@_FillValue = -999

  g = 9.80665
  hgt_mtn = 2852.

print("moutain height="+max(Z_sfc))

;; Create a new array to make the vertical cross section a 2-dimensional array
;; The dimensions are:
;; Vertical (on eta levels)
;; Horizontal (distance along the cross section line)

  data_fr = new((/sz(0),dimsizes(AMPS_i)/),float)
  data_fr!0 = "Eta_Level"
  data_fr!1 = "Horizontal" 
  data_fr@_FillValue = -999

  u_par = new((/sz(0),dimsizes(AMPS_i)/),float)
  u_par!0 = "Eta_Level"
  u_par!1 = "Horizontal"

  v_per = new((/sz(0),dimsizes(AMPS_i)/),float)
  v_per!0 = "Eta_Level"
  v_per!1 = "Horizontal"

;; Create array of eta level heights along the cross section
  z = new((/sz(0),dimsizes(AMPS_i)/),float)

;; Create array of distance along the cross section
  dist = new((/dimsizes(AMPS_i)/),float)

;; Create array of surface heights along the cross section
  z_sfc = new((/dimsizes(AMPS_i)/),float)

;; Loop through to create 2-dimensional arrays of variable to plot
;; and eta level heights along the cross section and 1-dimensional
;; arrays of surface height and distance along the cross section

  c=0

  do a =0, dimsizes(AMPS_i)-1

     x=0

     ; Determine which eta level (x) is the first level above the height
     ; of the mountain

      do  while (Z_e(x,a,a) .le. hgt_mtn)

       x=x+1

      end do
   
     ; x is now equal to the first level above the height
     ; of the mountain
     ; interpolate level x to the height of the mtn

     D_hgt = Z_e(x-1,a,a)  ;; the height of the eta level below the height to interpolate to
     E_hgt = Z_e(x,a,a)    ;; the height of the eta level above the height to interpolate to
     F_hgt = hgt_mtn   ;; the height to interpolate to
     total_dist = E_hgt - D_hgt  ;; the total distance between the eta levels surrounding the height to interpolate to
 
  if (pot_t(x,a,a) .gt. pot_t(x-1,a,a)) then ; determine if variable is increasing with height

     wt = (F_hgt-D_hgt)/total_dist  ;; a weighting factor 
     pot_t(x,a,a) = pot_t(x-1,a,a)+((pot_t(x,a,a)-pot_t(x-1,a,a))*wt)
  else
     wt = (E_hgt-F_hgt)/total_dist
     pot_t(x,a,a) = pot_t(x,a,a)+((pot_t(x-1,a,a)-pot_t(x,a,a))*wt)
  end if
 
  if (u_parallel(x,a,a) .gt. u_parallel(x-1,a,a)) then ; determine if variable is increasing with height

     wt = (F_hgt-D_hgt)/total_dist  ;; a weighting factor 
     u_parallel(x,a,a) = u_parallel(x-1,a,a)+((u_parallel(x,a,a)-u_parallel(x-1,a,a))*wt)
  else
     wt = (E_hgt-F_hgt)/total_dist
     u_parallel(x,a,a) = u_parallel(x,a,a)+((u_parallel(x-1,a,a)-u_parallel(x,a,a))*wt)
  end if

  if (v_perpendicular(x,a,a) .gt. v_perpendicular(x-1,a,a)) then ; determine if variable is increasing with height

     wt = (F_hgt-D_hgt)/total_dist  ;; a weighting factor 
     v_perpendicular(x,a,a) = v_perpendicular(x-1,a,a)+((v_perpendicular(x,a,a)-v_perpendicular(x-1,a,a))*wt)
  else
     wt = (E_hgt-F_hgt)/total_dist
     v_perpendicular(x,a,a) = v_perpendicular(x,a,a)+((v_perpendicular(x-1,a,a)-v_perpendicular(x,a,a))*wt)
  end if


  Z_e(x,a,a) = hgt_mtn

   do b=0, x-1
    do j=b, x-1
     if(j.eq.b) then
     fr_sum=(((pot_t(j+1,a,a)+pot_t(j,a,a))/2)-pot_t(b,a,a))*(Z_e(j+1,a,a)-Z_e(j,a,a))
     else
     fr_sum=(((pot_t(j+1,a,a)+pot_t(j,a,a))/2)-pot_t(b,a,a))*(Z_e(j+1,a,a)-Z_e(j,a,a))+fr_sum
     end if
    end do

    if(u_parallel(b,a,a).lt.0) then
     fr_data(b,a,a)=-u_parallel(b,a,a)/sqrt((g*fr_sum)/pot_t(b,a,a))
    else
     fr_data(b,a,a)=-.5
    end if

    fr_sum=0

   end do
    
   do kk=x, sz(0)-1

    fr_data(kk,a,a)=5

   end do

    u_par(:,a) = (/(u_parallel(:,a,a))/)
    v_per(:,a) = (/v_perpendicular(:,a,a)/)
    z(:,a) = (/Z_e(:,a,a)/)
    data_fr(:,a) = (/fr_data(:,a,a)/)

    z_sfc(a) = (/Z_sfc(a,a)/) 

   if(c .eq. 0) then
    dist(a) = 0
    else
    dist(a) = dist(a-1)+gc_latlon(lat(AMPS_i(a-1),AMPS_j(a-1)),lon(AMPS_i(a-1),AMPS_j(a-1)),lat(AMPS_i(a),AMPS_j(a)),lon(AMPS_i(a),AMPS_j(a)),4,4)
    end if 
  c = c +1
  end do


;; Create a new array:
;; Vertical dimension equals the interpolated heights
;; Horizontal dimension equals the horizontal distance of the cross section

  u_par_hgt = new((/dimsizes(hgts),dimsizes(dist)/),float)
  u_par_hgt!0 = "Height"
  u_par_hgt!1 = "Horizontal"
  u_par_hgt&Height = hgts
  u_par_hgt&Horizontal = dist
  u_par_hgt@_FillValue = -999

  v_per_hgt = new((/dimsizes(hgts),dimsizes(dist)/),float)
  v_per_hgt!0 = "Height"
  v_per_hgt!1 = "Horizontal"
  v_per_hgt&Height = hgts
  v_per_hgt&Horizontal = dist
  v_per_hgt@_FillValue = -999

  data_hgt_fr = new((/dimsizes(hgts),dimsizes(dist)/),float)
  data_hgt_fr!0 = "Height"
  data_hgt_fr!1 = "Horizontal"
  data_hgt_fr&Height = hgts
  data_hgt_fr&Horizontal = dist
  data_hgt_fr@_FillValue = -999

;; Loop through to to interpolate a value to each point in the data_hgt array

; Loop through each grid point along the distance of the cross section

 do d=0, dimsizes(dist)-1

 ; Loop through each heights to be interpolated to

  do h=0, dimsizes(hgts)-1

  ; Check to make sure that the height to be interpolated to is above
  ; the surface, if not, this should be a missing value

   if (z_sfc(d) .lt. hgts(h)) then

    f=0

   ; If the height to interpolate to is above the first eta level proceed with
   ; the interpolation

    if (z(f,d) .lt. hgts(h)) then

    ; Determine which eta level (f) is the first level above the height
    ; to interpolate to

     do  while (z(f,d) .lt. hgts(h))

      f=f+1

     end do
   
    ; f is now equal to the first level above the height 
    ; to interpolate to 

    A_hgt = z(f-1,d)  ;; the height of the eta level below the height to interpolate to
    B_hgt = z(f,d)    ;; the height of the eta level above the height to interpolate to
    C_hgt = hgts(h)   ;; the height to interpolate to
    total_dist = B_hgt - A_hgt  ;; the total distance between the eta levels surrounding the height to interpolate to
 
 if (u_par(f,d) .gt. u_par(f-1,d)) then ; determine if variable is increasing with height

    wt = (C_hgt-A_hgt)/total_dist  ;; a weighting factor 
    u_par_hgt(h,d) = u_par(f-1,d)+((u_par(f,d)-u_par(f-1,d))*wt)
 else
    wt = (B_hgt-C_hgt)/total_dist
    u_par_hgt(h,d) = u_par(f,d)+((u_par(f-1,d)-u_par(f,d))*wt)
 end if

 if (v_per(f,d) .gt. v_per(f-1,d)) then ; determine if variable is increasing with height

    wt = (C_hgt-A_hgt)/total_dist  ;; a weighting factor 
    v_per_hgt(h,d) = v_per(f-1,d)+((v_per(f,d)-v_per(f-1,d))*wt)
 else
    wt = (B_hgt-C_hgt)/total_dist
    v_per_hgt(h,d) = v_per(f,d)+((v_per(f-1,d)-v_per(f,d))*wt)
 end if

 if (ismissing(data_fr(f,d)) .or. ismissing(data_fr(f-1,d))) then

  if (ismissing(data_fr(f,d)) .and. .not.ismissing(data_fr(f-1,d)) .and. data_fr(f-1,d) .le. 1.) then
 
   data_hgt_fr(h,d)=1.

  else

  data_hgt_fr(h,d)=-999

  end if

 else

 if (data_fr(f,d) .gt. data_fr(f-1,d)) then ; determine if variable is increasing with height

    wt = (C_hgt-A_hgt)/total_dist  ;; a weighting factor 
    data_hgt_fr(h,d) = data_fr(f-1,d)+((data_fr(f,d)-data_fr(f-1,d))*wt)
 else
    wt = (B_hgt-C_hgt)/total_dist
    data_hgt_fr(h,d) = data_fr(f,d)+((data_fr(f-1,d)-data_fr(f,d))*wt)
 end if

 end if

 else

  u_par_hgt(h,d)=-999
  v_per_hgt(h,d)=-999
  data_hgt_fr(h,d)=-.5

 end if
   
else

  u_par_hgt(h,d) = -999
  v_per_hgt(h,d) = -999
  data_hgt_fr(h,d) = -999

end if

  end do
 end do

;print(data_hgt)

  z!0 = "Height"
  z!1 = "Horizontal"
  z@units = "km" 

  dist!0 = "Horizontal"
  dist@units = "km"

;gsn_define_colormap(wks, "sensibleheat_color_table_old")
 gsn_define_colormap(wks_u, "GrayWhiteGray_color_table")
 gsn_define_colormap(wks_v, "whitetoblack_color_table")
 gsn_define_colormap(wks_fr, "whitetoblack_color_table")
 

 opts = True
 opts@gsnFrame = False
 opts@gsnDraw  = False
 opts@cnLevelSpacingF = 2.
 opts@cnFillOn  = True
 opts@cnMonoFillPattern = False
 opts@cnMinLevelValF = 0
 opts@cnMaxLevelValF = 0
 opts@cnFillPatterns = (/0,0,0,0,0,0,0,15,15,15,15,15,15/)
 opts@cnLineLabelsOn = True
 opts@cnLineLabelInterval = 1
 opts@cnLevelSelectionMode = "ExplicitLevels"
 opts@cnLevels = (/-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24/)
 opts@gsnSpreadColors = True
; opts@gsnSpreadColorEnd = -3
 opts@gsnXAxisIrregular2Linear = True
 opts@gsnYAxisIrregular2Linear = True
 opts@lbLabelAutoStride = True
 opts@tiMainString = "Magnitude of Wind Speed (ms-1)  Parallel to the Cross Section: "+month+"-"+day+"-"+year+" "+hour+"UTC     "
 opts@tiMainFontHeightF = 0.018
 opts@tiXAxisString = "Distance (km)"
 opts@tiYAxisString = "Height (m)" 
 opts@lbLabelPosition = "Right"
 opts@lbOrientation = "Vertical"

 opts@cnMissingValFillPattern = 0
 opts@cnMissingValFillColor = "white"
 opts@cnMissingValPerimColor = "black"
 opts@cnMissingValPerimOn = True
 opts@cnMissingValPerimThicknessF = 2.

 plot_u = gsn_csm_contour(wks_u,u_par_hgt,opts)

 delete(opts@cnFillPatterns)
 delete(opts@cnLevels)
 opts@cnFillPatterns = (/0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/)
 opts@cnLevels = (/0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/)
 opts@tiMainString = "Magnitude of Wind Speed (ms-1)  Perpendicular to the Cross Section: "+month+"-"+day+"-"+year+" "+hour+"UTC     "

 plot_v = gsn_csm_contour(wks_v,v_per_hgt,opts)

 frs=True
 frs@gsnDraw = False
 frs@gsnFrame = False
 frs@cnLevelSelectionMode = "ExplicitLevels"
 frs@cnLevels = (/0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1.0/)
 frs@cnLinesOn = True
 frs@cnLineLabelsOn = False
; frs@cnLineThicknessF = 5.
 frs@cnFillOn = True
 frs@cnLineColor = "black"
 frs@cnInfoLabelOn = False
 frs@gsnSpreadColors = True

 frs@tiMainString = "Froude Number Along the Cross Section: "+month+"-"+day+"-"+year+" "+hour+"UTC      "
 frs@tiMainFontHeightF = 0.018
 frs@tiXAxisString = "Distance (km)"
 frs@tiYAxisString = "Height (m)" 
 frs@lbLabelPosition = "Right"
 frs@lbOrientation = "Vertical"



 frs@cnMissingValFillPattern = 0
 frs@cnMissingValFillColor = "white"
 frs@cnMissingValPerimColor = "black"
 frs@cnMissingValPerimOn = True
 frs@cnMissingValPerimThicknessF = 2.

;data_hgt_fr_plot = data_hgt_fr(0:2999,:)

 plot_fr = gsn_csm_contour(wks_fr,data_hgt_fr,frs)
; plot_2 = gsn_contour_shade(plot_2,0.9,1.0,frsshd)

; overlay(plot,plot_2)

 draw(plot_u)
 frame(wks_u)

 draw(plot_v)
 frame(wks_v)

 draw(plot_fr)
 frame(wks_fr)

end

