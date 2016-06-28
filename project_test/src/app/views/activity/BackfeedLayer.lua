local BackfeedLayer = class("BackfeedLayer",function()
	return display.newNode()
end)

local NodeBox = import("app.ui.NodeBox")
local scheduler = require("framework.scheduler")
local GafNode = import("app.ui.GafNode")

local payImage1 = "flip_pay1.png"
local payImage2 = "flip_pay2.png"
local payImage3 = "flip_pay3.png"
local getImage1 = "backfeed_get1.png"
local getImage2 = "backfeed_get2.png"
local boxImage1 = "box_close.png"
local boxImage2 = "box_open.png"

function BackfeedLayer:ctor()
	self.effectRing = false
	self.closeFunc = nil
	self:createBackView()
	self:createBackfeedBtn()
	self:createItemsView()
	self:createBoxView()
	self:createLightAnimation()
	self:addNodeEventListener(cc.NODE_EVENT,function (event)
		if event.name == "enter" then
			self:onEnter()
		elseif event.name == "exit" then
			self:onExit()
		end
	end)
end

function BackfeedLayer:createBackView()
	CommonView.blackLayer2()
	:addTo(self)

	self.backSprite = display.newSprite(FeedbackModel.bgImage)
	self.backSprite:setPosition(display.cx,display.cy+30)
	self:addChild(self.backSprite)

	CommonButton.close():addTo(self.backSprite):pos(905,545)
	:scale(0.8)
	:onButtonClicked(function()
		CommonSound.close()
		if self.closeFunc then
			self.closeFunc()
		end
	end)
	--充值按钮
	self.btnPay = cc.ui.UIPushButton.new({normal = flip_pay1, pressed = flip_pay2, disabled = flip_pay3})
    :addTo(self.backSprite)
    :pos(300,255)

    self.label1 = createOutlineLabel({text = "",size = 24})
	:addTo(self.backSprite)
	:pos(300,495)

	self.label2 = createOutlineLabel({text = "",size = 15})
	:addTo(self.backSprite)
	:pos(360,110)

    CommonView.animation_show_out(self.backSprite)
end

function BackfeedLayer:createBoxView()
	self.boxNode = NodeBox.new()
	self.boxNode:setCellSize(cc.size(100,100))
	self.boxNode:setPosition(395,233)
	self.boxNode:setSpace(53,0)
	self.boxNode:setUnit(5)
	self.backSprite:addChild(self.boxNode,10)
end
--特效动画
function BackfeedLayer:createLightAnimation()
	self.boxNodeAni = NodeBox.new()
	self.boxNodeAni:setCellSize(cc.size(100,100))
	self.boxNodeAni:setPosition(395,233)
	self.boxNodeAni:setSpace(53,0)
	self.boxNodeAni:setUnit(5)
	self.backSprite:addChild(self.boxNodeAni,9)
end

function BackfeedLayer:updateBoxView()
	self.boxNode:cleanElement()
	self.boxNodeAni:cleanElement()

	local tab = {}
	local lightAni = {} --背景特效集合
	for i=1,5 do
		local sprite
		local lightAnimation
		if i < FeedbackModel.process then

			sprite = display.newSprite(boxImage2)
			lightAnimation = CommonView.animation_backfeed()
    		:scale(0.01)

		elseif i == FeedbackModel.process and FeedbackModel.isFinish == 1 then --已经打开
			sprite = display.newSprite(boxImage2)

			lightAnimation = CommonView.animation_backfeed()
    		:scale(0.01)

		elseif i == FeedbackModel.process then

			lightAnimation = CommonView.animation_backfeed()
    		:scale(1.6)

			sprite = display.newSprite(boxImage1)

			if self.effectRing == true then
				local aniSprite = display.newSprite()
				aniSprite:zorder(12)
				sprite:addChild(aniSprite)
				aniSprite:setPosition(55,45)
				aniSprite:setScale(1.1)
    			local animation = createAnimation("coin%d.png",6,0.05)
    			transition.playAnimationForever(aniSprite,animation)
    			self.effectRing = false
			end
			
		else  --未开启
			if i < 5 then
				lightAnimation = CommonView.animation_backfeed()
    			:scale(1.6)

			else
				lightAnimation = CommonView.animation_backfeed()
    			:scale(3)
			end

			sprite = display.newSprite(boxImage1)
			
		end
		if i < 5 then
			sprite:setScale(0.8)
		end
		table.insert(tab,sprite)
		table.insert(lightAni,lightAnimation)

	end
	self.boxNode:addElement(tab)
	self.boxNodeAni:addElement(lightAni)
end

--显示商品
function BackfeedLayer:createItemsView()
	self.itemBox = NodeBox.new()
	self.itemBox:setCellSize(cc.size(100,100))
	self.itemBox:setPosition(280,410)
	self.itemBox:setSpace(10,0)
	self.backSprite:addChild(self.itemBox,10)
