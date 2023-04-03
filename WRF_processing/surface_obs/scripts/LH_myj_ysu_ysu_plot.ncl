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
en_num = 3

fname2 = indir + "wrf_10km_ysu0.15_sfc_all.txt"
fname3 = indir + "wrf_10km_ysu0.185_sfc_all.txt"
fname4 = indir + "wrf_10km_sfc_all.txt"
fname5 = indir + "GFDex_sfc_all.txt"

title2 = "WRF10 - YSU_0.15"
title3 = "WRF10 - YSU_0.185"
title4 = "WRF10 - MYJ"
title5 = "GFDex"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout = outdir + "LH_sub_MYJ_YSU_YSU"

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
data2    = asciiread(fname2,(/nrow,ncol/), "float")
data3    = asciiread(fname3,(/nrow,ncol/), "float")
data4    = asciiread(fname4,(/nrow,ncol/), "float")
data5    = asciiread(fname5,(/nrow,20/), "float")

xtit = data4(:,1)     ; array for flight # as xtitles... not sure if this will work
diml = dimsizes(xtit)

dim = dimsizes(xtit(0:81))

; make array to plot values against (SPECIFIED MANUALLY)
xtit2 = new((/dim/),"integer")
   do i = 0,dim-1
     xtit2(i) = i
   end do

;;;;;;;;;;;;;
; Make WRF variable arrays - arrangement = (L->R) 100km, 50km, 25km, 10km)
;;;;;;;;;;;;;
wnd10m_all = new((/en_num+1,diml/),"float")
   wnd10m_all(0,:) = data2(:,4)
   wnd10m_all(1,:) = data3(:,4)
   wnd10m_all(2,:) = data4(:,4)
   wnd10m_all(3,:) = data5(:,5)   ; GFDEX coare
   wnd10m_all@long_name = "10 m Wind Speed"
   wnd10m_all@units = "m s-1"

Qsurf_all = new((/en_num+1,diml/),"float")
   Qsurf_all(0,:) = data2(:,5)
   Qsurf_all(1,:) = data3(:,5)
   Qsurf_all(2,:) = data4(:,5)
   Qsurf_all(3,:) = data5(:,6)   ; GFDex
   Qsurf_all@long_name =  "Saturation Mixing Ratio at Surface"
   Qsurf_all@units = "g kg-1"

Q2m_all = new((/en_num+1,diml/),"float")
   Q2m_all(0,:) = data2(:,6)
   Q2m_all(1,:) = data3(:,6)
   Q2m_all(2,:) = data4(:,6)
   Q2m_all(3,:) = data5(:,8)    ; GFDex coare
   Q2m_all@long_name = "Mixing Ratio at 2m"
   Q2m_all@units = "g kg-1"

Tsurf_all = new((/en_num+1,diml/),"float")
   Tsurf_all(0,:) = data2(:,7)
   Tsurf_all(1,:) = data3(:,7)
   Tsurf_all(2,:) = data4(:,7)
   Tsurf_all(3,:) = data5(:,9)    ; GFDex
   Tsurf_all@long_name = "Sea Surface Temperature"
   Tsurf_all@units = "K"

T2m_all = new((/en_num+1,diml/),"float")
   T2m_all(0,:) = data2(:,8)
   T2m_all(1,:) = data3(:,8)
   T2m_all(2,:) = data4(:,8)
   T2m_all(3,:) = data5(:,11)    ; GFDex coare
   T2m_all@long_name = "Temperature at 2m"
   T2m_all@units = "K"

LHFlx_all = new((/en_num+2,diml/),"float")
   LHFlx_all(0,:) = data2(:,9)
   LHFlx_all(1,:) = data3(:,9)
   LHFlx_all(2,:) = data4(:,9)
   LHFlx_all(3,:) = data5(:,15)  ; GFDex coare
   LHFlx_all(4,:) = data5(:,13)  ; GFDex bulk
   LHFlx_all@long_name = "Latent Heat Flux at Surface"
   LHFlx_all@units = "W m-2"

SHFlx_all = new((/en_num+2,diml/),"float")
   SHFlx_all(0,:) = data2(:,10)
   SHFlx_all(1,:) = data3(:,10)
   SHFlx_all(2,:) = data4(:,10)
   SHFlx_all(3,:) = data5(:,19)  ; GFDex coare
   SHFlx_all(4,:) = data5(:,17)  ; GFDex bulk
   SHFlx_all@long_name = "Sensible Heat Flux at Surface"
   SHFlx_all@units = "W m-2"

;;;;;;;;;;;;;
; Make subsets of array for just 02 and 05 MAR
;;;;;;;;;;;;;

   Qsurf_sub = Qsurf_all(:,0:81)
   Qsurf_sub@long_name = "Saturation Mixing Ratio at Surface"
   Qsurf_sub@units = "g kg-1"

   Q2m_sub = Q2m_all(:,0:81)
   Q2m_sub@long_name = "2m Mixing Ratio"
   Q2m_sub@units = "g kg-1"

   wnd10m_sub = wnd10m_all(:,0:81)
   wnd10m_sub@long_name = "10m wind speed"
   wnd10m_sub@units = "m s-1"   

   LHFlx_sub = LHFlx_all(:,0:81)
   LHFlx_sub@long_name = "Latent Heat Flux at Surface"
   LHFlx_sub@units = "W m-2"   

