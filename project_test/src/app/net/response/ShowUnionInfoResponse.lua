local ShowUnionInfoResponse = class("ShowUnionInfoResponse")
local UnionModel = import("app.data.UnionModel")
function ShowUnionInfoResponse:ShowUnionInfoResponse(data)
    if data.result == 1 then
    	if data.param1 == 1 then      -- 已加入公会
    		-- 公会基本信息
    		local UnionModel = UnionModel.new({
					id            = data.param2,
					icon          = data.param4,
					exp           = data.param5,
					name          = data.param3 ,
					info          = data.param10 ,
					memberNums    = data.param6,
					memberMaxNums = data.param7 ,
					applyLv       = data.param8,
					applyType     = data.param9,
					notice        = data.param11,
					})
    		UnionListData:insertUnionData(UnionModel)

    		-- 公会成员信息table
    		UnionListData.unionMemberData = {}
    		if #data.a_param1 > 0 then
    			for i,v in ipairs(data.a_param1) do
			    	UnionListData:insertUnionMemberData(UnionModel:unionMember(v))
	    		end
    		end

            -- 申请人列表
            UnionListData.applyData = {}
    		if #data.a_param3 > 0 then
	    		for i,v in ipairs(data.a_param3) do
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
	    	local CharacterModel = import("app.battle.model.CharacterModel")
	    	UnionListData.allAgentData = {}
	    	if data.a_param4 and #data.a_param4 > 0 then
	    		for i,v in ipairs(data.a_param4) do
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

	    	-- 已发送邮件数量
	    	UnionListData.mailCount = data.param13

	    	if UserData.unionLevel and UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) >= UserData.unionLevel then
	    		UserData.unionLevel = UnionListData:getLevel(tonumber(UnionListData.unionData.exp))
	    	end

    	elseif data.param1 == 2 then  -- 未加入公会
    		if data.param11 then
				UnionListData:setApplyUnions(string.split(data.param11, ","))
			end

			if data.param12 then
				UnionListData.isCanApply = data.param12
			end

			UnionListData.unionShowList = {}
    		if #data.a_param2 >= 1 then
    			for i,v in ipairs(data.a_param2) do
					local UnionModel = UnionModel.new({
						id            = v.id,
						icon          = v.icon,
						exp           = v.exp,
						name          = v.name ,
						info          = v.declaration ,
						memberNums    = v.number,
						memberMaxNums = v.limitUp,
						applyLv       = v.applyLevel,
						applyType     = v.applyType,
						isApply       = v.hasApply,
						})
			    	UnionListData:insertShowData(UnionModel)
	    		end
    		end
    	end
    	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
    end
end
function ShowUnionInfoResponse:ctor()
	--响应消息号
	self.order = 30006
	--返回结果,1 成功
	self.result =  ""
	--是否加入了公会，1：已加入，2：未加入
	self.param1 =  ""
	--公会ID
	self.param2 =  ""
	--公会名称
	self.param3 =  ""
	--公会图标
	self.param4 =  ""
	--公会经验
	self.param5 =  ""
	--公会会员数量
	self.param6 =  ""
	--公会会员数量上限
	self.param7 =  ""
	--申请加入等级
	self.param8 =  ""
	--申请类型
	self.param9 =  ""
	--公会说明
	self.param10 =  ""
	--工会成员信息
	self.a_param1 =  ""
	--工会信息
	self.a_param2 =  ""
end

return ShowUnionInfoResponse