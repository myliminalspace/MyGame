
local UserData = class("UserData")

function UserData:ctor()
	self.isNew = 0
	self.gold = 0 					-- 金币数
	self.diamond = 0 				-- 宝石数
	self.power = 0 					-- 体力值
	self.soul = 0 					-- 灵能值
	self.cardValue = 0 				-- 抽卡积分
	self.arenaValue = 0 			-- 竞技场币
	self.arenaScore = 0 			-- 竞技场积分
	self.treeValue 	= 0 			-- 神树币/尾兽币
	self.cityValue 	= 0 			-- 城建币
	self.unionValue = 0 		    -- 公会币
	self.coinValue  = 0             -- 黄金碎片
	self.skillPoint = 0				-- 技能点
	self.skillRecoverTime = 0		-- 技能点恢复时间
	self.skillBuyTimes = 0			-- 技能点购买次数
	self.chatSever = ""				-- 聊天服务器
	self.chatPort = ""				-- 端口

	self.teamId = "" 				-- 战队id
	self.name = "" 					-- 昵称
	self.vip = 0 					-- VIP经验
	self.endTime = {}                -- 月卡时间戳
	self.firstBuy = {}              -- 首充状态
	self.isBuyGift = {}    			-- VIP等级对应礼包是否购买
	self.headIcon = "" 				-- 头像
	self.totalExp = 0 				-- 战队当前总经验

	self.account = "" 				-- 账号
	self.pwd = ""					-- 密码
	self.ip = "" 					-- 登陆ip
	self.port = 80 					-- 登陆端口
	self.zoneId = "" 				-- 选区id
	self.zoneName = "" 				-- 选区 名
	self.loginTime = 0 				-- 登陆时间
	self.myIp = "" 					-- 本机ip
	self.notice = ""				-- 公告内容

	self.userId = "" 				-- 用户id
	self.token = "" 				-- 传输 标记
	self.uuid = ""					-- 用户唯一标识

	-- self.latestUpdateTime = nil 	-- 最后更新数据时间

	self.battleList = {} 			-- 战斗队列


	self.haveMail 	= false 		-- 是否有邮件

	self.beganTime = 0 				-- 开始游戏时间
	self.powerRecoverTime = 0 		-- 体力开始恢复的时间点
	self.serverOpenSecond = 0 		-- 服务器开启日期零点的秒数（秒）
	self.serverStartSecond = 0 		-- 服务器开启日期（秒）

	-- 体力恢复数据
	self.powerData = {
		next = 0, 	-- 下一点恢复倒计时
		all = 0, 	-- 全部恢复倒计时
		buyTimes = 0, -- 已购买次数
	}

	self.preServerTime = 0 			-- 上次匹配的服务器时间
	self.curServerTime = 0 			-- 当前时间
	self.serverTime = 0 			-- 服务器同步来的时间

    self.secretIsOpen = false       -- 神秘商店定时是否开启
	self.secretOpenTime = 0         -- 神秘商店定时开启时间戳
    self.secretShopTip = false      -- 神秘商店开启提示
    self.powerEventEndTime = 0 		-- 战力活动截止时间戳

    self.buyGrowGift = 0			-- 是否购买成长基金
    self.firstRecharge = {}
    self.bannerImage = {}

    self.unionId = ""               -- 公会id
    self.unionPower = 0             -- 公会体力
    self.unionPowerBuyTimes = 0	    -- 公会之战次数购买次数

    self.v5Rmb = 0                  -- v5福利

    self.unionLevel = 0             -- 公会最高经验
end

function UserData:addEvent(name, func)
	return GameDispatcher:addEventListener(name, func)
end

function UserData:removeEvent(hand)
	GameDispatcher:removeEventListener(hand)
end

function UserData:dispatchEvent(event)
	GameDispatcher:dispatchEvent(event)
end

--设置用户金币
function UserData:setGold(value)
	self.gold = value
end

--用户金币修改
function UserData:addGold(value)
	self:setGold(self.gold+value)

	-- 活动相关
	if value > 0 then
		ActivityUtil.addParams("getGold", value)
	elseif value < 0 then
		ActivityUtil.addParams("costGold", math.abs(value))
	end

	return self
end

--设置用户钻石
function UserData:setDiamond(value)
	self.diamond = value
end

--用户钻石修改
function UserData:addDiamond(value)
	self:setDiamond(self.diamond+value)

	-- 活动相关
	if value < 0 then
		ActivityUtil.addParams("costDiamond", math.abs(value))
	end

	return self
