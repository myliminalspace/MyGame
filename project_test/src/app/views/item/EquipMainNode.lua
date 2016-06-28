local EquipMainNode = class("EquipMainNode",function ()
	return display.newNode()
end)

local NodeBox = import("app.ui.NodeBox")

local maxImage = "GearLv_Max.png"
local pointImage = "Point_Red.png"
local equipBg = "equip_main_bg.png"
local awakeImage = "AwakeStone%d.png"
local personalImage = "equip_sp.png"
local lockImage = "Lock_Another.png"
local arrowImage = "tip_arrow_green.png"
local starImage1 = "equip_star1.png"
local starImage2 = "equip_star2.png"

function EquipMainNode:ctor()
	self:createEquip()
	self:createPoint()
	self:createLevel()
	self:createArrow()
	self:createStar()
	self:createNameView()
end

function EquipMainNode:createEquip()
	self.equipBtn = cc.ui.UIPushButton.new({normal = equipBg, pressed = equipBg})
	:onButtonClicked(function ()
		AudioManage.playSound("Click.mp3")
		if self.callBack then
			self.callBack()
		end
	end)
	self.equipBtn:setTouchSwallowEnabled(true)
	self:addChild(self.equipBtn)
end

function EquipMainNode:createStar()
	self.starNodes = {}
	for i=1,EQUIP_STAR_MAX do
		local star = display.newSprite(starImage2)
		star:setScale(0.5)
		self.starNodes[i] = star
	end
	local starBox = NodeBox.new()
	starBox:setPosition(60,10)
	starBox:setCellSize(cc.size(18,18))
	starBox:setSpace(0,0)
	starBox:setUnit(1)
	starBox:addElement(self.starNodes)
	self.equipBtn:addChild(starBox,2)
end

function EquipMainNode:updateNode(equip)
	self.nameLabel:setString(equip.itemName)
	if self.equipBox then
		self.equipBox:removeFromParent(true)
		self.equipBox = nil
	end
	local icon = display.newSprite(equip.imageName,nil,nil,{class=cc.FilteredSpriteWithOne})
	if equip.count == 0 then
		self.numSprite:setVisible(false)
		self.maxSprite:setVisible(false)
   		self.nameLabel:setColor(cc.c3b(96,96,96))
		local filters = filter.newFilter("GRAY",{0.2, 0.3, 0.5, 0.1})
   		icon:setFilter(filters)
   		self.equipBox = display.newSprite(string.format(awakeImage,0))
   	else
   		self:updateEquipLv(equip)
   		self:updateEquipStar(equip)
   		self.nameLabel:setColor(COLOR_RANGE[equip.quality])
   		self.equipBox = display.newSprite(string.format(awakeImage,equip.configQuality))
	end
	local posX = self.equipBox:getContentSize().width/2
	local posY = self.equipBox:getContentSize().height/2
	icon:setPosition(posX,posY)

	self.equipBox:setScale(0.7)
	self.equipBox:addChild(icon)
	self.equipBox:setPosition(5,8)
	self.equipBtn:addChild(self.equipBox)
end

function EquipMainNode:updateEquipLv(equip)
	if equip.strLevel > 0 then
		self.numSprite:setVisible(true)
	else
		self.numSprite:setVisible(false)
	end
	if equip.targetItem and equip.strLevel >= equip.levelLimit then
		self.numSprite:setVisible(false)
		self.maxSprite:setVisible(true)
	else
		self.numSprite:setString(equip.strLevel)
		self.numSprite:setVisible(true)
		self.maxSprite:setVisible(false)
	end
end

function EquipMainNode:updateEquipStar(equip)
	for i=1,equip.star do
		self.starNodes[i]:removeAllChildren(true)
		local posX = self.starNodes[i]:getContentSize().width/2
		local posY = self.starNodes[i]:getContentSize().height/2
		local star = display.newSprite(starImage1)
		star:setPosition(posX,posY)
		self.starNodes[i]:addChild(star)
	end
end

function EquipMainNode:createPoint()
	self.point = display.newSprite(pointImage)
	self.point:setPosition(38,38)
	self.point:setVisible(false)
	self.equipBtn:addChild(self.point,2)
end

function EquipMainNode:createMark()
	local markSprite = display.newSprite(personalImage)
	markSprite:setPosition(-52,40)
	self.equipBtn:addChild(markSprite)
end

function EquipMainNode:createLock()
	local posX = self.equipBox:getContentSize().width/2
	local posY = self.equipBox:getContentSize().height/2
	self.lockSprite = display.newSprite(lockImage)
	self.lockSprite:setPosition(posX,posY)
	self.equipBox:addChild(self.lockSprite)
end

function EquipMainNode:removeLock()
	if self.lockSprite then
		self.lockSprite:removeFromParent(true)
		self.lockSprite = nil
	end
end

function EquipMainNode:createArrow()
	self.arrowSprite = display.newSprite(arrowImage)
	self.arrowSprite:setPosition(35,-15)
	local seq = transition.sequence({
		cc.MoveBy:create(0.3, cc.p(0,20)),
        cc.MoveBy:create(0.3, cc.p(0,-20))
		})
	local rep = cc.RepeatForever:create(seq)
	self.arrowSprite:runAction(rep)
	self.arrowSprite:setVisible(false)
	self.equipBtn:addChild(self.arrowSprite,2)
end

function EquipMainNode:createNameView()
	self.nameLabel = createOutlineLabel({text = "",size = 20})
	self.nameLabel:setPosition(0,-48)
	self.equipBtn:addChild(self.nameLabel)
end

function EquipMainNode:createLevel()
	self.numSprite = cc.Label:createWithCharMap("number.png",11,17,48)
	self.numSprite:setPosition(-50,-28)
	self.equipBtn:addChild(self.numSprite)

	self.maxSprite = display.newSprite(maxImage)
	self.maxSprite:setPosition(-50,-28)
	self.equipBtn:addChild(self.maxSprite)
end

function EquipMainNode:showStrEffect(type_)
	if type_ == 1 then
		local aniSprite = display.newSprite()
		aniSprite:setPosition(3,12)
		aniSprite:setScale(0.7)
	    aniSprite:addTo(self.equipBtn,2)

	    local animation = createAnimation("equip_1_%02d.png",13,0.03)
	    transition.playAnimationOnce(aniSprite,animation,true)
	elseif type_ == 2 then
		local aniSprite = display.newSprite()
		aniSprite:setPosition(3,12)
	    aniSprite:addTo(self.equipBtn,2)

	    local animation = createAnimation("equip_2_%02d.png",19,0.06)
	    transition.playAnimationOnce(aniSprite,animation,true)
	end	
end

function EquipMainNode:setCallBack(func)
	self.callBack = func or function() print("no func") end
end

return EquipMainNode