PlayerData = {}

--更新游戏数据
function PlayerData.updateGameData(data)
	PlayerData.updateUserData(data)
	PlayerData.updateSealData(data)
	PlayerData.updateHeroData(data)
	PlayerData.updateUnionData(data)
	PlayerData.updateBagData(data)
	PlayerData.updateTaskData(data)
	PlayerData.updateStageData(data)
	PlayerData.updateArena(data)
	PlayerData.updateSignIn(data)
	PlayerData.updateNoti(data)
	PlayerData.updateGuide(data)
	PlayerData.updateSummonData(data.param20)
	PlayerData.updateCoinData(data)
	PlayerData.updateCity(data)
	PlayerData.updateActivity(data)
	PlayerData.updateTrial(data)
	PlayerData.updateActivityEx(data)
end

--英雄数据
function PlayerData.updateHeroData(data)
	local CharacterModel = import("app.battle.model.CharacterModel")

	local ownHeros = {}
	local unHeros = {}

	for i,v in ipairs(data.a_param1) do
		local param = PlayerData.parseHero(v)
		local hero = CharacterModel.new(param)
		hero:setHeroConfig()
		table.insert(HeroListData.heroList,hero)
		table.insert(ownHeros,v.heroID)
	end
	for k,v1 in pairs(GameConfig.Hero) do
		local isExist = false
		for i,v2 in ipairs(ownHeros) do
			if k == v2 then
				isExist = true
				break
			end
		end
		if not isExist then
			table.insert(unHeros,k)
		end
	end

	for i, v in ipairs(unHeros) do
		local heroParam = {roleId = v}

		local hero = CharacterModel.new(heroParam)
		hero:setHeroConfig()
		hero:setStarLevel(hero.initStarLv)
		table.insert(HeroListData.unActList,hero)
	end

end

-- 公会数据
function PlayerData.updateUnionData( data )
	local CharacterModel = import("app.battle.model.CharacterModel")

	if data.param36 then
    	-- 公会id
    	if data.param36.param1 then
    		UserData.unionId = data.param36.param1
    	else
    		UserData.unionId = ""
    	end

    	-- 公会签到状态
    	UnionListData:setIsSignIn(string.split(data.param36.param2, ","))

    	-- 最高工会经验
    	if data.param36.param3 then
    		UserData.unionLevel = data.param36.param3
    	else
    		UserData.unionLevel = 0
    	end

    	-- 申请人列表
    	UnionListData.applyData = {}
		if #data.param36.a_param1 > 0 then
    		for i,v in ipairs(data.param36.a_param1) do
    			UnionListData:insertApplyData({
                    userId   = v.userid,
        			name     = v.name,
        			icon     = v.headSrc,
        			exp      = tonumber(v.exp),  -- 经验
        			power    = tostring(math.ceil(v.fightPower)),  -- 战力
        			vipLevel = tostring(v.vipLevel)
    			})
    		end
    	end

        -- 雇佣兵信息
    	UnionListData.allAgentData = {}
    	if data.param36.a_param2 and #data.param36.a_param2 > 0 then
    		for i,v in ipairs(data.param36.a_param2) do
    			if v.heroID then
    				local param = PlayerData.parseHero(v)
					local hero = CharacterModel.new(param)
					hero:setHeroConfig()
					hero:setTeamId(v.ownerId)
					hero:setTeamName(v.ownerName)
					hero:setUserId(v.ownerUserId)
					hero:setSendTime(v.sendTime)
					hero:setUseTimes(v.useTimes)
					table.insert(UnionListData.allAgentData,hero)
    			end
    		end
    	end
    end
end

-- 解析服务器装备数据
function PlayerData.parseEquip(equipData)
	local GameEquip = import("app.data.GameEquip")
	local equips = {0,0,0,0,0,0}

	for i,v in ipairs(equipData or {}) do
		local param = {itemId = equipData[i].param1,id = equipData[i].param2,level = equipData[i].param3,star = equipData[i].param5}
		local equip = GameEquip.new(param)
		equips[equipData[i].param4] = equip
	end

	return equips
end
-- 解析服务器英雄数据
function PlayerData.parseHero(heroData)
	local equips = PlayerData.parseEquip(heroData.equips)
	local param = {roleId = heroData.heroID, starLv = tonumber(heroData.nameLevel), strongLv = tonumber(heroData.awakeLevel),
	exp = tonumber(heroData.exp), leaderWater = heroData.leaderWater, memberWater = heroData.memberWater,
	stones = heroData.stones, equip = equips, coins = heroData.coins, skills = heroData.skills}

	return param
