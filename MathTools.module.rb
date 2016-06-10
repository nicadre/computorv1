module MathTools

    # precision used for sqrt function
    PRECISION = 0.0001
    TOSUM = 0.000005
    # return the absolute value of val
    def	MathTools.abs(val)
        return -val if val < 0
        val
    end

    # return val ^ 2
    def	MathTools.square(val)
        val * val
    end

    # return false if p < 0 or val ^ p
    def	MathTools.pow(val, p)
        return false if p < 0
        return 1 if p == 0
        return val * pow(val, (p - 1))
    end

    # return false if val < 0 or the sqrt of val
    def	MathTools.sqrt(val)
        return false if val < 0
        return val if val == 0 or val == 1
        max = val / 2
        (0..max).each do |v|
            return v if MathTools.square(v) == val
            if MathTools.square(v) < val and MathTools.square(v + 1) > val
                return MathTools.sqrt_float(val, (v + 1))
            end
        end
    end

    # return an aproximation of the sqrt of val
    def MathTools.sqrt_float(val, aprox)
        while MathTools.abs(MathTools.square(aprox) - val) > PRECISION
            aprox -= TOSUM
        end
        return aprox
    end
end
