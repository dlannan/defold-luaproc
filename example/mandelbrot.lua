local tinsert = table.insert

-- A mandelbrot zoomer that uses multiple processes for generating each frame.
-- Make a palette lookup table so these are our mapped indexes.
local NUM_COLORS     = 256

local palette = {
}

local radstep = (math.pi * 2.0) / (NUM_COLORS - 1)
local radoffset = math.rad(120)
local ang = 0.0
for i=2, NUM_COLORS do
    palette[i] = { 
        r = math.floor((math.sin(ang) * 0.5 + 0.5) * 255.0), 
        g = math.floor((math.sin(ang+radoffset) * 0.5 + 0.5) * 255.0), 
        b = math.floor((math.sin(ang+radoffset + radoffset) * 0.5 + 0.5) * 255.0),
    }
    ang = ang + radstep
end
palette[1] = { r = 0, g = 0, b = 0 }

local mandel = {
    frames     = {},        -- Keep the raw frames here (these are pure char buffers)
    current    = 1,         -- The current frame being rendered to the screen
    queued     = {},        -- The current frames that have been rendered waiting for output
    model_quad = "/mandel#model",
}

local function makeframebuffer( id, width, height, notex )

    local newframe = {
        width = width ,
        height = height - 1,
        buffer = {},
        extents = {
            tl = {x = -2.2, y = -1.4, },
            br = {x = 1.1, y = 1.4 },
        }
        -- extents = {
        --     tl = { x = -1.0, y = -0.2, },
        --     br = { x = -0.5, y = 0.1 },
        -- }                
    }

    newframe.calcextents = function ( self )
        self.extents.wide = self.extents.br.x - self.extents.tl.x 
        self.extents.high = self.extents.br.y - self.extents.tl.y
        self.extents.xscale = (self.width-1) / self.extents.wide
        self.extents.yscale = (self.height-1) / self.extents.high 
    end

    newframe:calcextents()
    newframe.setextents = function(self, ext )
        self.extents.tl = { x= ext.x1, y = ext.y1 }
        self.extents.br = { x= ext.x2, y = ext.y2 }
        self:calcextents()
    end

    if(notex == nil) then 
        newframe.buffer_info = {
            buffer = buffer.create(width * height, {{
                name = hash("rgb"), 
                type = buffer.VALUE_TYPE_UINT8, 
                count = 3
            }}),
            width = width,
            height = height,
            channels = 3,
        }

        newframe.header = {
            width = width, 
            height = height, 
            type = resource.TEXTURE_TYPE_2D, 
            format = resource.TEXTURE_FORMAT_RGB, 
            num_mip_maps = 1
        }

        newframe.new_resource_path = "/mandel"..id.."_image.texturec"
        local newres = resource.create_texture(newframe.new_resource_path, newframe.header)

        newframe.imagestream = buffer.get_stream(newframe.buffer_info.buffer, hash("rgb"))
    end

    -- Set the buffer to black before using
    for y=0,height-1 do
        for x=0,width-1 do
            local index = y * width * 3 + x * 3 + 1
            newframe.buffer[index + 0] = 0
            newframe.buffer[index + 1] = 0
            newframe.buffer[index + 2] = 0
        end
    end

    newframe.get_pixel = function(self, x, y)
        if(x < self.extents.tl.x or x > self.extents.br.x) then return nil, nil end
        if(y < self.extents.tl.y or y > self.extents.br.y) then return nil, nil end
        local x = (x - self.extents.tl.x) * self.extents.xscale
        local y = (y - self.extents.tl.y) * self.extents.yscale
        return math.floor(x), math.floor(y)
        --return x, y
    end

    -- Write stored char array to imagestream (outside proc)
    newframe.write_buffer = function(self)

        -- Set the buffer to black before using
        for idx=1, height * width * 3 do
            self.imagestream[idx] = self.buffer[idx]
        end
    end

    newframe.draw_pixel = function(self, A, B, K)
        -- newframe.imagestream = buffer.get_stream(newframe.buffer_info,buffer, hash("rgb"))
        local L = math.abs(K) % (NUM_COLORS-1) + 1
        if(L < 1) then L = 1 end
        if(K == 1) then L = 1 end
        local col = palette[L]

        local X1, Y1 = self:get_pixel(A, B)
        if(X1 ~= nil) then 
            local index1 = Y1 * self.width * 3 + X1 * 3 + 1
            newframe.buffer[index1 + 0] = col.r
            newframe.buffer[index1 + 1] = col.g
            newframe.buffer[index1 + 2] = col.b
        end

        -- local X2, Y2 = self:get_pixel(A, -B)
        -- if(X2 ~= nil) then 
        --     local index2 =  Y2 * self.width * 3 + X2 * 3 + 1
        --     newframe.imagestream[index2 + 0] = col.r
        --     newframe.imagestream[index2 + 1] = col.g
        --     newframe.imagestream[index2 + 2] = col.b
        -- end
    end

    return newframe
end

local function setframebuffer( id )
    local framebuff = mandel.frames[id]
    framebuff:write_buffer()
    local resource_path = go.get(mandel.model_quad, "texture0")
    resource.set_texture(resource_path, framebuff.header, framebuff.buffer_info.buffer)
end

-- Setup the frame buffers to write to. 
local function setup( width, height, num_frames, notex )

    for i=1, num_frames do 
        tinsert( mandel.frames, i, makeframebuffer(i, width, height, notex) )
    end
end

local function setmodelquad( quad )
    mandel.model_quad = quad 
end

local function makeframe( id, ext )
    local frame = mandel.frames[id]
    
    if(ext) then frame:setextents( ext ) end

    local N1 = frame.width / 2
    local N2 = frame.height / 2
    local A = 0.0
    local B = 0.0   
    local xzoom = frame.extents.wide * 0.5
    local yzoom = frame.extents.high * 0.5
    local xoffset = xzoom + frame.extents.tl.x
    local yoffset = yzoom + frame.extents.tl.y
        
    for I=-N1, N1 do 
        A = xoffset + xzoom * I/N1
        for J = -N2, N2 do 
            B = yoffset + yzoom * J/N2 
            local U = 4*(A*A + B*B)
            local V = U-2*A+0.25
            if(U + B * A + 15/4 < 0.0) then 
                K=1
                frame:draw_pixel(A, B, K)
            elseif( V-math.sqrt(V)+2*A-1/2 < 0.0 ) then 
                K=1
                frame:draw_pixel(A, B, K)
            else 
                local X=A
                local Y=B
                for K=1, 1000 do 
                    U = X*X 
                    V = Y*Y
                    local W = 2*X*Y 
                    X = U - V + A
                    Y = W + B
                    if(U+V > 16) then 
                        frame:draw_pixel(A, B, K)
                        break;
                    end
                end
            end
        end
    end
end

return {
    setup             = setup, 
    makeframe         = makeframe,
    setframebuffer    = setframebuffer,
    setmodelquad      = setmodelquad,
    frames            = mandel.frames,
}