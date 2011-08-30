-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
--            Edward Hermann (hermann@inf.puc-rio.br)
-- Tableaux Prover is licensed under a Creative Commons Attribution 3.0 Unported License


require 'TableauxProver'

selectLanguage("en")

indexDragging = nil
isDragging = false
isClosed = false

function stepButton()
	local xPos = windowWidth - 60
	local yPos = 5
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			tableauStep()
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(stepButtonName, xPos + 30, yPos - 5, 0, "center")
end

function tableauButton()
	local xPos = windowWidth - 60
	local yPos = 40
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			tableauSolve()
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(tableauButtonName, xPos + 30, yPos - 5, 0, "center")
end

function undoButton()
	local xPos = windowWidth - 60
	local yPos = 75
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			tableauStepUndo()
			isClosed = false
			cleanContradictions()
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(undoButtonName, xPos + 30, yPos - 5, 0, "center")
end

function readFileButton()
	local xPos = windowWidth - 60
	local yPos = 110
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			isClosed = false
			readFormulae(getPath(defaultInputFile))
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(readFileButtonName, xPos + 30, yPos - 5, 0, "center")
end

function writeFileButton()
	local xPos = windowWidth - 60
	local yPos = 145
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			qTreeOutput(getPath(defaultOutputFile))
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(latexButtonName, xPos + 30, yPos - 5, 0, "center")
end

function autoDisposeButton()
	local xPos = windowWidth - 60
	local yPos = 180
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			autoDisposeTree()
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(disposeButtonName, xPos + 30, yPos - 5, 0, "center")
end

function testFinished()
	if isClosed then
		love.graphics.setColor(0, 100, 200)
		love.graphics.print(tableauClosedLabel, windowWidth - 130, windowHeight - 30)
	else
		if tableauClosed() then
			isClosed = true
		end
	end
end

function love.draw()
	autoDisposeButton()
	writeFileButton()
	readFileButton()
	stepButton()
	tableauButton()
	undoButton()
	expandSelectedNode()
	dragFormula()
	linkFormulae()
	printFormulae()
	testFinished()
end

function linkFormulae()
	local i
	for i = 2, #formulaIndex do
		love.graphics.setLineStyle("rough")
		love.graphics.setColor(100, 100, 100) -- Purple line
		love.graphics.line(formulaX[i], formulaY[i], formulaX[formulaIndex[i]], formulaY[formulaIndex[i]])
	end
end

function printFormulae()
	local i = 1
	while i <= #formulaX do
		if formulaExpanded[i] then
			love.graphics.setColor(200, 0, 0) -- Red circle
		else
			love.graphics.setColor(0, 255, 0) -- Green circle
		end
		if inFormulaContradiction(i) then
			love.graphics.setColor(100, 100, 200) -- Cyan circle
		end
		love.graphics.circle("fill", formulaX[i], formulaY[i], 5, 25)
		love.graphics.setColor(255, 255, 255, 90) -- White 90%
		love.graphics.circle("line", formulaX[i], formulaY[i], 6)
		love.graphics.print(printNode(i), formulaX[i] + 20, formulaY[i] - 6)
		i = i + 1
	end
end

function getFormulaIndex()
	local pos = nil
	local i
	for i = 1, #formulaOperator do
		if love.mouse.getX() <= formulaX[i] + 6 and love.mouse.getX() >= formulaX[i] - 6 and love.mouse.getY() <= formulaY[i] + 6 and love.mouse.getY() >= formulaY[i] - 6 then
			pos = i
		end
	end
	return pos
end

function expandSelectedNode()
	local pos
	if love.mouse.isDown("r") then
		pos = getFormulaIndex()
		if pos ~= nil then
			expandFormula(pos)
		end
		love.timer.sleep(150)
	end
end

function dragFormula()
	if love.mouse.isDown("l") and not isDragging then
		indexMoving = getFormulaIndex()
		isDragging = true
	elseif not love.mouse.isDown("l") then
		isDragging = false
		indexMoving = nil
	elseif indexMoving ~= nil then
		formulaX[indexMoving] = love.mouse.getX()
		formulaY[indexMoving] = love.mouse.getY()
	end
end

function autoDisposeTree()
	local i = 1
	local j
	local notOver = true
	while notOver and i < #formulaIndex do
		j = i + 1
		while notOver and j <= #formulaIndex do
			if formulaX[i] == formulaX[j] and formulaY[i] == formulaY[j] then
				if formulaX[formulaIndex[i]] < formulaX[formulaIndex[j]] then
					formulaX[i] = formulaX[i] - xStep / 2
					formulaX[j] = formulaX[j] + xStep / 2
				else
					formulaX[i] = formulaX[i] + xStep / 2
					formulaX[j] = formulaX[j] - xStep / 2
				end
				notOver = false
				autoDisposeTree()
			end
			j = j + 1
		end
		i = i + 1
	end
end

function getPath(fileName)
	local file
	local i
	for i = 1, #defaultPath do
		if defaultPath[i] ~= nil then
			file = io.open(defaultPath[i] .. "/" .. fileName, "r")
			if file ~= nil then
				io.close(file)
				return defaultPath[i] .. "/" .. fileName
			end
			io.close(file)
		end
	end
end
