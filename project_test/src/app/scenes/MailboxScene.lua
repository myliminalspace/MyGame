--[[
邮箱场景
]]

local MailboxScene = class("MailboxScene", base.Scene)


function MailboxScene:initView()
	self:autoCleanImage()

	-- 背景
	CommonView.background()
	:addTo(self)
	:center()

	CommonView.blackLayer3()
	:addTo(self)

	-- 按钮层
	app:createView("widget.MenuLayer"):addTo(self)
	:onBack(function(layer)
		self:pop()
	end)

	local layer_ = self.layer_

	-------------------------------------------------
	-- 背景框
	display.newSprite("HeroBoard.png"):addTo(self.layer_)
	:pos(442, 285)
	:zorder(2)

	display.newSprite("Mail_Board.png"):addTo(self.layer_)
	:pos(440, 285)
	:zorder(2)

	CommonView.titleLinesFrame2()
	:addTo(self.layer_)
	:pos(450, 535)
	:zorder(2)

	display.newSprite("Word_Mail.png"):addTo(self.layer_)
	:pos(450, 535)
	:zorder(2)

	-- base.Label.new({text="邮箱", size=32}):addTo(self.layer_)
	-- :align(display.CENTER)
	-- :pos(450, 525)
	-- :zorder(2)

	-----------------------------------------------------

	-- 邮件列表
	self.listView_ = base.GridView.new({
		rows = 1,
		viewRect = cc.rect(0, 0, 770, 430),
		itemSize = cc.size(770, 135),
		page = true,
	}):addTo(layer_)
	:pos(55, 60)
	:onTouch(function(event)
		if event.name == "clicked" then
			if event.itemPos then
				local index = event.itemPos
				self:selectedItemAtIndex(index)

				CommonSound.click() -- 音效
			end
		end
	end)
	:zorder(2)

	-- 侧边 按钮
	self.btnGroup_ = base.ButtonGroup.new({
		zorder1 = 1,
		zorder2 = 5,
	})
	:addButtons({
		base.Grid.new({normal = "Label_Normal.png", selected = "Label_Select.png"}):addLabel({text="未读", size=22, x=5, y=0}),
		base.Grid.new({normal = "Label_Normal.png", selected = "Label_Select.png"}):addLabel({text="已读", size=22, x=5, y=0}),
	})
	:walk(function(index, button)
		button:pos(890, 430 - (index-1) * 80):addTo(self.layer_)
		if index == 1 then
			local imgW, imgH = button:getSize()
			self.redPoint_ = display.newSprite("Point_Red.png"):addTo(button):zorder(5):pos(imgW * 0.5 - 10, imgH * 0.5 - 10)
		end
	end)
	:onEvent(function(event)
		if self.data_ then
			self:updateListView()
			self:updateCheckMail()

			CommonSound.click() -- 音效
		end
	end)
	:selectedButtonAtIndex(1)


	-- 没有邮件
	self.checkLabel_ = base.Label.new({text="该邮箱没有相关邮件", size=35, color=cc.c3b(255,0,0)}):addTo(layer_, 2):align(display.CENTER):pos(433, 280)

end

function MailboxScene:selectedItemAtIndex(index)
	local data = self:getCurrentData()
	if data then
		local mail = data[index]
		if mail then
			self:showReadLayer(mail)
		end
	end
end

function MailboxScene:showReadLayer(data)
	app:createView("mail.ReadMailLayer", data):addTo(self):zorder(10)
	:onEvent(function(event)
		if event.name == "close" then
			event.target:removeSelf()
			self:checkMail(data, event.target)
		elseif event.name == "read" then
			event.target:removeSelf()
			NetHandler.request("MailRead", {data={param1=data.id}, onsuccess=handler(self, self.netReadMail)}, self) 	 -- 读取不带附件 邮件

		elseif event.name == "received" then
			self.readMailLayer = event.target
			NetHandler.request("MailRead", {data={param1=data.id}, onsuccess=handler(self, self.netReadAnnexMail)}, self) 	 -- 读取邮件
		end
	end)
end

function MailboxScene:netReadMail(params)
	local data = MailData:getMail(params.mailId)
	if data then
		self:checkMail(data)
	end
end

function MailboxScene:netReadAnnexMail(params)
	local data = MailData:getMail(params.mailId)
	if data then
		if self.readMailLayer then
			if self.readMailLayer.mailId == data.id then
				self.readMailLayer:setReceived()
			end
		else
			self:checkMail(data)
		end
	end

	UserData:showReward(params.items, function()
		UserData:showTeamLevelUp(params.levelUp)
	end)
end

function MailboxScene:checkMail(data)
	print(data.received)
	self.readMailLayer = nil
	if not data.received then return end

	self:updateView()
	self:updateView()
end

-----------------------------------------

function MailboxScene:updateData()
	self.data_ = {MailData:getMails(), MailData:getReadMails()}

end

function MailboxScene:getCurrentData()
	local idx = self.btnGroup_:getSelectedIndex()
	return self.data_[idx]
end

function MailboxScene:updateView()
	self:updateListView()
	self:updateRedPoint()
	self:updateCheckMail()
end

function MailboxScene:updateListView()
	if not self:getCurrentData() then return end

	self.listView_
	:removeAllItems()
	:addItems(#self:getCurrentData(), function(event)
		local index = event.index
		local data = self:getCurrentData()[index]
		local grid = base.Grid.new()
		self:showGrid(grid, data)
		return grid
	end)
	:reload()
end

function MailboxScene:showGrid(grid, data)
	grid:addItems({
		display.newSprite("Mail_List.png"),
		display.newScale9Sprite("Mail_Circle.png"):pos(-280, 0),
		display.newScale9Sprite(data.icon):pos(-280, 0),
		base.Label.new({text="主题：", size=24, color=CommonView.color_yellow()}):pos(-210, 30),
		base.Label.new({text=data.title, size=24, color=CommonView.color_green()}):pos(-130, 30),
		base.Label.new({text="来自：", size=24}):pos(-200, -10),
		base.Label.new({text=data.from, size=24}):pos(-130, -10),
		base.Label.new({text=data.sendTime, size=20, color=cc.c3b(255,255,50)}):pos(280, -35):align(display.CENTER_RIGHT),
		})
	if data:haveAnnex() then
		grid:addItem(base.Label.new({text="有附件", size=24, color=CommonView.color_red()}):pos(260, 30))
	end
end

function MailboxScene:updateRedPoint()
	self.redPoint_:setVisible(#self.data_[1] > 0)
end

function MailboxScene:updateCheckMail()
	self.checkLabel_:setVisible(#self:getCurrentData() == 0)
end

return MailboxScene