end

--设置用户体力
function UserData:setPower(value)
	self.power = value
end

--用户体力修改
function UserData:addPower(value)
	self:setPower(self.power+value)

	return self
end

--设置用户公会副本体力
function UserData:setUnionPower(value)
	self.unionPower = value
end

--用户公会副本体力修改
function UserData:addUnionPower(value)
	self:setUnionPower(self.unionPower+value)

	return self
end

-- 当前体力恢复上限
function UserData:getPowerMax()
	local value = GameConfig.user_exp[tostring(self:getUserLevel())].EnergyLimit
	return tonumber(value) or 0
end

--当前英雄等级上限
function UserData:getHeroMax()
	local value = GameConfig.user_exp[tostring(self:getUserLevel())].HeroLvLimit
	return tonumber(value) or 0
end

--设置用户灵能值
function UserData:setSoul(value)
	self.soul = value
end

--用户灵能值修改
function UserData:addSoul(value)
	self:setSoul(self.soul+value)

	return self
end

--设置用户抽卡积分
function UserData:setCardValue(value)
	self.cardValue = value
end

--用户抽卡积分修改
function UserData:addCardValue(value)
	self:setCardValue(self.cardValue+value)

	return self
end

--设置用户竞技场币
function UserData:setArenaValue(value)
	self.arenaValue = value
end

--用户竞技场币修改
function UserData:addArenaValue(value)
	self:setArenaValue(self.arenaValue+value)

	return self
end

--设置用户竞技场积分
function UserData:setArenaScore(value)
	self.arenaScore = value
end

--用户竞技场积分修改
function UserData:addArenaScore(value)
	self:setArenaScore(self.arenaScore+value)

	return self
end

--设置用户神树币
function UserData:setTreeValue(value)
	self.treeValue = value
end

--用户神树币修改
function UserData:addTreeValue(value)
	self:setTreeValue(self.treeValue+value)
	return self
end

--设置用户城建币
function UserData:setCityValue(value)
	self.cityValue = value
end

--用户城建币修改
function UserData:addCityValue(value)
	self:setCityValue(self.cityValue+value)

	return self
end

--设置工会币
function UserData:setUnionValue(value)
	self.unionValue = value
end

--用户工会币修改
function UserData:addUnionValue(value)
	self:setUnionValue(self.unionValue+value)

	return self
end

--设置黄金碎片
function UserData:setCoinValue(value)
	self.coinValue = value
end

--黄金碎片修改
function UserData:addCoinValue(value)
	self:setCoinValue(self.coinValue+value)

	return self
end

--设置工会体力
function UserData:setUnionPower(value)
	self.unionPower = value
end

--工会体力修改
function UserData:addUnionPower(value)
	self:setUnionPower(self.unionPower+value)

	return self
end

--设置用户技能点
function UserData:setSkillPoint(value)
	self.skillPoint = value
end

--用户技能点修改
function UserData:addSkillPoint(value)
	self:setSkillPoint(self.skillPoint+value)

	return
end

--设置用户技能点购买次数
function UserData:setSkillBuyTimes(value)
	self.skillBuyTimes = value
end

--用户购买技能点次数修改
function UserData:addSkillBuyTimes(value)
	self:setSkillBuyTimes(self.skillBuyTimes+value)

	return
end

-- 增加充值钱数
function UserData:addV5Rmb( rmb )
	self.v5Rmb = self.v5Rmb + rmb
end

--设置用户公会体力购买次数
function UserData:setUnionPowerBuyTimes(value)
	self.unionPowerBuyTimes = value
end

--用户购买公会体力次数修改
function UserData:addUnionPowerBuyTimes(value)
	self:setUnionPowerBuyTimes(self.unionPowerBuyTimes+value)

	return
end

--获取技能点数
function UserData:getSkillPoint()
	local limitPoint = tonumber(GameConfig.Global["1"].SkillPointLimit)
	local cycle = tonumber(GameConfig.Global["1"].SkillPointRecover)
	local dur = self.curServerTime - self.skillRecoverTime

	local point = math.floor(dur/cycle)
	if self.skillPoint >= limitPoint then
		point = self.skillPoint
	else
		point = self.skillPoint + point
		point = math.min(point,limitPoint)
	end

	return point
end

