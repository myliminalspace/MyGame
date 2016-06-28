local EquipMergeLayer = class("EquipMergeLayer",function ()
	return display.newNode()
end)

local ItemDropLayer = import(".ItemDropLayer")
local MaterialNode = import(".MaterialNode")

local boxImage = "Friends_Tips.png"
local closeImage = "Close.png"
local infoImage = "Gear_Info.png"
local greenImage1 = "Button_Enter.png"
local greenImage2 = "Button_Enter_Light.png"
local greenImage3 = "Button_Gray.png"
local abilityImage = "Gear_ Attribute.png"
local titleImage = "Box_Title.png"

function EquipMergeLayer:ctor(equip)
	self.equip = equip
    self:createBackView()
    self:createTitleView()
    self:createEquipNode(equip)
    self:createMatNode()

    self.exchangeBtn = self:createBtn(384,45,GET_TEXT_DATA("TEXT_COMPOSITE"))

    local closeBtn = cc.ui.UIPushButton.new({normal = closeImage, pressed = closeImage})
	:onButtonClicked(function ()
        AudioManage.playSound("Close.mp3")
        if self.delegate then
            self.delegate:removeMergeLayer()
        end
	end)
	closeBtn:setPosition(500,390)
	self.backSprite:addChild(closeBtn)
end

function EquipMergeLayer:createBackView()
    local colorLayer = display.newColorLayer(cc.c4b(0,0,0,100))
    self:addChild(colorLayer)

    self.backSprite = display.newSprite(boxImage)
    self.backSprite:setPosition(display.cx,display.cy)
    self:addChild(self.backSprite,2)

    self.backSprite:setScale(0.3)
    local seq = transition.sequence({
        cc.ScaleTo:create(0.15, 1.15),
        cc.ScaleTo:create(0.05, 1)
        })
    self.backSprite:runAction(seq)


    local attrBack = display.newSprite(abilityImage)
    attrBack:setPosition(264,150)
    self.backSprite:addChild(attrBack)
end

function EquipMergeLayer:createTitleView()
    local titleSprite = display.newSprite(titleImage)
    titleSprite:setPosition(264,385)
    self.backSprite:addChild(titleSprite)

    local param = {text = self.equip.itemName,size = 26}
    self.nameLabel = createOutlineLabel(param)
    self.nameLabel:setPosition(140,25)
    self.nameLabel:setColor(COLOR_RANGE[self.equip.quality])
    titleSprite:addChild(self.nameLabel)
end

function EquipMergeLayer:createBtn(x,y,str)
	local button = cc.ui.UIPushButton.new({normal = greenImage1, pressed = greenImage2, disabled = greenImage3})
	:onButtonClicked(handler(self,self.mergeEquip))
	button:setPosition(x,y)
	self.backSprite:addChild(button)

	local  param = {text = str,color = display.COLOR_WHITE}
    local label = display.newTTFLabel(param)
    button:setButtonLabel(label)

    button:setButtonEnabled(GamePoint.matEnough(self.equip.itemId))

	return button
end

function EquipMergeLayer:createEquipNode(equip)
    local infoBack = display.newSprite(infoImage)
    infoBack:setPosition(264,280)
    self.backSprite:addChild(infoBack)

	local iconBg = createItemIcon(equip.itemId)
    iconBg:setPosition(40,45)
    infoBack:addChild(iconBg)

    local desLabel = display.newTTFLabel({text = equip.desc,
        size = 20,
        align = cc.TEXT_ALIGNMENT_LEFT, 
        dimensions = cc.size(260, 60)})
    desLabel:setPosition(120,75)
    desLabel:setAnchorPoint(0,1)
    infoBack:addChild(desLabel)
end

function EquipMergeLayer:createMatNode()
	local titleLabel = display.newTTFLabel({text = GET_TEXT_DATA("TEXT_MERGE_NEED"),size = 22})
	titleLabel:setPosition(110,200)
	self.backSprite:addChild(titleLabel)

	self.matNode = MaterialNode.new(self.equip.needItem,self.equip.needCount)
	self.matNode:setNodeCallback(handler(self,self.showDropLayer))
	self.matNode:setPosition(264,140)
	self.backSprite:addChild(self.matNode)
end

function EquipMergeLayer:showDropLayer(item)
    if self.dropLayer then
        if self.dropLayer.item.itemId == item.itemId then
            return
        else
            self.dropLayer:removeFromParent(true)
            self.dropLayer = nil

            self.dropLayer = ItemDropLayer.new(item)
            self.dropLayer:setPosition(display.cx,display.cy-203)
            self:addChild(self.dropLayer,1)
        end
    else
        self.dropLayer = ItemDropLayer.new(item)
        self.dropLayer:setPosition(display.cx,display.cy)
        self:addChild(self.dropLayer,1)

        transition.moveBy(self.dropLayer, {x = 0, y = -203 ,time = 0.2})
        transition.moveBy(self.backSprite, {x = 0, y = 90 ,time = 0.2})  
    end
end

function EquipMergeLayer:mergeEquip()
    AudioManage.playSound("SetGear.mp3")
	if self.delegate then
        self.delegate:mergeHeroEquip()
    end
end

function EquipMergeLayer:updateView()
    self.matNode:updateMat()
    self.exchangeBtn:setButtonEnabled(GamePoint.matEnough(self.equip.itemId))
end

return EquipMergeLayer