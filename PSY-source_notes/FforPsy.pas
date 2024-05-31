unit FforPsy;

interface

uses
  PsyBaseStats;

  function F_Crit(p: float; v1, v2: integer): float;
  function F_Prob(y: float; v1, v2: integer): float;

implementation

{ AI 981209 above added, original code below}

{$F+}


function Theta(y: float; v1, v2: integer): float;
begin
    Theta := arctan(sqrt(y)*sqrt(v1/v2))
end; { Theta }

function Fx(y: float; v1, v2: integer): float;
begin
    Fx := v2/(v2 + v1*y)
end; { Fx }

function Av(t: float; v2: integer): float;
var
   m, n: integer;
   sum1, sum2, sum3, term1, term2: float;

begin
   case v2 of
        1:
          Av := 2*t/Pi;
        3:
          begin
              term1 := t + sin(t)*cos(t);
              Av := TWO_ON_PI*term1;
        end;
        else
          begin
          sum1 := 0;  sum2 := 0;  sum3 := 1;
          m := 2;  n := 3;
          while m <= v2 - 3 do
          begin
              sum1 := sum1 + ln(m);
              sum2 := sum2 + ln(n);
              sum3 := sum3 + exp(m*ln(cos(t)) + sum1 - sum2);
              m := m + 2; n := n + 2;
          end;
          term1 := t + sin(t)*cos(t)*sum3;
          Av := TWO_ON_PI*term1
          end
   end
end; { AV }


function Bv(t: float; v1, v2: integer): float;
var
   m: integer;
   st, ct, term1, term2, sum1, sum2: float;
begin
   if v1 = 1 then
      Bv := 0
   else
   begin
       st := ln(sin(t));
       ct := ln(cos(t));
       term1 := LnFactorial((v2 - 1)/2.0) - LnFactorial((v2 - 2)/2.0) + st + v2*ct;
       term2 := 1;
       if v1 > 3 then
       begin
          sum1 := 0;
          sum2 := 0;
          m := 3;
          while m <= (v1 - 2) do
          begin
              sum1  := sum1 + ln(v2 + (m - 2));
              sum2  := sum2 + ln(m);
              term2 := term2 + exp(sum1 - sum2 + (m - 1)*st);
              m := m + 2;
          end;
       end;
       Bv := TWO_ON_SQRT_PI*exp(term1)*term2
   end
end; { Bv }


function V1even(y: float; v1, v2:integer): float;

var
   m: integer;
   x, p, term1, term2, sum1, sum2: float;

begin
    x := v2/(v2 + v1*y);
    if v1 = 2 then
        V1even := exp(v2/2.0*ln(x))
    else begin
        term1 := exp(v2/2.0*ln(x));  term2 := 1;
        sum1 := 0;  sum2 := 0;
        m := 2;
        while m <= (v1 - 2) do
        begin
            sum1  := sum1 + ln(v2 + m - 2);
            sum2  := sum2 + ln(m);
            term2 := term2 + exp(sum1 - sum2 + (m/2.0)*ln(1.0 - x));
            m := m + 2;
        end;
        V1even := term1 * term2;
    end;
end; { V1even }


function V2even(y: float; v1, v2: integer): float;

var
   m: integer;
   x, p, term1, term2, sum1, sum2: float;

begin
   x := 1.0 - v2/(v2 + v1*y);

    if v1 = 2 then
        V2even := exp(v1/2.0*ln(x))
    else begin
        term1 := exp(v1/2.0*ln(x));  term2 := 1.0;
        sum1 := 0.0;  sum2 := 0.0;
        m := 2;
        while m <= (v2 - 2) do
        begin
            sum1  := sum1 + ln(v1 + m - 2);
            sum2  := sum2 + ln(m);
            term2 := term2 + exp(sum1 - sum2 + (m/2)*ln(1 - x));
            m := m + 2;
        end;
        V2even := 1 - term1 * term2;
    end;
end; { V2even }

function V1oddV2odd(y: float; v1, v2:integer): float;

var
   pa, pb: float;

begin
    pa := Av(Theta(y,v1,v2),v2);
    pb := Bv(Theta(y,v1,v2),v1,v2);
    V1oddV2odd := 1.0 - pa + pb;
end; { V1oddV2odd }


function F_Prob(y: float; v1, v2: integer): float;

var
   p, pa, pb: float;

begin
//*************************add checks**********************
{    if (v1 <= 0) or (v2 <= 0) then
        StatDistError('Function F_Prob: df must be > 0');
    if not (isinteger(v1) and isinteger(v2)) then
        StatDistError('Function F_Prob: df must both be integers');}

    if odd(v1) and odd(v2) then
       F_Prob := V1oddV2odd(y, v1, v2)
    else
    begin
        if even(v1) then
           F_Prob := V1even(y,v1,v2)
        else
           F_Prob := V2even(y,v1,v2)
    end
end; { F_Prob }


procedure F_Approx(p: float; v1, v2: integer; var lower, upper: float);
begin
     lower := 0.25;  upper := 9.0e+12
end; { F_Approx }


{    This is the function whose zero we find for F critical values.
     The required probability is in arglist[1].
     The degrees of freedom are in arglist[2:3].
     Function returns the the probability associated with the
     critical value x which comes from BrentZero }

function F_CritProb(x: float; arglist: BrentVec): float;
var
   v1, v2: integer;
begin
   v1 := round(arglist[2]);  v2 := round(arglist[3]);
   F_CritProb := arglist[1] - F_Prob(x,v1,v2);
end; { F_CritProb }

function F_Crit(p: float; v1, v2: integer): float;
const
   macheps = 2.0e-14;
   tol     = 1.0e-10;
var
   lower, upper: float;
   zerofun: BrentFn;
   arglist: BrentVec;
begin
   F_Approx(p,v1,v2,lower,upper);
   arglist[1] := p; arglist[2] := v1;  arglist[3] := v2;
   zerofun := F_CritProb;
   F_Crit := BrentZero(zerofun,lower,upper,arglist,macheps,tol);

end; { F_Crit }

{ AI 981209 FforPsy program commented-out }
{
type task = 'A'..'Z';

label 100, 200;

var f_val, p_val: float;
    v1, v2, i, code: integer;
    dowhat: task;
    line: string[80];

begin
   100: writeln('[F]-value  [P]robability of [Q]uit? ');
   readln(dowhat);
   200: writeln;
   case dowhat of
        'F': begin
        writeln('Enter p value and df');
        readln(line);
        if length(line) = 0 then goto 100;
        i := pos(' ',line);  val(copy(line,1,i-1),p_val,code);  delete(line,1,i);
        i := pos(' ',line);  val(copy(line,1,i-1),v1,code);     delete(line,1,i);
        val(line,v2,code);
        f_val := F_Crit(p_val, v1, v2);
        writeln('F value = ',f_val:18:12);
        end;

        'P': begin
        writeln('Enter F value and df');
        readln(line);
        if length(line) = 0 then goto 100;
        i := pos(' ',line);  val(copy(line,1,i-1),f_val,code);  delete(line,1,i);
        i := pos(' ',line);  val(copy(line,1,i-1),v1,code);     delete(line,1,i);
        val(line,v2,code);
        p_val := F_Prob(f_val, v1, v2);
        writeln('P value = ',p_val:12:8);
        end;

        'Q': halt;

        else goto 100;
   end;
   goto 200;
}
end.