end

--[[
解析服务器英雄数据
params = {
	heroId = "",
	robotId = "",
	evolve = true,
}
]]
function PlayerData.parseRobot(params)
	local cfg = params.robot -- 机器人配置数据
	local param = {
		roleId = params.heroId,
		starLv = cfg.star,
		strongLv = cfg.pz,
		level = cfg.level,
		propertyScale = cfg.roleData,
	}

	return param
end

-- 解析服务器发来的挑战队伍数据
function PlayerData.parseArenaTeam(serverData)
	local team = ArenaTeam.new({
		rank 	= serverData.ranking, 			-- 竞技场排名
		userId 	= serverData.userid, 			-- 用户id
		teamId 	= serverData.teamid, 			-- 战队id
		name 	= serverData.name, 				-- 战队昵称
		level 	= serverData.exp,  				-- 战队等级
		icon 	= serverData.headSrc, 			-- 战队头像
		battle	= serverData.param1, 			-- 战斗力（机器人用）
	})
	-- 尾兽
	local starInfo = parseTailsStar(serverData.param2) 		-- 尾兽星级信息
	local tailsList = convertTailsList(serverData.param3) 	-- 尾兽id列表

	local starList = {} 							-- 尾兽星级列表
	for i,w in ipairs(tailsList) do
		local star = tonumber(starInfo[w]) or 1
		table.insert(starList, star)
	end

	team:setTailsIdList(tailsList)
	team:setTailsStarList(starList)
	team:setSealLevel(checknumber(serverData.param4)) 		-- 封印等级

	local robotId = serverData.robotid
	local robotCfg = RobotData:getRobot(robotId)
	if robotCfg then
		team.evolveNum = robotCfg.evolveNum
	end

	local nRole = 0
	-- 队员
	for i,v in ipairs(serverData.a_param1 or {}) do
		nRole = nRole + 1
		if robotCfg then
			local param = PlayerData.parseRobot({
				heroId = v.heroID,
				robot = robotCfg,
			})

			local hero = team:createRole(param)
			hero:setSkillsLevel(math.floor(param.level / 4))
			team:addRole(hero)

		else
			local param = PlayerData.parseHero(v)
			local hero = team:createRole(param)
			team:addRole(hero)
		end
	end

	return team
end
---------------------------------------------

function PlayerData.updateUserData(data)
	UserData.teamId 	= data.teamid -- 战队id
	UserData.name 		= data.name -- 战队名
	UserData.headIcon 	= data.headSrc or DEFAULT_USER_AVATAR-- 战队头像
	UserData.isNew 		= tonumber(data.isNew) or 0
	UserData.totalExp = tonumber(data.exp) or 0
	UserData.vip 		= tonumber(data.viplevel) or 0 	-- vip等级
	UserData.diamond 	= tonumber(data.diamond) or 0	    -- 钻石
	UserData.gold 		= tonumber(data.gold) or 0		-- 金币
	UserData.power 		= tonumber(data.power) or 0		-- 体力
	UserData.cardValue 	= tonumber(data.choukaScore) or 0	-- 抽卡积分
	UserData.soul 		= tonumber(data.ling) or 0		-- 灵能值
	UserData.arenaValue = checknumber(data.jingjiGold) 	-- 竞技币
	UserData.arenaScore = checknumber(data.jingjiScore) -- 竞技积分
	UserData.cityValue 	= checknumber(data.cityGold) 	-- 城建币
	UserData.skillPoint = tonumber(data.skillPower) or 0   -- 技能点
	UserData.unionValue = tonumber(data.unionGold) or 0    -- 公会币
	UserData.coinValue  = tonumber(data.goldFragment) or 0 -- 黄金碎片
	UserData.unionPower = tonumber(data.unionPower) or 0   -- 公会副本体力
	UserData.treeValue 	= checknumber(data.treeGold) 	   -- 神树/尾兽 币
	UserData.chatSever = data.param22
	UserData.chatPort = data.param23
	UserData.skillRecoverTime = tonumber(data.param24) or 0 --恢复时间
	UserData.skillBuyTimes = tonumber(data.param25) or 0 --技能点购买次数
	UserData.powerData.buyTimes = checknumber(data.powerts) 	-- 购买体力的次数
	UserData.powerEventEndTime = tonumber(data.param31) or 0
	UserData.v5Rmb = tonumber(data.param37) or 0  -- V5福利

	if data.param18 and string.len(data.param18) > 0 then -- 队伍_主战
		UserData:setBattleList(string.split(data.param18, ","))
	else
		UserData:setBattleList(CreateInfoData.heroId)
	end

	UserData.powerRecoverTime = checknumber(data.param21) 	-- 体力开始恢复的时间点

	local sec = checknumber(data.param9) 	-- 服务器时间
	UserData.preServerTime = sec
	UserData.curServerTime = sec
	UserData.beganTime = sec
	UserData:setServerStartSecond(sec)
	UserData:setServerSecond(sec)

	local cardMsg = data.param29.param2     -- 月卡信息
    local firstCard = data.param29.param1   -- 首充状态
	if cardMsg then
		UserData:setEndTime(cardMsg)
	end
	UserData:setFirstBuy(firstCard)

	local secretOpenTime = data.param30.param2     -- 神秘商店开启时间戳
	UserData:setSecretTime(secretOpenTime)
	local isOpen = data.param30.param1
	UserData:setIsOpenSecretShop(isOpen)

    if data.vipGiftList then
    	UserData:setIsBuy(string.split(data.vipGiftList, ","))
    end

	UserData:setFirstRecharge(string.split(data.firstRechargeStatus, ","))

	if data.param33 then
		UserData:setBannerImage(string.split(data.param33, ","))
	end

    UserData.buyGrowGift = data.param35

