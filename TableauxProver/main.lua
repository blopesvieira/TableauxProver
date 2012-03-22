-- SequentProver
-- Copyright: Laborat'orio de Tecnologia em M'etodos Formais (TecMF)
--            Pontif'icia Universidade Cat'olica do Rio de Janeiro (PUC-Rio)
-- Author:    Bruno Lopes (bvieira@inf.puc-rio.br)
--            Edward Hermann (hermann@inf.puc-rio.br)
--            Vitor Pinheiro (valmeida@inf.puc-rio.br)
-- SequentProver is licensed under a Creative Commons Attribution 3.0 Unported License


require 'TableauxProver'

selectLanguage(defaultLanguage)
love.graphics.setBackgroundColor(255, 255, 255) -- White Color
font = love.graphics.newFont(11)

indexDragging = nil
isDragging = false
isClosed = false

--[[ Esta na funcao Draw
 Ela é chamado a todo momento, com um intervalo bem pequeno. Sempre que a posicao do mouse cai no
 unico if que tem nesta funcao, ela pinta o botao. Se além do mouse estar em cima do botao, o botao esquerdo do mouse
 estiver sendo apertado, ele chama a funcao tableauStep e depois chama um timer. ]]--
function stepButton()
	local xPos = windowWidth - 60
	local yPos = 5
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		-- Entra aqui quando o mouse esta em cima da regiao do botao	
		if love.mouse.isDown("l") then
			-- Entra aqui quando além do if de cima o botao esquedo foi pressionado.		
			tableauStep()
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
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
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
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
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(undoButtonName, xPos + 30, yPos - 5, 0, "center")
end

function readFileButton()
	local xPos = windowWidth - 60
	local yPos = 110
	local xLen = 55
	local yLen = 30
	local path
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then

--			insertFormula(opSeq, {opImp .. "(c,j)", opImp .. "(b,x)"}, opImp .. "("..opImp.."(z,x),c)", 0, 0, true, false, xBegin, yBegin)
			insertFormula(opSeq, {opImp .. "(c,j)", opImp .. "(b,x)"}, opImp .. "(c,"..opImp.."(z,x))", 0, 0, true, false, xBegin, yBegin)
--			insertFormula(opSeq, {opImp .. "(c,j)", opImp .. "(b,x)"}, opImp .. "(a,c)", 0, 0, true, false, xBegin, yBegin)
			--[[
			isClosed = false
			path = getPath(defaultInputFile)
			if path == nil then
				love.graphics.print(inputFail, windowWidth - 130, windowHeight - 30) -- VITOR: Ele até desenha, mas como o refresh é muito rapido nao da tempo de ler.
			else
				-- readFormulae(path) -- Comentei pq o parser pra sequentes ainda nao ta pronto
				-- colocar o insert formula aqui
				
			end 
			]]--
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(readFileButtonName, xPos + 30, yPos - 5, 0, "center")
end

function writeLaTeXFileButton()
	local xPos = windowWidth - 60
	local yPos = 145
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			qTreeOutput(getNonNil(defaultPath) .. "/" .. defaultLaTeXOutputFile)
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(latexButtonName, xPos + 30, yPos - 5, 0, "center")
end

function writeDotFileButton()
	local xPos = windowWidth - 60
	local yPos = 180
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			dotOutput(getNonNil(defaultPath) .. "/" .. defaultDotOutputFile)
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(dotButtonName, xPos + 30, yPos - 5, 0, "center")
end

function autoDisposeButton()
	local xPos = windowWidth - 60
	local yPos = 215
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		if love.mouse.isDown("l") then
			autoDisposeTree()
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
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
	autoDisposeButton() -- Desenha o botao Ajust, nao sei o que ele faz.
	writeDotFileButton()
	writeLaTeXFileButton()
	readFileButton() -- Desenha o Botao Read
	stepButton() -- Desenha o botao Step
	tableauButton() -- Desenha o Botao All
	undoButton() -- Desenha o Botao Undo
	expandSelectedNode() -- Recebe o evento do mouse pra expandir o nó desejado
	dragFormula()
	linkFormulae() -- Desenha as arestas entre os nós no canvas
	printFormulae() -- Desenha as formulas e as bolinhas
	testFinished()
	printDebugMessageTable() -- Só pra debug
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
			love.graphics.setColor(100, 100, 200) -- Cyan circle
		else
			love.graphics.setColor(0, 255, 0) -- Green circle
		end
		if inFormulaContradiction(i) then
			love.graphics.setColor(200, 0, 0) -- Red circle
		end
		love.graphics.circle("fill", formulaX[i], formulaY[i], 5, 25)
		love.graphics.setColor(0, 0, 0, 99) -- Black 99%
		love.graphics.circle("line", formulaX[i], formulaY[i], 6)
		love.graphics.print(printNode(i), formulaX[i] + circleSeparation, formulaY[i] - 6)
		i = i + 1
	end
end

