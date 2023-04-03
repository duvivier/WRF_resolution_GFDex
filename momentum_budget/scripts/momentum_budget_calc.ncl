;***************************************
; PROGRAM DESCRIPTION: This NCL script calculates the momentum budget values from WRF output
; INPUT DATA: WRF output post processed with wrfout_to_cf.ncl
; OUTPUT DATA: NetCDF file of momentum budget equations
; Note: This script only works for 21FEB at 7UTC
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***************************************
begin
; assign some info to start
day = "21FEB"
date0 = "2007-02-21-07"
date1 = "2007-02-21-08"
domain = "wrf_100km"
max_hgt = 100.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set variable input information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set file names based on qs pass
if (domain.eq."wrf_10km") then
  grid = 10000.
  fname_map = "/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_10km"
end if
if (domain.eq."wrf_25km") then
  grid = 25000.
  fname_map = "/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_25km"
end if
if (domain.eq."wrf_50km") then
  grid = 50000.
  fname_map = "/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_50km"
end if
if (domain.eq."wrf_100km") then
  grid = 100000.
  fname_map = "/data3/duvivier/NCAR/DATA/geo_em/geo_em.d01_100km"
end if

; getting correct directory
    dir1 = "/data3/duvivier/NCAR/DATA/" + day + "/" + domain + "/"
    fname0 = "wrf-" + date0
    fname1 = "wrf-" + date1

; set outdir and fout names
    outdir = "./"
    fout   = outdir + "momentum_budget_grid-" + domain + "-" + date0

; set constants and get mapfactor
    a = 6370000.
    omega = 0.00007292
    pi = 3.14159265

    print("Getting mapfactor")
    map_File = addfile(fname_map + ".nc","r")
    mapFac = map_File->MAPFAC_M(Time|0,south_north|:, west_east|:)
    delete(map_File)

  print("Running Flux figs for wrf-" + date0)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files and variables
;;;;;;;;;;
  print("Loading wrf")

  f0 = addfile(dir1 + fname0 + ".nc","r")  ; Load first wrf file
  f1 = addfile(dir1 + fname1 + ".nc","r")  ; Load second wrf file

  lat = f0->lat
  lon = f0->lon
  sizes = dimsizes(lat)
  nx_grid = sizes(1)
  ny_grid = sizes(0)
  n_tot = nx_grid*ny_grid

;;;;;;;;;;
; preallocate arrays for data
;;;;;;;;;;

 advection_u = new(sizes,"double")
 advection_v = new(sizes,"double")
 advection_mag = new(sizes,"double")
 curvature_u = new(sizes,"double")
 curvature_v = new(sizes,"double")
 curvature_mag = new(sizes,"double")
 pg_u = new(sizes,"double")
 pg_v = new(sizes,"double")
 pg_mag = new(sizes,"double")
 cf_u = new(sizes,"double")
 cf_v = new(sizes,"double")
 cf_mag = new(sizes,"double")
 du_dt = new(sizes,"double")
 dv_dt = new(sizes,"double")
 d_dt_mag = new(sizes,"double")
 friction_u = new(sizes,"double")
 friction_v = new(sizes,"double")
 friction_mag = new(sizes,"double")

 fill = advection_u@_FillValue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Run loops to find momentum terms at each grid cell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Calculating momentum terms at each grid point")

i=1
j=1

