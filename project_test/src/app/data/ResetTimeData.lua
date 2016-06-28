
local ResetTimeData = class("ResetTimeData")

function ResetTimeData:ctor()
	self.observers = {}
end

function ResetTimeData:addObserver(name, listener, flag)
	if not self.observers[name] then
		self.observers[name] = {}
	end
	table.insert(self.observers[name], {
		callback = listener,
		flag = flag,
	})

	return self
end

function ResetTimeData:removeObserver(name, flag)
	local list = self.observers[name]
	if list then
		local len = #list
		for i=1,len do
			local index = len-i+1
			if not list[index].flag or list[index].flag == flag then
				table.remove(list, index)
			end
		end
	end

	return self
end

function ResetTimeData:onEvent_(name, params)
	local list = self.observers[name]
	if not list then return end
	for i,v in ipairs(list) do
		v.callback(params)
	end
end

-------------------------------------------------
function ResetTimeData:checkTime(pre, cur)
	local dur = cur - pre
	if dur >= 86400 then -- 间隔超过一天
		self:resetAll()
		return
	end

--------------------------------------------------
	local curDate = os.date("*t", cur)
	local curSec = curDate.hour * 3600 + curDate.min * 60 + curDate.sec

	local preDate = os.date("*t", pre)
	local preSec = preDate.hour * 3600 + preDate.min * 60 + preDate.sec

	local nPre = math.floor(preSec)
	local nCur = math.floor(curSec)

	if self:isGetTime_(GlobalData.refreshTime, nPre, nCur) then
		self:resetStage()
		self:resetArena()
		self:resetAincrad()
		self:resetHolyLand()
		self:resetSignIn()
		self:resetMail()
		self:resetTask()
		self:resetPowerBuyTimes()
		self:resetWantedBuyTimes()
		self:resetNormalActivityDaily()
	end

	if self:isGetTime_(0, nPre, nCur) then
		self:coverDay()
	end

	local data = ShopList:getShop("normal")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetNormalShop()
		end
	end

	data = ShopList:getShop("score")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetScoreShop()
		end
	end

	data = ShopList:getShop("arena")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetArenaShop()
		end
	end

	data = ShopList:getShop("tree")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetTreeShop()
		end
	end

	data = ShopList:getShop("aincrad")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetAincradShop()

		end
	end

	data = ShopList:getShop("secret")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetSecretShop()
		end
	end

	data = ShopList:getShop("union")
	if data then
		if self:isGetTime_(data.time, nPre, nCur) then
			self:resetSecretShop()
		end
	end

end

--[[
获得两个时间点的长度
sec1 前时间点秒 不可超过24小时
sec2 后时间点秒 不可超过24小时
sec1与sec2 之间不可超过24小时
]]
function ResetTimeData:getTimeLength(sec1, sec2)
	sec2 = sec2 + 86400
	local dur = sec2 - sec1
	dur = math.mod(dur, 86400)
	return dur
end

function ResetTimeData:isGetTime(sec, sec1, sec2)
	local nSec = math.floor(sec)
	local nSec1 = math.floor(sec1)
	local nSec2 = math.floor(sec2)

	return self:isGetTime_(nSec, nSec1, nSec2)
end

function ResetTimeData:isGetTime_(sec, sec1, sec2)
	if sec2 < sec1 then
		sec2 = sec2 + 86400
	end
	if sec <= sec1 then
		sec = sec + 86400
	end
	if sec <= sec2 then
		return true
	end
	return false
end

function ResetTimeData:resetAll()
	self:resetStage()
	self:resetArena()
	self:resetAincrad()
	self:resetHolyLand()
	self:resetNormalShop()
	self:resetScoreShop()
	self:resetSecretShop()
	self:resetUnionShop()
	self:resetArenaShop()
	self:resetTreeShop()
	self:resetSignIn()
	self:resetMail()
	self:resetTask()
	self:resetPowerBuyTimes()
	self:resetWantedBuyTimes()
	self:resetNormalActivityDaily()
end

--------------------------------------

-- 重置 精英关卡
function ResetTimeData:resetStage()
	SceneData:reset("Chapter")
	self:onEvent_("chapter")
end

-- 重置 竞技场
function ResetTimeData:resetArena()

end

----------------------------------
-- 重置 艾恩葛朗特
function ResetTimeData:resetAincrad()
	SceneData:reset("Aincrad")
	AincradData:resetDayData()
	self:onEvent_("aincrad")
end

-- 重置 修炼圣地
function ResetTimeData:resetHolyLand()
	SceneData:reset("OpenTrials")
	self:onEvent_("holyland")
end

------------------------------
-- 重置 普通 商店
function ResetTimeData:resetNormalShop()
	SceneData:reset("OpenShopNormal")
	GameDispatcher:dispatchEvent({name="refresh_shop_normal"})
end

-- 重置 积分 商店
function ResetTimeData:resetScoreShop()
	SceneData:reset("OpenShopScore")
	GameDispatcher:dispatchEvent({name="refresh_shop_score"})
end

-- 重置 竞技场 商店
function ResetTimeData:resetArenaShop()
	SceneData:reset("OpenShopArena")
	GameDispatcher:dispatchEvent({name="refresh_shop_arena"})
end

-- 重置 世界树 商店
function ResetTimeData:resetTreeShop()
	SceneData:reset("OpenShopTree")
	GameDispatcher:dispatchEvent({name="refresh_shop_tree"})
end

-- 重置 艾恩葛朗特 商店
function ResetTimeData:resetAincradShop()
	SceneData:reset("OpenShopAincrad")
	GameDispatcher:dispatchEvent({name="refresh_shop_aincrad"})
end

-- 重置 神秘 商店
function ResetTimeData:resetSecretShop()
	SceneData:reset("OpenShopSecret")
	GameDispatcher:dispatchEvent({name="refresh_shop_secret"})
end

-- 重置 公会 商店
function ResetTimeData:resetUnionShop()
	SceneData:reset("OpenShopUnion")
	GameDispatcher:dispatchEvent({name="refresh_shop_union"})
end
-------------------------------

-- 重置 每日签到
function ResetTimeData:resetSignIn()
	SceneData:reset("SignIn")
	self:onEvent_("signin")
end

--------------------------------
-- 重置 邮箱
function ResetTimeData:resetMail()

end

-- 重置 任务
function ResetTimeData:resetTask()
	TaskData:resetDailyParams()
end

-- 重置 体力购买次数
function ResetTimeData:resetPowerBuyTimes()
	UserData.powerData.buyTimes = 0
end

-- 重置 日月追缉购买次数
function ResetTimeData:resetWantedBuyTimes()
	ArenaLookingForData:setHaveTimes(0)
end

-- 重置 通用任务 每日任务
function ResetTimeData:resetNormalActivityDaily()
	ActivityNormalData:resetDailyData()
end

-- 过了一天
function ResetTimeData:coverDay()

end

return ResetTimeData
