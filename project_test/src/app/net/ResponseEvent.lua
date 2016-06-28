
module("ResponseEvent", package.seeall)

-- 宝石不足
function lackGems()
	GemsAlert:show()
end

-- 金币不足
function lackGold()
	-- GuideAlert.gold()
	GoldAlert:show()
end

-- 体力不足
function lackPower()
	PowerAlert:show()
end

-- 已达最大挑战次数
function lackBattle()
	showToast({text="已达最大挑战次数"})
end

-- 等级不足
function lackLevel()
	showToast({text="等级不足"})
end

-- 关卡未开放
function stageNotOpen()
	showToast({text="关卡未开放"})
end

-- 星星数不足（扫荡需要3星通关）
function lackStar()
	showToast({text="未达到3星通关"})
end

-- 抽卡积分不足
function lackCardCoin()
	showToast({text="抽卡积分不足"})
end

-- 神树币不足
function lackTreeCoin()
	showToast({text="神树币不足"})
end

-- 竞技场币不足
function lackArenaCoin()
	showToast({text="竞技场币不足"})
end

-- 城建币不足
function lackCityCoin()
	showToast({text="城建币不足"})
end

-- 公会币不足
function lackUnionCoin()
	showToast({text="公会币不足"})
end
