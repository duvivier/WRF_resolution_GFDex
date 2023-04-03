;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wrfout_to_nc.ncl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -NCL script to read an ARW wrfout NetCDF file on staggered model
;  grid and to output unstaggered values in NetCDF CF compliant format
; -
; -Assistance in creating the original script was provided by Dennis Shea
;
; command syntax:
;   ncl 'file_in="wrfout.nc"' 'file_out="wrfpost.nc"' wrfout_to_cf.ncl
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
; -There are two slp calculations included in this script.  The first (slp_a) 
;  is based on the slp calculation which is a part of the wrf_ncl programs.
;  The second (slp_b) is based on a calculation using only the lowest model
;  level.  If only one of the two are selected, the netcdf output variable
;  is slp.  If both are selected then the output variables are slp_a and slp_b.
;
; Support information:
;  This script is semi-supported based on the available time that I have.  If
;  you come across an error or have an idea for an improvement, please let me
;  know.  I will update the script on a time available basis.  Send all 
;  inquiries or questions to: Mark Seefeldt - mark.seefeldt@colorado.edu
;
; Ver. 1.0.0 - May 2, 2008
;      1.0.1 - May 6, 2008
;       -several minor changes including the handling of lat/lon to make
;        the output CF compliant
;      1.1.0 - May 21, 2008
;       -change the input to use the (/.../) to strip all attributes/coords.
;       -added sub-procedure to add basic attributes
;       -re-ordered the attributes for each variable
;       -added the output variables (i.e. out2dMet, outPressure) to allow
;        the user to select the variables which they want processed/output
;       -add if-then-endif for all of the output variables
;     1.1.1 - August 1, 2008
;       -fixed a mistake by adding the general parameters (i.e. outEta) to 
;        additional flags in determining the output
;     1.1.2 - October 31, 2008
;       -added more comments to identify the different fields
;       -added a new method to calculate slp, referred to as slp_b
;     1.1.3 - March 25, 2009
;       -incorporated missing values for pressure level variables (_p)
;          -contributed by Petteri Uotila
;       -added the calculation of IWP and LWP
;     1.1.4 - ???
;       -fixed bug with UTC date variable type conversion
;       -added the field XICE as a secondary wrfout variable for seaice
;       -added the calculation of grid and cumulus precip in 6-hour intervals
;        TODO - needs to be finalized
;
;  Todo:
;       -remove the dimension included with p_top
;       -add true u and v as output options
;       -add ws and wd as output options at all levels (including 10 m)
;       -allow for 6-hour precip with time units other than hours
;       -add CF compliant projection information
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the libraries
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

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
; start the primary wrfout_to_cf.ncl program
begin
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; configuration settings
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the units for time
  TimeUnits = "hours since 2001-01-01 00:00:00"
  ; set the values for pressure to be interpolated
  pressure = (/1000.,950.,900.,850.,800.,700.,500.,300./)
  ; set the limits for the output range
  ;   0 = beginning of dataset
  ;   9999 = end of dataset
  ;   Note: remember that the array is zero-based
  limTime = (/0,9999/)
  limS_N = (/0,9999/)
  limW_E = (/0,9999/)
  limPres = (/0,9999/)
  limEta = (/0,9999/)
  limSoil = (/0,9999/)
  ; set default values for file_in, dir_in, and file_out, if not specified
  if (.not.isvar("file_in")) then
    file_in = "_file_in"
    ;file_in = "wrfout_d01_1997-12-31_00:00:00"
  end if
  if (.not.isvar("dir_in")) then
    ;dir_in = "_dir_in"
    dir_in = "./"
  end if
  if (.not.isvar("file_out")) then
    file_out = "_file_out"
    ;file_out = "wrfpost.nc"
  end if
  if (.not.isvar("dir_out")) then
    ;dir_out = "_dir_out"
    dir_out = "./"
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Note:  Not all of the indicated values below can be extracted / 
  ;        converted from a given wrfout file.  Some of the fields are
  ;        included with only specific physics options.
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; output settings
  axis                       = True      ;one-dimensional coordinat fields
  projection                 = False     ;CF projection info with fields
  outPtop                    = False     ;include Ptop in the output file
  ;MissingValue               = -999999   ;missing value
  ; Note: MissingValue is currently assigned in the procedure assignVarAttCoord
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; time / date variables
  outDateTime                = True      ;include a yyyymmddhh field
  outUTCDate                 = True      ;include yr,mo,dy,hr,mn fields
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional near-surface / surface met variables
  out2dMet                   = True
  out2dMet@SST               = True      ;sea-surface temperature
  out2dMet@T_sfc             = True      ;temperature at the surface
  out2dMet@p_sfc             = False      ;pressure at the surface
  out2dMet@slp_a             = True      ;sea-level pressure - using WRF-NCL
  out2dMet@slp_b             = False      ;sea-level pressure - lowest eta level
  out2dMet@T_2m              = True      ;temperature at 2 m
  out2dMet@Td_2m             = False      ;dew point at 2 m
  out2dMet@Th_2m             = True      ;potential temperature at 2 m
  out2dMet@q_2m              = True     ;mixing ratio at 2 m
  out2dMet@u_10m_gr          = True      ;u-component at 10 m (grid)
  out2dMet@v_10m_gr          = True      ;v-component at 10 m (grid)
  out2dMet@u_10m_tr          = True      ;u-component at 10 m (true)
  out2dMet@v_10m_tr          = True      ;v-component at 10 m (true)
  out2dMet@precip_g          = False      ;total grid scale precipitation
  out2dMet@precip_c          = False     ;total cumulus precipitation
  out2dMet@precip_6h_g       = False     ;grid scale precipitation @ 6h int
  out2dMet@precip_6h_c       = False     ;cumulus precipitation @ 6h int
  out2dMet@dryairmass        = False      ;total dry air mass in column
  out2dMet@pblh              = False      ;PBL height
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface energy budget / radiation variables
  out2dRadFlx                = True
  out2dRadFlx@SW_d           = True      ;shortwave flux - downward - surface
  out2dRadFlx@LW_d           = True      ;longwave flux - downward - surface
  out2dRadFlx@LW_toa         = True      ;longwave flux - outgoing - TOA
  out2dRadFlx@albedo         = True      ;albedo
  out2dRadFlx@SHFlx          = True      ;sensible heat flux - upward - surface
  out2dRadFlx@LHFlx          = True      ;latent heat flux - upward - surface
  out2dRadFlx@MFlx           = True      ;moisture heat flux - upward - surface
  out2dRadFlx@u_star         = True      ;friction velocity (u*)
  out2dRadFlx@LWP            = False     ;liquid water path
  out2dRadFlx@IWP            = False     ;ice water path
  out2dRadFlx@emiss_sfc      = False     ;surface emissivity
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface/soil variables
  out2dLandSoil              = True
  out2dLandSoil@LandMask     = True      ;land mask (1 - land, 0 - water)
  out2dLandSoil@LandUse      = False      ;land use category
  out2dLandSoil@SoilT_L      = False      ;soil temperature at lower boundary
  out2dLandSoil@SoilT_B      = False      ;bottom soil temperature
  out2dLandSoil@GroundFlx    = True      ;ground heat flux
  out2dLandSoil@SnowHgt      = False      ;snow height
  out2dLandSoil@SnowWater    = False      ;snow water equivalent
  out2dLandSoil@SnowDens     = False      ;snow density
  out2dLandSoil@SnowFlx      = False      ;snow phase change heat flux
  out2dLandSoil@SeaIce       = True      ;sea ice flag
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional upper-level (pressure) metorology variables
  outPressure                = True
  outPressure@Z_p            = True      ;geopotential height at pressure levels
  outPressure@T_p            = True      ;temperature at pressure levels
  outPressure@Th_p           = True      ;potential temperature at pressure levels
  outPressure@q_p            = True      ;mixing ratio at pressure levels
  outPressure@rh_p           = False     ;relative humidity at pressure levels
  outPressure@u_gr_p         = True      ;u wind in grid at pressure levels
  outPressure@v_gr_p         = True      ;v wind in grid at pressure levels
  outPressure@u_tr_p         = True      ;u wind in true at pressure levels (rotated) 
  outPressure@v_tr_p         = True      ;v wind in true at pressure levels (rotated)
  outPressure@w_p            = False     ;w wind at pressure levels
  outPressure@pp_p           = False     ;pressure pert. at pressure levels
  outPressure@q_cloud_p      = False     ;cloud mixing ratio at pressure levels
  outPressure@q_rain_p       = False     ;rain mixing ratio at pressure levels
  outPressure@q_ice_p        = False     ;ice mixing ratio at pressure levels
  outPressure@q_snow_p       = False     ;snow mixing ratio at pressure levels
  outPressure@q_graup_p      = False     ;graupel mixing ratio at pres. levels
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional upper-level (eta) metorology variables
  outEta                     = True
  outEta@p_e                 = True     ;pressure at eta levels
  outEta@Z_e                 = True     ;geopotential height at eta levels
  outEta@T_e                 = True     ;temperature at eta levels
  outEta@Th_e                = True     ; potential temperature at eta levels
  outEta@q_e                 = True     ;mixing ratio at eta levels
  outEta@rh_e                = False    ;relative humidity at eta levels
  outEta@u_gr_e              = True     ;u wind in grid at eta levels
  outEta@v_gr_e              = True     ;v wind in grid at eta levels
  outEta@u_tr_e              = True     ;u wind in true at eta levels (rotated)
  outEta@v_tr_e              = True     ;v wind in true at eta levels (rotated)
  outEta@w_e                 = True     ;w wind at eta levels
  outEta@pp_e                = False     ;pressure pert. at eta levels
  outEta@q_cloud             = False     ;cloud mixing ratio
  outEta@q_rain              = False     ;rain mixing ratio
  outEta@q_ice               = False     ;ice mixing ratio
  outEta@q_snow              = False     ;snow mixing ratio
  outEta@q_graup             = False     ;graupel mixing ratio
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional soil variables
  outSoil                    = False
  outSoil@SoilTemp           = True      ;temperature at soil levels
  outSoil@SoilMoist          = True      ;moisture at soil levels
  outSoil@SoilWater          = True      ;water at soil levels
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; open the input netcdf file (wrfout file)
  wrfout = addfile(dir_in+file_in+".nc","r")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; time coordinate
  ; -the time in wrfout is in an odd character format
  TimeChar = wrfout->Times 
  ; -determine the number of dimensions for time
  DimTimeChar = dimsizes(TimeChar)
  nTime = DimTimeChar(0)
  ; -convert the wrfout time to a CF compliant time
  ;  "hours since 1901-01-01 00:00:00"
  time_in = wrf_times_c(TimeChar, 1) 
  ; -create an array indicating the year, month, day, hour, minute, second
  utc_date = doubletoint(ut_calendar(time_in, 0))
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
  ; -convert the wrfout time to a DateTime integer for easy reading
  if (outDateTime) then
    DateTime = (/wrf_times_c(TimeChar, 3)/) ;time
      DateTime@long_name = "Date and Time"
      DateTime!0   = "time"
      DateTime&time = time
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; vertical variables / coordinates
  ; Note:  pressure levels are assigned in the beginning section
  if (outPressure) then
    nPressure = dimsizes(pressure)       ;pressure vertical coordinate
      pressure@long_name = "Pressure Level"
      pressure@standard_name = "air_pressure"
      pressure@units = "hPa"
      pressure@positive = "down"
      pressure!0 = "pressure"
      pressure&pressure = pressure
  end if
  if (outEta .or. outPressure)
    eta = (/wrfout->ZNU(0,:)/)           ;eta values on half-levels (mass)
      nEta = dimsizes(eta)
      eta@long_name = "Eta Level (mass point)"
      eta@standard_name = "atmosphere_sigma_coordinate"
      eta@units = "1"
      eta@positive = "down"
      eta@formula_terms = "sigma: eta ps: p_sfc ptop: p_top"
      eta!0 = "eta"
      eta&eta = eta
  end if
  if (outSoil) then
    soil = (/wrfout->ZS(0,:)/)           ;depths of center of soil layers
      nSoil = dimsizes(soil)
      soil@long_name = "Soil Level (depth)"
      soil@standard_name = "depth"
      soil@units = "m"
      soil@positive = "down"
      soil!0 = "soil"
      soil&soil = soil
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; one-dimensional general model variables
  if (outPtop .or. outEta) then
    p_top_in = (/wrfout->P_TOP/)/100.    ;pressure at top of model
    ;in some files P_TOP has two dimensions, in some it has one dimension
    if ((dimsizes(dimsizes(p_top_in))) .eq. 2) then
      p_top = p_top_in(0,0)
    else
      p_top = p_top_in(0)
    end if
    p_top@long_name = "Pressure at Top of the Model"
    p_top@standard_name = "air_pressure"
    p_top@units = "hPa"
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional mapping variables
  lat = (/wrfout->XLAT(0,:,:)/)        ;lat (mass)
    DimLat = dimsizes(lat)
    nS_N = DimLat(0)           ;S_N dimension
    nW_E = DimLat(1)           ;W_E dimension
    lat@long_name = "Latitude"
    lat@standard_name = "latitude"
    lat@units = "degrees_north"
    lat!0 = "south_north"
    lat!1 = "west_east"
  lon = (/wrfout->XLONG(0,:,:)/)       ;lon (mass)
    lon@long_name = "Longitude"
    lon@standard_name = "longitude"
    lon@units = "degrees_east"
    lon!0 = "south_north"
    lon!1 = "west_east"
  Z_sfc = (/wrfout->HGT(0,:,:)/)       ;Z_sfc
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
    if (out2dMet@SST) then
      SST = (/wrfout->SST/)                ;SST
        SST@long_name = "Sea-Surface Temperature"
        SST@standard_name = "sea_surface_temperature"
        SST@units = "K"
        assignVarAttCoord(SST,time,0,0)
    end if
    if (out2dMet@T_sfc) then
      T_sfc = (/wrfout->TSK/)              ;T_sfc
        T_sfc@long_name = "Temperature at the Surface"
        T_sfc@standard_name = "surface_temperature"
        T_sfc@units = "K"
        assignVarAttCoord(T_sfc,time,0,0)
    end if
    if (out2dMet@p_sfc) then
      p_sfc = (/wrfout->PSFC/)/100.        ;p_sfc
        p_sfc@long_name = "Pressure at the Surface"
        p_sfc@standard_name = "surface_air_pressure"
        p_sfc@units = "hPa"
        assignVarAttCoord(p_sfc,time,0,0)
    end if
    if (out2dMet@T_2m) then
      T_2m = (/wrfout->T2/) - 273.15       ;T_2m
        T_2m@long_name = "Temperature at 2 m"
        T_2m@standard_name = "air_temperature"
        T_2m@units = "degC"
        assignVarAttCoord(T_2m,time,0,0)
    end if
    if (out2dMet@Th_2m) then
      Th_2m = (/wrfout->TH2/)              ;Th_2m
        Th_2m@long_name = "Potential Temperature at 2 m"
        Th_2m@standard_name = "air_potential_temperature"
        Th_2m@units = "K"
        assignVarAttCoord(Th_2m,time,0,0)
    end if
    if (out2dMet@q_2m) then
      q_2m = (/wrfout->Q2/)                ;q_2m
        q_2m@long_name = "Mixing Ratio at 2 m"
        q_2m@standard_name = "humidity_mixing_ratio"
        q_2m@units = "kg kg-1"
        assignVarAttCoord(q_2m,time,0,0)
    end if
    if (out2dMet@u_10m_gr) then
      u_10m_gr = (/wrfout->U10/)           ;u_10m_gr
        u_10m_gr@long_name = "u-Component at 10 m (grid)"
        u_10m_gr@standard_name = "eastward_wind"
        u_10m_gr@units = "m s-1"
        assignVarAttCoord(u_10m_gr,time,0,0)
    end if
    if (out2dMet@v_10m_gr) then
      v_10m_gr = (/wrfout->V10/)           ;v_10m_gr
        v_10m_gr@long_name = "v-Component at 10 m (grid)"
        v_10m_gr@standard_name = "northward_wind"
        v_10m_gr@units = "m s-1"
        assignVarAttCoord(v_10m_gr,time,0,0)
    end if
   if (out2dMet@precip_g .or. out2dMet@precip_6h_g) then
      precip_g = (/wrfout->RAINNC/)        ;accumulated total grid scale precip
        precip_g@long_name = "Accumulated Total Grid Scale Precipitation"
        precip_g@standard_name = "large_scale_precipitation_amount"
        precip_g@units = "mm"
        assignVarAttCoord(precip_g,time,0,0)
    end if
    if (out2dMet@precip_c .or. out2dMet@precip_6h_c) then
      precip_c = (/wrfout->RAINC/)         ;accumulated total cumulus precip
        precip_c@long_name = "Accumulated Total Cumulus Precipitation"
        precip_c@standard_name = "convective_precipitation_amount"
        precip_c@units = "mm"
        assignVarAttCoord(precip_c,time,0,0)
    end if
    if (out2dMet@dryairmass) then
      dryairmass = ((/wrfout->MU/)+(/wrfout->MUB/))/100.   ;total dry air mass in column
        dryairmass@long_name = "Total Dry Air Mass in Column"
        dryairmass@standard_name = "dry_air_mass"
        dryairmass@units = "hPa"
        assignVarAttCoord(dryairmass,time,0,0)
    end if
    if (out2dMet@pblh) then
      pblh = (/wrfout->PBLH/)               ;PBL height
        pblh@long_name = "PBL Height"
        pblh@standard_name = "pbl_height"
        pblh@units = "m"
        assignVarAttCoord(pblh,time,0,0)
    end if
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; two-dimensional near-surface / surface met variables (calculated)
    if (out2dMet@slp_b) then
      ; Note: This is an alternative method to calculate slp based on 
      ;       the temperature, moisture, and height of the lowest model level.
      ;       There is no certainty that this is any better, and possibly 
      ;       worse than what is used in slp_a
      ; -create the variable
      slp_b = new((/nTime,nS_N,nW_E/), "float", "No_FillValue")    ;slp
      ; -loop through the nTimes
      do n = 0, nTime-1
        ; -create new variables for what is needed to calculate slp
        T_eta = new((/nEta,nS_N,nW_E/), double, "No_FillValue")
        q_eta = new((/nEta,nS_N,nW_E/), double, "No_FillValue")
        p_eta = new((/nEta,nS_N,nW_E/), double, "No_FillValue")
        Z_eta = new((/nEta,nS_N,nW_E/), double, "No_FillValue")
        temp_v = new((/nS_N,nW_E/), double, "No_FillValue")
        ; -read in the values needed for calculations
        T_eta = (/wrf_user_getvar(wrfout,"tk",n)/)
        p_eta = (/wrf_user_getvar(wrfout,"pressure",n)/)
        Z_eta = (/wrf_user_getvar(wrfout,"z",n)/)
        q_eta = (/wrfout->QVAPOR(n,:,:,:)/)
        ; -calculate the virtual temperature
        temp_v = (1.+(0.622*q_eta(0,:,:)))*T_eta(0,:,:)
        ; -calculate the sea-level pressure using the virtual temperature of
        ;  the lowest model level
        slp_b(n,:,:) = p_eta(0,:,:)*exp((9.81*Z_eta(0,:,:))/(287.*temp_v))
      end do
      ; -set the attributes
      slp_b@long_name = "Sea-Level Pressure"
        slp_b@standard_name = "air_pressure_at_sea_level"
        slp_b@units = "hPa"
        assignVarAttCoord(slp_b,time,0,0)      ;slp
    end if
