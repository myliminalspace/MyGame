local TabNode = class("TabNode", function()
    return display.newNode()
end)

local STATUS = {
    NORMAL = 0,
    PRESSED = 1
}

function TabNode:ctor(param)
    self.touchEvent = param.event
    self.normalImage = param.normal
    self.pressedImage = param.pressed

    self.sprite = display.newSprite(self.normalImage)
    self:setContentSize(self.sprite:getContentSize())
    self.status = STATUS.NORMAL
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self,self.onTouch))
    self:setTouchSwallowEnabled(false)
    self:setTouchEnabled(true)
    self:addChild(self.sprite)

    if param.imageLabel then
        self.label = display.newSprite()
        self:addChild(self.label)
    else
        self.label = createOutlineLabel({text="",size = param.size or 30})
        self.label:pos(5,0)
        self:addChild(self.label)
    end
end

function TabNode:setString(text)
    self.label:setString(text)
end

function TabNode:setTextColor(color)
    self.label:setColor(color)
end

function TabNode:setTexture(tex)
    self.label:setTexture(tex)
end

function TabNode:setOpacity(opacity)
    self.label:setOpacity(opacity)
end

function TabNode:setNormalStatus()
    self.status = STATUS.NORMAL
    ResManage.loadImage(self.normalImage)
    self.sprite:setTexture(self.normalImage)
    ResManage.removeImage(self.normalImage)
end

function TabNode:setPressedStatus()
    self.status = STATUS.PRESSED
    ResManage.loadImage(self.pressedImage)
    self.sprite:setTexture(self.pressedImage)
    ResManage.removeImage(self.pressedImage)
end

function TabNode:onTouch(event)
    if event.name == "began" then
        return self:touchBegan(event)
    elseif event.name == "ended" then
        self:touchEnd(event)
    elseif event == "cancelled" then
    end
end

function TabNode:touchBegan(event)
    local  pos = {x = event.x, y = event.y}
    if self.sprite:getCascadeBoundingBox():containsPoint(pos) and self.status == STATUS.NORMAL then
        self.status = STATUS.PRESSED
        return true
    end
    return false
end

function TabNode:touchEnd(event)
    local  pos = {x = event.x, y = event.y}
    if self.sprite:getCascadeBoundingBox():containsPoint(pos) and self.status==STATUS.PRESSED then
        self.touchEvent({target = self})
    else
        self.status = STATUS.NORMAL
    end
end

return TabNode