--[[
    宝藏系统
]]

local BasicScene = import("..ui.BasicScene")
local CoinScene = class("CoinScene", BasicScene)

local CoinLayer = import("..views.coin.CoinLayer")
local MenuNode = import("..views.main.MenuNode")
local BuyCoinItemLayer = import("..views.coin.BuyCoinItemLayer")
local GafNode = import("app.ui.GafNode")

local TAG = "CoinScene"
local bgImageName = "Background_coin.jpg"

function CoinScene:ctor()
	CoinScene.super.ctor(self,TAG)

    -- 按钮层
    app:createView("widget.MenuLayer", {wealth="coin"}):addTo(self):zorder(10)
    :onBack(function(layer)
        self:pop()
    end)

	self:createBackground()
	self:createMenuNode()
	self:createEnterLayer()

end

function CoinScene:createBackground()
    local bgSprite = display.newSprite(bgImageName)
    bgSprite:setPosition(display.cx,display.cy)
    self:addChild(bgSprite)
end

function CoinScene:createMenuNode()
	local menuNode = MenuNode.new()
    menuNode:setPosition(display.width-60,50)
    menuNode:setHorBtnVisible(false)
    self:addChild(menuNode,4)
end

function CoinScene:createEnterLayer()
	self.coinLayer = CoinLayer.new()
	self:addChild(self.coinLayer)
    self.coinLayer.delegate = self
end

function CoinScene:createBuyItemLayer(itemData)
    self.itemLayer = BuyCoinItemLayer.new(itemData)
    self.itemLayer:addTo(self, 10)
    self.itemLayer.delegate = self
end

function CoinScene:removeBuyLayer()
    if self.itemLayer then
        self.itemLayer:removeFromParent()
        self.itemLayer = nil
    end
end

function CoinScene:netCallback(event)
    local data = event.data
    local order = data.order
    if order == OperationCode.NavigateProcess then  -- 寻宝
        if data.param1 == 1 then        -- 航行一次
            self.coinLayer.findLayer:updateData()
            self.coinLayer.findLayer:startRecTimer()
            self.coinLayer.findLayer:updateView()

            self.coinLayer:showCardAnimation(function()
                hideMask()
                self.coinLayer.findLayer:createTripAnimation()
                app:pushToScene("CoinResultScene")
            end)
        elseif data.param1 == 10 then    -- 航行十次
            self.coinLayer:showCardAnimation(function()
                hideMask()
                self.coinLayer.findLayer:createTripAnimation()
                app:pushToScene("CoinResultScene")
            end)
        end
    elseif order == OperationCode.DecomposeProcess then  -- 分解物品
        UserData:showReward({{itemId = "15", count = self.coinLayer.decomposeLayer.counts, name = "黄金碎片"}})
        self.coinLayer.decomposeLayer:updateData()
        self.coinLayer.decomposeLayer:updateView()
    elseif order == OperationCode.ShowExchangeItemsProcess then  -- 兑换物品显示数据
        self.coinLayer.exchangeLayer:setVisible(true)
        self.coinLayer.exchangeLayer:updateData()
        self.coinLayer.exchangeLayer:updateView()
    elseif order == OperationCode.BuyShopGoodsProcess then  -- 黄金碎片兑换物品
        showToast({text = "兑换成功！"})
    end
end

function CoinScene:updateData()
    self.coinLayer:updateData()
end

function CoinScene:updateView()
    self.coinLayer:updateView()
end

function CoinScene:onEnter()
    if self.coinLayer.findLayer then
        self.coinLayer.findLayer.nextFreeTrip = CoinData.nextCoinTimeStamp - UserData.curServerTime
        self.coinLayer.findLayer:startRecTimer()
    end

    self:updateData()
    self:updateView()

    self.netEvent = GameDispatcher:addEventListener(EVENT_CONSTANT.NET_CALLBACK,handler(self,self.netCallback))
end

function CoinScene:onExit()
    if self.coinLayer.findLayer then
        self.coinLayer.findLayer:removeRecTimer()
    end
	GameDispatcher:removeEventListener(self.netEvent)
end

return CoinScene