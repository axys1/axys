local bit = {
    band = function(a, b)
        return a & b
    end,
    bor = function(a, b)
        return a | b
    end,
    bxor = function(a, b)
        return a ~ b
    end,
    bnot = function(a)
        return ~a
    end,
    lshift = function(a, n)
        return a << n
    end,
    rshift = function(a, n)
        return a >> n
    end
}

return bit
