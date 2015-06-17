-- weihao
local prePath = "image/ui/ChatUI/"
ChatRefresh = class("ChatRefresh",function() 
    return getLayout(prePath .. "Refresh.ExportJson")
end)

function ChatRefresh:ctor()

end 

function ChatRefresh:change(world)
   self.txt_words:setString(world)
end 

function ChatRefresh:createView()
   local view = ChatRefresh.new()
   return view
end 