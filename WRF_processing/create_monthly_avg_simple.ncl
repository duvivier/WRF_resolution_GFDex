;***************************************
; Simple script to create a single monthly average from a
; single wrf file made up of multiple time steps.
;
; Matt Higigns
; 3 Jun 2010
;
;
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin

  dirin     = (/"wrf_monthly",   "met_monthly"/)
  dirout    = (/"wrf_avg_mon",   "met_avg_mon"/)

  d = 0  ; set to 0 if using wrf, 1 if using met

  files = systemfunc("ls "+dirin(d))
  nfiles = dimsizes(files)

  vars_1d = (/"year", "month"/)
  vars_2d = (/"lat", "lon", "Z_sfc","LandMask"/)
  vars_3d = (/"SST", "T_sfc", "p_sfc", "slp", "T_2m", "Td_2m", "q_2m", "u_10m_gr", "v_10m_gr", \
                "SW_d", "LW_d", "albedo", "SHFlx", "LHFlx", "u_star", "u_10m_tr", "v_10m_tr", \
                "LWP", "IWP", "SnowHgt", "SnowWater", "SnowDens", "SnowFlx", "SeaIce", "GroundFlx"/)
  vars_4d = (/"Z_p", "T_p", "q_p","u_gr_p","v_gr_p","u_tr_p","v_tr_p",\
              "Z_e","T_e","Th_e","u_gr_e","v_gr_e","u_tr_e","v_tr_e",\
              "SoilTemp", "SoilMoist"/)
  vars_spec = (/"precip_g", "precip_c"/)  ; requires special handling; for WRF data
  vars_spec2 = (/"PrecipRate"/)  ; requires special handling; for NCEP data


  do f = 0, nfiles-1

    f1 = addfile(dirin(d)+"/"+files(f), "r")
    print("processing "+files(f))

    print("creating output file ")
    fout = addfile(dirout(d)+"/"+files(f), "c")

    print("Processing 1d variables.")
    do v = 0, dimsizes(vars_1d)-1
;    do v = 0, -1
      if(isfilevar(f1,vars_1d(v))) then
        print("Processing "+vars_1d(v))
        var1_all = f1->$vars_1d(v)$
        var1 = dim_avg_n_Wrap(var1_all,0)

        print("Writing "+vars_1d(v))
        fout->$vars_1d(v)$ = var1

        delete(var1_all)
        delete(var1)
      end if
      if(.not.isfilevar(f1,vars_1d(v))) then
        print("Skipping "+vars_1d(v))
      end if
    end do

    print("Processing 2d variables.")
    do v = 0, dimsizes(vars_2d)-1
;    do v = 0, -1
      if(isfilevar(f1,vars_2d(v))) then
        print("Processing "+vars_2d(v))
        var1 = f1->$vars_2d(v)$ 
        print("Writing "+vars_2d(v))
        fout->$vars_2d(v)$ = var1
        delete(var1)
      end if
      if(.not.isfilevar(f1,vars_2d(v))) then
        print("Skipping "+vars_2d(v))
      end if
    end do

    print("Processing 3d variables.")
    do v = 0, dimsizes(vars_3d)-1
;    do v = 0, -1
      if(isfilevar(f1,vars_3d(v))) then
        print("Processing "+vars_3d(v))
        var1_all = f1->$vars_3d(v)$
        var1 = dim_avg_n_Wrap(var1_all,0)
	var1_var = dim_variance_n_Wrap(var1_all,0)
	var1_neqv = equiv_sample_size(var1_all(south_north|:,west_east|:,time|:),0.05,0)

; fix metadata for neqv
	copy_VarCoords(var1_var,var1_neqv)
	if(isatt(var1_var,"_FillValue")) then
          temp1 = var1_var@_FillValue
          delete(var1_var@_FillValue)
        end if
        copy_VarAtts(var1_var,var1_neqv)
        delete(var1_neqv@variance_op_ncl) ; doesn't make sense to have this
        if (isdefined("temp1")) then
          var1_var@_FillValue = temp1       ; put it back
        end if
        var1_neqv@neqv = "equivalent sample size for this month"
        print("Writing "+vars_3d(v))
        fout->$vars_3d(v)$ = var1
        newstring = vars_3d(v)+"_var"
        fout->$newstring$ = var1_var
        newstring = vars_3d(v)+"_neqv"
        fout->$newstring$ = var1_neqv
        delete(var1)
        delete(var1_all)
        delete(var1_neqv)
	delete(var1_var)
        if (isdefined("temp1")) then
          delete(temp1)
        end if
      end if
      if(.not.isfilevar(f1,vars_3d(v))) then
        print("Skipping "+vars_3d(v))
      end if
    end do

    print("Processing 4d variables.")
    do v = 0, dimsizes(vars_4d)-1
