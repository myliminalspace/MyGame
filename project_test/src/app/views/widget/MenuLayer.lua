
local UserResLayer = import("..main.UserResLayer")
local MenuNode = import("..main.MenuNode")

local MenuLayer = class("MenuLayer", function()
	-- body
	return display.newNode()
end)

MenuLayer.wealthType = {
	power = UserResLayer.Type.EP_TYPE, -- 体力
	soul = UserResLayer.Type.SOUL_TYPE, -- 灵能值
	card = UserResLayer.Type.CARD_TYPE, -- 抽卡积分
	arena = UserResLayer.Type.ARENA_TYPE, -- 竞技场
	tree = UserResLayer.Type.TREE_TYPE, -- 尾兽/世界树
	castle = UserResLayer.Type.CASTLE_TYPE, -- 城建币
	skill = UserResLayer.Type.SKILL_TYPE, -- 技能点
	union = UserResLayer.Type.UNION_TYPE, -- 公会币
	instancePower = UserResLayer.Type.UNIONINSTANCE_TYPE, -- 公会副本体力
	coin = UserResLayer.Type.COIN_TYPE,  -- 黄金碎片
}

--[[
@param table options 参数表
-	wealth string 第三类财富类型
-   menu bool 是否显示menu node 默认显示
	back boll 返回按钮 显示
-   user bool 是否显示用户财富信息 默认显示
	autoClose  	bool 自动关闭按钮集合 默认
	autoOpen 	bool 自动打开按钮集合
~~ lua

	MenuLayer.new({wealth="card", menu=false})

~~ lua
]]
function MenuLayer:ctor(options)
	options = options or {}
	self:initData(options)
	self:initView(options)
	self:setNodeEventEnabled(true)
end

function MenuLayer:initData(options)
	if options.menu == nil then
		options.menu = true
	end
	if options.user == nil then
		options.user = true
	end
	if options.back == nil then
		options.back = true
	end

	self.autoOpen = options.autoOpen
	self.autoClose = options.autoClose
end

function MenuLayer:initView(options)
	self:autoCleanImage()


	-- 财富信息
	if options.user then
		self.userRes_ = UserResLayer.new(self.wealthType[options.wealth])
		:addTo(self)
		:pos(display.cx - 380, display.top - 60)
	end

	-- 返回按钮
	if options.back then
		self.backBtn_ = CommonButton.back()
		:addTo(self)
		:pos(display.right - 70, display.top - 50)
		-- :scale(0.8)
	end

	-- 按钮集合
	if options.menu then
		self.menuNode_ = MenuNode.new()
		:addTo(self)
		:pos(display.right - 60, 50)

		self.menuNode_:setHorBtnVisible(false)
	end


    self:zorder(10)

end

function MenuLayer:onBack(event)
	if self.backBtn_ then
		self.backBtn_:onButtonClicked(function(_event)
			event(self)

			-- 音效
			CommonSound.back()
		end)
	end
	return self
end

function MenuLayer:onEnter()
	self:reload()

end

function MenuLayer:updateDot()
	if self.menuNode_ then
		self.menuNode_:updateDot()
	end
end

function MenuLayer:onExit()

end

function MenuLayer:reload()

	-- 集合按钮
	if self.menuNode_ then
		if self.autoOpen then
			self:openMenuNode()
		elseif self.autoClose then
			self.menuNode_:hideMenu()
		end
	end

	-- 金钱信息更新
	if self.userRes_ then
		self.userRes_:updateUserCash()
		self.userRes_:updateUserDiamond()
		self.userRes_:updateUserEp()
		self.userRes_:updateUserInatanceEp()
		self.userRes_:updateSoulValue()
		self.userRes_:updateCardScoreValue()
		self.userRes_:updateArenaValue()
		self.userRes_:updateTreeValue()
		self.userRes_:updateUnionValue()
		self.userRes_:updateCoinValue()
	end
end

function MenuLayer:openMenuNode()
	if self.menuNode_ then
		if not self.menuNode_.isMenuOpen then
			self.menuNode_:showMenuBtnsAnimation()
    		self.menuNode_:setMenuOpen(true)
    		self.menuNode_:setBtnsEnabled()
    	end
	end
end

return MenuLayer