--获取技能点恢复时间
function UserData:getSkillTime()
	local limitPoint = tonumber(GameConfig.Global["1"].SkillPointLimit)
	local cycle = tonumber(GameConfig.Global["1"].SkillPointRecover)
	local dur = self.curServerTime - self.skillRecoverTime
	local leftTime = cycle - math.mod(dur,cycle)
	if self:getSkillPoint() >= limitPoint then
		leftTime = cycle
	end
	return leftTime
end

--设置用户经验
function UserData:setExp(value)
	self.totalExp = GameExp.getUserFinalExp(value,0)

	return
end

--用户经验修改
function UserData:addExp(value)
	self.totalExp = GameExp.getUserFinalExp(self.totalExp,value)

	return self
end

-- 获取用户战队等级
function UserData:getUserLevel()
	return GameExp.getUserLevel(self.totalExp)
end

-- 获取用户战队当前等级拥有的经验
function UserData:getUserCurrentExp()
	return GameExp.getUserCurrentExp(self.totalExp)
end

--获取用户战队当前升级所需总经验
function UserData:getUserUpgradeExp()
	return GameExp.getUserUpgradeExp(self.totalExp)
end

-- 获取vip等级
function UserData:getVip(exp)
	return VipData:getLevel(self.vip)
end

-- 获取VIP经验
function UserData:getVipExp()
	return self.vip
end

function UserData:setVip(value)
	if self.vip ~= value then
		self.vip = value
		self:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_VIP}) -- 分发 vip改变
	end

	return self
end

function UserData:getIsOpenSecretShop()
	return self.secretIsOpen
end

--神秘商店定时是否开启
function UserData:setIsOpenSecretShop(b)
	self.secretIsOpen = b
end

--神秘商店定时开启时间戳
function UserData:getSecretTime()
	return self.secretOpenTime
end

function UserData:setSecretTime(time)
	self.secretOpenTime = time
end

-- 神秘商店开启提示
function UserData:getSecretShopTip()
	return self.secretShopTip
end

function UserData:setSecretShopTip(param)
	self.secretShopTip = param
end

-- 获得首充状态
function UserData:getFirstBuy()
	return self.firstBuy
end


-- 设置首充状态
function UserData:setFirstBuy(array) -- 解析出充值首充状态
    for k,v in pairs(array) do
    	self.firstBuy[k] = v
    end
end

-- 是否显示首充按钮
function UserData:isFirstBuy()
	if self.firstRecharge[1] == "1" and self.firstRecharge[2] == "1" then
		return true
	end
	return false
end
-- 是否显示首充按钮红点
function UserData:isShowRechargeDot()
	if self.vip>=tonumber(GameConfig["FirstRechargeInfo"]["1"].Rdiamond) and self.firstRecharge[1]=="0" then
		return true
	elseif self.vip>=tonumber(GameConfig["FirstRechargeInfo"]["2"].Rdiamond) then
		if self.firstRecharge[1]=="0" or self.firstRecharge[2]=="0" then
			return true
		end
	end
	return false
end

-- 月卡结束时间戳
function UserData:getEndTime(id)
	return self.endTime[id]
end

function UserData:setEndTime(array)
	for k,v in pairs(array) do
    	self.endTime[k] = v
    end
end

-- 月卡剩余天数
function UserData:getCardDay(id)
	if self.endTime[tostring(id)] and self.endTime[tostring(id)] ~= 0 then
		local date = convertSecToDate(self.endTime[tostring(id)]-self.curServerTime)  -- date.hour, date.min, date.sec
		if date.hour>0 then
		    return date.day+1
		end
		return date.day
	end
	return 0
end

--通过VIP等级 获取是否购买过
function UserData:getIsBuy()
	return self.isBuyGift
end

-- 通过VIP等级 设置是否购买过
function UserData:setIsBuy(param)
	if type(param) == "table" then
		for i=1,#param do
			local id = param[i]
			self.isBuyGift[id] = 1
		end
	elseif type(param) == "string" then
        self.isBuyGift[param] = 1
	end

	return self
end

function UserData:setFirstRecharge(param)
	if type(param) == "table" then
		for i=1,#param do
			self.firstRecharge[i] = param[i]
		end
	elseif type(param) == "string" then
		self.firstRecharge[tonumber(param)] = "1"
	end
end

function UserData:getFirstRecharge()
	return self.firstRecharge
end

-- banner显示图片
function UserData:setBannerImage(imageId)
    if #imageId>0 then
    	for i=1,#imageId do
	    	self.bannerImage[i] = string.format("banner_%d.png", tonumber(imageId[i]))
	    end
    end
