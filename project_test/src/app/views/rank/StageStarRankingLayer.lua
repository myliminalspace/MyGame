--[[
关卡得星排名层
]]

local StageStarRankingLayer = class("StageStarRankingLayer", function()
	return display.newNode()
end)

function StageStarRankingLayer:ctor()
	print("关卡排名")
	self:initData()
	self:initView()
end

function StageStarRankingLayer:initData()

end

function StageStarRankingLayer:initView()

	local theight = 445
	self:addWord("word_20_ranking.png", 70, theight)
	self:addWord("word_20_head.png", 160, theight)
	self:addWord("word_20_level.png", 240, theight)
	self:addWord("word_20_name.png", 330, theight)
	self:addWord("word_20_star.png", 470, theight)

	-- 列表
    self.listView_ = base.TableView.new({
		rows = 1,
		-- freeMode = true,
		viewRect = cc.rect(0, 0, 570, 420),
		itemSize = cc.size(570, 105),
		})
	:addTo(self)
	:pos(0, 0)
	:onTouch(function(event)
		if event.name == "selected" then
			self:selectedIndex(event.index)
		end
	end)
end

function StageStarRankingLayer:addWord(name, x, y)
	display.newSprite(name)
	:addTo(self)
	:pos(x, y)
end

function StageStarRankingLayer:selectedIndex(index)
	local teamData = self.data[index]
	NetHandler.gameRequest("ShowTeamDefenseInfo", { param1 = teamData.userId ,param2 = 5, param3 = teamData.score})
end

function StageStarRankingLayer:updateData()
	self:updateListData()
end

function StageStarRankingLayer:updateView()
	self:updateListView()
end


function StageStarRankingLayer:updateListData()
	local data = RankData:getRank("stageStar")
	self.data = data.teams
	self.rank = data.rank 			-- 排名
	self.rankMax = data.rankMax 	-- 历史最高
end

function StageStarRankingLayer:updateListView()
	self.listView_
	:resetData()
	:addItems(table.nums(self.data), function(event)
		local index = event.index
		local data = self.data[index]
		local grid = event.target:getFreeItem()
		if not grid then
			grid = app:createView("rank.RankingGrid")
			grid:setIconBorder(ArenaData:getDefaultBorder())
		end

		if index <= 3 then
			grid:setBackground(string.format("Ranking_bar_%d.png", index))
		else
			grid:setBackground("Ranking_bar_4.png")
			grid.backIcon:pos(0, 3)
		end

		grid:setLevel(data.level)
		grid:setName(data.name)
		grid:setBattle(data:getScore())
		grid:setRank(data.rank)
		grid:setIcon(data.icon)
		print(data.rank.." data.rank")

		local teamId = data.teamId or ""
		grid:showSelfMark(teamId == UserData.teamId)

		return grid
	end)
	:reload()

	return self
end

return StageStarRankingLayer

