local __this = { data = {}, cache = {} }
ProgramMgr = __this

__this.loadProgram = function( name )
    local program = __this.data[ name ]
    if program == nil then
        program = cc.GLProgram:createWithFilenames( 'shader/' .. name .. '.vert', 'shader/' .. name .. '.frag' )
        
        if program == nil then
            LogMgr.log( 'system', 'ProgramMgr.__load_by_name( "' .. name .. '" ) error!' )
            return            
        end 
        
        program:retain()
        __this.data[ name ] = program
    end 

    return program
end

__this.reloadAllProgram = function()
    for name, program in pairs(__this.data) do
        program:reset()
        program:initWithFilenames( 'shader/' .. name .. '.vert', 'shader/' .. name .. '.frag' )
        program:link()
        program:updateUniforms()
    end
end

__this.createProgramState = function( name )
    local state = __this.cache[ name ]
    if not state then
        state = cc.GLProgramState:create( __this.loadProgram( name ) )
    end
    return state
end

__this.clear = function( name )
    local program = __this.data[ name ]
    if program ~= nil then
        program:release()
        __this.data[ name ] = nil
    end
end

local function createProgramStateCache( name )
    local state = __this.createProgramState( name )
    state:retain()

    __this.cache[ name ] = state
end
createProgramStateCache( 'banish' )
createProgramStateCache( 'gray' )
createProgramStateCache( 'normal' )

function __this.setState(renderer, state)
    if renderer.setGLProgramStateChildren then
        renderer:setGLProgramStateChildren(state)
    else
        renderer:setGLProgramState(state)
    end
end

function __this.setNormal(node)
    if node.getVirtualRenderer then
        node = node:getVirtualRenderer()
    end
    __this.setState(node, ProgramMgr.createProgramState('normal'))
end

function __this.setGray(node)
    if node.getVirtualRenderer then
        node = node:getVirtualRenderer()
    end
    __this.setState(node, ProgramMgr.createProgramState('gray'))

end

function __this.setLight(node, uniform)
    local shaderName = "light"

    local programState = ProgramMgr.createProgramState(shaderName)
    if uniform then
        programState:setUniformFloat("u_multiple", uniform)
    end
    local isCCUI = (string.find(tolua.type(node), "ccui.") == 1)
    if isCCUI == true then
        local render = node:getVirtualRenderer()
        if tolua.type(render) ~= "cc.Label" then
            if render ~= nil then
                render:setGLProgramState( programState )
            end
            local list = node:getChildren()
            for _, v in pairs(list) do
                __this.setLight(v, uniform)
            end
        end
    end
end
