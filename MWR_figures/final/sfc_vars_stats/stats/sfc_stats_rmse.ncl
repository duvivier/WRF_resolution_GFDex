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
en_num = 4

fname0 = indir + "wrf_100km_sfc_all.txt"
fname1 = indir + "wrf_50km_sfc_all.txt"
fname2 = indir + "wrf_25km_sfc_all.txt"
fname3 = indir + "wrf_10km_sfc_all.txt"
fname4 = indir + "GFDex_sfc_all.txt"

title0 = "WRF 100" 
title1 = "WRF 50" 
title2 = "WRF 25"
title3 = "WRF 10"
title4 = "GFDex"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout = outdir + "sfc_histograms_rmse"

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
data1    = asciiread(fname0,(/nrow,ncol/), "float")
data2    = asciiread(fname1,(/nrow,ncol/), "float")
data3    = asciiread(fname2,(/nrow,ncol/), "float")
data4    = asciiread(fname3,(/nrow,ncol/), "float")
data5    = asciiread(fname4,(/nrow,20/), "float")

xtit = data4(:,1)     ; array for flight # as xtitles... not sure if this will work
diml = dimsizes(xtit)
dim  = dimsizes(xtit(0:81))

; make array to plot values against (SPECIFIED MANUALLY)
xtit2 = new((/diml/),"integer")
   do i = 0,diml-1
     xtit2(i) = i
   end do

;;;;;;;;;;;;;
; Make arrays/variables for GFDex data
;;;;;;;;;;;;;
f = new((/1/),"float")
fill = f@_FillValue
   
wnd10m_gfdex_all = new((/1,diml/),"float")
;   wnd10m_gfdex_all(0,:) = data5(:,4)    ; direct obs
   wnd10m_gfdex_all(0,:) = data5(:,5)    ; coare

Qsurf_gfdex = data5(:,6)

Q2m_gfdex_all = new((/1,diml/),"float")
;   Q2m_gfdex_all(0,:) = data5(:,7)      ; direct obs
   Q2m_gfdex_all(0,:) = data5(:,8)      ; coare

Tsurf_gfdex = data5(:,9)

T2m_gfdex_all = new((/1,diml/),"float")
;   T2m_gfdex_all(0,:) = data5(:,10)    ; direct obs
   T2m_gfdex_all(0,:) = data5(:,11)    ; coare

LHFlx_gfdex_all = new((/2,diml/),"float")
   ;LHFlx_gfdex_all(0,:) = data5(:,12)    ; direct obs
   LHFlx_gfdex_all(0,:) = data5(:,15)    ; coare
   LHFlx_gfdex_all(1,:) = data5(:,13)    ; bulk
   ;LHFlx_gfdex_all(1,:) = data5(:,14)    ; bulk_gfd

SHFlx_gfdex_all = new((/2,diml/),"float")
   ;SHFlx_gfdex_all(0,:) = data5(:,16)    ; direct obs
   SHFlx_gfdex_all(0,:) = data5(:,19)    ; coare
   SHFlx_gfdex_all(1,:) = data5(:,17)    ; bulk
   ;SHFlx_gfdex_all(1,:) = data5(:,18)    ; bulk_gfd

;;;;;;;;;;;;;
; Make WRF variable arrays - arrangement = (L->R) 100km, 50km, 25km, 10km)
;;;;;;;;;;;;;
wnd10m_all = new((/en_num+1,diml/),"float")
   wnd10m_all(0,:) = data1(:,4)
   wnd10m_all(1,:) = data2(:,4)
   wnd10m_all(2,:) = data3(:,4)
   wnd10m_all(3,:) = data4(:,4)
   wnd10m_all(4,:) = data5(:,5)   ; GFDEX coare
   wnd10m_all@long_name = "10 m Wind Speed"
   wnd10m_all@units = "m s-1"

Qsurf_all = new((/en_num+1,diml/),"float")
   Qsurf_all(0,:) = data1(:,5)
   Qsurf_all(1,:) = data2(:,5)
   Qsurf_all(2,:) = data3(:,5)
   Qsurf_all(3,:) = data4(:,5)
   Qsurf_all(4,:) = data5(:,6)   ; GFDex
   Qsurf_all@long_name =  "Saturation Mixing Ratio at Surface"
   Qsurf_all@units = "g kg-1"

Q2m_all = new((/en_num+1,diml/),"float")
   Q2m_all(0,:) = data1(:,6)
   Q2m_all(1,:) = data2(:,6)
   Q2m_all(2,:) = data3(:,6)
   Q2m_all(3,:) = data4(:,6)
   Q2m_all(4,:) = data5(:,8)    ; GFDex coare
   Q2m_all@long_name = "Mixing Ratio at 2m"
   Q2m_all@units = "g kg-1"

