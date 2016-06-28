local UnionCreateLayer = class("UnionCreateLayer",function ()
	return display.newNode()
end)

local UnionIconListLayer = import(".UnionIconListLayer")
local nameInput = "Union_Find_Bg.png"
local iconInput = "Union_Icon.png"

function UnionCreateLayer:ctor()
    self:initData()
    self:initView()
end

function UnionCreateLayer:initData()
	self.unionName = ""
	self.unionIcon = "union001.png"
	self.unionCost = GameConfig.ConsortiaInfo["1"].Consortiaestablishcost
end

function UnionCreateLayer:initView()
	 -- 公会名称
	display.newTTFLabel({text = "公会名称:",color = cc.c3b(252, 242, 181),size = 22}):pos(205,320):addTo(self)
	self:initInputView()
	display.newSprite("Union_Line.png"):pos(405,270):addTo(self)

	-- 公会图标
	display.newTTFLabel({text = "公会图标:",color = cc.c3b(252, 242, 181),size = 22}):pos(205,215):addTo(self)
	self.iconInput = display.newSprite(self.unionIcon):pos(355,215):addTo(self)

	CommonButton.yellow("修改", {size = 22,color = cc.c3b(252, 242, 181)})
	:onButtonClicked(function()
		self.delegate.delegate:createUnionIconLayer()
	end)
	:pos(655,220):addTo(self)
    display.newSprite("Union_Line.png"):pos(405,160):addTo(self)

	-- 创建花费
	display.newTTFLabel({text = "创建花费:",color = cc.c3b(252, 242, 181),size = 22}):pos(205,100):addTo(self)
	display.newSprite("Union_Price_Bg.png"):pos(385,100):addTo(self)
	display.newSprite("Diamond60.png"):pos(330,100):scale(0.5):addTo(self)

	base.Label.new({text = self.unionCost, size=22,border = false,shadow = 1})
	:align(display.CENTER)
	:addTo(self)
	:pos(400, 100)

	CommonButton.yellow("创建公会", {size = 22,color = cc.c3b(252, 242, 181)})
	:onButtonClicked(function ( )
		if self.unionName == "" then
			showToast({text = "公会ID不能为空！"})
		else
			if UserData.diamond < self.unionCost then
				app:pushToScene("RechargeScene")
			else
				if self.textName then
					self.textName:removeFromParent()
					self.textName = nil
				end
				AlertShow.show2("提示", string.format("是否花费%d钻创建公会（会长连续七天未上线后，系统自动将会长职位转移给其他成员）", self.unionCost)
					, "确定", function(event)
			            self:createUnion()
			        end, function()
				        self:initInputView()
			        end)
			end
		end

	end)
	:pos(655,100)
	:addTo(self)
end

--控制输入框显示
function UnionCreateLayer:setInputVisible(b)
	self.textName:setVisible(b)
end

function UnionCreateLayer:updateUnionIcon(index)
	self.unionIcon = self.delegate.delegate.unionIconLayer.data[index]
	self.iconInput:setTexture(self.unionIcon)
end

-- 输入公会名
function UnionCreateLayer:initInputView()
		-- 	-- 输入框监听
	local function onEdit(event, editbox)
	    if event == "began" then
	    elseif event == "changed" then
	        local _text = editbox:getText()
			self.unionName = _text

			local _trimed = string.trim(_text)
			_trimed = parseString(_trimed, 12, 2)
			if _trimed ~= _text then
			    editbox:setText(_trimed)
			end

	    elseif event == "ended" then
	        -- 输入结束
	    elseif event == "return" then
	        -- 从输入框返回
	    end
	end

	local textBack = display.newScale9Sprite(nameInput)
	-- textBack:setOpacity(100)
	self.textName = cc.ui.UIInput.new({
	    UIInputType = 1,
	    image = textBack,
	    size = cc.size(250, 35),
	   	x = 80,
	    y = 80,
	    listener = onEdit,
	}):addTo(self,5)
	:pos(425,320)
	:align(display.CENTER)
	self.textName:setPlaceHolder("在此输入公会名")
	self.textName:setMaxLength(10)

end

function UnionCreateLayer:createUnion()
	NetHandler.gameRequest("CreateUnion",{param1 = self.unionName, param2 = self.unionIcon})
end

return UnionCreateLayer