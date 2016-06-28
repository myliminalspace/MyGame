local UnionHallLayer = class("UnionHallLayer",function ()
    return display.newNode()
end)

local UnionBg = "Union_Bg.png"
local listImage = "union_list_bg.png"
local unionSliderBg = "union_slide_bg.png"
local unionSliderImg = "union_slide.png"
local changeAd = "change_union_ad.png"
local pointImage = "Point_Red.png"

function UnionHallLayer:ctor()
    self:initData()
    self:initView()
end

function UnionHallLayer:initData()
    self.unionData = UnionListData.unionData
    self.unionMemberData = {}
    for i,v in ipairs(UnionListData.unionMemberData) do
        table.insert(self.unionMemberData, v)
    end

    self.unionDes_ = self.unionData.info
end

function UnionHallLayer:initView()
    self.backView = display.newSprite(UnionBg):pos(display.cx-5,display.cy-20):addTo(self)

    -- 公会头像
    self.unionIcon = display.newSprite(self.unionData.icon):pos(100, 410):addTo(self.backView)

    -- 公会名 ID 等级 签名
    local pos = 155
    local member_ = "（"..self.unionData.memberNums.."/"..self.unionData.memberMaxNums.."）"
    self.unionName = display.newTTFLabel({text = self.unionData.name..member_, color = cc.c3b(255, 47, 47), size = 22})
    self.unionName:pos(pos+self.unionName:getContentSize().width/2,448)
    self.unionName:addTo(self.backView)

    local unionId = display.newTTFLabel({text = "公会ID："..self.unionData.id, color = cc.c3b(252, 242, 181), size = 18})
    unionId:pos(pos+unionId:getContentSize().width/2,420)
    unionId:addTo(self.backView)

    local unionAd = display.newTTFLabel({text = "公会签名：", color = cc.c3b(252, 242, 181), size = 18})
    unionAd:pos(pos+45,397)
    unionAd:addTo(self.backView)

    local image_ = {}
    self.changeAd = CommonButton.yellow3("", {image = image_,size = 18, color = cc.c3b(252, 242, 181)})
    self.changeAd:pos(237, 397):addTo(self.backView)
    self.changeAd:setButtonLabelAlignment(display.LEFT_CENTER)
    self.changeAd:onButtonClicked(function ()
        if UnionListData:getUnionDuty() == "1" or UnionListData:getUnionDuty() == "2" then
            self.delegate:createUnionEditBox({
                msg        = self.unionDes_,
                fontNum    = 40,
                width      = 421,
                height     = 25,
                posX       = display.cx - 3,
                posY       = display.cy + 125,
                des        = "修改公会签名",
                maxLength  = 70,
                changeType = 1,
                })
        end
    end)

    local unionLevel = UnionListData:getLevel(tonumber(self.unionData.exp))
    self.unionLv = display.newTTFLabel({text = "公会等级："..unionLevel, color = cc.c3b(252, 242, 181), size = 18})
    self.unionLv:pos(pos+self.unionLv:getContentSize().width/2,372)
    self.unionLv:addTo(self.backView)

    local nextLv = display.newTTFLabel({text = "距离下一等级：",color = cc.c3b(252, 242, 181), size = 14})
    nextLv:pos(pos+120+nextLv:getContentSize().width/2,372)
    nextLv:addTo(self.backView)

    -- vip经验条
    local spr = display.newSprite(unionSliderBg):addTo(self.backView):align(display.CENTER_LEFT):pos(pos+210, 372)
    self.unionSlider_ = display.newSprite(unionSliderImg):addTo(spr):align(display.CENTER_LEFT):pos(4, 11)
    self.unionSlider_:setScaleX(0)
    self.unionExpLabel_ = base.Label.new({text = "",size = 12,color = cc.c3b(252, 242, 181)}):addTo(self.backView):align(display.CENTER):pos(pos+330, 372)

    --日志按钮  管理按钮
    CommonButton.yellow("公会日志", {size = 24, color = cc.c3b(252, 242, 181)})   -- 申请加入按钮
    :onButtonClicked(function ()
        NetHandler.gameRequest("ShowUnionLog")
    end)
    :pos(755,440)
    :addTo(self.backView,3)
    :scale(0.9)

    -- self.hallBtn = CommonButton.yellow("退出公会", {size = 24,color = cc.c3b(252, 242, 181)})
    --     :onButtonClicked(function ()
    --         AlertShow.show2("提示", "确定退出公会？", "确定", function(event)
    --             NetHandler.gameRequest("SecedeUnion")
    --         end, function()
    --         end)
    --     end)
    --     :pos(755,385)
    --     :addTo(self.backView,3)
    --     :scale(0.9)

    self.hallRedPoint = display.newSprite(pointImage):pos(815,402):zorder(11)
    self.hallRedPoint:setVisible(false)
    self.backView:addChild(self.hallRedPoint)

    --成员list
    self.listView = cc.TableView:create(cc.size(770,340))
    self.listView:setPosition(58,19)
    self.listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.listView:setDelegate()

    self.listView:registerScriptHandler(handler(self, self.scrollViewDidScroll), 0)
    self.listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED)
    self.listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self.listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.listView:reloadData()
    self.backView:addChild(self.listView)