Qgrad_all = Q2m_all - Qsurf_all

Tsurf_all = new((/en_num+1,diml/),"float")
   Tsurf_all(0,:) = data1(:,7)
   Tsurf_all(1,:) = data2(:,7)
   Tsurf_all(2,:) = data3(:,7)
   Tsurf_all(3,:) = data4(:,7)
   Tsurf_all(4,:) = data5(:,9)    ; GFDex
   Tsurf_all@long_name = "Sea Surface Temperature"
   Tsurf_all@units = "K"

T2m_all = new((/en_num+1,diml/),"float")
   T2m_all(0,:) = data1(:,8)
   T2m_all(1,:) = data2(:,8)
   T2m_all(2,:) = data3(:,8)
   T2m_all(3,:) = data4(:,8)
   T2m_all(4,:) = data5(:,11)    ; GFDex coare
   T2m_all@long_name = "Temperature at 2m"
   T2m_all@units = "K"

Tgrad_all = T2m_all - Tsurf_all

LHFlx_all = new((/en_num+2,diml/),"float")
   LHFlx_all(0,:) = data1(:,9)
   LHFlx_all(1,:) = data2(:,9)
   LHFlx_all(2,:) = data3(:,9)
   LHFlx_all(3,:) = data4(:,9)
   LHFlx_all(4,:) = data5(:,15)  ; GFDex coare
   LHFlx_all(5,:) = data5(:,13)  ; GFDex bulk
   LHFlx_all@long_name = "Latent Heat Flux at Surface"
   LHFlx_all@units = "W m-2"

SHFlx_all = new((/en_num+2,diml/),"float")
   SHFlx_all(0,:) = data1(:,10)
   SHFlx_all(1,:) = data2(:,10)
   SHFlx_all(2,:) = data3(:,10)
   SHFlx_all(3,:) = data4(:,10)
   SHFlx_all(4,:) = data5(:,19)  ; GFDex coare
   SHFlx_all(5,:) = data5(:,17)  ; GFDex bulk
   SHFlx_all@long_name = "Sensible Heat Flux at Surface"
   SHFlx_all@units = "W m-2"

;;;;;;;;;;;;;
; Make bias arrays (WRF-GFDex)
;;;;;;;;;;;;;

Qsurf_bias = new((/en_num,diml/),"float")
   Qsurf_bias(0,:) = Qsurf_all(0,:)-Qsurf_all(4,:)
   Qsurf_bias(1,:) = Qsurf_all(1,:)-Qsurf_all(4,:)
   Qsurf_bias(2,:) = Qsurf_all(2,:)-Qsurf_all(4,:)
   Qsurf_bias(3,:) = Qsurf_all(3,:)-Qsurf_all(4,:)

Q2m_bias = new((/en_num,diml/),"float")
   Q2m_bias(0,:) = Q2m_all(0,:)-Q2m_all(4,:)
   Q2m_bias(1,:) = Q2m_all(1,:)-Q2m_all(4,:)
   Q2m_bias(2,:) = Q2m_all(2,:)-Q2m_all(4,:)
   Q2m_bias(3,:) = Q2m_all(3,:)-Q2m_all(4,:)

Qgrad_bias = new((/en_num,diml/),"float")
   Qgrad_bias(0,:) = Qgrad_all(0,:)-Qgrad_all(4,:)
   Qgrad_bias(1,:) = Qgrad_all(1,:)-Qgrad_all(4,:)
   Qgrad_bias(2,:) = Qgrad_all(2,:)-Qgrad_all(4,:)
   Qgrad_bias(3,:) = Qgrad_all(3,:)-Qgrad_all(4,:)

Tsurf_bias = new((/en_num,diml/),"float")
   Tsurf_bias(0,:) = Tsurf_all(0,:)-Tsurf_all(4,:)
   Tsurf_bias(1,:) = Tsurf_all(1,:)-Tsurf_all(4,:)
   Tsurf_bias(2,:) = Tsurf_all(2,:)-Tsurf_all(4,:)
   Tsurf_bias(3,:) = Tsurf_all(3,:)-Tsurf_all(4,:)

T2m_bias = new((/en_num,diml/),"float")
   T2m_bias(0,:) = T2m_all(0,:)-T2m_all(4,:)
   T2m_bias(1,:) = T2m_all(1,:)-T2m_all(4,:)
   T2m_bias(2,:) = T2m_all(2,:)-T2m_all(4,:)
   T2m_bias(3,:) = T2m_all(3,:)-T2m_all(4,:)

