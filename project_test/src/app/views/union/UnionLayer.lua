local UnionLayer = class("UnionLayer",function ()
	return display.newNode()
end)

local signImg  = "Union_Church.png"
local hallImg  = "Union_Hall.png"
local arenaImg = "Union_Arena.png"
local shopImg  = "Union_Shop.png"
local instanceImg  = "Union_Instance.png"
local instanceWord = "instance_word.png"
local idImg    = "union_id.png"
local pointImage = "Point_Red.png"

function UnionLayer:ctor()
    self:initData()
    self:initView()
end

function UnionLayer:initData()
    self.isSend = false
    self.noticeMsg = UnionListData.unionData.notice
end

function UnionLayer:initView()
    local image_ = {normal = idImg}
    self.unionIdImg = CommonButton.yellow3("", {image = image_})
    :onButtonClicked(function ()
        if UnionListData:getUnionDuty() ~= "4" then
            self.delegate:createUnionEditBox({
                msg        = self.noticeMsg,
                fontNum    = 100,
                width      = 160,
                height     = 24,
                posX       = display.cx - 360,
                posY       = display.cy - 100,
                des        = "修改公告",
                maxLength  = 70,
                changeType = 2,
                })
        end
    end)
    :pos(display.cx - 360, display.cy - 170):addTo(self,3)

    self:createStageInfo()
end

function UnionLayer:createStageInfo()

    -- 公会签到
    local image_ = {normal = signImg}
    self.signBtn = CommonButton.yellow3("", {image = image_})
    :onButtonClicked(function()
        app:pushToScene("UnionSignInScene")
    end)
    :pos(display.cx - 330, display.cy + 150)
    :addTo(self,3)
    -- 签到红点
    self.signRedPoint = display.newSprite(pointImage):pos(110, -90):zorder(11)
    self.signRedPoint:setVisible(false)
    self.signBtn:addChild(self.signRedPoint)

    -- 公会大厅
    local image_ = {normal = hallImg}
    self.hallBtn = CommonButton.yellow3("", {image = image_})
    :onButtonClicked(function()
        app:pushToScene("UnionHallScene")
    end)
    :pos(display.cx + 15, display.cy + 150)
    :addTo(self,3)
    -- 申请人红点
    self.applyRedPoint = display.newSprite(pointImage):pos(130, -140):zorder(11)
    self.applyRedPoint:setVisible(false)
    self.hallBtn:addChild(self.applyRedPoint)

     -- 公会商店
    local image_ = {normal = shopImg}
    self.shopBtn = CommonButton.yellow3("", {image = image_})
    :onButtonClicked(function ()
        NetHandler.gameRequest("OpenShop",{param1 = 9})
    end)
    :pos(display.cx - 120, display.cy - 140)
    :addTo(self,3)

     -- 公会竞技场
    local image_ = {normal = arenaImg}
    self.fightBtn = CommonButton.yellow3("", {image = image_})
    :onButtonClicked(function ()
        if UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) < 1 then
            showToast({text = "需要公会1级开启"})
        else
            NetHandler.gameRequest("ShowUnionRandom")
        end
    end)
    :pos(display.cx + 295, display.cy - 140)
    :addTo(self,3)

    -- 公会副本
    local image_ = {normal = instanceImg}
    self.stageBtn = CommonButton.yellow3("", {image = image_})
    self.stageBtn:onButtonClicked(function ()
        if UnionListData:getLevel(tonumber(UnionListData.unionData.exp)) < 1 then
            showToast({text = "需要公会1级开启"})
        else
            app:pushToScene("UnionInstanceScene")
        end
    end)
    self.stageBtn:pos(display.cx + 320, display.cy + 140)
    self.stageBtn:addTo(self,3)
    local name = display.newSprite(instanceWord):pos(display.cx + 370, display.cy + 20):addTo(self, 5)
    -- 雇佣兵红点
    self.agentRedPoint = display.newSprite(pointImage):pos(115, 30):zorder(11)
    self.agentRedPoint:setVisible(false)
    name:addChild(self.agentRedPoint)

    local sequence = transition.sequence({
        cc.MoveTo:create(2, cc.p(display.cx + 320, display.cy + 125)),
        cc.MoveTo:create(2, cc.p(display.cx + 320, display.cy + 140)),
    })
    self.stageBtn:runAction(cc.RepeatForever:create(sequence))

end

function UnionLayer:updateData()
    self.noticeMsg = UnionListData.unionData.notice
end

function UnionLayer:updateView()
    if self.des then
        self.des:removeFromParent()
        self.des = nil
    end
    self.des = base.TalkLabel.new({
                text  = self.noticeMsg,
                size  = 18,
                dimensions = cc.size(150, 0),
                color = CommonView.color_black()
            })
    self.des:pos(-75, 85 - 22*self.des:getLines())
    self.des:addTo(self.unionIdImg,5)

    -- 签到红点
    self.signRedPoint:setVisible(UnionListData:isShowSignRedPoint())
    -- 申请人红点
    self.applyRedPoint:setVisible(UnionListData:isShowApplyRedPoint())
    -- 雇佣兵红点
    self.agentRedPoint:setVisible(UnionListData:isShowSendRedPoint() or UnionListData:isShowBackRedPoint())
end

return UnionLayer