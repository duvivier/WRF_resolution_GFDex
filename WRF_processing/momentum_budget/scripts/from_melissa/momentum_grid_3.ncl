	                                          
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

;;;;;
; Pull file names to be read 
;;;;;


; Creat arrays of possible year, month, day, hour and forecast for which files will be pulled
year = (/"2008","2009","2010"/)
month = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)
day = (/"01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"/)
hour = (/"00","12"/)
forecast = (/"000","003","006","009","012","015","018","021","024","027","030","033","036","039","042","045","048","051","054","057","060","063","066","069","072","075","078","081","084","087","090","093","096","099","102","105","108","111","114","117","120"/)

;;;;;;;;;;;;
;; Inputs ;;
;;;;;;;;;;;;

yr = 1             ; input the index of the year in the year array
mo = 8             ; input the index of the month in the month array
day_start = 4      ; input the index of the day in the day array where the analysis should bgin (note: this is model initialized date)
day_end   = 4      ; input the index of the day in the day array where the analysis should end
;AWS_site = 4       ; input the index of the AWS site in the AWS array where the momentum balance should be calculated
forecast_start = 4 ; input the index of the forecast category in the forecast array where analysis should start
forecast_end = 4   ; input the index of the forecast category in the forecast array where analysis should end

;; Create output arrays

size = (day_end-day_start+1)*(forecast_end-forecast_start+1)*2


;; Set constants

a = 6370000.
omega = 0.00007292
pi = 3.14159265
grid = 15000.

;; Open raw wrf file to get the map factors

mapFacFile = addfile("/home/marichar/wrf_raw/2010010100/wrfout_d02_2010-01-03_15:00:00.nc","r")

mapFac = mapFacFile->MAPFAC_M

;; Loop through each file to calculate terms for each time step

t=0

do d=day_start, day_end 
 do h=0,1
  do f=forecast_start, forecast_end

   ;; Create the file name of the file that the analysis is being conducted on

   file_name = "/data3/marichar/wrf_15km/"+year(yr)+month(mo)+"/"+year(yr)+month(mo)+day(d)+hour(h)+"-f"+forecast(f)+"-cf-ris.nc"

  if (f .ne. forecast_end) then
   file_name_2 = "/data3/marichar/wrf_15km/"+year(yr)+month(mo)+"/"+year(yr)+month(mo)+day(d)+hour(h)+"-f"+forecast(f+1)+"-cf-ris.nc"
  else
   if(h .ne. 1) then
   file_name_2 = "/data3/marichar/wrf_15km/"+year(yr)+month(mo)+"/"+year(yr)+month(mo)+day(d)+hour(1)+"-f"+forecast(forecast_start)+"-cf-ris.nc"
   else
   file_name_2 = "/data3/marichar/wrf_15km/"+year(yr)+month(mo)+"/"+year(yr)+month(mo)+day(d+1)+hour(0)+"-f"+forecast(forecast_start)+"-cf-ris.nc"
   end if
  end if


   ;; Open the file as read only

  wrf=addfile(file_name,"r")
  wrf_2=addfile(file_name_2,"r")
 
  lat = wrf->lat
  lon = wrf->lon
  sizes_cf = dimsizes(wrf->lat)
  nx_grid_cf = sizes_cf(1)
  ny_grid_cf = sizes_cf(0)


 advection_u = new(sizes_cf,"double")
 advection_v = new(sizes_cf,"double")
 advection_mag = new(sizes_cf,"double")
 curvature_u = new(sizes_cf,"double")
 curvature_v = new(sizes_cf,"double")
 curvature_mag = new(sizes_cf,"double")
 pg_u = new(sizes_cf,"double")
 pg_v = new(sizes_cf,"double")
 pg_mag = new(sizes_cf,"double")
 cf_u = new(sizes_cf,"double")
 cf_v = new(sizes_cf,"double")
 cf_mag = new(sizes_cf,"double")
 du_dt = new(sizes_cf,"double")
 dv_dt = new(sizes_cf,"double")
 d_dt_mag = new(sizes_cf,"double")
 friction_u = new(sizes_cf,"double")
 friction_v = new(sizes_cf,"double")
 friction_mag = new(sizes_cf,"double")


i=1
j=1

