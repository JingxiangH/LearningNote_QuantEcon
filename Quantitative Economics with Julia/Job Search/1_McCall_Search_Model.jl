using LinearAlgebra, Statistics
using Distributions, Expectations, LaTeXStrings
using NLsolve, Roots, Random, Plots

##### Computing the optimal policy I

### Implementation

n = 50
dist = BetaBinomial(n, 200, 100) # probability distribution
@show support(dist)
w = range(10.0, 60.0, length = n + 1) # linearly space wages

using StatsPlots
plt = plot(w, pdf.(dist, support(dist)), xlabel = "wages",
           ylabel = "probabilities", legend = false)

E = expectation(dist) # expectation operator

# exploring the properties of the operator
wage(i) = w[i + 1] # +1 to map from support of 0
E_w = E(wage)
E_w_2 = E(i -> wage(i)^2) - E_w^2 # variance
@show E_w, E_w_2

# use operator with left-multiply
@show E * w # the `w` are values assigned for the discrete states
@show dot(pdf.(dist, support(dist)), w); # identical calculation

# parameters and constant objects

c = 25
beta = 0.99
num_plots = 6

# Operator
# Broadcasts over the w, fixes the v
T(v) = max.(w / (1 - beta), c + beta * E * v)
# alternatively, T(v) = [max(wval/(1 - beta), c + beta * E*v) for wval in w]

# fill in matrix of vs
vs = zeros(n + 1, num_plots) # data to fill
vs[:, 1] .= w / (1 - beta) # initial guess of "accept all"

# manually applying operator, i+1 row is calculated through T(i)
for col in 2:num_plots
    v_last = vs[:, col - 1]
    vs[:, col] .= T(v_last)  # apply operator
end
plot(vs)

function compute_reservation_wage_direct(params; v_iv = collect(w ./ (1 - beta)),
                                         max_iter = 500, tol = 1e-6)
    (; c, beta, w) = params

    # create a closure for the T operator
    T(v) = max.(w / (1 - beta), c + beta * E * v) # (5) fixing the parameter values

    v = copy(v_iv) # copy to prevent v_iv modification # 浅拷贝
    v_next = similar(v)
    i = 0
    error = Inf
    while i < max_iter && error > tol
        v_next .= T(v) # (4)
        error = norm(v_next - v)
        i += 1
        v .= v_next  # copy contents into v
    end
    # now compute the reservation wage
    return (1 - beta) * (c + beta * E * v) # (2)
end

function compute_reservation_wage(params; v_iv = collect(w ./ (1 - beta)),
                                  iterations = 500, ftol = 1e-6, m = 1)
    (; c, beta, w) = params
    T(v) = max.(w / (1 - beta), c + beta * E * v) # (5) fixing the parameter values

    sol = fixedpoint(T, v_iv; iterations, ftol, m) # (5)
    sol.f_converged || error("Failed to converge")
    v_star = sol.zero
    return (1 - beta) * (c + beta * E * v_star) # (3)
end

mcm(; c = 25.0, beta = 0.99, w = range(10.0, 60.0, length = n + 1)) = (; c, beta, w)

compute_reservation_wage(mcm()) # call with default parameters

### Comparative Statics

grid_size = 25
R = zeros(grid_size, grid_size)

c_vals = range(10.0, 30.0, length = grid_size)
beta_vals = range(0.9, 0.99, length = grid_size)

for (i, c) in enumerate(c_vals)
    for (j, beta) in enumerate(beta_vals)
        R[i, j] = compute_reservation_wage(mcm(; c, beta); m = 0)
    end
end

contour(c_vals, beta_vals, R',
        title = "Reservation Wage",
        xlabel = L"c",
        ylabel = L"\beta",
        fill = true)

##### Exercise: 
#Compute the average duration of unemployment when β=0.99 and ̧c takes the following values c_vals = range(10, 40, length = 25)

function compute_reservation_wage_psi(c, beta; psi_iv = E * w ./ (1 - beta),
                                      iterations = 500, ftol = 1e-5, m = 1)
    T_psi(psi) = [c + beta * E * max.((w ./ (1 - beta)), psi[1])] # (7)
    # using vectors since fixedpoint doesn't support scalar
    sol = fixedpoint(T_psi, [psi_iv]; iterations, ftol, m)
    sol.f_converged || error("Failed to converge")
    psi_star = sol.zero[1]
    return (1 - beta) * psi_star # (2)
end

function compute_stopping_time(w_bar; seed = 1234)
    Random.seed!(seed)
    stopping_time = 0
    t = 1
    # make sure the constraint is sometimes binding
    @assert length(w) - 1 ∈ support(dist) && w_bar <= w[end]
    while true
        # Generate a wage draw
        w_val = w[rand(dist)] # the wage dist set up earlier
        if w_val >= w_bar
            stopping_time = t
            break
        else
            t += 1
        end
    end
    return stopping_time
end

function compute_mean_stopping_time(w_bar, num_reps = 10000)
    mean(i -> compute_stopping_time(w_bar,
                                    seed = i), 1:num_reps)
end

c_vals = range(10, 40, length = 25)
stop_times = similar(c_vals)

beta = 0.99
for (i, c) in enumerate(c_vals)
    w_bar = compute_reservation_wage_psi(c, beta)
    stop_times[i] = compute_mean_stopping_time(w_bar)
end

plot(c_vals, stop_times, label = "mean unemployment duration",
     xlabel = "unemployment compensation", ylabel = "months")