end

--账号数据
function PlayerData.updateAccountData(data)
	UserData.myIp 		= data.param2 			-- 我的ip
	UserData.ip 		= data.param6 			-- 登陆ip
	UserData.port 		= tonumber(data.param7)	-- 上次登陆端口号
	UserData.loginTime 	= data.param3 			-- 上次登陆时间
	UserData.zoneId 	= data.param4 			-- 上次选区id
	UserData.zoneName 	= data.param5 			-- 上次选区名
	UserData.userId 	= data.param1 			-- 用户id
	UserData.token 		= data.param8
	UserData.uuid       = data.param10
	UserData.notice		= data.param11
end

--背包数据
function PlayerData.updateBagData(data)
	local GameItem = import("app.data.GameItem")
	local GameEquip = import("app.data.GameEquip")
	for i,v in ipairs(data.a_param2) do
		local config = GameConfig.item[tostring(v.param1)]
		if config.Type == 2 then
			local param = {itemId = v.param1, id = v.param2, count = v.param3, level = v.param4}
			ItemData:superimposeEquip(param)
		else
			local param = {itemId = v.param1, id = v.param1, count = v.param3}
			table.insert(ItemData.itemList,GameItem.new(param))
		end
	end
end

--抽卡数据
function PlayerData.updateSummonData(data)
	SummonData:update(data)
end

-- 宝藏寻宝冷却数据
function PlayerData.updateCoinData(data)
	if data.param38 then
		CoinData:update(data.param38)
	end
	if data.treasureTimes then
		CoinData.coinAllCounts = tonumber(data.treasureTimes)
	end
end

--任务数据
function PlayerData.updateTaskData(data)
	local param1 = data.param1  -- 任务完成度
	local param2 = data.param2 	-- 成就任务完成度
	local param3 = data.param3 	-- 已完成的每日任务id
	local param4 = data.param4 	-- 已完成的成就任务

	TaskData:resetAllDatas()

	-- 日常任务 进度
	for k,v in pairs(param1) do
		TaskData:setDailyParams_(k, tonumber(v))
	end

	-- 成就任务（商店购买物品）
	function addBuyShopItem(taskName, itemIdStr)
		if itemIdStr then
			local arr = string.split(itemIdStr, ",")
			for i,v in ipairs(arr) do
				TaskData:setShopBuyParams("taskName", v, 1)
			end
		end
	end
	addBuyShopItem(param2.shop1) -- 竞技场商店
	addBuyShopItem(param2.shop2) -- 积分商店
	addBuyShopItem(param2.shop3) -- 神树商店

	function achieveTasks(arrTaskId)
		for i,v in ipairs(arrTaskId) do
			if string.len(v) > 0 then
				local task = TaskData:getTask(v)
				task.completed = true
			end
		end
	end
	-- 已完成的每日任务id
	if param3 then
		local arr = string.split(param3, ",")
		achieveTasks(arr)
	end

	-- 已完成的成就任务
	if param4 then
		local arr = string.split(param4, ",")
		achieveTasks(arr)
	end

