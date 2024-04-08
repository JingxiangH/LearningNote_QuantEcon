using Random
using Plots
using Statistics  # 用于计算均值
using StatsPlots

# 计算π的函数
function calculate_pi(n, trials)
    estimates = Float64[]
    for _ in 1:trials
        inside_circle = 0
        for _ in 1:n
            x, y = rand(), rand()  # 生成两个[0, 1)范围内的随机数
            if x^2 + y^2 <= 1
                inside_circle += 1  # 如果点(x, y)在单位圆内，则计数
            end
        end
        push!(estimates, (inside_circle / n) * 4)  # 根据单位圆内点的比例估计π的值
    end
    return estimates
end

# 不同的n值和试验次数
n_values = [10^i for i in 4:7]
trials = 50
all_estimates = [calculate_pi(n, trials) for n in n_values]
means = [mean(estimates) for estimates in all_estimates]

# 绘制频率分布图和均值折线图
plot(layout=(2,1), size=(800, 600))
for i in 1:length(n_values)
    violin!(1, all_estimates[i], label=false)
end
plot!(xticklabels=["10^4", "10^5", "10^6", "10^7"], xlabel="Number of Points (n)", ylabel="Estimates of π", title="Distribution of Estimates")

plot!(n_values, means, marker=:circle, labels="Mean Estimate", color=:blue, subplot=2, xscale=:log10, xlabel="Number of Points (n)", ylabel="Mean Estimate of π", title="Mean Estimation of π with Increasing Number of Points")
hline!([π], labels="Actual π", color=:red, linestyle=:dash, subplot=2)

# 调整x轴的标签显示10^4到10^9
xticks = n_values
xticklabels = ["10^4", "10^5", "10^6", "10^7"]
plot!(xticks=xticks, xticklabels=xticklabels)