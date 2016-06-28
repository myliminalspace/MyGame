--[[
活动 基类
]]

local ActivityGameBase = class("ActivityGameBase")

function ActivityGameBase:ctor(params)
	local cfg = params.cfg

	self.id = params.id

	self.desc 		= cfg.description or "" 	-- 描述
	self.sort 		= checknumber(cfg.sort) 	-- 排序
	self.jumpUI 	= checknumber(cfg.jumpUI) 	-- 跳转场景
	self.okCode 	= checknumber(cfg.finishCondition) 	-- 完成代号
	self.okParam1 	= cfg.finishNumber1 		-- 完成参数1
	self.okParam2 	= cfg.finishNumber2 		-- 完成参数2
	self.items 		= {} 						-- 奖励物品
	self.itemsDict 	= {}

	local qualitys = cfg.awardQuality or {}

	for i,v in ipairs(cfg.awardItemID or {}) do
		local itemData = {
			id = v, 	-- 物品id
			count = checknumber(cfg.itemNumber[i]), 	-- 物品数量
		}

		if qualitys[i] then
			itemData.quality = qualitys[i] -- 物品品质
		end

		table.insert(self.items, itemData)
		self.itemsDict[v] = itemData
	end

	self.completed 	= false 	-- 完成情况
	self.ok = false				-- 是否达成完成条件
	self.processLabel = "" 		-- 达成进度
	self.processValue = 0 		-- 进度数值
end

-- 重置
function ActivityGameBase:resetData()
	self.completed = false
	self.ok = false
	self.processLabel = ""
	self.processValue = 0
end

------------------------------------------------
-- 是否已经结束
function ActivityGameBase:isCompleted()
	return self.completed
end

-- 是否达成完成条件
function ActivityGameBase:isOk()
	return self.ok
end

-- 达成进度字符串
function ActivityGameBase:getProcessString()
	return self.processLabel
end

-- 获得进度
function ActivityGameBase:getProcessValue()
	return self.processValue
end

-- 设置是否已经结束
function ActivityGameBase:setCompleted(b)
	self.completed = b
	return self
end

-- 设置是否达成完成条件
function ActivityGameBase:setOk(b)
	self.ok = b
	return self
end

-- 设置达成进度字符串
function ActivityGameBase:setProcessString(txt)
	self.processLabel = txt
	return self
end

-- 设置进度
function ActivityGameBase:setProcessValue(value)
	self.processValue = value
	return self
end

-- 增加进度
function ActivityGameBase:addProcessValue(value)
	self:setProcessValue(self.processValue + value)
	return self
end

-----------------------------------------------------

return ActivityGameBase