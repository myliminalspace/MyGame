--[[
    公会副本
]]

local BasicScene = import("..ui.BasicScene")
local UnionInstanceScene = class("UnionInstanceScene", BasicScene)

local MenuNode = import("..views.main.MenuNode")
local UnionInstanceRuleLayer = import("..views.union.UnionInstanceRuleLayer")
local UnionAgentLayer = import("..views.union.UnionAgentLayer")
local UnionAgentDesLayer = import("..views.union.UnionAgentDesLayer")
local UnionAgentSendLayer = import("..views.union.UnionAgentSendLayer")
local UnionAgentGainLayer = import("..views.union.UnionAgentGainLayer")

local TAG = "UnionInstanceScene"
local skyImage = "Sky_Left.png"
local backImage = "Return.png"
local backImage2 = "Return_Light.png"
local unionArenaBg =  "union_instance_bg.png"
local listImage  = "union_instance_list1.png"
local listImage_ = "union_instance_list2.png"
local listImage_3 = "union_instance_list3.png"
local pointImage = "Point_Red.png"

function UnionInstanceScene:ctor()
	UnionInstanceScene.super.ctor(self,TAG)

    self:initData()
    self:initView()
end

function UnionInstanceScene:initData()
    -- self.items_ = UnionChapterData:getEliteChapters()
end

function UnionInstanceScene:initView()
	CommonView.background()
	:addTo(self)
	:center()

	CommonView.blackLayer3()
	:addTo(self)

    -- 按钮层
    app:createView("widget.MenuLayer", {wealth="instancePower"}):addTo(self):zorder(10)
    :onBack(function(layer)
        self:pop()
    end)

	self:createMenuNode()

	self.layer_ = display.newLayer():size(960, 640):pos(display.cx,display.cy):align(display.CENTER):addTo(self)
	display.newSprite(unionArenaBg):pos(450, 300):addTo(self.layer_)

	CommonButton.yellow("规则", {color = cc.c3b(252, 242, 181), size = 24})
    :onButtonClicked(function ()
    	self:createRuleLayer()
        print("规则")
    end)
    :pos(235, 112)
    :addTo(self.layer_)

    CommonButton.yellow("雇佣兵", {color = cc.c3b(252, 242, 181), size = 24})
    :onButtonClicked(function ()
        self:createAgentLayer()
        print("雇佣兵")
    end)
    :pos(655, 112)
    :addTo(self.layer_)
    -- 雇佣兵红点
    self.agentRedPoint = display.newSprite(pointImage):pos(715, 132):zorder(11)
    self.agentRedPoint:setVisible(false)
    self.layer_:addChild(self.agentRedPoint)

    self.listView = base.ListView.new({
        viewRect = cc.rect(0, 0, 700, 363),
        itemSize = cc.size(700, 115),
        -- async = true, --异步加载
    }):addTo(self.layer_)
    :pos(100, 147)
    :onTouch(handler(self, self.touchListener))

end

function UnionInstanceScene:touchListener(event)
    if "clicked" == event.name then

    end
end

function UnionInstanceScene:createMenuNode()
	local menuNode = MenuNode.new()
    menuNode:setPosition(display.width-60,50)
    menuNode:setHorBtnVisible(false)
    self:addChild(menuNode,4)
end

-- 副本规则
function UnionInstanceScene:createRuleLayer()
	self.ruleLayer = UnionInstanceRuleLayer.new()
	self.ruleLayer:addTo(self, 10)
	self.ruleLayer.delegate = self
    self.listView:setTouchEnabled(false)
end

function UnionInstanceScene:removeRuleLayer()
    if self.ruleLayer then
        self.ruleLayer:removeFromParent()
        self.ruleLabel = nil
    end
    self.listView:setTouchEnabled(true)
end

-- 副本雇佣兵
function UnionInstanceScene:createAgentLayer()
    self.agentLayer = UnionAgentLayer.new()
    self.agentLayer:addTo(self, 10)
    self.agentLayer.delegate = self
    self.listView:setTouchEnabled(false)
end

function UnionInstanceScene:removeAgentLayer()
    if self.agentLayer then
        self.agentLayer:removeFromParent()
        self.agentLayer = nil
    end
    self.listView:setTouchEnabled(true)
    self:updateData()
    self:updateView()
end

-- 副本雇佣兵说明
function UnionInstanceScene:createAgentDesLayer()
    self.agentLayer.ownLayer.listView:setTouchEnabled(false)
    self.agentDesLayer = UnionAgentDesLayer.new()
    self.agentDesLayer:addTo(self, 10)
    self.agentDesLayer.delegate = self
end

function UnionInstanceScene:removeAgentDesLayer()
    self.agentLayer.ownLayer.listView:setTouchEnabled(true)
    if self.agentDesLayer then
        self.agentDesLayer:removeFromParent()
        self.agentDesLayer = nil
    end
end

-- 派出佣兵
function UnionInstanceScene:createAgentSendLayer()
    self.agentDesLayer = UnionAgentSendLayer.new()
    self.agentDesLayer:addTo(self, 10)
    self.agentDesLayer.delegate = self
    self.agentLayer.ownLayer.listView:setTouchEnabled(false)
end

function UnionInstanceScene:removeAgentSendLayer()
    self.agentLayer.ownLayer.listView:setTouchEnabled(true)
    if self.agentDesLayer then
        self.agentDesLayer:removeFromParent()
        self.agentDesLayer = nil
    end
    self.agentLayer:updateData()
    self.agentLayer:updateView()
end

