;***************************************
; Matt Higgins - 5 Aug 2009
; Alice DuVivier - Oct. 2010
;
; This script uploads text files run previously and creates graphs
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; below codes are for testing purposes
;indir1 = "/data3/duvivier/ARSC/stats/text/era_i-v-wrf_cont/month_200702_points-06H/"
;indir2 = "/data3/duvivier/ARSC/stats/text/era_i-v-wrf_nudg/month_200702_points-06H/"
;fname1 = indir1+varcode+"_"+shrt_t0+"_"+shrt_t1+"_"+date1+"_Lat"+AWS_lat+"_Lon"+AWS_lon+"_stats"
;fname2 = indir2+varcode+"_"+shrt_t0+"_"+shrt_t2+"_"+date1+"_Lat"+AWS_lat+"_Lon"+AWS_lon+"_stats"
;fname3 = varcode+"_"+date1+"_Lat"+AWS_lat+"_Lon"+AWS_lon+"_stats"
;title0 = "ERA_interim"
;shrt_t0 = "era_i"
;title1 = "WRF_Continuous"
;shrt_t1 = "wrf_cont"
;title2 = "WRF_Spectral_Nudging"
;shrt_t2 = "wrf_nudg"
;date1 = "200702"
;varcode = "SLP"
;AWS_lat = "60.0"
;AWS_lon = "-43.5"
;en_mems = "3"

; Check for input information:
  if(.not.any(isvar("indir1").and.isvar("indir2") \
              .and.isvar("title0").and.isvar("title1").and.isvar("title2") \
              .and.isvar("shrt_t0").and.isvar("shrt_t1").and.isvar("shrt_t2") \
              .and.isvar("fname1").and.isvar("fname2").and.isvar("fname3") \
              .and.isvar("varcode").and.isvar("date1").and.isvar("en_mems") \
              )) then
    print("Can't find all input information!")
;    exit
  end if

; Check for lat/lon input information:
  if(.not.any(isvar("AWS_lat").and.isvar("AWS_lon"))) then
    print("Can't find latitude and longitude selections")
;    exit
  end if


; update titles to remove underscores:
  title0 = str_sub_str(title0,"_"," ")
  title1 = str_sub_str(title1,"_"," ")
  title2 = str_sub_str(title2,"_"," ")

; convert the number of ensemble members (inputted) into an integer
  en_num = stringtointeger(en_mems) 

; set outdir and fout names
  outdir = "./"
  fout = outdir+fname3

  print("Plotting stats for "+title0+", "+title1+", and "+title2+" for "+varcode)

