local SearchUnionResponse = class("SearchUnionResponse")
local UnionModel = import("app.data.UnionModel")
function SearchUnionResponse:SearchUnionResponse(data)
    if data.result == 1 then
    	if data.a_param1 then
    		UnionListData.unionFindList = {}
    		local UnionModel = UnionModel.new({
    			id            = data.a_param1.id ,
				icon          = data.a_param1.icon,
				exp           = data.a_param1.exp,
				name          = data.a_param1.name ,
				info          = data.a_param1.declaration ,
				memberNums    = data.a_param1.number,
				memberMaxNums = data.a_param1.limitUp ,  --最大成员数量
				applyLv       = data.a_param1.applyLevel,
				applyType     = data.a_param1.applyType,
				isApply       = data.a_param1.hasApply,
				})
	    	UnionListData:insertFindData(UnionModel)
	    	GameDispatcher:dispatchEvent({name = EVENT_CONSTANT.NET_CALLBACK,data = data})
	    else
			showToast({text = "查找的公会不存在！"})
    	end
    end

end
function SearchUnionResponse:ctor()
	--响应消息号
	self.order = 30005
	--返回结果,1 成功
	self.result =  ""
	--检索关键字
	self.param1 =  ""
	--工会列表
	self.a_param1 =  ""
end

return SearchUnionResponse