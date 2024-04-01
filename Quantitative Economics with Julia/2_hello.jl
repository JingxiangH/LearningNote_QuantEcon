using Plots

f(x) = 2 * x
g(x) = 3 * x
a =  1 : 5
b = f.(a)
plot(a,b)