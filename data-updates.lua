
require("prototypes.categories")
require("prototypes.items")
require("prototypes.recipes")
require("prototypes.technologies")

local palletize_all_items = settings.startup["palletize-all-items"].value

local custom_tints = 
{
-- raw-resources
  ["raw-wood"] = {r = 100, g = 38, b = 13, a = 255},
  ["coal"] = {r = 31, g = 29, b = 31, a = 255},
  ["stone"] = {r = 93, g = 88, b = 73, a = 255},
  ["iron-ore"] = {r = 27, g = 55, b = 77, a = 255},
  ["copper-ore"] = {r = 165, g = 74, b = 32, a = 255},
  ["uranium-ore"] = {r = 40, g = 89, b = 32, a = 255},
-- raw-materials
  ["wood"] = {r = 179, g = 140, b = 84, a = 255},
  ["iron-plate"] = {r = 125, g = 124, b = 129, a = 255},
  ["copper-plate"] = {r = 212, g = 135, b = 106, a = 255},
  ["solid-fuel"] = {r = 100, g = 96, b = 96, a = 255},
  ["stone-brick"] = {r = 140, g = 137, b = 129, a = 255},
  ["steel-plate"] = {r = 196, g = 207, b = 255, a = 255},
  ["sulfur"] = {r = 206, g = 194, b = 51, a = 255},
  ["plastic-bar"] = {r = 230, g = 231, b = 232, a = 255},
-- intermediate-products
  ["copper-cable"] = {r = 211, g = 146, b = 137, a = 255},
  ["iron-stick"] = {r = 88, g = 96, b = 101, a = 255},
  ["iron-gear-wheel"] = {r = 101, g = 116, b = 142, a = 255},
  ["electronic-circuit"] = {r = 35, g = 147, b = 0, a = 255},
  ["advanced-circuit"] = {r = 169, g = 1, b = 3, a = 255},
  ["processing-unit"] = {r = 63, g = 50, b = 254, a = 255},
  ["engine-unit"] = {r = 225, g = 206, b = 110, a = 255},
  ["electric-engine-unit"] = {r = 224, g = 90, b = 92, a = 255},
  ["battery"] = {r = 249, g = 203, b = 173, a = 255},
  ["explosives"] = {r = 98, g = 42, b = 8, a = 255},
  ["flying-robot-frame"] = {r = 74, g = 76, b = 72, a = 255},
  ["low-density-structure"] = {r = 125, g = 113, b = 94, a = 255},
  ["rocket-fuel"] = {r = 208, g = 189, b = 157, a = 255},
  ["nuclear-fuel"] = {r = 201, g = 255, b = 189, a = 255},
  ["rocket-control-unit"] = {r = 184, g = 187, b = 176, a = 255},
  ["satellite"] = {r = 117, g = 113, b = 207, a = 255},
  ["uranium-235"] = {r = 62, g = 147, b = 51, a = 255},
  ["uranium-238"] = {r = 15, g = 53, b = 29, a = 255},
  ["uranium-fuel-cell"] = {r = 4, g = 219, b = 12, a = 255},
  ["used-up-uranium-fuel-cell"] = {r = 31, g = 80, b = 49, a = 255}
}

function PalletItem(name, icons, subgroup, order, localized_name)
  
  local pallet_item_proto =
  {
    type = "item",
    name = "pallet-" .. name,
    subgroup = subgroup,
    order = order,
    icon_size = 32,
    icons = icons,
    flags = {"goes-to-main-inventory"},
    stack_size = 1,
    localised_name =
    {
      "item-name.item-pallet",
      {
        localized_name
      }
    },
  }
  
  data:extend({pallet_item_proto})
end

function PalletLoad(name, icons, subgroup, order, localized_name, stack_size)
  
  if name ~= "empty-pallet" then
    pallet_ingredient = {type = "item", name = "empty-pallet", amount = 1}
  end
  
  -- Adjust ingredients for very low density items
  local pallet_ingredient_count = 100
  if stack_size <= 10 then
    pallet_ingredient_count = 10
  end
  
  local load_pallet_recipe_proto =
  {
    type = "recipe",
    name = "load-pallet-" .. name,
    subgroup = subgroup,
    order = order,
    energy_required = 1,
    enabled = "false",
    category = "crafting-with-pallets",
    hide_from_stats = true,
    allow_decomposition = false,
    icon_size = 32,
    icons = icons,
    ingredients =
    {
      pallet_ingredient,
      {type = "item", name = name, amount = pallet_ingredient_count}
    },
    results =
    {
      {type = "item", name = "pallet-" .. name, amount = 1}
    },
    localised_name =
    {
      "recipe-name.load-pallet",
      {
        localized_name
      }
    },
  }

  local effects = data.raw["technology"]["universal-palleting"].effects
  table.insert(effects, {type = "unlock-recipe", recipe = load_pallet_recipe_proto.name})
  data:extend({load_pallet_recipe_proto})
end

