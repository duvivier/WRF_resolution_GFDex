;***************************************
; PROGRAM DESCRIPTION: This NCL script calcs stats between WRF and AWS values
; INPUT DATA: 
;             
; OUTPUT DATA: 
; NOTE: 
; CREATOR: Alice DuVivier - October 2010
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; below codes are for testing purposes
dir1 = "/data3/duvivier/NCAR/21FEB/wrf_100km/"
fname1 = "wrf-2007-02"
shrt_t1 = "wrf_100"           
location = "1"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set AWS locations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (location .eq. "1") then  ;Prins Christian - E
    AWS_lat = 60.050
    AWS_lon = -43.167
    AWS_elev = 75.0
  end if
  if (location .eq. "2") then  ;Ikerminarsuk - E
    AWS_lat = 61.933
    AWS_lon = -42.067
    AWS_elev = 39.0
  end if
  if (location .eq. "3") then  ;Angisoq - W
    AWS_lat = 59.983
    AWS_lon = -45.2
    AWS_elev = 16.0
  end if
  if (location .eq. "4") then  ;Qaqortoq - W
    AWS_lat = 60.717
    AWS_lon = -46.05
    AWS_elev = 34.0
  end if
  if (location .eq. "5") then  ;Narsarsuaq- W
    AWS_lat = 61.167
    AWS_lon = -45.417
    AWS_elev = 31.0
  end if

; convert hour step specified in cshell
hourstep = 1
hstep = stringtodouble(hourstep)

return

; set outdir and fout names
outdir = "./"
fout   = outdir+shrt_t1+"_stats_Lat"+AWS_lat+"_Lon"+AWS_lon
  print("Calculating stats for "+fname1+" and "+fname2+" for "+varcode)

; add in variable set as "varcode" from cshell wrapper. Assign it a title, units, etc.
  if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"
    invar2 = "slp"
    vartype = "2d"
    units = "hPa  "
  end if
  if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2m"
    invar1 = "T_2m"
    invar2 = "T_2m"
    vartype = "2d"
    units = "C    "
  end if
 if (varcode.eq."Windsurf_s") then
    vartitle1 = "Wind Speed at 10m"
    invar1 = "u_10m_tr"
    invar11 ="v_10m_tr"
    invar2 = "u_10m_tr"
    invar22 = "v_10m_tr"
    vartype = "2d"
    units = "m/s"
    wind = True
    find_speed = True
    met_not_avail = True  ; wind data not in met
  end if
  if (varcode.eq."Windsurf_d") then
    vartitle1 = "Wind Direction at 10m"
    invar1 = "u_10m_tr"
    invar11 ="v_10m_tr"
    invar2 = "u_10m_tr"
    invar22 = "v_10m_tr"
    vartype = "2d"
    units = "degrees"
    wind = True
    find_dir = True
    met_not_avail = True  ; wind data not in met
  end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data loading and manipulation:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load in the two files. Directories and filenames were specified as inputs.
  f1 = addfile(dir1 + fname1 + ".nc","r")
  f2 = addfile(dir2 + fname2 + ".nc","r")

if (isvar("wind").and.(wind))then              ; if we're looking at wind speed or direction load in the v components too
  f11 = addfile(dir1 + fname1 + ".nc","r")
  f22 = addfile(dir2 + fname2 + ".nc","r")
end if

; get lat and lon data
  lat2d  = f1->lat
  lon2d  = f1->lon

; break down times for nicer plots later
  year = f1->year
  month = f1->month
  day = f1->day
  hour = f1->hour

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lat/Lon index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Narrow down data to particular lat/lon position for evaluation
; Lat and lon are uploaded from cshell script

lat_i = stringtodouble(AWS_lat)            ; convert the lat/lon inputs to strings for index finder
lon_i = stringtodouble(AWS_lon)

indices = getind_latlon2d(lat2d,lon2d,lat_i,lon_i)
ind1 = indices(0,0)  ; get specific indicies for the latitude chosen
ind2 = indices(0,1)  ; get specific indicies for the longitude chosen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load 2d vars:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ; If statements check to to see if variable is 3d  and 'isfilevar' is an ncl function that checks if the input variable (invar1) resides in the input file. If it does, the input variable is loaded
; Input the whole dataset so that several grid points can be examined without reloading the data
 if (vartype.eq."2d") then
    var1 = f1->$invar1$(time|:,{south_north|ind1}, {west_east|ind2}) 
    var2 = f2->$invar2$(time|:,{south_north|ind1}, {west_east|ind2})
    if (isvar("wind").and.(wind))then
        var11 = f11->$invar11$(time|:,{south_north|ind1}, {west_east|ind2})
        var22 = f22->$invar22$(time|:,{south_north|ind1}, {west_east|ind2})
    end if
 end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load 3d vars:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If statements check to to see if variable is 3d  and 'isfilevar' is an ncl function that checks if the input variable (invar1) resides in the input file. If it does, the input variable is loaded.
; Input the whole dataset so that several grid points can be examined without reloading the data
 if (vartype.eq."3d")
    var1 = f1->$invar1$(time|:,{pressure|preslev},{south_north|ind1}, {west_east|ind2})
    var2 = f2->$invar2$(time|:,{pressure|preslev},{south_north|ind1}, {west_east|ind2})
    if (isvar("wind").and.(wind))then
        var11 = f11->$invar11$(time|:,{pressure|preslev},{south_north|ind1}, {west_east|ind2})
        var22 = f22->$invar22$(time|:,{pressure|preslev},{south_north|ind1}, {west_east|ind2})
    end if
    delete(preslev)
 end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Do necessary conversions/data manipulations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (isvar("convert_to_C").and.(convert_to_C)) then
    var1 = var1 - 273.15
    var2 = var2 - 273.15
  end if
  if (isvar("convert_to_g").and.(convert_to_g)) then
    var1 = var1*1000.
    var2 = var2*1000.
  end if

