MathExtend = {}
Deg2Rad = (3.1415926 * 2) / 360

MathExtend.ParseInt = function (val)
    return math.floor(val + 0.000001)
end

MathExtend.Pow = function (v, n)
    if (n == 1) then return v end
    local val = 1
    for i = 1, n, 1 do
        val = val * v
    end
    return val
end


MathExtend.Decimal = function (v, num)
    if (num == nil) then num = 0 end
    v = ParseInt(v * Pow(10, num))
    v = v / Pow(10, num)
    return v
end

MathExtend.SortList = function (list, order, isUp)
    isUp = isUp or false -- 默认降序
    for i = 1, #list - 1 do
        local k = i
        for j = i + 1, #list do
            if isUp then
                if (order and list[k][order] > list[j][order]) or (not order and list[k] > list[j]) then
                    k = j
                end
            else
                if (order and list[k][order] < list[j][order]) or (not order and list[k] < list[j]) then
                    k = j
                end
            end            
        end
        if k ~= i then
            list[i],list[k] = list[k],list[i]
        end
    end
    return list
end

MathExtend.SortListCom = function (list, call)
    for i = 1, #list - 1 do
        local k = i
        for j = i + 1, #list do
            if call(list[k], list[j]) then
                k = j
            end
        end
        if k ~= i then
            list[i],list[k] = list[k],list[i]
        end
    end
    return list
end

MathExtend.isTimeValidity = function (beginT, endT)
    local curT=os.time()
    if beginT and beginT >= 0 and curT < beginT then
        return false
    end
    if endT and endT >= 0 and curT > endT then
        return false
    end
    return true
end

MathExtend.RandomGroup = function (num)
    local data = {}
    for i = 1, num do
        data[#data + 1] = i
    end
    local num1 = num
    while num1 > 1 do
        local i = math.random(1, num1)
        if i ~= num1 then
            data[i],data[num1] = data[num1],data[i]
        end
        num1 = num1 - 1
    end
    return data
end


-- 高n位
MathExtend.GetGW = function (num, n)    
    local a = 0
    local s = 0
    local b = 0
    num = math.floor(tonumber(num))
    while (num > 0) do
        local d = num % 10
        num = math.floor(num/10)
        if a >= n then
            s = s + math.pow(10,n) * d
        else
            s = s + math.pow(10,a) * d
        end
        a = a + 1
        if s > math.pow(10, n) then
            s = math.floor(s/10)
        end
    end

    local tt = {g=s}
    if a < n then
        tt.w = 1
    else
        tt.w = math.pow(10,a-n)
    end
    return tt
end

MathExtend.SplitNumber = function (num, n)
    local tt
    if n < 10 then
        tt = MathExtend.GetGW(num, 2)
    else
        tt = MathExtend.GetGW(num, 3)
    end

    local a = math.floor(tt.g/n)
    local mm = {}
    local all = 0
    for i=1,n do
        if i < n then
            mm[#mm + 1] = a * tt.w
            all = all + mm[#mm]
        else
            mm[#mm + 1] = num - all
        end
    end
    return mm
end