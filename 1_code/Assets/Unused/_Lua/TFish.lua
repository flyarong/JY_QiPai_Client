-- 创建时间:2019-04-19

TFish = {}

function TFish.Create()
    local ins = TFish.Init()
    return ins
end

function TFish.GetPrefabName()
    local n = TFish.GetRandNum(23)
    local name = "Fish"
    if n < 10 then
        name = name .. "00" .. n
    else
        name = name .. "0" .. n
    end

    return name
end

function TFish.GetLayer()
    local n = TFish.GetRandNum(5)
    return GameObject.Find("Canvas/LayerLv" .. 1)
end

function TFish.GetRandNum(maxNum)
	if not TFish.randSeed then
		TFish.randSeed = os.time()%10000
	else
		TFish.randSeed = (TFish.randSeed + os.time()%10000)/math.random(9)
	end
	math.randomseed(TFish.randSeed)
	return math.max(1, math.floor(math.random() * maxNum))
end

function TFish.GetPos()
    local x = TFish.GetRandNum(Screen.width/2) * (TFish.GetRandNum(100) > 50 and 1 or -1)
    local y = TFish.GetRandNum(Screen.height/2) * (TFish.GetRandNum(100) > 50 and 1 or -1)
    return Vector3.New(x, y, 0)
end



local cur_layer = 1
function TFish.Init()
    local fishPrefab = TFish.GetPrefabName()
    local parent = TFish.GetLayer()
    --log("<color=yellow>--->>>Fish prefab:" .. fishPrefab .. ", parent:" .. parent.name .. "</color>")
    if fishPrefab == "Fish014" or fishPrefab == "Fish017" or fishPrefab == "Fish018" or fishPrefab == "Fish019" or fishPrefab == "Fish020" then
        fishPrefab = "Fish023"
    end
    -- if TFish.GetRandNum(360) %2==0 then
    --     fishPrefab = "Fish001"
    --     cur_layer = 1
    -- else
    --     fishPrefab = "Fish015"
    --     cur_layer = 10
    -- end
    cur_layer = tonumber(string.sub(fishPrefab,5,-1)) * 10
    local obj = {}
    obj.fish = newObject(fishPrefab, parent.transform)
    obj.transform = obj.fish.transform
    obj.transform.localPosition = TFish.GetPos()
    obj.transform:RotateAround(obj.transform.position, obj.transform.forward, TFish.GetRandNum(360))
    
    local fish = obj.transform:Find("fish")
    local sRender = fish.gameObject:GetComponent("SpriteRenderer")
    fish.localScale = Vector3.New(100, 100, 1)
    -- sRender.sortingLayerID = 0
    sRender.sortingLayerName = "1"
    sRender.sortingOrder = cur_layer + 1

    local shadow = fish.transform:Find("shadow")
    sRender = shadow.gameObject:GetComponent("SpriteRenderer")
    -- sRender.sortingLayerID = 0
    sRender.sortingLayerName = "1"
    sRender.sortingOrder = cur_layer
    cur_layer = cur_layer + 2

    -- shadow.gameObject:SetActive(false)

    obj.enableMove = false

    local vfx = {"hongbaoyu",
                "hongbaoyu",
                "kapianyu_1",
                "kapianyu_1",
                "shandianyu",
                "shandianyu",
            }
    local v = newObject(vfx[TFish.GetRandNum(3)], obj.transform)
    v.transform.localScale = Vector3.New(100, 100, 1)

    function obj:Kill()
        GameObject.Destroy(self.fish)
    end

    function obj:Update()
        if self.enableMove then
            self:Move()
        end
    end

    function obj:Move()
        
    end

    return obj
end