end

function UserData:getBannerImage()
	return self.bannerImage
end

function UserData:setName(value)
	if self.name ~= value then
		self.name = value
		self:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_NAME}) -- 分发 昵称改变
	end

	return self
end

function UserData:setHead(value)
	if self.headIcon ~= value then
		self.headIcon = value
		self:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_HEAD}) -- 分发 头像改变
	end

	return self
end

---------------------------------------------
--[[
{year = 1998, month = 9, day = 16, yday = 259, wday = 4,
 hour = 23, min = 48, sec = 10, isdst = false}
]]
function UserData:getServerTime()
	local time = self.curServerTime
	return os.date("*t", time)
end

function UserData:getServerSecond()
	return self.curServerTime
end

function UserData:getPlayedSecond()
	return self.curServerTime - self.beganTime
end

function UserData:setServerSecond(sec)
	self.serverTime = sec
	self:scheduleTime()
end

--[[
计算运行天数
以每天5：00为天数间隔
]]
function UserData:getRunningDay()
	-- self.beganTime
	local sec = 18000 -- 5小时
	local startDate = os.date("*t", self.beganTime - sec)

	startDate.hour = 0
	startDate.min = 0
	startDate.sec = 0

	local startSec = os.time(startDate)
	local offsec = self:getServerSecond() - startSec
	return math.floor(offsec / 86400)
end

---///////////////
-- 服务器开始时间 [暂时没加]
function UserData:getServerStartSecond()
	return self.serverStartSecond
end

function UserData:setServerStartSecond(sec)
	self.serverStartSecond = sec

	local date = os.date("*t", sec)
	local dateString = string.format("%d-%d-%d", date.year, date.month, date.day)
	local tDate = string.time(dateString)
	sec = os.time(tDate)

	self.severOpenSecond = sec
end

function UserData:getServerPlayedSecond()
	return self.curServerTime - self.serverStartSecond
end

-- 服务器开启日期零点的秒数
function UserData:getServerOpenSecond()
	return self.severOpenSecond
end

---------------------------------------------
local battlekeys = {
	"normal_herolist", 			-- 1. 主关卡 战斗队列
	"arena_battle_herolist", 	-- 2. 竞技场 战斗队列
	"arena_def_herolist", 		-- 3. 竞技场 防御队列
	"light_battle_herolist", 	-- 4. 山多拉的灯
	"house_battle_herolist", 	-- 5. 时间屋
	"mount_battle_herolist", 	-- 6. 庐山五老峰
	"aincrad_battle_herolist", 	-- 7. 艾恩葛朗特
	"tails_battle_list", 		-- 8. 尾兽出战队列
	"arena_sun_herolist", 		-- 9. 烈日追缉队列
	"arena_moon_herolist", 		-- 10.皎月追缉队列

}

local getHeroListKey = function(index)
	return battlekeys[index]
end

-- 设置 战队队列
function UserData:setBattleList(list)			-- 主关卡 战斗队列
	local key = getHeroListKey(1)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setArenaBattleList(list) 		-- 竞技场 战斗队列
	local key = getHeroListKey(2)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setArenaDefenseList(list)		-- 竞技场 防御队列
	local key = getHeroListKey(3)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setLightBattleList(list)		-- 山多拉的灯 战斗队列
	local key = getHeroListKey(4)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setHouseBattleList(list)		-- 精神时间屋 战斗队列
	local key = getHeroListKey(5)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setMountBattleList(list)		-- 庐山五老峰 战斗队列
	local key = getHeroListKey(6)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setAincradBattleList(list)		-- 艾恩葛朗特 战斗队列
	local key = getHeroListKey(7)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setTailsBattleList(list) 	-- 设置 尾兽出战队列
	local key = getHeroListKey(8)
	self.battleList[key] = list
	-- StoreData:save(list, key)
	return self
end

function UserData:setSunBattleList(list) 	-- 设置 烈日追缉
	local key = getHeroListKey(9)
	self.battleList[key] = list
	return self
end

function UserData:setMoonBattleList(list) 	-- 设置 皎月追缉
	local key = getHeroListKey(10)
	self.battleList[key] = list
	return self
end

---------------------------
function UserData:getBattleMember()			-- 主关卡 战斗队列
	local list = self:getBattleList()
	local arr = {}
	for i,v in ipairs(list) do
		if i < 5 then
			table.insert(arr, v)
		end
	end
	return arr
