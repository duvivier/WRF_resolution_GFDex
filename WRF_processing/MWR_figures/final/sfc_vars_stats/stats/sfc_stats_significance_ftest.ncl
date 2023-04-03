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
indir = "../txt_files/"
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
fout = outdir + "sfc_histograms"

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
f = new((/1/),"float")
fill = f@_FillValue

wnd10m_all = new((/en_num+1,diml/),"float")
   wnd10m_all(0,:) = data1(:,4)
   wnd10m_all(1,:) = data2(:,4)
   wnd10m_all(2,:) = data3(:,4)
   wnd10m_all(3,:) = data4(:,4)
   wnd10m_all(4,:) = data5(:,5)   ; GFDEX coare
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
   Qsurf_all(4,:) = data5(:,6)   ; GFDex
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
   Q2m_all(4,:) = data5(:,8)    ; GFDex coare
   Q2m_all@long_name = "Mixing Ratio at 2m"
   Q2m_all@units = "g kg-1"
   if (any(isnan_ieee(Q2m_all)))then
     replace_ieeenan(Q2m_all, fill, 0)
     Q2m_all@_FillValue = fill
   end if

Qgrad_all = Q2m_all - Qsurf_all

Tsurf_all = new((/en_num+1,diml/),"float")
   Tsurf_all(0,:) = data1(:,7)
   Tsurf_all(1,:) = data2(:,7)
   Tsurf_all(2,:) = data3(:,7)
   Tsurf_all(3,:) = data4(:,7)
   Tsurf_all(4,:) = data5(:,9)    ; GFDex
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
   T2m_all(4,:) = data5(:,11)    ; GFDex coare
   T2m_all@long_name = "Temperature at 2m"
   T2m_all@units = "K"
   if (any(isnan_ieee(T2m_all)))then
     replace_ieeenan(T2m_all, fill, 0)
     T2m_all@_FillValue = fill
   end if

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
   if (any(isnan_ieee(LHFlx_all)))then
     replace_ieeenan(LHFlx_all, fill, 0)
     LHFlx_all@_FillValue = fill
   end if

SHFlx_all = new((/en_num+2,diml/),"float")
   SHFlx_all(0,:) = data1(:,10)
   SHFlx_all(1,:) = data2(:,10)
   SHFlx_all(2,:) = data3(:,10)
   SHFlx_all(3,:) = data4(:,10)
   SHFlx_all(4,:) = data5(:,19)  ; GFDex coare
   SHFlx_all(5,:) = data5(:,17)  ; GFDex bulk
   SHFlx_all@long_name = "Sensible Heat Flux at Surface"
   SHFlx_all@units = "W m-2"
   if (any(isnan_ieee(SHFlx_all)))then
     replace_ieeenan(SHFlx_all, fill, 0)
     SHFlx_all@_FillValue = fill
   end if

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
Qsurf_rmse = new((/en_num/),"float")
Q2m_rmse = new((/en_num/),"float")
Qgrad_rmse = new((/en_num/),"float")
Tsurf_rmse = new((/en_num/),"float")
T2m_rmse = new((/en_num/),"float")
Tgrad_rmse = new((/en_num/),"float")
W10m_rmse = new((/en_num/),"float")
SHFlx_rmse = new((/en_num/),"float")  ; bias with coare
LHFlx_rmse = new((/en_num/),"float")  ; bias with coare

do i = 0,en_num-1
  ;Qsurf
  sum_sq_bias = sum(Qsurf_bias(i,:)^2)
  Qsurf_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;Q2m
  sum_sq_bias = sum(Q2m_bias(i,:)^2)
  Q2m_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;Qgrad
  sum_sq_bias = sum(Qgrad_bias(i,:)^2)
  Qgrad_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;Tsurf
  sum_sq_bias = sum(Tsurf_bias(i,:)^2)
  Tsurf_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;T2m
  sum_sq_bias = sum(T2m_bias(i,:)^2)
  T2m_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;Tgrad
  sum_sq_bias = sum(Tgrad_bias(i,:)^2)
  Tgrad_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;W10m
  sum_sq_bias = sum(W10m_bias(i,:)^2)
  W10m_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;SHFlx
  sum_sq_bias = sum(SHFlx_bias(i,:)^2)
  SHFlx_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

  ;LHFlx
  sum_sq_bias = sum(LHFlx_bias(i,:)^2)
  LHFlx_rmse(i)=sqrt(sum_sq_bias/diml)
  delete(sum_sq_bias)

end do

print ("Calculating signficance for bias arrays")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calcluate significance between WRF10 and other WRF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
siglvl = 0.05  ; 95% significantly different
titles = (/"WRF100","WRF50","WRF25","WRF10"/)
opt = 0

s1 = dimsizes(Qsurf_bias(0,:))
s2 = dimsizes(Qsurf_bias(0,:))

do i = 0,en_num-2
  ;Qsurf
  var1 = Qsurf_rmse(i)^2
  var2 = Qsurf_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 Qsurf RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End Qsurf")

  ;Q2m
  var1 = Q2m_rmse(i)^2
  var2 = Q2m_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 Q2m RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End Q2m")

  ;Qgrad
  var1 = Qgrad_rmse(i)^2
  var2 = Qgrad_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 Qgrad RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End Qgrad")

  ;Tsurf
  var1 = Tsurf_rmse(i)^2
  var2 = Tsurf_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 Tsurf RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End Tsurf")

  ;T2m
  var1 = T2m_rmse(i)^2
  var2 = T2m_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 T2m RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End T2m")

  ;Tgrad
  var1 = Tgrad_rmse(i)^2
  var2 = Tgrad_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 Tgrad RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End Tgrad")

  ;W10m
  var1 = W10m_rmse(i)^2
  var2 = W10m_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 W10m RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End W10m")

  ;SHFlx
  var1 = SHFlx_rmse(i)^2
  var2 = SHFlx_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 SHFlx RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End SHFlx")

  ;LHFlx
  var1 = LHFlx_rmse(i)^2
  var2 = LHFlx_rmse(3)^2
  prob = ftest(var1,s1,var2,s2,opt)
  if(prob.lt.siglvl)then
    print("Difference between "+titles(i)+" and WRF10 LHFlx RMSE is statistically significant to the 95% level")
  end if

  delete(var1)
  delete(var2)
  delete(prob)
  print("End LHFlx")

end do

print("End of Loop")

; End of script
end





