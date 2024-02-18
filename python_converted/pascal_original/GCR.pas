unit GCR;
{$F+}
//{$M 32000, 0, 655360}
// program GCR;

interface
{PSY2R... stuff learnt so far:

Ksmn - eq 7.8.1 - some aspects of multivariate analysis Roy 1957
RoyExact function (=theta) calls Ksmn, BetaRoy (which equals IncBetaContFrac or IncompleteBetaByPartsNLarge depending on what values of m and n) and BetaZero
}



uses {Psy, Dos;}
  PsyBaseStats;

{
   range: 2 <= s <= 20;  m, n <= 1000

   find probability as
      p := gcr_Prob_Exact(s, m, n, cv) [for 2 <= s <= 4 and n <= 600]
      p := gcr_Prob_Approx(s, m, n, cv) [everywhere in range]
   find critical value as
      cv := gcr_Crit(p, s, m, n, LOWERMIN, UPPERMAX)
}

  // AI: added this fn to handle diff limits
  function gcr_Prob(s, m, n, x: float): float;
//  function gcr_Prob_Exact(s, m, n, x: float): float;
//  function gcr_Prob_Approx(s, m, n, x: float): float;
  function gcr_Crit(p, s, m, n, lower, upper: float): float;

implementation

{ we don't know about critical values outside these limits }
const MINLOWER = 0.001;
      MAXUPPER = 0.999;

{ need error handling, added to prevent compile error }
procedure SpringErrorTrap(Num: Integer; Msg: String);
begin
end;
      
function Ksmn(s, m, n: float): float; {
------------- constant factor in largest root cdf [Roy 7.8.1] }
{PSY2R - not identical to anderson p. 537 equation...?}
{KG: }
var   i, si: integer;
      term: array[0..5] of float;

begin
     term[0] := (s/2)*ln(Pi);

     si := round(s);
     term[1] := 0.0;
     for i := 1 to si do
        begin
        term[1] := term[1] + LnGamma((2*m + 2*n + s + i + 2)/2);
        end;

     term[2] := 0.0;
     for i := 1 to si do
        begin
        term[2] := term[2] + LnGamma((2*m + i + 1)/2);
        end;

     term[3] := 0.0;
     for i := 1 to si do
        begin
        term[3] := term[3] + LnGamma((2*n + i + 1)/2);
        end;

     term[4] := 0.0;
     for i := 1 to si do
        begin
        term[4] := term[4] + LnGamma(i/2);
        end;

     term[5] := term[0] + term[1] - (term[2] + term[3] + term[4]);
     Ksmn := exp(term[5])

end;

function RoyExact(s,m,n,x: float): float; {
----------------- Exact expressions as per Roy/Pillai/Nanda }

var B, B0, work: array[1..10] of float;
    K: array[2..10] of float;
    Pr: array[2..6] of float;
    ns: integer;

begin
    for ns := 2 to trunc(s) do
      case ns of
      2: begin
         K[2]  := Ksmn(2,m,n); 
         B[1]  := BetaRoy(x,2*m+1,2*n+1);
         B0[1] := BetaZero(x,m+1,n+1);
         B[2]  := BetaRoy(x,m,n);
         Pr[2] := K[2]/(m + n + 2) * (2*B[1] - B0[1]*B[2]);
         end;
      3: begin
         K[3]  := Ksmn(3,m,n);
         B0[2] := BetaZero(x,m+2,n+1);
         B[3]  := BetaRoy(x,2*m+3,2*n+1);
         B[4]  := BetaRoy(x,2*m+2,2*n+1);
         B[5]  := BetaRoy(x,m+1,n);
         work[1] := 2*B[3]*B[2] - 2*B[4]*B[5] - B0[2]*Pr[2]/K[2];
         Pr[3] := K[3]/(m + n + 3) * work[1];
         end;
      4: begin
         K[4]  := Ksmn(4,m,n);
         B0[3] := BetaZero(x,m+3,n+1);
         B[6]  := BetaRoy(x,2*m+5,2*n+1);
         B[7]  := BetaRoy(x,2*m+4,2*n+1);
         work[1] := B0[3]*Pr[3]/K[3];
         work[2] := 2*B[6]*Pr[2]/K[2];
         work[3] := 2*B[3]/(m + n + 3);
         work[4] := 2*B[3] - B0[2]*B[5];
         work[5] := 2*B[7]/(m + n + 3);
         work[6] := -B0[2]*B[2] + (m + 2)*Pr[2]/K[2] + 2*B[4];
         work[7] := -work[1] + work[2] + work[3]*work[4] - work[5]*work[6];
         Pr[4] := K[4]/(m + n + 4) * work[7];
         end;
      5: begin
         end;
      6: begin
         end
      end;
      RoyExact := Pr[trunc(s)]
end; { RoyExact }

function PillaiApproxOriginal(s, m, n, x: float): float; {
---------Approximate method of Pillai as per Pillai & Flury 1984 2.3}

const smax = 20;
type sarray = array[1..smax] of float;
var si, i, j, minus1: integer;
    h, f: array[1..smax] of float;
    term: sarray;
    kms: array[-20..0] of float;
    hsx, sum: float;

procedure SortDown(var x: sarray; nx: integer);
var i, j: integer;
    hold: float;
begin
for i := nx downto 2 do
    for j := 2 to i do
        begin
        if x[j-1] < x[j] then
           begin
           hold := x[j];  x[j] := x[j-1];  x[j-1] := hold
           end
        end;
end;

function LnCsmn(s, m, n: float): float; {
------------- Eqn 2 in Pillai 1965 }
var i: integer;
    term: array[1..2] of float;

begin
   term[1] := 0.5*s*Ln(Pi); {all terms logged then exponentiated later on}
   term[2] := 0.0;
   for i := 1 to round(s) do
       begin
       term[1] := term[1] + LnGamma(0.5*(2*m + 2*n + s + i + 2));
       term[2] := term[2] + LnGamma(0.5*(2*m + i + 1))
                          + LnGamma(0.5*(2*n + i + 1))
                          + LnGamma(0.5*i)
       end;

   LnCsmn := term[1] - term[2] {PSY2R - actual expression is term1/term2}
end; { LnCsmn }

function LnCsmnRatio(s, m, n: float): float; {
------------- Eqn 2 in Pillai 1965: ratio C(s)/C(s-1) }
var i: integer;
    term: array[1..5] of float;

begin
   term[1] := 0.5*Ln(Pi);
   term[2] := LnGamma(0.5*(2*m + 2*n + 2*s + 2));
   term[3] := LnGamma(0.5*(2*m + s + 1));
   term[4] := LnGamma(0.5*(2*n + s + 1));
   term[5] := LnGamma(0.5*s);

   LnCsmnRatio := term[1] + term[2] - term[3] - term[4] - term[5]

end; { LnCsmnRatio }

function CompSum(x: sarray; n:integer): float; {
---------------- Double compensated summation 4.3 (p.97, Higham [1966]) }

var  y, u, t ,v, z, s, c: sarray;
     k: integer;
begin
y[1] := 0;  u[1] := 0;  t[1] := 0;  v[1] := 0;  z[1] := 0;
s[1] := x[1];
c[1] := 0;
for k := 2 to n do
    begin
    y[k] := c[k-1] + x[k];
    u[k] := x[k] - (y[k] - c[k-1]);
    t[k] := y[k] + s[k-1];
    v[k] := y[k] - (t[k] - s[k-1]);
    z[k] := u[k] + v[k];
    s[k] := t[k] + z[k];
    c[k] := z[k] - (s[k] - t[k])
    end;

CompSum := s[n]
end;

function Binomial(n, k: float): float;
begin
Binomial := trunc(0.5 + exp(LnGamma(n + 1) - LnGamma(k + 1) - LnGamma(n - k + 1)));
end { Binomial };

begin

si := round(s);

if odd(round(s)) then
	hsx := IncompleteBetaFunctionRatio(m+1, n+1, x)
else
	hsx := 1.0;

kms[0] := 0.0;
term[2] := exp(LnCsmn(s,m,n) - LnCsmn(s-1,m,n)); 
for i := 1 to si - 1 do
    begin
    term[1] := 1.0/(m + n + s - i + 1);
    term[3] := Binomial(s-1,i-1);
    term[4] := 1;
    for j := 1 to i - 1 do
        term[4] := term[4] * (2*m + s - j + 1) / (2*m + 2*n + 2*s - j + 1);
    term[5] := (m + s - i + 1)*kms[-i+1];
    kms[-i] := term[1] * (term[2]*term[3]*term[4] - term[5]);
    end;

minus1 := -1;
for i := 1 to si - 1 do
    begin
    term[i] := exp((s-i)*Ln(x));
    term[i] := minus1*kms[-i]*term[i];
    minus1 := -minus1
    end;

SortDown(term,si-1);
sum := CompSum(term,si-1);
sum := exp(m*Ln(x) + (n + 1)*Ln(1.0 - x)) * sum;

PillaiApproxOriginal := hsx + sum

end; { PillaiApproxOriginal }

function gcr_Prob_Exact(s, m, n, x: float): float;

begin
if s <= 0 then
   begin
   end
else if s = 1 then
   begin
   end
else if (2.0 <= s) and (s <= 4.0) and (n <= 600.0) then
   begin
   gcr_Prob_Exact := 1 - RoyExact(s,m,n,x)
   end
else
   begin
   gcr_Prob_Exact := 0.0;
   SpringErrorTrap(1000,'s out of range')
   end
end; { gcr_Prob_Exact }

function gcr_Prob_Approx(s, m, n, x: float): float;
begin

if s <= 0 then
   begin
   end
else if s = 1 then
   begin
   end
else if s <= 20 then
   begin
   gcr_Prob_Approx := 1 - PillaiApproxOriginal(s,m,n,x)
   end
else
   begin
   gcr_Prob_Approx := 0.0;
   SpringErrorTrap(1000,'s out of range')
   end

end; { gcr_Prob_Approx }


{ AI: added for general gcr prob lookup }
function gcr_Prob(s, m, n, x: float): float;
begin
  // ranges out side 2 < s < 20 should be prevented before calling
  Result := 0.0;
  if (2.0 <= s) and (s <= 4.0) and (n <= 600.0) then
    begin
      { PSY2R: This uses RoyExact}
      Result := gcr_Prob_Exact(s, m, n, x);
    end
  else if ((4.0 < s) and (s <= 20.0)) or
          ((2.0 <= s) and (s <= 4.0) and (n > 600.0)) then
    begin
      Result := gcr_Prob_Approx(s, m, n, x);
  end;
end;



{    This is the function whose zero we find for gcr critical values.
     The required probability is in arglist[1].
     The degrees of freedom are in arglist[2:4].
     Function returns the the probability associated with the
     critical value x which is passed by BrentZero }

function gcr_CritProb_Exact(x: float; arglist: BrentVec): float; {
--------------------- }
var
   s, m, n: float;
begin
   s := arglist[2];  m := arglist[3];  n := arglist[4];
   { PSYR: This uses RoyExact}
   gcr_CritProb_Exact := arglist[1] - gcr_Prob_Exact(s,m,n,x);
end; { gcr_CritProb_Exact }

function gcr_CritProb_Approx(x: float; arglist: BrentVec): float; {
--------------------- }
var
   s, m, n: float;
begin
   s := arglist[2];  m := arglist[3];  n := arglist[4];
   gcr_CritProb_Approx := arglist[1] - gcr_Prob_Approx(s,m,n,x);
end; { gcr_CritProb_Approx }

function NewUpper(upper: float): float;
begin
     if 1.05*upper < MAXUPPER then
        NewUpper := 1.05*upper
     else
        NewUpper := MAXUPPER
end;

function NewLower(lower: float): float;
begin
     if 0.95*lower > MINLOWER then
        NewLower := 0.95*lower
     else
        NewLower := MINLOWER
end;


function gcr_Crit(p, s, m, n, lower, upper: float): float; {
   {PSY2R this calls the BrentZero function which calls gcr_CritProb_Approx or gcr_CritProb_Exact
      The x value is equal to lower/upper}
----------------- }
const
   macheps = 2.0e-14;
   tol     = 1.0e-10;
var
   j, ns: integer;
   zerofun: BrentFn;
   arglist: BrentVec;
   funval: float;

label loop_8, loop_12, loop_16, loop_20;

begin
     if (2 <= s) and (s <= 4) then
        begin
        if n <= 600 then
           begin
           lower := MINLOWER;  upper := MAXUPPER;
           (* work around for m = -0.5 *)
           if m < 0 then
              begin
              upper := gcr_Crit(p, s, 0, n, lower, upper);
              lower := 0.50*upper;
              zerofun := gcr_CritProb_Approx
              end
           else
              zerofun := gcr_CritProb_Exact;

           arglist[1] := p; arglist[2] := s;  arglist[3] := m;  arglist[4] := n;
           gcr_Crit := BrentZero(zerofun,lower,upper,arglist,macheps,tol)
           end

        else (* use exact to find upper bound then switch to approx *)
           begin
           lower := MINLOWER;  upper := MAXUPPER;

           if m < 0 then
              begin
              upper := gcr_Crit(p, s, 0, n, lower, upper);
              lower := 0.75*upper;
              zerofun := gcr_CritProb_Approx
              end
           else
              zerofun := gcr_CritProb_Exact;

           arglist[1] := p; arglist[2] := s;  arglist[3] := m;  arglist[4] := 600;
           upper := BrentZero(zerofun,lower,upper,arglist,macheps,tol);
           lower := 0.50*upper;  arglist[4] := n;
           zerofun := gcr_CritProb_Approx;
           gcr_Crit := BrentZero(zerofun,lower,upper,arglist,macheps,tol)
           end
        end
     else (* s > 4 so work up finding lower bound *)
        begin
           if s <= 8 then
              begin
              lower := MINLOWER;   upper := MAXUPPER;
              lower := gcr_Crit(p, 4.0, m, n, lower, upper);
              upper := lower + 0.75*lower;
              if upper > MAXUPPER then upper := MAXUPPER;
              arglist[1] := p; arglist[2] := s;  arglist[3] := m;  arglist[4] := n;
              zerofun := gcr_CritProb_Approx;

              loop_8:
                  funval := BrentZero(zerofun,lower,upper,arglist,macheps,tol);
                  if funval = upper then
                     begin
                     upper := NewUpper(upper);
                     goto loop_8;
                     end
                  else if funval = lower then
                     begin
                     lower := NewLower(lower);
                     goto loop_8;
                     end;

              gcr_Crit := funval
              end

           else if s <= 12 then
              begin
              lower := MINLOWER;   upper := MAXUPPER;
              lower := gcr_Crit(p, 8.0, m, n, lower, upper);
              upper := lower + 0.5*lower;
              if upper > MAXUPPER then upper := MAXUPPER;
              arglist[1] := p; arglist[2] := s;  arglist[3] := m;  arglist[4] := n;
              zerofun := gcr_CritProb_Approx;

              loop_12:
                  funval := BrentZero(zerofun,lower,upper,arglist,macheps,tol);
                  if funval = upper then
                     begin
                     upper := NewUpper(upper);
                     goto loop_12;
                     end
                  else if funval = lower then
                     begin
                     lower := NewLower(lower);
                     goto loop_12;
                     end;

              gcr_Crit := funval
              end

           else if s <= 16 then
              begin
              lower := MINLOWER;   upper := MAXUPPER;
              lower := gcr_Crit(p, 12.0, m, n, lower, upper);
              upper := lower + 0.5*lower;  if upper > MAXUPPER then upper := MAXUPPER;
              arglist[1] := p; arglist[2] := s;  arglist[3] := m;  arglist[4] := n;
              zerofun := gcr_CritProb_Approx;

              loop_16:
                  funval := BrentZero(zerofun,lower,upper,arglist,macheps,tol);
                  if funval = upper then
                     begin
                     upper := NewUpper(upper);
                     goto loop_16;
                     end
                  else if funval = lower then
                     begin
                     lower := NewLower(lower);
                     goto loop_16;
                     end;

              gcr_Crit := funval
              end

           else if s <= 20 then
              begin
              lower := MINLOWER;   upper := MAXUPPER;
              lower := gcr_Crit(p, 16.0, m, n, lower, upper);
              upper := lower + 0.5*lower;
              if upper > MAXUPPER then upper := MAXUPPER;
              arglist[1] := p; arglist[2] := s;  arglist[3] := m;  arglist[4] := n;
              zerofun := gcr_CritProb_Approx;

              loop_20:
                  funval := BrentZero(zerofun,lower,upper,arglist,macheps,tol);
                  if funval = upper then
                     begin
                     upper := NewUpper(upper);
                     goto loop_20;
                     end
                  else if funval = lower then
                     begin
                     lower := NewLower(lower);
                     goto loop_20;
                     end;

              gcr_Crit := funval
              end
         end;

end; { gcr_Crit }


function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
end;



begin

{
   range: 2 <= s <= 20;  m, n <= 1000

   find probability as
      p := gcr_Prob_Exact(s, m, n, cv) [for 2 <= s <= 4 and n <= 600]
      p := gcr_Prob_Approx(s, m, n, cv) [everywhere in range]
   find critical value as
      cv := gcr_Crit(p, s, m, n, LOWERMIN, UPPERMAX)
}

end.