;    if (out2dMet@precip_6h_g) then
;      ; create variable
;      precip_6h_g = new((/nTime,nS_N,nW_E/), "float", "No_FillValue")
;      ; loop through the times
;      do n = 0, nTime-1
;
;      end do
;    end if

    ; calculate rotated 10m winds
   if (out2dMet@u_10m_tr .or. out2dMet@v_10m_tr) then 
     ; preallocate matrices
      uvm = new((/2,nTime,nS_N,nW_E/), "float", "No_FillValue")
      u_10m_tr = new((/nTime,nS_N,nW_E/), "float", "No_FillValue")
      v_10m_tr = new((/nTime,nS_N,nW_E/), "float", "No_FillValue")
     do n = 0, nTime-1
    ; calculate values
      uvm(:,n,:,:) = (/wrf_user_getvar(wrfout,"uvmet10",n)/)
      u_10m_tr(n,:,:) = uvm(0,n,:,:) ;u_10m_tr
      v_10m_tr(n,:,:) = uvm(1,n,:,:) ;v_10m_tr
     delete(uvm)
     end do
     ; set attributes
        u_10m_tr@long_name = "u-Component at 10 m (true)"
        u_10m_tr@standard_name = "eastward_wind"
        u_10m_tr@units = "m s-1"
        assignVarAttCoord(u_10m_tr,time,0,0)
        v_10m_tr@long_name = "v-Component at 10 m (true)"
        v_10m_tr@standard_name = "northward_wind"
        v_10m_tr@units = "m s-1"
        assignVarAttCoord(v_10m_tr,time,0,0)
   end if

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; two-dimensional near-surface / surface met variables (derived/diagnostic)
    ; -create variables
    if (out2dMet@slp_a) then
      slp_a = new((/nTime,nS_N,nW_E/), "float", "No_FillValue")    ;slp
    end if
    if (out2dMet@Td_2m) then
      Td_2m = new((/nTime,nS_N,nW_E/), "float", "No_FillValue")  ;Td_2m
    end if
    ; -read in the values using wrf_user_getvar
    do n = 0, nTime-1
      if (out2dMet@slp_a) then
        slp_a(n,:,:) = (/wrf_user_getvar(wrfout,"slp",n)/)
      end if
      if (out2dMet@Td_2m) then
        Td_2m(n,:,:) = (/wrf_user_getvar(wrfout,"td2",n)/)
      end if
    end do
    if (out2dMet@slp_a) then
      slp_a@long_name = "Sea-Level Pressure"
        slp_a@standard_name = "air_pressure_at_sea_level"
        slp_a@units = "hPa"
        assignVarAttCoord(slp_a,time,0,0)      ;slp
    end if
    if (out2dMet@Td_2m) then
      Td_2m@long_name = "Dewpoint Temperature at 2 m"
        Td_2m@standard_name = "dew_point_temperature"
        Td_2m@units = "degC"
        assignVarAttCoord(Td_2m,time,0,0)    ;Td_2m
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional upper-level (eta) metorology variables
  if (outEta .or. outPressure)
    if (outEta@pp_e .or. outPressure@pp_p) then
      pp_e = (/wrfout->P/)/100.                 ;pp_e
        pp_e@long_name = "Pressure Perturbation at Eta Levels"
        pp_e@standard_name = "pressure_perturbation"
        pp_e@units = "hPa"
        assignVarAttCoord(pp_e,time,eta,2)
    end if
    if (outEta@q_e .or. outPressure@q_p) then
      q_e = (/wrfout->QVAPOR/)                 ;q_e
        q_e@long_name = "Mixing Ratio - Water Vapor"
        q_e@standard_name = "humidity_mixing_ratio"
        q_e@units = "kg kg-1"
        assignVarAttCoord(q_e,time,eta,2)
    end if
    if (outEta@q_cloud .or. outPressure@q_cloud_p) then
      q_cloud = (/wrfout->QCLOUD/)             ;q_cloud
        q_cloud@long_name = "Mixing Ratio - Cloud"
        q_cloud@standard_name = "mass_fraction_of_cloud_condensed_water_in_air"
        q_cloud@units = "kg kg-1"
        assignVarAttCoord(q_cloud,time,eta,2)
    end if
    if (outEta@q_rain .or. outPressure@q_rain_p) then
      q_rain = (/wrfout->QRAIN/)               ;q_rain
        q_rain@long_name = "Mixing Ratio - Rain"
        q_rain@standard_name = "mass_fraction_of_rain_in_air"
        q_rain@units = "kg kg-1"
        assignVarAttCoord(q_rain,time,eta,2)
    end if
    if ((outEta@q_ice .or. outPressure@q_ice_p) .and.  \
         isfilevar(wrfout, "QICE")) then
      q_ice = (/wrfout->QICE/)
        q_ice@long_name = "Mixing Ratio - Ice"
        q_ice@standard_name = "mass_fraction_of_ice_in_air"
        q_ice@units = "kg kg-1"
        assignVarAttCoord(q_ice,time,eta,2)
    end if
    if ((outEta@q_snow .or. outPressure@q_snow_p) .and.  \
         isfilevar(wrfout, "QSNOW")) then
      q_snow = (/wrfout->QSNOW/)           ;q_snow
        q_snow@long_name = "Mixing Ratio - Snow"
        q_snow@standard_name = "mass_fraction_of_snow_in_air"
        q_snow@units = "kg kg-1"
        assignVarAttCoord(q_snow,time,eta,2)
    end if
    if ((outEta@q_graup .or. outPressure@q_graup_p) .and.  \
         isfilevar(wrfout, "QGRAUP")) then
      q_graup = (/wrfout->QGRAUP/)
        q_graup@long_name = "Mixing Ratio - Graupel"
        q_graup@standard_name = "mass_fraction_of_graupel_in_air"
        q_graup@units = "kg kg-1"
        assignVarAttCoord(q_graup,time,eta,2)
    end if
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; two-dimensional upper-level (eta) metorology variables
    ;   -derived/diagnostic fields using wrf_user_getvar
    ; -create variables
    if (outEta@p_e .or. outPressure) then
      p_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")     ;p_e
    end if
    if (outEta@Z_e .or. outPressure@Z_p) then
      Z_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")     ;Z_e
    end if
    if (outEta@T_e .or. outPressure@T_p) then
      T_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")     ;T_e
    end if
    if (outEta@Th_e .or. outPressure@Th_p) then
      Th_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")    ;Th_e
    end if
    if (outEta@rh_e .or. outPressure@rh_p) then
      rh_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")    ;rh_e
    end if
    if (outEta@u_gr_e .or. outPressure@u_gr_p) then
      u_gr_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")  ;u_gr_e
    end if
    if (outEta@v_gr_e .or. outPressure@v_gr_p) then
      v_gr_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")  ;v_gr_e
    end if
    if (outEta@u_tr_e .or. outPressure@u_tr_p) then
      u_tr_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")  ;u_tr_e
      uvm = new((/2,nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")
    end if
    if (outEta@v_tr_e .or. outPressure@v_tr_p) then
      v_tr_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")  ;v_tr_e
    end if
    if (outEta@w_e .or. outPressure@w_p) then
      w_e = new((/nTime,nEta,nS_N,nW_E/), "float", "No_FillValue")     ;w_e
    end if
    ; -read in the values using wrf_user_getvar
    do n = 0, nTime-1
      if (outEta@p_e .or. outPressure) then
        p_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"pressure",n)/)        ;p_e
      end if
      if (outEta@Z_e .or. outPressure@Z_p) then
        Z_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"z",n)/)               ;Z_e
      end if
      if (outEta@T_e .or. outPressure@T_p) then
        T_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"tk",n)/)              ;T_e
      end if
      if (outEta@Th_e .or. outPressure@Th_p) then
        Th_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"th",n)/)             ;Th_e
      end if
      if (outEta@rh_e .or. outPressure@rh_p) then
        rh_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"rh",n)/)             ;rh_e
      end if
      if (outEta@u_gr_e .or. outPressure@u_gr_p) then
        u_gr_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"ua",n)/)           ;u_gr_e
      end if
      if (outEta@v_gr_e .or. outPressure@v_gr_p) then
        v_gr_e(n,:,:,:) = (/wrf_user_getvar(wrfout,"va",n)/)           ;v_gr_e
      end if
      if (outEta@u_tr_e .or. outPressure@u_tr_p .or. outEta@v_tr_e .or. outPressure@v_tr_p) then
        uvm(:,n,:,:,:) = (/wrf_user_getvar(wrfout,"uvmet",n)/)
        u_tr_e(n,:,:,:) = uvm(0,n,:,:,:)
        v_tr_e(n,:,:,:) = uvm(1,n,:,:,:)
      end if
      if (outEta@w_e .or. outPressure@w_p) then
        w_e(n,:,:,:) =(/wrf_user_getvar(wrfout,"wa",n)/)               ;w_e
      end if
    end do
    if (outEta@p_e) then
      p_e@long_name = "Pressure at Eta Levels"
        p_e@standard_name = "air_pressure"
        p_e@units = "hPa"
        assignVarAttCoord(p_e,time,eta,2)
    end if
    if (outEta@Z_e .or. outPressure@Z_p) then
      Z_e@long_name = "Geopotential Height at Eta Levels"
        Z_e@standard_name = "geopotential_height"
        Z_e@units = "m"
        assignVarAttCoord(Z_e,time,eta,2)
    end if
    if (outEta@T_e .or. outPressure@T_p) then
      T_e@long_name = "Temperature at Eta Levels"
        T_e@standard_name = "air_temperature"
        T_e@units = "K"
        assignVarAttCoord(T_e,time,eta,2)
    end if
    if (outEta@Th_e .or. outPressure@Th_p) then
        Th_e@long_name = "Potential Temperature at Eta Levels"
        Th_e@standard_name = "potential_temperature"
        Th_e@units = "K"
        assignVarAttCoord(Th_e,time,eta,2)
    end if
    if (outEta@rh_e .or. outPressure@rh_p) then
      rh_e@long_name = "Relative Humidity at Eta Levels"
        rh_e@standard_name = "relative_humidity"
        rh_e@units = "percent"
        assignVarAttCoord(rh_e,time,eta,2)
    end if
    if (outEta@u_gr_e .or. outPressure@u_gr_p) then
      u_gr_e@long_name = "u-Component at Eta Levels (grid)"
        u_gr_e@standard_name = "eastward_wind"
        u_gr_e@units = "m s-1"
        assignVarAttCoord(u_gr_e,time,eta,2)
    end if
    if (outEta@v_gr_e .or. outPressure@v_gr_p) then
      v_gr_e@long_name = "v-Component at Eta Levels (grid)"
        v_gr_e@standard_name = "northward_wind"
        v_gr_e@units = "m s-1"
        assignVarAttCoord(v_gr_e,time,eta,2)
    end if
    if (outEta@u_tr_e .or. outPressure@u_tr_p) then
      u_tr_e@long_name = "u-Component at Eta Levels (true)"
        u_tr_e@standard_name = "eastward_wind"
        u_tr_e@units = "m s-1"
        assignVarAttCoord(u_tr_e,time,eta,2)
    end if
    if (outEta@v_tr_e .or. outPressure@v_tr_p) then
      v_tr_e@long_name = "v-Component at Eta Levels (true)"
        v_tr_e@standard_name = "northward_wind"
        v_tr_e@units = "m s-1"
        assignVarAttCoord(v_tr_e,time,eta,2)
    end if
    if (outEta@w_e .or. outPressure@w_p) then
      w_e@long_name = "w-Component at Eta Levels"
        w_e@standard_name = "upward_wind"
        w_e@units = "m s-1"
        assignVarAttCoord(w_e,time,eta,2)
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; three-dimensional upper-level (pressure) metorology variables
  ;   (variables on selected pressure levels)
  ;   -derived/diagnostic fields using wrf_user_getvar
  ; -create the variables
  if (outPressure) then
    if (outPressure@Z_p) then
      Z_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue")  ;Z_p
    end if
    if (outPressure@T_p) then
      T_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue")  ;T_p
    end if
    if (outPressure@Th_p) then
      Th_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue")  ;Th_p
    end if
    if (outPressure@q_p) then
      q_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue")  ;q_p
    end if
    if (outPressure@rh_p) then
      rh_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue") ;rh_p
    end if
    if (outPressure@u_gr_p) then
      u_gr_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue") ;u_gr_p
    end if
    if (outPressure@v_gr_p) then
      v_gr_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue") ;v_gr_p
    end if
    if (outPressure@u_tr_p) then
      u_tr_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue") ;u_tr_p
    end if
    if (outPressure@v_tr_p) then
      v_tr_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue") ;v_tr_p
    end if
    if (outPressure@w_p) then
      w_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue")  ;w_p
    end if
    if (outPressure@pp_p) then
      pp_p = new((/nTime,nPressure,nS_N,nW_E/), "float", "No_FillValue") ;pp_p
    end if
    if ((outPressure@q_cloud_p) .and. (isfilevar(wrfout, "QCLOUD"))) then
      q_cloud_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue")
    end if
    if ((outPressure@q_rain_p) .and. (isfilevar(wrfout, "QRAIN"))) then
      q_rain_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue")
    end if
    if ((outPressure@q_ice_p) .and. (isfilevar(wrfout, "QICE"))) then
      q_ice_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue")
    end if
    if ((outPressure@q_snow_p) .and. (isfilevar(wrfout, "QSNOW"))) then
      q_snow_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue")
    end if
    if ((outPressure@q_graup_p) .and. (isfilevar(wrfout, "QGRAUP"))) then
      q_graup_p = new((/nTime,nPressure,nS_N,nW_E/),"float","No_FillValue")
    end if
    do n = 0, nTime-1  ; loop through the times in the wrfout file
      do p = 0, nPressure-1  ; loop through the selected pressure levels
        if (outPressure@Z_p) then
          Z_p(n,p,:,:) = (/wrf_user_intrp3d(Z_e(n,:,:,:),p_e(n,:,:,:),  \ ;Z_p
                                          "h",pressure(p),0,False)/)
        end if
        if (outPressure@T_p) then
          T_p(n,p,:,:) = (/wrf_user_intrp3d(T_e(n,:,:,:),p_e(n,:,:,:),  \ ;T_p
                                          "h",pressure(p),0,False)/)
        end if
        if (outPressure@Th_p) then
          Th_p(n,p,:,:) = (/wrf_user_intrp3d(Th_e(n,:,:,:),p_e(n,:,:,:),  \ ;Th_p
                                          "h",pressure(p),0,False)/)
        end if
        if (outPressure@q_p) then
          q_p(n,p,:,:) = (/wrf_user_intrp3d(q_e(n,:,:,:),p_e(n,:,:,:), \;q_p
                                          "h",pressure(p),0,False)/)
        end if
        if (outPressure@rh_p) then
          rh_p(n,p,:,:) = (/wrf_user_intrp3d(rh_e(n,:,:,:),p_e(n,:,:,:), \;rh_p
                                             "h",pressure(p),0,False)/)
        end if
        if (outPressure@u_gr_p) then
          u_gr_p(n,p,:,:) = (/wrf_user_intrp3d(u_gr_e(n,:,:,:),p_e(n,:,:,:), \;u
                                             "h",pressure(p),0,False)/)
        end if
        if (outPressure@v_gr_p) then
          v_gr_p(n,p,:,:) = (/wrf_user_intrp3d(v_gr_e(n,:,:,:),p_e(n,:,:,:), \;v
                                             "h",pressure(p),0,False)/)
        end if
        if (outPressure@u_tr_p) then
          u_tr_p(n,p,:,:) = (/wrf_user_intrp3d(u_tr_e(n,:,:,:),p_e(n,:,:,:), \;u (true)
                                             "h",pressure(p),0,False)/)
        end if
        if (outPressure@v_tr_p) then
          v_tr_p(n,p,:,:) = (/wrf_user_intrp3d(v_tr_e(n,:,:,:),p_e(n,:,:,:), \;v (true)
                                             "h",pressure(p),0,False)/)
        end if
        if (outPressure@w_p) then
          w_p(n,p,:,:) = (/wrf_user_intrp3d(w_e(n,:,:,:),p_e(n,:,:,:),  \  ;w_p
                                          "h",pressure(p),0,False)/)
        end if
        if (outPressure@pp_p) then
          pp_p(n,p,:,:) = (/wrf_user_intrp3d(pp_e(n,:,:,:),p_e(n,:,:,:), \ ;pp_p
                                          "h",pressure(p),0,False)/)
        end if
        if ((outPressure@q_cloud_p) .and. (isfilevar(wrfout, "QCLOUD"))) then
          q_cloud_p(n,p,:,:)=(/wrf_user_intrp3d(q_cloud(n,:,:,:),p_e(n,:,:,:), \
                                                "h",pressure(p),0,False)/)
        end if
        if ((outPressure@q_rain_p) .and. (isfilevar(wrfout, "QRAIN"))) then
          q_rain_p(n,p,:,:) = (/wrf_user_intrp3d(q_rain(n,:,:,:),p_e(n,:,:,:), \
                                               "h",pressure(p),0,False)/)
        end if
        if ((outPressure@q_ice_p) .and. (isfilevar(wrfout, "QICE"))) then
          q_ice_p(n,p,:,:) = (/wrf_user_intrp3d(q_ice(n,:,:,:),p_e(n,:,:,:), \
                                              "h",pressure(p),0,False)/)
        end if
        if ((outPressure@q_snow_p) .and. (isfilevar(wrfout, "QSNOW"))) then
          q_snow_p(n,p,:,:) = (/wrf_user_intrp3d(q_snow(n,:,:,:),p_e(n,:,:,:), \
                                              "h",pressure(p),0,False)/)
        end if
        if ((outPressure@q_graup_p) .and. (isfilevar(wrfout, "QGRAUP"))) then
          q_graup_p(n,p,:,:)=(/wrf_user_intrp3d(q_graup(n,:,:,:),p_e(n,:,:,:), \
                                                "h",pressure(p),0,False)/)
        end if
      end do 
    end do
    if (outPressure@Z_p) then
      Z_p@long_name = "Geopotential Height at Pressure Levels"
        Z_p@standard_name = "geopotential_height"
        Z_p@units = "m"
        Z_p@_FillValue = -999999
        assignVarAttCoord(Z_p,time,pressure,1)               ;Z_p
    end if
    if (outPressure@T_p) then
      T_p@long_name = "Temperature at Pressure Levels"
        T_p@standard_name = "air_temperature"
        T_p@units = "K"
        assignVarAttCoord(T_p,time,pressure,1)               ;T_p
    end if
    if (outPressure@Th_p) then
      Th_p@long_name = "Potential Temperature at Pressure Levels"
        Th_p@standard_name = "potential_temperature"
        Th_p@units = "K"
        assignVarAttCoord(Th_p,time,pressure,1)               ;Th_p
    end if
    if (outPressure@q_p) then
      q_p@long_name = "Mixing Ratio at Pressure Levels"
        q_p@standard_name = "humidity_mixing_ratio"
        q_p@units = "kg kg-1"
        assignVarAttCoord(q_p,time,pressure,1)               ;q_p
    end if
    if (outPressure@rh_p) then
      rh_p@long_name = "Relative Humidity at Pressure Levels"
        rh_p@standard_name = "relative_humidity"
        rh_p@units = "percent"
        assignVarAttCoord(rh_p,time,pressure,1)              ;rh_p
    end if
    if (outPressure@u_gr_p) then
      u_gr_p@long_name = "u-Component at Pressure Levels (grid)"
        u_gr_p@standard_name = "eastward_wind"
        u_gr_p@units = "m s-1"
        assignVarAttCoord(u_gr_p,time,pressure,1)            ;u_gr_p
    end if
    if (outPressure@v_gr_p) then
      v_gr_p@long_name = "v-Component at Pressure Levels (grid)"
        v_gr_p@standard_name = "northward_wind"
        v_gr_p@units = "m s-1"
        assignVarAttCoord(v_gr_p,time,pressure,1)            ;v_gr_p
    end if
    if (outPressure@u_tr_p) then
      u_tr_p@long_name = "u-Component of Pressure Levels (true)"
        u_tr_p@standard_name = "eastward_wind"
        u_tr_p@units = "m s-1"
        assignVarAttCoord(u_tr_p,time,pressure,1)            ;u_tr_p
    end if
    if (outPressure@v_tr_p) then
      v_tr_p@long_name = "v-Component of Pressure Levels (true)"
        v_tr_p@standard_name = "northward_wind"
        v_tr_p@units = "m s-1"
        assignVarAttCoord(v_tr_p,time,pressure,1)           ;v_tr_p
    end if
    if (outPressure@w_p) then
      w_p@long_name = "w-Component at Pressure Levels"
        w_p@standard_name = "upward_wind"
        w_p@units = "m s-1"
        assignVarAttCoord(w_p,time,pressure,1)               ;w_p
    end if
    if (outPressure@pp_p) then
      pp_p@long_name = "Pressure-Perturbation at Pressure levels"
        pp_p@standard_name = "pressure_perturbation"
        pp_p@units = "hPa"
        assignVarAttCoord(pp_p,time,pressure,1)              ;pp_p
    end if
    if ((outPressure@q_cloud_p) .and. (isfilevar(wrfout, "QCLOUD"))) then
      q_cloud_p@long_name = "Mixing Ratio - Cloud at Pressure Levels"
        q_cloud_p@standard_name ="mass_fraction_of_cloud_condensed_water_in_air"
        q_cloud_p@units = "kg kg-1"
        assignVarAttCoord(q_cloud_p,time,pressure,1)
    end if
    if ((outPressure@q_rain_p) .and. (isfilevar(wrfout, "QRAIN"))) then
      q_rain_p@long_name = "Mixing Ratio - Rain at Pressure Levels"
        q_rain_p@standard_name = "mass_fraction_of_rain_in_air"
        q_rain_p@units = "kg kg-1"
        assignVarAttCoord(q_rain_p,time,pressure,1)
    end if
    if ((outPressure@q_ice_p) .and. (isfilevar(wrfout, "QICE"))) then
      q_ice_p@long_name = "Mixing Ratio - Ice at Pressure Levels"
        q_ice_p@standard_name = "mass_fraction_of_ice_in_air"
        q_ice_p@units = "kg kg-1"
        assignVarAttCoord(q_ice_p,time,pressure,1)
    end if
    if ((outPressure@q_snow_p) .and. (isfilevar(wrfout, "QSNOW"))) then
      q_snow_p@long_name = "Mixing Ratio - Snow at Pressure Levels"
        q_snow_p@standard_name = "mass_fraction_of_snow_in_air"
        q_snow_p@units = "kg kg-1"
        assignVarAttCoord(q_snow_p,time,pressure,1)
    end if
    if ((outPressure@q_graup_p) .and. (isfilevar(wrfout, "QGRAUP"))) then
      q_graup_p@long_name = "Mixing Ratio - Graupel at Pressure Levels"
        q_graup_p@standard_name = "mass_fraction_of_graupel_in_air"
        q_graup_p@units = "kg kg-1"
        assignVarAttCoord(q_graup_p,time,pressure,1)
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface energy budget / radiation variables
  if (out2dRadFlx) then
    if (out2dRadFlx@SW_d) then
      SW_d = (/wrfout->SWDOWN/)            ;downward shortwave flux at surface
        SW_d@long_name = "Shortwave Flux - Downward - at surface"
        SW_d@standard_name = "surface_downwelling_shortwave_flux"
        SW_d@units = "W m-2"
        assignVarAttCoord(SW_d,time,0,0)
    end if
    if (out2dRadFlx@LW_d) then
      LW_d = (/wrfout->GLW/)               ;downward longwave flux at surface
        LW_d@long_name = "Longwave Flux - Downward - at surface"
        LW_d@standard_name = "surface_downwelling_longwave_flux"
        LW_d@units = "W m-2"
        assignVarAttCoord(LW_d,time,0,0)
    end if
    if (out2dRadFlx@LW_toa .and. isfilevar(wrfout, "OLR")) then
      LW_toa = (/wrfout->OLR/)             ;top-of-atmosphere outgoing longwave
        LW_toa@long_name = "Longwave Flux - Outgoing - TOA"
        LW_toa@standard_name = "toa_outgoing_longwave_flux"
        LW_toa@units = "W m-2"
        assignVarAttCoord(LW_toa,time,0,0)
    end if
    if (out2dRadFlx@albedo) then
      albedo = (/wrfout->ALBEDO/)          ;albedo
        albedo@long_name = "Albedo"
        albedo@standard_name = "surface_albedo"
        albedo@units = ""
        assignVarAttCoord(albedo,time,0,0)
    end if
    if (out2dRadFlx@SHFlx) then
      SHFlx = (/wrfout->HFX/)              ;sensible heat flux at the surface
        SHFlx@long_name = "Sensible Heat Flux - Upward - at surface"
        SHFlx@standard_name = "surface_upward_sensible_heat_flux"
        SHFlx@units = "W m-2"
        assignVarAttCoord(SHFlx,time,0,0)
    end if
    if (out2dRadFlx@LHFlx) then
      LHFlx = (/wrfout->LH/)               ;latent heat flux at the surface
        LHFlx@long_name = "Latent Heat Flux - Upward - at surface"
        LHFlx@standard_name = "surface_upward_latent_heat_flux"
        LHFlx@units = "W m-2"
        assignVarAttCoord(LHFlx,time,0,0)
    end if
    if (out2dRadFlx@MFlx) then
      MFlx = (/wrfout->QFX/)               ;moisture heat flux at the surface
        MFlx@long_name = "Moisture Heat Flux - Upward - at surface"
        MFlx@standard_name = "surface_upward_water_flux"
        MFlx@units = "kg m-2 s-1"
        assignVarAttCoord(MFlx,time,0,0)
    end if
    if (out2dRadFlx@u_star .and. isfilevar(wrfout, "UST")) then
      u_star = (/wrfout->UST/)             ;friction velocity (similarity)
        u_star@long_name = "Friction Velocity (u*)"
        u_star@standard_name = ""
        u_star@units = "m s-1"
        assignVarAttCoord(u_star,time,0,0)
    end if
    if (out2dRadFlx@emiss_sfc) then
      emiss_sfc = (/wrfout->EMISS/)        ;surface emissivity
        emiss_sfc@long_name = "Surface Emissivity"
        emiss_sfc@standard_name = "surface_emissivity"
        emiss_sfc@units = ""
        assignVarAttCoord(emiss_sfc,time,0,0)
    end if
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; two-dimensional surface energy budget / radiation variables (calculated)
    ;  Note: process both IWP and LWP, even if only one is specified
    if (out2dRadFlx@LWP .or. out2dRadFlx@IWP) then
      ; -create the variable
      LWP = new((/nTime,nS_N,nW_E/), double, "No_FillValue")    ;LWP
      IWP = new((/nTime,nS_N,nW_E/), double, "No_FillValue")    ;IWP
      ; -loop through the nTimes
      do n = 0, nTime-1
        ; -create the variables (does not include time dimension)
        p_eta = new((/nEta,nS_N,nW_E/), double, "No_FillValue")
        p_int = new((/nEta+1,nS_N,nW_E/), double, "No_FillValue")
        p_surf = new((/nS_N,nW_E/), double, "No_FillValue")
        d_pres = new((/nS_N,nW_E/), double, "No_FillValue")
        q_eta = new((/nEta,nS_N,nW_E/), double)
        qc_eta = new((/nEta,nS_N,nW_E/), double)
        qr_eta = new((/nEta,nS_N,nW_E/), double)
        qi_eta = new((/nEta,nS_N,nW_E/), double)
        qi_eta = 0.d  ;set to 0 in case it is not in the wrfout file
        qs_eta = new((/nEta,nS_N,nW_E/), double)
        qs_eta = 0.d
        qg_eta = new((/nEta,nS_N,nW_E/), double)
        qg_eta = 0.d
        ; -read in the values needed for calculations
        p_eta = (/wrf_user_getvar(wrfout,"pressure",n)/)*100.
        p_surf = (/wrfout->PSFC(n,:,:)/)
        p_tp_in = (/wrfout->P_TOP/)     ;pressure at top of model
        ;in some files P_TOP has two dimensions, in some it has one dimension
        if ((dimsizes(dimsizes(p_tp_in))) .eq. 2) then
          p_tp = p_tp_in(0,0)
        else
          p_tp = p_tp_in(0)
        end if
        q_eta = (/wrfout->QVAPOR(n,:,:,:)/)
        qc_eta = (/wrfout->QCLOUD(n,:,:,:)/)
        qr_eta = (/wrfout->QRAIN(n,:,:,:)/)
        if (isfilevar(wrfout, "QICE")) then  ;verify it is included in wrfout
          qi_eta = (/wrfout->QICE(n,:,:,:)/)
        end if
        if (isfilevar(wrfout, "QSNOW")) then
          qs_eta = (/wrfout->QSNOW(n,:,:,:)/)
        end if
        if (isfilevar(wrfout, "QGRAUP")) then
          qg_eta = (/wrfout->QGRAUP(n,:,:,:)/)
        end if
        ; -calculate the pressure at the intersection between eta levels
        p_int(0,:,:) = p_surf
        p_int(nEta,:,:) = p_tp
        do k = 1, nEta-1
          p_int(k,:,:) = (p_eta(k-1,:,:)+p_eta(k,:,:))*0.5
        end do
        ; -loop through the nEta
        do k = 0, nEta-1
          ; -calculate the difference in pressure between eta levels
          d_pres = p_int(k,:,:) - p_int(k+1,:,:)
          ; -calculate the IWP and LWP
          LWP(n,:,:) = LWP(n,:,:) + (qc_eta(k,:,:)*d_pres/9.81)
          IWP(n,:,:) = IWP(n,:,:) +  \
                       (qi_eta(k,:,:)+qs_eta(k,:,:)+qg_eta(k,:,:))*d_pres/9.81
        end do
      end do
      ; -set the attributes
      LWP@long_name = "Column Integrated Cloud Water"
        LWP@standard_name = "atmosphere_cloud_liquid_water_content"
        LWP@units = "kg m-2"
        assignVarAttCoord(LWP,time,0,0)      ;LWP
      IWP@long_name = "Column Integrated Cloud Ice"
        IWP@standard_name = "atmosphere_cloud_ice_content"
        IWP@units = "kg m-2"
        assignVarAttCoord(IWP,time,0,0)      ;IWP
    end if
  end if
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; two-dimensional surface/soil variables
  if (out2dLandSoil) then
    if (out2dLandSoil@LandMask) then
      LandMask = (/wrfout->LANDMASK/)      ;land mask (1 - land, 0 - water)
        LandMask@long_name = "Land Mask"
        LandMask@standard_name = "land_binary_mask"
        LandMask@units = ""
        LandMask@notes = "1=land, 0=water"
        assignVarAttCoord(LandMask,time,0,0)
    end if
    if (out2dLandSoil@LandUse) then
      LandUse = (/wrfout->LU_INDEX/)       ;land use category
        LandUse@long_name = "Land Use Category"
        LandUse@standard_name = "land_cover"
        LandUse@units = ""
        assignVarAttCoord(LandUse,time,0,0)
    end if
    if (out2dLandSoil@SoilT_L) then
      SoilT_L = (/wrfout->TMN/)            ;soil temperature at lower boundary
        SoilT_L@long_name = "Soil Temperature - at lower boundery"
        SoilT_L@standard_name = "soil_temperature"
        SoilT_L@units = "K"
        assignVarAttCoord(SoilT_L,time,0,0)
    end if
    if ((out2dLandSoil@SoilT_B) .and. isfilevar(wrfout, "SOILTB")) then
      SoilT_B = (/wrfout->SOILTB/)         ;bottom soil temperature
        SoilT_B@long_name = "Soil Temperature - bottom"
        SoilT_B@standard_name = "soil_temperature"
        SoilT_B@units = "K"
        assignVarAttCoord(SoilT_B,time,0,0)
    end if
    if (out2dLandSoil@GroundFlx) then
      GroundFlx = (/wrfout->GRDFLX/)       ;ground heat flux
        GroundFlx@long_name = "Ground Heat Flux"
        GroundFlx@standard_name = "upward_heat_flux_at_ground_level_in_soil"
        GroundFlx@units = "W m-2"
        assignVarAttCoord(GroundFlx,time,0,0)
    end if
    if (out2dLandSoil@SnowHgt) then
      SnowHgt = (/wrfout->SNOWH/)          ;snow height
        SnowHgt@long_name = "Snow Height"
        SnowHgt@standard_name = "surface_snow_thickness"
        SnowHgt@units = "m"
        assignVarAttCoord(SnowHgt,time,0,0)
    end if
    if (out2dLandSoil@SnowWater) then
      SnowWater = (/wrfout->SNOW/)         ;snow water equivalent
        SnowWater@long_name = "Snow Water Equivalent"
        SnowWater@standard_name = "surface_snow_amount"
        SnowWater@units = "kg m-2"
        assignVarAttCoord(SnowWater,time,0,0)
    end if
    if ((out2dLandSoil@SnowDens) .and. isfilevar(wrfout, "RHOSN")) then
      SnowDens = (/wrfout->RHOSN/)         ;snow density
        SnowDens@long_name = "Snow Density"
        SnowDens@standard_name = "snow_density"
        SnowDens@units = "kg m-3"
        assignVarAttCoord(SnowDens,time,0,0)
    end if
    if ((out2dLandSoil@SnowFlx) .and. isfilevar(wrfout, "SNOPCX")) then
      SnowFlx = (/wrfout->SNOPCX/)         ;snow phase change heat flux
        SnowFlx@long_name = "Snow Phase Change Heat Flux"
        SnowFlx@standard_name = "surface_snow_melt_and_sublimation_heat_flux"
        SnowFlx@units = "W m-2"
        assignVarAttCoord(SnowFlx,time,0,0)
    end if
    if ((out2dLandSoil@SeaIce) .and. isfilevar(wrfout, "SEAICE")) then
      SeaIce = (/wrfout->SEAICE/)          ;sea ice flag
        SeaIce@long_name = "Sea Ice Flag"
        SeaIce@standard_name = "seaice_binary_mask"
        SeaIce@units = ""
        SeaIce@notes = "1=seaice, 0=water"
        assignVarAttCoord(SeaIce,time,0,0)
    else
      if ((out2dLandSoil@SeaIce) .and. isfilevar(wrfout, "XICE")) then
        SeaIce = (/wrfout->XICE/)          ;sea ice flag
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
      SoilTemp = (/wrfout->TSLB/)          ;soil temperature
        SoilTemp@long_name = "Soil Temperature"
        SoilTemp@standard_name = "soil_temperature"
        SoilTemp@units = "K"
        assignVarAttCoord(SoilTemp,time,soil,3)
    end if
    if (outSoil@SoilMoist) then
      SoilMoist = (/wrfout->SMOIS/)        ;soil moisture
        SoilMoist@long_name = "Soil Moisture"
        SoilMoist@standard_name = "soil_moisture_content"
        SoilMoist@units = "m3 m-3"
        assignVarAttCoord(SoilMoist,time,soil,3)
    end if
    if ((outSoil@SoilWater) .and. isfilevar(wrfout, "SH20")) then
      SoilWater = (/wrfout->SH20/)         ;soil liquid water
        SoilWater@long_name = "Soil Liquid Water"
        SoilWater@standard_name = "soil_liquid_water_content"
        SoilWater@units = "m3 m-3"
        assignVarAttCoord(SoilWater,time,soil,3)
    end if
  end if
  ; -for some reason the time attribute is added to the eta levels during
  ;  the interpolation routines - delete these attributes
  if (isvar("pressure") .and. isatt(pressure, "pressure")) then
    delete(pressure@pressure)
  end if
  if (isvar("Z_e") .and. isatt(Z_e, "time")) then
    delete(Z_e@time)
  end if
  if (isvar("p_e") .and. isatt(p_e, "time")) then
    delete(p_e@time)
  end if
  if (isvar("T_e") .and. isatt(T_e, "time")) then
    delete(T_e@time)
  end if
  if (isvar("Th_e") .and. isatt(Th_e, "time")) then
    delete(Th_e@time)
  end if
  if (isvar("u_gr_e") .and. isatt(u_gr_e, "time")) then
    delete(u_gr_e@time)
  end if
  if (isvar("v_gr_e") .and. isatt(v_gr_e, "time")) then
    delete(v_gr_e@time)
  end if
  if (isvar("u_tr_e") .and. isatt(u_tr_e, "time")) then
    delete(u_tr_e@time)
  end if
  if (isvar("v_tr_e") .and. isatt(v_tr_e, "time")) then
    delete(v_tr_e@time)
  end if
  if (isvar("w_e") .and. isatt(w_e, "time")) then
    delete(w_e@time)
  end if
  if (isvar("q_e") .and. isatt(q_e, "time")) then
    delete(q_e@time)
  end if
  if (isvar("pp_e") .and. isatt(pp_e, "time")) then
    delete(pp_e@time)
  end if
  if (isvar("rh_e") .and. isatt(rh_e, "time")) then
    delete(rh_e@time)
  end if
  if (isvar("q_cloud") .and. isatt(q_cloud, "time")) then
    delete(q_cloud@time)
  end if
  if (isvar("q_rain") .and. isatt(q_rain, "time")) then
    delete(q_rain@time)
  end if
  if (isvar("q_snow") .and. isatt(q_snow, "time")) then
    delete(q_snow@time)
  end if
  if (isvar("q_ice") .and. isatt(q_ice, "time")) then
    delete(q_ice@time)
  end if
  if (isvar("q_graup") .and. isatt(q_graup, "time")) then
    delete(q_graup@time)
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
  if (outEta) then
    if (limEta(1) .eq. 9999) then 
      limEta(1) = nEta-1
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
  wrfpost = addfile(dir_out+file_out,"c")    ;create new netCDF file
  filedimdef (wrfpost, "time", nTime, True)
  ; create the global attributes
  ; establish a variable for a new line in the attributes
  nl = integertochar(10)  ; newline character
  fileAtt                = True
  fileAtt@creation_date  =  systemfunc("date")
  fileAtt@institution = "University of Colorado at Boulder - CIRES"
  fileAtt@created_by = "Alice DuVivier - alice.duvivier@colorado.edu"
  fileAtt@notes = "Created with NCL script:  wrfout_to_cf.ncl v1.1.4"
  fileAtt@source         = file_in
  fileAtt@Conventions    = "CF-1.0"
  fileAtt@title          = file_out
  fileattdef(wrfpost, fileAtt)
  ;write post-processed WRF data to netCDF file
  ; -date and time variables
  wrfpost->time=time(limTime(0):limTime(1))
  if (outDateTime) then
    wrfpost->DateTime=DateTime(limTime(0):limTime(1))
  end if
  if (outUTCDate) then
    wrfpost->year = year(limTime(0):limTime(1))
    wrfpost->month = month(limTime(0):limTime(1))
    wrfpost->day = day(limTime(0):limTime(1))
    wrfpost->hour = hour(limTime(0):limTime(1))
    wrfpost->minute = minute(limTime(0):limTime(1))
  end if
  ; -vertical coordinate variables
  if (outPressure) then
    wrfpost->pressure=pressure(limPres(0):limPres(1))
  end if
  if (outEta) then
    wrfpost->eta=eta(limEta(0):limEta(1))
  end if
  if (outSoil) then
    wrfpost->soil=soil(limSoil(0):limSoil(1))
  end if
  ; -one-dimensional coordinate variables
  if (axis) then
    wrfpost->south_north=south_north(limS_N(0):limS_N(1))
    wrfpost->west_east=west_east(limW_E(0):limW_E(1))
  end if
  ; -one-dimensional general model variables
  if (outPtop .or. outEta) then
    wrfpost->p_top=p_top
  end if
  ; -two-dimensional mapping variables
    wrfpost->lat=lat(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    wrfpost->lon=lon(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    wrfpost->Z_sfc=Z_sfc(limS_N(0):limS_N(1),limW_E(0):limW_E(1))
  ; -two-dimensional near-surface / surface met variables
  if (out2dMet) then
    if (isvar("SST")) then
      wrfpost->SST=SST(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                       limW_E(0):limW_E(1))
    end if
    if (isvar("T_sfc")) then
      wrfpost->T_sfc=T_sfc(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("p_sfc")) then
      wrfpost->p_sfc=p_sfc(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("slp_a") .and. isvar("slp_b")) then
      wrfpost->slp_a=slp_a(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
      wrfpost->slp_b=slp_b(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    else
      if (isvar("slp_a")) then
        wrfpost->slp=slp_a(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
      end if
      if (isvar("slp_b")) then
        wrfpost->slp=slp_b(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
      end if
    end if
    if (isvar("T_2m")) then
      wrfpost->T_2m=T_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("Th_2m")) then
      wrfpost->Th_2m=Th_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("Td_2m")) then
      wrfpost->Td_2m=Td_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("q_2m")) then
      wrfpost->q_2m=q_2m(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("u_10m_gr")) then
      wrfpost->u_10m_gr=u_10m_gr(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("v_10m_gr")) then
      wrfpost->v_10m_gr=v_10m_gr(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("u_10m_tr")) then
      wrfpost->u_10m_tr=u_10m_tr(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("v_10m_tr")) then
      wrfpost->v_10m_tr=v_10m_tr(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("precip_g")) then
      wrfpost->precip_g=precip_g(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("precip_c")) then
      wrfpost->precip_c=precip_c(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("dryairmass")) then
      wrfpost->dryairmass=dryairmass(limTime(0):limTime(1),limS_N(0):limS_N(1), \
                                     limW_E(0):limW_E(1))
    end if
    if (isvar("pblh")) then
      wrfpost->pblh=pblh(limTime(0):limTime(1),limS_N(0):limS_N(1), \
                         limW_E(0):limW_E(1))
    end if
  end if
  ; -three-dimensional upper-level (pressure) meteorology variables
  if (outPressure) then
    if (isvar("Z_p")) then
      wrfpost->Z_p=Z_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("T_p")) then
      wrfpost->T_p=T_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("Th_p")) then
      wrfpost->Th_p=Th_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_p")) then
      wrfpost->q_p=q_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("rh_p")) then
      wrfpost->rh_p=rh_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                         limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("u_gr_p")) then
      wrfpost->u_gr_p=u_gr_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("v_gr_p")) then
      wrfpost->v_gr_p=v_gr_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("u_tr_p")) then
      wrfpost->u_tr_p=u_tr_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("v_tr_p")) then
      wrfpost->v_tr_p=v_tr_p(limTime(0):limTime(1),limPres(0):limPres(1),   \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("w_p")) then
      wrfpost->w_p=w_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("pp_p")) then
      wrfpost->pp_p=pp_p(limTime(0):limTime(1),limPres(0):limPres(1),  \
                         limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
  end if
  ; -three-dimensional upper-level (eta) meteorology variables
  if (outEta) then
    if (isvar("Z_e") .and. (outEta@Z_e)) then
      wrfpost->Z_e=Z_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("p_e") .and. (outEta@p_e)) then
      wrfpost->p_e=p_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("T_e") .and. (outEta@T_e)) then
      wrfpost->T_e=T_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("Th_e") .and. (outEta@Th_e)) then
      wrfpost->Th_e=Th_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_e") .and. (outEta@q_e)) then
      wrfpost->q_e=q_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                               limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("rh_e") .and. (outEta@rh_e)) then
      wrfpost->rh_e=rh_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                         limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("u_gr_e") .and. (outEta@u_gr_e)) then
      wrfpost->u_gr_e=u_gr_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("v_gr_e") .and. (outEta@v_gr_e)) then
      wrfpost->v_gr_e=v_gr_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("u_tr_e") .and. (outEta@u_tr_e)) then
      wrfpost->u_tr_e=u_tr_e(limTime(0):limTime(1),limEta(0):limEta(1),   \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("v_tr_e") .and. (outEta@v_tr_e)) then
       wrfpost->v_tr_e=v_tr_e(limTime(0):limTime(1),limEta(0):limEta(1),   \
                              limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if 
   if (isvar("w_e") .and. (outEta@w_e)) then
      wrfpost->w_e=w_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("pp_e") .and. (outEta@pp_e)) then
      wrfpost->pp_e=pp_e(limTime(0):limTime(1),limEta(0):limEta(1),  \
                       limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_cloud") .and. (outEta@q_cloud)) then
      wrfpost->q_cloud=q_cloud(limTime(0):limTime(1),limEta(0):limEta(1),  \
                               limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_rain") .and. (outEta@q_rain)) then
      wrfpost->q_rain=q_rain(limTime(0):limTime(1),limEta(0):limEta(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_ice") .and. (outEta@q_ice)) then
      wrfpost->q_ice=q_ice(limTime(0):limTime(1),limEta(0):limEta(1),  \
                           limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_snow") .and. (outEta@q_snow)) then
      wrfpost->q_snow=q_snow(limTime(0):limTime(1),limEta(0):limEta(1),  \
                             limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("q_graup") .and. (outEta@q_graup)) then
      wrfpost->q_graup=q_graup(limTime(0):limTime(1),limEta(0):limEta(1),  \
                               limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
  end if
  ; -two-dimensional surface energy budget / radiation variables
  if (out2dRadFlx) then
    if (isvar("SW_d")) then
      wrfpost->SW_d=SW_d(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("LW_d")) then
      wrfpost->LW_d=LW_d(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if isvar("LW_toa") then
      wrfpost->LW_toa=LW_toa(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                             limW_E(0):limW_E(1))
    end if
    if (isvar("albedo")) then
      wrfpost->albedo=albedo(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                             limW_E(0):limW_E(1))
    end if
    if (isvar("SHFlx")) then
      wrfpost->SHFlx=SHFlx(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("LHFlx")) then
      wrfpost->LHFlx=LHFlx(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                           limW_E(0):limW_E(1))
    end if
    if (isvar("MFlx")) then
      wrfpost->MFlx=MFlx(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if isvar("u_star") then
      wrfpost->u_star=u_star(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                             limW_E(0):limW_E(1))
    end if
    if (isvar("LWP") .and. (out2dRadFlx@LWP)) then
      wrfpost->LWP=LWP(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("IWP") .and. (out2dRadFlx@IWP)) then
      wrfpost->IWP=IWP(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                         limW_E(0):limW_E(1))
    end if
    if (isvar("emiss_sfc")) then
      wrfpost->emiss_sfc=emiss_sfc(limTime(0):limTime(1),limS_N(0):limS_N(1), \
                                   limW_E(0):limW_E(1))
    end if
  end if
  ; -two-dimensional surface / soil variables
  if (out2dLandSoil) then
    if (isvar("LandMask")) then
      wrfpost->LandMask=LandMask(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if (isvar("LandUse")) then
      wrfpost->LandUse=LandUse(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if (isvar("SoilT_L")) then
      wrfpost->SoilT_L=SoilT_L(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if isvar("SoilT_B") then
      wrfpost->SoilT_B=SoilT_B(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if (isvar("GroundFlx")) then
      wrfpost->GroundFlx=GroundFlx(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                   limW_E(0):limW_E(1))
    end if
    if (isvar("SnowHgt")) then
      wrfpost->SnowHgt=SnowHgt(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if (isvar("SnowWater")) then
      wrfpost->SnowWater=SnowWater(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                   limW_E(0):limW_E(1))
    end if
    if isvar("SnowDens") then
      wrfpost->SnowDens=SnowDens(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                                 limW_E(0):limW_E(1))
    end if
    if isvar("SnowFlx") then
      wrfpost->SnowFlx=SnowFlx(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                               limW_E(0):limW_E(1))
    end if
    if isvar("SeaIce") then
      wrfpost->SeaIce=SeaIce(limTime(0):limTime(1),limS_N(0):limS_N(1),  \
                             limW_E(0):limW_E(1))
    end if
  end if
  ; -three-dimensional soil variables
  if (outSoil) then
    if (isvar("SoilTemp")) then
      wrfpost->SoilTemp=SoilTemp(limTime(0):limTime(1),limSoil(0):limSoil(1),  \
                                 limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if (isvar("SoilMoist")) then
     wrfpost->SoilMoist=SoilMoist(limTime(0):limTime(1),limSoil(0):limSoil(1), \
                                   limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
    if isvar("SoilWater") then
     wrfpost->SoilWater=SoilWater(limTime(0):limTime(1),limSoil(0):limSoil(1), \
                                   limS_N(0):limS_N(1),limW_E(0):limW_E(1))
    end if
  end if
end 
