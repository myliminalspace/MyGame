local HeroSkillLayer = class("HeroSkillLayer",function ()
	return display.newNode()
end)

local HeroInsertLayer = import(".HeroInsertLayer")
local SkillUpNode = import(".SkillUpNode")
local NodeBox = import("app.ui.NodeBox")
local HeroUpLayer = import(".HeroUpLayer")

local bgImage = "bg_002.png"
local wordImage = "Skill_Plus%d.png"
local awakeImage = "AwakeStone%d.png"
local frameImage = "AwakeStoneCircle.png"
local lockImage = "Lock_Another.png"
local arrowImage = "Skill_Arrow.png"
local upArrowImage = "tip_arrow_green.png"
local boardImage = "Skill_Shading.png"

local BUTTON_ID = {
    BUTTON_STONE_5 = 5,
    BUTTON_STONE_1 = 1,
    BUTTON_STONE_2 = 2,
    BUTTON_STONE_3 = 3,
    BUTTON_STONE_4 = 4,
    BUTTON_STONE_6 = 6,
    BUTTON_AWAKE = 7,
    BUTTON_AWAKE_1 = 8,
}

function HeroSkillLayer:ctor(hero)
	self.hero = hero
	self.skillNode = {}

	self:createBoard()

	local skillUpView = self:createSkillUpView()
	skillUpView:setPosition(578,365)
	self:addChild(skillUpView)

	local btnCallBack = handler(self,self.buttonEvent)
	if self.hero.starLv >= NAME_MAX_LEVEL then
		self.currentStrengthIcon = self:createStrengthIcon(NAME_MAX_LEVEL-1)
		self.word1 = display.newSprite(string.format(wordImage,NAME_MAX_LEVEL-1))
		self.nextStrengthIcon = self:createLockBtn(NAME_MAX_LEVEL)
		self.word2 = display.newSprite(string.format(wordImage,NAME_MAX_LEVEL))
	else
		self.currentStrengthIcon = self:createStrengthIcon(self.hero.starLv)
		self.word1 = display.newSprite(string.format(wordImage,self.hero.starLv))
		self.nextStrengthIcon = self:createLockBtn(self.hero.starLv+1)
		self.word2 = display.newSprite(string.format(wordImage,self.hero.starLv+1))
	end
	self.currentStrengthIcon:addChild(self.word1,2)
	self.nextStrengthIcon:addChild(self.word2,2)

	self.currentStrengthIcon:onButtonClicked(btnCallBack)
    self.currentStrengthIcon:setTag(BUTTON_ID.BUTTON_AWAKE_1)
	self.currentStrengthIcon:setPosition(71,62)
	self.board:addChild(self.currentStrengthIcon)

	self.nextStrengthIcon:setPosition(731,62)
	self.board:addChild(self.nextStrengthIcon)

	self.lockSprite = display.newSprite(lockImage)
	self.nextStrengthIcon:addChild(self.lockSprite,4)

	if self.hero.starLv >= NAME_MAX_LEVEL then
		local file = "Skill%d.png"
		local image = string.format(file,self.hero.starLv)
		self.nextStrengthIcon:setButtonImage("normal",image)
		self.nextStrengthIcon:setButtonImage("pressed",image)
		self.lockSprite:setVisible(false)
	end

	self:createStoneView()
end

function HeroSkillLayer:createBoard()
	local bgSprite = display.newSprite(bgImage)
	bgSprite:setPosition(438,336)
	self:addChild(bgSprite)

	self.board = display.newSprite(boardImage)
	self.board:setPosition(438,92)
	self:addChild(self.board)

    self.awakeProgress = cc.ProgressTimer:create(display.newSprite(arrowImage))
    self.awakeProgress:setType(1)
    self.awakeProgress:setPosition(398,15)
    self.awakeProgress:setMidpoint(cc.p(0,1))
    self.awakeProgress:setBarChangeRate(cc.p(1, 0))
    self.board:addChild(self.awakeProgress)
end

function HeroSkillLayer:createSkillUpView()
	local count = #self.hero.skills
	for i=1,count do
		local node = SkillUpNode.new(self.hero,i)
		node.delegate = self
		table.insert(self.skillNode,i,node)
	end

	local nodeBox = NodeBox.new()
	nodeBox:setCellSize(cc.size(115,380))
	nodeBox:setSpace(15,0)
	nodeBox:setUnit(count)
	nodeBox:addElement(self.skillNode)
	return nodeBox
end

function HeroSkillLayer:updateUpStatus()
	for i=1,#self.skillNode do
		self.skillNode[i]:setUpStatus()
	end
end

