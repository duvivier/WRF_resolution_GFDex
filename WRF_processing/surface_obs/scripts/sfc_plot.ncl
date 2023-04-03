;***************************************
; PROGRAM DESCRIPTION: This NCL script plots surface variables along
;                      a particular line for a particular day
; INPUT DATA: Text file with surface data created with 'wrf_sfc_line*txt.ncl'
;             script for a particular day and line
; OUTPUT DATA: Panel plots of the variable along the line
; CREATOR: Alice DuVivier - July 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
indir1 = "/data3/duvivier/NCAR/surface_obs/05MAR/"
date1 = "2007-03-05-14"
type = "_sfc_obs_"
en_mems = "4"

title1 = "WRF_100" 
title2 = "WRF_50" 
title3 = "WRF_25"
title4 = "WRF_10"


; BEGIN SCRIPT
fname1   = indir1 + title1  + type + date1 + ".txt"
fname2   = indir1 + title2  + type + date1 + ".txt"
fname3   = indir1 + title3  + type + date1 + ".txt"
fname4   = indir1 + title4  + type + date1 + ".txt"

; update titles to remove underscores:
title1 = str_sub_str(title1,"_"," ")
title2 = str_sub_str(title2,"_"," ")
title3 = str_sub_str(title3,"_"," ")
title4 = str_sub_str(title4,"_"," ")

; convert the number of ensemble members (inputted) into an integer
en_num = stringtointeger(en_mems) 

; set outdir and fout names
outdir = "./"
fout = outdir + date1 + type + "plots"

