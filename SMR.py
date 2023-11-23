import math
from PsyBaseStats import *

def Smrpct(l, arglist):
    p = round(arglist[0])
    q = round(arglist[1])
    tau = round(arglist[2])
    a = arglist[3]
    return 1 - MultipleIntegral(p, q, tau, l) - a

def SmrCriticalValue(p, q, tau, a):
    if tau == 0:
        arglist = [p, q, a]
        zerofn = Gmqlpct
        return BrentZero(zerofn, 1.0, 2000.0, arglist, 1.0e-16, 1.0e-08)
    else:
        lowerlimit = SmrCriticalValue(p, q, 0, a)
        if tau > 350:
            arglist = [p, q, 250, a]
            zerofn = Smrpct
            upperlimit = BrentZero(zerofn, lowerlimit, 50.0, arglist, 1.0e-16, 1.0e-08)
        elif tau == 1:
            upperlimit = 1.0e+07
        elif tau == 2:
            upperlimit = 2.0e+04
        else:
            upperlimit = 2.0e+03

        arglist = [p, q, tau, a]
        zerofn = Smrpct
        return BrentZero(zerofn, lowerlimit, upperlimit, arglist, 1.0e-16, 1.0e-08)

def SmrPercentile(p, q, tau, a):
    if tau == 0:
        return 1 - Davis(p, q, a)
    else:
        return 1 - MultipleIntegral(p, q, tau, a)

# Additional implementations for the functions called in the provided code
def Gmqlpct(l, arglist):
    # Implement Gmqlpct function logic here
    pass

def MultipleIntegral(p, q, tau, l):
    # Implement MultipleIntegral function logic here
    pass

def Davis(p, q, a):
    # Implement Davis function logic here
    pass

def BrentZero(zerofn, lower, upper, arglist, e1, e2):
    # Implement BrentZero function logic here
    pass

SMALLEST_EXPONENT = -1.0e+04

def ExpTest(x):
    if x > SMALLEST_EXPONENT:
        return math.exp(x)
    else:
        return 0.0

def Gamma_ab(alpham1, beta, x):
    alpha = alpham1 + 1
    work = [
        math.exp(-alpha * math.log(beta)),
        Gamma(alpha),
        IncompleteGamma(beta * x, alpha)
    ]
    return work[0] * work[1] * work[2]

def Gfnr(r, a, q, b, l):
    tmp = [0.0] * 6

    if r == 0:
        if l == 0:
            return 0
        else:
            return ExpTest(-a * l + (math.log(l) * (a * q + b)))

    elif r == 1:
        return Gamma_ab(a * q + b, a, l)

    elif r == 2:
        tmp[0] = Gamma_ab(a * q + b, a, l)
        tmp[1] = Gamma_ab(a * q + b + 1, a, l)
        return l * tmp[0] - tmp[1]

    elif r == 3:
        tmp[0] = l * l * Gamma_ab(a * q + b, a, l)
        tmp[1] = 2 * l * Gamma_ab(a * q + b + 1, a, l)
        tmp[2] = Gamma_ab(a * q + b + 2, a, l)
        tmp[3] = tmp[0] - tmp[1] + tmp[2]
        return tmp[3] / math.gamma(3)

    elif r == 4:
        tmp[0] = l * l * l * Gamma_ab(a * q + b, a, l)
        tmp[1] = 3 * l * l * Gamma_ab(a * q + b + 1, a, l)
        tmp[2] = 3 * l * Gamma_ab(a * q + b + 2, a, l)
        tmp[3] = Gamma_ab(a * q + b + 3, a, l)
        tmp[4] = tmp[0] - tmp[1] + tmp[2] - tmp[3]
        return tmp[4] / math.gamma(4)

def Davis(m, q, l):
    work = [0.0] * 26

    if m == 2:
        work[0] = math.exp(-math.lgamma(q - 1))
        work[1] = Gfnr(1, 1, q, -2, l)
        work[2] = Gfnr(0, 1/2, q, -1/2, l)
        work[3] = Gfnr(1, 1/2, q, -3/2, l)
        return work[0] * (work[1] - 0.5 * work[2] * work[3])

    elif m == 3:
        work[0] = (q / 2 * math.log(2)) + math.lgamma(q / 2) + math.lgamma(q - 1)
        work[0] = math.exp(-work[0])
        work[1] = Gfnr(1, 1/2, q, -1, l)
        work[2] = Gfnr(1, 1, q, -2, l)
        work[3] = Gfnr(0, 1/2, q, -1, l)
        work[4] = Gfnr(2, 1, q, -2, l)
        return work[0] * (work[1] * work[2] - 2 * work[3] * work[4])

    elif m == 4:
        work[0] = math.lgamma(q - 1) + math.lgamma(q - 2)
        work[0] = math.exp(-work[0])
        work[1] = Gfnr(1, 1, q, -2, l) * Gfnr(1, 1, q, -3, l)
        work[2] = Gfnr(0, 1, q, -2, l) * Gfnr(2, 1, q, -3, l)
        work[3] = Gfnr(0, 1/2, q, -3/2, l) * Gfnr(1, 1/2, q, -3/2, l) * Gfnr(3, 1, q, -3, l)
        return work[0] * (work[1] - work[2] - 0.5 * work[3])

    elif m == 5:
        work[0] = math.lgamma(0.5 * q - 1) + math.lgamma(q - 1) + math.lgamma(q - 3)
        work[0] = (0.5 * q - 1) * math.log(2) + work[0]
        work[0] = math.exp(-work[0])

        work[1] = Gfnr(1, 1/2, q, -2, l)
        work[2] = Gfnr(1, 1, q, -2, l)
        work[3] = Gfnr(1, 1, q, -4, l)
        work[4] = work[1] * work[2] * work[3]

        work[5] = Gfnr(0, 1/2, q, -1, l)
        work[6] = Gfnr(1, 1, q, -4, l)
        work[7] = Gfnr(2, 1, q, -3, l)
        work[8] = work[5] * work[6] * work[7]

        work[9] = Gfnr(0, 3/2, q, -4, l)
        work[10] = Gfnr(3, 1, q, -4, l)
        work[11] = work[9] * work[10]

        work[12] = Gfnr(0, 1/2, q, -2, l)
        work[13] = Gfnr(1, 1, q, -3, l)
        work[14] = Gfnr(4, 1, q, -4, l)
        work[15] = work[12] * work[13] * work[14]

        work[16] = Gfnr(0, 1, q, -3, l)
        work[17] = Gfnr(1, 1/2, q, -2, l)
        work[18] = work[16] * work[17]

        work[19] = Gfnr(2, 1, q, -3, l)
        work[20] = Gfnr(3, 1, q, -4, l)
        work[21] = Gfnr(4, 1, q, -4, l)
        work[22] = work[19] + work[20] + work[21]

        work[23] = work[4] + 2 * (work[8] - work[11] - 2 * work[15])
        work[24] = work[18] * work[22]

        return work[0] * (work[23] - work[24])

