--[[
排行榜条
]]

local RankingGrid = class("RankingGrid", base.TableNode)

function RankingGrid:ctor(params)
	params = params or {}
	RankingGrid.super.ctor(self, params)
	-- print("\n\nnew flag:", params.flag)
	self:initView(params)
end

function RankingGrid:initView(params)
	self:initBackground()
	self:initIcon()
	self:initRank()
	self:initLevel()
	self:initName()
	self:initBattle()
	self:initSelfMark()
end

function RankingGrid:initBackground()
	self.backName = ""
	self.backIcon = nil
end

function RankingGrid:initIcon()
	self.iconWidget = display.newNode()
	:addTo(self, 2)
	:pos(-125, 0)


	self.iconName = ""
	self.icon = nil

	self.iconBorderName = ""
	self.iconBorder = nil
end

-- 排名
function RankingGrid:initRank()
	self.rankLabel = base.Label.new({
		size=50
	})
	:align(display.CENTER)
	:pos(-230, 0)
	:addTo(self, 2)
end

-- 等级
function RankingGrid:initLevel()
	base.Label.new({
		text="Lv",
		size=18
	})
	:pos(-65, 0)
	:addTo(self, 2)

	self.levelLabel = base.Label.new({
		size=18
	})
	:pos(-45, 0)
	:addTo(self, 2)

end

-- 昵称
function RankingGrid:initName()
	self.nameLabel = display.newTTFLabel({
		size=18
	})
	:pos(50, 0)
	:addTo(self, 2)
end

-- 战斗力
function RankingGrid:initBattle()
	self.battleLabel = display.newTTFLabel({
		size=20,
		color=cc.c3b(255,178,55)
	})
	:pos(185, 0)
	:addTo(self, 2)
end

-- 标记自己的图标
function RankingGrid:initSelfMark()
	self.selfMark = display.newSprite("Flag_Self.png")
	:addTo(self)
	:pos(-245, 25)
	:zorder(10)
	:hide()
end

-----------------------------------------------
-----------------------------------------------
--[[

]]

function RankingGrid:setBackground(name)
	if self:checkName(name, "backName", "backIcon") then
		self.backIcon = display.newSprite(name)
		:addTo(self)
	end

	return self
end

function RankingGrid:setRank(level)
	if level <= 3 then
		self.rankLabel:hide()
	else
		self.rankLabel:show()
		:setString(tostring(level))
	end
end

function RankingGrid:setIcon(name)
	if self:checkName(name, "iconName", "icon") then
		self.icon = display.newSprite(name)
		:addTo(self.iconWidget, 2)
		:scale(0.7)
	end
	return self
end

function RankingGrid:setIconBorder(name)
	if self:checkName(name, "iconBorderName", "iconBorder") then
		self.iconBorder = display.newSprite(name)
		:addTo(self.iconWidget)
		:scale(0.7)
	end
	return self
end

function RankingGrid:setLevel(level)
	self.levelLabel:setString(tostring(level))

	return self
end

function RankingGrid:setName(txt)
	self.nameLabel:setString(txt)

	return self
end

function RankingGrid:setBattle(level)
	self.battleLabel:setString(tostring(level))

	return self
end

-- 标记自己的图标
function RankingGrid:showSelfMark(b)
	self.selfMark:setVisible(b)

	return self
end

return RankingGrid













