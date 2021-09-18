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
        x = x+useless_gap,
        y = y+useless_gap,
        width = w-useless_gap*2,
        height = h-useless_gap*2
    }

    client:geometry(g)
    client.size_hints_honor = false
end

local function do_center(param, first_column, overlap)
    local start_left = first_column == "left"

    local t = param.tag or capi.screen[param.screen].selected_tag

    local gs = param.geometries
    local cls = param.clients
    local useless_gap = param.useless_gap
    local nmaster = math.min(t.master_count, #cls, 2)
    local nother = math.max(#cls - nmaster,0)

    local mwfact = t.master_width_factor
    local wa = param.workarea
    local ncol = t.column_count
    
    local master_total_width = wa.width*mwfact
    local master_width = master_total_width/nmaster

    local master_offset = (wa.width*(1-mwfact)/2.0)
    
    local fc_clients_cnt = ncol
    local sc_clients_cnt = nother-fc_clients_cnt
    
    local fc_height = wa.height / fc_clients_cnt
    local sc_height = wa.height / sc_clients_cnt

    local fc_offset = master_offset + master_total_width
    
    local column_width = (wa.width - master_total_width)/2
    
    local overlap_size = master_total_width*overlap

    local fc_h_offset = 0
    local sc_h_offset = 0
    
    for k,c in ipairs(cls) do
        if k <= nmaster then --master
            set_client_pos(c, wa.x + master_offset - overlap_size, wa.y, master_width + overlap_size*2, wa.height, useless_gap)
            master_offset = master_offset + master_width
        elseif k-nmaster <= fc_clients_cnt then
            if start_left then
                set_client_pos(c, wa.x , wa.y + fc_h_offset, column_width+overlap_size, fc_height, useless_gap)
            else
                set_client_pos(c, wa.x + fc_offset, wa.y + fc_h_offset, column_width+overlap_size, fc_height, useless_gap)
            end
            fc_h_offset = fc_h_offset + fc_height
        else
            if start_left then
                set_client_pos(c, wa.x + fc_offset - overlap_size, wa.y + sc_h_offset, column_width+overlap_size, sc_height, useless_gap)
            else
                set_client_pos(c, wa.x , wa.y + sc_h_offset, column_width+overlap_size, sc_height, useless_gap)
            end
            sc_h_offset = sc_h_offset + sc_height
        end
    end
end


local function do_center_left(param)
    do_center(param, "left", 0)
end

local function do_center_right(param)
    do_center(param, "right", 0)
end

local function do_center_left_overlap(param)
    do_center(param, "left", 0.2)
end

local function do_center_right_overlap(param)
    do_center(param, "right", 0.2)
end

local center = {
    name = "cntr.L",
    arrange = do_center_left
}

center.start_left = {
    name = "cntr.L",
    arrange = do_center_left
}

center.start_right = {
    name = "cntr.R",
    arrange = do_center_right
}

center.start_left_overlap = {
    name = "cntr.LO",
    arrange = do_center_left_overlap
}

center.start_right_overlap = {
    name = "cntr.RO",
    arrange = do_center_right_overlap
}

return center