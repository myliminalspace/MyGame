--
-- Author: zsp
-- Date: 2015-03-23 16:28:22
--
--[[
    显示角色怒气 控制变身按钮
--]]

local BattleEvent  = require("app.battle.BattleEvent")

local AngerButton = class("AngerButton",function()
    return display.newNode()
end)

function AngerButton:ctor(role)

   self.guide      = false --是否新手引导
   self.guideBegin = false --引导开始
   self.guideEnd   = false --引导结束

  -- self.handle = nil
  self.role = role --所属的角色
  self.visibleEffect = false --显示完成特效

  self.onEvolveMode = nil --是否变身模式
	 
  local bg = display.newSprite("Skill_Circle.png") 
  bg:addTo(self)
  bg:setTouchEnabled(true)

  self:setContentSize(bg:getContentSize())

  --按钮图标
  local awakeIcon = "AwakeIcon01.png" 
  if GameConfig.hero_awake[self.role.roleId] then
      awakeIcon = GameConfig.hero_awake[self.role.roleId]["AwakeIcon"]
  end

  local pack = {"GRAY",{0.1, 0.1, 0.1, 0.1}}
  local __filters, __params = unpack(pack)
  if __params and #__params == 0 then
    __params = nil
  end
 
  local mask =  display.newFilteredSprite(awakeIcon,__filters, __params)
  mask:addTo(self)

  --变身前怒气进度
  self.progress1 = cc.ProgressTimer:create(display.newSprite(awakeIcon))
  self.progress1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.progress1:setBarChangeRate(cc.p(0, 1))
  self.progress1:setMidpoint(cc.p(0, 0))
  self.progress1:addTo(self)
  self.progress1:setPercentage(self.role.model.anger * 1.0 / self.role.model.maxAnger * 100)

  --变身后怒气进度
  self.progress2 = cc.ProgressTimer:create(display.newSprite(awakeIcon))
  self.progress2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
  self.progress2:setBarChangeRate(cc.p(0, 1))
  self.progress2:setMidpoint(cc.p(0, 0))
  self.progress2:setPercentage(100)
  self.progress2:addTo(self)

  self:setEvolveMode(false)

  self.btn = cc.ui.UIPushButton.new(awakeIcon)
  self.btn:setVisible(false)
  self.btn:addTo(self)
 
  self.effect = display.newSprite("btn_leader_effect.png")
  self.effect:setVisible(false)
  self.effect:setScale(1.1)
  self.effect:addTo(self)

  if self.progress1:getPercentage() == 100 then
      self:setButtonEnabled(true)
  end
end

--[[
    启用 禁用按钮
--]]
function AngerButton:setButtonEnabled(enabled)
    self.btn:setVisible(enabled)
    self.btn:setButtonEnabled(enabled)

    if enabled then
        if self.visibleEffect then
          return
        end
    
        local action = cc.RepeatForever:create(cc.RotateBy:create(3,360))
        self.effect:runAction(action)
        self.effect:setVisible(enabled)
        self.visibleEffect = true
    else
        self.effect:stopAllActions()
        self.effect:setVisible(enabled)
        self.visibleEffect = false
    end
end

function AngerButton:onButtonClicked(callback)
   	self.btn:onButtonClicked(callback)
end

--[[
   变身前怒气进度
--]]
function AngerButton:onUpdateAnger1(role,anger,maxAnger)
	self.progress1:setPercentage(anger * 1.0 / maxAnger * 100)
	if self.progress1:getPercentage() == 100 then
      self:onGuideBegin()
		  self:setButtonEnabled(true)

		  if role.auto then
			    self:doClick()
		  end
	end
end

--[[
  变身后怒气进度
--]]
function AngerButton:onUpdateAnger2(role,anger,maxAnger)
    self:setButtonEnabled(false)
	  self.progress2:setPercentage(anger * 1.0 / maxAnger * 100)
	  --todd 如果变身角色正在释放技能，得把这个变身结束事件推迟到释放完这个技能后
	  if self.progress2:getPercentage() == 0 then
    		role.model.anger = role.model.maxAnger
    		self.progress2:setPercentage(100)
    		self:setEvolveMode(false)
  		  --发送技能特效开启事件
   	    BattleEvent:dispatchEvent({
      			name    = BattleEvent.EVOLVE_END,
      			sender  = self.role,
       		 })
  	end
end

--[[
  设置变身模式 根据不同模式显示不同的进度条
--]]
function AngerButton:setEvolveMode(mode)
	if mode then
		self.progress2:setVisible(true)
		self.progress1:setVisible(false)
	else 
		self.progress2:setVisible(false)
		self.progress1:setVisible(true)
	end

  if self.onEvolveMode ~= nil then
      self.onEvolveMode(mode)
  end
end

--[[
   触发按钮click事件
--]]
function AngerButton:doClick()
    local pt = self.btn:convertToWorldSpace(cc.p(0,0))
    self.btn:dispatchEvent({
        name = self.btn.CLICKED_EVENT,
        touchInTarget = true,
        target = self.btn,
        x = pt.x + 5,
        y = pt.y + 5,
    })
end

--[[
  新手引导开始使用
--]]
function AngerButton:onGuideBegin()
   
   if not self.guide then
      return
   end

   if self.guideBegin or self.guideEnd then
      return
   end

  self.guideBegin = true

   --发送技能特效开启事件
   BattleEvent:dispatchEvent({
      name   = BattleEvent.GUIDE_BUTTON,
      sender = self,
      text   = GameConfig.tutor_talk["4"].talk
   })
end

--[[
  新手引导使用后
--]]
function AngerButton:setGuideEnd()
    if not self.guide then
        return
    end
    
    if self.guideEnd then
       return
    end

    self.guideBegin = true
    self.guideEnd = true
end


return AngerButton