end

-- 获取 战队队列
function UserData:getBattleList()			-- 主关卡 战斗队列
	local key = getHeroListKey(1)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getArenaBattleList() 		-- 竞技场 战斗队列
	local key = getHeroListKey(2)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getArenaDefenseList()		-- 竞技场 防御队列
	local key = getHeroListKey(3)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getLightBattleList()		-- 山多拉的灯 战斗队列
	local key = getHeroListKey(4)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getHouseBattleList()		-- 精神时间屋 战斗队列
	local key = getHeroListKey(5)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getMountBattleList()		-- 庐山五老峰 战斗队列
	local key = getHeroListKey(6)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getAincradBattleList()	-- 艾恩葛朗特 战斗队列
	local key = getHeroListKey(7)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getTailsBattleList()		-- 尾兽出战 队列
	local key = getHeroListKey(8)
	return self.battleList[key] or {}
	-- return StoreData:get(key) or {}
end

function UserData:getSunBattleList()		-- 烈日追缉 队列
	local key = getHeroListKey(9)
	return self.battleList[key] or {}
end

function UserData:getMoonBattleList()		-- 烈日追缉 队列
	local key = getHeroListKey(10)
	return self.battleList[key] or {}
end


------------------------------------------------
-- 奖励英雄（暂时放这）
function UserData:rewardHero(heroId)
	local hero = HeroListData:getRoleWithId(heroId)
	if hero then -- 已经拥有英雄，转换为碎片
		ItemData:addItem(hero.stoneId, hero.stoneId, hero.exchangeStoneNum)
	else -- 激活英雄
		PlayerData.actHero(heroId)
	end
end

------------------------------------------------
-- 奖励其他物品
local GameEquip = import("app.data.GameEquip")
function UserData:addItem(uId, itemId, count, level)
	itemId = tostring(itemId)
	uId = uId or itemId
	count = tonumber(count) or 1

	local cfg = ItemData:getItemConfig(itemId)
	local iType = cfg.type
	if iType == 2 then 			-- 装备
		local param = {itemId = itemId, id = uId, count = count, level = level}
		ItemData:superimposeEquip(param)
	elseif iType == 8 then 		-- 金币
		self:addGold(count)
	elseif iType == 9 then 		-- 宝石
		self:addDiamond(count)
	elseif iType == 10 then 	-- 体力
		self:addPower(count)
	elseif iType == 11 then 	-- 灵能
		self:addSoul(count)
	elseif iType == 12 then 	-- 竞技场币
		self:addArenaValue(count)
	elseif iType == 13 then 	-- 战队经验
		self:addExp(count)
	elseif iType == 18 then 	-- 神树币
		self:addTreeValue(count)
	elseif iType == 19 then 	-- 城建币
		self:addCityValue(count)
	elseif iType == 27 then 	-- 公会币
		self:addUnionValue(count)
	elseif iType == 21 then 	-- 抽卡积分
		self:addCardValue(count)
	elseif iType == 24 then 	-- 技能点
		self.skillPoint = self.skillPoint + count
	else
		ItemData:addItem(uId, itemId, count)
	end
end

function UserData:removeItem(itemId, count)
	itemId = tostring(itemId)
	uId = uId or itemId
	count = tonumber(count) or 1

	local cfg = ItemData:getItemConfig(itemId)
	local iType = cfg.type
	if iType == 2 then 			-- 装备
		ItemData:reduceItemWithItemId(itemId, count)
	elseif iType == 8 then 		-- 金币
		self:addGold(-count)
	elseif iType == 9 then 		-- 宝石
		self:addDiamond(-count)
	elseif iType == 10 then 	-- 体力
		self:addPower(-count)
	elseif iType == 11 then 	-- 灵能
		self:addSoul(-count)
	elseif iType == 12 then 	-- 竞技场币
		self:addArenaValue(-count)
	elseif iType == 13 then 	-- 战队经验
		self:addExp(-count)
	elseif iType == 18 then 	-- 神树币
		self:addTreeValue(-count)
	elseif iType == 19 then 	-- 城建币
		self:addCityValue(-count)
	elseif iType == 27 then 	-- 城建币
		self:addUnionValue(-count)
	elseif iType == 21 then 	-- 抽卡积分
		self:addCardValue(-count)
	elseif iType == 24 then 	-- 技能点
		self.skillPoint = self.skillPoint - count
	else
		ItemData:reduceItemWithItemId(itemId, count)
	end
