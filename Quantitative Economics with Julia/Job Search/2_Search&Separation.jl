using LinearAlgebra, Statistics
using Distributions, Expectations, LaTeXStrings,NLsolve, Plots

using Distributions, LinearAlgebra, Expectations, NLsolve, Plots

function solve_mccall_model(mcm; U_iv = 1.0, V_iv = ones(length(mcm.w)), tol = 1e-5,
                            iter = 2_000)
    (; alpha, beta, sigma, c, gamma, w, dist, u) = mcm

    # parameter validation
    @assert c > 0.0
    @assert minimum(w) > 0.0 # perhaps not strictly necessary, but useful here

    # necessary objects
    u_w = mcm.u.(w, sigma)
    u_c = mcm.u(c, sigma)
    E = expectation(dist) # expectation operator for wage distribution

    # Bellman operator T. Fixed point is x* s.t. T(x*) = x*
    function T(x)
        V = x[1:(end - 1)]
        U = x[end]
        [u_w + beta * ((1 - alpha) * V .+ alpha * U);
         u_c + beta * (1 - gamma) * U + beta * gamma * E * max.(U, V)]
    end

    # value function iteration
    x_iv = [V_iv; U_iv] # initial x val
    xstar = fixedpoint(T, x_iv, iterations = iter, xtol = tol, m = 0).zero
    V = xstar[1:(end - 1)]
    U = xstar[end]

    # compute the reservation wage
    wbarindex = searchsortedfirst(V .- U, 0.0)
    if wbarindex >= length(w) # if this is true, you never want to accept
        w_bar = Inf
    else
        w_bar = w[wbarindex] # otherwise, return the number
    end

    # return a NamedTuple, so we can select values by name
    return (; V, U, w_bar)
end

function McCallModel(; alpha = 0.2,
                    beta = 0.98, # discount rate
                    gamma = 0.7,
                    c = 6.0, # unemployment compensation
                    sigma = 2.0,
                    u = (c, sigma) -> (c^(1 - sigma) - 1) / (1 - sigma),
                    w = range(10, 20, length = 60), # wage values
                    dist = BetaBinomial(59, 600, 400)) # distribution over wage values
    return (; alpha, beta, gamma, c, sigma, u, w, dist)
end

# plots setting

mcm = McCallModel()
(; V, U) = solve_mccall_model(mcm)
U_vec = fill(U, length(mcm.w))

plot(mcm.w, [V U_vec], lw = 2, alpha = 0.7, label = [L"V" L"U"])