print("Plotting stats for " + date1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be txt files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ncol = 12               ; number of columns in array
 header = 1             ; number of header lines

;;load data from ascii files
;;;;;;;;;;;;;
; load first file data
;;;;;;;;;;;;;
data1 = readAsciiTable(fname1, ncol, "float", header)
dist_1 = data1(:,2)
elev_1 = data1(:,3)
seaice_1 = data1(:,4)
T2m_1 = data1(:,5)
Q2m_1 = data1(:,6)
Tsurf_1 = data1(:,7)
LHFlx_1 = data1(:,8)
SHFlx_1 = data1(:,9)
ustar_1 = data1(:,10)
wnd10m_1 = data1(:,11)

;;;;;;;;;;;;;
; load second file data
;;;;;;;;;;;;;
data2 = readAsciiTable(fname2, ncol, "float", header)
dist_2 = data2(:,2)
elev_2 = data2(:,3)
seaice_2 = data2(:,4)
T2m_2 = data2(:,5)
Q2m_2 = data2(:,6)
Tsurf_2 = data2(:,7)
LHFlx_2 = data2(:,8)
SHFlx_2 = data2(:,9)
ustar_2 = data2(:,10)
wnd10m_2 = data2(:,11)

;;;;;;;;;;;;;
; load third file data
;;;;;;;;;;;;;
data3 = readAsciiTable(fname3, ncol, "float", header)
dist_3 = data3(:,2)
elev_3 = data3(:,3)
seaice_3 = data3(:,4)
T2m_3 = data3(:,5)
Q2m_3 = data3(:,6)
Tsurf_3 = data3(:,7)
LHFlx_3 = data3(:,8)
SHFlx_3 = data3(:,9)
ustar_3 = data3(:,10)
wnd10m_3 = data3(:,11)

;;;;;;;;;;;;;
; load fourth file data
;;;;;;;;;;;;;
data4 = readAsciiTable(fname4, ncol, "float", header)
dist_4 = data4(:,2)
elev_4 = data4(:,3)
seaice_4 = data4(:,4)
T2m_4 = data4(:,5)
Q2m_4 = data4(:,6)
Tsurf_4 = data4(:,7)
LHFlx_4 = data4(:,8)
SHFlx_4 = data4(:,9)
ustar_4 = data4(:,10)
wnd10m_4 = data4(:,11)


diml = dimsizes(dist_4)
;;;;;;;;;;;;;
; load fourth file data
;;;;;;;;;;;;;
elev_all = new((/en_num,diml/),"float")
   elev_all(0,:) = elev_1
   elev_all(1,:) = elev_2
   elev_all(2,:) = elev_3
   elev_all(3,:) = elev_4
   elev_all@long_name = "Height ASL"
   elev_all@units = "m"
seaice_all =  new((/en_num,diml/),"float")
   seaice_all(0,:) = seaice_1
   seaice_all(1,:) = seaice_2
   seaice_all(2,:) = seaice_3
   seaice_all(3,:) = seaice_4
   seaice_all@long_name = "Sea Ice Fraction"
T2m_all = new((/en_num,diml/),"float")
   T2m_all(0,:) = T2m_1
   T2m_all(1,:) = T2m_2
   T2m_all(2,:) = T2m_3
   T2m_all(3,:) = T2m_4
   T2m_all@long_name = "Temperature at 2m"
   T2m_all@units = "degC"
Q2m_all = new((/en_num,diml/),"float")
   Q2m_all(0,:) = Q2m_1
   Q2m_all(1,:) = Q2m_2
   Q2m_all(2,:) = Q2m_3
   Q2m_all(3,:) = Q2m_4
   Q2m_all@long_name = "Mixing Ratio at 2m"
   Q2m_all@units = "g kg-1"
Tsurf_all = new((/en_num,diml/),"float")
   Tsurf_all(0,:) = Tsurf_1
   Tsurf_all(1,:) = Tsurf_2
   Tsurf_all(2,:) = Tsurf_3
   Tsurf_all(3,:) = Tsurf_4
   Tsurf_all@long_name = "Sea Surface Temperature"
   Tsurf_all@units = "K"
LHFlx_all = new((/en_num,diml/),"float")
   LHFlx_all(0,:) = LHFlx_1
   LHFlx_all(1,:) = LHFlx_2
   LHFlx_all(2,:) = LHFlx_3
   LHFlx_all(3,:) = LHFlx_4
   LHFlx_all@long_name = "Latent Heat Flux at Surface"
   LHFlx_all@units = "W m-2"
SHFlx_all = new((/en_num,diml/),"float")
   SHFlx_all(0,:) = SHFlx_1
   SHFlx_all(1,:) = SHFlx_2
   SHFlx_all(2,:) = SHFlx_3
   SHFlx_all(3,:) = SHFlx_4
   SHFlx_all@long_name = "Sensible Heat Flux at Surface"
   SHFlx_all@units = "W m-2"
ustar_all = new((/en_num,diml/),"float")
   ustar_all(0,:) = ustar_1
   ustar_all(1,:) = ustar_2
   ustar_all(2,:) = ustar_3
   ustar_all(3,:) = ustar_4
   ustar_all@long_name = "Ustar"
   ustar_all@units = "m s-1"
wnd10m_all = new((/en_num,diml/),"float")
   wnd10m_all(0,:) = wnd10m_1
   wnd10m_all(1,:) = wnd10m_2
   wnd10m_all(2,:) = wnd10m_3
   wnd10m_all(3,:) = wnd10m_4
   wnd10m_all@long_name = "10 m Wind Speed"
   wnd10m_all@units = "m s-1"


print ("Plotting surface data")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot data from each resolution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;
  
  wks = gsn_open_wks("ps",fout)
 
  plot = new(9, graphic)

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
  res@trXMinF                     = min(dist_1)         ; set lower x limit
  res@trXMaxF                     = max(dist_1)         ; set upper x limit
  res@tmXBMode                    = "Manual"          ; specify the tick label spacing myself
  res@tmXBTickStartF              = round(dist_1(0),0)
  res@tmXBTickEndF                = round(dist_1(diml-1),0)
  res@tmXBTickSpacingF            = 12                 ; setting the spacing for ticks
  res@tmXBMinorOn                 = True              ; setting the number of days between major ticks
  res@tmXBMinorPerMajor           = 1
  res@tiXAxisString               = "Distance (km)" ; set title for x axis
  res@tiXAxisFontHeightF          = 0.015             ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.015             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.015             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.015             ; set tick mark label size for y axis
  res@vpHeightF                   = 0.2               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 0.9               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyLineColors               = (/ "black", "red", "green", "blue","orange"/)
   res@xyDashPatterns             = (/0,0,0,0,0/)
   res@xyMonoLineColor             = False                 ; allow other line colors
   res@xyMarkLineMode              = (/"Lines"/)           ; use both lines and markers (opts: Markers, Lines, MarkLines)


; legend resources for all the plots
  lgres                    = True
  lgres@lgLineColors       = res@xyLineColors   ; make the colors for the legend
  lgres@lgMonoDashIndex    = True               ; sets both contour lines to same dash type
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  lgres@vpWidthF           = 0.30               ; width of legend (NDC)
  lgres@vpHeightF          = 0.08               ; height of legend (NDC)
  lgres@lgLabelFontHeightF = 0.03
  lgres@lgLineLabelStrings = (/"", "", "", ""/)         ; take of any automatic line labels

;;;;;;;;;;;;;
; Plot 1 - T2m
;;;;;;;;;;;;;
title = T2m_all@long_name + " (" + T2m_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(T2m_all)
  opts@tmYLTickEndF               = max(T2m_all)
  opts@tiYAxisString              = T2m_all@units
  
  cplot0 = gsn_csm_xy(wks, dist_1, T2m_all, opts)      ; create plot of first time series
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - Q2m
;;;;;;;;;;;;;
title = Q2m_all@long_name + " (" + Q2m_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(Q2m_all)
  opts@tmYLTickEndF               = max(Q2m_all)
  opts@tiYAxisString              = Q2m_all@units
  
  cplot1 = gsn_csm_xy(wks, dist_1, Q2m_all, opts)      ; create plot of first time series
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 3 - 10m Wind
;;;;;;;;;;;;;
title = wnd10m_all@long_name + " (" + wnd10m_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(wnd10m_all)
  opts@tmYLTickEndF               = max(wnd10m_all)
  opts@tiYAxisString              = wnd10m_all@units
  
  cplot2 = gsn_csm_xy(wks, dist_1, wnd10m_all, opts)      ; create plot of first time series
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 4 - LHFlux at Surface
;;;;;;;;;;;;;
title = LHFlx_all@long_name + " (" + LHFlx_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(LHFlx_all)
  opts@tmYLTickEndF               = max(LHFlx_all)
  opts@tiYAxisString              = LHFlx_all@units
  
  cplot3 = gsn_csm_xy(wks, dist_1, LHFlx_all, opts)      ; create plot of first time series
  plot(3) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 5 - SHFlux at Surface
;;;;;;;;;;;;;
title = SHFlx_all@long_name + " (" + SHFlx_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(SHFlx_all)
  opts@tmYLTickEndF               = max(SHFlx_all)
  opts@tiYAxisString              = SHFlx_all@units
  
  cplot4 = gsn_csm_xy(wks, dist_1, SHFlx_all, opts)      ; create plot of first time series
  plot(4) = cplot4                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 6 - UStar
;;;;;;;;;;;;;
title = ustar_all@long_name + " (" + ustar_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(ustar_all)
  opts@tmYLTickEndF               = max(ustar_all)
  opts@tiYAxisString              = ustar_all@units
  
  cplot5 = gsn_csm_xy(wks, dist_1, ustar_all, opts)      ; create plot of first time series
  plot(5) = cplot5                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 7 - SST
;;;;;;;;;;;;;
title = Tsurf_all@long_name + " (" + Tsurf_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(Tsurf_all)
  opts@tmYLTickEndF               = max(Tsurf_all)
  opts@tiYAxisString              = Tsurf_all@units
  
  cplot6 = gsn_csm_xy(wks, dist_1, Tsurf_all, opts)      ; create plot of first time series
  plot(6) = cplot6                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 8 - Elevation
;;;;;;;;;;;;;
title = elev_all@long_name + " (" + elev_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(elev_all)
  opts@tmYLTickEndF               = max(elev_all)
  opts@tiYAxisString              = elev_all@units
  
  cplot7 = gsn_csm_xy(wks, dist_1, elev_all, opts)      ; create plot of first time series
  plot(7) = cplot7                              ; make panel section of this plot
  delete(opts)
  delete(title)

  ;; legend resources- for plot 1 overlay
   ledgres                    = lgres
   lbid = gsn_create_legend(wks,en_num,(/title1, title2, title3, title4/),lgres)         ; create legend

  ;; annotate first plot by adding legend
   amres                    = True
   amres@amParallelPosF     = 0.33	        ; move legend to the left or right
   amres@amOrthogonalPosF   = -0.3               ; move the legend down or up (neg = up)
   annoid1 = gsn_add_annotation(plot(7),lbid,amres)   ; add legend to plot

   delete(ledgres)
   delete(lbid)

;;;;;;;;;;;;;
; Plot 9 - Sea Ice Fraction
;;;;;;;;;;;;;
title = seaice_all@long_name + " (1=ice, 0 = water)"

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = 0
  opts@tmYLTickEndF               = 1
  opts@tiYAxisString              = "Fraction"
  
  cplot8 = gsn_csm_xy(wks, dist_1, seaice_all, opts)      ; create plot of first time series
  plot(8) = cplot8                              ; make panel section of this plot
  delete(opts)
  delete(title)


 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  title5 = "WRF Model Output at the Surface for  Different Resolutions on " + date1

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/3,3/),pnlres)               ; create final panel plot
  
print("Plots Completed")

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