end

function UserData:getItemCount(itemId)
	itemId = tostring(itemId)
	local count = 0

	local cfg = ItemData:getItemConfig(itemId)
	local iType = cfg.type
	if iType == 2 then 			-- 装备
		count = ItemData:getItemCount(itemId)
	elseif iType == 8 then 		-- 金币
		count = self.gold
	elseif iType == 9 then 		-- 宝石
		count = self.diamond
	elseif iType == 10 then 	-- 体力
		count = self.power
	elseif iType == 11 then 	-- 灵能
		count = self.soul
	elseif iType == 12 then 	-- 竞技场币
		count = self.arenaValue
	elseif iType == 13 then 	-- 战队经验
		count = self.totalExp
	elseif iType == 18 then 	-- 神树币
		count = self.treeValue
	elseif iType == 19 then 	-- 城建币
		count = self.cityValue
	elseif iType == 27 then 	-- 城建币
		count = self.unionValue
	elseif iType == 21 then 	-- 抽卡积分
		count = self.cardValue
	elseif iType == 24 then 	-- 技能点
		count = self.skillPoint
	else
		count = ItemData:getItemCount(itemId)
	end

	return count
end

-- 获得奖励 (items 服务器所发)
function UserData:rewardItems(items)
	for i,v in ipairs(items or {}) do
		local itemId 	= v.param1 						-- 物品id
		if itemId then
			itemId = tostring(itemId)
			local count 	= v.param3					-- 物品数量
			local itemType 	= checknumber(v.param4) 	-- 物品类型

			if itemType == 6 then -- 英雄
				self:rewardHero(itemId)
			else
				local uId = v.param2 or itemId			-- 物品唯一id
				local level = tonumber(v.param5) 		-- 等级
				self:addItem(uId, itemId, count, level)
			end
		end
	end
	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
end

-- 解析奖励 (items 服务器所发)
function UserData:parseItems(items)
	local arr = {}
	for i,v in ipairs(items or {}) do
		local itemId 	= v.param1 						-- 物品id
		if itemId then
			itemId = tostring(itemId)
			local count 	= checknumber(v.param3)		-- 物品数量
			local itemType 	= checknumber(v.param4) 	-- 物品类型

			if itemType == 6 then -- 英雄
				local data = HeroListData:getRole(itemId)
				table.insert(arr, {
					heroId 	= itemId,
					count 	= 1,
					name 	= data.name,
					border 	= 8,
				})
			else
				local data = ItemData:getItemConfig(itemId)
				table.insert(arr, {
					itemId 	= itemId,
					count 	= count,
					name 	= data.itemName,
				})
			end
		end
	end
	return arr
end

--[[
@param items  数组
{
	icon,
	border,
	count,
}
]]
function UserData:showReward(items, callback)
	print("显示奖励 ")
	local cScene = display.getRunningScene()
	items = items or {}
	local nItem = table.nums(items)
	if nItem > 0 then
		CommonSound.award() -- 音效

		app:createView("widget.RewardLayer", {items=items})
		:addTo(cScene)
		:zorder(100)
		:onEvent(function(event)
			event.target:removeSelf()
			if callback then
				callback({})
			end
		end)
	else
		if callback then
			callback({show=false})
		end
	end
end
-- 显示战队升级
function UserData:showTeamLevelUp(params, callback)
	if not params then return end
	params.callback = params.callback or callback
	local cScene = display.getRunningScene()
	app:createView("battle.TeamLevelUpLayer", params):addTo(cScene)
	:zorder(100)
end

-- 显示神秘商店开启提示
function UserData:showSecretTalk(params, callback)
	if not params then return end
	params.callback = params.callback or callback
	local cScene = display.getRunningScene()
	app:createView("shop.SecretShopTip", params):addTo(cScene)
	:zorder(100)
end

function UserData:showItemDropLayer(itemData)
	local colorLayer = CommonView.blackLayer(100)
	display.getRunningScene():addChild(colorLayer,10)

	local dropLayer = app:createView("item.ItemDropLayer", itemData)
    dropLayer:setPosition(display.cx,display.cy)
    colorLayer:addChild(dropLayer)

    local closeBtn = cc.ui.UIPushButton.new({normal = "Close.png", pressed = "Close.png"})
	:onButtonClicked(function ()
		AudioManage.playSound("Close.mp3")
		colorLayer:removeFromParent(true)
		colorLayer = nil
		dropLayer = nil
		closeBtn = nil
	end)
	closeBtn:setPosition(230,100)
	dropLayer:addChild(closeBtn)
