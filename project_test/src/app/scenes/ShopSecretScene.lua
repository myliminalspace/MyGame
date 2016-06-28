-- --[[
-- 神秘商店
-- ]]
local BasicScene = import("..ui.BasicScene")
local ShopSecretScene = class("ShopSecretScene", BasicScene)

local MenuNode = import("..views.main.MenuNode")
local UserResLayer = import("..views.main.UserResLayer")
local ShopItemLayer = app:getView("shop.ShopItemLayer")

local backImage = "Return.png"
local backImage2 = "Return_Light.png"

function ShopSecretScene:ctor()
	ShopSecretScene.super.ctor(self)
	self:createBackground()

	local menuNode = MenuNode.new()
    menuNode:setPosition(display.width-60,50)
    menuNode:setHorBtnVisible(false)
    self:addChild(menuNode,4)

    local resLayer = UserResLayer.new(3)
    resLayer:setPosition((display.width-760)/2,display.height-55)
	self:addChild(resLayer,5)

	self:createBackBtn()

    self:initData()
    self:initView()

end

function ShopSecretScene:createBackground()

    CommonView.background()
    :addTo(self)
    :center()

    local colorLayer = display.newColorLayer(cc.c4b(0,0,0,150))
    self:addChild(colorLayer)

end

function ShopSecretScene:createBackBtn()
	local backBtn = cc.ui.UIPushButton.new({normal = backImage, pressed = backImage2})
    :onButtonClicked(function ()
        AudioManage.playSound("Back.mp3")
        app:popToScene()
    end)
    self:addChild(backBtn,4)

    local posX = display.width - 55
    local posY = display.height - 45
    backBtn:setPosition(posX,posY)
end

function ShopSecretScene:initData()
    self.data = {}
end

function ShopSecretScene:initView()
    local layer_ = display.newLayer():size(960, 640):pos(display.cx,display.cy):align(display.CENTER):addTo(self)

    display.newSprite("ShopSecret_Bg.png")
    :addTo(layer_)
    :pos(440, 313)
    :zorder(2)

--------------------------------------------------------

    -- 商品列表
    self.listView_ = base.GridView.new({
        rows = 2,
        viewRect = cc.rect(0, 0, 750, 420),
        direction = "horizontal",
        itemSize = cc.size(180, 210),
    }):addTo(layer_)
    :setBounceable(false)
    :pos(60, 55)
    :zorder(2)
    :onTouch(function(event)
        if event.name == "clicked" then
            local index = event.itemPos
            if index then
                CommonSound.click() -- 音效

                self:selectedIndex(index)
            end
        end
    end)

    if VipData:isTreeShopOpen() then
        -- 下次刷新
        display.newSprite("Word_Shop_NextTime.png"):addTo(layer_)
        :pos(100, 487)
        :zorder(2)

        self.refreshTime_ = base.Label.new({
            color = display.COLOR_GREEN,
            size = 18,
        }):addTo(layer_)
        :pos(190, 486)
        :zorder(2)
    elseif UserData:getSecretTime() > UserData:getServerSecond() then

        base.Label.new({
         text = "剩余时间:",
         color = display.COLOR_YELLOW,
         size = 18,
        }):addTo(layer_)
        :pos(40, 489)
        :zorder(2)

        self.lastTime_ = base.Label.new({
            text = "",
            color = display.COLOR_GREEN,
            size = 18,
        }):addTo(layer_)
        :pos(150, 489)
        :zorder(2)

        self:schedule(function()
            self:updateTimeShow()
        end, 0.2)
    end


    -- 刷新按钮
    self.refreshBtn_ = CommonButton.red()
    :add(display.newSprite("Word_Shop_Refresh.png"))
    :addTo(layer_)
    :pos(750, 505)
    :zorder(2)
    :onButtonClicked(function(event)
        CommonSound.click() -- 音效

        print("刷新")
        local msg = {
            base.Label.new({text="是否花费"}):pos(30, 100),
            base.Label.new({text=string.format("x%d刷新商品", self.data.value)}):pos(200, 100),
            display.newSprite(self.data:getRefreshIcon()):pos(165, 100),
        }

        AlertShow.show2("提示", msg, "确定", function()
            self:refreshShop()
        end)
    end)

-- --------------------------------------------------------
-- --------------------------------------------------------

    -- 物品弹出信息
    self.shopItemLayer_ = ShopItemLayer.new()
    :addTo(self)
    :zorder(11)
    :onOk(function(item)
        print("ok")
        self:willBuyIndex(item:getIndex())
    end)
    :onCancel(function(item)
        print("cancel")
        item:hide()
    end)
    :hide()
end

