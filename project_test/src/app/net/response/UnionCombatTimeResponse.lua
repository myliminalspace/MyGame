local UnionCombatTimeResponse = class("UnionCombatTimeResponse")
function UnionCombatTimeResponse:UnionCombatTimeResponse(data)
	if data.result == 1 then
		local cost = UnionListData.timesCost  -- 购买挑战次数的花费的宝石
		UserData:addDiamond(-cost)

		UnionListData.timesCost = tonumber(data.param1)  -- 下一次购买挑战次数的花费
		UnionListData.times = tonumber(data.param2) 		-- 当前剩余的挑战次数

		UnionListData.buyTimes = UnionListData.buyTimes + 1

		GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
		GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
	elseif data.result == -1 then -- 钻石不足
		ResponseEvent.lackGems()
	end
end
function UnionCombatTimeResponse:ctor()
	--下一次购买挑战次数的花费
	self.param1 =  ""
	--当前可挑战次数
	self.param2 =  ""
end

return UnionCombatTimeResponse