; add in variable set as "varcode" from cshell wrapper. Assign it a title, units, etc.
  if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    units = "hPa  "
  end if
  if (varcode.eq."Z850") then
    vartitle1 = "Geopotential Height at 850mb"
    units = "m    "
  end if
  if (varcode.eq."Z700") then
    vartitle1 = "Geopotential Height at 700mb"
    units = "m    "
  end if
  if (varcode.eq."Z500") then
    vartitle1 = "Geopotential Height at 500mb"
    units = "m    "
  end if
  if (varcode.eq."Z300") then
    vartitle1 = "Geopotential Height at 300mb"
    units = "m    "
  end if
  if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2m"
    units = "C    "
  end if
  if (varcode.eq."T850") then
    vartitle1 = "Temperature at 850mb"
    units = "C    "
  end if
  if (varcode.eq."T700") then
    vartitle1 = "Temperature at 700mb"
    units = "C    "
  end if
  if (varcode.eq."T500") then
    vartitle1 = "Temperature at 500mb"
    units = "C    "
  end if
  if (varcode.eq."T300") then
    vartitle1 = "Temperature at 300mb"
    units = "C    "
  end if
 if (varcode.eq."Windsurf_s") then
    vartitle1 = "Wind Speed at 10m"
    units = "m/s"
  end if
  if (varcode.eq."Wind850_s") then
    vartitle1 = "Wind Speed at 850mb"
    units = "m/s"
  end if
  if (varcode.eq."Wind700_s") then
    vartitle1 = "Wind Speed at 700mb"
    units = "m/s"
  end if
  if (varcode.eq."Wind500_s") then
    vartitle1 = "Wind Speed at 500mb"
    units = "m/s"
  end if
  if (varcode.eq."Wind300_s") then
    vartitle1 = "Wind Speed at 300mb"
    units = "m/s"
  end if
  if (varcode.eq."Windsurf_d") then
    vartitle1 = "Wind Direction at 10m"
    units = "degrees"
    find_dir = True
  end if
  if (varcode.eq."Wind850_d") then
    vartitle1 = "Wind Direction at 850mb"
    units = "degrees"
    find_dir = True
  end if
  if (varcode.eq."Wind700_d") then
    vartitle1 = "Wind Direction at 700mb"
    units = "degrees"
    find_dir = True
  end if
  if (varcode.eq."Wind500_d") then
    vartitle1 = "Wind Direction at 500mb"
    units = "degrees"
    find_dir = True
  end if
  if (varcode.eq."Wind300_d") then
    vartitle1 = "Wind Direction at 300mb"
    units = "degrees"
    find_dir = True
  end if
  if (varcode.eq."Q2m") then
    varittle1 = "Mixing Ratio at 2m"
    units = "g/kg "
  end if
  if (varcode.eq."Q850") then
    vartitle1 = "Mixing Ratio at 850 mb"
    units = "g/kg "
  end if
  if (varcode.eq."Q500") then
    vartitle1 = "Mixing Ratio at 500 mb"
    units = "g/kg "
  end if
  if (varcode.eq."Q300") then
    vartitle1 = "Mixing Ratio at 300 mb"
    units = "g/kg "
  end if
  if (varcode.eq."ice") then
    units = "frac "
  end if
 if (varcode.eq."T_sfc") then
    units = "C    "
  end if
  if (varcode.eq."snow") then
    units = "kg/m2"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Make plots
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ncol = 10               ; number of columns in array
 header = 1             ; number of header lines

; load in data from ascii file
file1 = indir1+fname1+".txt"
file2 = indir2+fname2+".txt"
; read in dates from the first file
dates1 = readAsciiTable(file1,ncol,"integer",header)  ; read in ascii as float to get statistics
year = dates1(:,0)
month = dates1(:,1)
day = dates1(:,2)
hour = dates1(:,3)

;;;;;;;;;;;;;
; statistics from first file
;;;;;;;;;;;;;
stats1 = readAsciiTable(file1,ncol,"float",header)  ; read in ascii as float to get statistics
var1_1 = stats1(:,4)
var1_2 = stats1(:,5)
bias1 = stats1(:,6)
mae1 = stats1(:,7)
rmse1 = stats1(:,8)

;;;;;;;;;;;;;
; statistics from second file
;;;;;;;;;;;;;
stats2 = readAsciiTable(file2,ncol,"float",header)  ; read in ascii as float to get statistics
var2_1 = stats2(:,4)
var2_2 = stats2(:,5)
bias2 = stats2(:,6)
mae2 = stats2(:,7)
rmse2 = stats2(:,8)

;;;;;;;;;;;;;
; check that files match as expected
;;;;;;;;;;;;;
test = var2_1 - var1_1
test1 = avg(test)
  if(test1 .ne.0) 
    print("ERA data does not match, something went wrong.")
    exit
  end if
;;;;;;;;;;;;;
; convert times to Julian day for nicer plots
;;;;;;;;;;;;;
  julian = greg2jul(year,month,day,hour) ; convert times to julian day so that the data plots correctly
  time = julian - julian(0) ; normalize the J.days so that they are fractional days

; make arrays of the statistics to use in the plots

diml = dimsizes(year)

;;;;;;;;;;;;;
; timeseries data
;;;;;;;;;;;;;
data_all = new((/en_num,diml/),"double")
data_all(0,:) = var1_2
data_all(1,:) = var2_2
data_all(2,:) = var1_1   ; ERA-Interim data

