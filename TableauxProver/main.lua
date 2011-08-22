-- TableauxProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
-- Tableaux Prover is licensed under a Creative Commons Attribution 3.0 Unported License


require 'TableauxProver'

function stepButton()
	xPos = windowWidth - 60
	yPos = 5
	xLen = 55
	yLen = 30
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
	love.graphics.printf("Step", xPos + 30, yPos - 5, 0, "center")
end

function tableauButton()
	xPos = windowWidth - 60
	yPos = 40
	xLen = 55
	yLen = 30
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
	love.graphics.printf("Tableau", xPos + 30, yPos - 5, 0, "center")
end

function undoButton()
	xPos = windowWidth - 60
	yPos = 75
	xLen = 55
	yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			tableauStepUndo()
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf("Undo", xPos + 30, yPos - 5, 0, "center")
end

function readFileButton()
	xPos = windowWidth - 60
	yPos = 110
	xLen = 55
	yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			readFormulae("/Users/blopesvieira/GIT/TableauxProver/TableauxProver/" .. defaultInputFile)
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf("Read", xPos + 30, yPos - 5, 0, "center")
end

function writeFileButton()
	xPos = windowWidth - 60
	yPos = 145
	xLen = 55
	yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			qTreeOutput("/Users/blopesvieira/GIT/TableauxProver/TableauxProver/" .. defaultOutputFile)
			love.timer.sleep(150)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf("LaTeX", xPos + 30, yPos - 5, 0, "center")
end

function testFinished()
	if not finished and tableauFinished() then
		finished = true
	else
		love.graphics.setColor(0, 100, 200)
		love.graphics.print("Tableau Closed!", WindoWidth - 100, windowHeight - 30)
	end
end

function love.draw()
	writeFileButton()
	readFileButton()
	stepButton()
	tableauButton()
	undoButton()
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
		love.timer.sleep(150)
	end
	--screen = love.image.newImageData(800, 600)
	--BMPScreen = love.image.newEncodedImageData(screen, "bmp")
	--love.filesystem.write("proof.bmp", BMPScreen)
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
