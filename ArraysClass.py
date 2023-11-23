class TArrays():
    def __init__(self):
        self.DataMatrix: list[list[float]] = [[]]
        self.SubjectArray: list[int] = []
        self.SubjectIndexArray: list[int] = []
        self.BContrastArray: list[list[float]] = [[]]
        self.WContrastArray: list[list[float]] = [[]]
        
        self.Header: list[str] = []
        self.GroupsList: list[str] = []
        self.BetweenComments: list[str] = []
        self.WithinComments: list[str] = []

        self.SumOfSubjects: int = 0
        self.NumberOfGroups: int = 0
        self.NumberOfRepeats: int = 0
        self.NumberOfBContrasts: int = 0
        self.NumberOfWContrasts: int = 0

        self.AlphaString: str = ""
        self.DoConfidenceInterval: int = 0
        self.DoRescaling: bool = False

        self.CC: list[float] = [0.0, 1.0, 2.0]
        self.Alpha: float = 0.0
        self.p: int = 0
        self.q: int = 0
        self.OrdB: int = 0
        self.OrdW: int = 0
        self.DFE: float = 0
        self.RoyMessage: bool = False

        self.Bcc: float = 0.0
        self.Wcc: float = 0.0
        self.BWcc: float = 0.0

    def clear_all(self):
        self.DataMatrix = [[]]
        self.SubjectArray = []
        self.SubjectIndexArray = []
        self.BContrastArray = [[]]
        self.WContrastArray = [[]]
        
        self.Header = []
        self.GroupsList = []
        self.BetweenComments = []
        self.WithinComments = []

        self.SumOfSubjects = 0
        self.NumberOfGroups = 0
        self.NumberOfRepeats = 0
        self.NumberOfBContrasts = 0
        self.NumberOfWContrasts = 0

        self.AlphaString = ""
        self.DoConfidenceInterval = 0
        self.DoRescaling = False

        self.CC = [0.0, 1.0, 2.0]
        self.Alpha = 0.0
        self.p = 0
        self.q = 0
        self.OrdB = 0
        self.OrdW = 0
        self.DFE = 0
        self.RoyMessage = False

        self.Bcc = 0.0
        self.Wcc = 0.0
        self.BWcc= 0.0
        
