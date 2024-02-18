import math
from PsyBaseStats import *
from SMR import *

minLower = 0.001
maxUpper = 0.999

def Ksmn(s, m, n):
    term = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    term[0] = (s / 2) * math.log(math.pi)

    si = round(s)

    term[1] = 0.0
    for i in range(1, si + 1):
        term[1] += math.lgamma((2 * m + 2 * n + s + i + 2) / 2)

    term[2] = 0.0
    for i in range(1, si + 1):
        term[2] += math.lgamma((2 * m + i + 1) / 2)

    term[3] = 0.0
    for i in range(1, si + 1):
        term[3] += math.lgamma((2 * n + i + 1) / 2)

    term[4] = 0.0
    for i in range(1, si + 1):
        term[4] += math.lgamma(i / 2)

    term[5] = term[0] + term[1] - (term[2] + term[3] + term[4])
    
    return math.exp(term[5])

def RoyExact(s, m, n, x):
    # Try x being alpha or CI
    B = [0.0] * 11
    B0 = [0.0] * 11
    work = [0.0] * 11
    K = [0.0] * 11
    Pr = [0.0] * 7

    for ns in range(2, math.trunc(s) + 1):
        if ns == 2:
            K[2] = Ksmn(2, m, n)
            B[1] = BetaRoy(x, 2 * m + 1, 2 * n + 1)
            B0[1] = BetaZero(x, m + 1, n + 1)
            B[2] = BetaRoy(x, m, n)
            Pr[2] = K[2] / (m + n + 2) * (2 * B[1] - B0[1] * B[2])
        elif ns == 3:
            K[3] = Ksmn(3, m, n)
            B0[2] = BetaZero(x, m + 2, n + 1)
            B[3] = BetaRoy(x, 2 * m + 3, 2 * n + 1)
            B[4] = BetaRoy(x, 2 * m + 2, 2 * n + 1)
            B[5] = BetaRoy(x, m + 1, n)
            work[1] = 2 * B[3] * B[2] - 2 * B[4] * B[5] - B0[2] * Pr[2] / K[2]
            Pr[3] = K[3] / (m + n + 3) * work[1]
        elif ns == 4:
            K[4] = Ksmn(4, m, n)
            B0[3] = BetaZero(x, m + 3, n + 1)
            B[6] = BetaRoy(x, 2 * m + 5, 2 * n + 1)
            B[7] = BetaRoy(x, 2 * m + 4, 2 * n + 1)
            work[1] = B0[3] * Pr[3] / K[3]
            work[2] = 2 * B[6] * Pr[2] / K[2]
            work[3] = 2 * B[3] / (m + n + 3)
            work[4] = 2 * B[3] - B0[2] * B[5]
            work[5] = 2 * B[7] / (m + n + 3)
            work[6] = -B0[2] * B[2] + (m + 2) * Pr[2] / K[2] + 2 * B[4]
            work[7] = -work[1] + work[2] + work[3] * work[4] - work[5] * work[6]
            Pr[4] = K[4] / (m + n + 4) * work[7]

    return Pr[math.trunc(s)]

    

def SortDown(x):
    nx = len(x)
    for i in range(nx, 1, -1):
        for j in range(1, i):
            if x[j - 1] < x[j]:
                hold = x[j]
                x[j] = x[j - 1]
                x[j - 1] = hold

smax = 20

