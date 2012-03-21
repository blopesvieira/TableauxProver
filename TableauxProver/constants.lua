-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
-- TableauxProver is licensed under a Creative Commons Attribution 3.0 Unported License

-- Operators definitions
opAnd = '\\land'
opAndPrint = '&'
opOr = '\\lor'
opOrPrint = '|'
opImp = '\\to'
opImpPrint = '->'
opNot = '\\neg'
opNotPrint = '~'
opEx = '\\exists'
opExPrint = 'Ex'
opAll = '\\forall'
opAllPrint = 'All'

-- Separators definitions
formulaSep = ","
formulaOpenPar = "("
formulaClosePar = ")"
operatorStart = '\\'

-- Positioning definitions
windowWidth = 800
windowHeight = 600
xLim = 30
yLim = 30
xStep = 50
yStep = 30
xBegin = windowWidth / 2
yBegin = 50

-- Deep limit definitions
variableExpansionLimit = 100

-- File definitions
defaultInputFile = "formulae.txt"
defaultLaTeXOutputFile = "formulae.tex"
defaultDotOutputFile = "formulae.dot"
displayOutput = "display"
defaultPath = {os.getenv("PWD"), os.getenv("HOME"), os.getenv("HOMEPATH"), os.getenv("USERPROFILE")}
tecmfURL = "http://www.tecmf.inf.puc-rio.br/TableauxProver"
noFile = "directinput"

-- Format definitions
latexFormat = "latex"
dotFormat = "dot"
defaultOutputFormat = latexFormat

-- Constants definitions
newConst = "x"

-- Languege definitions
defaultLanguage = "en"

-- Time definitions
buttonTime = 150
