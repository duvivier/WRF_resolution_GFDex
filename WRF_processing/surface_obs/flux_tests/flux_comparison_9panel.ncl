;***************************************
; PROGRAM DESCRIPTION: This NCL script plots LHFlx surface variables 
; INPUT DATA: Text file with surface data from excel for all days 
;             for each model resolution
; OUTPUT DATA: Panel plots of the variable along surface paths
; Note: preprocessing of data is necessary from 'wrf_sfc_line*txt.ncl' AND 
;       microsoft excel saved as tab delimited file of all text files
;       This script plots only surface data from 2 and 5 March
; CREATOR: Alice DuVivier - July 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
indir = "./txt_files/"
en_num = 5

fname1 = indir + "wrf_10km_ysu0.185_sfc_all.txt"
fname2 = indir + "wrf_10km_ysu0.15_sfc_all.txt"
fname3 = indir + "wrf_10km_myj0.18_sfc_all.txt"
fname4 = indir + "wrf_10km_myj0.15_sfc_all.txt"
fname5 = indir + "GFDex_sfc_recalc.txt"
fname6 = indir + "GFDex_sfc_all.txt"

title1 = "YSU-0.18"
title2 = "YSU-0.15"
title3 = "MYJ-0.18"
title4 = "MYJ-0.15"
title5 = "GFDex-MYJ"
title6 = "GFDex-COARE"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout = outdir + "flux_compare_all"

print("Plotting stats for GFDex days")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be txt files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ncol = 11               ; number of columns in array
 nrow = 129             ; number of rows in array (the header is removed already)
 header = 1             ; number of header lines

;; load data from ascii files
;; at the same time put the data into arrays by variable
;;;;;;;;;;;;;
; load data 
;;;;;;;;;;;;;
data1    = asciiread(fname1,(/nrow,ncol/), "float")
data2    = asciiread(fname2,(/nrow,ncol/), "float")
data3    = asciiread(fname3,(/nrow,ncol/), "float")
data4    = asciiread(fname4,(/nrow,ncol/), "float")
data5    = asciiread(fname5,(/nrow,ncol/), "float")
data6    = asciiread(fname6,(/nrow,20/), "float")

xtit = data4(:,1)     ; array for flight # as xtitles... not sure if this will work
diml = dimsizes(xtit)
dim  = dimsizes(xtit(0:81))

; make array to plot values against (SPECIFIED MANUALLY)
xtit2 = new((/dim/),"integer")
   do i = 0,dim-1
     xtit2(i) = i
   end do

test = new((/1/),"float")
fill = test@_FillValue

;;;;;;;;;;;;;
; Make variable arrays - arrangement = (L->R) 100km, 50km, 25km, 10km, GFDex)
;;;;;;;;;;;;;
wnd10m_all = new((/en_num+1,diml/),"float")
   wnd10m_all(0,:) = data1(:,4)   ; YSU 0.185
   wnd10m_all(1,:) = data2(:,4)   ; YSU 0.15
   wnd10m_all(2,:) = data3(:,4)   ; MYJ 0.18
   wnd10m_all(3,:) = data4(:,4)   ; MYJ 0.15
   wnd10m_all(4,:) = data5(:,4)   ; GFDex recalc
   wnd10m_all(5,:) = data6(:,5)   ; GFDEX coare
   wnd10m_all@long_name = "10 m Wind Speed"
   wnd10m_all@units = "m s-1"
   if (any(isnan_ieee(wnd10m_all)))then
     replace_ieeenan(wnd10m_all, fill, 0)
     wnd10m_all@_FillValue = fill
   end if

Qsurf_all = new((/en_num+1,diml/),"float")
   Qsurf_all(0,:) = data1(:,5)
   Qsurf_all(1,:) = data2(:,5)
   Qsurf_all(2,:) = data3(:,5)
   Qsurf_all(3,:) = data4(:,5)
   Qsurf_all(4,:) = data5(:,5)
   Qsurf_all(5,:) = data6(:,6)   ; GFDex coare
   Qsurf_all@long_name =  "Saturation Mixing Ratio at Surface"
   Qsurf_all@units = "g kg-1"
   if (any(isnan_ieee(Qsurf_all)))then
     replace_ieeenan(Qsurf_all, fill, 0)
     Qsurf_all@_FillValue = fill
   end if

