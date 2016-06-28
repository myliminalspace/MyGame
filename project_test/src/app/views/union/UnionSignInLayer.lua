local UnionSignInLayer = class("UnionSignInLayer",function ()
	return display.newNode()
end)

local signInBg = "Union_SignIn_Bg.png"
local iconImageName = "Gold.png"
local iconImageName_ = "Summon_Diamond.png"

function UnionSignInLayer:ctor()
	self:initData()
    self:initView()
end

function UnionSignInLayer:initData()
    self.isSignIn = {}
    self.btnTable = {}
	self.arrData = {}
	local cfgs = GameConfig["ConsortiaCredit"]
    for k,v in pairs(cfgs) do
		table.insert(self.arrData, {
			id 		    = tonumber(k),
			costType    = v.CostItemID,
			costNum     = v.CostItemNum,
			getUnionExp = v.GetConsortiaExp,
			itemId      = v.GetItemID,
			itemNum     = v.GetItemNum,
			name        = v.Name
		})
	end

	table.sort(self.arrData, function(a, b)
		return a.id < b.id
	end)
end

function UnionSignInLayer:initView()
    local posX = display.cx - 265
	local posY = display.cy-50
	local addX = 260
	for i=1,#self.arrData do
		local data = self.arrData[i]
		local node = display.newNode():addTo(self):pos(posX+addX*(i-1), posY)
		display.newSprite(string.format("Union_SignIn_Bg%d.png", i)):pos(0,5):addTo(node)
		display.newSprite(string.format("Union_SignIn_Name%d.png", i)):pos(0, 220):addTo(node)

        -- 奖励物品
        local posY_ = 5
        local addY_ = -20
        createOutlineLabel({text = "公会经验+"..data.getUnionExp, size = 16}):pos(0, posY_):addTo(node)
        for i_=1,#data.itemNum do
        	local itemId = data.itemId[i_]
        	local itemNum = data.itemNum[i_]
        	self:createItem(itemId, itemNum):pos(0, posY_+addY_):addTo(node)
        end

        -- 价格
        local iconName = ""
        if data.costType == 1 then
        	iconName = iconImageName
        elseif data.costType == 2 then
        	iconName = iconImageName_
        end
		self:createPriceView(iconName,tostring(data.costNum),cc.c3b(255, 206, 85)):pos(-50,-85):addTo(node)

		local signBtn = CommonButton.yellow("签到")
		:onButtonClicked(function ( )
			if data.costType == 1 then
	        	if UserData.gold < data.costNum then
	        		app:pushToScene("RechargeScene")
	        	else
	        		if tonumber(self.isSignIn[i]) == 0 then
		        		NetHandler.gameRequest("UnionSign", {param1 = data.id})
		        	end
	        	end
	        elseif data.costType == 2 then
	        	if UserData.diamond < data.costNum then
	        		app:pushToScene("RechargeScene")
	        	else
	        		if tonumber(self.isSignIn[i]) == 0 then
		        		NetHandler.gameRequest("UnionSign", {param1 = data.id})
		        	end
	        	end
	        end
		end)
		:pos(0, -130)
		:addTo(node)
		:scale(0.8)

		table.insert(self.btnTable, signBtn)
	end
end

function UnionSignInLayer:createItem(itemId, itemNum)
    local name = ""
    local cfg = GameConfig["item"]
    for k,v in pairs(cfg) do
    	if k == itemId then
    		name = v.Name
    		break
    	end
    end
	local itemData = createOutlineLabel({text = name.."+"..itemNum, size = 16})
	return itemData
end

function UnionSignInLayer:createPriceView(image,text,color)
	local cashIcon = display.newSprite(image)
	cashIcon:setAnchorPoint(0,0.5)
	cashIcon:setScale(0.7)

	local tColor = color or cc.c3b(255,240,70)
	local priceLabel = createOutlineLabel({text = text,color = tColor,size = 24})
	priceLabel:setPosition(50,19)
	priceLabel:setAnchorPoint(0,0.5)
	cashIcon:addChild(priceLabel)

	return cashIcon
end

function UnionSignInLayer:updateData()
	self.isSignIn = UnionListData.isSignIn
end

function UnionSignInLayer:updateView()
	for i=1,#self.arrData do
		if tonumber(self.isSignIn[i]) == 0 then
	    	self.btnTable[i]:setButtonEnabled(true)
	    elseif tonumber(self.isSignIn[i]) == 1 then
	        self.btnTable[i]:setButtonEnabled(false)
	    end
	end
end

return UnionSignInLayer
