-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
--            Edward Hermann (hermann@inf.puc-rio.br)
-- Tableaux Prover is licensed under a Creative Commons Attribution 3.0 Unported License


formulaX = {}
formulaY = {}
formulaOperator = {}
formulaLeft = {}
formulaRight = {}
formulaIndex = {}
formulaOrigin = {}
formulaValue = {}
formulaConstants = {}
formulaConstantsUsed = {}
formulaExpanded = {}
formulaLeaf = {}
formulaContradiction = {}

function cleanFormulae()
	formulaX = {}
	formulaY = {}
	formulaOperator = {}
	formulaLeft = {}
	formulaRight = {}
	formulaIndex = {}
	formulaOrigin = {}
	formulaValue = {}
	formulaConstants = {}
	formulaConstantsUsed = {}
	formulaExpanded = {}
	formulaLeaf = {}
	formulaContradiction = {}
end

function cleanContradictions()
	formulaContradiction = {}
end

function printNode(pos, sub)
	local value
	local operator = formulaOperator[pos]
	local left = formulaOperator[pos]
	local to = #left
	local leftOutput = ""
	local right = formulaRight[pos]
	operator = string.gsub(operator, opAnd, opAndPrint)
	operator = string.gsub(operator, opOr, opOrPrint)
	operator = string.gsub(operator, opImp, opImpPrint)
	operator = string.gsub(operator, opNot, opNotPrint)
	operator = string.gsub(operator, opEx, opExPrint)
	operator = string.gsub(operator, opAll, opAllPrint)
	right = string.gsub(right, opAnd, opAndPrint)
	right = string.gsub(right, opOr, opOrPrint)
	right = string.gsub(right, opImp, opImpPrint)
	right = string.gsub(right, opNot, opNotPrint)
	right = string.gsub(right, opEx, opExPrint)
	right = string.gsub(right, opAll, opAllPrint)
	if sub ~= nil then
		if sub <= #left then
			to = sub
		end
	end 
	for i = 1, to do
		left[i] = string.gsub(left[i], opAnd, opAndPrint)
		left[i] = string.gsub(left[i], opOr, opOrPrint)
		left[i] = string.gsub(left[i], opImp, opImpPrint)
		left[i] = string.gsub(left[i], opNot, opNotPrint)
		left[i] = string.gsub(left[i], opEx, opExPrint)
		left[i] = string.gsub(left[i], opAll, opAllPrint)
		leftOutput = leftOutput .. "," .. left[i]
	end
	leftOutput = string.sub(leftOutput, 2)
	if sub ~= nil then
		return leftOutput
	end
	if formulaOperator[pos] == opAnd or formulaOperator[pos] == opOr or formulaOperator[pos] == opImp then
		return  operator .. " (" .. left .. "," .. right .. ")"
	elseif formulaOperator[pos] == opNot then
		return operator .. " (" .. right .. ")"
	else
		return operator  .. " " .. left .. "(" .. right .. ")"
	end
end

function inFormulaContradiction(pos)
	local i
	for i = 1, #formulaContradiction do
		if formulaContradiction[i] == pos then
			return true
		end
	end
	return false
end

function printNodeLaTeX(pos)
	local value
	if formulaValue[pos] then
		value = "\\textbf{" .. trueLabel .. "}"
	else
		value = "\\textbf{" .. falseLabel .. "}"
	end
	if inFormulaContradiction(pos) then
		value = "$\\Rightarrow$" .. value
	end
	if formulaOperator[pos] == opAnd or formulaOperator[pos] == opOr or formulaOperator[pos] == opImp then
		return value .. " " .. "$" .. formulaOperator[pos] .. "(" .. formulaLeft[pos] .. "," .. formulaRight[pos] .. ")$"
	elseif formulaOperator[pos] == opNot then
		return value .. " " .. "$" .. formulaOperator[pos] .. "(" .. formulaRight[pos] .. ")$"
	else
		return value .. " " .. "$" .. formulaOperator[pos]  .. " " .. formulaLeft[pos] .. "(" .. formulaRight[pos] .. ")$"
	end
end

function printQTreeChain(pos, where)
	local chainString
	local chainString1
	local chainString2
	if pos <= #formulaIndex then
		if formulaIndex[pos] == where then
			if formulaOperator[formulaOrigin[pos]] == opAnd then
				chainString1 = printQTreeChain(pos + 2, pos)
				chainString2 = printQTreeChain(pos + 2, pos + 1)
				chainString = "[.{" .. printNodeLaTeX(pos) .. "} " .. chainString1 .. "] [.{" .. printNodeLaTeX(pos + 1) .. "} " .. chainString2 .. "]"
				return chainString
			else
				chainString1 = printQTreeChain(pos + 1, pos)
				chainString = "[.{" .. printNodeLaTeX(pos) .. "} " .. chainString1 .. "]"
				return chainString
			end
		else
			return printQTreeChain(pos + 1, where)
		end
	end
	return ""
end

function insertFormula(operator, left, right, index, origin, value, expanded, x, y)
	local i
	formulaOperator[#formulaOperator + 1] = operator
	formulaIndex[#formulaIndex + 1] = index
	formulaOrigin[#formulaOrigin + 1] = origin
	formulaRight[#formulaRight + 1] = right
	formulaLeft[#formulaLeft + 1] = {}
	for i = 1, #left do
		formulaLeft[#formulaLeft][i] = left[i]
	end
	formulaValue[#formulaValue + 1] = value
	if x > windowWidth - xLim then
		x = windowWidth - xLim
	end
	if y > windowHeight - yLim then
		y = windowHeight - yLim
	end
	formulaX[#formulaX + 1] = x
	formulaY[#formulaY + 1] = y
	formulaExpanded[#formulaExpanded + 1] = expanded
	if #formulaLeaf > 0 then
		formulaLeaf[index] = false
	end
	formulaLeaf[#formulaLeaf + 1] = true
	formulaConstantsUsed[#formulaConstantsUsed + 1] = 0
end

function haveOpenChains()
	local i
	local j
	local open
	for i = 1, #formulaIndex do
		if formulaLeaf[i] then
			open = true
			j = 1
			while open and j < #formulaContradiction do
				if formulaContradiction[j] <= i and formulaContradiction[j+1] <= i then
					if isInChain(formulaContradiction[j], i) and isInChain(formulaContradiction[j+1], i) then
						open = false
					end
				end
				j = j + 2
			end
			if open then
				return true
			end
		end
	end
	return false
end

function tableauClosed()
	local i = 1
	local j
	local k
	local newContradiction
	if #formulaIndex == 0 then
		return false
	end
	while i < #formulaIndex do
		j = i + 1
		while j <= #formulaIndex do
			if formulaValue[i] ~= formulaValue[j] and formulaRight[i] == formulaRight[j] and formulaLeft[i] == formulaLeft[j]  and formulaOperator[i] == formulaOperator[j] and isInChain(i, j) then
				k = 1
				newContradiction = true
				while newContradiction and k <= #formulaContradiction do
					if (formulaContradiction[k] == i and formulaContradiction[k+1] == j) or (formulaContradiction[k] == j and formulaContradiction[k+1] == i) then
						newContradiction = false
					end
					k = k + 2
				end
				if newContradiction then
					formulaContradiction[#formulaContradiction + 1] = i
					formulaContradiction[#formulaContradiction + 1] = j
				end
			end
			j = j + 1
		end
		i = i + 1
	end
	return not haveOpenChains()
end
