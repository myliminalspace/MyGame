local ApproveJoinResponse = class("ApproveJoinResponse")
local UnionModel = import("app.data.UnionModel")
function ApproveJoinResponse:ApproveJoinResponse(data)
    if data.result == 1 then
    	if data.param1 == 1 then
    		-- UnionListData.unionData.memberNums = tostring(tonumber(UnionListData.unionData.memberNums) + 1)
    	 	local UnionModel = UnionModel.new(UnionListData.unionData)
	    	UnionListData:insertUnionMemberData(UnionModel:unionMember(data.a_param1[1]))
            showToast({text = "申请成功！该玩家已加入公会"})
        else
            for i,v in ipairs(UnionListData.applyData) do
                if v.userId == data.param2 then
                    table.remove(UnionListData.applyData, i)
                    break
                end
            end
    	end
    	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
    elseif data.result == 3 then
        for i,v in ipairs(UnionListData.applyData) do
            if v.userId == data.param2 then
                table.remove(UnionListData.applyData, i)
                break
            end
        end
        showToast({text = "申请失效！"})
        GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
    elseif data.result == 4 then
        for i,v in ipairs(UnionListData.applyData) do
            if v.userId == data.param2 then
                table.remove(UnionListData.applyData, i)
                break
            end
        end
    	showToast({text = "申请已经被处理过了！"})
        GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
    elseif data.result == 5 then
        for i,v in ipairs(UnionListData.applyData) do
            if v.userId == data.param2 then
                table.remove(UnionListData.applyData, i)
                break
            end
        end
    	showToast({text = "公会人员已满！"})
    	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
    end
end

function ApproveJoinResponse:ctor()
	--响应消息号
	self.order = 30012
	--返回结果,1:成功 ，2:没有操作权限，3:申请已过期,-1:其他非法错误
	self.result =  ""
	--是否同意加入
	self.param1 =  ""
	--被审批人userid
	self.param2 =  ""
end

return ApproveJoinResponse