using Random
using Plots

# 计算π的函数
function calculate_pi(n)
    inside_circle = 0
    for _ in 1:n
        x, y = rand(), rand()  # 生成两个[0, 1)范围内的随机数
        if x^2 + y^2 <= 1
            inside_circle += 1  # 如果点(x, y)在单位圆内，则计数
        end
    end
    return (inside_circle / n) * 4  # 根据单位圆内点的比例估计π的值
end

n_values = [10^i for i in 4:9]
pi_estimates = [calculate_pi(n) for n in n_values]

# 绘图
plot(n_values, pi_estimates, marker=:circle, labels="Estimate", xscale=:log10, color=:blue,
     xlabel="Number of Points", ylabel="Estimated π", title="Estimation of π")
hline!([π], labels="Actual π", color=:red, linestyle=:dash)

# 调整x轴的标签显示10^4到10^9
xticks = n_values
xticklabels = ["10^4", "10^5", "10^6", "10^7", "10^8", "10^9"]
plot!(xticks=xticks, xticklabels=xticklabels)