Q2m_all = new((/en_num+1,diml/),"float")
   Q2m_all(0,:) = data1(:,6)
   Q2m_all(1,:) = data2(:,6)
   Q2m_all(2,:) = data3(:,6)
   Q2m_all(3,:) = data4(:,6)
   Q2m_all(4,:) = data5(:,6)
   Q2m_all(5,:) = data6(:,8)    ; GFDex coare
   Q2m_all@long_name = "Mixing Ratio at 2m"
   Q2m_all@units = "g kg-1"
   if (any(isnan_ieee(Q2m_all)))then
     replace_ieeenan(Q2m_all, fill, 0)
     Q2m_all@_FillValue = fill
   end if

Qgrad_all = Qsurf_all - Q2m_all

Tsurf_all = new((/en_num+1,diml/),"float")
   Tsurf_all(0,:) = data1(:,7)
   Tsurf_all(1,:) = data2(:,7)
   Tsurf_all(2,:) = data3(:,7)
   Tsurf_all(3,:) = data4(:,7)
   Tsurf_all(4,:) = data5(:,7)
   Tsurf_all(5,:) = data6(:,9)    ; GFDex
   Tsurf_all@long_name = "Sea Surface Temperature"
   Tsurf_all@units = "K"
   if (any(isnan_ieee(Tsurf_all)))then
     replace_ieeenan(Tsurf_all, fill, 0)
     Tsurf_all@_FillValue = fill
   end if

T2m_all = new((/en_num+1,diml/),"float")
   T2m_all(0,:) = data1(:,8)
   T2m_all(1,:) = data2(:,8)
   T2m_all(2,:) = data3(:,8)
   T2m_all(3,:) = data4(:,8)
   T2m_all(4,:) = data5(:,8)
   T2m_all(5,:) = data6(:,11)    ; GFDex coare
   T2m_all@long_name = "Temperature at 2m"
   T2m_all@units = "K"
   if (any(isnan_ieee(T2m_all)))then
     replace_ieeenan(T2m_all, fill, 0)
     T2m_all@_FillValue = fill
   end if

Tgrad_all = Tsurf_all - T2m_all

LHFlx_all = new((/en_num+2,diml/),"float")
   LHFlx_all(0,:) = data1(:,9)
   LHFlx_all(1,:) = data2(:,9)
   LHFlx_all(2,:) = data3(:,9)
   LHFlx_all(3,:) = data4(:,9)
   LHFlx_all(4,:) = data5(:,9)   ; flux recalc
   LHFlx_all(5,:) = data6(:,15)  ; GFDex coare
   LHFlx_all(6,:) = data6(:,13)  ; GFDex bulk
   LHFlx_all@long_name = "Latent Heat Flux at Surface"
   LHFlx_all@units = "W m-2"
   if (any(isnan_ieee(LHFlx_all)))then
     replace_ieeenan(LHFlx_all, fill, 0)
     LHFlx_all@_FillValue = fill
   end if

SHFlx_all = new((/en_num+2,diml/),"float")
   SHFlx_all(0,:) = data1(:,10)
   SHFlx_all(1,:) = data2(:,10)
   SHFlx_all(2,:) = data3(:,10)
   SHFlx_all(3,:) = data4(:,10)
   SHFlx_all(4,:) = data5(:,10)
   SHFlx_all(5,:) = data6(:,19)  ; GFDex coare
   SHFlx_all(6,:) = data6(:,17)  ; GFDex bulk
   SHFlx_all@long_name = "Sensible Heat Flux at Surface"
   SHFlx_all@units = "W m-2"
   if (any(isnan_ieee(SHFlx_all)))then
     replace_ieeenan(SHFlx_all, fill, 0)
     SHFlx_all@_FillValue = fill
   end if

