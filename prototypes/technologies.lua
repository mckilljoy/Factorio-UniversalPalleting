data:extend(
{
  {
    type = "technology",
    name = "universal-palleting",
    icon = "__UniversalPalleting__/graphics/icons/pallet.png",
    icon_size = 64,
    prerequisites =
    {
      "steel-processing",
      "logistics-2",
      "automation-2"
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "empty-pallet"
      },
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
      },
      time = 15
    },
    order = "a-f-c",
  }
}
)