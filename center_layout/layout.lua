local tag = require("awful.tag")
local client = require("awful.client")
local ipairs = ipairs
local math = math
local naughty = require("naughty")

local capi =
{
    mouse = mouse,
    screen = screen,
    mousegrabber = mousegrabber
}

local function set_client_pos(client, x, y, w, h, useless_gap)
    g = {
        width = w-useless_gap*4,
        height = h-useless_gap*4,
        x = x+useless_gap,
        y = y+useless_gap
    }

    client:geometry(g)
    client.size_hints_honor = false
end

local function do_center(param, first_column)
    local start_left = first_column == "left"

    local t = param.tag or capi.screen[param.screen].selected_tag

    local gs = param.geometries
    local cls = param.clients
    local useless_gap = param.useless_gap
    local nmaster = math.min(t.master_count, #cls, 2)
    local nother = math.max(#cls - nmaster,0)

    local mwfact = t.master_width_factor
    local wa = param.workarea
    local ncol = math.max(math.min(t.column_count, 2), 1)
    
    local master_total_width = wa.width*mwfact
    local master_width = master_total_width/nmaster

    local master_offset = 0
    
    if start_left then
        master_offset = wa.width*(1-mwfact)
    end

    if ncol > 1 then
        master_offset = wa.width*(1-mwfact)/2.0
    end

    local fc_clients_cnt = math.ceil(nother/ncol)
    local sc_clients_cnt = nother-fc_clients_cnt
    
    local fc_height = wa.height / fc_clients_cnt
    local sc_height = wa.height / sc_clients_cnt

    local fc_offset = master_offset + master_total_width
    
    local column_width = (wa.width - master_total_width)
    if ncol > 1 then
        column_width = column_width/2
    end

    local fc_h_offset = 0
    local sc_h_offset = 0

    for k,c in ipairs(cls) do
        if k <= nmaster then --master
            set_client_pos(c, wa.x + master_offset, wa.y, master_width, wa.height, useless_gap)
            master_offset = master_offset + master_width
        elseif k-nmaster <= fc_clients_cnt then
            if start_left then
                set_client_pos(c, wa.x , wa.y + fc_h_offset, column_width, fc_height, useless_gap)
            else
                set_client_pos(c, wa.x + fc_offset, wa.y + fc_h_offset, column_width, fc_height, useless_gap)
            end
            fc_h_offset = fc_h_offset + fc_height
        else
            if start_left then
                set_client_pos(c, wa.x + fc_offset, wa.y + sc_h_offset, column_width, sc_height, useless_gap)
            else
                set_client_pos(c, wa.x , wa.y + sc_h_offset, column_width, sc_height, useless_gap)
            end
            sc_h_offset = sc_h_offset + sc_height
        end
    end
end


local function do_center_left(param)
    do_center(param, "left")
end

local function do_center_right(param)
    do_center(param, "right")
end

local center = {
    name = "center",
    arrange = do_center_left
}

center.start_left = {
    name = "center",
    arrange = do_center_left
}

center.start_right = {
    name = "center",
    arrange = do_center_right
}

return center