def Gmql(m, q, l):
    return Davis(m, q, l)

def LnGmql(m, q, l):
    tmp = Davis(m, q, l)
    if tmp <= 0.0:
        return math.log(1.0e-14)
    else:
        return math.log(tmp)

def Gmqlpct(l, arglist):
    m = round(arglist[0])
    q = round(arglist[1])
    p = arglist[2]
    return (1 - Davis(m, q, l)) - p

def NormalIntegral(x, upper):
    zero = 0.0
    one = 1.0
    half = 0.5
    con = 1.28
    ltone = 7.0
    utzero = 18.66
    p = 0.398942280444
    q = 0.39990348504
    r = 0.398942280385
    a1 = 5.75885480458
    a2 = 2.62433121679
    a3 = 5.92885724438
    b1 = -29.8213557807
    b2 = 48.6959930692
    c1 = -3.8052e-08
    c2 = 3.98064794e-04
    c3 = -0.151679116635
    c4 = 4.8385912808
    c5 = 0.742380924027
    c6 = 3.99019417011
    d1 = 1.00000615302
    d2 = 1.98615381364
    d3 = 5.29330324926
    d4 = -15.1508972451
    d5 = 30.789933034
    up = upper
    z = x

    if z < zero:
        up = not up
        z = -z

    if (z <= ltone) or ((z <= utzero) and up):
        y = half * z * z
        if z <= con:
            fn_val = half - z * (p - q * y / (y + a1 + b1 / (y + a2 + b2 / (y + a3))))
        else:
            fn_val = r * math.exp(-y) / (z + c1 + d1 / (z + c2 + d2 / (z + c3 + d3 / (z + c4 + d4 / (z + c5 + d5 / (z + c6))))))
    else:
        fn_val = zero

    if not up:
        return one - fn_val
    else:
        return fn_val

def IncompleteGamma(x, p):
    zero = 0.0
    one = 1.0
    two = 2.0
    three = 3.0
    nine = 9.0
    oflo = 1.0e+30
    tol = 1.0e-07
    plimit = 1000.0
    xbig = 1.0e+06
    elimit = -88.0e+00

    if x == zero:
        return zero
    else:
        if p > plimit:
            # normal approximation
            pn1 = three * math.sqrt(p) * (math.exp((one / three) * math.log(x / p)) + one / (nine * p) - one)
            return NormalIntegral(pn1, False)
        elif x > xbig:
            # X extremely large compared to P
            return one
        elif x <= 1 or x < p:
            # Pearson's expansion
            arg = p * math.log(x) - x - math.lgamma(p + one)
            c = one
            funval = one
            a = p
            while c > tol:
                a += one
                c *= x / a
                funval += c
            arg += math.log(funval)
            result = zero
            if arg > elimit:
                result = math.exp(arg)
            return result
        else:
            # Continued fraction
            arg = p * math.log(x) - x - math.lgamma(p)
            a = one - p
            b = a + x + one
            c = zero
            pn1 = one
            pn2 = x
            pn3 = x + one
            pn4 = x * b
            funval = pn3 / pn4
            loop = True
            while loop:
                a += one
                b += two
                c += one
                an = a * c
                pn5 = b * pn3 - an * pn1
                pn6 = b * pn4 - an * pn2
                if abs(pn6) > zero:
                    rn = pn5 / pn6
                    if abs(funval - rn) <= min(tol, tol * rn):
                        loop = False
                    else:
                        funval = rn
                if loop:
                    pn1, pn2, pn3, pn4 = pn3, pn4, pn5, pn6
                    if abs(pn5) >= oflo:
                        pn1 /= oflo
                        pn2 /= oflo
                        pn3 /= oflo
                        pn4 /= oflo
            arg += math.log(funval)
            result = one
            if arg >= elimit:
                result = one - math.exp(arg)
            return result

def Gamma(xx: float) -> float:
    return math.exp(LnGamma(xx))