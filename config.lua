Config = {}

Config.CodeMapping = {
    ["emergency"] = "10-33",
    ["help"] = "10-33",
    ["assistance"] = "10-33",
    ["location"] = "10-20",
    ["in progress"] = "10-33",
    -- Add more mappings as needed
}

Config.PriorityMapping = {
    ["10-33"] = 1,  
    ["10-20"] = 2,
    ["10-99"] = 3,
    
}
return Config