;;;;;;;;;;;;;
; bias array
;;;;;;;;;;;;;
bias_all = new((/en_num-1,diml/),"double")
bias_all(0,:) = bias1
bias_all(1,:) = bias2

;;;;;;;;;;;;;
; rmse array
;;;;;;;;;;;;;
rmse_all = new((/en_num-1,diml/),"double")
rmse_all(0,:) = rmse1
rmse_all(1,:) = rmse2

;;;;;;;;;;;;;
; correlation array
;;;;;;;;;;;;;
;corr_all = new((/en_num-1,diml/),"double")
;corr_all(0,:) = corr1
;corr_all(1,:) = corr2

;;;;;;;;;;;;;
; Calculating monthly average stats
;;;;;;;;;;;;;
corr_avg1 = escorc(var1_1,var1_2)
bias_avg1 = avg(bias1)
rmse_avg1 = avg(rmse1)
mae_avg1 = avg(mae1)

corr_avg2 = escorc(var1_1,var2_2)
bias_avg2 = avg(bias2)
rmse_avg2 = avg(rmse2)
mae_avg2 = avg(mae2)

;;;;;;;;;;;;;
; Write Monthly avg stats to a text file 
;;;;;;;;;;;;;
 header1 = varcode+" Monthly avg stats"
 header2 = shrt_t1+" bias    MAE     RMSE    CORR   "+shrt_t2+" bias    MAE     RMSE    CORR"
 head = array_append_record(header1,header2,0)

; write line of statistics outputs to 4 decimal points
a1 = sprintf("%10.4f",bias_avg1)+sprintf("%10.4f",mae_avg1)+sprintf("%10.4f",rmse_avg1)+sprintf("%10.4f",corr_avg1)+\
     sprintf("%10.4f",bias_avg2)+sprintf("%10.4f",mae_avg2)+sprintf("%10.4f",rmse_avg2)+sprintf("%10.4f",corr_avg2)

output = array_append_record(head,a1,0)  ; append the new statistics output (a1) to the previous outputs(output)

asciiwrite(fout+".txt",output)  ; write the text to an output file with name fout

;;;;;;;;;;;;;
; Plotting:
;;;;;;;;;;;;;
print ("Plotting time series, bias, and rmse")

  wks = gsn_open_wks("ps",fout)
 
  plot = new(3, graphic)

; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance frame
  res@gsnMaximize                 = True              ; maximize plot

; set title resources
  res@tiMainOn                    = True              ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.02              ; set size of font for main plot

; set x axist tick marks
  res@tmXTOn                      = False             ; delete top and right ticks
  res@tmYROn                      = False
  res@trXMinF                     = min(time)         ; set lower x limit
  res@trXMaxF                     = max(time)         ; set upper x limit
  res@tmXBMode                    = "Manual"          ; specify the tick label spacing myself
  res@tmXBTickStartF              = round(time(0),0)
  res@tmXBTickEndF                = round(time(diml-1),0)
  res@tmXBTickSpacingF            = 5                 ; setting the spacing for the day of the month ticks
  res@tmXBMinorOn                 = True              ; setting the number of days between major ticks
  res@tmXBMinorPerMajor           = 4
  res@tiXAxisString               = "Day of the Month" ; set title for x axis
  res@tiXAxisFontHeightF          = 0.015             ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.015             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.015             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.015             ; set tick mark label size for y axis
  res@vpHeightF                   = 0.2               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 1.0               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyLineColors                = (/"blue","red","black","green","orange"/)
   res@xyDashPatterns              = (/0,0,0,0,0/)
   res@xyMonoLineColor             = False             ; allow other line colors
   res@xyMarkLineModes              = (/"Lines"/)           ; use both lines and markers (opts: Markers, Lines, MarkLines)
   if (isvar("find_dir").and.(find_dir)) then
     res@xyMarkLineMode            = "Markers"
     res@xyMarkerColors            = (/"blue","red","black","green","orange"/)
   end if