do j=1, nx_grid_cf-2
  do i=1, ny_grid_cf-2

   ;; Get the i,j coordinates of the grid point nearest to the chosen AWS site.

   index = getind_latlon2d(wrf->lat,wrf->lon,lat(i,j),lon(i,j))

   ;; Check to make sure that none of the grid cells are at an elevation greater than 500 meters

   z_1_1 = wrf->Z_sfc(index(0,0),index(0,1))
   z_2_1 = wrf->Z_sfc(index(0,0)+1,index(0,1))
   z_0_1 = wrf->Z_sfc(index(0,0)-1,index(0,1))
   z_1_2 = wrf->Z_sfc(index(0,0),index(0,1)+1)
   z_1_0 = wrf->Z_sfc(index(0,0),index(0,1)-1)

if (z_1_1 .lt. 500 .and. z_2_1 .lt. 500 .and. z_0_1 .lt. 500 .and. z_1_2 .lt. 500 .and. z_1_0 .lt. 500) then

   ;; Get the various wind values for the discretization

   u_1_1 = wrf->u_10m_gr(0,index(0,0),index(0,1))
   u_2_1 = wrf->u_10m_gr(0,index(0,0)+1,index(0,1))
   u_0_1 = wrf->u_10m_gr(0,index(0,0)-1,index(0,1))
   u_1_2 = wrf->u_10m_gr(0,index(0,0),index(0,1)+1)
   u_1_0 = wrf->u_10m_gr(0,index(0,0),index(0,1)-1)

   v_1_1 = wrf->v_10m_gr(0,index(0,0),index(0,1))
   v_2_1 = wrf->v_10m_gr(0,index(0,0)+1,index(0,1))
   v_0_1 = wrf->v_10m_gr(0,index(0,0)-1,index(0,1))
   v_1_2 = wrf->v_10m_gr(0,index(0,0),index(0,1)+1)
   v_1_0 = wrf->v_10m_gr(0,index(0,0),index(0,1)-1)

   ;; Get the pressure and adjust it all to the elevation of index_1_1
   

   p_1_1 = wrf->p_sfc(0,index(0,0),index(0,1))
   p_2_1 = (wrf->p_sfc(0,index(0,0)+1,index(0,1)))*exp(-((z_1_1)-(wrf->Z_sfc(index(0,0)+1,index(0,1))))/(29.3*(wrf->T_sfc(0,index(0,0)+1,index(0,1)))))
   p_0_1 = (wrf->p_sfc(0,index(0,0)-1,index(0,1)))*exp(-((z_1_1)-(wrf->Z_sfc(index(0,0)-1,index(0,1))))/(29.3*(wrf->T_sfc(0,index(0,0)-1,index(0,1)))))
   p_1_2 = (wrf->p_sfc(0,index(0,0),index(0,1)+1))*exp(-((z_1_1)-(wrf->Z_sfc(index(0,0),index(0,1)+1)))/(29.3*(wrf->T_sfc(0,index(0,0),index(0,1)+1))))
   p_1_0 = (wrf->p_sfc(0,index(0,0),index(0,1)-1))*exp(-((z_1_1)-(wrf->Z_sfc(index(0,0),index(0,1)-1)))/(29.3*(wrf->T_sfc(0,index(0,0),index(0,1)-1))))


  ;; Get the density

  rho = (p_1_1*100.)/(287.*wrf->T_sfc(0,index(0,0),index(0,1)))

  ;; Get latitude and convert to radians

  lat_i = wrf->lat(index(0,0),index(0,1))
  lat_rad = (lat_i*pi)/180.

  ;; Get map factor

  mf = mapFac(0,index(0,0),index(0,1))

  ;; Calculate the advection term

  advection_u(i,j) = ((-u_1_1*(u_1_2-u_1_0))/(2*grid*mf))-((v_1_1*(u_2_1-u_0_1))/(2*grid*mf))
  advection_v(i,j) = ((-u_1_1*(v_1_2-v_1_0))/(2*grid*mf))-((v_1_1*(v_2_1-v_0_1))/(2*grid*mf))
  advection_mag(i,j) = sqrt((advection_u(i,j)*advection_u(i,j))+(advection_v(i,j)*advection_v(i,j)))

  ;; Calculate the curvature term

  curvature_u(i,j) = (u_1_1*v_1_1*tan(lat_rad))/a
  curvature_v(i,j) = -(u_1_1*u_1_1*tan(lat_rad))/a
  curvature_mag(i,j) = sqrt((curvature_u(i,j)*curvature_u(i,j))+(curvature_v(i,j)*curvature_v(i,j)))


  ;; Calculate pressure gradient term


  pg_u(i,j) = (-1/rho)*(((p_1_2-p_1_0)*100.)/(2*grid*mf))
  pg_v(i,j) = (-1/rho)*(((p_2_1-p_0_1)*100.)/(2*grid*mf))
  pg_mag(i,j) = sqrt((pg_u(i,j)*pg_u(i,j))+(pg_v(i,j)*pg_v(i,j)))


  ;; Calculate coriolis term

  cf_u(i,j) = 2*omega*v_1_1*sin(lat_rad)
  cf_v(i,j) = -2*omega*u_1_1*sin(lat_rad)
  cf_mag(i,j) = sqrt((cf_u(i,j)*cf_u(i,j))+(cf_v(i,j)*cf_v(i,j)))

  ;; Calculate acceleration term

  du_dt(i,j) = ((wrf_2->u_10m_gr(0,index(0,0),index(0,1)))-u_1_1)/10800.
  dv_dt(i,j) = ((wrf_2->v_10m_gr(0,index(0,0),index(0,1)))-v_1_1)/10800.
  d_dt_mag(i,j) = sqrt((du_dt(i,j)*du_dt(i,j))+(dv_dt(i,j)*dv_dt(i,j)))

  ;; Calculate friction term

  friction_u(i,j) = du_dt(i,j) - advection_u(i,j) - curvature_u(i,j) - pg_u(i,j) - cf_u(i,j)
  friction_v(i,j) = dv_dt(i,j) - advection_v(i,j) - curvature_v(i,j) - pg_v(i,j) - cf_v(i,j)
  friction_mag(i,j) = sqrt((friction_u(i,j)*friction_u(i,j))+(friction_v(i,j)*friction_v(i,j)))

