GRID_WIDTH = 16
GRID_HEIGHT = 8
selected_octave = 0
BASE_NOTE = 48 + selected_octave * 12


local scales = {
  {abbrev="Mj",size=7,degrees={0,2,4,5,7,9,11}},{abbrev="Mi",size=7,degrees={0,2,3,5,7,8,10}},
  {abbrev="Do",size=7,degrees={0,2,3,5,7,9,10}},{abbrev="Ph",size=7,degrees={0,1,3,5,7,8,10}},
  {abbrev="Ly",size=7,degrees={0,2,4,6,7,9,11}},{abbrev="Mx",size=7,degrees={0,2,4,5,7,9,10}},
  {abbrev="Pt",size=5,degrees={0,2,4,7,9}},     {abbrev="Hm",size=7,degrees={0,2,3,5,7,8,11}},
  {abbrev="Mm",size=7,degrees={0,2,3,5,7,9,11}},{abbrev="Pd",size=7,degrees={0,1,4,5,7,8,10}},
}
selected_scale = 1
local scale_degrees = scales[1].degrees
local scale_size = scales[1].size
visual_scale_col = 0.0
visual_scale_row = 0.0

local root_note_values = {9,10,11,0,2,3,4,5,7,8}
local root_names = {"A","Bb","B","C","D","Eb","E","F","G","Ab"}
selected_root = 0
visual_root_col = 3.0
visual_root_row = 0.0

velocity = {127,112,96,80,64,32,16,1}
held_notes = {}
local held_note_set = {}
local midi_in_note_set = {}
chord_size = 1
visual_chord_pos = 0.0
ch = 1
vel = 1
alt = 0
visual_octave_pos = 0

overlay_text = ""
overlay_timer = 0

-- 5x5 font (each row = 5-bit value, MSB=left)
local font = {
  A={14,17,31,17,17}, B={30,17,30,17,30}, C={14,16,16,16,14},
  D={30,17,17,17,30}, E={31,16,30,16,31}, F={31,16,30,16,16},
  G={14,16,19,17,15}, H={17,17,31,17,17}, L={16,16,16,16,31},
  M={17,27,21,17,17}, P={30,17,30,16,16},
  b={16,16,30,17,30}, d={1,1,15,17,15},   h={16,16,30,17,17},
  i={4,0,4,4,14},     j={2,0,2,2,12},     m={0,27,21,17,17},
  o={14,17,17,17,14}, t={31,4,4,4,14},    x={17,10,4,10,17},
  y={17,17,14,1,14},
}

local function glide(pos, target)
  local d = target - pos
  if math.abs(d) > 0.01 then return pos + d * 0.25 else return target end
end

local function gauss(dist_sq)
  return math.max(1, math.floor(10 * math.exp(-dist_sq * 0.8)))
end

local function root_semitone_to_index(s)
  for i,v in ipairs(root_note_values) do if v == s then return i end end
  return -1
end

local function root_index_to_colrow(i)
  return (i-1) % 5, math.floor((i-1) / 5)
end

