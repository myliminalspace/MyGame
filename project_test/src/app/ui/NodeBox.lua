--
-- Created by IntelliJ IDEA.
-- User: Tiny
-- Date: 14-7-30
-- Time: 上午11:46
-- To change this template use File | Settings | File Templates.
--

BOX_ALIGNMENT = {
    ALIGNMENT_HORIZONTAL = 0,
    ALIGNMENT_VERTICAL = 1
}

local NodeBox = class("NodeBox",function()
    return display.newNode()
end)

function NodeBox:ctor()
    self.alignment = BOX_ALIGNMENT.ALIGNMENT_HORIZONTAL
    self.childen = {}
    self.unit = 1
    self.spaceX = 0
    self.spaceY = 0
    self.size = cc.size(0,0)
end

function NodeBox:setUnit(unit)
    self.unit = unit or 1
end

function NodeBox:setSpace(x,y)
    self.spaceX = x or 0
    self.spaceY = y or 0
end

function NodeBox:setCellSize(size)
    self.cellSize = size or cc.size(0,0)
end

function NodeBox:getBoxSize()
    local length = table.getn(self.childen)
    local spaceX = self.spaceX
    local spaceY = self.spaceY

    if self.alignment == BOX_ALIGNMENT.ALIGNMENT_HORIZONTAL then
        local width = self.cellSize.width * self.unit + (self.unit-1)*spaceX
        local col = math.ceil(length/self.unit)
        local height = self.cellSize.height * col + (col-1)*spaceY
        return cc.size(width,height)
    end

    if self.alignment == BOX_ALIGNMENT.ALIGNMENT_VERTICAL then
        local height = self.cellSize.height * self.unit + (self.unit-1)*spaceY
        local col = math.ceil(length/self.unit)
        local width = self.cellSize.width * col + (col-1)*spaceX
        return cc.size(width,height)
    end

    return cc.size(0,0)
end

function NodeBox:addElement(nodeTab)
    if nodeTab ~= nil then
        for i=1,#nodeTab do
            table.insert(self.childen,nodeTab[i])
        end
    end
    self:setElementPostion()
end

function NodeBox:cleanElement()
    self.childen = {}
    self:removeAllChildren(true)
end

--逆向设置子节点z轴
function NodeBox:setChildOrder()
    for i,v in pairs(self.childen) do
        local order = #self.childen - i + 1
        v:setLocalZOrder(order)
    end
end

--计算箱子中元素位置
function NodeBox:setElementPostion()
    local length = table.getn(self.childen)
    if length <= 0 then
        return
    end

    local spaceX = self.spaceX
    local spaceY = self.spaceY

--计算水平方向元素位置
    if self.alignment == BOX_ALIGNMENT.ALIGNMENT_HORIZONTAL then
        if self.unit == 33 then
            local k = 3
            for i=1,length do
                if i < 7 then
                    if i == 1 or i == 4 then
                        self.childen[i]:pos(300*math.pow(-1,i),0)
                        self:addChild(self.childen[i])
                    else
                        local posX = 150*math.pow(-1,i-1)
                        local posY = 100*(k/math.abs(k))
                        self.childen[i]:pos(posX,posY)
                        self:addChild(self.childen[i])
                        k = k-2
                    end
                else
                    self.childen[i]:pos(0,0)
                    self:addChild(self.childen[i])
                end
            end
        else
            local width = self.cellSize.width * self.unit + (self.unit-1)*spaceX
            local col = math.ceil(length/self.unit)
            local height = self.cellSize.height * col + (col-1)*spaceY
            local startX = (self.cellSize.width - width)/2
            local startY = (height - self.cellSize.height)/2

            for i=1,length do
                local x = (i-1)%self.unit
                local y = math.floor((i-1)/self.unit)
                local posX = startX + x*(spaceX+self.cellSize.width)
                local posY = startY - y*(spaceY+self.cellSize.height)
                self.childen[i]:pos(posX,posY)
                self:addChild(self.childen[i])
            end
        end
    end

--计算垂直方向元素位置
    if self.alignment == BOX_ALIGNMENT.ALIGNMENT_VERTICAL then
        local height = self.cellSize.height * self.unit + (self.unit-1)*spaceY
        local col = math.ceil(length/self.unit)
        local width = self.cellSize.width * col + (col-1)*spaceX
        local startX = (self.cellSize.width - width)/2
        local startY = (height - self.cellSize.height)/2

        for i=1,length do
            local x = math.floor((i-1)/self.unit)
            local y = (i-1)%self.unit

            local posX = startX + x*(spaceX+self.cellSize.width)
            local posY = startY - y*(spaceY+self.cellSize.height)
            self.childen[i]:pos(posX,posY)
            self:addChild(self.childen[i])
        end
    end
end

return NodeBox