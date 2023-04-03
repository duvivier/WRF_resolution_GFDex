;; Plots a line graph of the momentum balance for a given 
;; set of grid points from AMPS output                                      

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

print("loaded libraries and begin")

;;;;;
; Pull file names to be read 
;;;;;

; Define constants

r2d = 45.0/atan(1.0)
pi = 3.14159265

; Create arrays of AWS names and locations (lats & lons)


i_index = (/49,50,51,52,53,54,55,56,57,58,59,60/)
j_index = (/114,113,112,111,110,109,108,107,106,105,104,103/)

print("loaded grid points")

input_file   = "/net/sundowner/data3/marichar/wrf_15km/200909/2009090600-f012-cf-ris.nc"
input_file_2 = "/net/sundowner/data3/marichar/wrf_15km/200909/2009090600-f015-cf-ris.nc" 

print("loaded input files")

;; Create output arrays

size = dimsizes(i_index)

print(size)
ws_u = new(size,"double")
ws_v = new(size,"double")
advection_u = new(size,"double")
advection_v = new(size,"double")
curvature_u = new(size,"double")
curvature_v = new(size,"double")
pg_u = new(size,"double")
pg_v = new(size,"double")
cf_u = new(size,"double")
cf_v = new(size,"double")
du_dt = new(size,"double")
dv_dt = new(size,"double")
friction_u = new(size,"double")
friction_v = new(size,"double")
data_u = new((/6,size/),"double")
data_v = new((/6,size/),"double")
data_mag = new((/6,size/),"double")
data_dir = new((/6,size/),"double")
data_along = new((/6,size/),"double")
data_cross = new((/6,size/),"double")
ws_along = new((/size/),"double")
ws_cross = new((/size/),"double")

dist = new(size,"float")


;; Set constants

a = 6370000.
omega = 0.00007292
pi = 3.14159265
grid = 15000.

;; Open raw wrf file to get the map factors

mapFacFile = addfile("/net/sundowner/home/marichar/wrf_raw/2010010100/wrfout_d02_2010-01-03_15:00:00.nc","r")

mapFac = mapFacFile->MAPFAC_M

print("loaded map factors")

;; Loop through each grid point to calculate terms 


do indx=0, dimsizes(i_index)-1

print(indx)

 ;; Open the file as read only

 wrf_1=addfile(input_file,"r")
 wrf_2=addfile(input_file_2,"r")

 lat_wrf=wrf_1->lat
 lon_wrf=wrf_1->lon

 ;; Calculate distance along the cross section
 if (indx.eq.0) then
  dist(indx)= 0
 else
  dist(indx)=dist(indx-1)+gc_latlon(lat_wrf(i_index(indx-1),j_index(indx-1)),lon_wrf(i_index(indx-1),j_index(indx-1)),lat_wrf(i_index(indx),j_index(indx)),lon_wrf(i_index(indx),j_index(indx)),4,4)
 end if


 ;; Get the various wind values for the discretization

   u_1_1 = wrf_1->u_10m_gr(0,i_index(indx),j_index(indx))
   u_2_1 = wrf_1->u_10m_gr(0,i_index(indx)+1,j_index(indx))
   u_0_1 = wrf_1->u_10m_gr(0,i_index(indx)-1,j_index(indx))
   u_1_2 = wrf_1->u_10m_gr(0,i_index(indx),j_index(indx)+1)
   u_1_0 = wrf_1->u_10m_gr(0,i_index(indx),j_index(indx)-1)

   v_1_1 = wrf_1->v_10m_gr(0,i_index(indx),j_index(indx))
   v_2_1 = wrf_1->v_10m_gr(0,i_index(indx)+1,j_index(indx))
   v_0_1 = wrf_1->v_10m_gr(0,i_index(indx)-1,j_index(indx))
   v_1_2 = wrf_1->v_10m_gr(0,i_index(indx),j_index(indx)+1)
   v_1_0 = wrf_1->v_10m_gr(0,i_index(indx),j_index(indx)-1)

 ;; Rotate u and v components to 1_1 for advection calculation

   ws_2_1 = sqrt((u_2_1*u_2_1)+(v_2_1*v_2_1))
   ws_0_1 = sqrt((u_0_1*u_0_1)+(v_0_1*v_0_1))
   ws_1_2 = sqrt((u_1_2*u_1_2)+(v_1_2*v_1_2))
   ws_1_0 = sqrt((u_1_0*u_1_0)+(v_1_0*v_1_0))
   ws_1_1 = sqrt((u_1_1*u_1_1)+(v_1_1*v_1_1))

   wd_2_1 = atan2(u_2_1,v_2_1)*r2d+180.
   wd_0_1 = atan2(u_0_1,v_0_1)*r2d+180.
   wd_1_2 = atan2(u_1_2,v_1_2)*r2d+180.
   wd_1_0 = atan2(u_1_0,v_1_0)*r2d+180.
  
   wd_1_1 = atan2(u_1_1,v_1_1)*r2d+180.

   line_angle_1 = wd_1_1/r2d

   angle_1 = line_angle_1-(wd_2_1/r2d)
   ws_2_1_along = ws_2_1*cos(angle_1)
   ws_2_1_cross = ws_2_1*sin(angle_1)

   angle_1 = line_angle_1-(wd_0_1/r2d)
   ws_0_1_along = ws_0_1*cos(angle_1)
   ws_0_1_cross = ws_0_1*sin(angle_1)

   angle_1 = line_angle_1-(wd_1_2/r2d)
   ws_1_2_along = ws_1_2*cos(angle_1)
   ws_1_2_cross = ws_1_2*sin(angle_1)

   angle_1 = line_angle_1-(wd_1_0/r2d)
   ws_1_0_along = ws_1_0*cos(angle_1)
   ws_1_0_cross = ws_1_0*sin(angle_1)
 
   angle_1 = line_angle_1-(wd_1_1/r2d)
   ws_1_1_along = ws_1_1*cos(angle_1)
   ws_1_1_cross = ws_1_1*sin(angle_1)

