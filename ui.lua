local mod_path = SMODS.current_mod.path

SMODS.DrawStep({
    key = "floating_sprite2",
    order = 100,
    func = function(self)
        if self.config.center.soul_pos and self.config.center.soul_pos.extra and (self.config.center.discovered or self.bypass_discovery_center) then
            
            local scale_mod = 0.07
            local rotate_mod = 0
            
            if not self.children.floating_sprite2 then
                self.children.floating_sprite2 = Sprite(
                    self.T.x,
                    self.T.y,
                    self.T.w,
                    self.T.h,
                    G.ASSET_ATLAS[self.config.center.atlas or self.config.center.set],
                    self.config.center.soul_pos.extra
                )
                self.children.floating_sprite2.role.draw_major = self
                self.children.floating_sprite2.states.hover.can = false
                self.children.floating_sprite2.states.click.can = false
            end

            self.children.floating_sprite2:draw_shader("dissolve", 0, nil, nil, self.children.center, scale_mod, rotate_mod, nil, 0.1, nil, 0.6)
            self.children.floating_sprite2:draw_shader("dissolve", nil, nil, nil, self.children.center, scale_mod, rotate_mod)
        end
    end,
    conditions = { vortex = false, facing = "front" },
})

SMODS.draw_ignore_keys.floating_sprite2 = true

G.effectmanager = G.effectmanager or {}

function LOB_LoadImage(fn)
    local full_path = mod_path .. "customimages/" .. fn
    local file_data = assert(NFS.newFileData(full_path), "Erreur : Fichier image introuvable " .. fn)
    local tempimagedata = love.image.newImageData(file_data)
    return love.graphics.newImage(tempimagedata)
end

function LOB_LoadSpritesheet(fn, px, py, subimg, orientation)
    local full_path = mod_path .. "customimages/" .. fn
    local file_data = assert(NFS.newFileData(full_path), "Erreur : Spritesheet introuvable " .. fn)
    local tempimagedata = love.image.newImageData(file_data)
    local tempimg = love.graphics.newImage(tempimagedata)

    local spritesheet = {}
    for i = 1, subimg do
        if orientation == 0 then
            table.insert(spritesheet, love.graphics.newQuad(0, (i-1)*py, px, py, tempimg:getDimensions()))
        else 
            table.insert(spritesheet, love.graphics.newQuad((i-1)*px, 0, px, py, tempimg:getDimensions()))
        end
    end
    return tempimg, spritesheet
end

function add_lob_effect(name, x, y)
    table.insert(G.effectmanager, {
        {
            name = name,
            xpos = x,
            ypos = y,
            frame = 1,
            max_frames = 17, 
            duration = 100,
            timer = 0
        }
    })
end

local draw_origin = love.draw
function love.draw()
    draw_origin() 

    if G.effectmanager then
        local _xscale = love.graphics.getWidth()/1920
        local _yscale = love.graphics.getHeight()/1080

        for i = #G.effectmanager, 1, -1 do
            local effect = G.effectmanager[i][1]
            
            if effect.name == "explosion" then
                if not G.LOB_img_explosion then
                    G.LOB_img_explosion, G.LOB_quad_explosion = LOB_LoadSpritesheet("explosiongif.png", 200, 282, 17, 0)
                end

                love.graphics.setColor(1, 1, 1, 1)
                local _x = effect.xpos - (100 * _xscale) 
                local _y = effect.ypos - (141 * _yscale)
                
                love.graphics.draw(G.LOB_img_explosion, G.LOB_quad_explosion[effect.frame], _x, _y, 0, _xscale, _yscale)

                effect.timer = effect.timer + 1
                if effect.timer % 2 == 0 then 
                    effect.frame = effect.frame + 1
                end

                if effect.frame > effect.max_frames then
                    table.remove(G.effectmanager, i)
                end
            end
        end
    end
end