;***************************************
; PROGRAM DESCRIPTION: This NCL script plots domain average statistics
;                      between WRF resolutions and QuikSCAT obs
; INPUT DATA: a text file input of all days, resolutions, and stats
;             created in Excel and called 'QS_stats_all.txt'
; OUTPUT DATA: Panel plots of bias, mae, rmse, correlation
; Notes: this is a fairly hard coded script
; CREATOR: Alice DuVivier - July 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
indir1 = "/data3/duvivier/NCAR/Quikscat/"
date1 = "QS_stats_all"

; BEGIN SCRIPT
fname1 = indir1 + date1 + ".txt"
; set outdir and fout names
outdir = "./"
fout = outdir + date1 + "_plots"

print("Plotting stats for " + date1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be txt file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; make horizontal titles
reso = (/1, 2, 3, 4, 5, 6, 7, 8/)    ; array with values to plot against
diml = dimsizes(reso)
days = (/"21FEB", "02MAR", "05MAR", "06MAR", "09MAR"/)
dimdays = dimsizes(days)

;;;;;;;;;;;;;
; load data from ascii files
;;;;;;;;;;;;;
ncol = 7               ; number of columns in array
header = 1             ; number of header lines

data1 = readAsciiTable(fname1, ncol, "float", header)

;;;;;;;;;;;;;
; Make arrays of things to plot
;;;;;;;;;;;;;
bias = new((/dimdays, diml/),"float")
   bias(0,:) = data1(0:7,3)    ; 21FEB
   bias(1,:) = data1(8:15,3)   ; 2MAR
   bias(2,:) = data1(16:23,3)  ; 5MAR
   bias(3,:) = data1(24:31,3)  ; 6MAR
   bias(4,:) = data1(32:39,3)  ; 9MAR

mae = new((/dimdays, diml/),"float")
   mae(0,:) = data1(0:7,4)    ; 21FEB
   mae(1,:) = data1(8:15,4)   ; 2MAR
   mae(2,:) = data1(16:23,4)  ; 5MAR
   mae(3,:) = data1(24:31,4)  ; 6MAR
   mae(4,:) = data1(32:39,4)  ; 9MAR

rmse = new((/dimdays, diml/),"float")
   rmse(0,:) = data1(0:7,5)    ; 21FEB
   rmse(1,:) = data1(8:15,5)   ; 2MAR
   rmse(2,:) = data1(16:23,5)  ; 5MAR
   rmse(3,:) = data1(24:31,5)  ; 6MAR
   rmse(4,:) = data1(32:39,5)  ; 9MAR

corr = new((/dimdays, diml/),"float")
   corr(0,:) = data1(0:7,6)    ; 21FEB
   corr(1,:) = data1(8:15,6)   ; 2MAR
   corr(2,:) = data1(16:23,6)  ; 5MAR
   corr(3,:) = data1(24:31,6)  ; 6MAR
   corr(4,:) = data1(32:39,6)  ; 9MAR

print ("Plotting QuikSCAT statistical data")
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

;; set x axist tick marks
  res@trXMinF                     = 0                   ; set lower x limit
  res@trXMaxF                     = 9                   ; set upper x limit
  res@tmXBMode                    = "Explicit"          ; specify the tick label spacing myself
  res@tmXBValues                  = reso
  res@tmXBLabels                  = (/"100km~C~7UTC", "50km~C~7UTC", "25km~C~7UTC", "10km~C~7UTC","100km~C~22UTC", "50km~C~22UTC", "25km~C~22UTC", "10km~C~22UTC"/)

  res@tiXAxisFontHeightF          = 0.015               ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.015               ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.015               ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.015               ; set tick mark label size for y axis
  res@vpHeightF                   = 0.2                 ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 0.8               
  
; arrays for different colors, etc.(requires a single array of data)
   res@xyLineColors                 = (/ "black", "red", "green", "blue","orange"/)
   res@xyMarkerColors               = (/ "black", "red", "green", "blue","orange"/)
   res@xyDashPatterns               = (/0,0,0,0,0/)
   res@xyMarkers                    = (/0,16,2,4,5/)
   res@xyMonoLineColor              = False                 ; allow other line colors
   res@xyMarkLineMode               = (/"Markers"/)           ; use both lines and markers (opts: Markers, Lines, MarkLines)
   res@xyMarkerSizeF                = 0.015


; legend resources for all the plots
  lgres                    = True
  lgres@lgMonoDashIndex    = True               ; sets both contour lines to same dash type
  lgres@lgAutoManage       = False              ; false allows me to set the legend directly
  lgres@vpWidthF           = 0.20               ; width of legend (NDC)
  lgres@vpHeightF          = 0.10               ; height of legend (NDC)
  lgres@lgLabelFontHeightF = 0.035
  lgres@lgLineLabelStrings = (/"", "", "", "", ""/)         ; take off any automatic line labels
  ;lgres@lgDashIndexes      = res@xyDashPatterns
  lgres@lgMarkerIndexes    = res@xyMarkers
  lgres@lgLineColors       = res@xyLineColors

;;;;;;;;;;;;;
; Plot 0 - Bias(WRF-QS)
;;;;;;;;;;;;;
title = "Bias (WRF-QS)"                         ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input name
  opts@tiYAxisString              = "m s-1"
  
  cplot0 = gsn_csm_xy(wks, reso, bias, opts)      ; create plot of first time series
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

 ;; legend resources- for plot 0 overlay
   ledgres                    = lgres
   lbid = gsn_create_legend(wks, dimdays, days, lgres)         ; create legend;

  ;; annotate plot by adding legend
   amres                    = True
   amres@amParallelPosF     = 0.38	        ; move legend to the left or right
   amres@amOrthogonalPosF   = -0.73               ; move the legend down or up (neg = up)
   annoid1 = gsn_add_annotation(plot(0),lbid,amres)   ; add legend to plot

   delete(ledgres)
   delete(lbid)

;;;;;;;;;;;;;
; Plot 1 - MAE
;;;;;;;;;;;;;
title = "MAE"                                          ; make a title string for the plot

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input name
  opts@tiYAxisString              = "m s-1"
  
  cplot1 = gsn_csm_xy(wks, reso, mae, opts)      ; create plot of first time series
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 2 - RMSE
;;;;;;;;;;;;;
title = "RMSE"

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input name
  opts@tiYAxisString              = "m s-1"
  
  cplot2 = gsn_csm_xy(wks, reso, rmse, opts)      ; create plot of first time series
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)
;;;;;;;;;;;;;
; Plot 3 - CORR
;;;;;;;;;;;;;
title = "Correlation"

  opts                            = res               ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title            ; set title for plot. designated above as both input name
  
  cplot3 = gsn_csm_xy(wks, reso, corr, opts)      ; create plot of first time series
  plot(3) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

 ;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  title5 = "Reduced Domain Average Statistics ~C~  WRF output and QuikSCAT obs."

  pnlres                            = True
  pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  pnlres@gsnPanelBottom             = 0.18
  gsn_panel(wks,(/plot/),(/4,1/),pnlres)               ; create final panel plot
  
print("Plots Completed")
;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





