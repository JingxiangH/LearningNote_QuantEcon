function calculate_pi(n)
    inside_circle = 0
    for _ in 1:n
        x = rand() # 生成一个[0, 1)范围内的随机数
        y = rand() # 生成另一个[0, 1)范围内的随机数
        if x^2 + y^2 <= 1
            inside_circle += 1 # 如果点(x, y)在单位圆内，则计数
        end
    end
    return (inside_circle / n) * 4 # 根据单位圆内点的比例估计π的值
end

# 调用函数，参数为随机点的数量
n = 1000000 # 可以调整这个数值以查看不同的精度
pi_estimate = calculate_pi(n)
println("Estimated π with ", n, " points is ", pi_estimate)