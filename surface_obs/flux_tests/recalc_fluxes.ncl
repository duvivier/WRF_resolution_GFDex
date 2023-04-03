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
indir = "./txt_output/"

fname5 = indir + "GFDex_sfc_data_for_flux_recalc.txt"

title5 = "GFDex"

; BEGIN SCRIPT
; set outdir and fout names
outdir = "./"
fout = outdir + "GFDex_fluxes_only_recalc"

print("Recalculating fluxes for GFDex using WRF method")
;;;;;;;;;;;;;
; Set constants
;;;;;;;;;;;;;
rd = 287.       ; units J/kg*K
cp = 1004.      ; units J/kg*K
vk = 0.4       ; von karman constant
xlv = 2.5*(10.^6.) ; units J/kg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load data - must be txt files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 nrow = 129             ; number of rows in array (the header is removed already

;; load data from ascii file
;;;;;;;;;;;;;
; load data 
;;;;;;;;;;;;;
data5    = asciiread(fname5,(/nrow,16/), "float")

xtit = data5(:,1)     ; array for flight # as xtitles... not sure if this will work
diml = dimsizes(xtit)

; make array to plot values against
xtit2 = new((/diml/),"integer")
   do i = 0,diml-1
     xtit2(i) = i
   end do

;;;;;;;;;;;;;
; Make variable arrays
;;;;;;;;;;;;;

lats = data5(:,2)
lons = data5(:,3)
u10m = data5(:,4)  ; units m/s
qsfc = data5(:,5)/1000.  ; units kg/kg
q2m = data5(:,6)/1000.   ; units kg/kg
tsfc = data5(:,7)  ; units K
t2m = data5(:,8)   ; units K
LH_orig = data5(:,9) ; units W/m2
SH_orig = data5(:,10) ; units W/m2
ustar = data5(:,11) ; units m/s
th2m = data5(:,12) ; units K
mslp = data5(:,13)*100. ; units [pa]
press = data5(:,14)*100. ; units[pa]
alt = data5(:,15) ; units m

thsfc = tsfc*(100000./mslp)^(rd/cp)  ; calculate surface potential temp for gradient

;;;;;;;;;;;;;
; Calculate fluxes
;;;;;;;;;;;;;
;calculate stability term
; 0.018 is charnock parameter
;same term for both latent and sensible heat fluxes
dum0 = ((0.35*30)/ustar)*((0.018*ustar^3)/1.5*10.^(-5.))^(0.25)
dum1 = (alt - dum0)/dum0
stab = (ustar*vk)/log(dum1)  ; natural log

SH_new = (-press/(rd*t2m))*cp*(th2m-thsfc)*stab
LH_new = (-press/(rd*t2m))*xlv*(q2m-qsfc)*stab


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Write recalculated vars to a text file for plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header = "lats     lons    SH_flx       LH_flx    " 
output = header

do j = 0,diml-1

  a1 = sprintf("%10.4f",lats(j))+sprintf("%10.4f",lons(j))+\
         sprintf("%10.4f",SH_new(j))+sprintf("%10.4f",LH_new(j))

   newoutput = array_append_record(output, a1, 0)
   delete(output)
   output = newoutput
   delete(newoutput)

end do

asciiwrite(fout + ".txt",output)


end