-- 立即归队显示获得佣金
function UnionInstanceScene:createAgentGainLayer(options)
    self.agentGainLayer = UnionAgentGainLayer.new(options)
    self.agentGainLayer:addTo(self, 10)
    self.agentGainLayer.delegate = self
    self.agentLayer.ownLayer.listView:setTouchEnabled(false)
end

function UnionInstanceScene:removeAgentGainLayer()
    self.agentLayer.ownLayer.listView:setTouchEnabled(true)
    if self.agentGainLayer then
        self.agentGainLayer:removeFromParent()
        self.agentGainLayer = nil
    end
    self.agentLayer:updateData()
    self.agentLayer:updateView()
end

function UnionInstanceScene:updateData()
end

function UnionInstanceScene:updateView()
    self.listView
    :removeAllItems()
    :addItems(UnionListData:getChapterCount(), function(event)
        local index = event.index
        local data = UnionListData:getChapterData(index)
        local grid = base.Grid.new()
        self:setGridShow(grid, data, index)

        return grid
    end)
    :reload()

    -- 雇佣兵红点
    self.agentRedPoint:setVisible(UnionListData:isShowSendRedPoint() or UnionListData:isShowBackRedPoint())
end

function UnionInstanceScene:setGridShow(grid, data, index)
    grid:removeItems()
    :addItems({
        display.newSprite(listImage),
        display.newSprite("Mail_Circle.png"):scale(0.75):pos(-255, 0),
        display.newSprite(UserData.headIcon):scale(0.75):pos(-255, -3),
        display.newTTFLabel({text = data.title.."  "..data.name, color = cc.c3b(252, 242, 181), size = 24}):pos(0, 0),
        })

    if index == 1 then
        grid:addItem(display.newSprite(listImage_):pos(0, 0))

        local bth = CommonButton.yellow("进入副本", {color = cc.c3b(252, 242, 181), size = 24})
        :onButtonClicked(function ()
            -- 普通对应关卡是否开启
            if UnionListData:isNormalPass(data.rId) then
                -- 是否达到开启公会经验
                if data.openLv <= UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) then
                    app:pushToScene("UnionStageScene",false,{data})
                else
                    showToast({text = "需要公会"..data.openLv.."级开启副本"})
                end
            else
                showToast({text = "未通过普通战场第"..data.rId.."章"})
            end

        end)
        :pos(250, 0)
        :scale(0.9)

        grid:addItem(bth)

    else
        if UnionListData:isChapterPass(UnionListData:getChapterData(index-1)) and not UnionListData:isNormalPass(data.rId)then
            grid:addItem(display.newSprite(listImage_):pos(0, 0))

            local bth = CommonButton.yellow("进入副本", {color = cc.c3b(252, 242, 181), size = 24})
            :onButtonClicked(function ()
                -- 普通对应关卡是否开启
                if UnionListData:isNormalPass(data.rId) then
                    -- 是否达到开启公会经验
                    if data.openLv <= UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) then
                        app:pushToScene("UnionStageScene",false,{data})
                    else
                        showToast({text = "需要公会"..data.openLv.."级开启副本"})
                    end
                else
                    showToast({text = "未通过普通战场第"..data.rId.."章"})
                end

            end)
            :pos(250, 0)
            :scale(0.9)

            grid:addItem(bth)
        elseif UnionListData:isNormalPass(data.rId) and not UnionListData:isChapterPass(UnionListData:getChapterData(index-1)) then
            grid:addItem(display.newSprite(listImage_):pos(0, 0))

            local bth = CommonButton.yellow("进入副本", {color = cc.c3b(252, 242, 181), size = 24})
            :onButtonClicked(function ()
                -- 普通对应关卡是否开启
                if UnionListData:isNormalPass(data.rId) then
                    -- 是否达到开启公会经验
                    if data.openLv <= UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) then
                        app:pushToScene("UnionStageScene",false,{data})
                    else
                        showToast({text = "需要公会"..data.openLv.."级开启副本"})
                    end
                else
                    showToast({text = "未通过副本第"..(index-1).."章"})
                end

            end)
            :pos(250, 0)
            :scale(0.9)

            grid:addItem(bth)
        elseif UnionListData:isNormalPass(data.rId) and UnionListData:isChapterPass(UnionListData:getChapterData(index-1)) then
            grid:addItem(display.newSprite(listImage_):pos(0, 0))

            local bth = CommonButton.yellow("进入副本", {color = cc.c3b(252, 242, 181), size = 24})
            :onButtonClicked(function ()
                -- 普通对应关卡是否开启
                if UnionListData:isNormalPass(data.rId) then
                    -- 是否达到开启公会经验
                    if data.openLv <= UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) then
                        app:pushToScene("UnionStageScene",false,{data})
                    else
                        showToast({text = "需要公会"..data.openLv.."级开启副本"})
                    end
                end

            end)
            :pos(250, 0)
            :scale(0.9)

            grid:addItem(bth)
        else
            grid:addItem(display.newSprite(listImage_3):pos(0, 0))
        end
    end

end

function UnionInstanceScene:netCallback(event)
    local data = event.data
    local order = data.order
    if order == OperationCode.SendMercenaryProcess then
        self:removeAgentSendLayer()
    elseif order == OperationCode.CallBackMercenaryProcess then
        self:removeAgentGainLayer()
    end
end

function UnionInstanceScene:onEnter()
    self:updateData()
    self:updateView()
    self.netEvent = GameDispatcher:addEventListener(EVENT_CONSTANT.NET_CALLBACK,handler(self,self.netCallback))
end

function UnionInstanceScene:onExit()
	GameDispatcher:removeEventListener(self.netEvent)
    self.listener = nil
end

return UnionInstanceScene