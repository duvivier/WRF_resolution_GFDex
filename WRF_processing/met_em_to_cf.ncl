;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; met_em_to_nc.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -NCL script to read an ARW met_em NetCDF file on staggered model
;  grid and to output unstaggered values in NetCDF CF compliant format
; -This script is based on the script wrfout_to_cf.ncl v.1.1.4a
;
; command syntax:
;   ncl 'file_in="met_em.d01.1998-02-01_00:00:00.nc"'  \
;       'file_out="met_em-cf.nc"' met_em_to_cf.ncl
;
; -The NCL script is executed by the above command syntax.  Alternatively,
;  the file_out and file_in can be set in the script and there is then no
;  need to specify it at the commande prompt.
; -The values which are to be included in the output are determined by
;  setting several attribute variables to True (include) or False (skip).
;  These attribute variables are set at around line 150 in this script.
; -Setting the overall variable to false will exclude all of the variables
;  in that class to not be included.  For example, setting the variable 
;  out2dMet to False means that all 2dMet variables will not be included.
;  If out2dMet is set to true all of the individual variable attributes
;  (i.e. out2dMet@T_sfc, out2dMet@T_2m, etc.) which are also set to true
;  will be included in the output.
;
; Support information:
;  This script is semi-supported based on the available time that I have.  If
;  you come across an error or have an idea for an improvement, please let me
;  know.  I will update the script on a time available basis.  Send all 
;  inquiries or questions to: Mark Seefeldt - mark.seefeldt@colorado.edu
;
; Ver. 1.0.0 - June 7, 2009 - original version
;
;  Todo:  -add ability to read in soil moisture and temperature
;          (currently inidcated below, but not implemented)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "/home/higginsm/ncl/fixes/WRFUserARW.ncl"
;load "/u1/uaf/higgins/ncl/fixes/WRFUserARW.ncl"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; procedure to process the attributes in creating CF compliant WRF output
procedure assignVarAttCoord(x:numeric, time[*]:numeric, vert[*]:numeric,  \
                             fl_vert:numeric)
  ; x:numeric        -variable to process the attributes
  ; time[*]:numeric  -array with time values for adding coordinates
  ; vert[*]:numeric  -array with vertical values for adding coordinates
  ;                  Note: set to 0 if no vertical coordinate
  ; fl_vert:numeric  -flag indicating vertical coordinate type
  ;                   0 = no vertical coordinate (x,y only)
  ;                   1 = pressure
  ;                   2 = eta
  ;                   3 = soil
  ; MissingValue     -assigned missing value attribute