end

-- 显示战队信息弹窗
function UserData:showTeamInfo(teamData, type_)
	app:createView("rank.TeamInfoLayer", {data = teamData, orderType = type_})
	:addTo(display.getRunningScene())
	:zorder(99)
	:onEvent(function(event)
		if event.name == "close" then
			event.target:removeSelf()
		end
	end)
end

----------------------------------------------

function UserData:getItemBorder(itemData)
	if type(itemData) == "string" then
		itemData = ItemData:getItemConfig(itemData)
	end
	return self:getItemBorder_(itemData.configQuality)
end

function UserData:getItemBorder_(quality)
	return string.format("AwakeStone%d.png", quality)
end

function UserData:getItemIcon(itemData)
	if type(itemData) == "string" then
		itemData = ItemData:getItemConfig(itemData)
	end
	return itemData.imageName
end

function UserData:getItemFlag(itemData)
	if type(itemData) == "string" then
		itemData = ItemData:getItemConfig(itemData)
	end
	local iType = checknumber(itemData.type)
	if iType == 1 then
		return "HeroStone.png"
	elseif iType == 3 then
		return "Stuff.png"
	else
		return nil
	end
end

function UserData:getItemColor(itemData)
	if type(itemData) == "string" then
		itemData = ItemData:getItemConfig(itemData)
	end
	local itemType = itemData.quality
	if itemType == 1 then
		return CommonView.color_white()
	elseif itemType == 2 then
		return CommonView.color_green()
	elseif itemType == 3 then
		return CommonView.color_blue()
	elseif itemType == 4 then
		return CommonView.color_purple()
	elseif itemType == 5 then
		return CommonView.color_orange()
	end
end

-- 创建物品展示
function UserData:createItemView(itemData, params)
	if type(itemData) == "string" then
		itemData = ItemData:getItemConfig(itemData)
	end

	params = params or {}
	local x = params.flagX or 1
	local tScale = params.scale or 1

	local grid = base.Grid.new({swallowTouch=false})
	if params.quality then
		local bordername = self:getItemBorder_(params.quality)
		grid:addItemWithKey("border", display.newSprite(bordername):scale(tScale))
	else
		grid:addItemWithKey("border", display.newSprite(self:getItemBorder(itemData)):scale(tScale))
	end
	grid:addItemWithKey("icon", display.newSprite(self:getItemIcon(itemData)):scale(tScale))
	:addItem(display.newSprite(self:getItemFlag(itemData)):pos(-45 * x * tScale, 40 * tScale):scale(tScale):zorder(5))

	if params.tips ~= false then
		local tipView = nil
		grid:onTouch(function(event)
			if event.name == "began" then
				tipView = app:createView("widget.TipsLayer", {
					title = itemData.itemName,
					desc = itemData.desc,
					price = itemData.value,
				}):zorder(101)

				local cScene = display.getRunningScene()
				local point = convertPosition(event.target, cScene, cc.p(0, 30))
				if point.x + 382 > display.right then
					point.x = display.right - 382
				end
				tipView:addTo(cScene)
				:pos(point.x, point.y)
				:onEvent(function(tipEvent)
					if tipEvent.name == "exit" then
						tipView = nil
					end
				end)

			elseif event.name == "moved" then
				if tipView then
					tipView:removeSelf()
					tipView = nil
				end
			elseif event.name == "ended" then
				if tipView then
					tipView:removeSelf()
					tipView = nil
				end
			end
		end)
	end

	return grid
end

function UserData:getHeroIcon(heroId)
	if not heroId then return end
	if type(heroId) ~= "string" then
		heroId = heroId.roleId
	end
	if string.len(heroId) > 0 then
		return string.format("head_%d.png", checknumber(heroId))
	end
end

function UserData:getHeroSuperIcon(heroId)
	if type(heroId) ~= "string" then
		heroId = heroId.roleId
	end
	local index = checknumber(heroId)
	index = index + 1
	return string.format("head_%d.png", index)
end

function UserData:getHeroBorder(heroData)
	if type(heroData) == "string" then
		heroData = HeroListData:getRole(heroData)
	end
	return string.format("HeroCircle%d.png", heroData.awakeLevel+1)
end

