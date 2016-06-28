--[[
世界树查看奖励界面
]]

local TreeAwardLayer = class("TreeAwardLayer", function()
	return display.newNode()
end)

function TreeAwardLayer:ctor()
	print("TreeAwardLayer:ctor")
	self:initData()
	self:initView()
end


function TreeAwardLayer:initData()
	self.data = TreeData:getAwardList()
end

function TreeAwardLayer:initView()

	-- 灰层背景
	CommonView.blackLayer3()
    :addTo(self)
    :onTouch(function()
    	-- body
    end)

    self.layer_ = display.newNode():size(960, 640):align(display.CENTER):addTo(self):center()

-- 主层
-----------------------------------------------------
-- 背景框
    CommonView.backgroundFrame2()
    :addTo(self.layer_)
	:pos(480, 280)

	-- 标题
	CommonView.titleLinesFrame2()
	:addTo(self.layer_)
	:pos(480, 540)

	-- display.newSprite("word_report.png"):addTo(self.layer_)
	-- :pos(480, 540)
	base.Label.new({text="奖励列表", size=26}):addTo(self.layer_)
	:align(display.CENTER)
	:pos(480, 540)

------------------------------------------------------
    -- 列表
    base.GridView.new({
		rows = 1,
		viewRect = cc.rect(0, 0, 800, 440),
		itemSize = cc.size(800, 80),
		})
	:addTo(self.layer_)
	:pos(120, 55)
	:addItems(table.nums(self.data), function(event)
		local index = event.index
		local data = self.data[index]
		local grid = base.Grid.new()

		grid:addItem(base.Label.new({text=string.format("%d胜:", data.win), size=22}):pos(-380, 0))

		local posX = -280
		local itemX = 70
		local paccing = 10
		for k,v in pairs(data.items) do
			local itemView = UserData:createItemView(v.id, {scale=0.4})
			:pos(posX, 0)

			grid:addItem(itemView)

			-- 数量
			local label = base.Label.new({text=string.format("%d", v.count)})
			grid:addItem(label:pos(posX + itemX * 0.5, 0))

			posX = posX + itemX + label:getContentSize().width + paccing
		end

		return grid
	end)
	:reload()

	-- 关闭按钮
	CommonButton.close():addTo(self.layer_):pos(880, 530)
	:onButtonClicked(function()
		CommonSound.close() -- 音效

		self:onEvent_{name="close"}
	end)
end

function TreeAwardLayer:onEvent(listener)
	self.eventListener = listener

	return self
end

function TreeAwardLayer:onEvent_(event)
	if not self.eventListener then return end

	event.target = self
	self.eventListener(event)
end

return TreeAwardLayer