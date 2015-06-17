require "Opengl"

GLNodeRect = class( "GLNodeRect", function()
    return gl.glNodeCreate()
end )

function GLNodeRect:create()
    local node = GLNodeRect.new()
    node.__rect_position = {}                   --坐标数据[ { x, y } ]
    node.__rect_texture = {}                    --纹理数据[ { u, v } ]
    node.__rect_params = {}                     --shader参数[ { name, type, value } ]
    node.__rect_program = 'mvp_color'
    node.__rect_texture_id = 0
    
    --node:setContentSize(cc.size(1024, 1024))
    node:setAnchorPoint(0,0)
    node:setPosition( 0, 0 )
    
    function node:createBuffer()
        node.__rect_vertexBuffer = {}
        node.__rect_vertexBuffer.position_id = gl.createBuffer()
        node.__rect_vertexBuffer.texture_id = gl.createBuffer()
    end
    
    function node:deleteBuffer()
        gl.deleteBuffer( node.__rect_vertexBuffer.position_id )
        gl.deleteBuffer( node.__rect_vertexBuffer.texture_id )
        node.__rect_vertexBuffer = nil
    end
    
    function node:clear()
        node.__rect_position = {}
        node.__rect_texture = {}
        node.__rect_params = {}
    end
    
    function node:setTexture( name )
        node.__rect_texture_id = name
    end
    
    function node:drawRect( width, height )
        node.__rect_position = 
        { 
            0, 0,
            0, height,
            width, height,
            0, 0,
            width, height,
            width, 0
        }
        
        node.__rect_texture = 
        { 
            0, 0,
            0, 1,
            1, 1,
            0, 0,
            1, 1,
            1, 0
        }
    end
    
    function node:setProgramName( name )
        node.__rect_program = name
    end
    
    function node:setUniformData( name, type, data )
        node.__rect_params[ #node.__rect_params + 1 ] = { name = name, type = type, data = data }
    end
    
    local function onDraw( transform, transformUpdated )
        local program = ProgramMgr.loadProgram( node.__rect_program )
        
        --填充坐标数据
        gl.bindBuffer( gl.ARRAY_BUFFER, node.__rect_vertexBuffer.position_id )
        gl.bufferData( gl.ARRAY_BUFFER, #node.__rect_position, node.__rect_position, gl.STATIC_DRAW )
        
        gl.bindBuffer( gl.ARRAY_BUFFER, node.__rect_vertexBuffer.texture_id )
        gl.bufferData( gl.ARRAY_BUFFER, #node.__rect_texture, node.__rect_texture, gl.STATIC_DRAW )
        
        gl.bindBuffer( gl.ARRAY_BUFFER, 0 )
        
        --设置渲染基本参数
        program:use()
        program:setUniformsForBuiltins()
        program:setUniformLocationWithMatrix4fv( gl.getUniformLocation( program:getProgram(), 'u_transform' ), transform, 1 )
        
        --填充shader
        for key, var in ipairs( node.__rect_params ) do
            local location = gl.getUniformLocation( program:getProgram(), var.name )
            
            if var.type == 'vec4' then
                program:setUniformLocationF32( location, var.data[1], var.data[2], var.data[3], var.data[4] )
            elseif var.type == 'vec3' then
                program:setUniformLocationF32( location, var.data[1], var.data[2], var.data[3] )
            elseif var.type == 'vec2' then
                program:setUniformLocationF32( location, var.data[1], var.data[2] )
            elseif var.type == 'vec1' then
                program:setUniformLocationF32( location, var.data[1] )
            elseif var.type == 'mat4' then
                program:setUniformLocationWithMatrix4fv( location, var.data, 1 )
            end
        end
        
        --渲染矩型
        gl.glEnableVertexAttribs( 5 )
        gl.bindTexture( gl.TEXTURE_2D, node.__rect_texture_id )
        
        gl.bindBuffer( gl.ARRAY_BUFFER, node.__rect_vertexBuffer.position_id )
        gl.vertexAttribPointer( cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0 )
        
        gl.bindBuffer( gl.ARRAY_BUFFER, node.__rect_vertexBuffer.texture_id )
        gl.vertexAttribPointer( cc.VERTEX_ATTRIB_TEX_COORD, 2, gl.FLOAT, false, 0, 0 )
        
        gl.drawArrays( gl.TRIANGLES, 0, 6 )
        
        gl.bindTexture( gl.TEXTURE_2D, 0 )
        gl.bindBuffer( gl.ARRAY_BUFFER, 0 )
    end
    
    --注册回调渲染
    node:registerScriptDrawHandler( onDraw )
    
    return node
end

--[[
    require "lua/display/GLNodeLine"
    local node = GLNodeLine:create()
    node:createBuffer()
    node:drawLine( { 0, 0 }, { 500, 500 } )
    node:drawLine( { 800, 200 }, { 500, 500 } )
    node:setUniformData( 'u_color', 'vec4', { 1.0, 0, 0, 1.0 } )
    scene:addChild( node )
    
    -----------------------------------------------------------------
    
    local x1 = 100
    local y1 = 100
    local x2 = 500
    local y2 = 700
    
    local image = cc.Image:new()
    image:initWithImageFile( 'image/test.png' )
    
    local texture = cc.Texture2D:new()
    texture:retain()
    texture:initWithImage( image )
    
    require "lua/display/GLNodeRect"
    local node = GLNodeRect:create()
    node:setPosition( 100, 100 )
    node:createBuffer()
    node:drawRect( 700, 700 )
    node:setTexture( texture:getName() )
    node:setProgramName( 'test' )
    node:setUniformData( 'u_line', 'vec3', { x2 - x1, y1 - y2, ( y2 - y1 ) * x1 - y1 * ( x2 - x1 ) } )
    node:setUniformData( 'u_size', 'vec2', { 700, 700 } )
    node:setUniformData( 'u_width', 'vec1', {30} )
    scene:addChild( node )
--]]