;;;;;;;;;;;;;
; Make subsets of array for just 02 and 05 MAR
;;;;;;;;;;;;;
   wnd10m_sub = wnd10m_all(:,0:81)
   wnd10m_sub@long_name = "10m wind speed"
   wnd10m_sub@units = "m s-1" 

   Qsurf_sub = Qsurf_all(:,0:81)
   Qsurf_sub@long_name = "Saturation Mixing Ratio at Surface"
   Qsurf_sub@units = "g kg-1"

   Q2m_sub = Q2m_all(:,0:81)
   Q2m_sub@long_name = "2m Mixing Ratio"
   Q2m_sub@units = "g kg-1"

   Qgrad_sub = Qgrad_all(:,0:81)
   Qgrad_sub@longname = "Mixing ratio gradient: (2m-sfc)"
   Qgrad_sub@units = "g kg-1"  

   LHFlx_sub = LHFlx_all(0:5,0:81)  ; keep only COARE values
   LHFlx_sub@long_name = "Latent Heat Flux at Surface"
   LHFlx_sub@units = "W m-2" 

   Tsurf_sub = Tsurf_all(:,0:81)
   Tsurf_sub@long_name = "Sea Surface Temperature"
   Tsurf_sub@units = "K"

   T2m_sub = T2m_all(:,0:81)
   T2m_sub@long_name = "2m Temperature"
   T2m_sub@units = "K"

   Tgrad_sub = Tgrad_all(:,0:81)
   Tgrad_sub@longname = "Temperature gradient: (2m-sfc)"
   Tgrad_sub@units = "K"

   SHFlx_sub = SHFlx_all(0:5,0:81)  ; Keep only COARE values
   SHFlx_sub@long_name = "Sensible Heat Flux at Surface"
   SHFlx_sub@units = "W m-2"    

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
  res@tiMainFontHeightF           = 0.04              ; set size of font for main plot

; set x axis tick marks
  res@tmXTOn                      = False             ; delete top and right ticks
  res@tmYROn                      = False
  res@trXMinF                     = min(xtit2)         ; set lower x limit
  res@trXMaxF                     = max(xtit2)         ; set upper x limit

  ;res@tmYLMode                    = "Manual"
  res@tmXBMode                    = "Explicit"
  res@tmXBValues                  = (/1, 20/)
  res@tmXBLabels                  = (/"2MAR", "5MAR"/)
  ;res@tmXBLabels                  = (/"B274", "B276", "B277", "B278"/)

  res@tiXAxisFontHeightF          = 0.03            ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.03             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.04             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.04             ; set tick mark label size for y axis
  ;res@vpHeightF                   = 0.2               ; change aspect ratio of plot (viewport)
  ;res@vpWidthF                    = 0.9               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyMarkLineModes             = (/"Lines", "Lines", "Lines", "Lines", "Markers", "Markers"/)
   res@xyMarkers                   = (/ -1, -1, -1, -1, 1, 4 /)
   res@xyMarkerSizes               = (/0.03,0.03,0.03,0.05,0.05/)
   res@xyLineColors                = (/ "orange", "red", "green", "blue","black", "black"/)
   res@xyMarkerColors              = (/ "black", "red", "green", "blue","black", "black"/)
   res@xyMonoLineColor             =  False                 ; allow other line colors
   res@xyDashPatterns              = (/0, 0, 0, 0, 0, 0/)
   res@xyLineThicknesses           = (/3.0, 3.0, 3.0, 3.0, 3.0/) 
   ;res@gsnYRefLine                 = 0.0           ; create a reference line
   ;res@gsnYRefLineColor            = "grey"

