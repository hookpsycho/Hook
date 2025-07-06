local Hook = getgenv().Hook or {
    OriginalNameCall = nil,
    OriginalFireServer = nil,
    OriginalInvokeServer = nil,
    OriginalUnreliableFireServer = nil,
    OriginalKick = nil,
    OriginalFire = nil,
    NameCall = nil,
    CurrentMethod = nil
}

--// Utility
function Hook:GetNameCallMethod()
    return self.CurrentMethod
end

--// NameCall
Hook.OriginalNameCall = Hook.OriginalNameCall or hookfunction(
    getrawmetatable(game).__namecall,
    clonefunction(newcclosure(function(...)
        local Method = Hook:GetNameCallMethod()
        Hook.CurrentMethod = Method
        return Hook.NameCall(...)
    end))
)

--// FireServer
Hook.OriginalFireServer = Hook.OriginalFireServer or hookfunction(
    Instance.new('RemoteEvent').FireServer,
    clonefunction(newcclosure(function(...)
        Hook.CurrentMethod = 'FireServer'
        return Hook.NameCall(...)
    end))
)

--// Unreliable FireServer
Hook.OriginalUnreliableFireServer = Hook.OriginalUnreliableFireServer or hookfunction(
    Instance.new('UnreliableRemoteEvent').FireServer,
    clonefunction(newcclosure(function(...)
        Hook.CurrentMethod = 'FireServer'
        return Hook.NameCall(...)
    end))
)

--// InvokeServer
Hook.OriginalInvokeServer = Hook.OriginalInvokeServer or hookfunction(
    Instance.new('RemoteFunction').InvokeServer,
    clonefunction(newcclosure(function(...)
        Hook.CurrentMethod = 'InvokeServer'
        return Hook.NameCall(...)
    end))
)

--// Kick
Hook.OriginalKick = Hook.OriginalKick or hookfunction(
    Instance.new('Player').Kick,
    clonefunction(newcclosure(function(...)
        Hook.CurrentMethod = 'Kick'
        return Hook.NameCall(...)
    end))
)

--// BindableEvent.Fire
Hook.OriginalFire = Hook.OriginalFire or hookfunction(
    Instance.new('BindableEvent').Fire,
    clonefunction(newcclosure(function(...)
        Hook.CurrentMethod = 'Fire'
        return Hook.NameCall(...)
    end))
)

--// Core
Hook.NameCall = Hook.NameCall or clonefunction(newcclosure(function(...)
    local Obj = select(1, ...)
    local Method = Hook:GetNameCallMethod()
    local Args = { namecall(...) }

    if Obj and typeof(Obj) == 'Instance' then
        if Method == 'FireServer' then
            if Obj.ClassName == 'UnreliableRemoteEvent' then
                return Hook.OriginalUnreliableFireServer(unpack(Args))
            end
            return Hook.OriginalFireServer(unpack(Args))
        end

        if Method == 'InvokeServer' then
            return Hook.OriginalInvokeServer(unpack(Args))
        end

        if Method == 'Kick' then
            return Hook.OriginalKick(unpack(Args))
        end

        if Method == 'Fire' then
            return Hook.OriginalFire(unpack(Args))
        end
    end

    return Hook.OriginalNameCall(unpack(Args))
end))

--// Compatibility
getgenv().namecall = clonefunction(newcclosure(function(...)
    return ...
end))

return Hook
