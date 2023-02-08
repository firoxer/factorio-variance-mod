function gaussian_random(stdev)
  local u = 1 - math.random()
  local v = math.random()
  local z = math.sqrt(-2.0 * math.log(u)) * math.cos(2.0 * math.pi * v);
  return z * stdev
end

local variance_pool = {}
local variance_pool_size = 1024

local function fill_variances()
  local stdev = settings.global["crafting-variance-stdev"].value
  for i = 1, variance_pool_size do
    variance_pool[i] = gaussian_random(stdev)
  end
end

script.on_init(fill_variances)
script.on_event(defines.events.on_runtime_mod_setting_changed, fill_variances)

local entity_filter = {
  name = {
    "assembling-machine-1",
    "assembling-machine-2",
    "assembling-machine-3",

    "stone-furnace",
    "steel-furnace",
    "electric-furnace",

    "oil-refinery",
    "chemical-plant",

    "centrifuge",
  }
}

local tick_count = math.huge -- To trigger variance assignment immediately
local entities = {}
local variance_per_entity = {}

script.on_event(defines.events.on_tick, function()
  tick_count = tick_count + 1

  -- Per-entity variances get stored in a table as a sort of a cache
  -- because otherwise math.random would (presumably) get called a lot
  -- TODO: Check if this actually helps
  if tick_count >= settings.global["crafting-variance-change-frequency"].value then
    entities = game.surfaces.nauvis.find_entities_filtered(entity_filter)

    -- TODO: Rolling updates
    for _, entity in ipairs(entities) do
      variance_per_entity[entity] = variance_pool[math.random(variance_pool_size)]
    end
    
    tick_count = 0
  end

  for _, entity in ipairs(entities) do
    if entity.valid and entity.is_crafting() and variance_per_entity[entity] then
      entity.crafting_progress = math.max(
        entity.crafting_progress + (entity.crafting_speed / 60 / entity.get_recipe().energy) * variance_per_entity[entity],
        0.000001 -- With 0, crafting would get cancelled altogether
      )
    end
  end
end)