; for wind plots, must have u and v data
; find wind speed
  if (isvar("find_speed").and.(find_speed)) then
     var1 = sqrt(var1^2+var11^2)
     var2 = sqrt(var2^2+var22^2)
     copy_VarMeta(var11,var1)
     copy_VarMeta(var11,var2)
     var1@long_name = "Net Wind Speed"
     var2@long_name = "Net Wind Speed"
  end if

 ; must rotate vectors and find direction    
 if (isvar("find_dir").and.(find_dir)) then
   r2d = 45.0/atan(1.0)         ; convert radians to degrees

    var1 = atan2(var1,var11)*r2d+180  ; wind direction in degrees
    var2 = atan2(var2,var22)*r2d+180  ; wind direction in degrees
    var1!0 = "time"
    var1&time = f1->time
    var1@long_name = "Wind Direction"
    var1@units = "Degrees"
     copy_VarMeta(var1,var2)
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Convert times
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load both variables time files to verify they are the same length
  allhours1 = var1&time
  allhours2 = var2&time
  alltimes1 = ut_calendar(allhours1,3)  ; convert times to UT time as a string
  alltimes2 = ut_calendar(allhours2,3)

; the initial time for looping is the first time in the input WRF file:
  tind2 = 0
  time2 = alltimes2(tind2)            ; start date for var2
  tind1 = ind(alltimes1.eq.time2)     ; get index for var1 where the date matches var2 start date
  time1 = alltimes1(tind1)            ; start date for var1 (should be)
; end time of month:
  tind1_end = dimsizes(alltimes1)-1   ; get dimension sizes of time array var1
  tind2_end = dimsizes(alltimes2)-1   ; get dimension sizes of time array var2
  time1_end = alltimes1(tind1_end)    ; get date of last entry in time array var1
  time2_end = alltimes2(tind2_end)    ; get date of last entry in time array var2

  if(time1.ne.time2) 
    print("Indexing went horribly wrong: start dates do not match.")
    exit
  end if
  if(time1_end.ne.time2_end) 
    print("Input files do not both have same end time.")
    exit
  end if
  if(tind1_end.ne.tind1_end) 
    print("Input files do not have the same dimensions.")
    exit
  end if
  
hour1 = allhours1(tind1)   ; set start date for do loop in stats calculation

;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate stats for each day
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start of do loop for calculating stats at each time step

t_loop = True      ; turn on time loop
index = 0          ; set first index
do while (t_loop)   ; start do loop

  time_str = sprintf("%10.10g",time1)  ; convert the time string to an equal precision time string

; choose the specific time to process and just the point that corresponds to the latitude/longitude in question
  avg1_2d = var1(time|tind1)
  avg2_2d = var2(time|tind2)

; choose year, month, day, hour position
  yy = year(time|tind1)
  mm = month(time|tind1)
  dd = day (time|tind1)
  hh = hour(time|tind1)
 
;get variable dimensions for stats
   y = 1
   x = 1  ; for just one gridpoint

;;;;;;
; var1 average
; domain average of variable 1, necessary for plotting timeseries
;;;;;;
  avg1 = avg(avg1_2d)

;;;;;;
; var2 average
; domain average of variable 2, necessary for plotting timeseries
;;;;;;
  avg2 = avg(avg2_2d)


;;;;;;  
; write output file
;;;;;;

  if (index.eq.0) then                ; set header for the output text file
    header = "year    month     day     hour      "+shrt_t1+"     "+shrt_t2+"     bias    MAE     RMSE    CORR"
    output = header
  end if

 ; write line of statistics outputs to 4 decimal points
  a1 = sprintf("%10.0f",yy)+sprintf("%10.0f",mm)+sprintf("%10.0f",dd)+sprintf("%10.0f",hh)+\
      sprintf("%10.4f",avg1)+sprintf("%10.4f",avg2)+\
      sprintf("%10.4f",BIAS)+sprintf("%10.4f",MAE)+sprintf("%10.4f",RMSE)+sprintf("%10.4f",CORR) 

  newoutput = array_append_record(output,a1,0)  ; append the new statistics output (a1) to the previous outputs(output)
  delete(output)
  output = newoutput                            ; set output as newly appended list of statistics
  delete(newoutput)


  hour1 = hour1 + hstep                      ; add "hstep" number of hours specified in cshell
  tind1 = ind(hour1.eq.allhours1)               ; increase the next index to where the new hour matches the hourly array
  if(all(ismissing(tind1))) then
    print("End of input file.")                 ; if there is not an index match then the file is done
    t_loop = False                              ; when file ends set the loop to false
  else
    time1 = alltimes1(tind1)                    ; if there is an index, get the time for the next time
    time2 = time1
    tind2 = ind(time2.eq.alltimes2)             ; set the second index 
  end if

  index = index + 1                             ; increase the index

; return  ; for testing the loop

end do ; do while loop

asciiwrite(fout+".txt",output)  ; write the text to an output file with name fout

; delete all variables and resources
  delete(var1)
  delete(var2)
  
end