--技能强化icon
function HeroSkillLayer:createStrengthIcon(lv)
	local file = "Skill%d.png"
	local image = string.format(file,lv)

	local btn = cc.ui.UIPushButton.new({normal = image})

	local frameSprite = display.newSprite(frameImage)
	btn:addChild(frameSprite,3)

	return btn
end

--未解锁技能强化Icon
function HeroSkillLayer:createLockBtn(lv)
	local btnCallBack = handler(self,self.buttonEvent)
	local icon = self:createStrengthIcon(lv)
	:onButtonClicked(btnCallBack)
    icon:setTag(BUTTON_ID.BUTTON_AWAKE)
    local file = "Skill%d_Half.png"
    local image = string.format(file,lv)
	icon:setButtonImage("normal",image)
	icon:setButtonImage("pressed",image)
	return icon
end

function HeroSkillLayer:createStoneView()
	self.coinBox = NodeBox.new()
	self.coinBox:setCellSize(cc.size(85,85))
	self.coinBox:setPosition(401,75)
	self.board:addChild(self.coinBox)
end

function HeroSkillLayer:updateStoneView()
	local awakeInfo = GameConfig.skill_awake[self.hero.roleId]
	--所需材料id数组
	local key1 = string.format("SkillNameItemID%d",math.min(self.hero.starLv+1,NAME_MAX_LEVEL))
	local stoneId = awakeInfo[key1]
	--所需材料数量数组
	local key2 = string.format("SkillNameNum%d",math.min(self.hero.starLv+1,NAME_MAX_LEVEL))
	local count = awakeInfo[key2]

	local stoneBtns = {}

	for i=1,#stoneId do
		local button = cc.ui.UIPushButton.new()
		:onButtonClicked(handler(self,self.buttonEvent))
	    button:setTag(i)
		button:setScale(0.7)
		table.insert(stoneBtns,i,button)

		local countText = string.format("%d/%d",self.hero.coinNums[i],count[i])
   		local param = {text = countText,size = 26}
		local label = createOutlineLabel(param)
		label:setPosition(0,-50)
		button:addChild(label,2)

        if GamePoint.holeCanInsert(self.hero,i) then
        	local aniSprite = display.newSprite()
        	aniSprite:addTo(button,3)
        	local animation = createAnimation("coin%d.png",6,0.05)
        	transition.playAnimationForever(aniSprite,animation)
        end

		local item = ItemData:getItemConfig(stoneId[i])
		if self.hero.coinNums[i] > 0 then
			local image = string.format(awakeImage,item.configQuality)
			button:setButtonImage("normal",image)
			button:setButtonImage("pressed",image)

			local sprite = display.newSprite(item.imageName)
	   		button:addChild(sprite)
		else
			local image = string.format(awakeImage,0)
			button:setButtonImage("normal",image)
			button:setButtonImage("pressed",image)

			local sprite = display.newSprite(item.imageName,nil,nil,{class=cc.FilteredSpriteWithOne})
	   		local filters = filter.newFilter("GRAY",{0.2, 0.3, 0.5, 0.1})
	   		sprite:setFilter(filters)
	   		button:addChild(sprite)
		end
	end
	self.coinBox:cleanElement()
	self.coinBox:setUnit(#stoneId)
	self.coinBox:addElement(stoneBtns)
	self.coinBox:setChildOrder()
end

function HeroSkillLayer:createInsertView(index)
	self.insertLayer = HeroInsertLayer.new(self.hero,index)
	self.insertLayer.delegate = self
	display.getRunningScene():addChild(self.insertLayer,5)
end

function HeroSkillLayer:removeInsertView()
	self.insertLayer:removeFromParent(true)
	self.insertLayer = nil
end

function HeroSkillLayer:updateAwakeArrow()
	if GamePoint.heroInsertPercent(self.hero) < 1 or self.hero.starLv >= NAME_MAX_LEVEL then
		if self.aniSprite then
			self.aniSprite:removeFromParent(true)
			self.aniSprite = nil
		end
	else
		self.lockSprite:setVisible(false)
		--可觉醒动画
		if not self.aniSprite then
			self.aniSprite = display.newSprite()
			self.nextStrengthIcon:addChild(self.aniSprite,55)

			local animation = createAnimation("coin%d.png",6,0.05)
        	transition.playAnimationForever(self.aniSprite,animation)
		end
	end
end

function HeroSkillLayer:updateSkillView()
	self:updateUpStatus()
	self:updateStoneView()
	self.awakeProgress:setPercentage(100*GamePoint.heroInsertPercent(self.hero))
	self:updateAwakeArrow()
	if self.delegate then
		self.delegate:updatePoint(3,GamePoint.heroSkillCanUpdate(self.hero))
	end
	if self.insertLayer then
		local index = self.insertLayer.index
		local awakeInfo = GameConfig.skill_awake[self.hero.roleId]
        local key = string.format("SkillNameNum%d",math.min(self.hero.starLv+1,NAME_MAX_LEVEL))
        local needCount = awakeInfo[key][index]
        if self.hero.coinNums[index] >= needCount then
        	self:removeInsertView()
        else
			self.insertLayer:updateView()
        end
	end
end

function HeroSkillLayer:upgradeHeroName()
	if self.hero.starLv >= NAME_MAX_LEVEL then
		local file = "Skill%d.png"
		local image = string.format(file,self.hero.starLv)
		self.nextStrengthIcon:setButtonImage("normal",image)
		self.nextStrengthIcon:setButtonImage("pressed",image)

		if self.delegate then
			self.delegate.heroView:updateHeroName()
			self.delegate:updatePoint(3,GamePoint.heroSkillCanUpdate(self.hero))
		end
	else
		local file = "Skill%d.png"
		local image = string.format(file,self.hero.starLv)
		self.currentStrengthIcon:setButtonImage("normal",image)
		self.currentStrengthIcon:setButtonImage("pressed",image)

		if self.word1 then
			self.word1:removeFromParent(true)
			self.word1 = nil
		end
		self.word1 = display.newSprite(string.format(wordImage,self.hero.starLv))
		self.currentStrengthIcon:addChild(self.word1)

		local file = "Skill%d_Half.png"
		local image = string.format(file,self.hero.starLv+1)
		self.nextStrengthIcon:setButtonImage("normal",image)
		self.nextStrengthIcon:setButtonImage("pressed",image)

		if self.word2 then
			self.word2:removeFromParent(true)
			self.word2 = nil
		end
		self.word2 = display.newSprite(string.format(wordImage,self.hero.starLv+1))
		self.nextStrengthIcon:addChild(self.word2)

		self:updateStoneView()
		if self.delegate then
			self.delegate.heroView:updateHeroName()
			self.delegate:updatePoint(3,GamePoint.heroSkillCanUpdate(self.hero))
		end
		self.awakeProgress:setPercentage(0)
	end
	self:updateAwakeArrow()
	self:updateUpStatus()
end

function HeroSkillLayer:buttonEvent(event)
	AudioManage.playSound("Click.mp3")
	local tag = event.target:getTag()
    if tag == BUTTON_ID.BUTTON_STONE_1 then
    	self:createInsertView(tag)
    elseif tag == BUTTON_ID.BUTTON_STONE_2 then
    	self:createInsertView(tag)
	elseif tag == BUTTON_ID.BUTTON_STONE_3 then
    	self:createInsertView(tag)
	elseif tag == BUTTON_ID.BUTTON_STONE_4 then
    	self:createInsertView(tag)
	elseif tag == BUTTON_ID.BUTTON_STONE_5 then
    	self:createInsertView(tag)
	elseif tag == BUTTON_ID.BUTTON_STONE_6 then
    	self:createInsertView(tag)
	elseif tag == BUTTON_ID.BUTTON_AWAKE then
		if GamePoint.heroInsertPercent(self.hero) >= 1 then
			if self.hero.starLv < NAME_MAX_LEVEL then
				showLoading()
				local heroId = self.hero.roleId
				NetHandler.gameRequest("JieSuoHeroName",{param1 = heroId})
			else
				self:showHeroUpView(-1)
			end
		else
			self:showHeroUpView(-1)
		end
	elseif tag == BUTTON_ID.BUTTON_AWAKE_1 then
		self:showHeroUpView(1)
	end
end

function HeroSkillLayer:showHeroUpView(dir)
	local upLayer = HeroUpLayer.new(self.hero.starLv,self.hero.roleId,dir)
	display.getRunningScene():addChild(upLayer,5)
end

--解锁后升星特效
function HeroSkillLayer:showStarUp(callback)
	local aniSprite = display.newSprite()
	aniSprite:setScale(1.5)
	aniSprite:addTo(self.nextStrengthIcon,10)
    local animation = createAnimation("star%d.png",16,0.05)
    transition.playAnimationOnce(aniSprite, animation, true,function ()
    	if self.hero.starLv >= NAME_MAX_LEVEL then
    		self.lockSprite:setVisible(false)
    	else
    		self.lockSprite:setVisible(true)
    		self.lockSprite:setOpacity(0)
    		self.lockSprite:fadeIn(0.5)
    	end
    	if callback then
			callback()
		end
    end)
end

return HeroSkillLayer