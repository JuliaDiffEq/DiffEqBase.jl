# Implements passing in Jacobians (and possibly other functions) via
# function overloading:
#
# - f(...) - objective function
# - f(Val{:jac}, ...) - Jacobian of objective function
# - the details of what `...` needs to be depends on the
#   AbstractODEProblem subtype


# Method_exists does not work:
#
# julia> f(::Val{:jac}, a, b, c) = 5
# f (generic function with 1 method)
#
# julia> method_exists(f, Tuple{Val{:jac}, Vararg})
# false
#
# Thus hand-code it:
"Check whether the first argument of any method matches one passed in"
check_first_arg(f,T::Type) = check_first_arg(typeof(f),T)
function check_first_arg{F}(::Type{F}, T::Type)
    typ = Tuple{Any, T, Vararg}
    typ2 = Tuple{Any, Type{T}, Vararg} # This one is required for overloaded types
    for m in Base.MethodList(F.name.mt) # F.name.mt gets the method-table
        (m.sig<:typ || m.sig<:typ2) && return true
    end
    return false
end
"Return the first argument of a method"
get_first_arg(m::Method) = m.sig.parameters[2]
# Note above function cannot be type stable as m.sig is not typed

"Return all methods which have a `Val` as first argument type."
function methods_overloaded{F}(f::F)
    out = []
    for m in Base.MethodList(F.name.mt) # F.name.mt gets the method-table
        get_first_arg(m)<:Val && push!(out, m)
    end
    return out
end

# Standard
@traitdef HasJac{F}
@traitdef HastGrad{F}
__has_jac(f) = check_first_arg(f, Val{:jac})
__has_tgrad(f) = check_first_arg(f, Val{:tgrad})
@generated SimpleTraits.trait{F}(::Type{HasJac{F}}) = __has_jac(F) ? :(HasJac{F}) : :(Not{HasJac{F}})
@generated SimpleTraits.trait{F}(::Type{HastGrad{F}}) = __has_tgrad(F) ? :(HastGrad{F}) : :(Not{HastGrad{F}})
has_jac{T}(f::T)   = istrait(HasJac{T})
has_tgrad{T}(f::T) = istrait(HastGrad{T})

# Performance
@traitdef HasExpJac{F}
@traitdef HasInvJac{F}
@traitdef HasInvW{F}
@traitdef HasInvW_t{F}
__has_expjac(f) = check_first_arg(f, Val{:expjac})
__has_invjac(f) = check_first_arg(f, Val{:invjac})
__has_invW(f) = check_first_arg(f, Val{:invW})
__has_invW_t(f) = check_first_arg(f, Val{:invW_t})
@generated SimpleTraits.trait{F}(::Type{HasExpJac{F}}) = __has_expjac(F) ? :(HasExpJac{F}) : :(Not{HasExpJac{F}})
@generated SimpleTraits.trait{F}(::Type{HasInvJac{F}}) = __has_invjac(F) ? :(HasInvJac{F}) : :(Not{HasInvJac{F}})
@generated SimpleTraits.trait{F}(::Type{HasInvW{F}}) = __has_invW(F) ? :(HasInvW{F}) : :(Not{HasInvW{F}})
@generated SimpleTraits.trait{F}(::Type{HasInvW_t{F}}) = __has_invW_t(F) ? :(HasInvW_t{F}) : :(Not{HasInvW_t{F}})
has_expjac{T}(f::T) = istrait(HasExpJac{T})
has_invjac{T}(f::T) = istrait(HasInvJac{T})
has_invW{T}(f::T)   = istrait(HasInvW{T})
has_invW_t{T}(f::T) = istrait(HasInvW_t{T})

# Hessians
@traitdef HasHes{F}
@traitdef HasInvHes{F}
__has_hes(f) = check_first_arg(f, Val{:hes})
__has_invhes(f) = check_first_arg(f, Val{:invhes})
@generated SimpleTraits.trait{F}(::Type{HasHes{F}}) = __has_hes(F) ? :(HasHes{F}) : :(Not{HasHes{F}})
@generated SimpleTraits.trait{F}(::Type{HasInvHes{F}}) = __has_invhes(F) ? :(HasInvHes{F}) : :(Not{HasInvHes{F}})
has_hes{T}(f::T)      = istrait(HasHes{T})
has_invhes{T}(f::T)   = istrait(HasInvHes{T})

# Parameter-Based
@traitdef HasParamDeriv{F}
@traitdef HasParamJac{F}
__has_paramderiv(f) = check_first_arg(f, Val{:deriv})
__has_paramjac(f) = check_first_arg(f, Val{:paramjac})
@generated SimpleTraits.trait{F}(::Type{HasParamDeriv{F}}) = __has_paramderiv(F) ? :(HasParamDeriv{F}) : :(Not{HasParamDeriv{F}})
@generated SimpleTraits.trait{F}(::Type{HasParamJac{F}}) = __has_paramjac(F) ? :(HasParamJac{F}) : :(Not{HasParamJac{F}})
has_paramderiv{T}(f::T) = istrait(HasParamDeriv{T})
has_paramjac{T}(f::T)   = istrait(HasParamJac{T})

# now a trait methods can dispatch on this:
# @traitfn fn(g::::HasJac, ...) = ...
# @traitfn fn(g::::(!HasJac), ...) = ...


#=
Function "traits"
- inplace
- implicitly defined


=#
