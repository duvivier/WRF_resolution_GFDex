;***************************************
; PROGRAM DESCRIPTION: This NCL script plots surface variables 
; INPUT DATA: Text file with surface data from excel for all days 
;             for each model resolution
; OUTPUT DATA: Panel plots of the variable along surface paths
; Note: preprocessing of data is necessary from 'wrf_sfc_line*txt.ncl' AND 
;       microsoft excel saved as tab delimited file of all text files
; CREATOR: Alice DuVivier - July 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
indir = "./"
en_num = 4

fname1 = indir + "wrf_100km_sfc_all.txt"
fname2 = indir + "wrf_50km_sfc_all.txt"
fname3 = indir + "wrf_25km_sfc_all.txt"
fname4 = indir + "wrf_10km_sfc_all.txt"

title1 = "WRF 100" 
title2 = "WRF 50" 
title3 = "WRF 25"
title4 = "WRF 10"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout = outdir + "sfc_plots_allGFDex_allWRF"

print("Plotting stats for GFDex days")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be txt files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ncol = 16               ; number of columns in array
 header = 1             ; number of header lines

;; load data from ascii files
;; at the same time put the data into arrays by variable
;;;;;;;;;;;;;
; load data 
;;;;;;;;;;;;;
data1    = asciiread(fname1,(/260,16/), "float")
data2    = asciiread(fname2,(/260,16/), "float")
data3    = asciiread(fname3,(/260,16/), "float")
data4    = asciiread(fname4,(/260,16/), "float")

;data1    = readAsciiTable(fname1, ncol, "float", header)
;data2    = readAsciiTable(fname2, ncol, "float", header)
;data3    = readAsciiTable(fname3, ncol, "float", header)
;data4    = readAsciiTable(fname4, ncol, "float", header)

xtit = data4(:,1)     ; array for flight # as xtitles... not sure if this will work
diml = dimsizes(xtit)

;;;;;;;;;;;;;
; Make variable arrays - arrangement = (L->R) 100km, 50km, 25km, 10km)
;;;;;;;;;;;;;
elev_all = new((/en_num,diml/),"float")
   elev_all(0,:) = data1(:,4)
   elev_all(1,:) = data2(:,4)
   elev_all(2,:) = data3(:,4)
   elev_all(3,:) = data4(:,4)
   elev_all@long_name = "Height ASL"
   elev_all@units = "m"

seaice_all =  new((/en_num,diml/),"float")
   seaice_all(0,:) = data1(:,5)
   seaice_all(1,:) = data2(:,5)
   seaice_all(2,:) = data3(:,5)
   seaice_all(3,:) = data4(:,5)
   seaice_all@long_name = "Sea Ice Fraction"

T2m_all = new((/en_num,diml/),"float")
   T2m_all(0,:) = data1(:,6)
   T2m_all(1,:) = data2(:,6)
   T2m_all(2,:) = data3(:,6)
   T2m_all(3,:) = data4(:,6)
   T2m_all@long_name = "Temperature at 2m"
   T2m_all@units = "K"

Q2m_all = new((/en_num,diml/),"float")
   Q2m_all(0,:) = data1(:,7)
   Q2m_all(1,:) = data2(:,7)
   Q2m_all(2,:) = data3(:,7)
   Q2m_all(3,:) = data4(:,7)
   Q2m_all@long_name = "Mixing Ratio at 2m"
   Q2m_all@units = "g kg-1"

Tsurf_all = new((/en_num,diml/),"float")
   Tsurf_all(0,:) = data1(:,8)
   Tsurf_all(1,:) = data2(:,8)
   Tsurf_all(2,:) = data3(:,8)
   Tsurf_all(3,:) = data4(:,8)
   Tsurf_all@long_name = "Sea Surface Temperature"
   Tsurf_all@units = "K"

LHFlx_all = new((/en_num,diml/),"float")
   LHFlx_all(0,:) = data1(:,9)
   LHFlx_all(1,:) = data2(:,9)
   LHFlx_all(2,:) = data3(:,9)
   LHFlx_all(3,:) = data4(:,9)
   LHFlx_all@long_name = "Latent Heat Flux at Surface"
   LHFlx_all@units = "W m-2"

SHFlx_all = new((/en_num,diml/),"float")
   SHFlx_all(0,:) = data1(:,10)
   SHFlx_all(1,:) = data2(:,10)
   SHFlx_all(2,:) = data3(:,10)
   SHFlx_all(3,:) = data4(:,10)
   SHFlx_all@long_name = "Sensible Heat Flux at Surface"
   SHFlx_all@units = "W m-2"

ustar_all = new((/en_num,diml/),"float")
   ustar_all(0,:) = data1(:,11)
   ustar_all(1,:) = data2(:,11)
   ustar_all(2,:) = data3(:,11)
   ustar_all(3,:) = data4(:,11)
   ustar_all@long_name = "Ustar"
   ustar_all@units = "m s-1"

wnd10m_all = new((/en_num,diml/),"float")
   wnd10m_all(0,:) = data1(:,12)
   wnd10m_all(1,:) = data2(:,12)
   wnd10m_all(2,:) = data3(:,12)
   wnd10m_all(3,:) = data4(:,12)
   wnd10m_all@long_name = "10 m Wind Speed"
   wnd10m_all@units = "m s-1"


; make array to plot values against
xtit2 = new((/diml/),"integer")
   do i = 0,diml-1
     xtit2(i) = i
   end do

