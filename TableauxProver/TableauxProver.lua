opAnd = '\\land'
opOr = '\\lor'
opImp = '\\to'
opNot = '\\neg'
opEx = '\\exists'
opAll = '\\forall'
formulaSep = ","
formulaOpenPar = "("
formulaClosePar = ")"
windowWidth = 800
windowHeight = 600
variableExpansionLimit = 100
defaultInputFile = "formula.p9"

newConst = "x"

formulaX = {}
formulaY = {}
formulaOperator = {}
formulaLeft = {}
formulaRight = {}
formulaIndex = {}
formulaValue = {}
formulaConstants = {}
formulaConstantsUsed = {}
formulaExpanded = {}
formulaLeaf = {}


function insertFormula(operator, left, right, index, value, expanded, x, y)
	formulaOperator[#formulaOperator + 1] = operator
	formulaIndex[#formulaIndex + 1] = index
	formulaRight[#formulaRight + 1] = right
	formulaLeft[#formulaLeft + 1] = left
	formulaValue[#formulaValue + 1] = value
	if x > windowWidth - 30 then
		x = windowWidth - 30
	end
	if y > windowHeight - 30 then
		y = windowHeight - 30
	end
	formulaX[#formulaX + 1] = x
	formulaY[#formulaY + 1] = y
	formulaExpanded[#formulaExpanded + 1] = expanded
	if #formulaLeaf > 0 then
		formulaLeaf[index] = false
	else
		findConstants(1)
	end
	formulaLeaf[#formulaLeaf + 1] = true
	formulaConstantsUsed[#formulaConstantsUsed + 1] = 0
end

function tableauStep()
	stepNotFound = true
	tableauStepI = 1
	while stepNotFound and tableauStepI <= #formulaExpanded do
		if not formulaExpanded[tableauStepI] then
			stepNotFound = false
			expandFormula(tableauStepI)
		else
			tableauStepI = tableauStepI + 1
		end
	end
	return not stepNotFound
end

function isLeaf(pos)
	leaf = true
	i = pos + 1
	while i <= #formulaIndex and leaf do
		if isInChain(pos, i) then
			leaf = false
		end
	end
	return leaf
end

function tableauStepUndo()
	if #formulaIndex > 1 then
		formulaExpanded[formulaIndex[#formulaIndex]] = false
		if formulaOperator[formulaIndex[#formulaIndex]] == opEx or formulaOperator[formulaIndex[#formulaIndex]] == opAll then
			if (formulaValue[formulaIndex[#formulaIndex]] and formulaOperator[formulaIndex[#formulaIndex]] == opEx) or (not formulaValue[formulaIndex[#formulaIndex]] and formulaOperator[formulaIndex[#formulaIndex]] == opAll) or (formulaConstantsUsed[formulaIndex[#formulaIndex]] == #formulaConstants) then
				formulaConstants[#formulaConstants] = nil
			end
			formulaConstantsUsed[formulaIndex[#formulaIndex]] = formulaConstantsUsed[formulaIndex[#formulaIndex]] - 1
		end
		if formulaOperator[formulaIndex[#formulaIndex]] == opAnd or formulaOperator[formulaIndex[#formulaIndex]] == opOr or formulaOperator[formulaIndex[#formulaIndex]] then
			toRemove = 2
		else
			toRemove = 1
		end
		if isLeaf(formulaIndex[#formulaIndex]) then
			formulaLeaf[formulaIndex[#formulaIndex]] = true
		end
		for stepUndoI = 1, toRemove do
			formulaX[#formulaIndex] = nil
			formulaY[#formulaY] = nil
			formulaOperator[#formulaOperator] = nil
			formulaLeft[#formulaLeft] = nil
			formulaRight[#formulaRight] = nil
			formulaIndex[#formulaIndex] = nil
			formulaValue[#formulaValue] = nil
			formulaLeaf[#formulaLeaf] = nil
		end
	end
end

function tableauClosed()
	noOpenBranch = true
	tableauClosedI = #formulaIndex
	while noOpenBranch and tableauClosedI > 0 do
		if formulaLeaf[tableauClosedI] then
			tableuClosedJ = tableauClosedI
			noContradiction = true
			while noContradiction and tableauClosedJ > 0 do
				tableauClosedK = formulaIndex[tableauClosedJ]
				while noConstradiction and tableauClosedK > 0 do
					if formulaOperator[tableauClosedJ] == formulaOperator[tableauClosedK] and formulaRight[tableauClosedJ] == formulaRight[tableauClosedK] and formulaLeft[tableauClosedJ] == formulaLeft[tableauClosedK] and formulaValue[tableauClosedJ] ~= formulaValue[tableauClosedK] then
						noConstradiction = false
					else
						tableauClosedK = tableauClosedK - 1
					end
				end
			end
			if not noContradiction then
				noOpenBranch = false
			end
		end
		tableauClosedI = tableauClosedI - 1
	end
	return noOpenBranch
end

function tableauFinished()
	finished = true
	tableauFinishedI = 1
	while finished and tableauFinishedI <= #formulaIndex do
		if not formulaExpanded[i] then
			finished = false
		end
		tableauFinishedI = tableauFinishedI + 1
	end
	return finished
end

function tableauSolve()
	solveLoop = 0
	while tableauStep() and solveLoop < variableExpansionLimit do
		solveLoop = solveLoop + 1
	end
end

function getOperatorPos(formula)
	if string.sub(formula, 1, string.len(opAnd)) == opAnd then
		return string.len(opAnd)
	elseif string.sub(formula, 1, string.len(opOr)) == opOr then
		return string.len(opOr)
	elseif string.sub(formula, 1, string.len(opNot)) == opNot then
		return string.len(opNot)
	elseif string.sub(formula, 1, string.len(opImp)) == opImp then
		return string.len(opImplies)
	elseif string.sub(formula, 1, string.len(opEx)) == opEx then
		return string.len(opEx)
	elseif string.sub(formula, 1, string.len(opAll)) == opAll then
		return string.len(opAll)
	end
	return nil
end

function isInChain(origin, pos)
	if origin == pos or formulaIndex[pos] == origin then
		return true
	end
	i = pos
	j = pos
	inChain = false
	while  j > origin do
		j = j - 1
		if formulaIndex[i] == j then
			i = j
			if formulaIndex[i] == origin then
				inChain = true
			end
		end
	end
	return inChain
end

function formulaFindSep(side, formulaSep)
	sepFindI = 0
	newFormula = 0
	formulaSepNotFound = true
	while formulaSepNotFound and sepFindI < string.len(side) do
		sepFindI = sepFindI + 1
		if string.sub(side, sepFindI, sepFindI) == formulaOpenPar then
			newFormula = newFormula + 1
		elseif string.sub(side, sepFindI, sepFindI) == formulaClosePar then
			newFormula = newFormula - 1
		elseif string.sub(side, sepFindI, sepFindI) == formulaSep and newFormula == 1 then
			formulaSepNotFound = false
		end
	end
	if sepFindI == string.len(side) then
		sepFindI = nil
	end
	return sepFindI
end

function expandAnd(pos)
	index = {}
	for i = pos, #formulaIndex do
		if formulaLeaf[i] and isInChain(pos, i) then
			index[#index + 1] = i
		end
	end
	if index == nil then
		index[1] = pos
	end
	left = formulaLeft[pos]
	right = formulaRight[pos]
	formulaExpanded[pos] = true
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(left)
	end
	j = getOperatorPos(left)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", left, index[k], false, true, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], false, false, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	end
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(right)
	end
	j = getOperatorPos(right)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], false, true, formulaX[index[k]] + 100, formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], false, false, formulaX[index[k]] + 200, formulaY[index[k]] + 30)
		end
	end
end

function expandOr(pos)
	index = {}
	for i = pos, #formulaIndex do
		if formulaLeaf[i] and isInChain(pos, i) then
			index[#index + 1] = i
		end
	end
	if index == nil then
		index[1] = pos
	end
	left = formulaLeft[pos]
	right = formulaRight[pos]
	formulaExpanded[pos] = true
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(left)
	end
	j = getOperatorPos(left)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", left, index[k], false, true, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], false, false, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	end
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(right)
	end
	j = getOperatorPos(right)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k] + 1, false, true, formulaX[index[k]] + 100, formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k] + 1, false, false, formulaX[index[k]], formulaY[index[k]] + 60)
		end
	end
end

function expandImp(pos)
	index = {}
	for i = pos, #formulaIndex do
		if formulaLeaf[i] and isInChain(pos, i) then
			index[#index + 1] = i
		end
	end
	if index == nil then
		index[1] = pos
	end
	left = formulaLeft[pos]
	right = formulaRight[pos]
	formulaExpanded[pos] = true
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(left)
	end
	j = getOperatorPos(left)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", left, index[k], true, true, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], true, false, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	end
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(right)
	end
	j = getOperatorPos(right)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k] + 1, false, true, formulaX[index[k]] + 100, formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k] + 1, false, false, formulaX[index[k]], formulaY[index[k]] + 60)
		end
	end
end

function expandNot(pos)
	index = {}
	for i = pos, #formulaIndex do
		if formulaLeaf[i] and isInChain(pos, i) then
			index[#index + 1] = i
		end
	end
	if index == nil then
		index[1] = pos
	end
	right = formulaRight[pos]
	formulaExpanded[pos] = true
	i = formulaFindSep(left, formulaSep)
	if i == nil then
		i = string.len(right)
	end
	j = getOperatorPos(right)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], not formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], not formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	end
end

function expandFormula(pos)
	if not formulaExpanded[pos] then
		if formulaOperator[pos] == opAnd then
			expandAnd(pos)
		elseif formulaOperator[pos] == opOr then
			expandOr(pos)
		elseif formulaOperator[pos] == opNot then
			expandNot(pos)
		elseif formulaOperator[pos] == opEx then
			expandEx(pos)
		elseif formulaOperator[pos] == opAll then
			expandAll(pos)
		end
	end
end

function findConstants(pos)
	left = formulaLeft[pos]
	right = formulaRight[pos]
	i = string.find(left, opEx)
	while i ~= nil do
		j = string.find(left, formulaSep, i)
		formulaConstants[#formulaConstants + 1] = string.sub(left, i + string.len(opEx) + 1, j - 1)
		i = string.find(left, opEx, j)
	end
	i = string.find(left, opAll)
	while i ~= nil do
		j = string.find(left, formulaSep, i)
		formulaConstants[#formulaConstants + 1] = string.sub(left, i + string.len(opAll) + 1, j - 1)
		i = string.find(left, opAll, j)
	end
	i = string.find(right, opEx)
	while i ~= nil do
		j = string.find(right, formulaSep, i)
		formulaConstants[#formulaConstants + 1] = string.sub(right, i + string.len(opEx) + 1, j - 1)
		i = string.find(right, opEx, j)
	end
	i = string.find(left, opAll)
	while i ~= nil do
		j = string.find(right, formulaSep, i)
		formulaConstants[#formulaConstants + 1] = string.sub(right, i + string.len(opAll) + 1, j - 1)
		i = string.find(right, opAll, j)
	end
end

function newConstant()
	exists = true
	i = 1
	while exists do
		if not existConstant(newConst) then
			newConst = string.rep(newConst, string.len(newConst) + 1)
		else
			exists = false
		end
	end
end

function getNewConstant()
	new = newConst .. (#formulaConstants + 1)
	if existConstant(new) then
		newConstant()
		new = newConst .. (#formulaConstants + 1)
	end
	return new
end

function existConstant(const)
	isNew = false
	i = 1
	while i <= #formulaConstants and not isNew do
		if formulaConstants[i] == const then
			isNew = true
		end
		i = i + 1
	end 
	return isNew
end

function expandEx(pos)
	index = {}
	for i = pos, #formulaIndex do
		if formulaLeaf[i] and isInChain(pos, i) then
			index[#index + 1] = i
		end
	end
	if index == nil then
		index[1] = pos
	end
	left = formulaLeft[pos]
	right = formulaRight[pos]
	if formulaValue[pos] then
		const = getNewConstant()
		formulaConstants[#formulaConstants + 1] = const
	else
		formulaConstantsUsed[pos] = formulaConstantsUsed[pos] + 1
		if formulaConstantsUsed[pos] <= #formulaConstants then
			const = formulaConstants[formulaConstantsUsed[pos]]	
		else
			const = getNewConstant()
			formulaConstants[#formulaConstants + 1] = const
		end
	end
	right = string.gsub(right, " " .. left, " " .. const)
	j = getOperatorPos(right)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	end
end

function expandAll()
	index = {}
	for i = pos, #formulaIndex do
		if formulaLeaf[i] and isInChain(pos, i) then
			index[#index + 1] = i
		end
	end
	if index == nil then
		index[1] = pos
	end
	left = formulaLeft[pos]
	right = formulaRight[pos]
	if not formulaValue[pos] then
		const = getNewConstant()
		formulaConstants[#formulaConstants + 1] = const
	else
		formulaConstantsUsed[pos] = formulaConstantsUsed[pos] + 1
		if formulaConstantsUsed[pos] <= #formulaConstants then
			const = formulaConstants[formulaConstantsUsed[pos]]	
		else
			const = getNewConstant()
			formulaConstants[#formulaConstants + 1] = const
		end
	end
	right = string.gsub(right, " " .. left, " " .. const)
	j = getOperatorPos(right)
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + 30)
		end
	end
end

function readFormulae(inputFileName)
	local formulae = {}
	io.input(inputFileName)
	formulae[1] = io.read()
	while formulae[#formulae] ~= nil do
		formulae[#formulae] = io.read()
	end
	return formulae
end