; legend resources for all the plots
  lgres                    = True
  lgres@lgLineColors       = res@xyLineColors   ; make the colors for the legend
  lgres@lgMonoDashIndex    = True               ; sets both contour lines to same dash type
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  lgres@vpWidthF           = 0.30               ; width of legend (NDC)
  lgres@vpHeightF          = 0.05               ; height of legend (NDC)
  lgres@lgLabelFontHeightF = 0.03
  lgres@lgLineLabelStrings = (/"", "",""/)         ; take of any automatic line labels for all data

;;;;;;;;;;;;;
; Plot 1 - monthly trend of outputs
;;;;;;;;;;;;;
title = "Timeseries"            ; make a title string for the overlay plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(var1_1)
  opts@tmYLTickEndF               = max(var1_1)
  opts@tiYAxisString              = units
  
  cplot1 = gsn_csm_xy(wks,time,data_all,opts)      ; create plot of first time series
  plot(0) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

; legend resources- for plot 1 overlay
  ledgres                    = lgres
  lbid = gsn_create_legend(wks,en_num,(/title1, title2, title0/),ledgres)         ; create legend

; annotate first plot by adding legend
  amres                    = True
  amres@amParallelPosF     = 0.33	        ; move legend to the left or right
  amres@amOrthogonalPosF   = -0.64               ; move the legend down or up (neg = up)
  annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

  delete(ledgres)
  delete(lbid)

;;;;;;;;;;;;;
; Plot 2 - bias
;;;;;;;;;;;;;
title = "Bias"              ; make a title string for the difference plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(bias1)
  opts@tmYLTickEndF               = max(bias1)
  opts@tiYAxisString              = units
  opts@gsnYRefLine                = 0.0               ; create a reference line at zero

  cplot2 = gsn_csm_xy(wks,time,bias_all,opts)  ; create plot of first contours
  plot(1) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

; legend resources- for plot 2 overlay
  ledgres                  = lgres
  lbid = gsn_create_legend(wks,en_num-1,(/title1+" - "+title0, title2+" - "+title0/),lgres)         ; create legend
; annotate first plot by adding legend
  amres                    = True
  amres@amParallelPosF     = 0.33	        ; move legend to the left or right
  amres@amOrthogonalPosF   = -0.64               ; move the legend down or up (neg = up)
  annoid1 = gsn_add_annotation(plot(1),lbid,amres)   ; add legend to plot

  delete(ledgres)
  delete(lbid)

;;;;;;;;;;;;;
; Plot 3 - RMSE
;;;;;;;;;;;;;
title = "Root Mean Square Error"             ; set title for plot. designated above as both input names

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            
  opts@tmYLTickStartF             = min(rmse1)
  opts@tmYLTickEndF               = max(rmse1)
  opts@tiYAxisString              = units

  cplot3 = gsn_csm_xy(wks,time,rmse_all,opts)  ; create plot of first contours
  plot(2) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

; legend resources- for plot 3 overlay
  ledgres                  = lgres
  lbid = gsn_create_legend(wks,en_num-1,(/title1+" & "+title0, title2+" & "+title0/),lgres)         ; create legend
; annotate first plot by adding legend
  amres                    = True
  amres@amParallelPosF     = 0.33	        ; move legend to the left or right
  amres@amOrthogonalPosF   = -0.64               ; move the legend down or up (neg = up)
  annoid1 = gsn_add_annotation(plot(2),lbid,amres)   ; add legend to plot

  delete(ledgres)
  delete(lbid)

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  title5 = "Statistics for "+date1+" "+vartitle1+" at Lat "+AWS_lat+"N and Lon "+AWS_lon+"W"  

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/3,1/),pnlres)               ; create final panel plot
  
;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

system(convert_cmd)
print("Plots completed")

; delete all variables and resources
  delete(wks)
  delete(plot)
  delete(convert_cmd)
  delete(lgres)
  delete(res)
  delete(pnlres)

end
