##__2x2Layer
##This code is an attempt at implementing the 2x2 MERA scheme for 2D square lattices as seen in this reference: https://arxiv.org/pdf/0707.1454
##I have not yet tested this
struct __2x2Layer{ST, ET, Tan} <: SimpleLayer
    # Even though the types are here marked as any, they are restricted to be specific,
    # concrete types dependent on ST, ET and Tan, both in the constructor and in
    # getproperty.
    disentangler::Any
    isometry::Any

    function BinaryLayer{ST, ET, Tan}(disentangler, isometry) where {ST, ET, Tan}
        DisType = disentangler_type(ST, ET, Tan)
        IsoType = binaryisometry_type(ST, ET, Tan)
        disconv = convert(DisType, disentangler)::DisType
        isoconv = convert(IsoType, isometry)::IsoType
        return new{ST, ET, Tan}(disconv, isoconv)
    end
end

function __2x2Layer(disentangler::DisType, isometry::IsoType) where {
    ST,
    DisType <: AbstractTensorMap{ST, 4, 4},
    IsoType <: AbstractTensorMap{ST, 4, 1}
}
    ET = eltype(DisType)
    @assert eltype(IsoType) === ET
    return BinaryLayer{ST, ET, false}(disentangler, isometry)
end

function __2x2Layer(disentangler::DisTanType, isometry::IsoTanType) where {
    ST,
    DisType <: AbstractTensorMap{ST, 4, 4},
    IsoType <: AbstractTensorMap{ST, 4, 1},
    DisTanType <: Stiefel.StiefelTangent{DisType},
    IsoTanType <: Grassmann.GrassmannTangent{IsoType},
}
    ET = eltype(DisType)
    @assert eltype(IsoType) === ET
    return BinaryLayer{ST, ET, true}(disentangler, isometry)
end

function Base.getproperty(l::BinaryLayer{ST, ET, Tan}, sym::Symbol) where {ST, ET, Tan}
    if sym === :disentangler
        T = disentangler_type(ST, ET, Tan)
    elseif sym === :isometry
        T = binaryisometry_type(ST, ET, Tan)
    else
        T = Any
    end
    return getfield(l, sym)::T
end

__2x2Mera{N} = GenericMERA{N, T, O} where {T <: __2x2Layer, O}
layertype(::Type{__2x2Mera}) = __2x2Layer
