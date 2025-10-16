pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--the snickness (snake sickness)
--by songbird

--define tile size for grid
tile_size = 8

function _init()
	init_menu()
end

function _update()
	if menu then
		update_menu()
	else
		update_snake()
		update_food()
	end
end

function _draw()
	cls()

	if menu then
		draw_menu()
	else
		draw_border()
		draw_snake()
		draw_food()
	end
end

-->8
--snake

function init_snake()
	sprites = {
		head = 1,
		body = 9,
		bend = 13,
		fbody = 21,
		fbend = 25,
		tail = 37
	}

	snake = {
		x = 7 * tile_size,
		y = 7 * tile_size,
		dx = 1,
		dy = 0,
		dir = 1
	}

	head = make_segment(
		sprites.head,
		snake.dir,
		snake.dir + 2,
		snake.x,
		snake.y
	)

	for i = 3, 1, -1 do
		body:enqueue(make_segment(
			sprites.body,
			snake.dir,
			snake.dir + 2,
			snake.x - i * tile_size,
			snake.y
		))
	end

	tail = make_segment(
		sprites.tail,
		snake.dir,
		snake.dir + 2,
		snake.x - 4 * tile_size,
		snake.y
	)

	tick = 0
	rate = 0.1
end

function make_segment(type, to, from, x, y)
	return {
		type = type,
		to = to,
		from = from,
		x = x,
		y = y
	}
end

function update_snake()
	if btn(⬆️)
			and head.to ~= 0
			and head.from ~= 0 then
		snake.dx = 0
		snake.dy = -1
		snake.dir = 0
	elseif btn(➡️)
			and head.to ~= 1
			and head.from ~= 1 then
		snake.dx = 1
		snake.dy = 0
		snake.dir = 1
	elseif btn(⬇️)
			and head.to ~= 2
			and head.from ~= 2 then
		snake.dx = 0
		snake.dy = 1
		snake.dir = 2
	elseif btn(⬅️)
			and head.to ~= 3
			and head.from ~= 3 then
		snake.dx = -1
		snake.dy = 0
		snake.dir = 3
	end

	tick += rate
	if tick >= 1 then
		snake.x += snake.dx * tile_size
		snake.y += snake.dy * tile_size
		update_segments()
		eaten = false
		tick = 0
	end
end

function update_segments()
	--update tail
	if not eaten then
		tail = body:dequeue()
		tail.type = sprites.tail
		tail.from = (tail.to + 2) % 4
	end

	--update head
	body:enqueue(head)
	head = make_segment(
		sprites.head,
		snake.dir,
		(snake.dir + 2) % 4,
		snake.x,
		snake.y
	)

	--update new body segment
	if head.to == body[body.last].to then
		--not turning
		if eaten then
			body[body.last].type = sprites.fbody
		else
			body[body.last].type = sprites.body
		end
	else
		--turning
		if eaten then
			body[body.last].type = sprites.fbend
		else
			body[body.last].type = sprites.bend
		end
		body[body.last].to = head.to
	end

	if check_collisions() then
		end_game()
	end
end

function check_collisions()
	--check walls
	if head.x == 0
			or head.y == 0
			or head.x == 128 - tile_size
			or head.y == 128 - tile_size then
		return true
	end

	--check for tail
	if check_collision(tail) then
		return true
	end

	--check for all body segments
	for i = body.first, body.last - 2 do
		if check_collision(body[i]) then
			return true
		end
	end

	--no collisions
	return false
end

function check_collision(segment)
	return head.x == segment.x
			and head.y == segment.y
end

function end_game()
	--todo: pause for a bit?
	body:clear()
	init_menu()
end

function draw_snake()
	--draw body segments
	for i = body.first, body.last do
		local to = body[i].to
		local from = body[i].from
		local diff = abs(to - from)
		local offset = 0

		if diff == 2 then
			--not turning
			offset = to
		elseif diff == 3 then
			--turning
			offset = diff
		else
			--turning
			offset = min(from, to)
		end

		--draw segment
		spr(
			body[i].type + offset,
			body[i].x,
			body[i].y
		)
	end

	--draw tail
	spr(
		tail.type + tail.to,
		tail.x,
		tail.y
	)

	--draw head
	spr(
		head.type + head.to,
		head.x,
		head.y
	)
