-- language: luau, file: NovaUI/Core/Maid.luau
local Maid = {}
Maid.__index = Maid

function Maid.new()
    local self = setmetatable({}, Maid)
    self._tasks = {}
    return self
end

function Maid:GiveTask(task)
    if not task then return task end
    table.insert(self._tasks, task)
    return task
end

function Maid:DoCleaning()
    local tasks = self._tasks
    self._tasks = {}

    for _, task in ipairs(tasks) do
        if typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif typeof(task) == "function" then
            task()
        elseif typeof(task) == "table" and typeof(task.Destroy) == "function" then
            task:Destroy()
        end
    end
end

function Maid:Destroy()
    self:DoCleaning()
end

return Maid
