
local CostDiamondData = class("CostDiamondData")

function CostDiamondData:ctor()
	self.arr = {}
	local cfgs = GameConfig["TimesDiamond"]
	local count = 0
	for k,v in pairs(cfgs) do
		table.insert(self.arr,  {
			times 	= checknumber(k), 						-- 次数
			shop 	= checknumber(v.ShopRefreshDiamond), 	-- 商店刷新
			gold 	= checknumber(v.ExChargeDiamond), 		-- 点金花费
			power 	= checknumber(v.BuyEnergyDiamon), 		-- 买体力花费
			arenaT 	= checknumber(v.BuyArenaTimes), 		-- 买竞技场次数
			arenaCD	= checknumber(v.BuyArenaCD), 			-- 买竞技场CD
			aincrad	= checknumber(v.AincardAward), 			-- 艾恩葛朗特开宝箱
			wanted 	= checknumber(v.WantedTimes), 			-- 日月追缉购买次数花费
			unionTimes 	= checknumber(v.BuyConsortiachallengeDiamon), 		-- 买公会挑战次数花费
		})
		count = count + 1
	end
	self.count = count -- 总次数

	table.sort(self.arr, function(a, b)
		return a.times < b.times
	end)


end

function CostDiamondData:getData(times)
	if times > self.count then
		times = self.count
	end
	return self.arr[times]
end

-- 商店刷新
function CostDiamondData:getRefreshShop(times)
	return self:getData(times).shop
end

-- 点金花费
function CostDiamondData:getBuyGold(times)
	return self:getData(times).gold
end

-- 买体力花费
function CostDiamondData:getBuyPower(times)
	return self:getData(times).power
end

-- 买公会体力花费
function CostDiamondData:getBuyUnionTimes(times)
	return self:getData(times).unionTimes
end

-- 买竞技场次数
function CostDiamondData:getBuyArenaTimes(times)
	return self:getData(times).arenaT
end

-- 买竞技场CD
function CostDiamondData:getBuyArenaCD(times)
	return self:getData(times).arenaCD
end

-- 艾恩葛朗特开宝箱
function CostDiamondData:getAincradAward(times)
	return self:getData(times).aincrad
end

-- 日月追缉购买次数花费
function CostDiamondData:getWanted(times)
	return self:getData(times).wanted
end

return CostDiamondData