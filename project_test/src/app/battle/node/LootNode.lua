--
-- Author: zsp
-- Date: 2015-04-02 10:17:14
--

local LootNode = class("GameNode", function()
	return display.newNode()
end)

--[[
	金币和宝箱奖励掉落
--]]
function LootNode:ctor(type)
	self.effect = display.newSprite("loot_effect.png");
	self.effect:addTo(self)
	self.effect:setVisible(false)

	self.type = type
	self.name = { [1] = "loot_chest", [2] = "loot_gold" }
	
	local sp = display.newSprite(string.format("%s.png", self.name[self.type]))
	--sp:setAnchorPoint(0.5,0)
	sp:setLocalZOrder(999)
	sp:addTo(self)

	self:showEffect()

end

function LootNode:showEffect()
	-- body
    self.effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(5,360)))
    self.effect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,100),cc.FadeTo:create(1,255))))
    self.effect:setVisible(true)
end

function LootNode:hideEffect()
	-- body
	self.effect:stopAllActions()
	self.effect:setVisible(false)
end

function LootNode:pickup()

	AudioManage.playSound("FightAwardFly.mp3",false)

	self:hideEffect()
	self:setVisible(false)

	local sp = display.newSprite(string.format("%s.png", self.name[self.type]))
	local x,y = self:getPosition()
	local pt = self:getParent():convertToWorldSpace(cc.p(x,y))
	sp:setPosition(pt)
	cc.Director:getInstance():getRunningScene():addChild(sp)
	
	local tx = 0
	if self.type == 1 then
		tx = 250
	else
		tx = 100
	end

	sp:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(tx,display.height-50)),cc.RemoveSelf:create()))
end

return LootNode