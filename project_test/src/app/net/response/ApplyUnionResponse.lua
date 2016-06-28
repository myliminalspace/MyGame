local ApplyUnionResponse = class("ApplyUnionResponse")
local UnionModel = import("app.data.UnionModel")

function ApplyUnionResponse:ApplyUnionResponse(data)
    if data.result == 1 then
    	for i,v in ipairs(UnionListData.unionShowList) do
    		if v.id == data.param1 then
    			v.isApply = 1
    		    break
    		end
    	end
    	showToast({text = "已申请，请等待审核结果！"})
    	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
    elseif data.result == 2 then
    	showToast({text = "成功加入公会！"})
    	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
	elseif data.result == 3 then
    	showToast({text = "公会已经解散"})
	elseif data.result == 4 then
    	showToast({text = "公会已经满员！"})
	elseif data.result == 5 then
    	showToast({text = "您的等级不足！"})
	elseif data.result == 6 then
    	showToast({text = "已经申请过该公会"})
    end
end

function ApplyUnionResponse:ctor()
	--响应消息号
	self.order = 30008
	--返回结果,1:成功申请,2:成功加入公会(公会加入规则为直接加入),3:公会已经解散,4:公会已经满员,5:等级不足,6:已经申请过该公会    -1:玩家已经加入了公会或其他异常
	self.result =  ""
	--公会Id
	self.param1 =  ""
	--工会成员信息
	self.a_param1 =  ""
end

return ApplyUnionResponse