function getFormulaIndex()
	local pos = nil
	local sub = nil
	local i
	local searchSub = true
	local from = 0
	for i = 1, #formulaOperator do
		if love.mouse.getX() <= formulaX[i] + circleSeparation + font:getWidth(printNode(i)) and love.mouse.getX() >= formulaX[i] + circleSeparation and love.mouse.getY() <= formulaY[i] + 6 and love.mouse.getY() >= formulaY[i] - 6 then
			pos = i
		end
	end
	if pos ~= nil then
		i = 0

		-- Vitor Inicio
		--[[
		local acabar = true
		local k=1
		while k <= 3 do					
			if formulaLeft[1][k] then
				createDebugMessage("getFormulaIndex: formulaLeft[1]["..k.."] = " .. formulaLeft[1][k])				
				createDebugMessage("getFormulaIndex: font:getWidth(formulaLeft[1]["..k.."]) = " .. font:getWidth(formulaLeft[1][k]))				
			end	
			k = k + 1
		end		
		createDebugMessage("getFormulaIndex: font:getWidth(formulaOperator[1]) = " .. font:getWidth(formulaOperator[1]))				
		createDebugMessage("getFormulaIndex: font:getWidth(formulaRight[1]) = " .. font:getWidth(formulaRight[1]))				
		]]--
		-- Vitor Fim


		while searchSub do
			i = i + 1

			if formulaLeft[pos][i] == nil then
				searchSub = false -- clicou fora do lado esquerdo da formula
				break
			end

			from = from + font:getWidth(formulaLeft[pos][i])

			--local debugMessage = font:getWidth(printNode(i))
			--local debugMessage2 = printNode(i)

			--createDebugMessage("getFormulaIndex: font:getWidth(printNode("..i..")) = "..debugMessage)
			--createDebugMessage("getFormulaIndex: printNode("..i..") = " .. debugMessage2)
			--createDebugMessage("getFormulaIndex: formulaX["..i.."] = "..formulaX[i])		
			--createDebugMessage("getFormulaIndex: love.mouse.getX() = "..love.mouse.getX())



			--local posInsideFormula = formulaX[i] - love.mouse.getX()


			--font:getWidth(formulaLeft[pos][i])

			-- Sempre sub ta igual a 1, algo errado aqui
			-- Só tem uma formula no formulaX
			-- printNode(i) retorna o tamanho de toda a formula, e só tem uma.
			if love.mouse.getX() <= formulaX[pos] + font:getWidth(formulaOperator[pos]) + circleSeparation + from then
				sub = i
				searchSub = false
			end
		end

		if sub then 
			createDebugMessage("getFormulaIndex: pos = ".. pos .. " sub = "..sub)
		else
			createDebugMessage("getFormulaIndex: pos = ".. pos .. " sub = nil")
		end

		return pos, sub
	end
	return pos
end

function expandSelectedNode()
	local pos = nil
	local subPos = nil
	if love.mouse.isDown("r") then
		pos, subPos = getFormulaIndex()

		-- VITOR DEBUG
		if subPos then
			local debugMessage = "expandSelectedNode: pos = " ..pos .. "subPos = "..subPos
			createDebugMessage(debugMessage)
		end

		if pos ~= nil then
			expandFormula(pos, subPos)
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
	local notOver
	while i < #formulaIndex do
		j = i + 1
		notOver = true
		while notOver and j <= #formulaIndex do
			if formulaX[i] == formulaX[j] and formulaY[i] == formulaY[j] and (formulaX[i] > 0 and formulaX[i] < windowWidth) then
				if formulaIndex[i] ~= 0 and formulaX[formulaIndex[i]] < formulaX[formulaIndex[j]] then
					formulaX[i] = formulaX[i] - xStep / 2
					formulaX[j] = formulaX[j] + xStep / 2
				else
					formulaX[i] = formulaX[i] + xStep / 2
					formulaX[j] = formulaX[j] - xStep / 2
				end
				notOver = false
				i = 0
			end
			j = j + 1
		end
		i = i + 1
	end
end

-- Essa funcao tenta encontrar o arquivo nester lugares:
-- o primeiro que ele consegue abrir ele usa.
-- 1) os.getenv("PWD"), 2) os.getenv("HOME"), 3) os.getenv("HOMEPATH"), 4) os.getenv("USERPROFILE")
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
		end
	end
	return nil
end

function getNonNil(list)
	local i
	for i = 1, #list do
		if list[i] ~= nil then
			return list[i]
		end
	end
	return nil
end

function createDebugMessage(debugMessage)
	MsgDebugTable[#MsgDebugTable+1] = debugMessage
end

function printDebugMessageTable()	
	for i = 1, #MsgDebugTable do
		local yRes = yDebug + i*15

		if yRes > windowHeight - yLim then
			MsgDebugTable = {}
			MsgDebugTable[1] = "Mensagens para debug:"
			love.graphics.print(MsgDebugTable[1], xDebug, yRes)
			break
		else		
			love.graphics.print(MsgDebugTable[i], xDebug, yRes)			
		end
	end
end
