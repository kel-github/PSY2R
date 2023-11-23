import math
from ArraysClass import TArrays
from FforPsy import *
from Defines import *

class TPsyCalc:
    def __init__(self):
        self.NewWContrastArray: list[list[float]] = [] #            : array of array of Float; {NewBContrastsArray;}
        self.NormalisedDataMatrix: list[list[float]] = [] #         : array of array of Float; {NormalisedDataMatrixArray;}
        self.SumSquaresWithinGroupsArray: list[float] = [] #  : array of Float;
        self.SumSquaresArray: list[float] = [] #              : array of Float;
        self.MeanMatrix: list[list[float]] = [] #                   : array of array of Float;
        self.GroupMeansOnRepeatContrasts: list[list[float]] = [] #  : array of array of Float;
        self.StandardError: list[list[float]] = [] #                : array of array of Float; {StandardErrorMatrix;}
        self.SampleValue: list[list[float]] = [] #                  : array of array of Float; {SampleValueMatrix;}
        self.FinalSampleValue: list[list[float]] = [] #             : array of array of Float;
        self.LowerLimits: list[list[float]] = [] #                  : array of array of Float;
        self.UpperLimits: list[list[float]] = [] #                  : array of array of Float;
        self.DeviationMatrix: list[list[float]] = [] #               : array of array of Float;
        self.SumsOfSquaresMatrix: list[list[float]] = [] #          : array of array of Float;
        self.ReScaleFactor: int = 0

