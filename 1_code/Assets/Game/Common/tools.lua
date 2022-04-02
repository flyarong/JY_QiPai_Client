--tools
tls = tls or {}

function tls.clampf(value, min_inclusive, max_inclusive)
    -- body
    local temp = 0
    if min_inclusive > max_inclusive then
        temp = min_inclusive
        min_inclusive =  max_inclusive
        max_inclusive = temp
    end

    if value < min_inclusive then
        return min_inclusive
    elseif value < max_inclusive then
        return value
    else
        return max_inclusive
    end
end

--Point
function tls.p(_x,_y)
    if nil == _y then
         return { x = _x.x, y = _x.y }
    else
         return { x = _x, y = _y }
    end
end

function tls.pAdd(pt1,pt2)
    return {x = pt1.x + pt2.x , y = pt1.y + pt2.y }
end

function tls.pSub(pt1,pt2)
    return {x = pt1.x - pt2.x , y = pt1.y - pt2.y }
end

function tls.pMul(pt1,factor)
    return { x = pt1.x * factor , y = pt1.y * factor }
end

function tls.pMidpoint(pt1,pt2)
    return { x = (pt1.x + pt2.x) / 2.0 , y = ( pt1.y + pt2.y) / 2.0 }
end

function tls.pForAngle(a)
    return { x = math.cos(a), y = math.sin(a) }
end

function tls.pGetLength(pt)
    return math.sqrt( pt.x * pt.x + pt.y * pt.y )
end

function tls.pNormalize(pt)
    local length = tls.pGetLength(pt)
    if 0 == length then
        return { x = 1.0,y = 0.0 }
    end

    return { x = pt.x / length, y = pt.y / length }
end

function tls.pCross(self,other)
    return self.x * other.y - self.y * other.x
end

function tls.pDot(self,other)
    return self.x * other.x + self.y * other.y
end

function tls.pToAngleSelf(self)
    return math.atan2(self.y, self.x)
end

function tls.pGetAngle(self,other)
    local a2 = tls.pNormalize(self)
    local b2 = tls.pNormalize(other)
    local angle = math.atan2(tls.pCross(a2, b2), tls.pDot(a2, b2) )
    if math.abs(angle) < 1.192092896e-7 then
        return 0.0
    end

    return angle
end

function tls.pGetDistance(startP,endP)
    return tls.pGetLength(tls.pSub(startP,endP))
end

function tls.pIsLineIntersect(A, B, C, D, s, t)
    if ((A.x == B.x) and (A.y == B.y)) or ((C.x == D.x) and (C.y == D.y))then
        return false, s, t
    end

    local BAx = B.x - A.x
    local BAy = B.y - A.y
    local DCx = D.x - C.x
    local DCy = D.y - C.y
    local ACx = A.x - C.x
    local ACy = A.y - C.y

    local denom = DCy * BAx - DCx * BAy
    s = DCx * ACy - DCy * ACx
    t = BAx * ACy - BAy * ACx

    if (denom == 0) then
        if (s == 0 or t == 0) then
            return true, s , t
        end

        return false, s, t
    end

    s = s / denom
    t = t / denom

    return true,s,t
end

function tls.pPerp(pt)
    return { x = -pt.y, y = pt.x }
end

function tls.RPerp(pt)
    return { x = pt.y,  y = -pt.x }
end

function tls.pProject(pt1, pt2)
    return { x = pt2.x * (tls.pDot(pt1,pt2) / tls.pDot(pt2,pt2)) , y = pt2.y * (tls.pDot(pt1,pt2) / tls.pDot(pt2,pt2)) }
end

function tls.pRotate(pt1, pt2)
    return { x = pt1.x * pt2.x - pt1.y * pt2.y, y = pt1.x * pt2.y + pt1.y * pt2.x }
end

function tls.pUnrotate(pt1, pt2)
    return { x = pt1.x * pt2.x + pt1.y * pt2.y, pt1.y * pt2.x - pt1.x * pt2.y }
end
--Calculates the square length of pt
function tls.pLengthSQ(pt)
    return tls.pDot(pt,pt)
