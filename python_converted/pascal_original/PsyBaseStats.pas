unit PsyBaseStats;

{$F+}

interface

type string128 = string[128];

type float = extended;

type BrentVec = array [1..5] of float; {[1, 2, 3, 4, 5]}

type BrentFn = function(x: float; arglist: BrentVec): float;

type errorstr = string[128];
type errorrecord = record
     calledfrom: errorstr;
     errornum: integer;
     errormsg: errorstr;
     end;

type ib = array[0..100] of float;


const      PI: float =               3.141592653589793e+00;
           ONE_ON_PI: float =        3.183098861837907e-01;
           ONE_ON_SQRT_PI: float =   5.641895835477563e-01;
           TWO_ON_PI: float =        6.366197723675814e-01;
           TWO_ON_SQRT_PI: float =   1.128379167095513e+00;
           LNSQR2PI: float =         9.189385332046727e-01;

procedure SetErrorTrap(called: errorstr);
procedure SpringErrorTrap(errnum: integer; errmsg: errorstr);

function Min(x, y: float): float;
function Max(x, y: float): float;
function Min_Int(x, y: integer): integer;
function Max_Int(x, y: integer): integer;
function Sign(x: float): integer;
function even(i: integer): boolean;
function LnGamma(xx: float): float;
         { returns the natural log of the gamma function }
function LnFactorial(x: float): float;
         { returns the natural log of x! }
function IsInteger(x: float): boolean;
function BrentZero(Fz: BrentFn; a, b: float;
                   arglist: BrentVec; macheps, tolerance: float): float;


{ Following all related to Beta function and variants }
function LnBeta(a, b: float): float;
function BetaZero(x, m, n: float): float;
function IncBetaContFrac(x, p, q: float; fn: integer): float;
function BetaRoy(x, m, n: float): float;
function IncompleteBetaByPartsNLarge(r, m, n: float): float;
function IncompleteBetaByPartsMLarge(r, m, n: float): float;
function IncompleteBetaFunctionRatio(p, q, x: float): float;

var PDFError: errorrecord;





implementation

procedure SetErrorTrap(called: errorstr); {
---------------------- This procedure is called at the start of any
function/procedure which might encounter an error due either to
illegal parameters or a numerical error.
If the error is encountered then the error trap is sprung.
It is up to the calling block to check.
-------------------------------------------}

begin
   with PDFError do
      begin
      calledfrom := called;
      errornum := 0;
      errormsg := 'Successful';
      end;
end;

procedure SpringErrorTrap(errnum: integer; errmsg: errorstr);
begin
   with PDFError do
      begin
      errornum := errnum;
      errormsg := errmsg;
      end;
end;

function Min(x, y: float): float;
begin
if x < y then
    Min := x
else
    Min := y
end;

function Min_Int(x, y: integer): integer;
begin
if x < y then
    Min_Int := x
else
    Min_Int := y
end;


function Max(x, y: float): float;
begin
if x > y then
    Max := x
else
    Max := y
end;

function Max_Int(x, y: integer): integer;
begin
if x > y then
    Max_Int := x
else
    Max_Int := y
end;

function Sign(x: float): integer;
begin
if x < 0 then
    Sign := 0
else
    Sign := 1
end; { Sign }