begin
  ; assign the default missing value
  MissingValue               = -999999
  ; set time for all variables
  x!0 = "time"
  x&time = time
  ; set the vertical coordinate depending on fl_vert
  if (fl_vert .eq. 1) then             ;pressure as vertical coordinate
    x!1 = "pressure"
    x&pressure = vert
    x@missing_value = MissingValue
  end if
  if (fl_vert .eq. 2) then             ;eta as vertical coordinate
    x!1 = "eta"
    x&eta = vert
  end if
  if (fl_vert .eq. 3) then             ;soil as vertical coordinate
    x!1 = "soil"
    x&soil = vert
  end if
  ; set the horizontal coordinates
  if (fl_vert .eq. 0) then             ;no vertical coordinate 
    x!1 = "south_north"
    x!2 = "west_east"
  else                                 ;with vertical coordinate
    x!2 = "south_north"
    x!3 = "west_east"
  end if
  ; set the mapping coordinates
  x@coordinates = "lon lat"
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; start the primary met_em_to_cf.ncl program
begin
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; configuration settings
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the units for time
  TimeUnits = "hours since 1998-01-01 00:00:00"
  ; set the limits for the output range
  ;   0 = beginning of dataset
  ;   9999 = end of dataset
  ;   Note: remember that the array is zero-based
  ;   Note: met_em files are produced with only one time per file
  limTime = (/0,9999/)
  limS_N = (/0,9999/)
  limW_E = (/0,9999/)
  limPres = (/0,19/)
  limSoil = (/0,9999/)
  ; set default values for file_in, dir_in, and file_out, if not specified
  if (.not.isvar("file_in")) then
    ;file_in = "_file_in"
    file_in = "met_em.d01.1998-01-01.nc"
  end if
  if (.not.isvar("dir_in")) then
    ;dir_in = "_dir_in"
    dir_in = "./"
  end if
  if (.not.isvar("file_out")) then
    ;file_out = "_file_out"
    file_out = "met_em-cf.nc"
  end if
  if (.not.isvar("dir_out")) then
    ;dir_out = "_dir_out"
    dir_out = "./"
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Note:  Not all of the indicated values below can be extracted / 
  ;        converted from a given met_em file.  Some of the fields are
  ;        included with only specific physics options.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; output settings
  axis                       = True      ;one-dimensional coordinat fields
  projection                 = False     ;CF projection info with fields
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; time / date variables
  outDateTime                = True      ;include a yyyymmddhh field
  outUTCDate                 = True      ;include yr,mo,dy,hr,mn fields
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional near-surface / surface met variables
  out2dMet                   = True
  out2dMet@SST               = True      ;sea-surface temperature
  out2dMet@T_sfc             = True      ;temperature at the surface
  out2dMet@p_sfc             = True      ;pressure at the surface
  out2dMet@slp               = True      ;sea-level pressure
  out2dMet@T_2m              = True      ;temperature at 2 m
  out2dMet@rh_2m             = True      ;relative humidity at 2 m
  out2dMet@q_2m              = True      ;mixing ratio at 2 m
  out2dMet@u_10m_gr          = True      ;u-component at 10 m (grid)
  out2dMet@v_10m_gr          = True      ;v-component at 10 m (grid)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface/soil variables
  out2dLandSoil              = False
  out2dLandSoil@SoilT_L      = False      ;soil temperature at lower boundary
  ;out2dLandSoil@SnowHgt      = False      ;snow height
  out2dLandSoil@SnowWater    = False      ;snow water equivalent
  out2dLandSoil@SeaIce       = True      ;sea ice flag
  out2dLandSoil@PrecipRate   = True      ; precipitation rate
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional upper-level (pressure) metorology variables
  outPressure                = True
  outPressure@Z_p            = True      ;geopotential height at pressure levels
  outPressure@T_p            = True      ;temperature at pressure levels
  outPressure@q_p            = True      ;mixing ratio at pressure levels
  outPressure@rh_p           = False     ;relative humidity at pressure levels
  outPressure@u_gr_p         = True      ;u wind in grid at pressure levels
  outPressure@v_gr_p         = True      ;v wind in grid at pressure levels
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional soil variables
  outSoil                    = True
  outSoil@SoilTemp           = True      ;temperature at soil levels
  outSoil@SoilMoist          = True      ;moisture at soil levels
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; open the input netcdf file (met_em file)
  met_em = addfile(dir_in+file_in+".nc","r")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; time coordinate
  ; -the time in met_em is in an odd character format
  TimeChar = met_em->Times 
  ; -determine the number of dimensions for time
  DimTimeChar = dimsizes(TimeChar)
  nTime = DimTimeChar(0)
  ; -convert the met_em time to a CF compliant time
  ;  "hours since 1901-01-01 00:00:00"
  time_in = wrf_times_c(TimeChar, 1) 
  ; -create an array indicating the year, month, day, hour, minute, second
  utc_date = floattoint(ut_calendar(time_in, 0))
  ; -create the final variable for time with the units selected
  time = (/ut_inv_calendar(utc_date(:,0), utc_date(:,1), utc_date(:,2),  \
                          utc_date(:,3), utc_date(:,4), utc_date(:,5),  \
                          TimeUnits, 0)/)  ;time
    time@long_name = "Time"
    time@standard_name = "time"
    time@units = TimeUnits
    time@calendar = "standard"
    time!0 = "time"
    time&time = time
  utc_date!0 = "time"                  ;utc_date
    utc_date&time = time
  year = utc_date(:,0)
    year@long_name = "Year"
    year!0 = "time"
    year&time = time
  month = utc_date(:,1)
    month@long_name = "Month"
    month!0 = "time"
    month&time = time
  day = utc_date(:,2)
    day@long_name = "Day"
    day!0 = "time"
    day&time = time
  hour = utc_date(:,3)
    hour@long_name = "Hour"
    hour!0 = "time"
    hour&time = time
  minute = utc_date(:,4)
    minute@long_name = "Minutes"
    minute!0 = "time"
    minute&time = time
  ; -convert the met_em time to a DateTime integer for easy reading
  if (outDateTime) then
    DateTime = (/wrf_times_c(TimeChar, 3)/) ;time
      DateTime@long_name = "Date and Time"
      DateTime!0   = "time"
      DateTime&time = time
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; read in the general 3-dimension state variables
  p_in = (/met_em->PRES/)/100.
  T_in = (/met_em->TT/)
  rh_in = (/met_em->RH/)
  u_in = (/met_em->UU/)
  v_in = (/met_em->VV/)
  ; create post-processed values
  q_in = mixhum_ptrh(p_in, T_in, rh_in, 1)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; vertical variables / coordinates
  ; Note:  pressure levels are assigned in the beginning section
  if (outPressure) then
    p_tmp = p_in(0,:,0,0)
      nPressure = dimsizes(p_tmp)-1 ;pressure vertical coordinate
      pressure = p_tmp(1:nPressure)
      pressure@long_name = "Pressure Levels"
      pressure@standard_name = "air_pressure"
      pressure@units = "hPa"
      pressure@positive = "down"
      pressure!0 = "pressure"
      pressure&pressure = pressure
  end if
  if (outSoil) then
    soil = (/met_em->SOIL_LAYERS(0,:,0,0)/)           ;depths of center of soil layers
      nSoil = dimsizes(soil)
      soil@long_name = "Soil Levels (depth)"
      soil@standard_name = "depth"
      soil@units = "m"
      soil@positive = "down"
      soil!0 = "soil"
      soil&soil = soil
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional mapping variables
  lat = (/met_em->XLAT_M(0,:,:)/)        ;lat (mass)
    DimLat = dimsizes(lat)
    nS_N = DimLat(0)           ;S_N dimension
    nW_E = DimLat(1)           ;W_E dimension
    lat@long_name = "Latitude"
    lat@standard_name = "latitude"
    lat@units = "degrees_north"
    lat!0 = "south_north"
    lat!1 = "west_east"
  lon = (/met_em->XLONG_M(0,:,:)/)       ;lon (mass)
    lon@long_name = "Longitude"
    lon@standard_name = "longitude"
    lon@units = "degrees_east"
    lon!0 = "south_north"
    lon!1 = "west_east"
  Z_sfc = (/met_em->HGT_M(0,:,:)/)       ;Z_sfc
    Z_sfc@long_name = "Terrain Height"
    Z_sfc@standard_name = "height"
    Z_sfc@units = "m"
    Z_sfc@coordinates = "lon lat"
    Z_sfc!0 = "south_north"
    Z_sfc!1 = "west_east"
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; one-dimensional coordinate system
  if (axis) then
    south_north = ispan(0,nS_N-1,1)      ;south_north
      south_north@long_name = "y-coordinate in Cartesian system"
      south_north@axis = "Y"
      south_north@units = "m"
      south_north!0 = "south_north"
    west_east = ispan(0,nW_E-1,1)        ;west_east
      west_east@long_name = "x-coordinate in Cartesian system"
      west_east@axis = "X"
      west_east@units = "m"
      west_east!0 = "west_east"
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional near-surface / surface met variables
  if (out2dMet) then
    if (out2dMet@SST .and. isfilevar(met_em, "SST")) then
      SST = (/met_em->SST/)                ;SST
        SST@long_name = "Sea-Surface Temperature"
        SST@standard_name = "sea_surface_temperature"
        SST@units = "K"
        assignVarAttCoord(SST,time,0,0)
    end if
    if (out2dMet@T_sfc) then
      T_sfc = (/met_em->SKINTEMP/)              ;T_sfc
        T_sfc@long_name = "Temperature at the Surface"
        T_sfc@standard_name = "surface_temperature"
        T_sfc@units = "K"
        assignVarAttCoord(T_sfc,time,0,0)
    end if
    if (out2dMet@p_sfc) then
      p_sfc = (/met_em->PSFC/)/100.        ;p_sfc
        p_sfc@long_name = "Pressure at the Surface"
        p_sfc@standard_name = "surface_air_pressure"
        p_sfc@units = "hPa"
        assignVarAttCoord(p_sfc,time,0,0)
    end if
    if (out2dMet@T_2m) then
      T_2m = T_in(:,0,:,:) - 273.15           ;T_2m
        T_2m@long_name = "Temperature at 2 m"
        T_2m@standard_name = "air_temperature"
        T_2m@units = "degC"
        assignVarAttCoord(T_2m,time,0,0)
    end if
    if (out2dMet@rh_2m) then
      rh_2m = rh_in(:,0,:,:)                        ;rh_2m
        rh_2m@long_name = "Relative Humidity at 2 m"
        rh_2m@standard_name = "relative_humidity"
        rh_2m@units = "percent"
        assignVarAttCoord(rh_2m,time,0,0)
    end if
    if (out2dMet@q_2m) then
      q_2m = q_in(:,0,:,:)                          ;q_2m
        q_2m@long_name = "Mixing Ratio at 2 m"
        q_2m@standard_name = "humidity_mixing_ratio"
        q_2m@units = "kg kg-1"
        assignVarAttCoord(q_2m,time,0,0)
    end if
    if (out2dMet@u_10m_gr) then
      u_10m_gr = new((/nTime,nS_N,nW_E/), float, "No_FillValue")
      do t = 0, nTime-1
        u_10m_gr(t,:,:) = wrf_user_unstagger(u_in(t,0,:,:),"X")
      end do
        u_10m_gr@long_name = "u-Component at 10 m (grid)"
        u_10m_gr@standard_name = "eastward_wind"
        u_10m_gr@units = "m s-1"
        assignVarAttCoord(u_10m_gr,time,0,0)
    end if
    if (out2dMet@v_10m_gr) then
      v_10m_gr = new((/nTime,nS_N,nW_E/), float, "No_FillValue")
      do t = 0, nTime-1
        v_10m_gr(t,:,:) = wrf_user_unstagger(v_in(t,0,:,:),V@stagger)
      end do
        v_10m_gr@long_name = "v-Component at 10 m (grid)"
        v_10m_gr@standard_name = "northward_wind"
        v_10m_gr@units = "m s-1"
        assignVarAttCoord(v_10m_gr,time,0,0)
    end if
    if (out2dMet@slp) then
      slp = (/met_em->PMSL/)/100.              ; slp
        slp@long_name = "Sea-Level Pressure"
        slp@standard_name = "air_pressure_at_sea_level"
        slp@units = "hPa"
        assignVarAttCoord(slp,time,0,0)
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional upper-level (pressure) metorology variables
  if (outPressure) then
    if (outPressure@Z_p) then
      Z_p = (/met_em->GHT(:,1:nPressure,:,:)/)              ;Z_p
        Z_p@long_name = "Geopotential Height at Pressure Levels"
        Z_p@standard_name = "geopotential_height"
        Z_p@units = "m"
        Z_p@_FillValue = -999999
        assignVarAttCoord(Z_p,time,pressure,1)
    end if
    if (outPressure@T_p) then
      T_p = T_in(:,1:nPressure,:,:)                        ;T_p
        T_p@long_name = "Temperature at Pressure Levels"
        T_p@standard_name = "air_temperature"
        T_p@units = "K"
        T_p@_FillValue = -999999
        assignVarAttCoord(T_p,time,pressure,1)
    end if
    if (outPressure@rh_p) then
      rh_p = rh_in(:,1:nPressure,:,:)                      ;rh_p
        rh_p@long_name = "Relative Humidity at Pressure Levels"
        rh_p@standard_name = "relative_humidity"
        rh_p@units = "percent"
        assignVarAttCoord(rh_p,time,pressure,1)
    end if
    if (outPressure@q_p) then
      q_p = q_in(:,1:nPressure,:,:)                        ;q_p
        q_p@long_name = "Mixing Ratio at Pressure Levels"
        q_p@standard_name = "humidity_mixing_ratio"
        q_p@units = "kg kg-1"
        q_p@_FillValue = -999999
        assignVarAttCoord(q_p,time,pressure,1)
    end if
    if (outPressure@u_gr_p) then
      u_gr_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue") ;u_gr_p
      do t = 0, nTime-1
        do p = 1, nPressure
          u_gr_p(t,p,:,:) = wrf_user_unstagger(u_in(t,p,:,:),U@stagger)
        end do
      end do
      u_gr_p@long_name = "u-Component at Pressure Levels (grid)"
        u_gr_p@standard_name = "eastward_wind"
        u_gr_p@units = "m s-1"
        assignVarAttCoord(u_gr_p,time,pressure,1)            ;u_gr_p
    end if
    if (outPressure@v_gr_p) then
      v_gr_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue") ;v_gr_p
      do t = 0, nTime-1
        do p = 1, nPressure
          v_gr_p(t,p,:,:) = wrf_user_unstagger(v_in(t,p,:,:),V@stagger)
        end do
      end do
      v_gr_p@long_name = "v-Component at Pressure Levels (grid)"
        v_gr_p@standard_name = "northward_wind"
        v_gr_p@units = "m s-1"
        assignVarAttCoord(v_gr_p,time,pressure,1)            ;v_gr_p
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface/soil variables
  if (out2dLandSoil) then
    if (out2dLandSoil@SoilT_L) then
      SoilT_L = (/met_em->SOILTEMP/)        ;soil temperature at lower boundary
        SoilT_L@long_name = "Annual Mean Deep Soil Temperature"
        SoilT_L@standard_name = "soil_temperature"
        SoilT_L@units = "K"
        assignVarAttCoord(SoilT_L,time,0,0)
    end if
    if (out2dLandSoil@SnowWater) then
      SnowWater = (/met_em->SNOW/)         ;snow water equivalent
        SnowWater@long_name = "Snow Water Equivalent"
        SnowWater@standard_name = "surface_snow_amount"
        SnowWater@units = "kg m-2"
        assignVarAttCoord(SnowWater,time,0,0)
    end if
