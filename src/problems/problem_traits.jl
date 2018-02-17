is_diagonal_noise(prob::AbstractRODEProblem{uType,tType,isinplace,ND}) where {uType,tType,isinplace,ND} = ND <: Void

isinplace(prob::P) where {P <: DEProblem} = isinplace(P)
isinplace(::Type{<:AbstractODEProblem{uType,tType,iip}}) where {uType,tType,iip} = iip
isinplace(::Type{<:AbstractSteadyStateProblem{uType,iip}}) where {uType,iip} = iip
isinplace(::Type{<:AbstractRODEProblem{uType,tType,iip,ND}}) where {uType,tType,iip,ND} = iip
isinplace(::Type{<:AbstractDDEProblem{uType,tType,lType,iip}}) where {uType,tType,lType,iip} = iip
isinplace(::Type{<:AbstractDAEProblem{uType,duType,tType,iip}}) where {uType,duType,tType,iip} = iip
isinplace(::Type{NoiseProblem{N}}) where N = isinplace(N)
isinplace(::Type{<:AbstractNoiseProcess{T,N,iip}}) where {T,N,iip} = iip
isinplace(prob::AbstractNoiseProblem) = isinplace(prob.noise)

### Displays

Base.summary(prob::DEProblem) = string(parameterless_type(prob)," with uType ",typeof(prob.u0)," and tType ",typeof(prob.tspan[1]),". In-place: ",isinplace(prob))
Base.summary(prob::AbstractSteadyStateProblem{uType,iip}) where {uType,iip} = string(parameterless_type(prob)," with uType ",uType)
Base.summary(prob::AbstractNoiseProblem) = string(parameterless_type(prob)," with WType ",typeof(prob.noise.W[1])," and tType ",typeof(prob.tspan[1]),". In-place: ",isinplace(prob))
function Base.show(io::IO, A::DEProblem)
  println(io,summary(A))
  print(io,"timespan: ")
  show(io,A.tspan)
  println(io)
  print(io,"u0: ")
  show(io, A.u0)
end
function Base.show(io::IO, A::AbstractNoiseProblem)
  println(io,summary(A))
  print(io,"timespan: ")
  show(io,A.tspan)
  println(io)
end
function Base.show(io::IO, A::AbstractDAEProblem)
  println(io,summary(A))
  print(io,"timespan: ")
  show(io,A.tspan)
  println(io)
  print(io,"u0: ")
  show(io, A.u0)
  println(io)
  print(io,"du0: ")
  show(io, A.du0)
end
function Base.show(io::IO, A::AbstractSteadyStateProblem)
  println(io,summary(A))
  print(io,"u0: ")
  show(io, A.u0)
end

Base.summary(prob::AbstractMonteCarloProblem) = string(DiffEqBase.parameterless_type(prob)," with problem ",DiffEqBase.parameterless_type(prob.prob))
Base.show(io::IO, A::AbstractMonteCarloProblem) = print(io,summary(A))
