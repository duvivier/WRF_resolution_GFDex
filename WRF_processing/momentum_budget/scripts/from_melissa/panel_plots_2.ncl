	                                          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load necessary libraries ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;;;;;;;;;;;;;;;;;
; Start program ;
;;;;;;;;;;;;;;;;;

begin

;;;;;
; Pull file names to be read 
;;;;;


; Creat arrays of possible year, month, day, hour and forecast for which files will be pulled
year = (/"2008","2009","2010"/)
month = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)
day = (/"01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"/)
hour = (/"00","03","06","09","12","15","18","21"/)
;forecast = (/"000","003","006","009","012","015","018","021","024","027","030","033","036","039","042","045","048","051","054","057","060","063","066","069","072","075","078","081","084","087","090","093","096","099","102","105","108","111","114","117","120"/)

;;;;;;;;;;;;
;; Inputs ;;
;;;;;;;;;;;;

;; NOTE: these inputs should be for the valid date, unlike the momenum_grid_3.ncl program

yr = 1             ; input the index of the year in the year array
mo = 8             ; input the index of the month in the month array
day_start = 5      ; input the index of the day in the day array where the analysis should begin (note: this is model initialized date)
day_end   = 6      ; input the index of the day in the day array where the analysis should end
;forecast_start = 4 ; input the index of the forecast category in the forecast array where analysis should start
;forecast_end = 7   ; input the index of the forecast category in the forecast array where analysis should end
hour_start = 7
hour_end = 7

;; Open raw wrf file to get the map factors

mapFacFile = addfile("/sundowner/home/marichar/wrf_raw/2010010100/wrfout_d02_2010-01-03_15:00:00.nc","r")

mapFac = mapFacFile->MAPFAC_M

;; Loop through each file to make the panel plots

t=0

do d=day_start, day_end 
 do h=hour_start,hour_end
;  do f=forecast_start, forecast_end

   ;; Create the file name of the file that the analysis is being conducted on

   file_name = "/sundowner/home/marichar/momentum_balance/"+year(yr)+month(mo)+day(d)+hour(h)+"_momentum_balance_grid_data.nc"

   ;; Open the file as read only

  wrf=addfile(file_name,"r")

 
  lat = wrf->lat
  lon = wrf->lon

  year_i = wrf->year
  month_i = wrf->month
  day_i = wrf->day
  hour_i = wrf->hour

  sizes_cf = dimsizes(wrf->lat)
  nx_grid_cf = sizes_cf(1)
  ny_grid_cf = sizes_cf(0)

 advection_u = wrf->advection_u
 advection_u@lat2d = lat
 advection_u@lon2d = lon
 advection_u@units = "ms-2"
 advection_v = wrf->advection_v
 advection_v@lat2d = lat
 advection_v@lon2d = lon
 advection_v@units = "ms-2"
 advection_mag = wrf->advection_mag
 advection_mag@lat2d = lat
 advection_mag@lon2d = lon
 advection_mag@units = "ms-2"
 curvature_u = wrf->curvature_u
 curvature_u@lat2d = lat
 curvature_u@lon2d = lon
 curvature_u@units = "ms-2"
 curvature_v = wrf->curvature_v
 curvature_v@lat2d = lat
 curvature_v@lon2d = lon
 curvature_v@units = "ms-2"
 curvature_mag = wrf->curvature_mag
 curvature_mag@lat2d = lat
 curvature_mag@lon2d = lon
 curvature_mag@units = "ms-2"
 pg_u = wrf->pg_u
 pg_u@lat2d = lat
 pg_u@lon2d = lon
 pg_u@units = "ms-2"
 pg_v = wrf->pg_v
 pg_v@lat2d = lat
 pg_v@lon2d = lon
 pg_v@units = "ms-2"
 pg_mag = wrf->pg_mag
 pg_mag@lat2d = lat
 pg_mag@lon2d = lon
 pg_mag@units = "ms-2"
 cf_u = wrf->cf_u
 cf_u@lat2d = lat
 cf_u@lon2d = lon
 cf_u@units = "ms-2"
 cf_v = wrf->cf_v
 cf_v@lat2d = lat
 cf_v@lon2d = lon
 cf_v@units = "ms-2"
 cf_mag = wrf->cf_mag
 cf_mag@lat2d = lat
 cf_mag@lon2d = lon
 cf_mag@units = "ms-2"
 du_dt = wrf->du_dt
 du_dt@lat2d = lat
 du_dt@lon2d = lon
 du_dt@units = "ms-2"
 dv_dt = wrf->dv_dt
 dv_dt@lat2d = lat
 dv_dt@lon2d = lon
 dv_dt@units = "ms-2"
 d_dt_mag = wrf->d_dt_mag
 d_dt_mag@lat2d = lat
 d_dt_mag@lon2d = lon
 d_dt_mag@units = "ms-2"
 friction_u = wrf->friction_u
 friction_u@lat2d = lat
 friction_u@lon2d = lon
 friction_u@units = "ms-2"
 friction_v = wrf->friction_v
 friction_v@lat2d = lat
 friction_v@lon2d = lon
 friction_v@units = "ms-2"
 friction_mag = wrf->friction_mag
 friction_mag@lat2d = lat
 friction_mag@lon2d = lon
 friction_mag@units = "ms-2"
 residual_u = friction_u+curvature_u
 residual_u@lat2d = lat
 residual_u@lon2d = lon
 residual_u@units = "ms-2"
 residual_v = friction_v+curvature_v
 residual_v@lat2d = lat
 residual_v@lon2d = lon
 residual_v@units = "ms-2"
 residual_mag = friction_mag+curvature_mag
 residual_mag@lat2d = lat
 residual_mag@lon2d = lon
 residual_mag@units = "ms-2"

