using Glob
using NCDatasets

function extractprecip(
    schname :: String,
)

    fncvec = glob("$(schname)_*.nc",datadir(schname,"OUT_2D"))
    nfnc = length(fnc)

    fol = datadir("precipitation");   !isdir(fol)  ? mkdir(fol)         : nothing
    fnc = joinpath(fol,"$schname.nc"); isfile(fnc) ? rm(fnc,force=true) : nothing
    ds  = NCDataset(fnc,"w")

    tds = NCDataset(fncvec[1])
    nx  = tds.dim["x"]
    ny  = tds.dim["y"]

    defDim(ds,"x",nx)
    defDim(ds,"y",ny)
    defDim(ds,"time",nfnc)

    ncx = defVar(ds,"x",Float32,("x",),attrib=Dict(tds["x"].attrib))
    ncy = defVar(ds,"y",Float32,("y",),attrib=Dict(tds["y"].attrib))
    nct = defVar(ds,"time",Float32,("time",),attrib=Dict(tds["time"].attrib))
    ncp = defVar(ds,"Prec",Float32,("x","y","time",),attrib=Dict(tds["Prec"].attrib))

    ncx[:] = tds["x"][:]
    ncy[:] = tds["y"][:]
    nct[:] = collect(1:nfnc) / 48

    close(tds)

    for ifnc = 1 : nfnc
        tds = NCDataset(fncvec[ifnc])
        ncp[:,:,ifnc] = tds["Prec"][:,:,1]
        close(tds)
    end

    close(ds)

end