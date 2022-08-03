local maps = {
	"@7912127",
	"@7912131",
	"@7912143",
	"@7912170",
	"@7912171",
	"@7912172"
}

local gameTime = 150
local startBlocks = 50


----------------------

tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableAfkDeath(true)

local leftBlocks = {}

----------------------

function resetBlocks(nick)
	leftBlocks[nick] = startBlocks
	destroyBlock(nick)
	drawLeftBlocks(nick)
	updatePlayersStats()
end

-- How many blocks left. That text on the top-right
function drawLeftBlocks(nick)
	ui.addTextArea(0, "Objects left: "..leftBlocks[nick], nick, 680, 35, 200, 50, 0, 0, 0, true)
end

-- How many blocks each player has
---->
function showPlayersStats(nick)
	ui.addTextArea(1, "", nick, 10, 50, 200, 200, 0x565656, 0x767676, 0.5, true)
	updatePlayersStats()
end

function updatePlayersStats()
	local list = ""
	for nick, blocks in pairs(leftBlocks) do
		list = list..nick..": "..blocks.."\n"
	end

	ui.updateTextArea(1, list, nil)
end

function hidePlayersStats(nick)
	ui.removeTextArea(1, nick)
end
----<

-- Does player has any blocks left?
function hasBlocks(nick)
	return leftBlocks[nick] > 0
end

-- Place block
function spawnBlock(nick, x, y)
	local id = tfm.get.room.playerList[nick].id

	tfm.exec.addPhysicObject(id, x, y, {
		type = 13,
		width = 10,
		height = 10,
		friction = 0,
		resitution = 40,
		color = math.random(0x000000, 0xffffff)
	})
end

-- Destroy block
function destroyBlock(nick)
	local id = tfm.get.room.playerList[nick].id

	tfm.exec.removePhysicObject(id)
end

-- Start new map and reset players' blocks
function startGame()
	local newMapID = math.random(1, #maps)
	local newMap = maps[newMapID]
	local isFlipped = math.random(0, 1) == 1

	tfm.exec.newGame(newMap, isFlipped)

	for nick in pairs(leftBlocks) do
		resetBlocks(nick)
	end

	tfm.exec.setGameTime(gameTime)
	tfm.exec.setUIMapName("Czarodziejh <BL>- <I>Mouseour 1.1.0</BL></I>")
end

-- Button showing stats of each player
---->
function drawStatsButton(nick, event)
	ui.addTextArea(2,"<a href=\'event:"..event.."\'>...</a>",nick, 10, 30, 16, 15, 0x696969, 0x898989, 1, true)
end

function drawStatsButtonOn(nick)
	drawStatsButton(nick, "on")
end

function drawStatsButtonOff(nick)
	drawStatsButton(nick, "off")
end
----<

-----------------------------

function eventNewPlayer(nick)
	resetBlocks(nick)
	drawLeftBlocks(nick)
	drawStatsButtonOn(nick)
	system.bindMouse(nick, true)
end

for nick in pairs(tfm.get.room.playerList) do
	eventNewPlayer(nick)
end


function eventMouse(nick, x, y)
	-- Does player has any blocks
	if not hasBlocks(nick) then return end

	-- Decrease amount of available blocks
	leftBlocks[nick] = leftBlocks[nick] - 1
	spawnBlock(nick, x, y)

	drawLeftBlocks(nick)
	updatePlayersStats()
end


function eventPlayerDied(nick)
	resetBlocks(nick)
	tfm.exec.respawnPlayer(nick)
end


function eventTextAreaCallback(id, nick, event)
	if event == "on" then
		drawStatsButtonOff(nick)
		showPlayersStats(nick)
	elseif event == "off" then
		drawStatsButtonOn(nick)
		hidePlayersStats(nick)
	end
end

-----------------------------


startGame()