;; Check
; print(ws_1_1_cross)  ; should be zero
; print(ws_1_1)         
; print(ws_1_1_along)  ; should equal ws_1_1


   ;; Get the pressure and adjust it all to the elevation of index_1_1
   
   z_1_1 = wrf_1->Z_sfc(i_index(indx),j_index(indx))
   p_1_1 = wrf_1->p_sfc(0,i_index(indx),j_index(indx))
   p_2_1 = (wrf_1->p_sfc(0,i_index(indx)+1,j_index(indx)))*exp(-((z_1_1)-(wrf_1->Z_sfc(i_index(indx)+1,j_index(indx))))/(29.3*(wrf_1->T_sfc(0,i_index(indx)+1,j_index(indx)))))
   p_0_1 = (wrf_1->p_sfc(0,i_index(indx)-1,j_index(indx)))*exp(-((z_1_1)-(wrf_1->Z_sfc(i_index(indx)-1,j_index(indx))))/(29.3*(wrf_1->T_sfc(0,i_index(indx)-1,j_index(indx)))))
   p_1_2 = (wrf_1->p_sfc(0,i_index(indx),j_index(indx)+1))*exp(-((z_1_1)-(wrf_1->Z_sfc(i_index(indx),j_index(indx)+1)))/(29.3*(wrf_1->T_sfc(0,i_index(indx),j_index(indx)+1))))
   p_1_0 = (wrf_1->p_sfc(0,i_index(indx),j_index(indx)-1))*exp(-((z_1_1)-(wrf_1->Z_sfc(i_index(indx),j_index(indx)-1)))/(29.3*(wrf_1->T_sfc(0,i_index(indx),j_index(indx)-1))))

