-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
--            Edward Hermann (hermann@inf.puc-rio.br)
-- Tableaux Prover is licensed under a Creative Commons Attribution 3.0 Unported License


require 'constants'
require 'formula'
require 'language'


function tableauStep()
	local stepNotFound = true
	local tableauStepI = 1
	if #formulaIndex >= 1 then
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
end

function tableauStepUndo()
	local tableauStepUndo = #formulaIndex
	local tableauStepOrigin = formulaOrigin[#formulaOrigin]
	local tableauStepConstant
	local tableauStepLeafs = {}
	local tableauStepI
	if #formulaIndex > 1 then
		formulaExpanded[tableauStepOrigin] = false
		if formulaOperator[tableauStepOrigin] == opEx or formulaOperator[tableauStepOrigin] == opAll then
			if (formulaOperator[tableauStepOrigin] == opEx and formulaValue[tableauStepOrigin]) or (formulaOperator[tableauStepOrigin] == opAll and not formulaValue[tableauStepOrigin]) or ((formulaConstantsUsed[tableauStepOrigin] == #formulaConstants)) then
				formulaConstants[#formulaConstants] = nil
			end
			formulaConstantsUsed[tableauStepOrigin] = formulaConstantsUsed[tableauStepOrigin] - 1
			while formulaOrigin[#formulaOrigin] == tableauStepOrigin and formulaLeaf[#formulaLeaf] do
				tableauStepLeafs[#tableauStepLeafs+1] = formulaIndex[#formulaIndex]
				formulaX[#formulaX] = nil
				formulaY[#formulaY] = nil
				formulaOperator[#formulaOperator] = nil
				formulaLeft[#formulaLeft] = nil
				formulaRight[#formulaRight] = nil
				formulaIndex[#formulaIndex] = nil
				formulaOrigin[#formulaOrigin] = nil
				formulaValue[#formulaValue] = nil
				formulaExpanded[#formulaExpanded] = nil
				formulaLeaf[#formulaLeaf] = nil
			end
			for tableauStepI = 1, #tableauStepLeafs do
				if tableauStepLeafs[tableauStepI] <= #formulaLeaf then
					formulaLeaf[tableauStepLeafs[tableauStepI]] = true
				end
			end	
		else
			while formulaOrigin[#formulaOrigin] == tableauStepOrigin do
				formulaLeaf[formulaIndex[#formulaIndex]] = true
				formulaX[#formulaX] = nil
				formulaY[#formulaY] = nil
				formulaOperator[#formulaOperator] = nil
				formulaLeft[#formulaLeft] = nil
				formulaRight[#formulaRight] = nil
				formulaIndex[#formulaIndex] = nil
				formulaOrigin[#formulaOrigin] = nil
				formulaValue[#formulaValue] = nil
				formulaExpanded[#formulaExpanded] = nil
				formulaLeaf[#formulaLeaf] = nil
			end
		end
	end
end

function tableauSolve()
	local solveLoop = 0
	if #formulaIndex >= 1 then
		while not tableauClosed() and tableauStep() and solveLoop < variableExpansionLimit do
			solveLoop = solveLoop + 1
		end
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
		return string.len(opImp)
	elseif string.sub(formula, 1, string.len(opEx)) == opEx then
		return string.len(opEx)
	elseif string.sub(formula, 1, string.len(opAll)) == opAll then
		return string.len(opAll)
	end
	return nil
end

function isInChain(origin, pos)
	local i = pos
	local j = pos
	local inChain = false
	if origin == pos or formulaIndex[pos] == origin then
		return true
	end
	while j > origin do
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
	local sepFindI = 0
	local newFormula = 0
	local formulaSepNotFound = true
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
	local index = {}
	local right
	local left
	local i
	local j
	local k
	local op
	if formulaValue[pos] then
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
		j = getOperatorPos(left)
		op = string.sub(left, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(left, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(left, formulaSep)
			if i == nil then
				i = string.len(left)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", left, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		end
		index = {}
		for i = pos, #formulaIndex do
			if formulaLeaf[i] and isInChain(pos, i) then
				index[#index + 1] = i
			end
		end
		j = getOperatorPos(right)
		op = string.sub(right, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(right, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(right, formulaSep)
			if i == nil then
				i = string.len(right)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		end

	else
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
		j = getOperatorPos(left)
		op = string.sub(left, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(left, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(left, formulaSep)
			if i == nil then
				i = string.len(left)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", left, index[k], pos, formulaValue[pos], true, formulaX[index[k]] - xStep, formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]] - xStep, formulaY[index[k]] + yStep)
			end
		end
		j = getOperatorPos(right)
		op = string.sub(right, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(right, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(right, formulaSep)
			if i == nil then
				i = string.len(right)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]] + xStep, formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]] + xStep, formulaY[index[k]] + yStep)
			end
		end
	end
end

function expandOr(pos)
	local index = {}
	local right
	local left
	local i
	local j
	local k
	local op
	if not formulaValue[pos] then
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
		j = getOperatorPos(left)
		op = string.sub(left, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(left, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(left, formulaSep)
			if i == nil then
				i = string.len(left)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", left, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		end
		index = {}
		for i = pos, #formulaIndex do
			if formulaLeaf[i] and isInChain(pos, i) then
				index[#index + 1] = i
			end
		end
		j = getOperatorPos(right)
		op = string.sub(right, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(right, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(right, formulaSep)
			if i == nil then
				i = string.len(right)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		end

	else
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
		j = getOperatorPos(left)
		op = string.sub(left, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(left, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(left, formulaSep)
			if i == nil then
				i = string.len(left)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", left, index[k], pos, formulaValue[pos], true, formulaX[index[k]] - xStep, formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]] - xStep, formulaY[index[k]] + yStep)
			end
		end
		j = getOperatorPos(right)
		op = string.sub(right, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(right, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(right, formulaSep)
			if i == nil then
				i = string.len(right)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]] + xStep, formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]] + xStep, formulaY[index[k]] + yStep)
			end
		end
	end
end

function expandImp(pos)
	local index = {}
	local right
	local left
	local i
	local j
	local k
	local op
	if not formulaValue[pos] then
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
		j = getOperatorPos(left)
		op = string.sub(left, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(left, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(left, formulaSep)
			if i == nil then
				i = string.len(left)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", left, index[k], pos, not formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], pos, not formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		end
		index = {}
		for i = pos, #formulaIndex do
			if formulaLeaf[i] and isInChain(pos, i) then
				index[#index + 1] = i
			end
		end
		j = getOperatorPos(right)
		op = string.sub(right, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(right, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(right, formulaSep)
			if i == nil then
				i = string.len(right)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
			end
		end

	else
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
		j = getOperatorPos(left)
		op = string.sub(left, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(left, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(left, formulaSep)
			if i == nil then
				i = string.len(left)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", left, index[k], pos, not formulaValue[pos], true, formulaX[index[k]] - xStep, formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(left,1,j), string.sub(left,j+2,i-1), string.sub(left,i+1,string.len(left)-1), index[k], pos, not formulaValue[pos], false, formulaX[index[k]] - xStep, formulaY[index[k]] + yStep)
			end
		end
		j = getOperatorPos(right)
		op = string.sub(right, 1, j)
		if op == opEx or op == opAll then
			i = j + 1
			while string.sub(right, i, i) ~= formulaOpenPar do
				i = i + 1
			end
		elseif op == opNot then
			i = j + 1
		else
			i = formulaFindSep(right, formulaSep)
			if i == nil then
				i = string.len(right)
			end
		end
		if j == nil then
			for k = 1, #index do
				insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]] + xStep, formulaY[index[k]] + yStep)
			end
		else
			for k = 1, #index do
				insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]] + xStep, formulaY[index[k]] + yStep)
			end
		end
	end

end

function expandNot(pos)
	local index = {}
	local right
	local left
	local i
	local j
	local k
	local op
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
	j = getOperatorPos(right)
	op = string.sub(right, 1, j)
	if op == opEx or op == opAll then
		i = j + 1
		while string.sub(right, i, i) ~= formulaOpenPar do
			i = i + 1
		end
	elseif op == opNot then
		i = j + 1
	else
		i = formulaFindSep(right, formulaSep)
		if i == nil then
			i = string.len(right)
		end
	end
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], pos, not formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, not formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
		end
	end
end

function expandFormula(pos)
	if not formulaExpanded[pos] then
		if formulaOperator[pos] == opAnd then
			expandAnd(pos)
		elseif formulaOperator[pos] == opOr then
			expandOr(pos)
		elseif formulaOperator[pos] == opImp then
			expandImp(pos)
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
	local left = formulaLeft[pos]
	local right = formulaRight[pos]
	local i = string.find(left, opEx)
	local j
	while i ~= nil do
		j = string.find(left, formulaSep, i)
		if j ~= nil then
			formulaConstants[#formulaConstants + 1] = string.sub(left, i + string.len(opEx) + 1, j - 1)
			i = string.find(left, opEx, j)
		else
			i = nil
		end
	end
	i = string.find(left, opAll)
	while i ~= nil do
		j = string.find(left, formulaSep, i)
		if j ~= nil then 
			formulaConstants[#formulaConstants + 1] = string.sub(left, i + string.len(opAll) + 1, j - 1)
			i = string.find(left, opAll, j)
		else
			i = nil
		end
	end
	i = string.find(right, opEx)
	while i ~= nil do
		j = string.find(right, formulaSep, i)
		if j ~= nil then
			formulaConstants[#formulaConstants + 1] = string.sub(right, i + string.len(opEx) + 1, j - 1)
			i = string.find(right, opEx, j)
		else
			i = nil
		end
	end
	i = string.find(right, opAll)
	while i ~= nil do
		j = string.find(right, formulaSep, i)
		if j ~= nil then
			formulaConstants[#formulaConstants + 1] = string.sub(right, i + string.len(opAll) + 1, j - 1)
			i = string.find(right, opAll, j)
		else
			i = nil
		end
	end
end

function newConstant()
	local exists = true
	local i = 1
	while exists do
		if not existConstant(newConst) then
			newConst = string.rep(newConst, string.len(newConst) + 1)
		else
			exists = false
		end
	end
end

function getNewConstant()
	local new = newConst .. (#formulaConstants + 1)
	if existConstant(new) then
		newConstant()
		new = newConst .. (#formulaConstants + 1)
	end
	return new
end

function existConstant(const)
	local isNew = false
	local i = 1
	while i <= #formulaConstants and not isNew do
		if formulaConstants[i] == const then
			isNew = true
		end
		i = i + 1
	end 
	return isNew
end

function expandEx(pos)
	local index = {}
	local right
	local left
	local i
	local j
	local k
	local op
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
	op = string.sub(right, 1, j)
	if op == opEx or op == opAll then
		i = j + 1
		while string.sub(right, i, i) ~= formulaOpenPar do
			i = i + 1
		end
	elseif op == opNot then
		i = j + 1
	else
		i = formulaFindSep(right, formulaSep)
		if i == nil then
			i = string.len(right)
		end
	end
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
		end
	end
end

function expandAll(pos)
	local index = {}
	local right
	local left
	local i
	local j
	local k
	local op
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
	op = string.sub(right, 1, j)
	if op == opEx or op == opAll then
		i = j + 1
		while string.sub(right, i, i) ~= formulaOpenPar do
			i = i + 1
		end
	elseif op == opNot then
		i = j + 1
	else
		i = formulaFindSep(right, formulaSep)
		if i == nil then
			i = string.len(right)
		end
	end
	if j == nil then
		for k = 1, #index do
			insertFormula("", "", right, index[k], pos, formulaValue[pos], true, formulaX[index[k]], formulaY[index[k]] + yStep)
		end
	else
		for k = 1, #index do
			insertFormula(string.sub(right,1,j), string.sub(right,j+2,i-1), string.sub(right,i+1,string.len(right)-1), index[k], pos, formulaValue[pos], false, formulaX[index[k]], formulaY[index[k]] + yStep)
		end
	end
end

function composeAnd(formulae)
	local composedFormulae = {}
	local cI
	if #formulae > 2 then
		for cI = 1, #formulae - 3 do
			composedFormulae[cI] = formulae[cI]
		end
		composedFormulae[#composedFormulae + 1] = opAnd .. formulaOpenPar .. formulae[#formulae - 2] .. formulaSep .. formulae[#formulae - 1] .. formulaClosePar
		composedFormulae[#composedFormulae + 1] = formulae[#formulae]
		return composeAnd(composedFormulae)
	end
	return formulae
end

function readFormulae(inputFileName)
	local formulae = {}
	local i
	local j
	local k 
	local op
	local value = true
	local formulaR
	io.input(inputFileName)
	formulaR = io.read()
	while formulaR ~= nil do
		if formulaPrefixParser(formulaR) then
			formulae[#formulae+1] = formulaR
		end
		formulaR = removeExtraWhiteSpace(io.read())
	end
	formulae = composeAnd(formulae)
	cleanFormulae()
	for i = 1, #formulae do
		if i == #formulae then
			value = false
		end
		j = getOperatorPos(formulae[i])
		op = string.sub(formulae[i], 1, j)
		if op == opEx or op == opAll then
			k = j + 1
			while string.sub(formulae[i], k, k) ~= formulaOpenPar do
				k = k + 1
			end
		elseif op == opNot then
			k = j + 1
		else
			k = formulaFindSep(formulae[i], formulaSep)
			if k == nil then
				k = string.len(formulae[i])
			end
		end
		if j == nil then
			insertFormula("", "", formulae[i], i - 1, 0, value, true, xBegin, yBegin * i)
		else
			insertFormula(op, string.sub(formulae[i],j+2,k-1), string.sub(formulae[i],k+1,string.len(formulae[i])-1), i - 1, 0, value, false, xBegin, yBegin * i)
		end
	end
	
end

function qTreeOutput(outputFileName)
	local outputFile
	if outputFileName == nil then
		outputFile = io.stdout
	else
		outputFile = io.open(outputFileName, "w")
	end
	outputFile:write("% " .. fileDisclaimer .. "\n")
	outputFile:write("% " .. tecmfURL .. "\n")
	outputFile:write("\\documentclass{article}\n\n")
	outputFile:write("\\usepackage{qtree}\n\n")
	outputFile:write("\\begin{document}\n\n")
	outputFile:write("\\Tree\n ")
	outputFile:write(printQTreeChain(1, 0))
	outputFile:write("\n\n\\end{document}")
	if outputFile ~= io.stdout then
		outputFile:close()
	end
end

function dotOutput(outputFileName)
	local i
	local outputFile
	if outputFileName == nil then
		outputFile = io.stdout
	else
		outputFile = io.open(outputFileName, "w")
	end
	outputFile:write("// " .. fileDisclaimer .. "\n")
	outputFile:write("// " .. tecmfURL .. "\n")
	outputFile:write("digraph Proof{\n")
	for i = 1, #formulaIndex do
		outputFile:write(i .. '[label="' .. printNode(i) .. '"]\n')
	end
	for i = 2, #formulaIndex do
		outputFile:write(formulaIndex[i] .. ' -> ' .. i .. '\n')
	end
	outputFile:write("}")
	if outputFile ~= io.stdout then
		outputFile:close()
	end
end

function removeExtraWhiteSpace(formula)
	local extraI = 1
	local left
	local right
	local nextC
	if formula == nil then
		return formula
	end
	while extraI < string.len(formula) do
		if string.sub(formula, extraI, extraI) == " " then
			nextC = string.sub(formula, extraI + 1, extraI + 1)
			if nextC == formulaSeparator or nextC == " " or nextC == formulaOpenPar or nextC == formulaClosePar or nextC == operatorStart then
				left = string.sub(formula, 1, extraI - 1)
				right = string.sub(formula, extraI + 1, string.len(formula))
				if left == nil then
					left = ""
				end
				if right == nil then
					right = ""
				end
				formula = left .. right
			else
				extraI = extraI + 1
			end
		else
			extraI = extraI + 1
		end
	end
	return formula
end

function formulaPrefixParser(formula)
	local i
	local j
	local k
	local left
	local right
	j = getOperatorPos(formula)
	if j == nil then
		for i = 1, string.len(formula) do
			if string.sub(formula, i, i) == formulaOpenPar or string.sub(formula, i, i) == formulaClosePar or string.sub(formula, i, i) == formulaSep then
				return false
			end
		end
		return true
	end
	if string.sub(formula, 1, j) == opEx or string.sub(formula, 1, j) == opAll then
		if string.sub(formula, j + 1, j + 1) ~= " " or string.sub(formula, j + 2, j + 2) == formulaOpenPar or string.sub(formula, j + 2, j + 2) == formulaClosePar or string.sub(formula, j + 2, j + 2) == formulaSep or string.sub(formula, j + 2, j + 2) == " " then
			return false
		end
		k = j + 3
		while k > string.len(formula) and string.sub(formula, k, k) ~= formulaOpenPar do
			k = k + 1
		end
		if k > string.len(formula) then
			return false
		end
		return formulaPrefixParser(string.sub(formula,k+1,string.len(formula)-1))
	end
	if string.sub(formula, j + 1, j + 1) ~= formulaOpenPar or string.sub(formula, string.len(formula)) ~= formulaClosePar then
		return false
	end
	if string.sub(formula, 1, j) == opNot then
		return formulaPrefixParser(string.sub(formula, j + 2, string.len(formula) - 1))
	end
	i = formulaFindSep(formula, formulaSep)
	left = formulaPrefixParser(string.sub(formula,j+string.len(formulaOpenPar)+1,i-1))
	right = formulaPrefixParser(string.sub(formula,i+1,string.len(formula)-1))
	return left and right
end

function autoTableau(outputFormat, formulaInput, formulaOutput, expansionLimit, direct)
	local j
	local k
	local op
	local file
	if formulaInput == nil then
		formulaInput = defaultInputFile
	end
	if outputFormat == nil then
		outputFormat = defaultOutputFormat
	end
	if formulaOutput == nil then
		if outputFormat == latexFormat then
			formulaOutput = defaultLaTeXOutputFile
		elseif outputFormat == dotFormat then
			formulaOutput = defaultDotOutputFile
		end
	end
	if expansionLimit ~= nil then
		variableExpansionLimit = tonumber(expansionLimit)
	end
	if direct ~= noFile then
		file = io.open(formulaInput, "r")
		if file == nil then
			print(inputFail)
		else
			io.close(file)
			readFormulae(formulaInput)
		end
	elseif formulaPrefixParser(formulaInput) then
		j = getOperatorPos(formulaInput)
		op = string.sub(formulaInput, 1, j)
		if op == opEx or op == opAll then
			k = j + 1
			while string.sub(formulaInput, k, k) ~= formulaOpenPar do
				k = k + 1
			end
		elseif op == opNot then
			k = j + 1
		else
			k = formulaFindSep(formulaInput, formulaSep)
			if k == nil then
				k = string.len(formulaInput)
			end
		end
		insertFormula(op, string.sub(formulaInput,j+2,k-1), string.sub(formulaInput,k+1,string.len(formulaInput)-1), 0, 0, false, false, xBegin, yBegin)
		
	end
	tableauSolve()
	if formulaOutput == displayOutput then
		formulaOutput = nil
	end
	if outputFormat == latexFormat and #formulaIndex > 0 then
		qTreeOutput(formulaOutput)
	elseif outputFormat == dotFormat and #formulaIndex > 0 then
		dotOutput(formulaOutput)
	end
end

-- Console execution
if #arg > 0 then
	selectLanguage(defaultLanguage)
	autoTableau(arg[1], arg[2], arg[3], arg[4], arg[5])
end
