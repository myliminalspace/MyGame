--
-- Author: zsp
-- Date: 2015-07-28 11:36:32
--

local AnimWrapper = class("AnimWrapper",function()
	return display.newNode()
end)

function AnimWrapper:ctor(animObject)
	self.animObject = animObject:createObject()
	self.width      = animObject:getSceneWidth()
	self.height     = animObject:getSceneHeight()
	self.animObject:addTo(self)
	self:setNodeEventEnabled(true)
end

function AnimWrapper:start()
	self.animObject:start()
end

function AnimWrapper:stop()
	self.animObject:stop()
end

function AnimWrapper:clearSequence()
	self.animObject:clearSequence()
end

function AnimWrapper:setFpsLimitations(fpsLimitations)
	self.animObject:setFpsLimitations(fpsLimitations)
end

--[[
	暂定动画，也会暂停帧回调
--]]
function AnimWrapper:pauseAnimation()
	self:enableTick(false)
	self.animObject:pauseAnimation()
	self.animObject:pause()
	
end

function AnimWrapper:resumeAnimation()
	self:enableTick(true)
	self.animObject:resumeAnimation()
	self.animObject:resume()
end

function AnimWrapper:enableTick(enable)
	self.animObject:enableTick(enable)
end


function AnimWrapper:playSequence(name,looped,resume)
	if resume == nil then
		self.animObject:playSequence(name,looped,true)
	else
		self.animObject:playSequence(name,looped,resume)
	end
end

--[[
	兼容之前的接口
--]]
function AnimWrapper:setDelegate()

end
    
--[[
	获取动画尺寸
--]]
function AnimWrapper:getFrameSize()
	return cc.rect(0,0,self.width,self.height)
end

function AnimWrapper:getFps()
	return self.animObject:getFps()
end

function AnimWrapper:setFps(value)
	self.animObject:setFps(value)
end

--[[
	注册动画回调
--]]
function AnimWrapper:registerScriptHandler(callback)
	self.animObject:setFramePlayedDelegate(function(frame,finish)
		callback(frame,finish)	
	end)
end

--[[
	解绑定回调，如果注册了回调，一定要注销，不注销会引起native内存泄露
--]]
function AnimWrapper:unregisterScriptHandler()
	self.animObject:enableTick(false)
	self.animObject:setFramePlayedDelegate(nil)
end

function AnimWrapper:onExit()
	if self.animObject then
		self.animObject:enableTick(false)
		self.animObject:setFramePlayedDelegate(nil)
		self.animObject = nil
	end
end

return AnimWrapper