Tgrad_bias = new((/en_num,diml/),"float")
   Tgrad_bias(0,:) = Tgrad_all(0,:)-Tgrad_all(4,:)
   Tgrad_bias(1,:) = Tgrad_all(1,:)-Tgrad_all(4,:)
   Tgrad_bias(2,:) = Tgrad_all(2,:)-Tgrad_all(4,:)
   Tgrad_bias(3,:) = Tgrad_all(3,:)-Tgrad_all(4,:)

W10m_bias = new((/en_num,diml/),"float")
   W10m_bias(0,:) = wnd10m_all(0,:)-wnd10m_all(4,:)
   W10m_bias(1,:) = wnd10m_all(1,:)-wnd10m_all(4,:)
   W10m_bias(2,:) = wnd10m_all(2,:)-wnd10m_all(4,:)
   W10m_bias(3,:) = wnd10m_all(3,:)-wnd10m_all(4,:)

SHFlx_bias = new((/en_num,diml/),"float")  ; bias with coare
   SHFlx_bias(0,:) = SHFlx_all(0,:)-SHFlx_all(4,:)
   SHFlx_bias(1,:) = SHFlx_all(1,:)-SHFlx_all(4,:)
   SHFlx_bias(2,:) = SHFlx_all(2,:)-SHFlx_all(4,:)
   SHFlx_bias(3,:) = SHFlx_all(3,:)-SHFlx_all(4,:) 

LHFlx_bias = new((/en_num,diml/),"float")  ; bias with coare
   LHFlx_bias(0,:) = LHFlx_all(0,:)-LHFlx_all(4,:)
   LHFlx_bias(1,:) = LHFlx_all(1,:)-LHFlx_all(4,:)
   LHFlx_bias(2,:) = LHFlx_all(2,:)-LHFlx_all(4,:)
   LHFlx_bias(3,:) = LHFlx_all(3,:)-LHFlx_all(4,:) 

;;;;;;;;;;;;;
; Make RMSE arrays at each pt 
;;;;;;;;;;;;;
; RMSE = sqrt(sum(bias^2)/2)
; At 1 pt: RMSE = sqrt(bias^2)--> RMSE= ABS(bias)

Qsurf_rmse = abs(Qsurf_bias)
Q2m_rmse = abs(Q2m_bias)
Qgrad_rmse = abs(Qgrad_bias)

Tsurf_rmse = abs(Tsurf_bias)
T2m_rmse = abs(T2m_bias)
Tgrad_rmse = abs(Tgrad_bias)

W10m_rmse = abs(W10m_bias)
SHFlx_rmse = abs(SHFlx_bias)
LHFlx_rmse = abs(LHFlx_bias)

print ("Plotting surface data")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plot data from each resolution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;  
  wks = gsn_open_wks("ps",fout)
 
  plot = new(36, graphic)

; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance frame
  res@gsnMaximize                 = True              ; maximize plot

; histogram resources
  res@gsnHistogramNumberOfBins    = 20
  res@gsEdgeColor                 = "black"
  res@gsFillColor = (/"transparent"/)
  res@tmXBLabelStride = 2

;; set title resources
  res@tiMainOn                    = True      ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.03      ; set size of font for main plot
  res@tiYAxisFontHeightF          = 0.03      ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.03      ; set label size for y axis

;;;;;;;;;;;;;
; Plot 0 - Sfc Mixing ratio
;;;;;;;;;;;;;

title = "WRF100"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = "Frequency: Qsurf"
  
  cplot0 = gsn_histogram(wks,Qsurf_rmse(0,:),opts)
  plot(0) = cplot0                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;

title = "WRF50"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = ""
  
  cplot1 = gsn_histogram(wks,Qsurf_rmse(1,:),opts)
  plot(1) = cplot1                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;

title = "WRF25"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = ""
  
  cplot2 = gsn_histogram(wks,Qsurf_rmse(2,:),opts)
  plot(2) = cplot2                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;

title = "WRF10"

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiMainString               = title         ; set title for plot. designated above as both input names
  opts@tiYAxisString              = ""
  
  cplot3 = gsn_histogram(wks,Qsurf_rmse(3,:),opts)
  plot(3) = cplot3                              ; make panel section of this plot
  delete(opts)
  delete(title)