output_filename = year(yr)+month(mo)+day(d)+hour(h)+"_momentum_balance_grid"

wks_adv = gsn_open_wks("ps",output_filename+"_adv_mag")
wks_curv = gsn_open_wks("ps",output_filename+"_curv_mag")
wks_pg = gsn_open_wks("ps",output_filename+"_pg_mag")
wks_cf = gsn_open_wks("ps",output_filename+"_cf_mag")
wks_d_dt = gsn_open_wks("ps",output_filename+"_d_dt_mag")
wks_fric = gsn_open_wks("ps",output_filename+"_fric")
wks_resid = gsn_open_wks("ps",output_filename+"_resid")

gsn_define_colormap(wks_adv,"wind_constancy")
gsn_define_colormap(wks_curv,"wind_constancy")
gsn_define_colormap(wks_pg,"wind_constancy")
gsn_define_colormap(wks_cf,"wind_constancy")
gsn_define_colormap(wks_d_dt,"wind_constancy")
gsn_define_colormap(wks_fric,"wind_constancy")
gsn_define_colormap(wks_resid,"wind_constancy")

 res = True

 res@gsnMaximize                 = True            ; Maximize plot in frame
 res@gsnAddCyclic                = False           ; This is not global data
 res@gsnFrame                    = False           ; Do not advance frame
 res@gsnDraw                     = False

 res@mpProjection                = "Stereographic" ; Polar stereographic map projection

 res@mpLimitMode                 = "Points"        ; How to zoom in on the map
 res@mpDataBaseVersion           = "HighRes"       ; Use high resolution map information

;; Dimensions for full RIS

; res@mpCenterLonF                = -180.           ; Set dimensions of map to zoom in on our area
; res@mpCenterLatF                = -82.0           ; Set dimensions of map to zoom in on our area
; res@mpLeftPointLatF             = -77.0
; res@mpLeftPointLonF             = 160.            ; Set dimentions of map to zoom in on our area
; res@mpRightPointLatF            = -77.0           ; Set dimentions of map to zoom in on our area
; res@mpRightPointLonF            = -150.0          ; Set dimentions of map to zoom in on our area