end
--Calculates the square distance between pt1 and pt2
function tls.pDistanceSQ(pt1,pt2)
    return tls.pLengthSQ(tls.pSub(pt1,pt2))
end

function tls.pGetClampPoint(pt1,pt2,pt3)
    return { x = tls.clampf(pt1.x, pt2.x, pt3.x), y = tls.clampf(pt1.y, pt2.y, pt3.y) }
end

function tls.pFromSize(sz)
    return { x = sz.width, y = sz.height }
end

function tls.pLerp(pt1,pt2,alpha)
    return tls.pAdd(tls.pMul(pt1, 1.0 - alpha), tls.pMul(pt2,alpha) )
end

function tls.pFuzzyEqual(pt1,pt2,variance)
    if (pt1.x - variance <= pt2.x) and (pt2.x <= pt1.x + variance) and (pt1.y - variance <= pt2.y) and (pt2.y <= pt1.y + variance) then
        return true
    else
        return false
    end
end

function tls.pRotateByAngle(pt1, pt2, angle)
    return tls.pAdd(pt2, tls.pRotate( tls.pSub(pt1, pt2),tls.pForAngle(angle)))
end

function tls.pIsSegmentIntersect(pt1,pt2,pt3,pt4)
    local s,t,ret = 0,0,false
    ret,s,t =tls.pIsLineIntersect(pt1, pt2, pt3, pt4,s,t)

    if ret and  s >= 0.0 and s <= 1.0 and t >= 0.0 and t <= 0.0 then
        return true
    end

    return false
end

function tls.pGetIntersectPoint(pt1,pt2,pt3,pt4)
    local s,t, ret = 0,0,false
    ret,s,t = tls.pIsLineIntersect(pt1,pt2,pt3,pt4,s,t)
    if ret then
        return tls.p(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y))
    else
        return tls.p(0,0)
    end
end
--Size
function tls.size( _width,_height )
    return { width = _width, height = _height }
end

--Rect
function tls.rect(_x,_y,_width,_height)
    return { x = _x, y = _y, width = _width, height = _height }
end

function tls.rectEqualToRect(rect1,rect2)
    if ((rect1.x >= rect2.x) or (rect1.y >= rect2.y) or
        ( rect1.x + rect1.width <= rect2.x + rect2.width) or
        ( rect1.y + rect1.height <= rect2.y + rect2.height)) then
        return false
    end

    return true
end

function tls.rectGetMaxX(rect)
    return rect.x + rect.width
end

function tls.rectGetMidX(rect)
    return rect.x + rect.width / 2.0
end

function tls.rectGetMinX(rect)
    return rect.x
end

function tls.rectGetMaxY(rect)
    return rect.y + rect.height
end

function tls.rectGetMidY(rect)
    return rect.y + rect.height / 2.0
end

function tls.rectGetMinY(rect)
    return rect.y
end

function tls.rectContainsPoint( rect, point )
    local ret = false

    if (point.x >= rect.x) and (point.x <= rect.x + rect.width) and
       (point.y >= rect.y) and (point.y <= rect.y + rect.height) then
        ret = true
    end

    return ret
end

function tls.rectIntersectsRect( rect1, rect2 )
    local intersect = not ( rect1.x > rect2.x + rect2.width or
                    rect1.x + rect1.width < rect2.x         or
                    rect1.y > rect2.y + rect2.height        or
                    rect1.y + rect1.height < rect2.y )

    return intersect
end

function tls.rectUnion( rect1, rect2 )
    local rect = tls.rect(0, 0, 0, 0)
    rect.x = math.min(rect1.x, rect2.x)
    rect.y = math.min(rect1.y, rect2.y)
    rect.width = math.max(rect1.x + rect1.width, rect2.x + rect2.width) - rect.x
    rect.height = math.max(rect1.y + rect1.height, rect2.y + rect2.height) - rect.y
    return rect
end

function tls.rectIntersection( rect1, rect2 )
    local intersection = tls.rect(
        math.max(rect1.x, rect2.x),
        math.max(rect1.y, rect2.y),
        0, 0)

    intersection.width = math.min(rect1.x + rect1.width, rect2.x + rect2.width) - intersection.x
    intersection.height = math.min(rect1.y + rect1.height, rect2.y + rect2.height) - intersection.y
    return intersection
