from typing import List, Tuple

Float = float

dfBuildNum = '20000818'

dfHeaderInfo = 'PSY ' + dfBuildNum
dfCopyright = '© 2000'

PSYINHEADER = '%PSY IN%'
PSYOUTHEADER = '%PSY OUT%'

dfNL = '\r\n'
dfDefDelim = '\t'

dfComment = '//'
dfComLen = len(dfComment)

dfHeader = '[Header]'
dfData = '[Data]'
dfBCont = '[BetweenContrasts]'
dfWCont = '[WithinContrasts]'

dfSearchKeyList = [dfHeader, dfData, '[BContrasts]', dfBCont, '[BContrast]', '[BetweenContrast]',
                   '[WContrasts]', dfWCont, '[WContrast]', '[WithinContrast]']
dfNumSearchKeys = len(dfSearchKeyList)

nvAnalysis = 'PSY'
dfOutSearchKeyList = ['====', ' Number ', ' Means ', ' Analysis ', ' Rescaled ', ' Raw ', ' Approximate ']
dfNumOutSearchKeys = len(dfOutSearchKeyList)

clLow = 70.0
clHigh = 99.9
clErrMsg = 'Confidence Level must be between 70% and 99.9%'
clHintMsg = '70 to 99.9'
clDefMsg = '95'

cwInTitle = 'IN - '
cwOutTitle = 'OUT - '
cwDefTitle = 'Untitled'
cwCloseMsg = 'Close In/Out Window?'
cwInCloseSaveMsg = 'Save changes to IN window?'
cwOutCloseSaveMsg = 'Save changes to OUT window?'
cwOpenDef = 'in'
cwSaveIn = 'in'
cwSaveOut = 'out'

dfStatusWidth = 100
dfNavWidth = 121
peMSG = 'Error found in input!'
dfRpt = 60
dfLblWid = 12
dfMinRows = 3
dfMinCols = 4
dfMinColWidth = 64
dfCol0Width = 32
prLead = 6
dfTol = 1e-30
dfMissing = (255, 255, 0)  # Yellow
dfError = (255, 0, 0)  # Red
dfNot0Sum = (255, 255, 0)  # Yellow
dfTop = 22
dfLeft = 22
dfRight = 95

ewNoData = 'ERROR: No Data was found;20'
ewContrasts = 'ERROR: The Number of Groups and Measures must both be greater than two;0'
ewDf = 'ERROR: The degrees of freedom must be greater than zero;0'
ewGroup = 'ERROR: There must be at least one Between contrast;0'
ewMeasure = 'ERROR: There must be at least one Within contrast;0'
ewNoContrats = 'ERROR: There must be at least one Between or Within contrast;0'
ewIntContrasts = 'ERROR: Contrast coefficients must be integers;0'
ewBadData = 'Warning: Data missing or could not be understood;0'
ewBadCont = 'Warning: Either a contrast coefficient or the data''s group membership variable is missing or could not be understood;0'

prFigs = 3


def isFloat(in_str: str) -> bool:
    try:
        float(in_str)
        return True
    except ValueError:
        return False


def isInt(in_str: str) -> bool:
    try:
        int(in_str)
        return True
    except ValueError:
        return False


def f_to_str(in_val: Float, leading: int, places: int) -> str:
    tmp_str = format('{:e}', in_val)
    i = tmp_str.find('E') + 1
    mag_str = tmp_str[i + 1:i + 4]
    mag = int(mag_str)
    mag_str = str(mag)
    mag_len = len(mag_str)
    if mag > 30:
        return format('{: >{}.{}f}', 0.0, leading + places + 2, places)
    elif mag >= leading:
        return format('{: >{}.{}e}e{}{}', tmp_str, leading + places - mag_len,
                      leading + places - mag_len - 1, tmp_str[i], mag_str)
    else:
        return format('{: >{}.{}f}', in_val, leading + places + 2, places)