def PillaiApproxOriginal(s, m, n, x):
    def SortDown(x):
        for i in range(smax, 1, -1):
            for j in range(2, i + 1):
                if x[j - 1] < x[j]:
                    x[j - 1], x[j] = x[j], x[j - 1]

    def LnCsmn(s, m, n):
        term1 = 0.5 * s * math.log(math.pi)
        term2 = 0.0
        for i in range(1, round(s) + 1):
            term1 += math.lgamma(0.5 * (2 * m + 2 * n + s + i + 2))
            term2 += math.lgamma(0.5 * (2 * m + i + 1)) + math.lgamma(0.5 * (2 * n + i + 1)) + math.lgamma(0.5 * i)

        return term1 - term2

    def LnCsmnRatio(s, m, n):
        term1 = 0.5 * math.log(math.pi)
        term2 = math.lgamma(0.5 * (2 * m + 2 * n + 2 * s + 2))
        term3 = math.lgamma(0.5 * (2 * m + s + 1))
        term4 = math.lgamma(0.5 * (2 * n + s + 1))
        term5 = math.lgamma(0.5 * s)

        return term1 + term2 - term3 - term4 - term5

    def CompSum(x):
        y = [0] * (smax + 1)
        u = [0] * (smax + 1)
        t = [0] * (smax + 1)
        v = [0] * (smax + 1)
        z = [0] * (smax + 1)
        s = [0] * (smax + 1)
        c = [0] * (smax + 1)

        y[1] = 0
        u[1] = 0
        t[1] = 0
        v[1] = 0
        z[1] = 0
        s[1] = x[1]
        c[1] = 0

        for k in range(2, smax + 1):
            y[k] = c[k - 1] + x[k]
            u[k] = x[k] - (y[k] - c[k - 1])
            t[k] = y[k] + s[k - 1]
            v[k] = y[k] - (t[k] - s[k - 1])
            z[k] = u[k] + v[k]
            s[k] = t[k] + z[k]
            c[k] = z[k] - (s[k] - t[k])

        return s[smax]

    def Binomial(n, k):
        return round(0.5 + math.exp(math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)))

    si = round(s)
    kms = [0.0] * 21
    term = [0.0] * 6
    hsx = 0.0

    if round(s) % 2 != 0:
        hsx = math.betainc(m + 1, n + 1, x)
    else:
        hsx = 1.0

    kms[0] = 0.0
    term[2] = math.exp(LnCsmn(s, m, n) - LnCsmn(s - 1, m, n))

    for i in range(1, si):
        term[1] = 1.0 / (m + n + s - i + 1)
        term[3] = Binomial(s - 1, i - 1)
        term[4] = 1
        for j in range(1, i):
            term[4] *= (2 * m + s - j + 1) / (2 * m + 2 * n + 2 * s - j + 1)
        term[5] = (m + s - i + 1) * kms[-i + 1]
        kms[-i] = term[1] * (term[2] * term[3] * term[4] - term[5])

    minus1 = -1

    for i in range(1, si):
        term[i] = math.exp((s - i) * math.log(x))
        term[i] = minus1 * kms[-i] * term[i]
        minus1 = -minus1

    SortDown(term)
    summation = CompSum(term)
    result = math.exp(m * math.log(x) + (n + 1) * math.log(1.0 - x)) * summation

    return hsx + result

""" def PillaiApproxOriginal(s, m, n, x):
    smax = 20
    sarray = [0.0] * (smax + 1)
    h = [0.0] * (smax + 1)
    f = [0.0] * (smax + 1)
    term = [0.0] * (smax + 1)
    kms = [0.0] * 21  # Array indices from -20 to 0
    hsx = 0.0
    sum_result = 0.0

    si = round(s)

    if si % 2 == 1:
        hsx = IncompleteBetaFunctionRatio(m+1, n+1, x)
    else:
        hsx = 1.0

    for i in range(1, si + 1):
        term[i] = Ksmn(i, m, n, x)

    for i in range(-20, 1):
        kms[i] = 0.0

    for i in range(1, si + 1):
        h[i] = 0.0
        for j in range(1, i + 1):
            h[i] += term[j]

    for i in range(1, si + 1):
        f[i] = 0.0
        for j in range(1, i + 1):
            f[i] += term[j] ** 2

    for i in range(1, si + 1):
        sarray[i] = f[i] - h[i] ** 2 / i

    SortDown(sarray)

    for i in range(1, si + 1):
        for j in range(1, i):
            if sarray[i] == f[j] - h[j] ** 2 / j:
                h[i] = h[j]
                f[i] = f[j]
                break

    for i in range(1, si + 1):
        hsx += h[i] / x

    for i in range(1, si + 1):
        sum_result += h[i] ** 2 / f[i]

    return 1 + hsx + sum_result """