end

function UnionHallLayer:scrollViewDidScroll(table)

end

function UnionHallLayer:tableCellTouched(table,cell)
	-- print("cellIdx:"..cell:getIdx())
end

function UnionHallLayer:cellSizeForTable(table,idx)
	  return 105
end

function UnionHallLayer:tableCellAtIndex(table,idx)
	  return self:createCell(idx)
end

function UnionHallLayer:numberOfCellsInTableView(table)
	  return #self.unionMemberData
end

function UnionHallLayer:createCell(idx)
	  local cell = cc.TableViewCell:new()
	  cell:setIdx(idx)

    local bgSprite = display.newSprite(listImage)
    bgSprite:setAnchorPoint(0,0)
    cell:addChild(bgSprite)

    local data = self.unionMemberData[idx+1]
    local image_ = {normal = data.headIcon}
    display.newSprite("Mail_Circle.png"):scale(0.75):pos(55,50):addTo(cell)
    CommonButton.yellow3("",{image = image_})
    :onButtonClicked(function ()
        -- self.delegate:createUnionMemberLayer() -- 传入指定成员信息表
    		-- print("查看")
    end)
    :pos(55,50)
    :addTo(cell)
    :scale(0.75)

    local pos = 110
    local name = display.newTTFLabel({text = data.name,color = cc.c3b(254, 231, 93), size = 20})
    name:pos(pos+name:getContentSize().width/2,65)
    name:addTo(cell)

    local duty = ""
    if data.duty == "1" then
        duty = "   会长"
    elseif data.duty == "2" then
        duty = "   副会长"
    elseif data.duty == "3" then
        duty = "   管理员"
    end

    local memLv = display.newTTFLabel({text = "lv."..tostring(GameExp.getUserLevel(data.exp))..duty, color = cc.c3b(254, 231, 93), size = 20})
    memLv:pos(pos+memLv:getContentSize().width/2,30)
    memLv:addTo(cell)

    local allH = display.newTTFLabel({text = "累计贡献 "..data.totalCon,color = cc.c3b(252, 242, 181), size = 17})
    allH:pos(pos+130+allH:getContentSize().width/2,70)
    allH:addTo(cell)

    local todayH = display.newTTFLabel({text = "今日贡献 "..data.todayCon,color = cc.c3b(252, 242, 181), size = 17})
    todayH:pos(pos+130+todayH:getContentSize().width/2,40)
    todayH:addTo(cell)

    local nowTime = UserData:getServerSecond()
    local date = convertSecToDate(nowTime - data.loginTime)
    local day = date.day
    local hour = date.hour
    if tonumber(day) > 0 then
        local recentL = display.newTTFLabel({text = tostring(day).."天前登陆",color = cc.c3b(252, 242, 181), size = 20})
        recentL:pos(pos+320+recentL:getContentSize().width/2,75)
        recentL:addTo(cell)
    elseif tonumber(day) == 0 and tonumber(hour) > 0 then
        local recentL = display.newTTFLabel({text = tostring(hour).."小时前登陆",color = cc.c3b(252, 242, 181), size = 20})
        recentL:pos(pos+320+recentL:getContentSize().width/2,75)
        recentL:addTo(cell)
    elseif tonumber(day) == 0 and tonumber(hour) == 0 then
        local recentL = display.newTTFLabel({text = "刚刚登陆",color = cc.c3b(252, 242, 181), size = 20})
        recentL:pos(pos+320+recentL:getContentSize().width/2,75)
        recentL:addTo(cell)
    end

    local totalP = display.newTTFLabel({text = "战力："..data.totalPower,color = cc.c3b(252, 242, 181), size = 20})
    totalP:pos(pos+475+totalP:getContentSize().width/2,75)
    totalP:addTo(cell)

    local pos = 680
    -- local addBtn
    -- if not "是否是好友" then
        -- addBtn = CommonButton.yellow("添加好友", {color = cc.c3b(252, 242, 181)})
        -- :onButtonClicked(function ()
        --     print("添加好友")
        -- end)
        -- :pos(pos-120,30)
        -- :addTo(cell)
        -- :scale(0.7)
    -- else
    --     addBtn = CommonButton.yellow("删除好友", {color = cc.c3b(252, 242, 181)})
    --     :onButtonClicked(function ()
    --         print("删除好友")
    --     end)
    --     :pos(pos-120,30)
    --     :addTo(cell)
    --     :scale(0.7)
    -- end

  --   local checkBtn = CommonButton.yellow("查看", {color = cc.c3b(252, 242, 181)})
  --   :onButtonClicked(function ()
  --       self.delegate:createUnionMemberLayer()
		-- 	  print("查看")
		-- end)
		-- :pos(pos,30)
		-- :addTo(cell)
  --   :scale(0.7)

    if UnionListData:getUnionDuty() == "1" then
        if data.id ~= UserData.userId then
            -- addBtn:setPosition(pos- 240, 30)
            -- checkBtn:setPosition(pos- 120, 30)

            CommonButton.yellow("管理", {color = cc.c3b(252, 242, 181)})
            :onButtonClicked(function ()
                self.delegate:createUnionFucLayer(data)
                print("管理")
            end)
            :pos(pos,30)
            :addTo(cell)
            :scale(0.7)
        end
    elseif UnionListData:getUnionDuty() == "2" then
        if data.id == UserData.userId then
        elseif data.duty == "1" then
        else
            -- addBtn:setPosition(pos- 240, 30)
            -- checkBtn:setPosition(pos- 120, 30)

            CommonButton.yellow("管理", {color = cc.c3b(252, 242, 181)})
            :onButtonClicked(function ()
                self.delegate:createUnionFucLayer(data)
                print("管理")
            end)
            :pos(pos,30)
            :addTo(cell)
            :scale(0.7)
        end
    elseif UnionListData:getUnionDuty() == "3" then
        if data.id == UserData.userId then
        elseif data.duty == "1" then
        elseif data.duty == "2" then
        else
            -- addBtn:setPosition(pos- 240, 30)
            -- checkBtn:setPosition(pos- 120, 30)

            CommonButton.yellow("管理", {color = cc.c3b(252, 242, 181)})
            :onButtonClicked(function ()
                self.delegate:createUnionFucLayer(data)
                print("管理")
            end)
            :pos(pos,30)
            :addTo(cell)
            :scale(0.7)
        end
    end

    return cell
