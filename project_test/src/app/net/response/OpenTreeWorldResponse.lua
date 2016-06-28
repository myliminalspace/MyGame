local OpenTreeWorldResponse = class("OpenTreeWorldResponse")
function OpenTreeWorldResponse:OpenTreeWorldResponse(data)
	if data.result == 1 then 
		TreeData.tree_we = data.param1 
		TreeData.useTimes = checknumber(data.param3)
		TreeData.winTimes = checknumber(data.param4)
		TreeData.refreshTimes = checknumber(data.param6)
	    TreeData:setBattleData(data.param5)
		TreeData.battling = checknumber(data.param8) == 1 

		TreeData:resetBattleHeroList()
		TreeData:resetHeroCacheList()

		-- 加入待选列表
		for i,v in ipairs(string.split(data.param2 or "", ",")) do
			TreeData:addCacheHero(v)
		end
		-- 加入已选列表
		for i,v in ipairs(string.split(data.param7 or "", ",")) do
			TreeData:addBattleHero(v)
		end

		-- 完成任务
		TaskData:addTaskParams("tree", 1)

	elseif data.result == -1 then 
		showToast({text="未开放"})
	elseif data.result == -2 then 
		showToast({text="没有挑战次数"})
	end 
end
function OpenTreeWorldResponse:ctor()
	--响应消息号
	self.order = 20021
	--返回结果,1 成功;
	self.result =  ""
	--tree_we的id
	self.param1 =  ""
	--英雄列表，三个以逗号隔开
	self.param2 =  ""
	--已使用的世界树次数
	self.param3 =  ""
	--胜利的次数
	self.param4 =  ""
	--上次战斗的信息
	self.param5 =  ""
	--英雄列表刷新的次数
	self.param6 =  ""
	--已选择的英雄id,多个以逗号开隔
	self.param7 =  ""	
end

return OpenTreeWorldResponse