end

--关卡数据
function PlayerData.updateStageData(data)
	local params = data.a_param3 or {} -- 关卡信息
	local param1 = params.param3 or {}	-- 关卡完成信息（星星数）
	local param2 = params.param4 or {}	-- 领取每个章节奖励次数
	local param3 = params.param2 or {}	-- 每天 精英关卡的挑战次数
	local param4 = params.param1 or ""	-- 每天 精英关卡的购买的的“挑战次数”
	local param5 = params.param5 or {}

	ChapterData:resetAllDatas()
-------------------------
	local function splitComma(str)
		return string.split(str, ",")
	end

	local function split_(str)
		return string.split(str, "_")
	end

	local function parse_comma(str)
		local dict = {}
		local arr = splitComma(str)
		for i,v in ipairs(arr) do
			local values = split_(v)
			if table.nums(values) == 2 then
				dict[values[1]] = checknumber(values[2])
			end
		end
		return dict
	end

	-- 关卡完成信息
	for k1,v in pairs(param1) do
		if v then
			local dict = parse_comma(v)
			for k,w in pairs(dict) do
				local stage = GameConfig["Stage"][k]
				local chapter = GameConfig["Chapter"][stage.Chapter]
				if chapter.Type == 3 then
					local stageModel = require("app.model.StageModel").new()
					stageModel:addStar(tonumber(w))
					UnionListData.stageData[k] = stageModel
				else
					local stage = ChapterData:getStage(k)
					if stage then
						stage.passLevel = w
					end
				end
			end
		end
	end

	-- 领取每个章节奖励次数
	for i,v in ipairs(param2) do
		local dict = parse_comma(v)
		for k,w in pairs(dict) do
			ChapterData:setAwardNum(k, w)
		end
	end

	-- 每天 精英关卡的挑战次数
	for i,v in ipairs(param3) do
		local dict = parse_comma(v)
		for k,w in pairs(dict) do
			local stage = ChapterData:getStage(k)
			if stage then
				stage.passNum = w
			end
		end
	end

	-- 每天 精英关卡的购买的的“挑战次数”
	local dict = parse_comma(param4)
	for k,v in pairs(dict) do
		local stage = ChapterData:getStage(k)
		if stage then
			stage.buyEliteNum = v
		end
	end

	--更新工会副本次数
	for i,v in ipairs(param5) do
		local dict = parse_comma(v)
		for k,w in pairs(dict) do
			local stageModel = UnionListData.stageData[k]
			if stageModel then
				local passNum = tonumber(w)
				stageModel:addLeftTimes(-passNum)
			end
		end
	end
end

-- 尾兽
function PlayerData.updateSealData(data)
	local param1 = data.param10 	-- 封印总经验
	local param2 = data.param11 	-- 尾兽信息 （星级）
	local param3 = data.param13 	-- 尾兽出战队列

	SealData:setSealExp(checknumber(param1))

	TailsData:resetAllDatas()

	if param2 then
		local arrStar = string.split(param2, "_")
		if table.nums(arrStar) == 2 then
			local ids = string.split(arrStar[1], ",")
			local nums = string.split(arrStar[2], ",")
			for i,v in ipairs(ids) do
				if string.len(v) > 0 then
					local tails = TailsData:getTails(v)
					tails.star = checknumber(nums[i])
				end
			end
		end
	end

	if param3 and string.len(param3) > 0 then
		if string.sub(param3, -1, -1) == "," then
			param3 = string.sub(param3, 1, -2)
		end
		local ids = string.split(param3, ",")
		UserData:setTailsBattleList(ids)
	else
		UserData:setTailsBattleList({})
	end
end
-- 竞技场
function PlayerData.updateArena(data)
	local scores = data.param12 or "" 	-- 已兑换过的积分，多个以逗号分开
	local arr = string.split(scores, ",")

	ArenaScoreData:resetAllDatas()

	for i,v in ipairs(arr) do
		local rewardData = ArenaScoreData:getReward(v)
		if rewardData then
			rewardData.completed = true
		end
	end
