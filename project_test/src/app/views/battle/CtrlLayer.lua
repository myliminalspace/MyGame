--
-- Author: zsp
-- Date: 2015-06-18 15:24:48
--
--[[
  角色移动控制按钮层  
--]]

local CtrlButton = import(".CtrlButton")

local CtrlLayer = class("CtrlLayer",function()
    return display.newLayer()
end)


function CtrlLayer:ctor(params)

	--操作模式，0屏幕触摸 1 按键
  self.model    = params.model or 1
  self.ctrlNode = params.ctrlNode
  self.guide    = false
  self.isLock = false
  
  if params.guide and params.guide.move then
      self.guide = true
  end

  --self:setNodeEventEnabled(true)

  self:setTouchEnabled(true)
 
	if self.model == 0 then
	   
      --todo onExit时删除事件
      self:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
      self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouchEvent))
	else
		  local panel = display.newSprite("ctrl_panel.png")
      panel:setPosition(160,70)
      panel:addTo(self)

      local size = panel:getContentSize()

      self.btnR = CtrlButton.new("ctrl_button.png",{
        ["name"] = "btn R"
        })
      self.btnR:setPosition(size.width + 30,size.height * 0.5)
      self.btnR:addTo(panel)
      self.btnR:onButtonEvent(function(btn)
          if btn.state == "press" then
              if not self:isCtrl() then
                return false
              end

              if self.delegate then
                  self.delegate:delMoveGuide()
              end

              self.ctrlNode.isForward = true
              self.ctrlNode:doWalk()
              self.btnR:stopAllActions()
              self.btnR:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1.3),cc.ScaleTo:create(0.05,1)))
          end

          if btn.state == "release" then
              if not self:isCtrl() then
                  return false
              end
              self.ctrlNode:doIdle()
          end
      end)
     

      self.btnL = CtrlButton.new("ctrl_button.png",{
          ["name"] = "btn L"
      })
      self.btnL:setScaleX(-1)
      self.btnL:setPosition(-30,size.height * 0.5)
      self.btnL:addTo(panel)
      self.btnL:onButtonEvent(function(btn)
          if btn.state == "press" then
            -- printInfo("左边按钮 press")
                if not self:isCtrl() then
                  return false
                end

                self.ctrlNode.isForward = false
                self.ctrlNode:doWalk()
                self.btnL:stopAllActions()
                self.btnL:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,-1.3,1.3),cc.ScaleTo:create(0.05,-1,1)))

          end

          if btn.state == "release" then
              --printInfo("左边按钮 release")
              if not self:isCtrl() then
                  return false
              end

              self.ctrlNode:doIdle()
          end
      end)

      self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            -- event.name 是触摸事件的状态：began, moved, ended, cancelled
            -- event.x, event.y 是触摸点当前位置
            -- event.prevX, event.prevY 是触摸点之前的位置
             --printf("sprite: %s x,y: %0.2f, %0.2f", event.name, event.x, event.y)

            -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
            -- 则必须返回 true

            self.btnL:onTouch_(event)
            self.btnR:onTouch_(event)

            if event.name == "began" then
                return true
            end
        end)
	end

end

--[[
	是否能控制
--]]
function CtrlLayer:isCtrl()
	if self.ctrlNode == nil or 
      self.ctrlNode.auto == true or 
      self.ctrlNode:isActive() == false or 
      -- todo 替补队员上场时暂停 抬手会让队长继续移动 先忽略这个
      --self.ctrlNode.isPaused == true or
      self.ctrlNode.disabled == true or
      self.ctrlNode.skillLock == true or
      self.isLock then
    	return false;
    end
    return true
end

function CtrlLayer:onTouchEvent(event)
    if table.nums(event.points) == 0 then
        return false
    end

   	if not self:isCtrl() then
   		  return false
   	end
   	local tb = table.values(event.points)
    local point = tb[#tb]
    if event.name == "began" then
        if point.x > display.width * 0.5 then
    		    self.ctrlNode.isForward = true
    	  else
    		    self.ctrlNode.isForward = false
    	  end
    	  self.ctrlNode:doWalk()
        return true
    elseif event.name == "added" then
        if point.x > display.width * 0.5 then
            self.ctrlNode.isForward = true
        else
            self.ctrlNode.isForward = false
        end
        self.ctrlNode:doWalk()
    elseif event.name == "ended" then
    	  self.ctrlNode:doIdle()
    elseif event.name == "cancelled" then
        self.ctrlNode:doIdle()
    end
end

return CtrlLayer