function LnGamma(xx: float): float; {
---------------- Alan Miller's version on Netlib }
var
   j, m, n: integer;
   lg, tmp: float;

const
     a: array[1..9] of float =
     (  0.9999999999995183,
        676.5203681218835,
        -1259.139216722289,
        771.3234287757674,
        -176.6150291498386,
        12.50734324009056,
        -0.1385710331296526,
        0.9934937113930748e-05,
        0.1659470187408462e-06
     );

{ The following table contains Ln[Gamma(x)] for x = 0.5 by 0.5 to 100.0
  Values calculated in Maple V }

     tablemin = 0.5;  tablemax = 100.0;
     table: array[0..100,0..1] of float =
     (( 0.0000000000000000e+00 ,  5.7236494292470008e-01 ),
      ( 0.0000000000000000e-01 , -1.2078223763524522e-01 ),
      ( 0.0000000000000000e-01 ,  2.8468287047291915e-01 ),
      ( 6.9314718055994530e-01 ,  1.2009736023470742e+00 ),
      ( 1.7917594692280550e+00 ,  2.4537365708424422e+00 ),
      ( 3.1780538303479456e+00 ,  3.9578139676187162e+00 ),
      ( 4.7874917427820459e+00 ,  5.6625620598571415e+00 ),
      ( 6.5792512120101009e+00 ,  7.5343642367587329e+00 ),
      ( 8.5251613610654143e+00 ,  9.5492672573009977e+00 ),
      ( 1.0604602902745250e+01 ,  1.1689333420797268e+01 ),
      ( 1.2801827480081469e+01 ,  1.3940625219403763e+01 ),
      ( 1.5104412573075515e+01 ,  1.6292000476567241e+01 ),
      ( 1.7502307845873885e+01 ,  1.8734347511936445e+01 ),
      ( 1.9987214495661886e+01 ,  2.1260076156244701e+01 ),
      ( 2.2552163853123422e+01 ,  2.3862765841689084e+01 ),
      ( 2.5191221182738681e+01 ,  2.6536914491115613e+01 ),
      ( 2.7899271383840891e+01 ,  2.9277754515040814e+01 ),
      ( 3.0671860106080672e+01 ,  3.2081114895947349e+01 ),
      ( 3.3505073450136888e+01 ,  3.4943315776876817e+01 ),
      ( 3.6395445208033053e+01 ,  3.7861086508961096e+01 ),
      ( 3.9339884187199494e+01 ,  4.0831500974530798e+01 ),
      ( 4.2335616460753485e+01 ,  4.3851925860675160e+01 ),
      ( 4.5380138898476908e+01 ,  4.6919978795808777e+01 ),
      ( 4.8471181351835223e+01 ,  5.0033494105019152e+01 ),
      ( 5.1606675567764373e+01 ,  5.3190494526169265e+01 ),
      ( 5.4784729398112319e+01 ,  5.6389167643719946e+01 ),
      ( 5.8003605222980519e+01 ,  5.9627846095884327e+01 ),
      ( 6.1261701761002001e+01 ,  6.2904990828876503e+01 ),
      ( 6.4557538627006331e+01 ,  6.6219176833549029e+01 ),
      ( 6.7889743137181534e+01 ,  6.9569080920823634e+01 ),
      ( 7.1257038967168009e+01 ,  7.2953471184169408e+01 ),
      ( 7.4658236348830164e+01 ,  7.6371197867782774e+01 ),
      ( 7.8092223553315310e+01 ,  7.9821185413614361e+01 ),
      ( 8.1557959456115037e+01 ,  8.3302425502950053e+01 ),
      ( 8.5054467017581517e+01 ,  8.6813970941781074e+01 ),
      ( 8.8580827542197678e+01 ,  9.0354930265818388e+01 ),
      ( 9.2136175603687092e+01 ,  9.3924462962299758e+01 ),
      ( 9.5719694542143202e+01 ,  9.7521775222888204e+01 ),
      ( 9.9330612454787426e+01 ,  1.0114611615586456e+02 ),
      ( 1.0296819861451381e+02 ,  1.0479677439715830e+02 ),
      ( 1.0663176026064345e+02 ,  1.0847307506906538e+02 ),
      ( 1.1032063971475739e+02 ,  1.1217437704317787e+02 ),
      ( 1.1403421178146170e+02 ,  1.1590007047041453e+02 ),
      ( 1.1777188139974507e+02 ,  1.1964957454634490e+02 ),
      ( 1.2153308151543863e+02 ,  1.2342233548443953e+02 ),
      ( 1.2531727114935689e+02 ,  1.2721782467361173e+02 ),
      ( 1.2912393363912721e+02 ,  1.3103553699956863e+02 ),
      ( 1.3295257503561630e+02 ,  1.3487498931216194e+02 ),
      ( 1.3680272263732636e+02 ,  1.3873571902320254e+02 ),
      ( 1.4067392364823425e+02 ,  1.4261728282114598e+02 ),
      ( 1.4456574394634488e+02 ,  1.4651925549072062e+02 ),
      ( 1.4847776695177303e+02 ,  1.5044122882700194e+02 ),
      ( 1.5240959258449735e+02 ,  1.5438281063467163e+02 ),
      ( 1.5636083630307878e+02 ,  1.5834362380426920e+02 ),
      ( 1.6033112821663090e+02 ,  1.6232330545817117e+02 ),
      ( 1.6432011226319518e+02 ,  1.6632150615984036e+02 ),
      ( 1.6832744544842765e+02 ,  1.7033788918059275e+02 ),
      ( 1.7235279713916280e+02 ,  1.7437212981874515e+02 ),
      ( 1.7639584840699735e+02 ,  1.7842391476654845e+02 ),
      ( 1.8045629141754377e+02 ,  1.8249294152078626e+02 ),
      ( 1.8453382886144949e+02 ,  1.8657891783333785e+02 ),
      ( 1.8862817342367159e+02 ,  1.9068156119837464e+02 ),
      ( 1.9273904728784490e+02 ,  1.9480059837318712e+02 ),
      ( 1.9686618167288999e+02 ,  1.9893576492992947e+02 ),
      ( 2.0100931639928152e+02 ,  2.0308680483582812e+02 ),
      ( 2.0516819948264119e+02 ,  2.0725347005962984e+02 ),
      ( 2.0934258675253683e+02 ,  2.1143552020227105e+02 ),
      ( 2.1353224149456326e+02 ,  2.1563272214993286e+02 ),
      ( 2.1773693411395422e+02 ,  2.1984484974781134e+02 ),
      ( 2.2195644181913033e+02 ,  2.2407168349307952e+02 ),
      ( 2.2619054832372759e+02 ,  2.2831301024565027e+02 ),
      ( 2.3043904356577695e+02 ,  2.3256862295546849e+02 ),
      ( 2.3470172344281826e+02 ,  2.3683832040516845e+02 ),
      ( 2.3897838956183432e+02 ,  2.4112190696702908e+02 ),
      ( 2.4326884900298271e+02 ,  2.4541919237324787e+02 ),
      ( 2.4757291409618688e+02 ,  2.4972999149863339e+02 ),
      ( 2.5189040220972319e+02 ,  2.5405412415488837e+02 ),
      ( 2.5622113555000952e+02 ,  2.5839141489572086e+02 ),
      ( 2.6056494097186320e+02 ,  2.6274169283208016e+02 ),
      ( 2.6492164979855280e+02 ,  2.6710479145686852e+02 ),
      ( 2.6929109765101982e+02 ,  2.7148054847852881e+02 ),
      ( 2.7367312428569370e+02 ,  2.7586880566295333e+02 ),
      ( 2.7806757344036614e+02 ,  2.8026940868320014e+02 ),
      ( 2.8247429268763039e+02 ,  2.8468220697654078e+02 ),
      ( 2.8689313329542699e+02 ,  2.8910705360839759e+02 ),
      ( 2.9132395009427030e+02 ,  2.9354380514276072e+02 ),
      ( 2.9576660135076062e+02 ,  2.9799232151870343e+02 ),
      ( 3.0022094864701413e+02 ,  3.0245246593264126e+02 ),
      ( 3.0468685676566871e+02 ,  3.0692410472600483e+02 ),
      ( 3.0916419358014692e+02 ,  3.1140710727801872e+02 ),
      ( 3.1365282994987906e+02 ,  3.1590134590329953e+02 ),
      ( 3.1815263962020932e+02 ,  3.2040669575400541e+02 ),
      ( 3.2266349912672617e+02 ,  3.2492303472628688e+02 ),
      ( 3.2718528770377521e+02 ,  3.2945024337080526e+02 ),
      ( 3.3171788719692847e+02 ,  3.3398820480709990e+02 ),
      ( 3.3626118197919847e+02 ,  3.3853680464159960e+02 ),
      ( 3.4081505887079901e+02 ,  3.4309593088908628e+02 ),
      ( 3.4537940706226685e+02 ,  3.4766547389743122e+02 ),
      ( 3.4995411804077023e+02 ,  3.5224532627543503e+02 ),
      ( 3.5453908551944080e+02 ,  3.5683538282361307e+02 ),
      ( 3.5913420536957539e+02 ,  0.0000000000000000e+00 ));



begin

{ use table if possible }
if (xx >= tablemin) and (xx <= tablemax) then
   if isinteger(xx) or (frac(xx) = 0.5) then
      begin
      m := trunc(xx);
      if frac(xx) = 0.5 then n := 1 else n := 0;
      LnGamma := table[m,n];
      exit
      end;


lg  := 0.0;
tmp := xx + 7.0;

for j := 9 downto 2 do
begin
    lg  := lg + a[j]/tmp;
    tmp := tmp - 1;
end;


lg := lg + a[1];
LnGamma := Ln(lg) + LNSQR2PI - (xx + 6.5) + (xx - 0.5) * Ln(xx + 6.5);

end; { LnGamma }


function IsInteger(x: float): boolean;
begin
if frac(x) = 0.0 then
   IsInteger := true
else
   IsInteger := false
end; { IsInteger }

function even(i: integer): boolean;
begin
   even := not odd(i)
end; { even }

function LnFactorial(x: float): float;

const
     TableSize = 12;
     Table: array[1..TableSize] of float =
     (      1.00000000e+00,
            2.00000000e+00,
            6.00000000e+00,
            2.40000000e+01,
            1.20000000e+02,
            7.20000000e+02,
            5.04000000e+03,
            4.03200000e+03,
            3.62880000e+05,
            3.62880000e+06,
            3.99168000e+07,
            4.79001600e+08
      );

begin
if x = 0.0 then
   LnFactorial := 0.0
else
   if (IsInteger(x) and (trunc(x) <= TableSize)) then
      LnFactorial := Ln(Table[trunc(x)])
   else
       LnFactorial := LnGamma(x + 1.0)
end; { LnFactorial }

{
Brent's algorithm for the zero of a function
Tolerance etc is global
We check that there is a change of sign between Fz(a) and Fz(b)
The function to be minimized (Fz) has two arguments:
x:    which is manipulated by Brent
args: which might or might not be needed by fx and is untouched
}

function BrentZero(Fz: BrentFn; a, b: float;
                   arglist: BrentVec; macheps, tolerance: float): float;
type
   option = (Interpolate, Extrapolate);
var
   c, d, e, fa, fb, fc, tol, m, p, q, r, s: float;
   done, exp1, exp2: boolean;
   flag: option;

begin
   SetErrorTrap('BrentZero');
   fa := Fz(a,arglist);  fb := Fz(b,arglist);
   if Sign(fa) = Sign(fb) then
      SpringErrorTrap(100,'No zero between bounds')
   else begin
      done := false;  flag := Interpolate;
      while not done do
      case flag of
         Interpolate: 
         begin
            c := a;  fc := fa;  e := b - a;  d := e;
            flag := Extrapolate;
         end;
         
         Extrapolate:
         begin
            if abs(fc) < abs(fb) then
               begin
                  a  := b;   b  := c;    c := a;
                  fa := fb;  fb := fc;  fc := fa;
               end;

            tol := 2 * macheps * abs(b) + tolerance;
            m   := 0.5 * (c - b);

            if (abs(m) > tol) and (fb <> 0) then
               begin
                  if (abs(e) < tol) or (abs(fa) <= abs(fb)) then
                     begin
                        e := m;  
                        d := e;
                     end            
                  else
                     begin
                        s := fb/fa;
                        if a = c then
                           begin
                              p := 2 * m * s;  
                              q := 1 - s;
                           end
                        else 
                           begin
                              q := fa/fc;  
                              r := fb/fc;
                              p := s * (2 * m * q * (q - r) - (b - a) * (r - 1));
                              q := (q - 1) * (r - 1) * (s - 1);
                           end;

                        if p > 0 then
                           q := -q 
                        else 
                           p := -p;

                        e := d;  
                        s := e;
                        exp1 := (2*p) < (3*m*q - abs(tol*q));
                        exp2 := (p < abs(0.5*s*q));
                        if (exp1 and exp2) then
                           d := p/q
                        else
                           begin
                              e := m;
                              d := e;
                           end
                     end;
                  a  := b;  
                  fa := fb;
                  if abs(d) > tol then
                     b := b + d
                  else
                     begin
                        if m > 0 then
                           b := b + tol
                        else
                           b := b - tol
                     end;

                  fb := Fz(b,arglist);
                  if (fb > 0) = (fc > 0) then
                     flag := Interpolate
                  else
                     flag := Extrapolate;
               end
            else
                  done := true;
         end { extrapolate }
      end { case }
   end; { main if }
   BrentZero := b;
end; { BrentZero }






function LnBeta(a, b: float): float; {
--------------- log of the complete Beta function }
begin
   LnBeta := LnGamma(a) + LnGamma(b) - LnGamma(a + b)
end; { LnBeta }


function BetaZero(x, m, n: float): float; {
-------------------- B0 as per Roy p.202 }
begin
   BetaZero := exp(m*ln(x) + n*ln(1.0 - x));
end; { BetaZero }

function IncBetaContFrac(x, p, q: float; fn: integer): float;
{PSY2R: Function is embedded, converted to python for easier reading} {
------------------------ Tretter & Walster cf as per Boik & Robinson-Cox
                         fn = 1 return Ix(a,b): incomplete beta function ratio
                         fn = 2 return incomplete beta(a,b) }
const napproxmax = 128;
type  valuelist = (minimum, previous, current);
var   n: integer;
      A, B: array[-1..1] of float;
      an, bn, f, cf, Kxpq, tmp: float;
      convergence: array[0..2] of float;
      converged, switch: boolean;
      value: array[minimum..current] of float;

function anfn(n: integer; p, q, f: float): float; {
------------- }
var   term: array[1..2] of float;
begin
   if n == 1 then
      begin
      term1 := p*f * (q - 1);
      term2 := q * (p + 1);
      end
   else
      begin
      term1 := (p*p) * (f*f) * (n-1) * (p+q+n-2) * (p+n-1) * (q-n);
      term2 := (q*q) * (p+2*n-3) * (p+2*n-2) * (p+2*n-2) * (p+2*n-1);
      end;
   anfn := term[1]/term[2];
end; { anfn }

function bnfn(n: integer; p, q, f: float): float; {
------------- }
var   term: array[1..2] of float;
begin
   term[1] := 2*(p*f + 2*q)*(n*n) + 2*(p*f + 2*q)*(p - 1)*n + (p*q)*(p - 2 - p*f);
   term[2] := q*(p + 2*n - 2)*(p + 2*n);
   bnfn := term[1]/term[2];
end; { bnfn }


begin
   if (x > p/(p + q)) then
      begin switch := true;
      x := 1.0 - x;  tmp := p;  p := q;  q := tmp;
      end
   else switch := false;

   f := (q * x)/(p * (1 - x));
   value[minimum] := 1.0e-12;  value[previous] := 1.0;
   A[-1] := 1;  A[0] := 1;
   B[-1] := 0;  B[0] := 1;
   converged := false;  n := 0;
   while not converged do
      begin n := n + 1;
      an := anfn(n,p,q,f);
      bn := bnfn(n,p,q,f);
      A[1] := an * A[-1] + bn * A[0];
      B[1] := an * B[-1] + bn * B[0];
      if B[1] > A[1] then
         begin
         A[0] := A[0]/B[1];  A[1] := A[1]/B[1];
         B[0] := B[0]/B[1];  B[1] := 1.0
         end
      else
         begin
         B[0] := B[0]/A[1];  B[1] := B[1]/A[1];
         A[0] := A[0]/A[1];  A[1] := 1.0
         end;

      A[-1] := A[0];  A[0] := A[1];
      B[-1] := B[0];  B[0] := B[1];

      value[current] := A[1]/B[1];
      converged := abs(value[previous] - value[current]) < value[minimum];
      value[previous] := value[current]

      end;

   cf := Ln(A[1]) - Ln(B[1]);

   if fn = 1 then { incomplete beta function ratio }
      begin
      Kxpq := p*Ln(x) + (q-1)*Ln(1.0-x) - Ln(p) - LnBeta(p,q);
      if switch then
         IncBetaContFrac := 1.0 - exp(Kxpq + cf)
      else
         IncBetaContFrac := exp(Kxpq + cf)
      end
   else { incomplete beta function }
      if switch then
         begin
         Kxpq := p*Ln(x) + (q-1)*Ln(1.0-x) - Ln(p);
         IncBetaContFrac := exp(LnBeta(p,q)) - exp(Kxpq + cf)
         end
      else
         begin
         Kxpq := p*Ln(x) + (q-1)*Ln(1.0-x) - Ln(p);
         IncBetaContFrac := exp(Kxpq + cf)
         end
end;

function IncompleteBetaByPartsNLarge(r, m, n: float): float; {
------------------------------ In some regions do parts }

var   I, lhs, rhs, mult, upperlimit, lowerlimit: float;

begin
   lhs := -exp(m*Ln(r) + (n + 1)*Ln(1 - r) - Ln(n + 1));
   if m = 0 then
      I := lhs
   else
      if m = 1 then
         begin
         mult := Ln(m/(n + 1));
         upperlimit := (n + 2)*Ln(1 - r) -  Ln(n + 2);
         lowerlimit := (n + 2)*Ln(1 - 0) -  Ln(n + 2);
         rhs := (-exp(mult + upperlimit)) - (-exp(mult + lowerlimit));
         I := lhs + rhs
         end
      else
         begin
         mult := m/(n + 1);
         I := lhs + mult*IncompleteBetaByPartsNLarge(r,m-1,n+1)
         end;
   IncompleteBetaByPartsNLarge := I
end;

function IncompleteBetaByPartsMLarge(r, m, n: float): float; {
------------------------------ In some regions do parts }

var   I, lhs, rhs, mult, upperlimit, lowerlimit: float;

begin
   lhs := -exp(m*Ln(r) + (n + 1)*Ln(1 - r) - Ln(n + 1));
   if m = 1 then
      begin
      mult := Ln(m/(n + 1));
      upperlimit := (n + 2)*Ln(1 - r) -  Ln(n + 2);
      lowerlimit := (n + 2)*Ln(1 - 0) -  Ln(n + 2);
      rhs := (-exp(mult + upperlimit)) - (-exp(mult + lowerlimit));
      I := lhs + rhs
      end
   else
      begin
      mult := m/(n + 1);
      I := lhs + mult*IncompleteBetaByPartsMLarge(r,m-1,n+1)
      end;
   IncompleteBetaByPartsMLarge := I
end;


function BetaRoy(x, m, n: float): float; {
---------------- B as per Roy p.202 (just to get around slightly
                 different version of incomplete beta }
begin
   m := m + 1;  n := n + 1;
   if n <= 600 then
      begin
      BetaRoy := IncBetaContFrac(x,m,n,2)
      end
   else
      begin
      BetaRoy := IncompleteBetaByPartsNLarge(x,m-1,n-1)
      end
end; { Beta }

function IncompleteBetaFunctionRatio(p, q, x: float): float; {
------------------------------------ This just calls other routines to do the
         required calculations so that how it is done is transparent }

begin
   IncompleteBetaFunctionRatio := IncBetaContFrac(x, p, q, 1);
end; { IncompleteBetaFunctionRatio }



end.