; for NCEP2 precip:
    if ((out2dLandSoil@PrecipRate) .and. isfilevar(met_em, "PRATE")) then
      PrecipRate = (/met_em->PRATE/)         ;precipitation rate
        PrecipRate@long_name = "Precipitation Rate"
        PrecipRate@standard_name = "precipitation_rate"
        PrecipRate@units = "kg m-2 s-1"
        assignVarAttCoord(PrecipRate,time,0,0)
    end if
; for ERA-Interim precip:
    if ((out2dLandSoil@PrecipRate) .and. isfilevar(met_em, "TP")) then
      PrecipRate = (/met_em->TP/)         ;precipitation rate
        PrecipRate@long_name = "Total Accumulated Precip"
        PrecipRate@standard_name = "accumulated_precip"
        PrecipRate@units = "m"
        assignVarAttCoord(PrecipRate,time,0,0)
    end if
    if ((out2dLandSoil@SeaIce) .and. isfilevar(met_em, "SEAICE")) then
      SeaIce = (/met_em->SEAICE/)          ;sea ice flag
        SeaIce@long_name = "Sea Ice Flag"
        SeaIce@standard_name = "seaice_binary_mask"
        SeaIce@units = ""
        SeaIce@notes = "1=seaice, 0=water"
        assignVarAttCoord(SeaIce,time,0,0)
    else
      if ((out2dLandSoil@SeaIce) .and. isfilevar(met_em, "XICE")) then
        SeaIce = (/met_em->XICE/)          ;sea ice flag
          SeaIce@long_name = "Sea Ice Flag"
          SeaIce@standard_name = "seaice_binary_mask"
          SeaIce@units = ""
          SeaIce@notes = "1=seaice, 0=water"
          assignVarAttCoord(SeaIce,time,0,0)
      end if
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional soil variables
  ;   (variables on staggered soil levels)
  if (outSoil) then
    if (outSoil@SoilTemp) then
      SoilTemp = (/met_em->ST/)          ;soil temperature
        SoilTemp@long_name = "Soil Temperature"
        SoilTemp@standard_name = "soil_temperature"
        SoilTemp@units = "K"
        assignVarAttCoord(SoilTemp,time,soil,3)
    end if
    if (outSoil@SoilMoist) then
      SoilMoist = (/met_em->SM/)        ;soil moisture
        SoilMoist@long_name = "Soil Moisture"
        SoilMoist@standard_name = "soil_moisture_content"
        SoilMoist@units = "m3 m-3"
        assignVarAttCoord(SoilMoist,time,soil,3)
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;check the limits for the output arrays, set 9999 to end of dataset
  if (limTime(1) .eq. 9999) then
    limTime(1) = nTime-1
  end if
  if (limS_N(1) .eq. 9999) then 
    limS_N(1) = nS_N-1
  end if
  if (limW_E(1) .eq. 9999) then 
    limW_E(1) = nW_E-1
  end if
  if (outPressure) then
    if (limPres(1) .eq. 9999) then 
      limPres(1) = nPressure-1
    end if
  end if
  if (outSoil) then
    if (limSoil(1) .eq. 9999) then 
      limSoil(1) = nSoil-1
    end if
  end if
  ;create filename and open post-processed netCDF file 
  if isfilepresent(dir_out+file_out) then
    system ("rm "+dir_out+file_out)             ;remove any pre-exisiting file
  end if
  met_em_cf = addfile(dir_out+file_out,"c")    ;create new netCDF file
  filedimdef (met_em_cf, "time", nTime, True)
  ; create the global attributes
  ; establish a variable for a new line in the attributes
  nl = integertochar(10)  ; newline character
  fileAtt                = True
  fileAtt@creation_date  =  systemfunc("date")
  fileAtt@institution = "University of Colorado at Boulder - CIRES"
  fileAtt@created_by = "Matthew Higgins - matthew.higgins@colorado.edu"
  fileAtt@notes = "Created with NCL script:  met_em_to_cf.ncl v1.0.0a"
  fileAtt@source         = file_in
  fileAtt@Conventions    = "CF-1.0"
  fileAtt@title          = file_out
  fileattdef(met_em_cf, fileAtt)
  ;write post-processed WRF data to netCDF file
  ; -date and time variables
  met_em_cf->time=time(limTime(0):limTime(1))
  if (outDateTime) then
    met_em_cf->DateTime=DateTime(limTime(0):limTime(1))
  end if
  if (outUTCDate) then
    met_em_cf->year = year(limTime(0):limTime(1))
    met_em_cf->month = month(limTime(0):limTime(1))
    met_em_cf->day = day(limTime(0):limTime(1))
    met_em_cf->hour = hour(limTime(0):limTime(1))
    met_em_cf->minute = minute(limTime(0):limTime(1))
  end if
  ; -vertical coordinate variables
  if (outPressure) then
    met_em_cf->pressure=pressure(limPres(0):limPres(1))
  end if
  if (outSoil) then
    met_em_cf->soil=soil(limSoil(0):limSoil(1))
  end if
  ; -one-dimensional coordinate variables
  if (axis) then
    met_em_cf->south_north=south_north(limS_N(0):limS_N(1))
    met_em_cf->west_east=west_east(limW_E(0):limW_E(1))
  end if
  ; -two-dimensional mapping variables
    met_em_cf->lat=lat(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    met_em_cf->lon=lon(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    met_em_cf->Z_sfc=Z_sfc(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
  ; -two-dimensional near-surface / surface met variables
  if (out2dMet) then
    if (isvar("SST")) then
      met_em_cf->SST=SST(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                       limW_E(0):limW_E(1))
    end if
    if (isvar("T_sfc")) then
      met_em_cf->T_sfc=T_sfc(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("p_sfc")) then
      met_em_cf->p_sfc=p_sfc(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("slp")) then
        met_em_cf->slp=slp(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("T_2m")) then
      met_em_cf->T_2m=T_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("rh_2m")) then
      met_em_cf->rh_2m=rh_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("q_2m")) then
      met_em_cf->q_2m=q_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("u_10m_gr")) then
      met_em_cf->u_10m_gr=u_10m_gr(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("v_10m_gr")) then
      met_em_cf->v_10m_gr=v_10m_gr(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
  end if
  ; -three-dimensional upper-level (pressure) meteorology variables
  if (outPressure) then
    if (isvar("Z_p")) then
      met_em_cf->Z_p=Z_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("T_p")) then
      met_em_cf->T_p=T_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_p")) then
      met_em_cf->q_p=q_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("rh_p")) then
      met_em_cf->rh_p=rh_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                         limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("u_gr_p")) then
      met_em_cf->u_gr_p=u_gr_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("v_gr_p")) then
      met_em_cf->v_gr_p=v_gr_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
  end if
  ; -two-dimensional surface / soil variables
  if (out2dLandSoil) then
    if (isvar("SoilT_L")) then
      met_em_cf->SoilT_L=SoilT_L(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if (isvar("SnowHgt")) then
      met_em_cf->SnowHgt=SnowHgt(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if (isvar("SnowWater")) then
      met_em_cf->SnowWater=SnowWater(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                   limW_E(0):limW_E(1))
    end if
    if (isvar("PrecipRate")) then
      met_em_cf->PrecipRate=PrecipRate(limTime(0):limTime(1),limS_N(0):limS_N(1), \
                                   limW_E(0):limW_E(1))
    end if
    if isvar("SeaIce") then
      met_em_cf->SeaIce=SeaIce(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                             limW_E(0):limW_E(1))
    end if
  end if
  ; -three-dimensional soil variables
  if (outSoil) then
    if (isvar("SoilTemp")) then
      met_em_cf->SoilTemp=SoilTemp(limTime(0):limTime(1),limSoil(0):limSoil(1),  \
                                 limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("SoilMoist")) then
     met_em_cf->SoilMoist=SoilMoist(limTime(0):limTime(1),limSoil(0):limSoil(1), \
                                   limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
  end if
end 