do j=1, nx_grid-2
  do i=1, ny_grid-2

   ;; Check to make sure that none of the grid cells have an elevation greater than threshold(m)
    z_1_1 = f0->Z_sfc(south_north|i, west_east|j)
    z_2_1 = f0->Z_sfc(south_north|i+1, west_east|j)
    z_0_1 = f0->Z_sfc(south_north|i-1, west_east|j)
    z_1_2 = f0->Z_sfc(south_north|i, west_east|j+1)
    z_1_0 = f0->Z_sfc(south_north|i, west_east|j-1)

   ; Only do analysis for points with surface height below 500m
   if (z_1_1 .lt. max_hgt .and. z_2_1 .lt. max_hgt .and. z_0_1 .lt. max_hgt .and. z_1_2 .lt. max_hgt .and. z_1_0 .lt. max_hgt) then
   ;;;;;;;;;;
   ; Load variables
   ;;;;;;;;;;
   ;; Get the various wind values for the discretization
     u_1_1 = f0->u_10m_gr(time|0,south_north|i, west_east|j)
     u_2_1 = f0->u_10m_gr(time|0,south_north|i+1, west_east|j)
     u_0_1 = f0->u_10m_gr(time|0,south_north|i-1, west_east|j)
     u_1_2 = f0->u_10m_gr(time|0,south_north|i, west_east|j+1)
     u_1_0 = f0->u_10m_gr(time|0,south_north|i, west_east|j-1)

     v_1_1 = f0->v_10m_gr(time|0,south_north|i, west_east|j)
     v_2_1 = f0->v_10m_gr(time|0,south_north|i+1, west_east|j)
     v_0_1 = f0->v_10m_gr(time|0,south_north|i-1, west_east|j)
     v_1_2 = f0->v_10m_gr(time|0,south_north|i, west_east|j+1)
     v_1_0 = f0->v_10m_gr(time|0,south_north|i, west_east|j-1)

   ;; Get the winds needed from the next timestep
     u1_1_1 = f1->u_10m_gr(time|0,south_north|i, west_east|j)
     v1_1_1 = f1->v_10m_gr(time|0,south_north|i, west_east|j)

   ;; Get the various temperature values for the discretization
     t_1_1 = f0->T_sfc(time|0,south_north|i, west_east|j)
     t_2_1 = f0->T_sfc(time|0,south_north|i+1, west_east|j)
     t_0_1 = f0->T_sfc(time|0,south_north|i-1, west_east|j)
     t_1_2 = f0->T_sfc(time|0,south_north|i, west_east|j+1)
     t_1_0 = f0->T_sfc(time|0,south_north|i, west_east|j-1)

   ;; Get the various pressure values for the discretization
     ; uses slp not p_sfc because no p_sfc in my post_processed files. 
     ; Over ocean, so difference shouldn't be large.
     p_1_1 = f0->slp(time|0,south_north|i, west_east|j)
     p_2_1 = f0->slp(time|0,south_north|i+1, west_east|j)
     p_0_1 = f0->slp(time|0,south_north|i-1, west_east|j)
     p_1_2 = f0->slp(time|0,south_north|i, west_east|j+1)
     p_1_0 = f0->slp(time|0,south_north|i, west_east|j-1)

   ;; Calcluate pressure adjusted to elevation of index_1_1
     ; This formula 3.27 from Wallace and Hobbes
     p_2_1 = p_2_1*exp(-((z_1_1)-(z_2_1))/(29.3*t_2_1))
     p_0_1 = p_0_1*exp(-((z_1_1)-(z_0_1))/(29.3*t_0_1))
     p_1_2 = p_1_2*exp(-((z_1_1)-(z_1_2))/(29.3*t_1_2))
     p_1_0 = p_1_0*exp(-((z_1_1)-(z_1_0))/(29.3*t_1_0))

   ;;;;;;;;;;
   ; Get necessary constants
   ;;;;;;;;;;
   ;; Calculate the density [kg/m3]
     rho = (p_1_1*100.)/(287.*t_1_1)

   ;; Get latitude and convert to radians
     lat_i = lat(south_north|i, west_east|j)
     lat_rad = (lat_i*pi)/180.

   ;; Get map factor at grid cell
     mf = mapFac(south_north|i, west_east|j)

   ;;;;;;;;;;
   ; Calculate momentum budget terms
   ;;;;;;;;;;
   ;; Calculate the advection term
     advection_u(i,j) = ((-u_1_1*(u_1_2-u_1_0))/(2*grid*mf))-((v_1_1*(u_2_1-u_0_1))/(2*grid*mf))
     advection_v(i,j) = ((-u_1_1*(v_1_2-v_1_0))/(2*grid*mf))-((v_1_1*(v_2_1-v_0_1))/(2*grid*mf))
     advection_mag(i,j) = sqrt((advection_u(i,j)^2)+(advection_v(i,j)^2))

   ;; Calculate the curvature term
     curvature_u(i,j) = (u_1_1*v_1_1*tan(lat_rad))/a
     curvature_v(i,j) = -(u_1_1*u_1_1*tan(lat_rad))/a
     curvature_mag(i,j) = sqrt((curvature_u(i,j)^2)+(curvature_v(i,j)^2))

   ;; Calculate pressure gradient term
     pg_u(i,j) = (-1/rho)*(((p_1_2-p_1_0)*100.)/(2*grid*mf))
     pg_v(i,j) = (-1/rho)*(((p_2_1-p_0_1)*100.)/(2*grid*mf))
     pg_mag(i,j) = sqrt((pg_u(i,j)^2)+(pg_v(i,j)^2))

   ;; Calculate coriolis term
     cf_u(i,j) = 2*omega*v_1_1*sin(lat_rad)
     cf_v(i,j) = -2*omega*u_1_1*sin(lat_rad)
     cf_mag(i,j) = sqrt((cf_u(i,j)^2)+(cf_v(i,j)^2))

   ;; Calculate acceleration term
     du_dt(i,j) = (u1_1_1-u_1_1)/10800.
     dv_dt(i,j) = (v1_1_1-v_1_1)/10800.
     d_dt_mag(i,j) = sqrt((du_dt(i,j)^2)+(dv_dt(i,j)^2))

   ;; Calculate friction term
     friction_u(i,j) = du_dt(i,j) - advection_u(i,j) - curvature_u(i,j) - pg_u(i,j) - cf_u(i,j)
     friction_v(i,j) = dv_dt(i,j) - advection_v(i,j) - curvature_v(i,j) - pg_v(i,j) - cf_v(i,j)
     friction_mag(i,j) = sqrt((friction_u(i,j)^2)+(friction_v(i,j)^2))

   else

     advection_u(i,j) = fill
     advection_v(i,j) = fill
     advection_mag(i,j) = fill
     curvature_u(i,j) = fill
     curvature_v(i,j) = fill
     curvature_mag(i,j) = fill
     pg_u(i,j) = fill
     pg_v(i,j) = fill
     pg_mag(i,j) = fill
     friction_u(i,j) = fill
     friction_v(i,j) = fill
     friction_mag(i,j) = fill
     du_dt(i,j) = fill
     dv_dt(i,j) = fill
     d_dt_mag(i,j) = fill
     cf_u(i,j) = fill
     cf_v(i,j) = fill
     cf_mag(i,j) = fill

   end if
 
   if(i%100.eq.0) then
     print("created weighting i="+i+" of "+ny_grid)
   end if
 end do
   if(j%10.eq.0) then
     print("created weighting j="+j+" of "+nx_grid)
   end if  
end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Create output file with momentum budget terms
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("creating momentum budget output file for " + domain)

  ;; Set valid date and time
  year_o = f0->year
  month_o = f0->month
  day_o = f0->day
  hour_o = f0->hour

;; Build output file
  ncdf = addfile(fout + ".nc","c")

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

;;;;;;;;;;;;;;;;;;;;;; END script

end
