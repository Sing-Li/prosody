local template = [[
{greet!?Hi}, {name?world}!
]];
local expect1 = [[
Hello, WORLD!
]];
local expect2 = [[
Hello, world!
]];
local expect3 = [[
Hi, YOU!
]];
local template_array = [[
{foo#{idx}. {item}
}]]
local expect_array = [[
1. HELLO
2. WORLD
]]
local template_map = [[
{foo%{idx}: {item!}
}]]
local expect_map = [[
FOO: bar
]]

describe("util.interpolation", function ()
	it("renders", function ()
		local render = require "util.interpolation".new("%b{}", string.upper);
		assert.equal(expect1, render(template, { greet = "Hello", name = "world" }));
		assert.equal(expect2, render(template, { greet = "Hello" }));
		assert.equal(expect3, render(template, { name = "you" }));
		assert.equal(expect_array, render(template_array, { foo = { "Hello", "World" } }));
		assert.equal(expect_map, render(template_map, { foo = { foo = "bar" } }));
	end);
end);