print ("Plotting surface data")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot data from each resolution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;
  
  wks = gsn_open_wks("ps",fout)
 
  plot = new(4, graphic)

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
  res@tmXBValues                  = (/1, 20/)
  res@tmXBLabels                  = (/"2MAR", "5MAR"/)

  res@tiXAxisFontHeightF          = 0.01             ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.012             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.015             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.015             ; set tick mark label size for y axis
  res@vpHeightF                   = 0.2               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 0.9               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyMarkLineModes             = (/"Lines", "Lines", "Lines", "Markers", "Markers"/)
   res@xyMarkers                   = (/-1, -1, -1, 1, 4 /)
   res@xyLineColors                = (/"red", "blue", "green", "black", "black"/)
   res@xyMarkerColors              = (/"red", "blue", "green", "black", "black"/)
   res@xyMonoLineColor             =  False                 ; allow other line colors
   res@xyDashPatterns              = (/0, 0, 0, 0, 0/)


; legend resources for all the plots
  lgres                    = True

  lgres@vpWidthF           = 0.30               ; width of legend (NDC)
  lgres@vpHeightF          = 0.15               ; height of legend (NDC)
  lgres@lgLabelFontHeightF = 0.03
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  
  lgres@lgMonoLineColor    = False
  lgres@lgMonoItemType       = False
  lgres@lgItemTypes        = res@xyMarkLineModes
  lgres@lgDashIndexes      = res@xyDashPatterns
  lgres@lgMarkerIndexes    = res@xyMarkers
  lgres@lgLineColors       = res@xyLineColors   ; make the colors for the legend
  lgres@lgMarkerColors     = res@xyMarkerColors


;  lgres@lgLineLabelStrings = (/"", "", "", "", "", ""/)         ; take off any automatic line labels

; annotation resources for legends
   amres                    = True
   amres@amParallelPosF     = 0.675	        ; move legend to the left or right(neg = left)
   amres@amOrthogonalPosF   = 0.0               ; move the legend down or up (neg = up)

;;;;;;;;;;;;;
; Plot 1 - Qsurf≈ß
;;;;;;;;;;;;;
title = Qsurf_all@long_name + " (" + Qsurf_sub@units + ")"           ; make a title string for the plot

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Qsurf_sub@units
  
  cplot0 = gsn_csm_xy(wks, xtit2, Qsurf_sub, opts)      ; create plot of first time series
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

  ;; legend resources- for plot 1 overlay
   lbid = gsn_create_legend(wks,en_num + 1,(/title2, title3, title4, title5 + " COARE3.0"/),lgres)         ; create legend

  ;; annotate first plot by adding legend
   annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

   delete(lbid)

;;;;;;;;;;;;;
; Plot 2 - Q2m
;;;;;;;;;;;;;
title = Q2m_all@long_name + " (" + Q2m_sub@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Q2m_sub@units
  
  cplot1 = gsn_csm_xy(wks, xtit2, Q2m_sub, opts)      ; create plot of first time series
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

  ;; legend resources- for plot 1 overlay
   lbid = gsn_create_legend(wks,en_num + 1,(/title2, title3, title4, title5 + " COARE3.0"/),lgres)         ; create legend

  ;; annotate first plot by adding legend
   annoid1 = gsn_add_annotation(plot(1),lbid,amres)   ; add legend to plot

   delete(lbid)

;;;;;;;;;;;;;
; Plot 3 - 10m Wind
;;;;;;;;;;;;;
title = wnd10m_all@long_name + " (" + wnd10m_sub@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tiYAxisString              = wnd10m_sub@units
  
  cplot2 = gsn_csm_xy(wks, xtit2, wnd10m_sub, opts)      ; create plot of first time series
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

  ;; legend resources- for plot 1 overlay
   lbid = gsn_create_legend(wks,en_num + 1,(/title2, title3, title4, title5 + " COARE3.0"/),lgres)         ; create legend

  ;; annotate first plot by adding legend
   annoid1 = gsn_add_annotation(plot(2),lbid,amres)   ; add legend to plot

   delete(lbid)

;;;;;;;;;;;;;
; Plot 4 - LHFlux at Surface
;;;;;;;;;;;;;
title = LHFlx_all@long_name + " (" + LHFlx_sub@units + ")"           ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input names
  opts@tiYAxisString              = LHFlx_sub@units
  
  cplot3 = gsn_csm_xy(wks, xtit2, LHFlx_sub, opts)      ; create plot of first time series
  plot(3) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

  ;; legend resources- for plot 1 overlay
   lbid = gsn_create_legend(wks,en_num + 2,(/title2, title3, title4, title5 + " COARE3.0", title5 + " Bulk(Smith)"/),lgres)         ; create legend

  ;; annotate first plot by adding legend
   annoid1 = gsn_add_annotation(plot(3),lbid,amres)   ; add legend to plot

   delete(lbid)

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  title5 = "WRF(MYJ and YSU PBL) and GFDex surface latent heat flux variable comparisons"

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/4,1/),pnlres)               ; create final panel plot
  
print("Plots Completed")

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





