using Plots, Random

f(x) = x + 1
function plot_results()
    x = 1:5
    y = f.(x)
    Fig = plot(x, y)
    display(Fig)
    print(y)
end

# execute main function
plot_results() 