local assets = require "assets"

local msgbox = {}

function msgbox.new()
	local frame = loveframes.Create("frame")
	frame:SetName("Text")
	frame:SetSize(800, 330)
	frame:Center()

	local list1 = loveframes.Create("list", frame)
	list1:SetPos(5, 30)
	list1:SetSize(243, 265)
	list1:SetPadding(5)
	list1:SetSpacing(5)

	local text1 = loveframes.Create("text")
	text1:SetLinksEnabled(true)
	text1:SetDetectLinks(true)
	text1:SetText( "A buncha stuff" )
	text1:SetShadowColor(200, 200, 200, 255)
	list1:AddItem(text1)

	local colortext = {}
	for i=1, 150 do
	    local r = math.random(0, 255)
	    local g = math.random(0, 255)
	    local b = math.random(0, 255)
	    table.insert(colortext, {color = {r, g, b, 255}, font = assets.FONTS.MAIN })
	    table.insert(colortext, math.random(1, 1000) .. " ")
	end

	local list2 = loveframes.Create("list", frame)
	list2:SetPos(252, 30)
	list2:SetSize(243, 265)
	list2:SetPadding(5)
	list2:SetSpacing(5)

	local text2 = loveframes.Create("text", frame)
	text2:SetPos(255, 30)
	text2:SetLinksEnabled(true)
	text2:SetText(colortext)
	text2.OnClickLink = function(object, text)
	    print(text)
	end
	list2:AddItem(text2)

	local shadowbutton = loveframes.Create("button", frame)
	shadowbutton:SetSize(490, 25)
	shadowbutton:SetPos(5, 300)
	shadowbutton:SetText("Toggle Text Shadow")
	shadowbutton.OnClick = function()
    	text1:SetShadow(not text1:GetShadow())
	    text2:SetShadow(not text2:GetShadow())
	end

end

return msgbox