end

-->8
--body

body = { first = 1, last = 0 }

function body:length()
	return 1 + self.last - self.first
end

function body:isempty()
	return self.first > self.last
end

function body:enqueue(segment)
	self.last += 1
	self[self.last] = segment
end

function body:dequeue()
	if self:isempty() then
		return nil
	end
	local segment = self[self.first]
	self[self.first] = nil
	self.first += 1
	return segment
end

function body:clear()
	while not body:isempty() do
		body:dequeue()
	end
	body.first = 1
	body.last = 0
end

-->8
--food

function init_food()
	score = 0
	eaten = false
	food = make_food()
end

function make_food()
	local x = get_coord()
	local y = get_coord()

	while not valid_spawn(x, y) do
		x = get_coord()
		y = get_coord()
	end

	return {
		sprite = 0,
		x = x,
		y = y
	}
end

function get_coord()
	return ceil(rnd(14)) * tile_size
end

function valid_spawn(x, y)
	--check head and tail
	if (x == head.x
				and y == head.y)
			or (x == tail.x
				and y == tail.y) then
		--spawn is invalid
		return false
	end

	--check body segments
	for i = body.first, body.last do
		if x == body[i].x
				and y == body[i].y then
			--spawn is invalid
			return false
		end
	end

	--spawn is valid
	return true
end

function update_food()
	if head.x == food.x
			and head.y == food.y then
		eat_food()
	end
end

function eat_food()
	score += 1
	eaten = true
	food = make_food()
end

function draw_food()
	spr(
		food.sprite,
		food.x,
		food.y
	)
end

-->8
--ui

function init_menu()
	menu = true
	logo = {
		sprite = 64,
		x = 0,
		y = 32,
		w = 16,
		h = 4
	}
end

function update_menu()
	if btn(❎) then
		init_snake()
		init_food()
		menu = false
	end
end

function draw_menu()
	spr(
		logo.sprite,
		logo.x,
		logo.y,
		logo.w,
		logo.h
	)

	print(
		"(snake sickness)",
		32,
		64,
		3
	)

	print(
		"press ❎ to start",
		30,
		80,
		11
	)
end

function draw_border()
	rrectfill(0, 0, 128, tile_size, 0, 6)
	rrectfill(0, 0, tile_size, 128, 0, 6)
	rrectfill(0, 128 - tile_size, 128, tile_size, 0, 6)
	rrectfill(128 - tile_size, 0, tile_size, 128, 0, 6)
	print(score, 9, 2, 0)
end

