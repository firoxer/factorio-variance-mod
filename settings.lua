data:extend({
  {
    type = "double-setting",
    name = "crafting-variance-stdev",
    setting_type = "runtime-global",
    default_value = 0.2,
    minimum_value = 0,
    maximum_value = 5
  },
  {
    type = "int-setting",
    name = "crafting-variance-change-frequency",
    setting_type = "runtime-global",
    default_value = 60,
    minimum_value = 1,
    maximum_value = 600
  }
})