function UserData:createHeroView(heroData, params)
	if type(heroData) == "string" then
		heroData = HeroListData:getRole(heroData)
	end

	params = params or {}
	local tScale = params.scale or 1

	local grid = base.Grid.new()

	if params.border then
		grid:addItemWithKey("border", createHeroCircle(params.border):scale(tScale))
	elseif params.defaultBorder ~= false then
		grid:addItemWithKey("border", createHeroCircle(0):scale(tScale))
	else
		grid:addItemWithKey("border", createHeroCircle(heroData.awakeLevel+1):scale(tScale))
	end

	grid:addItemWithKey("icon", display.newSprite(self:getHeroIcon(heroData)):scale(tScale))

	return grid
end

function UserData:createView(params, params2)
	if params.itemId then
		return self:createItemView(params.itemId, params2)
	elseif params.heroId then
		return self:createHeroView(params.heroId, params2)
	end
	return base.Grid.new()
end

function UserData:createAniEffect(params)
	if params.itemId then
		local itemData = ItemData:getItemConfig(params.itemId)
		local index = itemData.quality - 2
		if index > 0 then
			return createAniEffect(index)
		end
	elseif params.heroId then
		return createAniEffect(2)
	end
end

function UserData:showGuideLayer(params)
    local posX = params.x
    local posY = params.y
    local offX = params.offX or 0
    local offY = params.offY or 0
    local scale = params.scale or nil

    return showTutorial2({
        text = params.text,
        rect = cc.rect(posX, posY, 130, 130),
        x = posX + offX,
        y = posY + offY,
        scale = scale,
        callback = function(target)
            if params.callback then
                params.callback(target)
            end
            if params.autoremove ~= false then
                target:removeSelf()
            end
        end,
    })
end

-----------------------------------------------------
----------------- 消息 ------------------
function UserData:resetNoti()
	self.haveMail = false
end

-- 邮件
function UserData:isHaveMail()
	return self.haveMail
end

function UserData:setHaveMail(b)
	self.haveMail = b
end
-----------------------------------------------------
----------------- ui -------------------
function UserData:slider(img, per)
	per = per or 0
	local slider = display.newProgressTimer(img, display.PROGRESS_TIMER_BAR)
    slider:setMidpoint(cc.p(0, 1))
    slider:setBarChangeRate(cc.p(1, 0))
    slider:setPercentage(math.min(per * 100, 100))

    return slider
end

function UserData:setSliderPer(slider, per)
	per = math.min(per, 1)
	per = math.max(per, 0)
	slider:setPercentage(per * 100)
end

-----------------------------------------------------
---------------- 重置数据 -------------------

--------------------------------------------
function UserData:scheduleTime()
	if not self.schedule_ then
		local scheduler = require("framework.scheduler")
		self.schedule_ = scheduler.scheduleGlobal(handler(self,self.updateTime), 0.3)
	end
end

function UserData:unscheduleTime()
	if self.schedule_ then
		scheduler.unscheduleGlobal(self.schedule_)
		self.schedule_ = nil
	end
end

function UserData:updateTime(dt)
	local nowTime = self.curServerTime + dt
	if nowTime < self.serverTime then
		nowTime = self.serverTime
	end

	ResetTimeData:checkTime(self.curServerTime, nowTime)

	local dur = nowTime - self.curServerTime
	if dur > 0 then
		local powerMax = self:getPowerMax()
		if self.power < powerMax then
			local addtime = nowTime - self.powerRecoverTime
			if addtime >= GlobalData.powerRecover then -- 有体力恢复
				local addNum = math.floor(addtime / GlobalData.powerRecover) -- 增加数量
				if addNum >= powerMax - self.power then -- 全部恢复满
					self:setPower(powerMax)
					self.powerRecoverTime = nowTime
					self.powerData.next = 0
					self.powerData.all = 0
				else
					self.powerRecoverTime = self.powerRecoverTime + GlobalData.powerRecover * addNum
					self:addPower(addNum)

					self.powerData.next = addtime - addNum * GlobalData.powerRecover
					self.powerData.all = self.powerData.next + (powerMax - self.power - 1) * GlobalData.powerRecover
				end
			else  	-- 没有体力恢复
				self.powerData.next = GlobalData.powerRecover - addtime
				self.powerData.all = self.powerData.next + (powerMax - self.power - 1) * GlobalData.powerRecover
			end
		else
			self.powerRecoverTime = nowTime
			self.powerData.next = 0
			self.powerData.all = 0
		end
	end

	self.curServerTime = nowTime
end

return UserData