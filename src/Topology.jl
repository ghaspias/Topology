# Topology-related algorithms
module Topology

export stl2tri, readstl, indexstl

# returns the unique elements
function unique(r::Array)

    (idx,rs)=sortrows(r)
    sz=size(r)

    idxu=prod((diff(rs[[end,1:end],:]).==0)+0,2).==0;
    #idxu=sum(abs(diff(rs[[end,1:end],:])),2).!=0
    ru=rs[idxu[:],:];

    idxU::Array{Int,1}=zeros(sz[1])
    idxU[idx[:]]=int(cumsum(idxu[:])) # Should we reshape this?

    return ru,idx,idxU

end

# this does something like sortrows in Matlab
function sortrows(r::Array)
# TO-DO: finish implementing interface equivalent to Matlab
# NOTE: this is probably not needed in v. 0.2, which has sortrows(...)

    rs=r
    sz=size(rs)
    idx=1:sz[1]

    if length(sz)>=2
        for d=sz[2]:-1:1
            idx2=sortperm(rs[:,d])
            rs=rs[idx2,:]
            idx=idx[idx2]
        end;
    else
        idx=sortperm(rs)
        rs=rs[idx];
    end

    return (idx,rs)
end

# Include description here
function readstl(f::String)

    hf=open(f,"r")
    cab=read(hf,Uint8,80)
    cab=ascii(cab)
    n=convert(Int,read(hf,Int32))
    dat=convert(Array{Uint32,2},read(hf,Uint16,25,n)[1:24,:])
    close(hf)

    N=reshape(dat[1:2:6,:]+dat[2:2:6,:]*2^16,3,n)
    N=reinterpret(Float32,N)

    M=reshape(dat[6+(1:2:18),:]+dat[6+(2:2:18),:]*2^16,3,3,n)
    M=reinterpret(Float32,M)

    return M,N,cab
end

# Include description here
function indexstl(Mat)
    (UV,idxV,idxU)=unique(Mat)
    return reshape(idxU,3,int(size(Mat,1)/3)),UV
end

# Include description here
function stl2tri(f::String)
    (M,N,I)=readstl(f)
    (T,V)=indexstl(M[:,:]')
    return T',V
end

end # module Topology