end

--Color3B
function tls.c3b( _r,_g,_b )
    return { r = _r, g = _g, b = _b }
end

--Color4B
function tls.c4b( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end

--Color4F
function tls.c4f( _r,_g,_b,_a )
    return { r = _r, g = _g, b = _b, a = _a }
end

local function isFloatColor(c)
    return (c.r <= 1 and c.g <= 1 and c.b <= 1) and (math.ceil(c.r) ~= c.r or math.ceil(c.g) ~= c.g or math.ceil(c.b) ~= c.b)
end

function tls.convertColor(input, typ)
    assert(type(input) == "table" and input.r and input.g and input.b, "tls.convertColor() - invalid input color")
    local ret
    if typ == "3b" then
        if isFloatColor(input) then
            ret = {r = math.ceil(input.r * 255), g = math.ceil(input.g * 255), b = math.ceil(input.b * 255)}
        else
            ret = {r = input.r, g = input.g, b = input.b}
        end
    elseif typ == "4b" then
        if isFloatColor(input) then
            ret = {r = math.ceil(input.r * 255), g = math.ceil(input.g * 255), b = math.ceil(input.b * 255)}
        else
            ret = {r = input.r, g = input.g, b = input.b}
        end
        if input.a then
            if math.ceil(input.a) ~= input.a or input.a >= 1 then
                ret.a = input.a * 255
            else
                ret.a = input.a
            end
        else
            ret.a = 255
        end
    elseif typ == "4f" then
        if isFloatColor(input) then
            ret = {r = input.r, g = input.g, b = input.b}
        else
            ret = {r = input.r / 255, g = input.g / 255, b = input.b / 255}
        end
        if input.a then
            if math.ceil(input.a) ~= input.a or input.a >= 1 then
                ret.a = input.a
            else
                ret.a = input.a / 255
            end
        else
            ret.a = 255
        end
    else
        error(string.format("tls.convertColor() - invalid type %s", typ), 0)
    end
    return ret
end

--Vertex2F
function tls.vertex2F(_x,_y)
    return { x = _x, y = _y }
end

--Vertex3F
function tls.Vertex3F(_x,_y,_z)
    return { x = _x, y = _y, z = _z }
end

--Tex2F
function tls.tex2F(_u,_v)
    return { u = _u, v = _v }
end

--PointSprite
function tls.PointSprite(_pos,_color,_size)
    return { pos = _pos, color = _color, size = _size }
end

--Quad2
function tls.Quad2(_tl,_tr,_bl,_br)
    return { tl = _tl, tr = _tr, bl = _bl, br = _br }
end

--Quad3
function tls.Quad3(_tl, _tr, _bl, _br)
    return { tl = _tl, tr = _tr, bl = _bl, br = _br }
end

--V2F_C4B_T2F
function tls.V2F_C4B_T2F(_vertices, _colors, _texCoords)
    return { vertices = _vertices, colors = _colors, texCoords = _texCoords }
end

--V2F_C4F_T2F
function tls.V2F_C4F_T2F(_vertices, _colors, _texCoords)
    return { vertices = _vertices, colors = _colors, texCoords = _texCoords }
end

--V3F_C4B_T2F
function tls.V3F_C4B_T2F(_vertices, _colors, _texCoords)
    return { vertices = _vertices, colors = _colors, texCoords = _texCoords }
end

--V2F_C4B_T2F_Quad
function tls.V2F_C4B_T2F_Quad(_bl, _br, _tl, _tr)
    return { bl = _bl, br = _br, tl = _tl, tr = _tr }
end

--V3F_C4B_T2F_Quad
function tls.V3F_C4B_T2F_Quad(_tl, _bl, _tr, _br)
    return { tl = _tl, bl = _bl, tr = _tr, br = _br }
end

--V2F_C4F_T2F_Quad
function tls.V2F_C4F_T2F_Quad(_bl, _br, _tl, _tr)
    return { bl = _bl, br = _br, tl = _tl, tr = _tr }
end

--T2F_Quad
function tls.T2F_Quad(_bl, _br, _tl, _tr)
    return { bl = _bl, br = _br, tl = _tl, tr = _tr }
end

--AnimationFrameData
function tls.AnimationFrameData( _texCoords, _delay, _size)
    return { texCoords = _texCoords, delay = _delay, size = _size }
end

--PhysicsMaterial
function tls.PhysicsMaterial(_density, _restitution, _friction)
	return { density = _density, restitution = _restitution, friction = _friction }
end

function tls.vec3(_x, _y, _z)
    return { x = _x, y = _y, z = _z }
end

function tls.vec4(_x, _y, _z, _w)
    return { x = _x, y = _y, z = _z, w = _w }
end

function tls.vec3normalize(vec3)
    local n = vec3.x * vec3.x + vec3.y * vec3.y + vec3.z * vec3.z
    if n == 1.0 then
        return vec3
    end

    n = math.sqrt(n)

    if n < 2e-37 then
        return vec3
    end

    n = 1.0 / n
    return {x = vec3.x * n, y = vec3.y * n, z = vec3.z * n}
end

function tls.quaternion(_x, _y ,_z,_w)
    return { x = _x, y = _y, z = _z, w = _w }
end

function tls.blendFunc(_src, _dst)
    return {src = _src, dst = _dst}
end

tls.mat4 = tls.mat4 or {}

function tls.mat4.new(...)
    local params = {...}
    local size   = #params
    local obj = {}

    if 1 == size then
        assert(type(params[1]) == "table" , "type of input params are wrong to new a mat4 when num of params is 1")
        for i= 1, 16 do
            if params[1][i] ~= nil then
                obj[i] = params[1][i]
            else
                obj[i] = 0
            end
        end
    elseif 16 == size then
        for i= 1, 16 do
            obj[i] = params[i]
        end
    end

    setmetatable(obj, {__index = tls.mat4})

    return obj
end

function tls.mat4.getInversed(self)
    return mat4_getInversed(self)
end

function tls.mat4.transformVector(self, vector, dst)
    return mat4_transformVector(self, vector, dst)
end

function tls.mat4.multiply(self, mat)
    return mat4_multiply(self, mat)
end

function tls.mat4.decompose(self, scale, rotation, translation)
    return mat4_decompose(self, scale ,rotation, translation)
end

function tls.mat4.createIdentity()
    return tls.mat4.new(1.0 ,0.0, 0.0, 0.0,
                       0.0, 1.0, 0.0, 0.0,
                       0.0, 0.0, 1.0, 0.0,
                       0.0, 0.0, 0.0, 1.0)
end

function tls.mat4.createTranslation(translation, dst)
    assert(type(translation) == "table" and type(dst) == "table", "The type of input parameters should be table")
    dst = tls.mat4.createIdentity()
    dst[13] = translation.x
    dst[14] = translation.y
    dst[15] = translation.z
    return dst
end

function tls.mat4.createRotation(q, dst)
    assert(type(q) == "table" and type(dst) == "table", "The type of input parameters should be table")
    local x2 = q.x + q.x
    local y2 = q.y + q.y
    local z2 = q.z + q.z

    local xx2 = q.x * x2
    local yy2 = q.y * y2
    local zz2 = q.z * z2
    local xy2 = q.x * y2
    local xz2 = q.x * z2
    local yz2 = q.y * z2
    local wx2 = q.w * x2
    local wy2 = q.w * y2
    local wz2 = q.w * z2

    dst[1] = 1.0 - yy2 - zz2
    dst[2] = xy2 + wz2
    dst[3] = xz2 - wy2
    dst[4] = 0.0

    dst[5] = xy2 - wz2
    dst[6] = 1.0 - xx2 - zz2
    dst[7] = yz2 + wx2
    dst[8] = 0.0

    dst[9] = xz2 + wy2
    dst[10] = yz2 - wx2
    dst[11] = 1.0 - xx2 - yy2
    dst[12] = 0.0

    dst[13] = 0.0
    dst[14] = 0.0
    dst[15] = 0.0
    dst[16] = 1.0

    return dst
end
