local BuffBase = import(".BuffBase")
local CurseBuff = class("CurseBuff",BuffBase)

function CurseBuff:doBegin()
	self:doBuff()
	self.owner:addBuffEffect(self)
end

function CurseBuff:doBuff()
end

function CurseBuff:doEnd()
	self.owner:removeBuffEffect(self)
end

function CurseBuff:doUpdate(dt)
	
end

return CurseBuff