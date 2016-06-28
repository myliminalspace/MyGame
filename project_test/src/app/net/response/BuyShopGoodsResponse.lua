local BuyShopGoodsResponse = class("BuyShopGoodsResponse")

function BuyShopGoodsResponse:ctor()
	--响应消息号
	self.order = 10005
	--返回结果,如果成功才会返回下面的参数：1 成功,2 金币不足，3，钻石不足，4，已购买过，5，商品不存在,6，积分不足，7 ，神树币不足，8 竞技场币不足 9 城建币不足
	self.result =  ""
	--花费_花费类型:1 是金币，2 钻石_位置_当前有的数量
	self.value =  ""
	--商店类型：1 普通商店；2 积分商店；3 神树商店；4 竞技场商店
	self.param1 =  ""
end

function BuyShopGoodsResponse:BuyShopGoodsResponse(data)
	if data.result == 1 then
		-- 购买商品 成功
		local shopType 		= tonumber(data.param3)		-- 商店类型
		if shopType == 5 then  -- 购买经验物品
			local itemId = data.param1
			local count = data.param4

			local unit = GameConfig.item[itemId].Content.count
		    local price = GameConfig.item[itemId].Content.price[1]
		    local symbol = GameConfig.item[itemId].Content.price[2]
		    local cost = price * count
			ItemData:addMultipleItem(itemId,count*unit)

            if symbol == 1 then
                UserData:addGold(-cost)
            elseif symbol == 2 then
            	UserData:addDiamond(-cost)
            end

            GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
		elseif shopType == 10 then  -- 宝藏系统兑换
			local itemId = data.param1
			local count = data.param4
			local unit = 0
			local price = 0

			local shopItem = CoinData.exchangeItems
			for i,v in ipairs(shopItem) do
				if itemId == v.itemId then
					unit = v.count
					price = v.price
				end
			end

			local cost = price * count
			UserData:addCoinValue(-cost)
			ItemData:addMultipleItem(itemId,count*unit)

			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK, data = data})
		elseif shopType == 8 then  -- 打折商店
			local index = tonumber(data.param1)
			DiscountShopModel:updateBuyStatus(index,true)

			local discountGood = DiscountShopModel:getItem(index)
			local itemIds = discountGood.GiftItemID
			local itemNums = discountGood.GiftItemNum
			for i,v in ipairs(itemIds) do
				local cfg = GameConfig.item[v]
				local num = tonumber(itemNums[i])
				if cfg.Type == 8 then
					UserData:addGold(num)
				elseif cfg.Type == 9 then
					UserData:addDiamond(num)
				elseif cfg.Type == 10 then
					UserData:addPower(num)
				elseif cfg.Type == 11 then
					UserData:addSoul(num)
				elseif cfg.Type == 12 then
					UserData:addArenaValue(num)
				elseif cfg.Type == 13 then
					UserData:addExp(num)
				elseif cfg.Type == 18 then
					UserData:addTreeValue(num)
				elseif cfg.Type == 19 then
					UserData:addCityValue(num)
				elseif cfg.Type == 21 then
					UserData:addCardValue(num)
				elseif cfg.Type == 24 then
					UserData:addSkillPoint(num)
				else
					ItemData:addMultipleItem(v,num)
				end
			end
			local cost = discountGood.sale
			UserData:addDiamond(-cost)

			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
		elseif shopType == 7 then  -- 神秘商店
			local costStr 		= data.value 				-- 花费: 花费数量_花费类型_位置_当前拥有物品数量
			local items 		= data.a_param1 			-- 物品列表
			-- 解析花费
			local values = string.split(costStr, "_") -- 花费数量_花费类型_位置_当前拥有物品数量

			local coinType = values[2]
			local coinCount = tonumber(values[1])

			local pos = tonumber(values[3]) + 1
			local count = checknumber(values[4])
			if coinType == "1" then 		-- 金币
				UserData:addGold(coinCount - UserData.gold)
			elseif coinType == "2" then  	-- 钻石
				UserData:addDiamond( coinCount - UserData.diamond)
			elseif coinType == "3" then 	-- 积分
				UserData:addCardValue(coinCount - UserData.cardValue)
			elseif coinType == "4" then 	-- 神树
				UserData:addTreeValue(coinCount - UserData.treeValue)
			elseif coinType == "5" then 	-- 竞技
				UserData:addArenaValue(coinCount - UserData.arenaValue)
			elseif coinType == "6" then 	-- 城建、尾兽
				UserData:addCityValue(coinCount - UserData.cityValue)
			end

			local shop = ShopList:getShopByIndex(shopType)
			local shopItem = shop.items[pos]
			shopItem.sell = false
			for i,v in ipairs(shop.items) do
				if shopItem.id == v.id then
					v.have = count
				end
			end

			-- 增加物品
			local GameEquip = import("app.data.GameEquip")

			for k,v in pairs(items) do
				local itemId 		= tostring(v.param1) 		-- 物品id
				local uId 			= tostring(v.param2) 		-- 物品唯一id
				local level 		= checknumber(v.param4) 	-- 物品强化等级
				local buyCount 		= tonumber(v.param3) or 1 	-- 物品数量
				local cfg = ItemData:getItemConfig(itemId)
				if cfg.type == 2 then
					local param = {itemId = itemId, id = uId, count = buyCount, level = level}
					ItemData:superimposeEquip(param)
				else
					ItemData:addItem(itemId, itemId, buyCount)
				end
			end

			-- 设置任务购买商品数据
			if shopType > 1 and shopType <= 4 then
				local taskNames = {"", "shopArena", "shopScore", "shopTree"}
				TaskData:addShopBuyParams(taskNames[shopType], itemId, 1)
			end

			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
	    else  -- 其他商店
	    	local costStr 		= data.value 				-- 花费: 花费后剩余数量_花费类型_位置_当前拥有物品数量
			local items 		= data.a_param1 			-- 物品列表
			-- 解析花费
			local values = string.split(costStr, "_") -- 花费后剩余数量_花费类型_位置_当前拥有物品数量

			local coinType = values[2]
			local coinCount = tonumber(values[1])

			local pos = tonumber(values[3]) + 1
			local count = checknumber(values[4])
			if coinType == "1" then 		-- 金币
				UserData:addGold(coinCount - UserData.gold)
			elseif coinType == "2" then  	-- 钻石
				UserData:addDiamond( coinCount - UserData.diamond)
			elseif coinType == "3" then 	-- 积分
				UserData:addCardValue(coinCount - UserData.cardValue)
			elseif coinType == "4" then 	-- 神树
				UserData:addTreeValue(coinCount - UserData.treeValue)
			elseif coinType == "5" then 	-- 竞技
				UserData:addArenaValue(coinCount - UserData.arenaValue)
			elseif coinType == "6" then 	-- 城建、尾兽
				UserData:addCityValue(coinCount - UserData.cityValue)
			elseif coinType == "7" then     -- 公会币
				UserData:addUnionValue(coinCount - UserData.unionValue)
			end

			local shop = ShopList:getShopByIndex(shopType)
			local shopItem = shop.items[pos]
			shopItem.sell = false
			for i,v in ipairs(shop.items) do
				if shopItem.id == v.id then
					v.have = count
				end
			end

			-- 增加物品
			local GameEquip = import("app.data.GameEquip")

			for k,v in pairs(items) do
				local itemId 		= tostring(v.param1) 		-- 物品id
				local uId 			= tostring(v.param2) 		-- 物品唯一id
				local level 		= checknumber(v.param4) 	-- 物品强化等级
				local buyCount 		= tonumber(v.param3) or 1 	-- 物品数量
				local cfg = ItemData:getItemConfig(itemId)
				if cfg.type == 2 then
					local param = {itemId = itemId, id = uId, count = buyCount, level = level}
					ItemData:superimposeEquip(param)
				else
					ItemData:addItem(itemId, itemId, buyCount)
				end
			end

			-- 设置任务购买商品数据
			if shopType > 1 and shopType <= 4 then
				local taskNames = {"", "shopArena", "shopScore", "shopTree"}
				TaskData:addShopBuyParams(taskNames[shopType], itemId, 1)
			end

			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.UPDATE_USER_RES})
		end
	else

		if data.result == 2 then
			-- 金币不足
			ResponseEvent.lackGold()
		elseif data.result == 3 then
			-- 钻石不足
			ResponseEvent.lackGems()
		elseif data.result == 4 then
			-- 已购买过
			showToast({text="不可以重复购买"})
		elseif data.result == 5 then
			-- 商品不存在或已刷新
			showToast({text="商品不存在或已刷新"})
			GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
		elseif data.result == 6 then
			ResponseEvent.lackCardCoin()
		elseif data.result == 7 then
			ResponseEvent.lackTreeCoin()
		elseif data.result == 8 then
			ResponseEvent.lackArenaCoin()
		elseif data.result == 9 then
			ResponseEvent.lackCityCoin()
		elseif data.result == 10 then
			ResponseEvent.lackUnionCoin()
		end
	end
end

return BuyShopGoodsResponse