class TPsyOut:

    def __init__(self, array: TArrays):
        self.array: TArrays = array

    def WriteConfidenceInterval(self, a_contrast_counter,
    b_contrast_counter  : int,
    lv_cc, 
    scale_factor : float,
    temp_string,
    ss_string,
    sv_string,
    f_string : str,
    error_string: str,
    s : int,
    psy_calc: TPsyCalc):
        # Shorthand
        array = self.array
        
        # CC is the critical constant for:
        # Index 0: Between, 1: Within, 2: Between-Within
        CC = [0.0, 0.0, 0.0]
        dfLblWid = 10  # Replace with the actual value

        if array.DoConfidenceInterval == 1:
            # Separate
            result = math.sqrt(self.CalculateF(array.Alpha, array.DFE, 1))
            CC = [result, result, result]
        elif array.DoConfidenceInterval == 2:
            # Bonferroni
            if array.NumberOfBContrasts > 0:
                CC[0] = math.sqrt(self.CalculateF(array.Alpha/array.NumberOfBContrasts, array.DFE, 1))
            if array.NumberOfWContrasts > 0:
                CC[0] = math.sqrt(self.CalculateF(array.Alpha/array.NumberOfWContrasts, array.DFE, 1))
            if array.NumberOfBContrasts > 0 and array.NumberOfWContrasts > 0:
                CC[0] = math.sqrt(self.CalculateF(array.Alpha/(array.NumberOfBContrasts*array.NumberOfWContrasts), array.DFE, 1))
        elif array.DoConfidenceInterval == 3:
            # Post-hoc
            S = min(array.NumberOfGroups - 1, array.NumberOfRepeats - 1)
            if array.NumberOfBContrasts > 0:
                CC[0] = math.sqrt(array.NumberOfGroups - 1) * (self.CalculateF(array.Alpha, array.DFE, array.NumberOfGroups - 1))
            if array.NumberOfWContrasts > 0:
                CC[1] = math.sqrt((((array.NumberOfRepeats - 1) * array.DFE) / (array.DFE - array.NumberOfRepeats + 2)) * self.CalculateF(array.Alpha, array.DFE - array.NumberOfRepeats + 2, array.NumberOfRepeats - 1))
            if (array.NumberOfBContrasts > 0) and (array.NumberOfWContrasts > 0):
                if S > 1:
                    CC[2] = self.gcr_Crit(array.Alpha, S, (abs(array.NumberOfGroups - array.NumberOfRepeats) - 1) / 2, (array.DFE - array.NumberOfRepeats) / 2, 0.001, 0.999)
                    if CC[2] > 0 and CC[2] < 1:
                        CC[2] = math.sqrt(array.DFE * CC[2] / (1 - CC[2]))
                    else:
                        CC[2] = 0
                elif array.NumberOfGroups == 2:
                    CC[2] = CC[1]
                else:
                    CC[2] = CC[0]            
        elif array.DoConfidenceInterval == 4:
            # SMR
            if array.p > array.q:
                result = math.sqrt(self.SmrCriticalValue(array.q, array.p, array.DFE, array.Alpha))  # symmetric
            else:
                result = math.sqrt(self.SmrCriticalValue(array.p, array.q, array.DFE, array.Alpha))  # symmetric
            CC = [result, result, result]

        elif array.DoConfidenceInterval == 5:
            # Special/User-applied
            CC = [array.Bcc, array.Wcc, array.BWcc]


        for b_contrast_counter in range(1, array.NumberOfWContrasts + 2): # 1 more than pascal
            for a_contrast_counter in range(1, array.NumberOfBContrasts + 2):
                lvCC = CC[0]
                scale_factor = 1

                if a_contrast_counter > 1 and b_contrast_counter == 1:
                    lvCC = CC[0]
                    scale_factor = self.SumOfPositiveAContrasts(a_contrast_counter) / array.OrdB

                if a_contrast_counter == 1 and b_contrast_counter > 1:
                    lvCC = CC[1]
                    scale_factor = self.SumOfPositiveBcontrasts(b_contrast_counter) / array.OrdW

                if a_contrast_counter > 1 and b_contrast_counter > 1:
                    lvCC = CC[2]
                    scale_factor = (self.SumOfPositiveAContrasts(a_contrast_counter) *
                                    self.SumOfPositiveBcontrasts(b_contrast_counter)) / (array.OrdB * array.OrdW)

                if lvCC != -1:
                    psy_calc.LowerLimits[b_contrast_counter][a_contrast_counter] = psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] - (
                            psy_calc.StandardError[a_contrast_counter][b_contrast_counter] * lvCC)
                    psy_calc.UpperLimits[b_contrast_counter][a_contrast_counter] = psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] + (
                            psy_calc.StandardError[a_contrast_counter][b_contrast_counter] * lvCC)

                    if array.DoRescaling:
                        #TODO: CHECK THIS SECTION
                        psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] /= scale_factor
                        psy_calc.StandardError[a_contrast_counter][b_contrast_counter] /= scale_factor
                        psy_calc.LowerLimits[b_contrast_counter][a_contrast_counter] /= scale_factor
                        psy_calc.UpperLimits[a_contrast_counter][b_contrast_counter] /= scale_factor
                        # END OF TODO

                    sv_string = self.FtoStr((psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] / psy_calc.ReScaleFactor), prLead, prFigs)
                    ss_string = self.FtoStr((psy_calc.StandardError[a_contrast_counter][b_contrast_counter] / psy_calc.ReScaleFactor), prLead, prFigs)
                    f_string = self.FtoStr((psy_calc.LowerLimits[b_contrast_counter][a_contrast_counter] / psy_calc.ReScaleFactor), prLead, prFigs)
                    error_string = self.FtoStr((psy_calc.UpperLimits[b_contrast_counter][a_contrast_counter] / psy_calc.ReScaleFactor), prLead, prFigs)

                    #self.write_result(sv_string, ss_string, f_string, error_string,
                    #                    a_contrast_counter, b_contrast_counter)
                else:
                    if array.DoRescaling:
                        psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] = (
                                (psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] / scale_factor) / psy_calc.ReScaleFactor)
                        psy_calc.StandardError[a_contrast_counter][b_contrast_counter] = (
                                (psy_calc.StandardError[a_contrast_counter][b_contrast_counter] / scale_factor) / psy_calc.ReScaleFactor)

                    sv_string = self.FtoStr((psy_calc.FinalSampleValue[b_contrast_counter][a_contrast_counter] / psy_calc.ReScaleFactor), prLead, prFigs)
                    ss_string = self.FtoStr((psy_calc.StandardError[a_contrast_counter][b_contrast_counter] / psy_calc.ReScaleFactor), prLead, prFigs)
                    f_string = self.Format('  %*s %*s', [prLead, '*', prFigs, ''])
                    error_string = self.Format('  %*s %*s', [prLead, '*', prFigs, ''])
                    RoyMessage = True
                
                temp_string = ""
                if a_contrast_counter == 1:
                    temp_string += self.Format(' %-*.*s W%-2d     %s %s %s %s',
                                                [dfLblWid, dfLblWid, array.WithinComments[b_contrast_counter - 1],
                                                b_contrast_counter - 1, sv_string, ss_string, f_string, error_string])
                elif b_contrast_counter == 1:
                    temp_string += self.Format(' %-*.*s B%-2d     %s %s %s %s',
                                                [dfLblWid, dfLblWid, array.BetweenComments[a_contrast_counter - 1],
                                                a_contrast_counter - 1, sv_string, ss_string, f_string, error_string])
                else:
                    temp_string += self.Format(' %*s %-7s %s %s %s %s',
                                                [dfLblWid, ' ', self.Format('B%dW%d', [a_contrast_counter - 1, b_contrast_counter - 1]),
                                                sv_string, ss_string, f_string, error_string])

                if not ((a_contrast_counter == 1) and (b_contrast_counter == 1)):
                    self.Lines_Add(temp_string)


    def MinI(self, x, y):
        return x if x < y else y

    def FtoStr(self, InVal, Leading, Places):
        tmpStr = self.Format('%e' % InVal)  # convert to exponential notation
        i = tmpStr.find('E') + 1  # find the exponent, +1 to skip E
        MagStr = tmpStr[i:i + 3]  # +1 to skip sign
        Mag = int(MagStr)
        MagStr = str(Mag)  # explicit convert to clean leading zeros
        MagLen = len(MagStr)
        if Mag > 30:  # * done to avoid rounding errors near zero
            return self.Format('%*.*f' % (Leading + Places + 2, Places, 0.0))
        elif Mag >= Leading:
            # self.Format: number as -d.dddde-d
            return self.Format('%*.*se%s%s' % (Leading + Places - MagLen,  # width
                                        Leading + Places - MagLen - 1,  # number width, -1 for sign
                                        tmpStr,  # number
                                        tmpStr[i],  # exponent sign
                                        MagStr))  # exponent
        else:
            return self.Format('%*.*f' % (Leading + Places + 2, Places, InVal))

    def CalculateF(self, alpha, dfd, ndf) -> float:
        return F_Crit(alpha, ndf, dfd)

    def SumOfPositiveAContrasts(self, AContrastNumber):
            ResultVar = 0
            for i in range(1, self.array.NumberOfGroups + 1):
                if self.array.BContrastArray[AContrastNumber][i] > 0:
                    ResultVar += self.array.BContrastArray[AContrastNumber][i]
            
            if ResultVar == 0:
                raise BaseException("Sum of positive A contrasts is 0. Don't know how to handle it.")
            return ResultVar

    def SumOfPositiveBcontrasts(self, BContrastNumber):
            ResultVar = 0
            for i in range(1, self.array.NumberOfGroups + 1):
                if self.array.WContrastArray[BContrastNumber][i] > 0:
                    ResultVar += self.array.WContrastArray[BContrastNumber][i]
            
            if ResultVar == 0:
                raise BaseException("Sum of positive B contrasts is 0. Don't know how to handle it.")
            return ResultVar

    def Lines_Add(self, temp_string):
        print(temp_string)

    # Shouldn't need
    # def write_result(self, temp_string, a_contrast_counter, b_contrast_counter):
    #     # Implement the logic to write the result
    #     pass
        
    def psyr_scale_div(self, list_2d, scale_factor):
        for i in range(len(list_2d)):
            temp = list_2d[i]
            for j in range(len(temp)):
                list_2d[i][j] = temp[j]/scale_factor
        
    def psyr_scale_mult(self, list_2d, scale_factor):
        for i in range(len(list_2d)):
            temp = list_2d[i]
            for j in range(len(temp)):
                list_2d[i][j] = temp[j]*scale_factor