end

function BackfeedLayer:updateItemView()
	self.itemBox:cleanElement()
	if not FeedbackModel:isCompleted() then
		local itemsNode = {}
		local len = #FeedbackModel.items
		self.itemBox:setUnit(len)
		for j=1,len do
			local item = FeedbackModel.items[j]
			table.insert(itemsNode,self:showItem(tostring(item.param1), tonumber(item.param3)))
	    end
		self.itemBox:addElement(itemsNode)
	end
end

--显示商品列表
function BackfeedLayer:showItem(itemId, count)
    local grid = UserData:createItemView(itemId, {scale=0.7})

    local label = base.Label.new({
        text = tostring(count),
        size = 18,
        color = CommonView.color_white(),
    })
    :align(display.BOTTOM_RIGHT)
    :pos(50, -50)

    grid:addItem(label)

    return grid
end

function BackfeedLayer:createBackfeedBtn()
	self.btn1 = cc.ui.UIPushButton.new()
	:onButtonClicked(function ()
		if FeedbackModel.rechargeValue < FeedbackModel:getRechargeLimit() then
			app:pushScene("RechargeScene")
		else
			NetHandler.gameRequest("GetSevenRechargeAward")
		end
		if self.effectNode2 then
			self.effectNode2:removeFromParent()
			self.effectNode2 = nil
		end
    end)
    self.btn1:setPosition(530,400)
	self.backSprite:addChild(self.btn1)

	self.label3 = createOutlineLabel({text = "", size = 24})
	self.label3:setPosition(0,35)
	self.btn1:addChild(self.label3)
end

function BackfeedLayer:updateBackfeedBtn()
	if FeedbackModel:isCompleted() then
		self.btn1:setVisible(false)
	else
		if FeedbackModel.rechargeValue < FeedbackModel:getRechargeLimit() then
			self.btn1:setButtonImage("normal",payImage1)
		  	self.btn1:setButtonImage("pressed",payImage2)
		else
			if FeedbackModel.isFinish == 1 then
				self.btn1:setButtonImage("disabled",payImage3)
				self.btn1:setButtonEnabled(false)
			else
				self.btn1:setButtonImage("normal",getImage1)
				self.btn1:setButtonImage("pressed",getImage2)
				self.effectRing = true
				local param = {gaf = "anniu_gaf"}
			    self.effectNode2 = GafNode.new(param)
			    self.effectNode2:playAction("a1",true)
			    self.effectNode2:setPosition(530, 350)
			    self.effectNode2:addTo(self.backSprite)
			    self.effectNode2:setTouchSwallowEnabled(false)
			end
		end
	end
end

function BackfeedLayer:updateLabel()
	if FeedbackModel:isCompleted() then
		self.label1:setString("")
		self.label3:setString("")
	else
		local str = string.format("今日充值%d元即可领取第%d阶段奖励",FeedbackModel:getRechargeLimit(),FeedbackModel.process)
		if FeedbackModel.isFinish == 1 then
			str = string.format("充值%s元即可领取第%d阶段奖励","??",FeedbackModel.process+1)
		end
		self.label1:setString(str)

		str = string.format("%d/%d",FeedbackModel.rechargeValue,FeedbackModel:getRechargeLimit())
		if FeedbackModel.isFinish == 1 then
			str = "次日5点开启"
		end
		self.label3:setString(str)
	end
end

function BackfeedLayer:updateView()
	self:updateBackfeedBtn()
	self:updateLabel()
	self:updateItemView()
	self:updateBoxView()
end

function BackfeedLayer:updateTimeShow()
	self.leftTime = self.leftTime - 1
	if self.leftTime <= 0 then
		self.closeFunc()
	end
	local date = convertSecToDate(self.leftTime)
    local str = string.format("活动规则: 1.达成一个阶段的充值任务后,第二天凌晨5点开启下一个阶段。\n             2.每一个阶段只累积当天的充值金额。\n             3.本活动将于%s天后消失,所有未领奖励将自动发放邮箱。",date.day)
	self.label2:setString(str)
end

function BackfeedLayer:startTimer()
    if self.timeHandle then
        return
    end
    self.timeHandle = scheduler.scheduleGlobal(handler(self,self.updateTimeShow),1)
end

function BackfeedLayer:stopTimer()
    if self.timeHandle then
        scheduler.unscheduleGlobal(self.timeHandle)
        self.timeHandle = nil
    end
end

function BackfeedLayer:onEnter()
	self.leftTime = FeedbackModel.closeTime - UserData:getServerSecond()
	self:updateTimeShow()
	self:updateView()
	self:startTimer()
end

function BackfeedLayer:onExit()
	self:stopTimer()
end

return BackfeedLayer