end
-- 签到或礼包
function PlayerData.updateSignIn(data)
	local nDay = checknumber(data.param14) 	-- 七天签到天数
	local signTime = checknumber(data.param15) 	-- 七天奖励最近领取的时间
	local info = data.param19 	-- 每日签到信息

	SignInData.sevenCount = nDay
	SignInData.sevenDate = signTime

	SignInData.totalSignIn 		= checknumber(info.signTotal) 	 -- 总的签到次数
	SignInData.latestId 		= tostring(info.signId) 		 -- 最近的签到id
	SignInData.latestDate 		= checknumber(info.lastSignDay)  -- 最后一次签到的时间
	SignInData.signVip 			= checknumber(info.vipSign) == 1 -- 是否进行了vip签到
	SignInData.latestReward 	= tostring(info.lastreward) 	 -- 最后一次领取的累积奖励id

    SignInData.viplatestId      = tostring(info.lastRechargeSign) -- 最近的签到id
    SignInData.vipIsReward      = info.canGetReward               -- 是否可以领取至尊签到礼包 0充值 1领取 2领过

end
-- 消息提醒
function PlayerData.updateNoti(data)
	local params = data.param16
	local arrParam = string.split(params, ",")

	UserData:resetNoti()

	for i,v in ipairs(arrParam) do
		PlayerData.parseNoti(checknumber(v))
	end

end
-- 新手引导
function PlayerData.updateGuide(data)
	local keys = data.param17 or ""
	local arr = string.split(keys, ",")

	GuideData.dict = {}
	-- arr[1] = 1
	if checknumber(arr[1]) == 1 then
		local list = {
			"Firstbattle",
			"Fight",
			"Fight2",
			"Name",
			"Card",
			"Fight1-1",
			"Awaken",
			"Fight1-2",
			"Fight1-3",
			"Chest",
			"Activate",
			"Fight2-1",
			"Fight2-2",
			"StarUp",
			"Fight2-3",
			"experience",
			"DailyQuest",
			"Equipment",
			"EliteStage",
			"Arena1",
			"Arena2",
			"DreamBook",
			"Castle",
			"Aincrad",
			"Tails1",
			"Tails2",
			"WorldTree",
			"Equipmentsupport",
		}
		for i,v in ipairs(list) do
			GuideData:setCompleted_(v)
		end
	else
		for i,v in ipairs(arr) do
			GuideData:setCompleted_(v)
		end
	end
end

-- 城建信息
function PlayerData.updateCity(data)
	local param = data.param26 or ""

	for i,v in ipairs(string.split(param, ",")) do
		local arr = string.split(v, "_")
		if #arr == 3 then
			CityData:setCity(arr[1], arr[3])
			CityData:setCityLevel(arr[1], checknumber(arr[2]))
		end
	end
end

-- 通用任务
local function updateNormalActivity(data)
	ActivityNormalData:resetData()
	local params = data.param28 or {}
	ActivityNormalData:initDictData(params.a_param2 or {})
	ActivityNormalData:initSectionDictData(params.a_param1 or {})

	-- 已经完成
	local ids = string.split(params.param2 or "", ",")
	for i,v in ipairs(ids) do
		if string.len(v) > 0 then
			local adata = ActivityNormalData:getActivityData(v)
			if adata then
				adata:setCompleted(true)
			end
		end
	end

	-- 进度
	for k,v in pairs(params.param1 or {}) do
		if string.len(v) > 0 then
			local adata = ActivityNormalData:getActivityData(k)
			if adata then
				adata:setProcessValue(checknumber(v))
			end
		end
	end

end

function PlayerData.updateActivity(data)
	ActivityOpenData:resetData()

	local param = data.param27 or {}
	-- 开服活动信息
	local openInfo = param.param1 or {}

	local ids = string.split(openInfo.param1 or "", ",")
	for i,v in ipairs(ids) do
		if string.len(v) > 0 then
			local adata = ActivityOpenData:getActivityData(v)
			if adata then
				adata:setCompleted(true)
			end
		end
	end

	ActivityOpenData:setStartTime(checknumber(openInfo.param2))
	ActivityOpenData.received = checknumber(openInfo.param3) == 1


	-- 开服活动进度信息
	param.param2 = param.param2 or {}
	ArenaData:setRank(checknumber(param.param2["18"]))
	AincradData:setOldFloor(checknumber(param.param2["19"]))
	TreeData:setOldWin(checknumber(param.param2["20"]))

	param.param2["18"] = nil
	param.param2["19"] = nil
	param.param2["20"] = nil
	for k,v in pairs(param.param2) do
		ActivityOpenData:setParams_(checknumber(k), checknumber(v))
	end

	updateNormalActivity(data)