; res@mpTopPointLatF              = -77.           ; Set dimentions of map to zoom in on our area
; res@mpTopPointLonF              = 180.            ; Set dimentions of map to zoom in on our area
; res@mpBottomPointLatF           = -87.           ; Set dimentions of map to zoom in on our area
; res@mpBottomPointLonF           = 180.              ; Set dimentions of map to zoom in on our area

;; Dimensions for zoomed in 

 res@mpCenterLonF                = -180.           ; Set dimensions of map to zoom in on our area
 res@mpCenterLatF                = -85.0
 res@mpLeftPointLatF             = -80.0
 res@mpLeftPointLonF             = 160.            ; Set dimentions of map to zoom in on our area
 res@mpRightPointLatF            = -80.0           ; Set dimentions of map to zoom in on our area
 res@mpRightPointLonF            = -160.0          ; Set dimentions of map to zoom in on our area

 res@mpTopPointLatF              = -80.           ; Set dimentions of map to zoom in on our area
 res@mpTopPointLonF              = 180.            ; Set dimentions of map to zoom in on our area
 res@mpBottomPointLatF           = -87.           ; Set dimentions of map to zoom in on our area
 res@mpBottomPointLonF           = 180.              ; Set dimentions of map to zoom in on our area
 
 res@mpGridAndLimbOn             = True            ; Turn on lat/lon grid
 res@mpGridLineThicknessF        = 0.5             ; Grid thickness
 res@mpGridLineDashPattern       = 2               ; Dash pattern
 res@mpGridAndLimbDrawOrder      = "PostDraw"      ; Overlay grid on what is drawn
 res@mpGridLonSpacingF           = 10.              ; Spacing of latitude and longitude lines on grid
 res@mpGridLatSpacingF           = 2.             ; Spacing of latitude and longitude lines on grid
 res@mpGeophysicalLineThicknessF = 2.0             ; Make continent lines a bit thicker
 res@mpGeophysicalLineColor      = "black"
 res@mpOutlineOn                 = True
 res@mpFillOn                    = False

 res@tiMainSide                  = "Bottom"           ; Put date on the bottom of the plot
 res@tiMainFont                  = 21              ; Title font (helvetica)
 res@tiMainFontHeightF           = 0.015           ; Make title font a bit smaller
 res@tiMainString = "Date: "+month_i+"/"+day_i+"/"+year_i+" "+hour_i+" UTC"
 res@gsnStringFont = "helvetica" 
 
  res@gsnScalarContour            = True
  res@cnLinesOn                   = True           ; Draw contour lines also 
  res@cnFillOn                    = True            ; Turn on contour fill
  res@cnLineLabelsOn               = True
  res@cnLineLabelFont             = 21
  res@cnLineLabelFontHeightF      = 0.01
  res@cnLineLabelFormat           = "@*+^sg"
  res@cnMissingValFillColor       = "LightGrey"
  res@cnMissingValFillPattern     = 0
  res@cnMissingValPerimOn         = True
  res@cnMissingValPerimColor      = "black"
  res@gsnSpreadColors             = True           ; Span full color map
  res@gsnSpreadColorEnd          = -2
  res@lbLabelAutoStride           = True            ; Control labelbar spacing
  res@lbOrientation               = "Vertical"      ; Vertical label bar
  res@lbLabelFont                 = 21              ; Label bar font (helvetica)
  res@lbLabelFontHeightF          = 0.015           ; Make label bar font a bit bigger
  res@gsnPaperOrientation         = "portrait"



  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/0.,0.001,0.002,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.010/) 
;  res@cnLevels = (/0.,0.0025,0.005,0.0075,0.010,0.0125,0.015,0.0175,0.020,0.0225,0.025,0.0275,0.030/) 

;; Resources for vector plots

  res@vcGlyphStyle = "LineArrow"
  res@vcLineArrowColor = "black"
  res@vcRefAnnoOn = False  
  res@vcRefMagnitudeF = 0.002
  res@vcRefLengthF = 0.01
  res@vcMinDistanceF = 0.02


