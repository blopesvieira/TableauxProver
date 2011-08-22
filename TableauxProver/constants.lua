-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
-- Tableaux Prover is licensed under a Creative Commons Attribution 3.0 Unported License

-- Operators definitions
opAnd = '\\land'
opOr = '\\lor'
opImp = '\\to'
opNot = '\\neg'
opEx = '\\exists'
opAll = '\\forall'

-- Separators definitions
formulaSep = ","
formulaOpenPar = "("
formulaClosePar = ")"

-- Positioning definitions
windowWidth = 800
windowHeight = 600
xLim = 30
yLim = 30
xStep = 50
yStep = 30
xBegin = 50
yBegin = 50

-- Deep limit definitions
variableExpansionLimit = 100

-- File definitions
defaultInputFile = "formulae.txt"
defaultOutputFile = "formulae.tex"

-- Constants definitions
newConst = "x"