function PalletUnload(name, icons, subgroup, order, localized_name, stack_size)
  
  if name ~= "empty-pallet" then
    pallet_ingredient = {type = "item", name = "empty-pallet", amount = 1}
  end

  local result_stack_size = 100
  if stack_size <= 10 then
    result_stack_size = 10
  end
  
  results = {pallet_ingredient}
  if stack_size < result_stack_size then
    local stack_remaining = stack_size
    local stack_count = result_stack_size / stack_size
	
	for i=1,stack_count,1 do
	  table.insert(results, {type = "item", name = name, amount = stack_size} )
	  stack_remaining = stack_remaining - result_stack_size
	end
    if stack_remaining > 0 then
	  table.insert(results, {type = "item", name = name, amount = stack_remaining} )
	end
	  
  else
    table.insert(results, {type = "item", name = name, amount = result_stack_size} )
  end
  
  local unload_pallet_recipe_proto =
  {
    type = "recipe",
    name = "unload-pallet-" .. name,
    subgroup = subgroup,
    order = order,
    energy_required = 1,
    enabled = "false",
    category = "crafting-with-pallets",
    hide_from_stats = true,
    allow_decomposition = false,
    icon_size = 32,
    icons = icons,
    ingredients =
    {
      {type = "item", name = "pallet-" .. name, amount = 1}
    },
    results = results,
    localised_name =
    {
      "recipe-name.unload-pallet",
      {
        localized_name
      }
    },
  }

  local effects = data.raw["technology"]["universal-palleting"].effects
  table.insert(effects, {type = "unlock-recipe", recipe = unload_pallet_recipe_proto.name})
  data:extend({unload_pallet_recipe_proto})
end

function PalletizeItem(name, icon, subgroup, order, localized_name, stack_size)

  -- don't palletize pallets or barrels; this will still let empty pallets pass
  if (string.find(name, "pallet") or string.find(name, "barrel")) then
    return
  end
  
  local tint = nil
  if palletize_all_items == false then
    tint = custom_tints[name]
  end

  if icon == nil then
    icon = "__UniversalPalleting__/graphics/icons/empty-pallet.png"
  end

  PalletItem(
    name,
    {
      {
        icon = "__UniversalPalleting__/graphics/icons/empty-pallet.png",
        tint = tint,
      },
      {
        icon = icon,
        scale = 0.5,
        shift = {
          0,
          -2
        }
      }
    },
	"load-pallet-" .. subgroup,
	order,
	localized_name
  )
  
  PalletLoad(
    name,
    {
      {
        icon = "__UniversalPalleting__/graphics/icons/empty-pallet.png",
        tint = tint,
      },
      {
        icon = icon,
        scale = 0.5,
        shift = {
          0,
          -4
        }
      }
    },
	"load-pallet-" .. subgroup,
	order,
	localized_name,
	stack_size
  )
  
  PalletUnload(
    name,
    {
      {
        icon = "__UniversalPalleting__/graphics/icons/empty-pallet.png",
        tint = tint,
      },
      {
        icon = "__UniversalPalleting__/graphics/icons/small-arrow.png",
      },
      {
        icon = icon,
        scale = 0.5,
        shift = {
          7,
          8
        }
      }
    },
	"unload-pallet-" .. subgroup,
	order,
	localized_name,
	stack_size
  )

end

-- make a pallet pallet
PalletItem(
  "empty-pallet",
  {{icon = "__UniversalPalleting__/graphics/icons/empty-pallet-pallet.png"}},
  "pallet",
  "a[empty-pallet]-a[pallet-pallet]",
  "item-name.empty-pallet"
 )

 PalletLoad(
  "empty-pallet",
  {{icon = "__UniversalPalleting__/graphics/icons/empty-pallet-pallet.png"}},
  "pallet",
  "a[empty-pallet]-a[load-pallet]",
  "item-name.empty-pallet",
  10
 )
 
 PalletUnload(
  "empty-pallet",
  {
    {
      icon = "__UniversalPalleting__/graphics/icons/empty-pallet.png",
    },
    {
      icon = "__UniversalPalleting__/graphics/icons/small-arrow.png",
    },
    {
      icon = "__UniversalPalleting__/graphics/icons/empty-pallet-pallet.png",
      scale = 0.5,
      shift = {
        7,
        8
      }
    }
  },
  "pallet",
  "a[empty-pallet]-a[unload-pallet]",
  "item-name.empty-pallet",
  10
 )

if palletize_all_items == true then
  -- palletize *everything*
  for item_name,item in pairs(data.raw.item) do
    -- see if this thing is hidden, otherwise we get weird secret objects
	local is_hidden = false
    for i,flag in pairs(item.flags) do
      if flag == "hidden" then
        is_hidden = true
      end
    end
	if is_hidden == false then
	  -- for some reason these are nil for items that place things
      local localized_name = "item-name." .. item.name
      if item.place_result then
	    localized_name = "entity-name." .. item.name
      end
      -- and equipment too
      if item.placed_as_equipment_result then
	    localized_name = "equipment-name." .. item.name
      end
	  
	  PalletizeItem(item.name, item.icon, "intermediate-product", item.order, localized_name, item.stack_size)
	end
  end
  
else
  -- palletize only things with a custom tint i.e. vanilla intermediates
  for item_name,tint in pairs(custom_tints) do
    local item = data.raw.item[item_name]

    if item_name == "stone-brick" then
      -- stone-bricks would naturally sort into the 'wrong' place,
      -- so order them after solid-fuel
      local subgroup = data.raw.item["solid-fuel"].subgroup
      local order = data.raw.item["solid-fuel"].order .. "-a[stone-brick]"

      PalletizeItem(item.name, item.icon, subgroup, order, "item-name." .. item.name, item.stack_size)
    else
      PalletizeItem(item.name, item.icon, item.subgroup, item.order, "item-name." .. item.name, item.stack_size)
    end
  end
end