;; Make panel plots of magnitude and diretion of the momentum balance forces

   res@gsnLeftString = "Advection"
   plot_adv = gsn_csm_vector_scalar_map(wks_adv,advection_u,advection_v,advection_mag,res)
   res@gsnLeftString = "Curvature"
   plot_curv = gsn_csm_vector_scalar_map(wks_curv,curvature_u,curvature_v,curvature_mag,res)
   res@gsnLeftString = "Pressure Gradient"
   plot_pg = gsn_csm_vector_scalar_map(wks_pg,pg_u,pg_v,pg_mag,res)
   res@gsnLeftString = "Coriolis"
   plot_cf = gsn_csm_vector_scalar_map(wks_cf,cf_u,cf_v,cf_mag,res)
;   res@cnLevels = (/0.,0.00025,0.0005,0.00075,0.001,0.00125,0.0015,0.00175,0.002,0.00225,0.0025/)
   res@cnLevels = (/0.,0.000125,0.00025,0.000375,0.0005,0.000625,0.00075,0.000875,0.001,0.001125,0.00125/)
   res@vcRefMagnitudeF = 0.0005
   res@vcRefLengthF = 0.015
   res@vcMinDistanceF = 0.02
   res@gsnLeftString = "Acceleration"
   plot_d_dt = gsn_csm_vector_scalar_map(wks_d_dt,du_dt,dv_dt,d_dt_mag,res)
   res@cnLevels = (/0.,0.001,0.002,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.010/)
   res@vcRefMagnitudeF = 0.002
   res@vcRefLengthF = 0.01
   res@vcMinDistanceF = 0.02
   res@gsnLeftString = "Friction"
   plot_fric = gsn_csm_vector_scalar_map(wks_fric,friction_u,friction_v,friction_mag,res)
   res@gsnLeftString = "Residual"
   plot_resid = gsn_csm_vector_scalar_map(wks_resid,residual_u,residual_v,residual_mag,res)


draw(wks_adv)
draw(wks_curv)
draw(wks_pg)
draw(wks_cf)
draw(wks_d_dt)
draw(wks_fric)
draw(wks_resid)


;; Resources for adding markers for AWS 

AWS_lat = (/-84.25,-81.504/)
AWS_lon = (/190.,163.939/)

;AWS_lat = (/-84.25,-81.504,-82.486,-80.,-79.922,-79.952,-79.867,-78.5,-79.935,-79.305,-83.11/)
;AWS_lon = (/190.,163.939,-174.553,-165.,-178.586,175.864,170.142,177.753,165.378,162.985,174.316/)

polyres = True
polyres@gsMarkerIndex     = 16
polyres@gsMarkerSizeF     = 10.0
polyres@gsMarkerColor     = "black"

   gsn_polymarker(wks_adv,plot_adv,AWS_lon,AWS_lat,polyres)
   gsn_polymarker(wks_curv,plot_curv,AWS_lon,AWS_lat,polyres)
   gsn_polymarker(wks_pg,plot_pg,AWS_lon,AWS_lat,polyres)
   gsn_polymarker(wks_cf,plot_cf,AWS_lon,AWS_lat,polyres)
   gsn_polymarker(wks_d_dt,plot_d_dt,AWS_lon,AWS_lat,polyres)
   gsn_polymarker(wks_fric,plot_fric,AWS_lon,AWS_lat,polyres)
   gsn_polymarker(wks_resid,plot_resid,AWS_lon,AWS_lat,polyres)



;; Resources for adding gridpoints

gridpolyres = True
gridpolyres@gsMarkerIndex = 1
gridpolyres@gsMarkerSizeF = 0.015
gridpolyres@gsMarkerColor = "white"


;i=0
;do while(i.le.202)
; j=0
; do while(j.le.200)
;  gsn_polymarker(wks_adv,plot_adv,lon(i,j),lat(i,j),gridpolyres)
;  gsn_polymarker(wks_curv,plot_curv,lon(i,j),lat(i,j),gridpolyres)
;  gsn_polymarker(wks_pg,plot_pg,lon(i,j),lat(i,j),gridpolyres)
;  gsn_polymarker(wks_cf,plot_cf,lon(i,j),lat(i,j),gridpolyres)
;  gsn_polymarker(wks_d_dt,plot_d_dt,lon(i,j),lat(i,j),gridpolyres)
;  gsn_polymarker(wks_fric,plot_fric,lon(i,j),lat(i,j),gridpolyres)
;  gsn_polymarker(wks_resid,plot_resid,lon(i,j),lat(i,j),gridpolyres)
;  j=j+1
;end do
; i=i+1
;end do  