def LnCsmn(s, m, n):
    
    term1 = 0.5 * s * math.log(math.pi)
    term2 = 0.0

    for i in range(1, round(s) + 1):
        term1 += math.lgamma(0.5 * (2 * m + 2 * n + s + i + 2))
        term2 += math.lgamma(0.5 * (2 * m + i + 1)) + math.lgamma(0.5 * (2 * n + i + 1)) + math.lgamma(0.5 * i)

    result = term1 - term2
    return result

def LnCsmnRatio(s, m, n):
    term = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]  # First index is not used

    term1 = 0.5 * math.log(math.pi)
    term2 = math.lgamma(0.5 * (2 * m + 2 * n + 2 * s + 2))
    term3 = math.lgamma(0.5 * (2 * m + s + 1))
    term4 = math.lgamma(0.5 * (2 * n + s + 1))
    term5 = math.lgamma(0.5 * s)

    result = term1 + term2 - term3 - term4 - term5
    return result

def CompSum(x, n):
    y = [0.0] * (n + 1)
    u = [0.0] * (n + 1)
    t = [0.0] * (n + 1)
    v = [0.0] * (n + 1)
    z = [0.0] * (n + 1)
    s = [0.0] * (n + 1)
    c = [0.0] * (n + 1)

    s[1] = x[1]
    c[1] = 0.0

    for k in range(2, n + 1):
        y[k] = c[k - 1] + x[k]
        u[k] = x[k] - (y[k] - c[k - 1])
        t[k] = y[k] + s[k - 1]
        v[k] = y[k] - (t[k] - s[k - 1])
        z[k] = u[k] + v[k]
        s[k] = t[k] + z[k]
        c[k] = z[k] - (s[k] - t[k])

    return s[n]

def gcr_Prob_Exact(s, m, n, x):
    if s <= 0 or s == 1:
        raise NotImplementedError("This did nothing in original Psy")
    elif s >= 2.0 and s <= 4.0 and n <= 600:
        return 1 - RoyExact(s,m,n,x)
    else:
        raise RuntimeError("Out of range error")

def gcr_Prob(s, m, n, x) -> float:
    result = 0.0
    if s >= 2.0 and s <= 4.0 and n <= 600:
        return gcr_Prob_Exact(s, m, n, x)
    else:
        raise NotImplementedError("This hasn't been converted from pascal yet")

def gcr_CritProb_Exact(x, arglist: OffsetList):
    s = arglist.get(2)
    m = arglist.get(3)
    n = arglist.get(4)
    return arglist.get(1) - gcr_Prob_Exact(s, m, n, x)
    

def gcr_CritProb_Approx(x, arglist: OffsetList):
    s = arglist.get(2)
    m = arglist.get(3)
    n = arglist.get(4)
    return arglist.get(1) - gcr_Prob_Approx(s, m, n, x)

def gcr_Prob_Approx(s, m, n, x):
    if s <= 0:
        raise NotImplementedError("This hasn't been converted from pascal yet")
    elif s == 1:
        raise NotImplementedError("This hasn't been converted from pascal yet")
    elif s <= 20:
        return 1 - PillaiApproxOriginal(s, m, n, x)
    else:
        raise ValueError("Out of Range")
        return 0.0
        
def NewUpper(upper):
    if 1.05*upper < maxUpper:
        return 1.05*upper
    else:
        return maxUpper

def NewLower(lower):
    if 0.95*lower > minLower:
        return 0.95*lower
    else:
        return minLower    


