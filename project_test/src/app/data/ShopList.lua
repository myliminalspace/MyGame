--[[
商店列表
]]
local ShopList = class("ShopList")
local ShopData = import(".ShopData")

function ShopList:ctor()
	self.lists = {}
	self.types = {"normal", "score", "tree", "arena", "", "aincrad", "secret", "", "union"}
	self.shopType = 1
end

function ShopList:createData(params)
	return ShopData.new(params)
end

-- 重置商店
function ShopList:resetShop(type)
	self.lists[type] = {}
	return self
end

-- 获取商店
function ShopList:getShop(type)
	return self.lists[type]
end
-- 获取商店
function ShopList:getShopByIndex(index)
	return self:getShop(self.types[index])
end

-- 获取商店
function ShopList:getShopType(index)
	return self.types[index]
end

-- 设置商店
function ShopList:addShop(shopData, shopType)
	if type(shopData) == "table" then
		shopData = self:createData(shopData)
	end
	self.lists[shopType] = shopData
	local index = table.indexof(self.types, shopType)
	shopData.shopIndex = index

	return shopData
end

-- 设置商店
function ShopList:addShopByIndex(shopData, index)
	return self:addShop(shopData, self:getShopType(index))
end

return ShopList