;; Label latitude and longitude grid lines

LatLabels = (/"84S","82S","80S"/)
LatlatLoc = (/-84,-82,-80/)
LatlonLoc = (/-165,-165,-165/)

;; Set resources for latitude and longitude text

txres = True
txres@txFontHeightF = 15.0
txres@txFont        = 22

gsn_text(wks_adv,plot_adv,LatLabels,LatlonLoc,LatlatLoc,txres)
gsn_text(wks_curv,plot_curv,LatLabels,LatlonLoc,LatlatLoc,txres)
gsn_text(wks_pg,plot_pg,LatLabels,LatlonLoc,LatlatLoc,txres)
gsn_text(wks_cf,plot_cf,LatLabels,LatlonLoc,LatlatLoc,txres)
gsn_text(wks_d_dt,plot_d_dt,LatLabels,LatlonLoc,LatlatLoc,txres)
gsn_text(wks_fric,plot_fric,LatLabels,LatlonLoc,LatlatLoc,txres)
gsn_text(wks_resid,plot_resid,LatLabels,LatlonLoc,LatlatLoc,txres)


LonLabels = (/"140E","150E","160E","170E","180","170W","160W","150W","140W"/)
LonlatLoc = (/-85.9,-85.9,-85.9,-85.9,-85.9,-85.9,-85.9,-85.9,-85.9/)
LonlonLoc = (/140,150,160,170,180,190,200,210,220/)

gsn_text(wks_adv,plot_adv,LonLabels,LonlonLoc,LonlatLoc,txres)
gsn_text(wks_curv,plot_curv,LonLabels,LonlonLoc,LonlatLoc,txres)
gsn_text(wks_pg,plot_pg,LonLabels,LonlonLoc,LonlatLoc,txres)
gsn_text(wks_cf,plot_cf,LonLabels,LonlonLoc,LonlatLoc,txres)
gsn_text(wks_d_dt,plot_d_dt,LonLabels,LonlonLoc,LonlatLoc,txres)
gsn_text(wks_fric,plot_fric,LonLabels,LonlonLoc,LonlatLoc,txres)
gsn_text(wks_resid,plot_resid,LonLabels,LonlonLoc,LonlatLoc,txres)

ftxres = True
ftxres@txFontHeightF = 15.0
ftxres@txFont        = 22

mtn_lab = (/"Prince Olav","Mtns","Queen","Alexander","Mtns","Churchill","Mtns"/)
mtn_lat = (/-84.85,-85.1,-82.75,-83.,-83.25,-81.75,-82./)
mtn_lon = (/187.,187.,164.5,164.7,164.5,161.,161./)

gsn_text(wks_adv,plot_adv,mtn_lab,mtn_lon,mtn_lat,ftxres)
gsn_text(wks_curv,plot_curv,mtn_lab,mtn_lon,mtn_lat,ftxres)
gsn_text(wks_pg,plot_pg,mtn_lab,mtn_lon,mtn_lat,ftxres)
gsn_text(wks_cf,plot_cf,mtn_lab,mtn_lon,mtn_lat,ftxres)
gsn_text(wks_d_dt,plot_d_dt,mtn_lab,mtn_lon,mtn_lat,ftxres)
gsn_text(wks_fric,plot_fric,mtn_lab,mtn_lon,mtn_lat,ftxres)
gsn_text(wks_resid,plot_resid,mtn_lab,mtn_lon,mtn_lat,ftxres)


frame(wks_adv)
frame(wks_curv)
frame(wks_pg)
frame(wks_cf)
frame(wks_d_dt)
frame(wks_fric)
frame(wks_resid)

end do 
;end do
end do


end