print(z_1_1)

  ;; Get the density

  rho = (p_1_1*100.)/(287.*wrf_1->T_sfc(0,i_index(indx),j_index(indx)))
  print(rho)

  ;; Get latitude and convert to radians

  lat = wrf_1->lat(i_index(indx),j_index(indx))
  lat_rad = (lat*pi)/180.

  ;; Get map factor

  mf = mapFac(0,i_index(indx),j_index(indx))

  ;; Calculate the advection term in rotated coordinates - DO NOT NEED TO ROTATE LATER

  advection_u(indx) = ((-u_1_1*(ws_1_2_cross-ws_1_0_cross))/(2*grid*mf))-((v_1_1*(ws_2_1_cross-ws_0_1_cross))/(2*grid*mf))
  advection_v(indx) = ((-u_1_1*(ws_1_2_along-ws_1_0_along))/(2*grid*mf))-((v_1_1*(ws_2_1_along-ws_0_1_along))/(2*grid*mf))



  ;; Calculate the curvature term in rotated coordinates - DO NOT NEED TO ROTATE LATER

  curvature_u(indx) = (u_1_1*v_1_1*tan(lat_rad))/a
  curvature_v(indx) = -(u_1_1*u_1_1*tan(lat_rad))/a

  ;; Calculate pressure gradient term in i,j coordinates - NEED TO ROTATE LATER

  pg_u(indx) = (-1/rho)*(((p_1_2-p_1_0)*100.)/(2*grid*mf))
  pg_v(indx) = (-1/rho)*(((p_2_1-p_0_1)*100.)/(2*grid*mf))

  ;; Calculate coriolis term in rotated coordinates - DO NOT NEED TO ROTATE LATER

  cf_u(indx) = 2*omega*v_1_1*sin(lat_rad)
  cf_v(indx) = -2*omega*u_1_1*sin(lat_rad)

  ;; Calculate acceleration term

  u_1_1 = wrf_1->u_10m_gr(0,i_index(indx),j_index(indx))

  ;; Get u and v from next time step
  u_1_1_2 = wrf_2->u_10m_gr(0,i_index(indx),j_index(indx))
  v_1_1_2 = wrf_2->v_10m_gr(0,i_index(indx),j_index(indx))

  ;; Rotate u and v from next time step
  
   ws_next = sqrt((u_1_1_2*u_1_1_2)+(v_1_1_2*v_1_1_2))
   wd_next = atan2(u_1_1_2,v_1_1_2)*r2d+180.

   angle_1 = line_angle_1-(wd_next/r2d)
   ws_1_1_2_along = ws_next*cos(angle_1)
   ws_1_1_2_cross = ws_next*sin(angle_1)

  du_dt(indx) = (ws_1_1_2_cross-ws_1_1_cross)/10800.
  dv_dt(indx) = (ws_1_1_2_along-ws_1_1_along)/10800.

  ;; Calculate friction term - will need to calculate later, this is a place holder

  friction_u(indx) = du_dt(indx) - advection_u(indx) - curvature_u(indx) - pg_u(indx) - cf_u(indx)
  friction_v(indx) = dv_dt(indx) - advection_v(indx) - curvature_v(indx) - pg_v(indx) - cf_v(indx)

  ;; Create array of u and v component of winds

  ws_u(indx) = u_1_1
  ws_v(indx) = v_1_1

  ;; Set valid date and time

  year  = wrf_1->year
  month = wrf_1->month
  day   = wrf_1->day
  hour  = wrf_1->hour

end do

;; Rotate the u and v components to be along the jet and cross the jet



;; Put each force into one array for looping through the rotating code

data_u(0,:) = advection_u
data_u(1,:) = curvature_u
data_u(2,:) = pg_u
data_u(3,:) = cf_u 
data_u(4,:) = du_dt
data_u(5,:) = friction_u

data_v(0,:) = advection_v
data_v(1,:) = curvature_v
data_v(2,:) = pg_v
data_v(3,:) = cf_v  
data_v(4,:) = dv_dt
data_v(5,:) = friction_v

data_mag(0,:) = sqrt((advection_u*advection_u)+(advection_v*advection_v))
data_mag(1,:) = sqrt((curvature_u*curvature_u)+(curvature_v*curvature_v))
data_mag(2,:) = sqrt((pg_u*pg_u)+(pg_v*pg_v))
data_mag(3,:) = sqrt((cf_u*cf_u)+(cf_v*cf_v))
data_mag(4,:) = sqrt((du_dt*du_dt)+(dv_dt*dv_dt))
data_mag(5,:) = sqrt((friction_u*friction_u)+(friction_v*friction_v))
ws_mag = sqrt((ws_u*ws_u)+(ws_v*ws_v))

data_dir(0,:) = atan2(advection_u,advection_v)*r2d
data_dir(1,:) = atan2(curvature_u,curvature_v)*r2d
data_dir(2,:) = atan2(pg_u,pg_v)*r2d
data_dir(3,:) = atan2(cf_u,cf_v)*r2d
data_dir(4,:) = atan2(du_dt,dv_dt)*r2d
data_dir(5,:) = atan2(friction_u,friction_v)*r2d
ws_dir = atan2(ws_u,ws_v)*r2d+180

do r=0, size-1

;print(r)

mag = data_mag(:,r)
dir = data_dir(:,r)

line_angle = ws_dir(r)/r2d

do ww=1, 3

 angle = line_angle-(dir(ww)/r2d)
 data_along(ww,r) = -mag(ww)*cos(angle)
 data_cross(ww,r) = -mag(ww)*sin(angle)

end do

data_along(0,r) = data_v(0,r)
data_cross(0,r) = data_u(0,r)
;data_along(1,r) = data_v(1,r)
;data_cross(1,r) = data_u(1,r)
;data_along(3,r) = data_v(3,r)
;data_cross(3,r) = data_u(3,r)
data_along(4,r) = data_v(4,r)
data_cross(4,r) = data_u(4,r)


;; rotate winds as a check

angle = line_angle-(ws_dir(r)/r2d)
ws_along(r) = ws_mag(r)*cos(angle)
ws_cross(r) = ws_mag(r)*sin(angle)

end do

