import math

def LnGamma(value):
    return math.lgamma(value)

def LnBeta(a, b) -> float:
    return LnGamma(a) + LnGamma(b) - LnGamma(a+b)

def BetaZero(x, m, n) -> float:
    return math.exp(m*math.log(x)+n*math.log(1.0-x))

class Option:
    Interpolate, Extrapolate = range(2)


def sign(x):
    return (x > 0) - (x < 0)



def error_trap(msg):
    raise ValueError(msg)

def set_error_trap(msg):
    # Do nothing
    pass

def BrentZero(Fz, a, b, arglist, macheps, tolerance):

    set_error_trap('BrentZero')

    fa = Fz(a, arglist)
    fb = Fz(b, arglist)

    if sign(fa) == sign(fb):
        error_trap('No zero between bounds')
    else:
        done = False
        flag = Option.Interpolate

        while not done:
            if flag == Option.Interpolate:
                c, fc, e, d = a, fa, b - a, b - a
                flag = Option.Extrapolate
            elif flag == Option.Extrapolate:
                if abs(fc) < abs(fb):
                    a, b, c = b, c, a
                    fa, fb, fc = fb, fc, fa

                tol = 2 * macheps * abs(b) + tolerance
                m = 0.5 * (c - b)

                if (abs(m) > tol) and (fb != 0):
                    if (abs(e) < tol) or (abs(fa) <= abs(fb)):
                        e, d = m, m
                    else:
                        s = fb / fa
                        if a == c:
                            p, q = 2 * m * s, 1 - s
                        else:
                            q, r = fa / fc, fb / fc
                            p = s * (2 * m * q * (q - r) - (b - a) * (r - 1))
                            q = (q - 1) * (r - 1) * (s - 1)

                        if p > 0:
                            q = -q
                        else:
                            p = -p

                        e, s = d, e
                        exp1 = (2 * p) < (3 * m * q - abs(tol * q))
                        exp2 = (p < abs(0.5 * s * q))

                        if exp1 and exp2:
                            d = p / q
                        else:
                            e, d = m, m

                    a, fa = b, fb

                    if abs(d) > tol:
                        b += d
                    else:
                        if m > 0:
                            b += tol
                        else:
                            b -= tol

                    fb = Fz(b, arglist)

                    if (fb > 0) == (fc > 0):
                        flag = Option.Interpolate
                    else:
                        flag = Option.Extrapolate
                else:
                    done = True

    return b

def IncompleteBetaFunctionRatio(p, q, x):
    return IncBetaContFrac(x, p, q, 1)

def BetaRoy(x, m, n):

    m = m + 1
    n = n + 1
    if n <= 600:
        bRoy = IncBetaContFrac(x, m, n, 2)
    else:
        bRoy = IncompleteBetaByPartsNLarge(x, m - 1, n - 1)
    return bRoy

def IncompleteBetaByPartsNLarge(r, m, n) -> float:
    lhs = -math.exp(m*math.log(r) + (n+1)*math.log(1-r) - math.log(n+1))
    if m == 0:
        result = lhs
    elif m == 1:
        mult = math.log(m/(n+1))
        upperlimit = (n+2)*math.log(1-r)-math.log(n+2)
        lowerlimit = (n+2)*math.log(1-0)-math.log(n+2)
        rhs = (-math.exp(mult+upperlimit)) - (-math.exp(mult + lowerlimit))
        result = lhs + rhs
    else:
        mult = m/(n+1)
        result = lhs + mult*IncompleteBetaByPartsNLarge(r, m-1, n+1) 
    return result

def IncBetaContFrac(x, p, q, fn) -> float:
    if x > p/(p + q):
        switch = True
        x = 1 - x
        tmp = p
        p = q
        q = tmp
    else:
        switch = False
    f = (q*x)/(p*(1-x))
    # dict is an odd way to do it but keeps it consistent with the pascal code
    value = dict()
    minimum = "minimum"
    previous = "previous"
    current = "current"
    value[minimum] = float("1e-12")
    value[previous] = 1
    value[current] = 0
    A = OffsetList(-1, 1)
    B = OffsetList(-1, 1)
    convergence = OffsetList(0,2)
    A.set(-1, 1)
    A.set(0, 1)
    B.set(-1, 0)
    B.set(0, 1)
    converged = False
    n = 0
    while not converged:
        n += 1
        an = anfn(n, p, q, f)
        bn = bnfn(n, p, q, f)
        A.set(1, an*A.get(-1)+ bn * A.get(0))
        B.set(1, an*B.get(-1)+ bn * B.get(0))
        if B.get(1) > B.get(1):
            A.set(0, A.get(0)/B.get(1))
            A.set(1, A.get(1)/B.get(1))
            B.set(0, B.get(0)/B.get(1))
            B.set(1, 1)
        else:
            B.set(0, B.get(0)/A.get(1))
            B.set(1, B.get(1)/A.get(1))
            A.set(0, A.get(0)/A.get(1))
            A.set(1, 1)
        A.set(-1, A.get(0))
        A.set(0, A.get(1))
        B.set(-1, B.get(0))
        B.set(0, B.get(1))

        value[current] = A.get(1)/B.get(1)
        converged = abs(value[previous] - value[current])
        value[previous] = value[current]
    
    cf = math.log(A.get(1)/B.get(1))

    if fn == 1:
        Kxpq = p*math.log(x) + (q-1)*math.log(1.0-x)-math.log(p)-LnBeta(p, q)
        if switch is True:
            return 1.0 - math.exp(Kxpq + cf)
        else:
            return math.exp(Kxpq+cf)
    else:
        Kxpq = p*math.log(x)+(q-1)*math.log(1.0-x)-math.log(p)
        if switch is True:
            return math.exp(LnBeta(p,q))-math.exp(Kxpq+cf)
        else:
            return math.exp(Kxpq+cf)

        

        

class OffsetList:
    # Used for pascal lists that don't start at 0
    def __init__(self, start_ind, stop_ind):
        self.list = [None] * (stop_ind + 1 - start_ind)
        self.start_ind = start_ind
    def get(self, ind):
        adjusted_ind = ind - self.start_ind
        return self.list[adjusted_ind]
    def set(self, ind, val):
        adjusted_ind = ind - self.start_ind
        self.list[adjusted_ind] = val

    
        


def anfn(n, p, q, f) -> float:
    if n == 1:
        term1 = p * f * (q - 1)
        term2 = q * (p + 1)
    else:
        term1 = (p*p) * (f*f) * (n-1) * (p+q+n-2) * (p+n-1) * (q-n)
        term2 = (q*q) * (p+2*n-3) * (p+2*n-2) * (p+2*n-2) * (p+2*n-1)
    return term1/term2

def bnfn(n, p, q, f) -> float:
    term1 = 2*(p*f + 2*q)*(n*n) + 2*(p*f + 2*q)*(p - 1)*n + (p*q)*(p - 2 - p*f)
    term2 = q*(p + 2*n - 2)*(p + 2*n)
    return term1/term2