def gcr_Crit(p, s, m, n, lower, upper):
    arglist = OffsetList(1,5)
    macheps = 2.0e-14
    tol = 1.0e-10

    if 2 <= s and s <= 4:
        if n <= 600:
            lower = minLower
            upper = maxUpper
            if m < 0:
                upper = gcr_Crit(p, s, 0, n, lower, upper)
                lower = 0.50 * upper
                zerofun = gcr_CritProb_Approx
            else:
                zerofun = gcr_CritProb_Exact

            arglist.set(1, p)
            arglist.set(2, s)
            arglist.set(3, m)
            arglist.set(4, n)
            return BrentZero(zerofun, lower, upper, arglist, macheps, tol)
        else:
            lower = minLower
            upper = maxUpper

            if m < 0:
                upper = gcr_Crit(p, s, 0, n, lower, upper)
                lower = 0.75 * upper
                zerofun = gcr_CritProb_Approx
            else:
                zerofun = gcr_CritProb_Exact

            arglist.set(1, p)
            arglist.set(2, s)
            arglist.set(3, m)
            arglist.set(4, 600)

            upper = BrentZero(zerofun, lower, upper, arglist, macheps, tol)
            lower = 0.50 * upper
            arglist.set(4, n)
            zerofun = gcr_CritProb_Approx
            return BrentZero(zerofun, lower, upper, arglist, macheps, tol)
    else:
        if s <= 8:
            lower = minLower
            upper = maxUpper
            lower = gcr_Crit(p, 4.0, m, n, lower, upper)
            upper = lower + 0.75 * lower
            
            arglist.set(1, p)
            arglist.set(2, s)
            arglist.set(3, m)
            arglist.set(4, n)

            zerofun = gcr_CritProb_Approx

            while True:
                funval = BrentZero(zerofun, lower, upper, arglist, macheps, tol)
                if funval == upper:
                    upper = NewUpper(upper)
                elif funval == lower:
                    lower = NewLower(lower)
                else:
                    return funval
                    break

        elif s <= 12:
            lower = minLower
            upper = maxUpper
            lower = gcr_Crit(p, 8.0, m, n, lower, upper)
            upper = lower + 0.5 * lower
            if upper > maxUpper:
                upper = maxUpper
            arglist.set(1, p)
            arglist.set(2, s)
            arglist.set(3, m)
            arglist.set(4, n)
            zerofun = gcr_CritProb_Approx

            while True:
                funval = BrentZero(zerofun, lower, upper, arglist, macheps, tol)
                if funval == upper:
                    upper = NewUpper(upper)
                elif funval == lower:
                    lower = NewLower(lower)
                else:
                    return funval
                    break
        elif s <= 16:
            lower = minLower
            upper = maxUpper
            lower = gcr_Crit(p, 12.0, m, n, lower, upper)
            upper = lower + 0.5 * lower
            if upper > maxUpper:
                upper = maxUpper
            arglist.set(1, p)
            arglist.set(2, s)
            arglist.set(3, m)
            arglist.set(4, n)
            zerofun = gcr_CritProb_Approx

            while True:
                funval = BrentZero(zerofun, lower, upper, arglist, macheps, tol)
                if funval == upper:
                    upper = NewUpper(upper)
                elif funval == lower:
                    lower = NewLower(lower)
                else:
                    return funval
                    break
        elif s <= 20:
            lower = minLower
            upper = maxUpper
            lower = gcr_Crit(p, 16.0, m, n, lower, upper)
            upper = lower + 0.5 * lower
            if upper > maxUpper:
                upper = maxUpper
            arglist.set(1, p)
            arglist.set(2, s)
            arglist.set(3, m)
            arglist.set(4, n)
            zerofun = gcr_CritProb_Approx

            while True:
                funval = BrentZero(zerofun, lower, upper, arglist, macheps, tol)
                if funval == upper:
                    upper = NewUpper(upper)
                elif funval == lower:
                    lower = NewLower(lower)
                else:
                    return funval
                    break
        


# PSY2R: In PSY this calculates:
# Select Probability calculator
# Select p-value
# This calculates these values
print("GCR results")
s_val = 2
m_val = 3
n_val = 3
a_val = 0.05  # alpha
k_val = 3
x_val = a_val #/k_val
a_k_val = a_val/k_val
# This is correct
quick_test = gcr_Prob_Exact(s_val, m_val, n_val, x_val)
print("p value", quick_test)

# These are constants
min_val = minLower
max_val = maxUpper
# Note: PillaiApproxOriginal does not work correctly at the moment.
quick_test_2 = gcr_Crit(a_k_val, s_val, m_val, n_val, min_val, max_val)

print("Crit Val:", quick_test_2)