data_along(5,:) = data_along(4,:)-data_along(3,:)-data_along(2,:)-data_along(1,:)-data_along(0,:)
data_cross(5,:) = data_cross(4,:)-data_cross(3,:)-data_cross(2,:)-data_cross(1,:)-data_cross(0,:)
data_mag(5,:) = sqrt((data_along(5,:)*data_along(5,:))+(data_cross(5,:)*data_cross(5,:)))


output_filename = "/home/marichar/momentum_balance/2009090600-f012_revision_momentum_balance_locus_4"

;; Build output file

title = output_filename+".txt"

header = "year  month  day  hour     adv_u   adv_v   curv_u   curv_v    pg_u    pg_v    cf_u    cf_v     du/dt     dv/dt     fric_u     fric_v"

a1 = sprintf("%6.4g",advection_u)+"     "+sprintf("%6.4g",advection_v)+"     "+sprintf("%6.4g",curvature_u)+"     "+\
       sprintf("%6.4g",curvature_v)+"     "+sprintf("%6.4g",pg_u)+"     "+sprintf("%6.4g",pg_v)+"     "+sprintf("%6.4g",cf_u)+"     "+sprintf("%6.4g",cf_v)+"     "+sprintf("%6.4g",du_dt)+"     "+sprintf("%6.4g",dv_dt)+"     "+sprintf("%6.4g",friction_u)+"     "+sprintf("%6.4g",friction_v)

output = array_append_record(header,a1,0)

asciiwrite(title,output)

; Plot each component

wks_u = gsn_open_wks("ps",output_filename+"_along")
wks_v = gsn_open_wks("ps",output_filename+"_cross")
wks_mag = gsn_open_wks("ps",output_filename+"_mag")

lgres = True
lgres@vpWidthF           = 0.15
lgres@vpHeightF          = 0.1
lgres@lgLabelFontHeightF = 0.08
lgres@lgBoxBackground    = "white"
lgres@lgPerimFill        = 0
lgres@lgPerimFillColor   = "white"
lgres@lgLineColors       = (/"black","green","red","blue","orange","pink"/)

anres = True
anres@amOrthogonalPosF   = -0.45
anres@amParallelPosF     = 0.42

legend_u = gsn_create_legend(wks_u,6,(/"Advection","Curvature", "Pressure Gradient", "Coriolis","Acceleration","Friction"/), lgres)
legend_v = gsn_create_legend(wks_v,6,(/"Advection","Curvature", "Pressure Gradient", "Coriolis","Acceleration","Friction"/), lgres)
legend_mag = gsn_create_legend(wks_mag,6,(/"Advection","Curvature","Pressure Gradient","Coriolis","Acceleration","Friction"/),lgres)

;; create resources

res = True
res@gsnMaximize          = True
res@gsnDraw              = False
res@gsnFrame             = False
res@xyMonoLineColor      = False
res@xyLineColors         = (/"black","green","red","blue","orange","pink"/)
;res@trXMinF              = min(julian_o)-values_t(0)
;res@trXMaxF              = max(julian_o)-values_t(0)
res@trYMinF = -0.014
res@trYMaxF = 0.014
res@tmXBLabelFontHeightF = 0.01
;res@tmXBMode             = "Manual"
;res@tmXBTickStartF       = round(min(julian_o)-values_t(0),0)
;res@tmXBTickEndF         = round(max(julian_o)-values_t(0),0)
res@tmXBTickSpacingF     = 5.
res@tmXBMinorOn          = True
res@tmXBMinorPerMajor    = 4.
res@tmYLLabelFontHeightF = 0.01
res@tiMainFontHeightF    = 0.02
res@tiMainOn             = True
res@tiMainString         = "Momentum Along Jet for 09-06-2009 at 12 UTC"
res@tiXAxisFontHeightF   = 0.015
res@tiYAxisFontHeightF   = 0.015
res@tiYAxisString        = "Momentum (ms-2)"
res@tiXAxisString        = "Distance (km)"
;res@tmXBMode             = "Explicit"
;res@tmXBLabels           = labels
;res@tmXBValues           = values


plot_u = gsn_xy(wks_u,dist,data_along,res)

res@tiMainString         = "Momentum Cross Jet for 09-06-2009 at 12 UTC"

plot_v = gsn_xy(wks_v,dist,data_cross,res)

res@tiMainString         = "Momentum Magnitude for 09-06-2009 at 12 UTC"

plot_mag = gsn_xy(wks_mag,dist,data_mag,res)

leg_to_pl_u = gsn_add_annotation(plot_u,legend_u,anres)
leg_to_pl_v = gsn_add_annotation(plot_v,legend_v,anres)
leg_to_pl_mag = gsn_add_annotation(plot_mag,legend_mag,anres)

draw(plot_u)
draw(plot_v)
draw(plot_mag)

frame(wks_u)
frame(wks_v)
frame(wks_mag)


end