end

function UnionHallLayer:updateData()

    self.unionData = UnionListData.unionData
    self.unionMemberData = {}
    for i,v in ipairs(UnionListData.unionMemberData) do
        table.insert(self.unionMemberData, v)
    end
    self.unionDes_ = self.unionData.info

    self.unionExp = tonumber(self.unionData.exp)
    self.unionExp_ = {
        vip = UnionListData:getLevel(self.unionExp),  -- 当前VIP经验下的VIP等级
        vipMax = UnionListData:getUnionLevelMax(),   -- 最大VIP等级
        exp = self.unionExp,
        expMax = UnionListData:getExpMax(self.vipExp), --下一级对应的经验
    }

    if self.unionExp > UnionListData:getUnionExpMax() then
        self.unionExp_.expMax = UnionListData:getUnionExpMax()  --下一级对应的经验
    end
end

-- 更新基本信息  头像、说明、成员数量
function UnionHallLayer:updateUnionDes()
    -- 公会头像
    self.unionIcon:setTexture(self.unionData.icon)
    -- 公会名称 人数
    local member_ = self.unionData.name.."（"..self.unionData.memberNums.."/"..self.unionData.memberMaxNums.."）"
    self.unionName:setString(member_)
    -- 公会等级
    local unionLevel = UnionListData:getLevel(tonumber(self.unionData.exp))
    self.unionLv:setString("公会等级："..unionLevel)
    -- 公会签名
    self.changeAd:setButtonLabelString(self.unionDes_)
end

-- 更新经验条
function UnionHallLayer:updateUnionSlider()
    if self.unionExp_.vip < self.unionExp_.vipMax then
        local scale = self.unionExp_.exp / self.unionExp_.expMax
        self.unionSlider_:setScaleX(scale)
        self.unionExpLabel_:setString(string.format("%d/%d", self.unionExp_.exp, self.unionExp_.expMax))
    else
        self.unionSlider_:setScaleX(1)
        self.unionExpLabel_:setString(self.unionExp_.exp.."/"..self.unionExp_.expMax)
    end
end

-- 更新管理 退出按钮
function UnionHallLayer:updateManageBtn()
    if self.hallBtn then
        self.hallBtn:removeFromParent()
        self.hallBtn = nil
    end
    if UnionListData:getUnionDuty() ~= "4" then
        self.hallBtn = CommonButton.yellow("公会管理", {size = 24,color = cc.c3b(252, 242, 181)})
            :onButtonClicked(function ()
                self.delegate:createUnionManageLayer()
            end)
            :pos(755,385)
            :addTo(self.backView,3)
            :scale(0.9)

        if #UnionListData.applyData > 0 then
            self.hallRedPoint:setVisible(true)
        else
            self.hallRedPoint:setVisible(false)
        end
    elseif UnionListData:getUnionDuty() == "4" then
        self.hallBtn = CommonButton.yellow("退出公会", {size = 24,color = cc.c3b(252, 242, 181)})
        :onButtonClicked(function ()
            AlertShow.show2("提示", "确定退出公会？", "确定", function(event)
                NetHandler.gameRequest("SecedeUnion")
            end, function()
            end)
        end)
        :pos(755,385)
        :addTo(self.backView,3)
        :scale(0.9)
    end
end

function UnionHallLayer:updateView()
    self:updateManageBtn()
    self:updateUnionDes()
    self:updateUnionSlider()

    self.listView:reloadData()
end

return UnionHallLayer