;;;;;;;;;;;;;
; Plot 0 - Sfc Mixing ratio
;;;;;;;;;;;;;
title = "a)  Surface Mixing Ratio"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Qsurf_sub@units
  opts@trYMinF                    = 0.0
  opts@trYMaxF                    = 7.0
  
  cplot0 = gsn_csm_xy(wks, xtit2, Qsurf_sub, opts) 
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 1 - 2m Mixing ratio
;;;;;;;;;;;;;
title = "b)  2m Mixing Ratio"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Q2m_sub@units
  opts@trYMinF                    = 0.0
  opts@trYMaxF                    = 7.0
  
  cplot1 = gsn_csm_xy(wks, xtit2, Q2m_sub, opts) 
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - Mixing ratio gradient
;;;;;;;;;;;;;
title = "c)  Mixing Ratio Gradient"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Qgrad_sub@units
  
  cplot2 = gsn_csm_xy(wks, xtit2, Qgrad_sub, opts) 
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 3 - Sfc Temperature
;;;;;;;;;;;;;
title = "d)  Surface Temperature"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Tsurf_sub@units
  opts@trYMinF                    = 261.0
  opts@trYMaxF                    = 282.0
  
  cplot3 = gsn_csm_xy(wks, xtit2, Tsurf_sub, opts) 
  plot(3) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 4 - 2m Temperature
;;;;;;;;;;;;;
title = "e)  2m Temperature"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = T2m_sub@units
  opts@trYMinF                    = 261.0
  opts@trYMaxF                    = 282.0
  
  cplot4 = gsn_csm_xy(wks, xtit2, T2m_sub, opts) 
  plot(4) = cplot4                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 5 - Temperature gradient
;;;;;;;;;;;;;
title = "f)  Temperature Gradient"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Tgrad_sub@units
  
  cplot5 = gsn_csm_xy(wks, xtit2, Tgrad_sub, opts) 
  plot(5) = cplot5                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 6 - 10m Wind
;;;;;;;;;;;;;
title = "g)  10m wind speed"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = wnd10m_sub@units
  
  cplot6 = gsn_csm_xy(wks, xtit2, wnd10m_sub, opts) 
  plot(6) = cplot6                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 7 - LHFlux at Surface
;;;;;;;;;;;;;
title = "h)  Latent Heat Flux"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = LHFlx_sub@units
  opts@trYMinF                    = 0.0
  opts@trYMaxF                    = 800.0
  
  cplot7 = gsn_csm_xy(wks, xtit2, LHFlx_sub, opts) 
  plot(7) = cplot7                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 8 - LHFlux at Surface
;;;;;;;;;;;;;
title = "i)  Sensible Heat Flux"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = SHFlx_sub@units
  opts@trYMinF                    = 0.0
  opts@trYMaxF                    = 800.0
  
  cplot8 = gsn_csm_xy(wks, xtit2, SHFlx_sub, opts) 
  plot(8) = cplot8                              ; make panel section of this plot
  delete(opts)
  delete(title)

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  titlefin = "GFDex and WRF10 near surface variables - flux tests"

  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False
  pnlres@txString                   = titlefin           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/3,3/),pnlres)               ; create final panel plot

;  ; make general legend
; legend resources for all the plots
  lgres                    = True

  ;lgres@pmLegendWidthF     = 0.03
  ;lgres@pmLegendHeightF    = 0.01
  lgres@vpWidthF           = 0.65               ; width of legend (NDC)
  lgres@vpHeightF          = 0.05               ; height of legend (NDC)
  lgres@lgLabelFontHeightF = 0.01
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  
  lgres@lgOrientation      = "horizontal" 
  lgres@lgMonoLineColor    = False
  lgres@lgMonoItemType     = False
  lgres@lgItemTypes        = res@xyMarkLineModes
  lgres@lgDashIndexes      = res@xyDashPatterns
  lgres@lgMarkerIndexes    = res@xyMarkers
  lgres@lgMonoMarkerSize   = False
  lgres@lgMarkerSizes      = res@xyMarkerSizes
  lgres@lgMonoLineThickness = False
  lgres@lgLineThicknesses  = res@xyLineThicknesses
  lgres@lgLineColors       = res@xyLineColors   ; make the colors for the legend
  lgres@lgMarkerColors     = res@xyMarkerColors
  xpos = 0.2   ; xposition 
  ypos = 0.13  ; yposition (below figures)

  gsn_legend_ndc(wks,en_num + 1,(/title1, title2, title3, title4, title5, title6 /),xpos ,ypos ,lgres) 

frame(wks)
  
print("Plots Completed")

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





