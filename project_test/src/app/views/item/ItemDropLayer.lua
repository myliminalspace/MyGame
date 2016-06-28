--物品掉落途径view

local ItemDropLayer = class("ItemDropLayer",function ()
	return display.newNode()
end)

local UIListView = import("framework.cc.ui.UIListView")
local DropNode = import(".DropNode")
local GameStage = import("app.data.GameStage")

local bgImage = "DropWay_Board.png"
local itemImage = "DropWay_Banner.png"
local arrowImage = "DropWay_arrow.png"

function ItemDropLayer:ctor(item)
	self.item = item
	self:createItemBg()
	if self.item.dropWay then
		self:createListView()
	else
		self:createTipLabel()
	end
	self:addNodeEventListener(cc.NODE_EVENT,function(event)
        if event.name == "enter" then
            self:onEnter()
        elseif event.name == "exit" then
            self:onExit()
        end
    end)
end

function ItemDropLayer:createItemBg()
	self.bgSprite = display.newSprite(bgImage)
	self:addChild(self.bgSprite)

	local textParam = {text = self.item.itemName..GET_TEXT_DATA("DROP_WAY"),color = cc.c3b(255,97,0),size = 24}
    local titleLabel = createOutlineLabel(textParam)
    titleLabel:setPosition(263,180)

    self.bgSprite:addChild(titleLabel)
end

function ItemDropLayer:createTipLabel()
	local textParam = {text = GET_TEXT_DATA("DROP_TIP"),color = display.COLOR_WHITE, size = 30}
    local tipLabel = createOutlineLabel(textParam)
    tipLabel:setPosition(260,110)
    self.bgSprite:addChild(tipLabel)
end

function ItemDropLayer:createListView()
	local params = {viewRect = cc.rect(22,20,480,145),direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
	self.listView = UIListView.new(params)
	for k,way in pairs(self.item.dropWay) do
		if way == 1 then
			if self.item.mapId then
				for i,map in ipairs(self.item.mapId) do
					local item = self.listView:newItem()
					local stage = ChapterData:getStage(map)
					if not stage then
						stage = ChapterData:createStage(map)
					end
					local dropNode = DropNode.new(stage)
					local size = dropNode:getContentSize()
					item:addContent(dropNode)
					item:setItemSize(size.width+2, size.height)
					self.listView:addItem(item)
				end
			end
		else
			self.listView:addItem(self:createExtraItem(way))
		end
	end
	self.listView:reload()
	self.bgSprite:addChild(self.listView)

	if #self.listView.items_ > 3 then
		self:createArrow()
	end
end

function ItemDropLayer:createArrow()
	local leftArrow = display.newSprite(arrowImage)
	leftArrow:setPosition(540,100)
	self.bgSprite:addChild(leftArrow)

	local rightArrow = display.newSprite(arrowImage)
	rightArrow:setPosition(-15,100)
	rightArrow:flipX(true)
	self.bgSprite:addChild(rightArrow)
end

function ItemDropLayer:createExtraItem(way)
	local _text = nil
	if way == 2 then
		_text = GET_TEXT_DATA("GOTO_SHOP_1")
	elseif way == 3 then
		_text = GET_TEXT_DATA("GOTO_SHOP_2")
	elseif way == 4 then
		_text = GET_TEXT_DATA("GOTO_SHOP_3")
	elseif way == 5 then
		_text = GET_TEXT_DATA("GOTO_SHOP_4")
	elseif way == 6 then
		_text = GET_TEXT_DATA("GOTO_SHOP_5")
	elseif way == 7 then
		_text = GET_TEXT_DATA("GOTO_SIGH")
	elseif way == 9 then
		_text = GET_TEXT_DATA("GOTO_WORD_TREE")
	elseif way == 10 then
		_text = GET_TEXT_DATA("GOTO_ANGLT")
	elseif way == 11 then
		_text = GET_TEXT_DATA("GOTO_ANGLT_SHOP")
	elseif way == 13 then
		_text = "寻宝"
	end

	local  item = self.listView:newItem()
	local btnCallBack = handler(self,self.buttonEvent)
	local button = cc.ui.UIPushButton.new({normal = itemImage})
	:onButtonClicked(btnCallBack)
	button:setTag(way)
	button:setTouchSwallowEnabled(false)

	local label = display.newTTFLabel({text = _text, align = cc.ui.TEXT_ALIGN_CENTER, size = 20, color = display.COLOR_GREEN})
	button:setButtonLabel(label)

	local size = button:getCascadeBoundingBox().size
	local content = display.newNode()
	content:addChild(button)
	item:addContent(content)
	item:setItemSize(size.width+2, size.height)

	return item
end

function ItemDropLayer:buttonEvent(event)
	AudioManage.playSound("Click.mp3")
	local tag = event.target:getTag()
	if tag == 2 then
		print("前往神秘商店")
	elseif tag == 3 then
		SceneData:pushScene("ShopArena", self)
    elseif tag == 4 then
    	self:toTreeShop()
    elseif tag == 5 then
    	-- self:toUnionShop()
    elseif tag == 6 then
        NetHandler.gameRequest("OpenShop",{param1 = 2})  -- 积分商店
    elseif tag == 7 then
    	SceneData:pushScene("SignIn", self)
	elseif tag == 9 then
		print("前往世界树")
	elseif tag == 10 then
		app:pushScene("TrialScene",{{toIndex=2}})
	elseif tag == 11 then
		self:toAincradShop()
	elseif tag == 13 then
		self:toCoinScene()
	end
end

-- 世界树商店
function ItemDropLayer:toTreeShop()
	if UserData:getUserLevel() >= OpenLvData.tree.openLv then
		NetHandler.gameRequest("OpenShop",{param1 = 3})
	else
		showToast({text = string.format("%d级开启", OpenLvData.tree.openLv)})
	end
end

-- 公会商店
function ItemDropLayer:toUnionShop()
	if UserData:getUserLevel() >= GameConfig["ConsortiaInfo"]["1"].ConsortiaOpenLeve then
		NetHandler.gameRequest("OpenShop",{param1 = 9})
	else
		showToast({text = string.format("%d级开启", GameConfig["ConsortiaInfo"]["1"].ConsortiaOpenLeve)})
	end
end

-- 葛朗特商店
function ItemDropLayer:toAincradShop()
	if UserData:getUserLevel() >= OpenLvData.aincrad.openLv then
		NetHandler.gameRequest("OpenShop",{param1 = 6})
	else
		showToast({text = string.format("%d级开启", OpenLvData.aincrad.openLv)})
	end
end

-- 宝藏系统
function ItemDropLayer:toCoinScene()
    if UserData:getUserLevel() >= GameConfig["CoinInfo"]["1"].OpenLeve then
        app:pushScene("CoinScene")  -- 宝藏系统
    else
        showToast({text = string.format("%d级开启！", openLevel) })
    end
end

function ItemDropLayer:onEnter()

end

function ItemDropLayer:onExit()
    --移除监听事件
    SceneData:removeTarget(self)
end

return ItemDropLayer