;;;;;;;;;;;;;
; Plot 4 - 2m Mixing ratio
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = "Frequency: Q2m"
  
  cplot4 = gsn_histogram(wks,Q2m_rmse(0,:),opts)
  plot(4) = cplot4                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot5 = gsn_histogram(wks,Q2m_rmse(1,:),opts)
  plot(5) = cplot5                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot6 = gsn_histogram(wks,Q2m_rmse(2,:),opts)
  plot(6) = cplot6                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot7 = gsn_histogram(wks,Q2m_rmse(3,:),opts)
  plot(7) = cplot7                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 4 - Mixing ratio grad
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = "Frequency: Qgrad"
  
  cplot8 = gsn_histogram(wks,Qgrad_rmse(0,:),opts)
  plot(8) = cplot8                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot9 = gsn_histogram(wks,Qgrad_rmse(1,:),opts)
  plot(9) = cplot9                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot10 = gsn_histogram(wks,Qgrad_rmse(2,:),opts)
  plot(10) = cplot10                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot11 = gsn_histogram(wks,Qgrad_rmse(3,:),opts)
  plot(11) = cplot11                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 12 - Sfc Temp
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above

  opts@tiYAxisString              = "Frequency: Tsurf"
  
  cplot12 = gsn_histogram(wks,Tsurf_rmse(0,:),opts)
  plot(12) = cplot12                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot13 = gsn_histogram(wks,Tsurf_rmse(1,:),opts)
  plot(13) = cplot13                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot14 = gsn_histogram(wks,Tsurf_rmse(2,:),opts)
  plot(14) = cplot14                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot15 = gsn_histogram(wks,Tsurf_rmse(3,:),opts)
  plot(15) = cplot15                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 16 - 2m Temp
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = "Frequency: T2m"
  
  cplot16 = gsn_histogram(wks,T2m_rmse(0,:),opts)
  plot(16) = cplot16                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot17 = gsn_histogram(wks,T2m_rmse(1,:),opts)
  plot(17) = cplot17                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot18 = gsn_histogram(wks,T2m_rmse(2,:),opts)
  plot(18) = cplot18                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot19 = gsn_histogram(wks,T2m_rmse(3,:),opts)
  plot(19) = cplot19                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 20 - Temp grad
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = "Frequency: Tgrad"
  
  cplot20 = gsn_histogram(wks,Tgrad_rmse(0,:),opts)
  plot(20) = cplot20                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot21 = gsn_histogram(wks,Tgrad_rmse(1,:),opts)
  plot(21) = cplot21                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot22 = gsn_histogram(wks,Tgrad_rmse(2,:),opts)
  plot(22) = cplot22                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""

  cplot23 = gsn_histogram(wks,Tgrad_rmse(3,:),opts)
  plot(23) = cplot23                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 24 - LHFlx
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above

  opts@tiYAxisString              = "Frequency: LHFlx"
  
  cplot24 = gsn_histogram(wks,LHFlx_rmse(0,:),opts)
  plot(24) = cplot24                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot25 = gsn_histogram(wks,LHFlx_rmse(1,:),opts)
  plot(25) = cplot25                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot26 = gsn_histogram(wks,LHFlx_rmse(2,:),opts)
  plot(26) = cplot26                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot27 = gsn_histogram(wks,LHFlx_rmse(3,:),opts)
  plot(27) = cplot27                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 28 - SHFlx
;;;;;;;;;;;;;

  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = "Frequency: SHFlx"
  
  cplot28 = gsn_histogram(wks,SHFlx_rmse(0,:),opts)
  plot(28) = cplot28                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot29 = gsn_histogram(wks,SHFlx_rmse(1,:),opts)
  plot(29) = cplot29                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot30 = gsn_histogram(wks,SHFlx_rmse(2,:),opts)
  plot(30) = cplot30                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot31 = gsn_histogram(wks,SHFlx_rmse(3,:),opts)
  plot(31) = cplot31                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 32 - Wind10m
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = "Frequency: W10m"
  
  cplot32 = gsn_histogram(wks,W10m_rmse(0,:),opts)
  plot(32) = cplot32                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot33 = gsn_histogram(wks,W10m_rmse(1,:),opts)
  plot(33) = cplot33                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot34 = gsn_histogram(wks,W10m_rmse(2,:),opts)
  plot(34) = cplot34                              ; make panel section of this plot
  delete(opts)

;;;;;;;;;;;;;
; Plot 
;;;;;;;;;;;;;
  opts                            = res           ; set resources for plot 1 to be same as specified above
  opts@tiYAxisString              = ""
  
  cplot35 = gsn_histogram(wks,W10m_rmse(3,:),opts)
  plot(35) = cplot35                              ; make panel section of this plot
  delete(opts)


;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  ;titlefin = "Surface variables"

  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/9,4/),pnlres)               ; create final panel plot

frame(wks)
  
print("Plots Completed")

;;;;;;;;;;;;;
; Post Processing stuff 
;;;;;;;;;;;;;
 convert_cmd = "convert -density 300 "+fout+".ps -rotate -90 -trim -bordercolor white -border 10 -colors 256 -depth 8 "+fout+".png"

  system(convert_cmd)


end