local function get_chord_notes(x, y)
  local base = selected_root >= 9 and BASE_NOTE - 12 or BASE_NOTE
  local total = (x-6) + 3*(GRID_HEIGHT-y)
  local notes = {}
  for i = 0, chord_size-1 do
    local t = total + 2*i
    local degree = (t % scale_size) + 1
    local octave = math.floor(t / scale_size)
    local semitone = scale_degrees[degree] + selected_root
    local n = base + (semitone%12) + (octave + math.floor(semitone/12)) * 12
    if n >= 0 and n <= 127 then notes[#notes+1] = n end
  end
  return notes
end

local BIT_POWERS = {16, 8, 4, 2, 1}

local function draw_text(name, brightness)
  local char_w = 5
  local x0 = GRID_WIDTH - (#name * char_w + #name - 1) + 1
  for i = 1, #name do
    local glyph = font[name:sub(i,i)]
    if glyph then
      local cx = x0 + (i-1) * (char_w+1)
      for row = 1, 5 do
        local bits = glyph[row]
        for col = 0, 4 do
          if math.floor(bits / BIT_POWERS[col+1]) % 2 == 1 then
            grid_led(cx+col, row, brightness)
          end
        end
      end
    end
  end
end

function note(x, y)
  local base = selected_root >= 9 and BASE_NOTE - 12 or BASE_NOTE
  local total = (x-6) + 3*(GRID_HEIGHT-y)
  local degree = (total % scale_size) + 1
  local octave = math.floor(total / scale_size)
  local semitone = scale_degrees[degree] + selected_root
  return base + (semitone%12) + (octave + math.floor(semitone/12)) * 12
end

function draw()
  grid_led_all(0)

  visual_octave_pos = glide(visual_octave_pos, selected_octave)
  visual_chord_pos  = chord_size - 1
  visual_scale_col  = glide(visual_scale_col,  (selected_scale-1) % 5)
  visual_scale_row  = glide(visual_scale_row,  math.floor((selected_scale-1) / 5))

  local target_idx = root_semitone_to_index(selected_root)
  if target_idx > 0 then
    local tc, tr = root_index_to_colrow(target_idx)
    visual_root_col = glide(visual_root_col, tc)
    visual_root_row = glide(visual_root_row, tr)
  end

  if alt == 0 then
    for k in pairs(held_note_set) do held_note_set[k] = nil end
    for _, notes in pairs(held_notes) do
      for _, n in ipairs(notes) do held_note_set[n] = true end
    end

    for y = 1, GRID_HEIGHT do
      for x = 6, GRID_WIDTH do
        local n = note(x, y)
        if n >= 0 and n <= 127 then
          local pos = x*10 + y
          if held_notes[pos] then
            grid_led(x, y, 15)
          elseif held_note_set[n] then
            grid_led(x, y, 8)
          elseif midi_in_note_set[n] then
            grid_led(x, y, 6)
          elseif n % 12 == selected_root then
            grid_led(x, y, 4)
          end
        end
      end
    end

    for y = 1, 2 do
      for x = 1, 5 do
        local dc = (x-1) - visual_scale_col
        local dr = ((y==2) and 0 or 1) - visual_scale_row
        grid_led(x, y, gauss(dc*dc + dr*dr*1.5))
      end
    end

    for x = 1, 5 do
      local d = (x-1) - visual_chord_pos
      local br
      if d <= 0 then br = math.max(4, gauss(d*d)) else br = 0 end
      grid_led(x, 6, br)
    end

    for y = 7, 8 do
      for x = 1, 5 do
        local d = (x-3) - visual_octave_pos
        local dy = y - 7.5
        grid_led(x, y, gauss(d*d + dy*dy*0.3))
      end
    end

    for y = 4, 5 do
      for x = 1, 5 do
        local dc = (x-1) - visual_root_col
        local dr = ((y==5) and 0 or 1) - visual_root_row
        grid_led(x, y, gauss(dc*dc + dr*dr*1.5))
      end
    end

    if overlay_timer > 0 then
      overlay_timer = overlay_timer - 1
      local fade = 1
      if overlay_timer > 65 then fade = (75 - overlay_timer) / 10
      elseif overlay_timer < 20 then fade = overlay_timer / 20 end
      for y = 1, 5 do
        for x = 6, GRID_WIDTH do grid_led(x, y, 0) end
      end
      draw_text(overlay_text, math.max(1, math.floor(fade * 8)))
    end
  end

  grid_refresh()
end

event_grid = function(x, y, z)
  if z == 0 then
    if x >= 6 then
      local pos = x*10 + y
      local notes = held_notes[pos]
      if notes then
        for _, n in ipairs(notes) do midi_note_off(n, 0, ch) end
        held_notes[pos] = nil
      end
    else
      overlay_timer = 0
    end
    return
  end

  if x >= 6 and x <= 16 and y >= 1 and y <= 8 then
    local pos = x*10 + y
    local notes = get_chord_notes(x, y)
    if #notes > 0 then
      for _, n in ipairs(notes) do midi_note_on(n, velocity[vel], ch) end
      held_notes[pos] = notes
    end
  elseif x >= 1 and x <= 5 then
    if y == 1 or y == 2 then
      local idx = (y==2) and x or (x+5)
      selected_scale = idx
      scale_degrees = scales[idx].degrees
      scale_size = scales[idx].size
      overlay_text = scales[idx].abbrev
      overlay_timer = 75
    elseif y == 4 or y == 5 then
      local idx = (y==5) and x or (x+5)
      selected_root = root_note_values[idx]
      overlay_text = root_names[idx]
      overlay_timer = 75
    elseif y == 6 then
      chord_size = x
    elseif y == 7 or y == 8 then
      selected_octave = x - 3
      BASE_NOTE = 48 + selected_octave * 12
    end
  end
end

event_midi = function(byte1, byte2, byte3)
  local msg = midi_to_msg({byte1, byte2, byte3})
  if msg.type == "note_on" and msg.vel > 0 then
    midi_in_note_set[msg.note] = true
  elseif msg.type == "note_off" or (msg.type == "note_on" and msg.vel == 0) then
    midi_in_note_set[msg.note] = nil
  end
end

m = metro.init(draw, 1/30)
m:start()
