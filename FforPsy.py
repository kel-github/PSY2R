from scipy.optimize import brentq
import math

def F_CritProb(x, arglist):
    v1 = round(arglist[1])
    v2 = round(arglist[2])
    return arglist[1] - F_Prob(x, v1, v2)  # Assuming F_Prob is defined elsewhere

def F_Crit(p, v1, v2) -> float:
    macheps = 2.0e-14
    tol = 1.0e-10

    lower, upper = F_Approx(p, v1, v2)  # Assuming F_Approx is defined elsewhere

    arglist = [p, v1, v2]
    critical_value = brentq(F_CritProb, lower, upper, args=(arglist,), xtol=macheps, rtol=tol)

    return critical_value

def F_Approx(p, v1, v2):
    # Taken directly from Psy
    return 0.25, float("9.0e12")

def F_Prob(y, v1, v2):
    # *************************add checks**********************
    # if (v1 <= 0) or (v2 <= 0):
    #     StatDistError('Function F_Prob: df must be > 0')
    # if not (isinteger(v1) and isinteger(v2)):
    #     StatDistError('Function F_Prob: df must both be integers')

    if v1 % 2 == 1 and v2 % 2 == 1:
        return V1oddV2odd(y, v1, v2)
    else:
        if v1 % 2 == 0:
            return V1even(y, v1, v2)
        else:
            return V2even(y, v1, v2)

def V1even(y, v1, v2):
    x = v2 / (v2 + v1 * y)
    if v1 == 2:
        return math.exp(v2 / 2.0 * math.log(x))
    else:
        term1 = math.exp(v2 / 2.0 * math.log(x))
        term2 = 1
        sum1 = 0
        sum2 = 0
        m = 2
        while m <= (v1 - 2):
            sum1 += math.log(v2 + m - 2)
            sum2 += math.log(m)
            term2 += math.exp(sum1 - sum2 + (m / 2.0) * math.log(1.0 - x))
            m += 2
        return term1 * term2

def V2even(y, v1, v2):
    x = 1.0 - v2 / (v2 + v1 * y)
    if v1 == 2:
        return math.exp(v1 / 2.0 * math.log(x))
    else:
        term1 = math.exp(v1 / 2.0 * math.log(x))
        term2 = 1.0
        sum1 = 0.0
        sum2 = 0.0
        m = 2
        while m <= (v2 - 2):
            sum1 += math.log(v1 + m - 2)
            sum2 += math.log(m)
            term2 += math.exp(sum1 - sum2 + (m / 2) * math.log(1 - x))
            m += 2
        return 1 - term1 * term2

def V1oddV2odd(y, v1, v2):
    pa = Av(Theta(y, v1, v2), v2)
    pb = Bv(Theta(y, v1, v2), v1, v2)
    return 1.0 - pa + pb

import math

def Theta(y, v1, v2):
    return math.atan(math.sqrt(y) * math.sqrt(v1 / v2))

def Fx(y, v1, v2):
    return v2 / (v2 + v1 * y)

def Av(t, v2):
    TWO_ON_PI = 2 / math.pi

    if v2 == 1:
        return 2 * t / math.pi
    elif v2 == 3:
        term1 = t + math.sin(t) * math.cos(t)
        return TWO_ON_PI * term1
    else:
        sum1 = 0
        sum2 = 0
        sum3 = 1
        m = 2
        n = 3
        while m <= v2 - 3:
            sum1 += math.log(m)
            sum2 += math.log(n)
            sum3 += math.exp(m * math.log(math.cos(t)) + sum1 - sum2)
            m += 2
            n += 2
        term1 = t + math.sin(t) * math.cos(t) * sum3
        return TWO_ON_PI * term1

def Bv(t, v1, v2):
    TWO_ON_SQRT_PI = 2 / math.sqrt(math.pi)

    if v1 == 1:
        return 0
    else:
        st = math.log(math.sin(t))
        ct = math.log(math.cos(t))
        term1 = math.log(math.factorial((v2 - 1) // 2)) - math.log(math.factorial((v2 - 2) // 2)) + st + v2 * ct
        term2 = 1

        if v1 > 3:
            sum1 = 0
            sum2 = 0
            m = 3
            while m <= (v1 - 2):
                sum1 += math.log(v2 + (m - 2))
                sum2 += math.log(m)
                term2 += math.exp(sum1 - sum2 + (m - 1) * st)
                m += 2

        return TWO_ON_SQRT_PI * math.exp(term1) * term2