print ("Plotting surface data")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot data from each resolution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;
  
  wks = gsn_open_wks("ps",fout)
 
  plot = new(8, graphic)

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
  res@trXMinF                     = min(xtit2)         ; set lower x limit
  res@trXMaxF                     = max(xtit2)         ; set upper x limit

  ;res@tmYLMode                    = "Manual"
  res@tmXBMode                    = "Explicit"
  res@tmXBValues                  = (/0, 44, 159, 189/)
  res@tmXBLabels                  = (/"B274", "B276", "B277", "B278"/)

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
  ;opts@tmYLTickStartF             = 263.
  ;opts@tmYLTickEndF               = 279.
  ;opts@tmYLTickStartF             = min(T2m_all)
  ;opts@tmYLTickEndF               = max(T2m_all)
  opts@tiYAxisString              = T2m_all@units
  
  cplot0 = gsn_csm_xy(wks, xtit2, T2m_all, opts)      ; create plot of first time series
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - Q2m
;;;;;;;;;;;;;
title = Q2m_all@long_name + " (" + Q2m_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  ;opts@tmYLTickStartF             = 0.
  ;opts@tmYLTickEndF               = 6.
  ;opts@tmYLTickStartF             = min(Q2m_all)
  ;opts@tmYLTickEndF               = max(Q2m_all)
  opts@tiYAxisString              = Q2m_all@units
  
  cplot1 = gsn_csm_xy(wks, xtit2, Q2m_all, opts)      ; create plot of first time series
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 3 - 10m Wind
;;;;;;;;;;;;;
title = wnd10m_all@long_name + " (" + wnd10m_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  ;opts@tmYLTickStartF             = 0
  ;opts@tmYLTickEndF               = 35
  ;opts@tmYLTickStartF             = min(wnd10m_all)
  ;opts@tmYLTickEndF               = max(wnd10m_all)
  opts@tiYAxisString              = wnd10m_all@units
  
  cplot2 = gsn_csm_xy(wks, xtit2, wnd10m_all, opts)      ; create plot of first time series
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 4 - LHFlux at Surface
;;;;;;;;;;;;;
title = LHFlx_all@long_name + " (" + LHFlx_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  ;opts@tmYLTickStartF             = 0
  ;opts@tmYLTickEndF               = 600
  ;opts@tmYLTickStartF             = min(LHFlx_all)
  ;opts@tmYLTickEndF               = max(LHFlx_all)
  opts@tiYAxisString              = LHFlx_all@units
  
  cplot5 = gsn_csm_xy(wks, xtit2, LHFlx_all, opts)      ; create plot of first time series
  plot(5) = cplot5                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 5 - SHFlux at Surface
;;;;;;;;;;;;;
title = SHFlx_all@long_name + " (" + SHFlx_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  ;opts@tmYLTickStartF             = 0
  ;opts@tmYLTickEndF               = 800
  ;opts@tmYLTickStartF             = min(SHFlx_all)
  ;opts@tmYLTickEndF               = max(SHFlx_all)
  opts@tiYAxisString              = SHFlx_all@units
  
  cplot4 = gsn_csm_xy(wks, xtit2, SHFlx_all, opts)      ; create plot of first time series
  plot(4) = cplot4                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 6 - UStar
;;;;;;;;;;;;;
;title = ustar_all@long_name + " (" + ustar_all@units + ")"           ; make a title string for the plot

;  opts                            = res               ; set resources for plot 1 to be same as specified above
;  opts@tiMainString               = title            ; set title for plot. designated above as both input names
;  opts@tmYLTickStartF             = min(ustar_all)
;  opts@tmYLTickEndF               = max(ustar_all)
;  opts@tiYAxisString              = ustar_all@units
  
;  cplot5 = gsn_csm_xy(wks, xtit2, ustar_all, opts)      ; create plot of first time series
;  plot(5) = cplot5                              ; make panel section of this plot
;  delete(opts)
;  delete(title)

;;;;;;;;;;;;;
; Plot 7 - SST
;;;;;;;;;;;;;
title = Tsurf_all@long_name + " (" + Tsurf_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  ;opts@tmYLTickStartF             = 260
  ;opts@tmYLTickEndF               = 285
  ;opts@tmYLTickStartF             = min(Tsurf_all)
  ;opts@tmYLTickEndF               = max(Tsurf_all)
  opts@tiYAxisString              = Tsurf_all@units
  
  cplot3 = gsn_csm_xy(wks, xtit2, Tsurf_all, opts)      ; create plot of first time series
  plot(3) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 8 - Elevation
;;;;;;;;;;;;;
title = seaice_all@long_name + " (1=ice, 0 = water)"

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = 0
  opts@tmYLTickEndF               = 1
  opts@tiYAxisString              = "Fraction"

  
  cplot7 = gsn_csm_xy(wks, xtit2, seaice_all, opts)      ; create plot of first time series
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
title = elev_all@long_name + " (" + elev_all@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tmYLTickStartF             = min(elev_all)
  opts@tmYLTickEndF               = max(elev_all)
  opts@tiYAxisString              = elev_all@units

  
  cplot6 = gsn_csm_xy(wks, xtit2, elev_all, opts)      ; create plot of first time series
  plot(6) = cplot6                              ; make panel section of this plot
  delete(opts)
  delete(title)


 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  title5 = "WRF surface output for all resolutions at GFDex flight locations" 

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/4,2/),pnlres)               ; create final panel plot
  
print("Plots Completed")

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





