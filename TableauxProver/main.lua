require 'TableauxProver'

--insertFormula(opOr, opAnd .. "(a" .. formulaSep .. "b)", opAnd .. "(b" .. formulaSep .. "a)", 1, false, false, 100, 100)
insertFormula(opEx, "x", "P x", 1, false, false, 100, 100)

love.graphics.setMode(windowWidth, windowHeight, false, false, 0)

function love.draw()
	expandSelectedNode()
	dragFormula()
	linkFormulae()
	printFormulae()
end

function linkFormulae()
	for i = 2, #formulaIndex do
		love.graphics.setLineStyle("rough")
		love.graphics.setColor(100, 100, 100) -- Purple line
		love.graphics.line(formulaX[i], formulaY[i], formulaX[formulaIndex[i]], formulaY[formulaIndex[i]])
	end
end

function printFormulae()
	i = 1
	while i <= #formulaX do
		if formulaExpanded[i] then
			love.graphics.setColor(200, 0, 0) -- Red circle
		else
			love.graphics.setColor(0, 255, 0) -- Green circle
		end
		love.graphics.circle("fill", formulaX[i], formulaY[i], 5, 25)
		love.graphics.setColor(255, 255, 255, 90) -- White 90%
		love.graphics.circle("line", formulaX[i], formulaY[i], 6)
		if formulaValue[i] then
			value = "(T)"
		else
			value = "(F)"
		end
		if formulaOperator[i] == opAnd or formulaOperator[i] == opOr or formulaOperator[i] == opImp then
			love.graphics.print(value .. " " .. formulaOperator[i] .. "(" .. formulaLeft[i] .. "," .. formulaRight[i] .. ")", formulaX[i] + 20, formulaY[i] - 6)
		elseif formulaOperator[i] == opNot then
			love.graphics.print(value .. " " .. formulaOperator[i] .. "(" .. formulaRight[i] .. ")", formulaX[i] + 20, formulaY[i] - 6)
		else
			love.graphics.print(value .. " " .. formulaOperator[i] .. " " .. formulaLeft[i] .. "(" .. formulaRight[i] .. ")", formulaX[i] + 20, formulaY[i] - 6)
		end
		i = i + 1
	end
end

function getFormulaIndex()
	pos = nil
	for i = 1, #formulaOperator do
		if love.mouse.getX() <= formulaX[i] + 6 and love.mouse.getX() >= formulaX[i] - 6 and love.mouse.getY() <= formulaY[i] + 6 and love.mouse.getY() >= formulaY[i] - 6 then
			pos = i
		end
	end
	return pos
end

function expandSelectedNode()
	if love.mouse.isDown("r") then
		pos = getFormulaIndex()
		if pos ~= nil then
			expandFormula(pos)
		end
	end
	love.timer.sleep(200)
end

function dragFormula()
	if love.mouse.isDown("l") then
		pos = getFormulaIndex()
		if pos ~= nil then
			formulaX[pos] = love.mouse.getX()
			formulaY[pos] = love.mouse.getY()
		end
	end
end