__gfx__
00005500000880000000000000bb3b0000000000000880000000000000bb3b000000000000bb3b000000000000bb3b000000000000bb3b000000000000000000
00445440003bb30003bbb30003b3bb30003bbb30005335000533350005b3bb500053335000b3bb000000000000b3bb000000000000b3bb000000000000000000
0488444403bbbb30bbbb0b300bbbbbb003b0bbbb053bb350bbbb035003bbbb300530bbbb00bb3b00bbbbbbbb00bb3b00bbbbbbbb00bb3bbb003bbbbbbbbbb300
488888450b0bb0b03bbbbbb80bbbbbb08bbbbb3b030bb0303bbbbb3803bbbb3083bbbb3b00b3bb003b3b3b3b00b3bb003b3b3b3b00b3bb3b00bb3b3b3b3bbb00
448884540bbbbbb0b3bbbbb80b0bb0b08bbbbbb303bbbb30b3bbbb38030bb03083bbbbb300bb3b00b3b3b3b300bb3b00b3b3b3b300bbb3b300bbb3b3b3bb3b00
484845450bbbbbb0bbbb0b3003bbbb3003b0bbbb03bbbb30bbbb0350053bb3500530bbbb00b3bb00bbbbbbbb00b3bb00bbbbbbbb003bbbbb00b3bbbbbbb3bb00
0484545003bb3b3003bbb300003bb300003bbb3005bb3b5005333500005335000053335000bb3b000000000000bb3b00000000000000000000bb3b0000bb3b00
0045450000b3bb0000000000000880000000000000b3bb0000000000000880000000000000b3bb000000000000b3bb00000000000000000000b3bb0000b3bb00
00bb3b0000bb3b00000000000000000000bb3b0000bb3b000033330000bb3b000033330000bb3b00003333000033330000bb3b0000bb3b000055550000bb3b00
00b3bb0000b3bb00000000000000000000b3bb0003b3bb3003bbbb3003b3bb3003bbbb3003b3bb3003bbbb3003bbbb3003b3bb3005b3bb50053bb35005b3bb50
bbbb3b0000bb3bbb0053bbbbbbbb3500bbbb3b003bbb3bb3bbbb3bbb3bbb3bb3bbbb3bbb3bbb3bbb3bbb3bbbbbbb3bb3bbbb3bb353bb3b35bbbb3bbb53bb3b35
3b3bbb0000b3bb3b003b3b3b3b3bb3003b3bbb003b3bbbb33b3bbb3b3b3bbbb33b3bbb3b3b3bbb3b3b3bbb3b3b3bbbb33b3bbbb35b3bbbb53b3bbb3b5b3bbbb5
b3b3bb00003bb3b300bbb3b3b3bb3b00b3b3b3003bbbb3b3b3bbb3b33bbbb3b3b3bbb3b33bbbb3b33bbbb3b3b3bbb3b3b3bbb3b35bbbb3b5b3bbb3b35bbbb3b5
bbbbb3000053bbbb00b3bbbbbbb3bb00bbbb35003bb3bbb3bbb3bbbb3bb3bbb3bbb3bbbb3bb3bbbb3bb3bbbbbbb3bbb3bbb3bbb353b3bb35bbb3bbbb53b3bb35
000000000000000000bb3b0000bb3b000000000003bb3b3003bbbb3003bb3b3003bbbb3003bbbb3003bb3b3003bb3b3003bbbb3005bb3b50053bb35005bb3b50
000000000000000000b3bb0000b3bb000000000000b3bb000033330000b3bb00003333000033330000b3bb0000b3bb000033330000b3bb000055550000b3bb00
0055550000bb3b00005555000055550000bb3b0000bb3b0000000000000330000000000000bb3b00000000000005500000000000000000000000000000000000
053bb35005b3bb50053bb350053bb35005b3bb5000b3bb0000000000003bb3000000000000b3bb00000000000053350000000000000000000000000000000000
bbbb3bbb53bb3bbb53bb3bbbbbbb3b35bbbb3b3500bb3b0003bbbbbb00bbbb00bbbbbb3000bb3b00053bbbbb003bb300bbbbb350000000000000000000000000
3b3bbb3b5b3bbb3b5b3bbb3b3b3bbbb53b3bbbb500b3bb003bbb3b3b00b3bb003b3b3bb300b3bb0053bb3b3b00b3bb003b3b3b35000000000000000000000000
b3bbb3b35bbbb3b35bbbb3b3b3bbb3b5b3bbb3b500bb3b003bb3b3b300bb3b00b3b3bbb300bb3b0053b3b3b300bb3b00b3b3bb35000000000000000000000000
bbb3bbbb53b3bbbb53b3bbbbbbb3bb35bbb3bb3500bbbb0003bbbbbb00b3bb00bbbbbb30003bb300053bbbbb00b3bb00bbbbb350000000000000000000000000
053bb350053bb35005bb3b5005bb3b50053bb350003bb3000000000000bb3b0000000000005335000000000000bb3b0000000000000000000000000000000000
005555000055550000b3bb0000b3bb0000555500000330000000000000b3bb0000000000000550000000000000b3bb0000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000bbb0b00b0bbb0000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000b0b00b00b0b000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000b00bbbb0bb00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000b00b00b0b00b000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000b00b00b0bbb0000000000000000000000000000000000000000000000000000000000
000000bbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bbbbbbbbbb00000000000000bbb0000bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbb000
0000bbbbbbbbbbb0000bbbb00000bbb0000bbbbbbb000000bbbbbb00000bbb0000000000000000000bbb0000bbbbbbbbb000000bbbbbbb000000bbbbbbbbbb00
000bbbbb00bbbbb0000bbbb00000bbb00003bbbbb30000bbbbbbbbbb000bbb000000bbb00bbbb0000bbb0000bbbbbbbbb00000bbbbbbbbbb0000bbbbbbbbbbb0
000bbbb0000bbbb0000bbbb00000bbb000003bbb000000bbbbbbbbbb000bbb0000bbbbb00bbbb0000bbb000bbbbbbbbb300000bbbbbbbbbb000bbbbb000bbbb0
000bbbb00000bb30000bbbbb0000bbb000000bbb00000bbbbbbbbbbb000bbb0000bbbb300bbbb0000bbb000bbbb0000300000bbbbb00bbb3000bbbb000003b30
000bbbbb00000300000bbbbbb000bbb000000bbb00000bbbb00003bb000bbb000bbbb3300bbbbb000bbb000bbb00000000000bbbb0000330000bbbb000000330
0003bbbbb000000000bbbbbbb000bbb000000bbb00000bbb30000033000bbb0bbbbb30300bbbbb000bbb000bbb00000000000bbbb0000030000bbbbb00000300
00003bbbbbb0000000bbbbbbb000bbb000000bbb00000bbb0000003000bbbbbbbbbb00000bbbbbb00bbb000bbb00000000000bbbbb0000000003bbbbb0000000
00000bbbbbbbb00000bbbbbbbb00bbb000000bbb00000bbb0000000000bbbbbbbbb000000bbbbbb00bbb000bbbb00bbbb00000bbbbb0000000003bbbbb000000
0000003bbbbbbb0000bbb0bbbb00bbb000000bbb00000bbb0000000000bbbbbbbb0000000bbbbbbb0bbb000bbbbbbbbbb000003bbbbb000000000bbbbbbb0000
000000033bbbbbb000bbb00bbbb0bbb00000bbbb00000bbb0000000000bbbbbbb00000000bbbbbbb0bbb0003bbbbbbbbb000000bbbbbb0000000003bbbbb0000
0000000300bbbbb000bbb00bbbbbbbb00000bbbb00000bbb0000000000bbbbbbb00000000bbbbbbbbbbb0000bbbbbbb3000000003bbbbb0000000000bbbbb000
00000000000bbbbb00bbb003bbbbbb300000bbb300000bbb0000000000bbbbbbbb0000000bbb0bbbbbbb0000bbb000300000000003bbbbb0000000003bbbb000
00bb00000000bbbb00bbb000bbbbbb000000bbb000000bbb0000bbb000bbb0bbbbb000000bbb00bbbbbb0000bbb0000000000000000bbbb00000000003bbbb00
0bbbb0000000bbbb00bbb0003bbbbb000000bbb000000bbbb00bbbb000bbb00bbbbb00000bbb003bbbbb0000bbb0000000000bb0000bbbb00000000000bbbb00
0bbbb0000000bbbb00bbb0000bbbbb00000bbbb000000bbbbbbbbbb000bbb003bbbbb0000bbb000bbbbb0000bbbbb0000000bbbb00bbbbb00bb0000000bbbb00
0bbbbb00000bbbb300bbb00000bbbb00000bbbb0000003bbbbbbbb3000bbb0000bbbbb000bbb0000bbbb0000bbbbbbbbbb00bbbbbbbbbb30bbbb000000bbbb00
00bbbbb00bbbbb3000bbb000003bbb000bbbbbbbb000003bbbbbbb0000bbb00003bbbb000bbb00000bb300003bbbbbbbbb00bbbbbbbbb300bbbb000000bbbb00
00bbbbbbbbbbbb3000bbb000000bb3000bbbbbbbb0000033bbbb300000bb3000003bbb0003b3000003300000033bbbbbb3000bbbbbbb3300bbbbb0000bbbb000
003bbbbbbbbbb300003b30000003300003bbbbbb300000300000000000330000000330000033000000300000000000033000003bbbb003000bbbbbbbbbbbb000
00033bbbbbb3300000330000000300000030003300000000000000000003000000030000000300000000000000000000300000033000000003bbbbbbbbbb3000
0000330000330000000300000000000000000003000000000000000000000000000000000000000000000000000000000000000300000000003bbbbbbbb30000
000030000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303bbbbb030000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000
