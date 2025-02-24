local module = {}
local prepares = {}

function module.Prepare(name, query)
    assert(type(name) == 'string', 'Name must be a string')
    assert(type(query) == 'string', 'Query must be a string')
    prepares[name] = query
end

function module.Insert(query, params)
    assert(type(query) == 'string', 'Query must be a string')
    params = params or {}
    assert(type(params) == "table", "Params must be a table")
    local q = prepares[query] or query
    return MySQL.insert.await(q, params)
end

function module.Update(query, params)
    assert(type(query) == 'string', 'Query must be a string')
    params = params or {}
    assert(type(params) == "table", "Params must be a table")
    local q = prepares[query] or query
    return MySQL.update.await(q, params)
end

function module.Single(query, params)
    assert(type(query) == 'string', 'Query must be a string')
    params = params or {}
    assert(type(params) == "table", "Params must be a table")
    local q = prepares[query] or query
    return MySQL.single.await(q, params)
end

function module.Scalar(query, params)
    assert(type(query) == 'string', 'Query must be a string')
    params = params or {}
    assert(type(params) == "table", "Params must be a table")
    local q = prepares[query] or query
    return MySQL.scalar.await(q, params)
end

function module.Fetch(query, params)
    assert(type(query) == 'string', 'Query must be a string')
    params = params or {}
    assert(type(params) == "table", "Params must be a table")
    local q = prepares[query] or query
    return MySQL.query.await(q, params)
end


local function __init__()
    local _module = { name = 'Storage', exp_prefix = 'SQL'}
    return setmetatable(_module, {__index = module })
end

return __init__