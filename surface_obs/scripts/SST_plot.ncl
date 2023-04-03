
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
fname5 = indir + "GFDex_sfc_all.txt"
fname6 = indir + "MODIS_sfc_all.txt"

title1 = "WRF 100" 
title2 = "WRF 50" 
title3 = "WRF 25"
title4 = "WRF 10"
title5 = "GFDex"
title6 = "MODIS"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout = outdir + "SST_comp_plot"

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
data5    = asciiread(fname5,(/nrow,20/), "float")
data6    = asciiread(fname6,(/nrow,5/), "float")

xtit = data4(:,1)     ; array for flight # as xtitles... not sure if this will work
diml = dimsizes(xtit)

; make array to plot values against
xtit2 = new((/diml/),"integer")
   do i = 0,diml-1
     xtit2(i) = i
   end do

;;;;;;;;;;;;;
; Make WRF variable arrays - arrangement = (L->R) 100km, 50km, 25km, 10km)
;;;;;;;;;;;;;

Tsurf_all = new((/en_num+2,diml/),"float")
   Tsurf_all(0,:) = data1(:,7)
   Tsurf_all(1,:) = data2(:,7)
   Tsurf_all(2,:) = data3(:,7)
   Tsurf_all(3,:) = data4(:,7)
   Tsurf_all(4,:) = data5(:,9)    ; GFDex
   Tsurf_all(5,:) = data6(:,4)    ; MODIS
   Tsurf_all@long_name = "Sea Surface Temperature"
   Tsurf_all@units = "K"

print ("Plotting surface data")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot data from each resolution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;
  
  wks = gsn_open_wks("ps",fout)
 
  plot = new(1, graphic)

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
  res@tmXBValues                  = (/0, 20, 82, 90/)
  res@tmXBLabels                  = (/"02MAR", "05MAR", "06MAR", "09MAR"/)
 ; res@tmXBLabels                  = (/"B274", "B276", "B277", "B278"/)

  res@tiXAxisFontHeightF          = 0.015             ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.012             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.015             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.015             ; set tick mark label size for y axis
  res@vpHeightF                   = 0.2               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 0.9               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyMarkLineModes             = (/"Lines", "Lines", "Lines", "Lines", "Markers", "Markers"/)
   res@xyMarkers                   = (/ -1, -1, -1, -1, 1, 9 /)
   res@xyLineColors                = (/ "orange", "red", "green", "blue","black", "black"/)
   res@xyMarkerColors              = (/ "orange", "red", "green", "blue","black", "black"/)
   res@xyMonoLineColor             =  False                 ; allow other line colors
   res@xyDashPatterns              = (/0, 0, 0, 0, 0, 0/)


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

; annotation resources for legends
   amres                    = True
   amres@amParallelPosF     = 0.675	        ; move legend to the left or right(neg = left)
   amres@amOrthogonalPosF   = 0.0               ; move the legend down or up (neg = up)

;;;;;;;;;;;;;
; Plot 1 - Tsurf
;;;;;;;;;;;;;
title = Tsurf_all@long_name + " (" + Tsurf_all@units + ")"           ; make a title string for the plot

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = Tsurf_all@units
  opts@trYMinF                    = 261.0
  opts@trYMaxF                    = 282.0
  
  cplot0 = gsn_csm_xy(wks, xtit2, Tsurf_all, opts)      ; create plot of first time series
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

  ;; legend resources- for plot 1 overlay
   lbid = gsn_create_legend(wks,en_num + 2,(/title1, title2, title3, title4, title5, title6/),lgres)         ; create legend

  ;; annotate first plot by adding legend
   annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

   delete(lbid)

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  title5 = "WRF, GFDex, MODIS SST values"

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot
  
print("Plots Completed")

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





