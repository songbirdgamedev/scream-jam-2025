pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--the snickness (snake sickness)
--by songbird

--define tile size for grid
tile_size = 8

function _init()
	init_snake()
	init_food()
end

function _update()
	update_snake()
	update_food()
end

function _draw()
	cls()
	draw_border()
	draw_snake()
	draw_food()
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
	rate = 0.02
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
		tick = 0
	end
end

function draw_snake()
	--draw head
	spr(
		head.type + head.to,
		head.x,
		head.y
	)

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

function update_segments()
	tail = body:dequeue()
	tail.type = sprites.tail
	tail.from = (tail.to + 2) % 4

	body:enqueue(head)
	head = make_segment(
		sprites.head,
		snake.dir,
		(snake.dir + 2) % 4,
		snake.x,
		snake.y
	)

	if head.to == body[body.last].to then
		--not turning
		body[body.last].type = sprites.body
	else
		--turning
		body[body.last].type = sprites.bend
		body[body.last].to = head.to
	end
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

-->8
--food

function init_food()
end

function update_food()
end

function draw_food()
end

-->8
--border

function draw_border()
	rrectfill(0, 0, 128, tile_size, 0, 6)
	rrectfill(0, 0, tile_size, 128, 0, 6)
	rrectfill(0, 128 - tile_size, 128, tile_size, 0, 6)
	rrectfill(128 - tile_size, 0, tile_size, 128, 0, 6)
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
