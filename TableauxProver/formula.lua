-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
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
end

function printNode(pos)
	local value
	if formulaValue[pos] then
		value = "(" .. trueLabel .. ")"
	else
		value = "(" .. falseLabel .. ")"
	end
	if formulaOperator[pos] == opAnd or formulaOperator[pos] == opOr or formulaOperator[pos] == opImp then
		return value .. " " .. "$" .. formulaOperator[pos] .. "(" .. formulaLeft[pos] .. "," .. formulaRight[pos] .. ")$"
	elseif formulaOperator[qTreeOutputI] == opNot then
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
				chainString = "[.{" .. printNode(pos) .. "} " .. chainString1 .. "] [.{" .. printNode(pos + 1) .. "} " .. chainString2 .. "]"
				return chainString
			else
				chainString1 = printQTreeChain(pos + 1, pos)
				chainString = "[.{" .. printNode(pos) .. "} " .. chainString1 .. "]"
				return chainString
			end
		else
			return printQTreeChain(pos + 1, where)
		end
	end
	return ""
end

function insertFormula(operator, left, right, index, origin, value, expanded, x, y)
	formulaOperator[#formulaOperator + 1] = operator
	formulaIndex[#formulaIndex + 1] = index
	formulaOrigin[#formulaOrigin + 1] = origin
	formulaRight[#formulaRight + 1] = right
	if operator == opNot then
		formulaLeft[#formulaLeft + 1] = ""
	else
		formulaLeft[#formulaLeft + 1] = left
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
	else
		findConstants(1)
	end
	formulaLeaf[#formulaLeaf + 1] = true
	formulaConstantsUsed[#formulaConstantsUsed + 1] = 0
end
