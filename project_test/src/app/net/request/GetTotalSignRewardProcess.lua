local GetTotalSignRewardProcess = class("GetTotalSignRewardProcess")

function GetTotalSignRewardProcess:ctor()
	--请求消息号
	self.order = 10042
	--用户id
	self.userid =  ""
	--战队id
	self.teamid =  ""
	--uuid
	self.uuid =  ""
	--token值
	self.token =  ""
	--累计签到id
	self.param1 =  ""	
end


function GetTotalSignRewardProcess:serialization()
	local data = {
		order = self.order,
		userid = self.userid,
		teamid = self.teamid,
		uuid = self.uuid,
		token = self.token,
		param1 = self.param1,
		
	}
	return data
end

return GetTotalSignRewardProcess