;    do v = 0, -1
      if(isfilevar(f1,vars_4d(v))) then
        print("Processing "+vars_4d(v))
        var1_all = f1->$vars_4d(v)$
        dims1    = dimsizes(var1_all)
        dimnames = getfilevardims(f1,vars_4d(v))
; will run out of memory, so just use a few plevels.
        if ((d.eq.1).and.(dimnames(1).eq."pressure")) then
          print("Extracting pressure levels.")
          wantedplevels = (/850,700,500,300/)
          var1_all_b = var1_all(time|:,{pressure|wantedplevels},south_north|:,west_east|:)
          delete(var1_all)
          var1_all = var1_all_b
          delete(var1_all_b)
          dims1    = dimsizes(var1_all)
        end if
        var1 = dim_avg_n_Wrap(var1_all,0)
        var1_var = dim_variance_n_Wrap(var1_all,0)
        var1_neqv = equiv_sample_size(var1_all($dimnames(1)$|:,$dimnames(2)$|:,$dimnames(3)$|:,time|:),0.05,0)
; fix metadata for neqv
        copy_VarCoords(var1_var,var1_neqv)
	if(isatt(var1_var,"_FillValue")) then
          temp1 = var1_var@_FillValue
          delete(var1_var@_FillValue)
        end if
        copy_VarAtts(var1_var,var1_neqv)
        delete(var1_neqv@variance_op_ncl) ; doesn't make sense to have this
        if (isdefined("temp1")) then
          var1_var@_FillValue = temp1       ; put it back
        end if
        var1_neqv@neqv = "equivalent sample size for this month"
        print("Writing "+vars_4d(v))
        fout->$vars_4d(v)$ = var1
	  newstring = vars_4d(v)+"_var"
        fout->$newstring$ = var1_var
        newstring = vars_4d(v)+"_neqv"
        fout->$newstring$ = var1_neqv
        delete(var1_all)
        delete(var1)
        delete(dims1)
        delete(dimnames)
        delete(var1_var)
        delete(var1_neqv)
        if (isdefined("temp1")) then
           delete(temp1)
        end if
      end if
      if(.not.isfilevar(f1,vars_4d(v))) then
        print("Skipping "+vars_4d(v))
      end if
    end do

    print("Processing special variables.")
    do v = 0, dimsizes(vars_spec)-1
      if(isfilevar(f1,vars_spec(v))) then
        print("Processing "+vars_spec(v))
        var1_all = f1->$vars_spec(v)$

        dims1 = dimsizes(var1_all)
        ntime = dims1(0)
        endtime = ntime - 1
        var1 = var1_all(ntime-1,:,:) - var1_all(0,:,:)

        var1_ext = var1_all(0,:,:)

        copy_VarMeta(var1_ext, var1)
        var1@comment = "monthly total"

	delete(dims1)
        delete(var1_all)
        delete(var1)
        delete(var1_ext)

      end if
      if(.not.isfilevar(f1,vars_spec(v))) then
        print("Skipping "+vars_spec(v))
      end if
    end do

    print("Processing special variables part 2.")
    do v = 0, dimsizes(vars_spec2)-1

; this section needs to be updated for ERA-Interim data

      if(isfilevar(f1,vars_spec2(v))) then
        print("Processing "+vars_spec2(v))
      end if
      if(.not.isfilevar(f1,vars_spec2(v))) then
        print("Skipping "+vars_spec2(v))
      end if

    end do

    fileAtt                = True
    fileAtt@creation_date  =  systemfunc("date")
    fileAtt@created_by     = "Alice DuVivier - alice.duvivier@colorado.edu"
    fileAtt@comment0       = "Created with NCL script: create_monthly_avg_simple.ncl"
    fileattdef(fout, fileAtt)                             
    delete(f1)


  end do ; file loop

 

end
