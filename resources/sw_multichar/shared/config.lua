local Config = {} 

Config.MaxPlayerCharacters = 4
Config.StartPoint = vector3(1383.52, 1157.81, 114.33)


Config.SpawnPoints = {
    { title = 'Delegacia da Praça', pos = vec4(423.33, -977.89, 30.71, 86.30) },
    { title = 'Delegacia de Sandy Shore', pos = vec4(1858.03, 3680.19, 33.77, 212.71) },
    { title = 'Delegacia de Paleto', pos = vec4(-438.52, 6021.01, 31.49, 312.22) },
    { title = 'Delegacia de Vinewood', pos = vec4(-555.73, -135.47, 38.26, 218.43) },
}


Config.CharacterSpawnPreview = {
    [1] = {
        spawn = vector4(1383.52, 1157.81, 114.33, 182.23),
        -- idle_anim = { '', '' },
        scenary = 'WORLD_HUMAN_AA_COFFEE',
        deleted = {
            scenary = 'PROP_HUMAN_STAND_IMPATIENT'
        }
        -- prop = { 
        --     model = '', 
        --     boneId = 0, 
        --     distance_offset = vector3(0.0, 0.0, 0.0), 
        --     rot_offset = vector3(0.0, 0.0, 0.0) 
        -- },
        -- deleted = {
        --     effect = {},
        --     anim = {},
        --     scenary = '',            
        -- }
    },
    [2] = {
        spawn = vector4(1381.7, 1154.5, 114.33, 267.79),
        scenary = 'WORLD_HUMAN_CLIPBOARD',
        deleted = {
            scenary = 'PROP_HUMAN_STAND_IMPATIENT'
        }
    },
    [3] = {
        spawn = vector4(1391.76, 1156.67, 114.44, 127.2),
        scenary = 'WORLD_HUMAN_DRUG_DEALER',
        deleted = {
            scenary = 'PROP_HUMAN_STAND_IMPATIENT'
        }
    },
    [4] = {
        spawn = vector4(1390.9, 1152.26, 114.44, 0.45),
        scenary = 'WORLD_HUMAN_GOLF_PLAYER',
        deleted = {
            scenary = 'PROP_HUMAN_STAND_IMPATIENT'
        }

    }
}

Config.NameText = {
    scale = 0.5,
    color = { 255, 255, 255 },
    font = 0, -- GTA FONT ID
}


return Config