-- 更新时间显示
function ShopSecretScene:updateTimeShow()
    local nowTime = UserData:getServerSecond()
    local date = convertSecToDate(UserData:getSecretTime() - nowTime)

    local timestring = string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)

    if date.hour <= 0 and date.min <= 0 and date.sec <= 0 then
        self.lastTime_:setString("00:00:00")
        app:popScene()
    else
        self.lastTime_:setString(timestring)
    end

end

function ShopSecretScene:updateListView()
    self.listView_
    :removeAllItems()
    :addItems(#self.data.items, function(event)
        local index = event.index
        local data = self.data.items[index]
        local grid = base.Grid.new({type=1})
            :setBackgroundImage(display.newSprite("Banner_Goods.png"):pos(7, 5))
            :setSelectedImage("Sold_Out.png", 6)
        self:setGridShow(grid, data)

        return grid
    end)
    :reload()
end

function ShopSecretScene:updateView()
    if VipData:isTreeShopOpen() then
        self:setRefreshTime(self.data.timeStr)
        if self.lastTime_ then
            self.lastTime_:removeFromParent()
            self.lastTime_ = nil
        end
    end
    self:updateListView()
end

function ShopSecretScene:updateData()
    self.data = ShopList:getShop("secret")
end

function ShopSecretScene:setGridShow(grid, data)
    grid:addItems({
        UserData:createItemView(data.itemId, {tips=false}):pos(0, 25):scale(0.8),
        display.newSprite(data:getSellIcon()):pos(-32, -36):scale(0.6),
        base.Label.new({text = tostring(data.price), size=18}):pos(10, -36):align(display.CENTER),
        display.newSprite("Shop_Goods_Name.png"):pos(0, -88),
        base.Label.new({text = data.name, color = UserData:getItemColor(data.itemCfg), size=20}):pos(0, -88):align(display.CENTER)
        })
    if data.count > 1 then
        grid:addItems({
            display.newSprite("Banner_Level.png"):pos(34, -6):scale(0.7),
            base.Label.new({text = tostring(data.count), size=18})
                :align(display.CENTER):pos(34, -6),
        })
    end

    if data.sale ~= 0 then
        grid:addItems({
            display.newSprite(string.format("sale_%d.png", tonumber(data.sale))):pos(37, 54),
        })
    end

    grid:setSelected(not data:isSelling())
end

function ShopSecretScene:selectedIndex(index)
    local data = self.data.items[index]
    if data.sell then
        self.shopItemLayer_:show()
        :setIndex(index)
        :setTitle(data.name, UserData:getItemColor(data.itemCfg))
        :setHave(data.have)
        :setDescription(data.desc)
        :setIcon(UserData:createItemView(data.itemId, {tips=false}))
        :setItemNum(data.count)
        :setPrice(data.price)
        :setPriceUnit(data:getSellIcon())
    end
end

function ShopSecretScene:setRefreshTime(txt)
    self.refreshTime_:setString(txt)
end

function ShopSecretScene:willBuyIndex(index)
    local data = self.data.items[index]
    local shopIndex = 7
    NetHandler.request("BuyShopGoods", {
        data = {
            param1  = data.id,
            param2  = index-1,
            param3  = shopIndex,
        },
        onsuccess = function()
        end
    }, self)
end

function ShopSecretScene:didBuyItem()
    showToast({text="购买成功"})
    self.shopItemLayer_:hide()
end

function ShopSecretScene:refreshShop()
    local shopIndex = 7
    NetHandler.request("HandRefreshShop", {
        data = {param1=shopIndex},
        onsuccess = function()
            self:updateData()
            self:updateView()
        end
    }, self)
end

function ShopSecretScene:onEnter()
    self:updateData()
    self:updateView()
    self:addUpdateListener()

    self.netEvent = GameDispatcher:addEventListener(EVENT_CONSTANT.NET_CALLBACK,handler(self,self.netCallback))

end

function ShopSecretScene:netCallback(event)
    local data = event.data
    local order = event.order
    if order == OperationCode.BuyShopGoodsResponse then
        if data.result == 1 then
            self:updateView()
            self:didBuyItem()
        elseif data.result == 5 then
            local shopIndex = 7
            NetHandler.request("OpenShop",{
                data = {param1=shopIndex},
                onsuccess = function()
                    self:updateData()
                    self:updateView()
                end
            }, self)
        end
    end
end

function ShopSecretScene:addUpdateListener()
    local listenerName = self:autoRefreshListenerName()
    if listenerName then
        local shopIndex = 7
        self.handlerRefresh = UserData:addEvent(listenerName, function()
            NetHandler.request("OpenShop",{param1=shopIndex})
        end)
    end
end
-- 商店 到时间 刷新了 的检测
function ShopSecretScene:autoRefreshListenerName()
    return nil
end

function ShopSecretScene:onExit()
    GameDispatcher:removeEventListener(self.netEvent)
    UserData:removeEvent(self.handlerRefresh)
end

return ShopSecretScene