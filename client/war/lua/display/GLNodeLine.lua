require "Opengl"

GLNodeLine = class( "GLNodeLine", function()
    return gl.glNodeCreate()
end )

function GLNodeLine:create()
    local node = GLNodeLine.new()
    node.__line_data = {}                       --线条数据[ { x, y } ]
    node.__line_params = {}                     --shader参数[ { name, type, value } ]
    node.__line_program = 'mvp_color'
    
    --node:setContentSize(cc.size(1024, 1024))
    node:setAnchorPoint(0,0)
    node:setPosition( 0, 0 )
    
    function node:createBuffer()
        node.__line_vertexBuffer = { buffer_id = gl.createBuffer() }
    end
    
    function node:deleteBuffer()
        gl.deleteBuffer( node.__line_vertexBuffer.buffer_id )
        node.__line_vertexBuffer = nil
    end
    
    function node:clear()
        node.__line_data = {}
        node.__line_params = {}
    end
    
    function node:drawLine( src, des )
        node.__line_data[ #node.__line_data + 1 ] = src[1];
        node.__line_data[ #node.__line_data + 1 ] = src[2];
        node.__line_data[ #node.__line_data + 1 ] = des[1];
        node.__line_data[ #node.__line_data + 1 ] = des[2];
    end
    
    function node:setProgramName( name )
        node.__line_program = name
    end
    
    function node:setUniformData( name, type, data )
        node.__line_params[ #node.__line_params + 1 ] = { name = name, type = type, data = data }
    end
    
    local function onDraw( transform, transformUpdated )
        local program = ProgramMgr.loadProgram( node.__line_program )
        
        --填充线条数据
        gl.bindBuffer( gl.ARRAY_BUFFER, node.__line_vertexBuffer.buffer_id )
        gl.bufferData( gl.ARRAY_BUFFER, #node.__line_data, node.__line_data, gl.STATIC_DRAW )
        gl.bindBuffer( gl.ARRAY_BUFFER, 0 )
        
        --设置渲染基本参数
        program:use()
        program:setUniformsForBuiltins()
        
        gl.glEnableVertexAttribs( cc.VERTEX_ATTRIB_FLAG_POSITION )
        program:setUniformLocationWithMatrix4fv( gl.getUniformLocation( program:getProgram(), 'u_transform' ), transform, 1 )
        
        --填充shader
        for key, var in ipairs( node.__line_params ) do
            local location = gl.getUniformLocation( program:getProgram(), var.name )
            
            if var.type == 'vec4' then
                program:setUniformLocationF32( location, var.data[1], var.data[2], var.data[3], var.data[4] )
            elseif var.type == 'mat4' then
                program:setUniformLocationWithMatrix4fv( location, var.data, 1 )
            end
        end
        
        --渲染线条
        local lineSum = #node.__line_data / 2
        gl.bindBuffer( gl.ARRAY_BUFFER, node.__line_vertexBuffer.buffer_id )
        gl.vertexAttribPointer( cc.VERTEX_ATTRIB_POSITION, 2, gl.FLOAT, false, 0, 0 )
        gl.drawArrays( gl.LINES, 0, lineSum )
        gl.bindBuffer( gl.ARRAY_BUFFER,0 )
    end
    
    --注册回调渲染
    node:registerScriptDrawHandler( onDraw )
    
    return node
end