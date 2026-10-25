if lua_ext == nil then
    lua_ext = {}
end

lua_ext.LinkedEl = {}

function lua_ext.LinkedEl.new(next, value)
	local out = nil
	if next then
		out = {prev=next.prev, next=next, value=value}
		next.prev = out
		if out.prev then
			out.prev.next = out
		end
	else
		out = {prev=nil, next=nil, value=value}
	end
	return out
end

function lua_ext.LinkedEl.pluck(el)
	if el.next then
		el.next.prev = el.prev
	end
	if el.prev then
		el.prev.next = el.next
	end
	el.next = nil
	el.prev = nil
end

lua_ext.LList = {}

function lua_ext.LList.push(q, value)
	local el = lua_ext.LinkedEl.new(q.first, value)
	if not q.first then
		q.last = el
	end
	q.first = el
	q.count = q.count + 1
end

function lua_ext.LList.remove(q, it, rev)
	local out = nil
	if rev then
		out = it.prev
	else
		out = it.next
	end
	
	if it == q.last then
		q.last = it.prev
	end
	if it == q.first then
		q.first = it.next
	end
	
	lua_ext.LinkedEl.pluck(it)
	q.count = q.count - 1
	return out
end 
