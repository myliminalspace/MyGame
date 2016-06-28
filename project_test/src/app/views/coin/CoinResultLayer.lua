local CoinResultLayer = class("CoinResultLayer",function()
    return display.newLayer()
end)

local BUTTON_ID = {
	BUTTON_SUMMON = 1,
	BUTTON_BACK = 2,
}

local SummonItemNode = import("app.views.summon.SummonItemNode")
local NodeBox = import("app.ui.NodeBox")

local buttonImage1 = "Award_Button.png"
local buttonImage2 = "Award_Button_Light.png"
local recordImgName = "CoinRecord.png"
local diamondImageName = "Diamond.png"

function CoinResultLayer:ctor()
    self.showIndex = 0
	self:createBtns()

	self.resultView = self:createResultView()
	self:addChild(self.resultView)

    self:updateResultView()

	self:addNodeEventListener(cc.NODE_EVENT,function(event)
        if event.name == "enter" then
            self:onEnter()
        elseif event.name == "exit" then
            self:onExit()
        end
    end)
end

function CoinResultLayer:createBtns()
    local btnEvent = handler(self,self.buttonEvent)
    self.summonBtn = cc.ui.UIPushButton.new({normal = buttonImage1, pressed = buttonImage2})
    :onButtonClicked(btnEvent)
    self.summonBtn:setTag(BUTTON_ID.BUTTON_SUMMON)

    self.cashIcon = display.newSprite()
	self.cashIcon:setPosition(-35,55)
	self.summonBtn:addChild(self.cashIcon)

	self.priceLabel = createOutlineLabel({text = ""})
	self.priceLabel:setPosition(40,19)
	self.priceLabel:setAnchorPoint(0,0.5)
	self.cashIcon:addChild(self.priceLabel)

	self.againLabel = createOutlineLabel({text = ""})
	self.summonBtn:addChild(self.againLabel)

	--返回按钮
    local backBtn = cc.ui.UIPushButton.new({normal = buttonImage1, pressed = buttonImage2})
    :onButtonClicked(btnEvent)
    backBtn:setTag(BUTTON_ID.BUTTON_BACK)

    local backLabel = createOutlineLabel({text = GET_TEXT_DATA("BACK")})
	backBtn:addChild(backLabel)

    self.nodeBoxBtn = NodeBox.new()
    self.nodeBoxBtn:setUnit(2)
    self.nodeBoxBtn:setCellSize(backBtn.sprite_[1]:getContentSize())
    self.nodeBoxBtn:setSpace(200,0)
    self.nodeBoxBtn:setPosition(display.cx,50)
    self.nodeBoxBtn:setVisible(false)
    self:addChild(self.nodeBoxBtn)
    self.nodeBoxBtn:addElement({self.summonBtn,backBtn})
end

function CoinResultLayer:createShowReward()
    if self.showIndex > 0 then
        return
    end

    local len = #CoinData.coinResult
    function showResult()
        if self.showIndex >= len then
            self.showIndex = 0
            self.nodeBoxBtn:setVisible(true)
            return
        end
        self.showIndex = self.showIndex + 1
        self.resultNodes[self.showIndex]:itemShowAnimation(showResult)
    end
    showResult()
end

function CoinResultLayer:createResultView()
	local resultNode = NodeBox.new()
	resultNode:setCellSize(cc.size(132,132))
	resultNode:setSpace(20,40)
	resultNode:setPosition(display.cx,display.cy+20)

	local len = #CoinData.coinResult
	if len > 1 then
        if len == 6 or len == 7 then
            resultNode:setUnit(33)
        else
            resultNode:setUnit(5)
        end
	else
		resultNode:setUnit(1)
	end
	return resultNode
end

function CoinResultLayer:showResult()
    if #CoinData.coinResult == 1 then
        self.resultNodes[1]:itemShowAnimation(function ()
            self.nodeBoxBtn:setVisible(true)
        end)
    else
        self:createShowReward()
    end
end

function CoinResultLayer:updateResultView()
    self.resultNodes = {}
    self.resultView:cleanElement()
	local len = #CoinData.coinResult
    for i=1,len do
        local item = CoinData.coinResult[i]
        local heroId = CoinData.heroId[i]
        local node = SummonItemNode.new(item,heroId,CoinData.coinType)
        table.insert(self.resultNodes,node)
    end
    self.resultView:addElement(self.resultNodes)
end

function CoinResultLayer:buttonEvent(event)
	local tag = event.target:getTag()

	if tag == BUTTON_ID.BUTTON_SUMMON then
		if CoinData.coinType == COIN_TYPE.COIN_TRIP then
            AudioManage.playSound("Click_Coin.mp3")
            if UserData.diamond < CoinData.coinPrice then
                local param = {text = "资金不足",size = 30,color = display.COLOR_RED}
                showToast(param)
                return
            end
            self.summonBtn:setButtonEnabled(false)
            NetHandler.gameRequest("Navigate", {param1 = 1})
	    elseif CoinData.coinType == COIN_TYPE.COIN_TRIPEX then
            AudioManage.playSound("Click_Coin.mp3")
            if UserData.diamond < CoinData.coinPriceEx then
                local param = {text = "资金不足",size = 30,color = display.COLOR_RED}
                showToast(param)
                return
            end
            NetHandler.gameRequest("Navigate", {param1 = 10})
            showMask()
		end
	elseif tag == BUTTON_ID.BUTTON_BACK then
        AudioManage.playSound("Back.mp3")
        app:popToScene()
	end
end

function CoinResultLayer:netCallback(event)
    local data = event.data
    local order = data.order
    if order == OperationCode.NavigateProcess then
        if data.param1 == 1 then
            self:updatePriceTab()
            self:updateResultView()
            self.resultNodes[1]:itemShowAnimation(function ()
                self.summonBtn:setButtonEnabled(true)
            end)
        elseif data.param1 == 10 then
            hideMask()
            self:updateResultView()
            self:createShowReward()
            self.nodeBoxBtn:setVisible(false)
        end
    end
end

function CoinResultLayer:updatePriceTab()
    local imageName = nil
    local priceText = nil
    local againText = nil
    if CoinData.coinType == COIN_TYPE.COIN_TRIP then  -- 航行一次
        if CoinData:getRecordCount() > 0 then
            print("使用永久指针")
            imageName = recordImgName
            priceText = tostring(CoinData:getRecordCount())
        else
            imageName = diamondImageName
            priceText = tostring(CoinData.coinPrice)
        end
        againText = GET_TEXT_DATA("SUMMON_AGAIN")
    elseif CoinData.coinType == COIN_TYPE.COIN_TRIPEX then   -- 航行十次
        imageName = diamondImageName
        priceText = tostring(CoinData.coinPriceEx)
        againText = GET_TEXT_DATA("SUMMON_AGAIN_TEN")
    end
    self.cashIcon:setTexture(imageName)
    self.priceLabel:setString(priceText)
    self.againLabel:setString(againText)
end

function CoinResultLayer:onEnter()
    self:updatePriceTab()
    --注册监听事件
    self.netEvent = GameDispatcher:addEventListener(EVENT_CONSTANT.NET_CALLBACK,handler(self,self.netCallback))
end

function CoinResultLayer:onExit()
    --移除监听事件
    GameDispatcher:removeEventListener(self.netEvent)
end

return CoinResultLayer