end

function PlayerData.updateActivityEx(data)
	if data.param34 then
		if data.param34.param1 then
			SlotModel:update(data.param34.param1)
		end
		if data.param34.param2 then
			FlopModel:update(data.param34.param2)
		end
		if data.param34.param3 then
			FeedbackModel:update(data.param34.param3)
		end
		if data.param34.param4 then
			GamblingModel:update(data.param34.param4)
		end
		if data.param34.param6 then
			DiscountShopModel:update(data.param34.param6)
		end
	end
end

function PlayerData.updateTrial(data)
	TrialData:resetLight()
	TrialData:resetHouse()
	TrialData:resetMount()

end

function PlayerData.parseNoti(value)
	if value == 1 then
		UserData:setHaveMail(true)
	end
end

--激活英雄
function PlayerData.actHero(heroID)
	HeroListData:activateHeroWithId(heroId)
end

--增加英雄经验
function PlayerData.incHeroExp(heroId,exp)
	local hero = HeroListData:getRoleWithId(heroId)
	local oldLv = hero.level
	hero.exp = GameExp.getFinalExp(hero.exp,exp)
	hero:setLevel(GameExp.getLevel(hero.exp))
	TaskData:addTaskParams("upHeroLevel",hero.level - oldLv)
end

--增加战队经验
function PlayerData.incUserExp(exp)

end

-- 更新英雄属性
function PlayerData.updateHeros()
	for k,v in pairs(HeroListData.heroList) do
		PlayerData.updateHero(v)
	end
	for k,v in pairs(HeroListData.unActList) do
		PlayerData.updateHero(v)
	end
end

-- 更新英雄属性
function PlayerData.updateHero(hero)
	hero:updateProperty()
end

--增加物品数据
function PlayerData.addItem(data)
	for i,v in ipairs(data) do
		if v.param4 == 6 then
			local heroId = tostring(v.param1)
			local hero = HeroListData:getRoleWithId(heroId)
			if hero then
				local itemId = hero.stoneId
				local count = hero.exchangeStoneNum
		    	ItemData:addMultipleItem(itemId,count)
			else
				HeroListData:activateHeroWithId(heroId)
			end
		else
			local itemId = tostring(v.param1)
			local config = GameConfig.item[itemId]
			if config.Type == 2 then
				local param = {itemId = itemId, id = v.param2}
				ItemData:superimposeEquip(param)
			elseif config.Type == 8 then
				UserData:addGold(v.param3)
			elseif config.Type == 9 then
				UserData:addDiamond(v.param3)
			elseif config.Type == 10 then
				UserData:addPower(v.param3)
			elseif config.Type == 11 then
				UserData:addSoul(v.param3)
			elseif config.Type == 12 then
				UserData:addArenaValue(v.param3)
			elseif config.Type == 13 then
				UserData:addExp(v.param3)
			elseif config.Type == 18 then
				UserData:addTreeValue(v.param3)
			elseif config.Type == 19 then
				UserData:addCityValue(v.param3)
			elseif config.Type == 21 then
				UserData:addCardValue(v.param3)
			elseif config.Type == 24 then
				UserData:addSkillPoint(v.param3)
			elseif config.Type == 26 then
				UnionListData:setUnionExp(v.param3)
			elseif config.Type == 27 then
				UserData:addUnionValue(v.param3)
			elseif config.Type == 28 then
				UserData:addUnionPower(v.param3)
			else
		    	ItemData:addMultipleItem(itemId,v.param3)
			end
		end
	end
end

function PlayerData.clean()
	SlotModel:clean()
	FlopModel:clean()
	FeedbackModel:clean()
	GamblingModel:clean()
	DiscountShopModel:clean()
	HeroListData:clean()
	NoticeData:clean()
	ItemData:clean()
	ResetTimeData:resetAll()
	SceneData:resetAll()
	ChatData:cleanData()
	UnionListData:cleanData()
end