else

advection_u(i,j) = -9999
advection_v(i,j) = -9999
advection_mag(i,j) = -9999
curvature_u(i,j) = -9999
curvature_v(i,j) = -9999
curvature_mag(i,j) = -9999
pg_u(i,j) = -9999
pg_v(i,j) = -9999
pg_mag(i,j) = -9999
friction_u(i,j) = -9999
friction_v(i,j) = -9999
friction_mag(i,j) = -9999
du_dt(i,j) = -9999
dv_dt(i,j) = -9999
d_dt_mag(i,j) = -9999
cf_u(i,j) = -9999
cf_v(i,j) = -9999
cf_mag(i,j) = -9999

end if


  ;; Set valid date and time

  year_o = wrf->year
  month_o = wrf->month
  day_o = wrf->day
  hour_o = wrf->hour


end do
end do

  yryr=wrf->year
  syr=flt2string(yryr)
  momo=wrf->month
  if (momo .lt. 10) then
  smo = "0"+flt2string(momo)
  else
  smo=flt2string(momo)
  end if
  dydy=wrf->day
  if (dydy .lt. 10) then
  sdy="0"+flt2string(dydy)
  else
  sdy=flt2string(dydy)
  end if
  hrhr=wrf->hour
  if (hrhr .lt. 10) then
  shr="0"+flt2string(hrhr)
  else
  shr=flt2string(hrhr)
  end if


;; Build output file

output_title = syr+smo+sdy+shr+"_momentum_balance_grid_data"

ncdf = addfile(output_title+".nc","c")

ncdf->lat = lat
ncdf->lon = lon
ncdf->year = year_o
ncdf->month = month_o
ncdf->day = day_o
ncdf->hour = hour_o
ncdf->du_dt = du_dt
ncdf->dv_dt = dv_dt
ncdf->d_dt_mag = d_dt_mag
ncdf->pg_u = pg_u
ncdf->pg_v = pg_v
ncdf->pg_mag = pg_mag
ncdf->advection_u = advection_u
ncdf->advection_v = advection_v
ncdf->advection_mag = advection_mag
ncdf->cf_u = cf_u
ncdf->cf_v = cf_v
ncdf->cf_mag = cf_mag
ncdf->curvature_u = curvature_u
ncdf->curvature_v = curvature_v
ncdf->curvature_mag = curvature_mag
ncdf->friction_u = friction_u
ncdf->friction_v = friction_v
ncdf->friction_mag = friction_mag


end do 
end do
end do


end
