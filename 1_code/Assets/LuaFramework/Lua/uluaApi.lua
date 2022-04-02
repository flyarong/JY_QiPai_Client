UnityEngine.Vector3 = {}
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector3.kEpsilon = 9.99999974737875E-06
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector3.kEpsilonNormalSqrt = 1.00000000362749E-15
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector3.x = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector3.y = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector3.z = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.normalized = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector3.magnitude = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector3.sqrMagnitude = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.zero = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.one = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.forward = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.back = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.up = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.down = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.left = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.right = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.positiveInfinity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Vector3.negativeInfinity = nil
--[[
	@x System.Single
	@y System.Single
	@return [luaIde#UnityEngine.Vector3]
]]
function UnityEngine.Vector3:New(x,y) end
--[[
	@x System.Single
	@y System.Single
	@z System.Single
	@return [luaIde#UnityEngine.Vector3]
]]
function UnityEngine.Vector3:New(x,y,z) end
--[[
	@a UnityEngine.Vector3
	@b UnityEngine.Vector3
	@t System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Slerp(a,b,t) end
--[[
	@a UnityEngine.Vector3
	@b UnityEngine.Vector3
	@t System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:SlerpUnclamped(a,b,t) end
--[[
	@normal UnityEngine.Vector3&
	@tangent UnityEngine.Vector3&
--]]
function UnityEngine.Vector3:OrthoNormalize(normal,tangent) end
--[[
	@current UnityEngine.Vector3
	@target UnityEngine.Vector3
	@maxRadiansDelta System.Single
	@maxMagnitudeDelta System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:RotateTowards(current,target,maxRadiansDelta,maxMagnitudeDelta) end
--[[
	@a UnityEngine.Vector3
	@b UnityEngine.Vector3
	@t System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Lerp(a,b,t) end
--[[
	@a UnityEngine.Vector3
	@b UnityEngine.Vector3
	@t System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:LerpUnclamped(a,b,t) end
--[[
	@current UnityEngine.Vector3
	@target UnityEngine.Vector3
	@maxDistanceDelta System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:MoveTowards(current,target,maxDistanceDelta) end
--[[
	@current UnityEngine.Vector3
	@target UnityEngine.Vector3
	@currentVelocity UnityEngine.Vector3&
	@smoothTime System.Single
	@maxSpeed System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:SmoothDamp(current,target,currentVelocity,smoothTime,maxSpeed) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Vector3:geti(index) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Vector3:geti(index) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Vector3:seti(index,value) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Vector3:seti(index,value) end
--[[
	@newX System.Single
	@newY System.Single
	@newZ System.Single
--]]
function UnityEngine.Vector3:Set(newX,newY,newZ) end
--[[
	@a UnityEngine.Vector3
	@b UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Scale(a,b) end
--[[
	@lhs UnityEngine.Vector3
	@rhs UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Cross(lhs,rhs) end
function UnityEngine.Vector3:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Vector3:Equals(other) end
--[[
	@inDirection UnityEngine.Vector3
	@inNormal UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Reflect(inDirection,inNormal) end
--[[
	@value UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Normalize(value) end
--[[
	@lhs UnityEngine.Vector3
	@rhs UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Vector3:Dot(lhs,rhs) end
--[[
	@vector UnityEngine.Vector3
	@onNormal UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Project(vector,onNormal) end
--[[
	@vector UnityEngine.Vector3
	@planeNormal UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:ProjectOnPlane(vector,planeNormal) end
--[[
	@from UnityEngine.Vector3
	@to UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Vector3:Angle(from,to) end
--[[
	@from UnityEngine.Vector3
	@to UnityEngine.Vector3
	@axis UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Vector3:SignedAngle(from,to,axis) end
--[[
	@a UnityEngine.Vector3
	@b UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Vector3:Distance(a,b) end
--[[
	@vector UnityEngine.Vector3
	@maxLength System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:ClampMagnitude(vector,maxLength) end
--[[
	@vector UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Vector3:Magnitude(vector) end
--[[
	@vector UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Vector3:SqrMagnitude(vector) end
--[[
	@lhs UnityEngine.Vector3
	@rhs UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Min(lhs,rhs) end
--[[
	@lhs UnityEngine.Vector3
	@rhs UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Vector3:Max(lhs,rhs) end
function UnityEngine.Vector3:ToString() end
function UnityEngine.Vector3:GetType() end

UnityEngine.Vector2 = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector2.x = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector2.y = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector2.kEpsilon = 9.99999974737875E-06
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector2.kEpsilonNormalSqrt = 1.00000000362749E-15
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.normalized = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector2.magnitude = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector2.sqrMagnitude = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.zero = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.one = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.up = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.down = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.left = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.right = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.positiveInfinity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Vector2.negativeInfinity = nil
--[[
	@x System.Single
	@y System.Single
	@return [luaIde#UnityEngine.Vector2]
]]
function UnityEngine.Vector2:New(x,y) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Vector2:geti(index) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Vector2:geti(index) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Vector2:seti(index,value) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Vector2:seti(index,value) end
--[[
	@newX System.Single
	@newY System.Single
--]]
function UnityEngine.Vector2:Set(newX,newY) end
--[[
	@a UnityEngine.Vector2
	@b UnityEngine.Vector2
	@t System.Single
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:Lerp(a,b,t) end
--[[
	@a UnityEngine.Vector2
	@b UnityEngine.Vector2
	@t System.Single
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:LerpUnclamped(a,b,t) end
--[[
	@current UnityEngine.Vector2
	@target UnityEngine.Vector2
	@maxDistanceDelta System.Single
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:MoveTowards(current,target,maxDistanceDelta) end
--[[
	@a UnityEngine.Vector2
	@b UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:Scale(a,b) end
function UnityEngine.Vector2:Normalize() end
function UnityEngine.Vector2:ToString() end
function UnityEngine.Vector2:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Vector2:Equals(other) end
--[[
	@inDirection UnityEngine.Vector2
	@inNormal UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:Reflect(inDirection,inNormal) end
--[[
	@inDirection UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:Perpendicular(inDirection) end
--[[
	@lhs UnityEngine.Vector2
	@rhs UnityEngine.Vector2
	return System.Single
--]]
function UnityEngine.Vector2:Dot(lhs,rhs) end
--[[
	@from UnityEngine.Vector2
	@to UnityEngine.Vector2
	return System.Single
--]]
function UnityEngine.Vector2:Angle(from,to) end
--[[
	@from UnityEngine.Vector2
	@to UnityEngine.Vector2
	return System.Single
--]]
function UnityEngine.Vector2:SignedAngle(from,to) end
--[[
	@a UnityEngine.Vector2
	@b UnityEngine.Vector2
	return System.Single
--]]
function UnityEngine.Vector2:Distance(a,b) end
--[[
	@vector UnityEngine.Vector2
	@maxLength System.Single
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:ClampMagnitude(vector,maxLength) end
--[[
	@a UnityEngine.Vector2
	return System.Single
--]]
function UnityEngine.Vector2:SqrMagnitude(a) end
--[[
	@lhs UnityEngine.Vector2
	@rhs UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:Min(lhs,rhs) end
--[[
	@lhs UnityEngine.Vector2
	@rhs UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:Max(lhs,rhs) end
--[[
	@current UnityEngine.Vector2
	@target UnityEngine.Vector2
	@currentVelocity UnityEngine.Vector2&
	@smoothTime System.Single
	@maxSpeed System.Single
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Vector2:SmoothDamp(current,target,currentVelocity,smoothTime,maxSpeed) end
function UnityEngine.Vector2:GetType() end

UnityEngine.Vector4 = {}
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector4.kEpsilon = 9.99999974737875E-06
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector4.x = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector4.y = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector4.z = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Vector4.w = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 
--]]
UnityEngine.Vector4.normalized = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector4.magnitude = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Vector4.sqrMagnitude = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 
--]]
UnityEngine.Vector4.zero = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 
--]]
UnityEngine.Vector4.one = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 
--]]
UnityEngine.Vector4.positiveInfinity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 
--]]
UnityEngine.Vector4.negativeInfinity = nil
--[[
	@x System.Single
	@y System.Single
	@return [luaIde#UnityEngine.Vector4]
]]
function UnityEngine.Vector4:New(x,y) end
--[[
	@x System.Single
	@y System.Single
	@z System.Single
	@return [luaIde#UnityEngine.Vector4]
]]
function UnityEngine.Vector4:New(x,y,z) end
--[[
	@x System.Single
	@y System.Single
	@z System.Single
	@w System.Single
	@return [luaIde#UnityEngine.Vector4]
]]
function UnityEngine.Vector4:New(x,y,z,w) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Vector4:geti(index) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Vector4:geti(index) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Vector4:seti(index,value) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Vector4:seti(index,value) end
--[[
	@newX System.Single
	@newY System.Single
	@newZ System.Single
	@newW System.Single
--]]
function UnityEngine.Vector4:Set(newX,newY,newZ,newW) end
--[[
	@a UnityEngine.Vector4
	@b UnityEngine.Vector4
	@t System.Single
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:Lerp(a,b,t) end
--[[
	@a UnityEngine.Vector4
	@b UnityEngine.Vector4
	@t System.Single
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:LerpUnclamped(a,b,t) end
--[[
	@current UnityEngine.Vector4
	@target UnityEngine.Vector4
	@maxDistanceDelta System.Single
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:MoveTowards(current,target,maxDistanceDelta) end
--[[
	@a UnityEngine.Vector4
	@b UnityEngine.Vector4
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:Scale(a,b) end
function UnityEngine.Vector4:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Vector4:Equals(other) end
--[[
	@a UnityEngine.Vector4
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:Normalize(a) end
--[[
	@a UnityEngine.Vector4
	@b UnityEngine.Vector4
	return System.Single
--]]
function UnityEngine.Vector4:Dot(a,b) end
--[[
	@a UnityEngine.Vector4
	@b UnityEngine.Vector4
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:Project(a,b) end
--[[
	@a UnityEngine.Vector4
	@b UnityEngine.Vector4
	return System.Single
--]]
function UnityEngine.Vector4:Distance(a,b) end
--[[
	@a UnityEngine.Vector4
	return System.Single
--]]
function UnityEngine.Vector4:Magnitude(a) end
--[[
	@lhs UnityEngine.Vector4
	@rhs UnityEngine.Vector4
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:Min(lhs,rhs) end
--[[
	@lhs UnityEngine.Vector4
	@rhs UnityEngine.Vector4
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Vector4:Max(lhs,rhs) end
function UnityEngine.Vector4:ToString() end
--[[
	@a UnityEngine.Vector4
	return System.Single
--]]
function UnityEngine.Vector4:SqrMagnitude(a) end
function UnityEngine.Vector4:GetType() end

UnityEngine.Color = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Color.r = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Color.g = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Color.b = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Color.a = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.red = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.green = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.blue = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.white = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.black = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.yellow = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.cyan = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.magenta = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.gray = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.grey = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.clear = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Color.grayscale = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.linear = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 
--]]
UnityEngine.Color.gamma = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Color.maxColorComponent = nil
--[[
	@r System.Single
	@g System.Single
	@b System.Single
	@return [luaIde#UnityEngine.Color]
]]
function UnityEngine.Color:New(r,g,b) end
--[[
	@r System.Single
	@g System.Single
	@b System.Single
	@a System.Single
	@return [luaIde#UnityEngine.Color]
]]
function UnityEngine.Color:New(r,g,b,a) end
function UnityEngine.Color:ToString() end
function UnityEngine.Color:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Color:Equals(other) end
--[[
	@a UnityEngine.Color
	@b UnityEngine.Color
	@t System.Single
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Color:Lerp(a,b,t) end
--[[
	@a UnityEngine.Color
	@b UnityEngine.Color
	@t System.Single
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Color:LerpUnclamped(a,b,t) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Color:geti(index) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Color:geti(index) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Color:seti(index,value) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Color:seti(index,value) end
--[[
	@rgbColor UnityEngine.Color
	@H System.Single&
	@S System.Single&
	@V System.Single&
--]]
function UnityEngine.Color:RGBToHSV(rgbColor,H,S,V) end
--[[
	@H System.Single
	@S System.Single
	@V System.Single
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Color:HSVToRGB(H,S,V) end
function UnityEngine.Color:GetType() end

UnityEngine.Quaternion = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Quaternion.x = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Quaternion.y = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Quaternion.z = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Quaternion.w = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Quaternion.kEpsilon = 9.99999997475243E-07
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 
--]]
UnityEngine.Quaternion.identity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Quaternion.eulerAngles = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 
--]]
UnityEngine.Quaternion.normalized = nil
--[[
	@x System.Single
	@y System.Single
	@z System.Single
	@w System.Single
	@return [luaIde#UnityEngine.Quaternion]
]]
function UnityEngine.Quaternion:New(x,y,z,w) end
--[[
	@fromDirection UnityEngine.Vector3
	@toDirection UnityEngine.Vector3
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:FromToRotation(fromDirection,toDirection) end
--[[
	@rotation UnityEngine.Quaternion
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:Inverse(rotation) end
--[[
	@a UnityEngine.Quaternion
	@b UnityEngine.Quaternion
	@t System.Single
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:Slerp(a,b,t) end
--[[
	@a UnityEngine.Quaternion
	@b UnityEngine.Quaternion
	@t System.Single
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:SlerpUnclamped(a,b,t) end
--[[
	@a UnityEngine.Quaternion
	@b UnityEngine.Quaternion
	@t System.Single
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:Lerp(a,b,t) end
--[[
	@a UnityEngine.Quaternion
	@b UnityEngine.Quaternion
	@t System.Single
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:LerpUnclamped(a,b,t) end
--[[
	@angle System.Single
	@axis UnityEngine.Vector3
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:AngleAxis(angle,axis) end
--[[
	@forward UnityEngine.Vector3
	@upwards UnityEngine.Vector3
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:LookRotation(forward,upwards) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Quaternion:geti(index) end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.Quaternion:geti(index) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Quaternion:seti(index,value) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.Quaternion:seti(index,value) end
--[[
	@newX System.Single
	@newY System.Single
	@newZ System.Single
	@newW System.Single
--]]
function UnityEngine.Quaternion:Set(newX,newY,newZ,newW) end
--[[
	@a UnityEngine.Quaternion
	@b UnityEngine.Quaternion
	return System.Single
--]]
function UnityEngine.Quaternion:Dot(a,b) end
--[[
	@view UnityEngine.Vector3
--]]
function UnityEngine.Quaternion:SetLookRotation(view) end
--[[
	@a UnityEngine.Quaternion
	@b UnityEngine.Quaternion
	return System.Single
--]]
function UnityEngine.Quaternion:Angle(a,b) end
--[[
	@x System.Single
	@y System.Single
	@z System.Single
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:Euler(x,y,z) end
--[[
	@angle System.Single&
	@axis UnityEngine.Vector3&
--]]
function UnityEngine.Quaternion:ToAngleAxis(angle,axis) end
--[[
	@fromDirection UnityEngine.Vector3
	@toDirection UnityEngine.Vector3
--]]
function UnityEngine.Quaternion:SetFromToRotation(fromDirection,toDirection) end
--[[
	@from UnityEngine.Quaternion
	@to UnityEngine.Quaternion
	@maxDegreesDelta System.Single
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:RotateTowards(from,to,maxDegreesDelta) end
--[[
	@q UnityEngine.Quaternion
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Quaternion:Normalize(q) end
function UnityEngine.Quaternion:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Quaternion:Equals(other) end
function UnityEngine.Quaternion:ToString() end
function UnityEngine.Quaternion:GetType() end

UnityEngine.Ray = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Ray.origin = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Ray.direction = nil
--[[
	@origin UnityEngine.Vector3
	@direction UnityEngine.Vector3
	@return [luaIde#UnityEngine.Ray]
]]
function UnityEngine.Ray:New(origin,direction) end
--[[
	@distance System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Ray:GetPoint(distance) end
function UnityEngine.Ray:ToString() end
--[[
	@obj System.Object
	return System.Boolean
--]]
function UnityEngine.Ray:Equals(obj) end
function UnityEngine.Ray:GetHashCode() end
function UnityEngine.Ray:GetType() end

UnityEngine.Bounds = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Bounds.center = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Bounds.size = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Bounds.extents = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Bounds.min = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Bounds.max = nil
--[[
	@center UnityEngine.Vector3
	@size UnityEngine.Vector3
	@return [luaIde#UnityEngine.Bounds]
]]
function UnityEngine.Bounds:New(center,size) end
function UnityEngine.Bounds:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Bounds:Equals(other) end
--[[
	@min UnityEngine.Vector3
	@max UnityEngine.Vector3
--]]
function UnityEngine.Bounds:SetMinMax(min,max) end
--[[
	@point UnityEngine.Vector3
--]]
function UnityEngine.Bounds:Encapsulate(point) end
--[[
	@amount System.Single
--]]
function UnityEngine.Bounds:Expand(amount) end
--[[
	@bounds UnityEngine.Bounds
	return System.Boolean
--]]
function UnityEngine.Bounds:Intersects(bounds) end
--[[
	@ray UnityEngine.Ray
	return System.Boolean
--]]
function UnityEngine.Bounds:IntersectRay(ray) end
function UnityEngine.Bounds:ToString() end
--[[
	@point UnityEngine.Vector3
	return System.Boolean
--]]
function UnityEngine.Bounds:Contains(point) end
--[[
	@point UnityEngine.Vector3
	return System.Single
--]]
function UnityEngine.Bounds:SqrDistance(point) end
--[[
	@point UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Bounds:ClosestPoint(point) end
function UnityEngine.Bounds:GetType() end

UnityEngine.Touch = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Touch.fingerId = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Touch.position = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Touch.rawPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Touch.deltaPosition = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.deltaTime = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Touch.tapCount = nil
--[[
	UnityEngine.TouchPhase
	 Get 	 Set 
--]]
UnityEngine.Touch.phase = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.pressure = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.maximumPossiblePressure = nil
--[[
	UnityEngine.TouchType
	 Get 	 Set 
--]]
UnityEngine.Touch.type = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.altitudeAngle = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.azimuthAngle = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.radius = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Touch.radiusVariance = nil
function UnityEngine.Touch:New () end
--[[
	@obj System.Object
	return System.Boolean
--]]
function UnityEngine.Touch:Equals(obj) end
function UnityEngine.Touch:GetHashCode() end
function UnityEngine.Touch:ToString() end
function UnityEngine.Touch:GetType() end

UnityEngine.RaycastHit = {}
--[[
	@RefType [luaIde#UnityEngine.Collider]
	 Get 
--]]
UnityEngine.RaycastHit.collider = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.RaycastHit.point = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.RaycastHit.normal = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.RaycastHit.barycentricCoordinate = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.RaycastHit.distance = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.RaycastHit.triangleIndex = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.RaycastHit.textureCoord = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.RaycastHit.textureCoord2 = nil
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 
--]]
UnityEngine.RaycastHit.transform = nil
--[[
	@RefType [luaIde#UnityEngine.Rigidbody]
	 Get 
--]]
UnityEngine.RaycastHit.rigidbody = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.RaycastHit.lightmapCoord = nil
function UnityEngine.RaycastHit:New () end
--[[
	@obj System.Object
	return System.Boolean
--]]
function UnityEngine.RaycastHit:Equals(obj) end
function UnityEngine.RaycastHit:GetHashCode() end
function UnityEngine.RaycastHit:ToString() end
function UnityEngine.RaycastHit:GetType() end

UnityEngine.LayerMask = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.LayerMask.value = nil
function UnityEngine.LayerMask:New () end
--[[
	@layer System.Int32
	return System.String
--]]
function UnityEngine.LayerMask:LayerToName(layer) end
--[[
	@layerName System.String
	return System.Int32
--]]
function UnityEngine.LayerMask:NameToLayer(layerName) end
--[[
	@layerNames System.String{}
	return System.Int32
--]]
function UnityEngine.LayerMask:GetMask(layerNames) end
--[[
	@obj System.Object
	return System.Boolean
--]]
function UnityEngine.LayerMask:Equals(obj) end
function UnityEngine.LayerMask:GetHashCode() end
function UnityEngine.LayerMask:ToString() end
function UnityEngine.LayerMask:GetType() end

Debugger = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
Debugger.useLog = nil
--[[
	System.String
	 Get 	 Set 
--]]
Debugger.threadStack = nil
--[[
	LuaInterface.ILogger
	 Get 	 Set 
--]]
Debugger.logger = nil
--[[
	@str System.String
--]]
function Debugger:Log(str) end
--[[
	@str System.String
--]]
function Debugger:LogWarning(str) end
--[[
	@str System.String
--]]
function Debugger:LogError(str) end
--[[
	@e System.Exception
--]]
function Debugger:LogException(e) end

--@SuperType [luaIde#System.Object]
DG.Tweening.DOTween = {}
--[[
	System.String
	 Get 
--]]
DG.Tweening.DOTween.Version = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.useSafeMode = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.showUnityEditorReport = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.DOTween.timeScale = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.useSmoothDeltaTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.DOTween.maxSmoothUnscaledTime = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.drawGizmos = nil
--[[
	DG.Tweening.UpdateType
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultUpdateType = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultTimeScaleIndependent = nil
--[[
	DG.Tweening.AutoPlay
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultAutoPlay = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultAutoKill = nil
--[[
	DG.Tweening.LoopType
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultLoopType = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultRecyclable = nil
--[[
	DG.Tweening.Ease
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultEaseType = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultEaseOvershootOrAmplitude = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.DOTween.defaultEasePeriod = nil
--[[
	DG.Tweening.LogBehaviour
	 Get 	 Set 
--]]
DG.Tweening.DOTween.logBehaviour = nil
--[[
	@return [luaIde#DG.Tweening.DOTween]
]]
function DG.Tweening.DOTween:New() end
--[[
	@recycleAllByDefault System.Nullable`1{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	@useSafeMode System.Nullable`1{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	@logBehaviour System.Nullable`1{{DG.Tweening.LogBehaviour, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return DG.Tweening.IDOTweenInit
--]]
function DG.Tweening.DOTween:Init(recycleAllByDefault,useSafeMode,logBehaviour) end
--[[
	@tweenersCapacity System.Int32
	@sequencesCapacity System.Int32
--]]
function DG.Tweening.DOTween:SetTweensCapacity(tweenersCapacity,sequencesCapacity) end
--[[
	@destroy System.Boolean
--]]
function DG.Tweening.DOTween:Clear(destroy) end
function DG.Tweening.DOTween:ClearCachedTweens() end
function DG.Tweening.DOTween:Validate() end
--[[
	@deltaTime System.Single
	@unscaledDeltaTime System.Single
--]]
function DG.Tweening.DOTween:ManualUpdate(deltaTime,unscaledDeltaTime) end
--[[
	@getter DG.Tweening.Core.DOGetter`1{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	@setter DG.Tweening.Core.DOSetter`1{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	@endValue System.Single
	@duration System.Single
	return DG.Tweening.Core.TweenerCore`3{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089},{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089},{DG.Tweening.Plugins.Options.FloatOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:To(getter,setter,endValue,duration) end
--[[
	@getter DG.Tweening.Core.DOGetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@setter DG.Tweening.Core.DOSetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@endValue System.Single
	@duration System.Single
	@axisConstraint DG.Tweening.AxisConstraint
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.VectorOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:ToAxis(getter,setter,endValue,duration,axisConstraint) end
--[[
	@getter DG.Tweening.Core.DOGetter`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@setter DG.Tweening.Core.DOSetter`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function DG.Tweening.DOTween:ToAlpha(getter,setter,endValue,duration) end
--[[
	@getter DG.Tweening.Core.DOGetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@setter DG.Tweening.Core.DOSetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@direction UnityEngine.Vector3
	@duration System.Single
	@vibrato System.Int32
	@elasticity System.Single
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.Vector3{}, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.Vector3ArrayOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:Punch(getter,setter,direction,duration,vibrato,elasticity) end
--[[
	@getter DG.Tweening.Core.DOGetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@setter DG.Tweening.Core.DOSetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@duration System.Single
	@strength System.Single
	@vibrato System.Int32
	@randomness System.Single
	@ignoreZAxis System.Boolean
	@fadeOut System.Boolean
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.Vector3{}, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.Vector3ArrayOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:Shake(getter,setter,duration,strength,vibrato,randomness,ignoreZAxis,fadeOut) end
--[[
	@getter DG.Tweening.Core.DOGetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@setter DG.Tweening.Core.DOSetter`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@endValues UnityEngine.Vector3{}
	@durations System.Single{}
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.Vector3{}, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.Vector3ArrayOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:ToArray(getter,setter,endValues,durations) end
function DG.Tweening.DOTween:Sequence() end
--[[
	@withCallbacks System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:CompleteAll(withCallbacks) end
--[[
	@targetOrId System.Object
	@withCallbacks System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:Complete(targetOrId,withCallbacks) end
function DG.Tweening.DOTween:FlipAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:Flip(targetOrId) end
--[[
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:GotoAll(to,andPlay) end
--[[
	@targetOrId System.Object
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:Goto(targetOrId,to,andPlay) end
--[[
	@complete System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:KillAll(complete) end
--[[
	@targetOrId System.Object
	@complete System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:Kill(targetOrId,complete) end
function DG.Tweening.DOTween:PauseAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:Pause(targetOrId) end
function DG.Tweening.DOTween:PlayAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:Play(targetOrId) end
function DG.Tweening.DOTween:PlayBackwardsAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:PlayBackwards(targetOrId) end
function DG.Tweening.DOTween:PlayForwardAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:PlayForward(targetOrId) end
--[[
	@includeDelay System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:RestartAll(includeDelay) end
--[[
	@targetOrId System.Object
	@includeDelay System.Boolean
	@changeDelayTo System.Single
	return System.Int32
--]]
function DG.Tweening.DOTween:Restart(targetOrId,includeDelay,changeDelayTo) end
--[[
	@includeDelay System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:RewindAll(includeDelay) end
--[[
	@targetOrId System.Object
	@includeDelay System.Boolean
	return System.Int32
--]]
function DG.Tweening.DOTween:Rewind(targetOrId,includeDelay) end
function DG.Tweening.DOTween:SmoothRewindAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:SmoothRewind(targetOrId) end
function DG.Tweening.DOTween:TogglePauseAll() end
--[[
	@targetOrId System.Object
	return System.Int32
--]]
function DG.Tweening.DOTween:TogglePause(targetOrId) end
--[[
	@targetOrId System.Object
	@alsoCheckIfIsPlaying System.Boolean
	return System.Boolean
--]]
function DG.Tweening.DOTween:IsTweening(targetOrId,alsoCheckIfIsPlaying) end
function DG.Tweening.DOTween:TotalPlayingTweens() end
--[[
	@fillableList System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:PlayingTweens(fillableList) end
--[[
	@fillableList System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:PausedTweens(fillableList) end
--[[
	@id System.Object
	@playingOnly System.Boolean
	@fillableList System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:TweensById(id,playingOnly,fillableList) end
--[[
	@target System.Object
	@playingOnly System.Boolean
	@fillableList System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return System.Collections.Generic.List`1{{DG.Tweening.Tween, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function DG.Tweening.DOTween:TweensByTarget(target,playingOnly,fillableList) end

--@SuperType [luaIde#System.Object]
DG.Tweening.Tween = {}
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.Tween.timeScale = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
DG.Tweening.Tween.isBackwards = nil
--[[
	System.Object
	 Get 	 Set 
--]]
DG.Tweening.Tween.id = nil
--[[
	System.String
	 Get 	 Set 
--]]
DG.Tweening.Tween.stringId = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
DG.Tweening.Tween.intId = nil
--[[
	System.Object
	 Get 	 Set 
--]]
DG.Tweening.Tween.target = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onPlay = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onPause = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onRewind = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onUpdate = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onStepComplete = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onComplete = nil
--[[
	DG.Tweening.TweenCallback
	 Get 	 Set 
--]]
DG.Tweening.Tween.onKill = nil
--[[
	DG.Tweening.TweenCallback`1{{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	 Get 	 Set 
--]]
DG.Tweening.Tween.onWaypointChange = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.Tween.easeOvershootOrAmplitude = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.Tween.easePeriod = nil
--[[
	System.Single
	 Get 	 Set 
--]]
DG.Tweening.Tween.fullPosition = nil
--[[
	@t DG.Tweening.Tween
	return System.Single
--]]
function DG.Tweening.Tween:PathLength(t) end
--[[
	@t DG.Tweening.Tween
	@subdivisionsXSegment System.Int32
	return UnityEngine.Vector3{}
--]]
function DG.Tweening.Tween:PathGetDrawPoints(t,subdivisionsXSegment) end
--[[
	@t DG.Tweening.Tween
	@pathPercentage System.Single
	@return [luaIde#UnityEngine.Vector3]
--]]
function DG.Tweening.Tween:PathGetPoint(t,pathPercentage) end
--[[
	@t DG.Tweening.Tween
	return System.Int32
--]]
function DG.Tweening.Tween:Loops(t) end
--[[
	@t DG.Tweening.Tween
	return System.Boolean
--]]
function DG.Tweening.Tween:IsPlaying(t) end
--[[
	@t DG.Tweening.Tween
	return System.Boolean
--]]
function DG.Tweening.Tween:IsInitialized(t) end
--[[
	@t DG.Tweening.Tween
	return System.Boolean
--]]
function DG.Tweening.Tween:IsComplete(t) end
--[[
	@t DG.Tweening.Tween
	return System.Boolean
--]]
function DG.Tweening.Tween:IsBackwards(t) end
--[[
	@t DG.Tweening.Tween
	return System.Boolean
--]]
function DG.Tweening.Tween:IsActive(t) end
--[[
	@t DG.Tweening.Tween
	return System.Single
--]]
function DG.Tweening.Tween:ElapsedDirectionalPercentage(t) end
--[[
	@t DG.Tweening.Tween
	@includeLoops System.Boolean
	return System.Single
--]]
function DG.Tweening.Tween:ElapsedPercentage(t,includeLoops) end
--[[
	@t DG.Tweening.Tween
	@includeLoops System.Boolean
	return System.Single
--]]
function DG.Tweening.Tween:Elapsed(t,includeLoops) end
--[[
	@t DG.Tweening.Tween
	@includeLoops System.Boolean
	return System.Single
--]]
function DG.Tweening.Tween:Duration(t,includeLoops) end
--[[
	@t DG.Tweening.Tween
	return System.Single
--]]
function DG.Tweening.Tween:Delay(t) end
--[[
	@t DG.Tweening.Tween
	return System.Int32
--]]
function DG.Tweening.Tween:CompletedLoops(t) end
--[[
	@t DG.Tweening.Tween
	return UnityEngine.Coroutine
--]]
function DG.Tweening.Tween:WaitForStart(t) end
--[[
	@t DG.Tweening.Tween
	@position System.Single
	return UnityEngine.YieldInstruction
--]]
function DG.Tweening.Tween:WaitForPosition(t,position) end
--[[
	@t DG.Tweening.Tween
	@elapsedLoops System.Int32
	return UnityEngine.YieldInstruction
--]]
function DG.Tweening.Tween:WaitForElapsedLoops(t,elapsedLoops) end
--[[
	@t DG.Tweening.Tween
	return UnityEngine.YieldInstruction
--]]
function DG.Tweening.Tween:WaitForKill(t) end
--[[
	@t DG.Tweening.Tween
	return UnityEngine.YieldInstruction
--]]
function DG.Tweening.Tween:WaitForRewind(t) end
--[[
	@t DG.Tweening.Tween
	return UnityEngine.YieldInstruction
--]]
function DG.Tweening.Tween:WaitForCompletion(t) end
--[[
	@t DG.Tweening.Tween
	@waypointIndex System.Int32
	@andPlay System.Boolean
--]]
function DG.Tweening.Tween:GotoWaypoint(t,waypointIndex,andPlay) end
--[[
	@t DG.Tweening.Tween
--]]
function DG.Tweening.Tween:TogglePause(t) end
--[[
	@t DG.Tweening.Tween
--]]
function DG.Tweening.Tween:SmoothRewind(t) end
--[[
	@t DG.Tweening.Tween
	@includeDelay System.Boolean
--]]
function DG.Tweening.Tween:Rewind(t,includeDelay) end
--[[
	@t DG.Tweening.Tween
	@includeDelay System.Boolean
	@changeDelayTo System.Single
--]]
function DG.Tweening.Tween:Restart(t,includeDelay,changeDelayTo) end
--[[
	@t DG.Tweening.Tween
--]]
function DG.Tweening.Tween:PlayForward(t) end
--[[
	@t DG.Tweening.Tween
--]]
function DG.Tweening.Tween:PlayBackwards(t) end
--[[
	@t T
	return T
--]]
function DG.Tweening.Tween:Play(t) end
--[[
	@t T
	return T
--]]
function DG.Tweening.Tween:Pause(t) end
--[[
	@t DG.Tweening.Tween
	@complete System.Boolean
--]]
function DG.Tweening.Tween:Kill(t,complete) end
--[[
	@t DG.Tweening.Tween
	@to System.Single
	@andPlay System.Boolean
--]]
function DG.Tweening.Tween:Goto(t,to,andPlay) end
--[[
	@t DG.Tweening.Tween
--]]
function DG.Tweening.Tween:ForceInit(t) end
--[[
	@t DG.Tweening.Tween
--]]
function DG.Tweening.Tween:Flip(t) end
--[[
	@t DG.Tweening.Tween
	@withCallbacks System.Boolean
--]]
function DG.Tweening.Tween:Complete(t,withCallbacks) end

--@SuperType [luaIde#DG.Tweening.Tween]
DG.Tweening.Sequence = {}
--[[
	@t T
	@isSpeedBased System.Boolean
	return T
--]]
function DG.Tweening.Sequence:SetSpeedBased(t,isSpeedBased) end
--[[
	@t T
	@isRelative System.Boolean
	return T
--]]
function DG.Tweening.Sequence:SetRelative(t,isRelative) end
--[[
	@t T
	@delay System.Single
	return T
--]]
function DG.Tweening.Sequence:SetDelay(t,delay) end
--[[
	@s DG.Tweening.Sequence
	@atPosition System.Single
	@callback DG.Tweening.TweenCallback
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:InsertCallback(s,atPosition,callback) end
--[[
	@s DG.Tweening.Sequence
	@callback DG.Tweening.TweenCallback
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:PrependCallback(s,callback) end
--[[
	@s DG.Tweening.Sequence
	@callback DG.Tweening.TweenCallback
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:AppendCallback(s,callback) end
--[[
	@s DG.Tweening.Sequence
	@interval System.Single
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:PrependInterval(s,interval) end
--[[
	@s DG.Tweening.Sequence
	@interval System.Single
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:AppendInterval(s,interval) end
--[[
	@s DG.Tweening.Sequence
	@atPosition System.Single
	@t DG.Tweening.Tween
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:Insert(s,atPosition,t) end
--[[
	@s DG.Tweening.Sequence
	@t DG.Tweening.Tween
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:Join(s,t) end
--[[
	@s DG.Tweening.Sequence
	@t DG.Tweening.Tween
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:Prepend(s,t) end
--[[
	@s DG.Tweening.Sequence
	@t DG.Tweening.Tween
	@return [luaIde#DG.Tweening.Sequence]
--]]
function DG.Tweening.Sequence:Append(s,t) end
--[[
	@t T
	@tweenParams DG.Tweening.TweenParams
	return T
--]]
function DG.Tweening.Sequence:SetAs(t,tweenParams) end
--[[
	@t T
	@action DG.Tweening.TweenCallback`1{{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	return T
--]]
function DG.Tweening.Sequence:OnWaypointChange(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnKill(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnComplete(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnStepComplete(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnUpdate(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnRewind(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnPause(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnPlay(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Sequence:OnStart(t,action) end
--[[
	@t T
	@updateType DG.Tweening.UpdateType
	@isIndependentUpdate System.Boolean
	return T
--]]
function DG.Tweening.Sequence:SetUpdate(t,updateType,isIndependentUpdate) end
--[[
	@t T
	@recyclable System.Boolean
	return T
--]]
function DG.Tweening.Sequence:SetRecyclable(t,recyclable) end
--[[
	@t T
	@customEase DG.Tweening.EaseFunction
	return T
--]]
function DG.Tweening.Sequence:SetEase(t,customEase) end
--[[
	@t T
	@loops System.Int32
	@loopType DG.Tweening.LoopType
	return T
--]]
function DG.Tweening.Sequence:SetLoops(t,loops,loopType) end
--[[
	@t T
	@target System.Object
	return T
--]]
function DG.Tweening.Sequence:SetTarget(t,target) end
--[[
	@t T
	@intId System.Int32
	return T
--]]
function DG.Tweening.Sequence:SetId(t,intId) end
--[[
	@t T
	@autoKillOnCompletion System.Boolean
	return T
--]]
function DG.Tweening.Sequence:SetAutoKill(t,autoKillOnCompletion) end

--@SuperType [luaIde#DG.Tweening.Tween]
DG.Tweening.Tweener = {}
--[[
	@newStartValue System.Object
	@newDuration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function DG.Tweening.Tweener:ChangeStartValue(newStartValue,newDuration) end
--[[
	@newEndValue System.Object
	@newDuration System.Single
	@snapStartValue System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function DG.Tweening.Tweener:ChangeEndValue(newEndValue,newDuration,snapStartValue) end
--[[
	@newStartValue System.Object
	@newEndValue System.Object
	@newDuration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function DG.Tweening.Tweener:ChangeValues(newStartValue,newEndValue,newDuration) end
--[[
	@t T
	@isSpeedBased System.Boolean
	return T
--]]
function DG.Tweening.Tweener:SetSpeedBased(t,isSpeedBased) end
--[[
	@t T
	@isRelative System.Boolean
	return T
--]]
function DG.Tweening.Tweener:SetRelative(t,isRelative) end
--[[
	@t T
	@delay System.Single
	return T
--]]
function DG.Tweening.Tweener:SetDelay(t,delay) end
--[[
	@t T
	@isRelative System.Boolean
	return T
--]]
function DG.Tweening.Tweener:From(t,isRelative) end
--[[
	@t T
	@tweenParams DG.Tweening.TweenParams
	return T
--]]
function DG.Tweening.Tweener:SetAs(t,tweenParams) end
--[[
	@t T
	@action DG.Tweening.TweenCallback`1{{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	return T
--]]
function DG.Tweening.Tweener:OnWaypointChange(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnKill(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnComplete(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnStepComplete(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnUpdate(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnRewind(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnPause(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnPlay(t,action) end
--[[
	@t T
	@action DG.Tweening.TweenCallback
	return T
--]]
function DG.Tweening.Tweener:OnStart(t,action) end
--[[
	@t T
	@updateType DG.Tweening.UpdateType
	@isIndependentUpdate System.Boolean
	return T
--]]
function DG.Tweening.Tweener:SetUpdate(t,updateType,isIndependentUpdate) end
--[[
	@t T
	@recyclable System.Boolean
	return T
--]]
function DG.Tweening.Tweener:SetRecyclable(t,recyclable) end
--[[
	@t T
	@customEase DG.Tweening.EaseFunction
	return T
--]]
function DG.Tweening.Tweener:SetEase(t,customEase) end
--[[
	@t T
	@loops System.Int32
	@loopType DG.Tweening.LoopType
	return T
--]]
function DG.Tweening.Tweener:SetLoops(t,loops,loopType) end
--[[
	@t T
	@target System.Object
	return T
--]]
function DG.Tweening.Tweener:SetTarget(t,target) end
--[[
	@t T
	@intId System.Int32
	return T
--]]
function DG.Tweening.Tweener:SetId(t,intId) end
--[[
	@t T
	@autoKillOnCompletion System.Boolean
	return T
--]]
function DG.Tweening.Tweener:SetAutoKill(t,autoKillOnCompletion) end

--DG.Tweening.LoopType  Enum
DG.Tweening.LoopType = {}
--[[

	 Get 
--]]
DG.Tweening.LoopType.Restart = 0
--[[

	 Get 
--]]
DG.Tweening.LoopType.Yoyo = 1
--[[

	 Get 
--]]
DG.Tweening.LoopType.Incremental = 2

--DG.Tweening.PathMode  Enum
DG.Tweening.PathMode = {}
--[[

	 Get 
--]]
DG.Tweening.PathMode.Ignore = 0
--[[

	 Get 
--]]
DG.Tweening.PathMode.Full3D = 1
--[[

	 Get 
--]]
DG.Tweening.PathMode.TopDown2D = 2
--[[

	 Get 
--]]
DG.Tweening.PathMode.Sidescroller2D = 3

--DG.Tweening.PathType  Enum
DG.Tweening.PathType = {}
--[[

	 Get 
--]]
DG.Tweening.PathType.Linear = 0
--[[

	 Get 
--]]
DG.Tweening.PathType.CatmullRom = 1

--DG.Tweening.RotateMode  Enum
DG.Tweening.RotateMode = {}
--[[

	 Get 
--]]
DG.Tweening.RotateMode.Fast = 0
--[[

	 Get 
--]]
DG.Tweening.RotateMode.FastBeyond360 = 1
--[[

	 Get 
--]]
DG.Tweening.RotateMode.WorldAxisAdd = 2
--[[

	 Get 
--]]
DG.Tweening.RotateMode.LocalAxisAdd = 3

--DG.Tweening.Ease  Enum
DG.Tweening.Ease = {}
--[[

	 Get 
--]]
DG.Tweening.Ease.Unset = 0
--[[

	 Get 
--]]
DG.Tweening.Ease.Linear = 1
--[[

	 Get 
--]]
DG.Tweening.Ease.InSine = 2
--[[

	 Get 
--]]
DG.Tweening.Ease.OutSine = 3
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutSine = 4
--[[

	 Get 
--]]
DG.Tweening.Ease.InQuad = 5
--[[

	 Get 
--]]
DG.Tweening.Ease.OutQuad = 6
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutQuad = 7
--[[

	 Get 
--]]
DG.Tweening.Ease.InCubic = 8
--[[

	 Get 
--]]
DG.Tweening.Ease.OutCubic = 9
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutCubic = 10
--[[

	 Get 
--]]
DG.Tweening.Ease.InQuart = 11
--[[

	 Get 
--]]
DG.Tweening.Ease.OutQuart = 12
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutQuart = 13
--[[

	 Get 
--]]
DG.Tweening.Ease.InQuint = 14
--[[

	 Get 
--]]
DG.Tweening.Ease.OutQuint = 15
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutQuint = 16
--[[

	 Get 
--]]
DG.Tweening.Ease.InExpo = 17
--[[

	 Get 
--]]
DG.Tweening.Ease.OutExpo = 18
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutExpo = 19
--[[

	 Get 
--]]
DG.Tweening.Ease.InCirc = 20
--[[

	 Get 
--]]
DG.Tweening.Ease.OutCirc = 21
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutCirc = 22
--[[

	 Get 
--]]
DG.Tweening.Ease.InElastic = 23
--[[

	 Get 
--]]
DG.Tweening.Ease.OutElastic = 24
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutElastic = 25
--[[

	 Get 
--]]
DG.Tweening.Ease.InBack = 26
--[[

	 Get 
--]]
DG.Tweening.Ease.OutBack = 27
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutBack = 28
--[[

	 Get 
--]]
DG.Tweening.Ease.InBounce = 29
--[[

	 Get 
--]]
DG.Tweening.Ease.OutBounce = 30
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutBounce = 31
--[[

	 Get 
--]]
DG.Tweening.Ease.Flash = 32
--[[

	 Get 
--]]
DG.Tweening.Ease.InFlash = 33
--[[

	 Get 
--]]
DG.Tweening.Ease.OutFlash = 34
--[[

	 Get 
--]]
DG.Tweening.Ease.InOutFlash = 35
--[[

	 Get 
--]]
DG.Tweening.Ease.INTERNAL_Zero = 36
--[[

	 Get 
--]]
DG.Tweening.Ease.INTERNAL_Custom = 37

--@SuperType [luaIde#DG.Tweening.Tweener]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions.startValue = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions.endValue = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions.changeValue = nil
--[[
	DG.Tweening.Plugins.Options.QuaternionOptions
	 Get 	 Set 
--]]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions.plugOptions = nil
--[[
	DG.Tweening.Core.DOGetter`1{{UnityEngine.Quaternion, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions.getter = nil
--[[
	DG.Tweening.Core.DOSetter`1{{UnityEngine.Quaternion, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions.setter = nil
--[[
	@newStartValue System.Object
	@newDuration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions:ChangeStartValue(newStartValue,newDuration) end
--[[
	@newEndValue System.Object
	@snapStartValue System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions:ChangeEndValue(newEndValue,snapStartValue) end
--[[
	@newStartValue System.Object
	@newEndValue System.Object
	@newDuration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function TweenerCore_UnityEngine_Quaternion_UnityEngine_Vector3_DG_Tweening_Plugins_Options_QuaternionOptions:ChangeValues(newStartValue,newEndValue,newDuration) end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.Component = {}
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 
--]]
UnityEngine.Component.transform = nil
--[[
	@RefType [luaIde#UnityEngine.GameObject]
	 Get 
--]]
UnityEngine.Component.gameObject = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.Component.tag = nil
--[[
	@return [luaIde#UnityEngine.Component]
]]
function UnityEngine.Component:New() end
--[[
	@type System.Type
	@return [luaIde#UnityEngine.Component]
--]]
function UnityEngine.Component:GetComponent(type) end
--[[
	@t System.Type
	@includeInactive System.Boolean
	@return [luaIde#UnityEngine.Component]
--]]
function UnityEngine.Component:GetComponentInChildren(t,includeInactive) end
--[[
	@t System.Type
	@includeInactive System.Boolean
	return UnityEngine.Component{}
--]]
function UnityEngine.Component:GetComponentsInChildren(t,includeInactive) end
--[[
	@t System.Type
	@return [luaIde#UnityEngine.Component]
--]]
function UnityEngine.Component:GetComponentInParent(t) end
--[[
	@t System.Type
	@includeInactive System.Boolean
	return UnityEngine.Component{}
--]]
function UnityEngine.Component:GetComponentsInParent(t,includeInactive) end
--[[
	@type System.Type
	return UnityEngine.Component{}
--]]
function UnityEngine.Component:GetComponents(type) end
--[[
	@tag System.String
	return System.Boolean
--]]
function UnityEngine.Component:CompareTag(tag) end
--[[
	@methodName System.String
	@value System.Object
	@options UnityEngine.SendMessageOptions
--]]
function UnityEngine.Component:SendMessageUpwards(methodName,value,options) end
--[[
	@methodName System.String
	@value System.Object
--]]
function UnityEngine.Component:SendMessage(methodName,value) end
--[[
	@methodName System.String
	@parameter System.Object
	@options UnityEngine.SendMessageOptions
--]]
function UnityEngine.Component:BroadcastMessage(methodName,parameter,options) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Component:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Component:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.Component:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Component:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.Component:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.Component:DOComplete(target,withCallbacks) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.Transform = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.position = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.localPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.eulerAngles = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.localEulerAngles = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.right = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.up = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.forward = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 	 Set 
--]]
UnityEngine.Transform.rotation = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 	 Set 
--]]
UnityEngine.Transform.localRotation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Transform.localScale = nil
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 	 Set 
--]]
UnityEngine.Transform.parent = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Transform.worldToLocalMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Transform.localToWorldMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 
--]]
UnityEngine.Transform.root = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Transform.childCount = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Transform.lossyScale = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Transform.hasChanged = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Transform.hierarchyCapacity = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Transform.hierarchyCount = nil
--[[
	@p UnityEngine.Transform
--]]
function UnityEngine.Transform:SetParent(p) end
--[[
	@position UnityEngine.Vector3
	@rotation UnityEngine.Quaternion
--]]
function UnityEngine.Transform:SetPositionAndRotation(position,rotation) end
--[[
	@translation UnityEngine.Vector3
	@relativeTo UnityEngine.Space
--]]
function UnityEngine.Transform:Translate(translation,relativeTo) end
--[[
	@eulers UnityEngine.Vector3
	@relativeTo UnityEngine.Space
--]]
function UnityEngine.Transform:Rotate(eulers,relativeTo) end
--[[
	@point UnityEngine.Vector3
	@axis UnityEngine.Vector3
	@angle System.Single
--]]
function UnityEngine.Transform:RotateAround(point,axis,angle) end
--[[
	@target UnityEngine.Transform
	@worldUp UnityEngine.Vector3
--]]
function UnityEngine.Transform:LookAt(target,worldUp) end
--[[
	@direction UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Transform:TransformDirection(direction) end
--[[
	@direction UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Transform:InverseTransformDirection(direction) end
--[[
	@vector UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Transform:TransformVector(vector) end
--[[
	@vector UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Transform:InverseTransformVector(vector) end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Transform:TransformPoint(position) end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Transform:InverseTransformPoint(position) end
function UnityEngine.Transform:DetachChildren() end
function UnityEngine.Transform:SetAsFirstSibling() end
function UnityEngine.Transform:SetAsLastSibling() end
--[[
	@index System.Int32
--]]
function UnityEngine.Transform:SetSiblingIndex(index) end
function UnityEngine.Transform:GetSiblingIndex() end
--[[
	@n System.String
	@return [luaIde#UnityEngine.Transform]
--]]
function UnityEngine.Transform:Find(n) end
--[[
	@parent UnityEngine.Transform
	return System.Boolean
--]]
function UnityEngine.Transform:IsChildOf(parent) end
function UnityEngine.Transform:GetEnumerator() end
--[[
	@index System.Int32
	@return [luaIde#UnityEngine.Transform]
--]]
function UnityEngine.Transform:GetChild(index) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Transform:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Transform:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.Transform:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Transform:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.Transform:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.Transform:DOComplete(target,withCallbacks) end
--[[
	@target UnityEngine.Transform
	@byValue UnityEngine.Vector3
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOBlendableScaleBy(target,byValue,duration) end
--[[
	@target UnityEngine.Transform
	@punch UnityEngine.Vector3
	@duration System.Single
	@vibrato System.Int32
	@elasticity System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOBlendablePunchRotation(target,punch,duration,vibrato,elasticity) end
--[[
	@target UnityEngine.Transform
	@byValue UnityEngine.Vector3
	@duration System.Single
	@mode DG.Tweening.RotateMode
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOBlendableLocalRotateBy(target,byValue,duration,mode) end
--[[
	@target UnityEngine.Transform
	@byValue UnityEngine.Vector3
	@duration System.Single
	@mode DG.Tweening.RotateMode
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOBlendableRotateBy(target,byValue,duration,mode) end
--[[
	@target UnityEngine.Transform
	@byValue UnityEngine.Vector3
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOBlendableLocalMoveBy(target,byValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@byValue UnityEngine.Vector3
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOBlendableMoveBy(target,byValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@path UnityEngine.Vector3{}
	@duration System.Single
	@pathType DG.Tweening.PathType
	@pathMode DG.Tweening.PathMode
	@resolution System.Int32
	@gizmoColor System.Nullable`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Core.PathCore.Path, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.PathOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Transform:DOLocalPath(target,path,duration,pathType,pathMode,resolution,gizmoColor) end
--[[
	@target UnityEngine.Transform
	@path UnityEngine.Vector3{}
	@duration System.Single
	@pathType DG.Tweening.PathType
	@pathMode DG.Tweening.PathMode
	@resolution System.Int32
	@gizmoColor System.Nullable`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Core.PathCore.Path, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.PathOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Transform:DOPath(target,path,duration,pathType,pathMode,resolution,gizmoColor) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Vector3
	@jumpPower System.Single
	@numJumps System.Int32
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Sequence]
--]]
function UnityEngine.Transform:DOLocalJump(target,endValue,jumpPower,numJumps,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Vector3
	@jumpPower System.Single
	@numJumps System.Int32
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Sequence]
--]]
function UnityEngine.Transform:DOJump(target,endValue,jumpPower,numJumps,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@duration System.Single
	@strength UnityEngine.Vector3
	@vibrato System.Int32
	@randomness System.Single
	@fadeOut System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOShakeScale(target,duration,strength,vibrato,randomness,fadeOut) end
--[[
	@target UnityEngine.Transform
	@duration System.Single
	@strength UnityEngine.Vector3
	@vibrato System.Int32
	@randomness System.Single
	@fadeOut System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOShakeRotation(target,duration,strength,vibrato,randomness,fadeOut) end
--[[
	@target UnityEngine.Transform
	@duration System.Single
	@strength UnityEngine.Vector3
	@vibrato System.Int32
	@randomness System.Single
	@snapping System.Boolean
	@fadeOut System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOShakePosition(target,duration,strength,vibrato,randomness,snapping,fadeOut) end
--[[
	@target UnityEngine.Transform
	@punch UnityEngine.Vector3
	@duration System.Single
	@vibrato System.Int32
	@elasticity System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOPunchRotation(target,punch,duration,vibrato,elasticity) end
--[[
	@target UnityEngine.Transform
	@punch UnityEngine.Vector3
	@duration System.Single
	@vibrato System.Int32
	@elasticity System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOPunchScale(target,punch,duration,vibrato,elasticity) end
--[[
	@target UnityEngine.Transform
	@punch UnityEngine.Vector3
	@duration System.Single
	@vibrato System.Int32
	@elasticity System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOPunchPosition(target,punch,duration,vibrato,elasticity,snapping) end
--[[
	@target UnityEngine.Transform
	@towards UnityEngine.Vector3
	@duration System.Single
	@axisConstraint DG.Tweening.AxisConstraint
	@up System.Nullable`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLookAt(target,towards,duration,axisConstraint,up) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOScaleZ(target,endValue,duration) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOScaleY(target,endValue,duration) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOScaleX(target,endValue,duration) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOScale(target,endValue,duration) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Quaternion
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLocalRotateQuaternion(target,endValue,duration) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Vector3
	@duration System.Single
	@mode DG.Tweening.RotateMode
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLocalRotate(target,endValue,duration,mode) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Quaternion
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DORotateQuaternion(target,endValue,duration) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Vector3
	@duration System.Single
	@mode DG.Tweening.RotateMode
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DORotate(target,endValue,duration,mode) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLocalMoveZ(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLocalMoveY(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLocalMoveX(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Vector3
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOLocalMove(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOMoveZ(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOMoveY(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOMoveX(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Transform
	@endValue UnityEngine.Vector3
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOMove(target,endValue,duration,snapping) end
--[[
	@transform UnityEngine.Transform
	@target UnityEngine.Vector3
	@height System.Int32
	@duration System.Single
	@direction System.Byte
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOMoveLocalBezier(transform,target,height,duration,direction) end
--[[
	@transform UnityEngine.Transform
	@target UnityEngine.Vector3
	@height System.Int32
	@duration System.Single
	@direction System.Byte
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Transform:DOMoveBezier(transform,target,height,duration,direction) end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.Light = {}
--[[
	UnityEngine.LightType
	 Get 	 Set 
--]]
UnityEngine.Light.type = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.spotAngle = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Light.color = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.colorTemperature = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.intensity = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.bounceIntensity = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Light.shadowCustomResolution = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.shadowBias = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.shadowNormalBias = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.shadowNearPlane = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.range = nil
--[[
	UnityEngine.Flare
	 Get 	 Set 
--]]
UnityEngine.Light.flare = nil
--[[
	UnityEngine.LightBakingOutput
	 Get 	 Set 
--]]
UnityEngine.Light.bakingOutput = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Light.cullingMask = nil
--[[
	UnityEngine.LightShadowCasterMode
	 Get 	 Set 
--]]
UnityEngine.Light.lightShadowCasterMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.shadowRadius = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.shadowAngle = nil
--[[
	UnityEngine.LightShadows
	 Get 	 Set 
--]]
UnityEngine.Light.shadows = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.shadowStrength = nil
--[[
	UnityEngine.Rendering.LightShadowResolution
	 Get 	 Set 
--]]
UnityEngine.Light.shadowResolution = nil
--[[
	System.Single{}
	 Get 	 Set 
--]]
UnityEngine.Light.layerShadowCullDistances = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Light.cookieSize = nil
--[[
	@RefType [luaIde#UnityEngine.Texture]
	 Get 	 Set 
--]]
UnityEngine.Light.cookie = nil
--[[
	UnityEngine.LightRenderMode
	 Get 	 Set 
--]]
UnityEngine.Light.renderMode = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Light.commandBufferCount = nil
--[[
	@return [luaIde#UnityEngine.Light]
]]
function UnityEngine.Light:New() end
function UnityEngine.Light:Reset() end
function UnityEngine.Light:SetLightDirty() end
--[[
	@evt UnityEngine.Rendering.LightEvent
	@buffer UnityEngine.Rendering.CommandBuffer
--]]
function UnityEngine.Light:AddCommandBuffer(evt,buffer) end
--[[
	@evt UnityEngine.Rendering.LightEvent
	@buffer UnityEngine.Rendering.CommandBuffer
	@queueType UnityEngine.Rendering.ComputeQueueType
--]]
function UnityEngine.Light:AddCommandBufferAsync(evt,buffer,queueType) end
--[[
	@evt UnityEngine.Rendering.LightEvent
	@buffer UnityEngine.Rendering.CommandBuffer
--]]
function UnityEngine.Light:RemoveCommandBuffer(evt,buffer) end
--[[
	@evt UnityEngine.Rendering.LightEvent
--]]
function UnityEngine.Light:RemoveCommandBuffers(evt) end
function UnityEngine.Light:RemoveAllCommandBuffers() end
--[[
	@evt UnityEngine.Rendering.LightEvent
	return UnityEngine.Rendering.CommandBuffer{}
--]]
function UnityEngine.Light:GetCommandBuffers(evt) end
--[[
	@type UnityEngine.LightType
	@layer System.Int32
	return UnityEngine.Light{}
--]]
function UnityEngine.Light:GetLights(type,layer) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Light:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Light:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.Light:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Light:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.Light:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.Light:DOComplete(target,withCallbacks) end
--[[
	@target UnityEngine.Light
	@endValue UnityEngine.Color
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Light:DOBlendableColor(target,endValue,duration) end
--[[
	@target UnityEngine.Light
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Light:DOShadowStrength(target,endValue,duration) end
--[[
	@target UnityEngine.Light
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Light:DOIntensity(target,endValue,duration) end
--[[
	@target UnityEngine.Light
	@endValue UnityEngine.Color
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Light:DOColor(target,endValue,duration) end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.Material = {}
--[[
	@RefType [luaIde#UnityEngine.Shader]
	 Get 	 Set 
--]]
UnityEngine.Material.shader = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Material.color = nil
--[[
	@RefType [luaIde#UnityEngine.Texture]
	 Get 	 Set 
--]]
UnityEngine.Material.mainTexture = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Material.mainTextureOffset = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Material.mainTextureScale = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Material.renderQueue = nil
--[[
	UnityEngine.MaterialGlobalIlluminationFlags
	 Get 	 Set 
--]]
UnityEngine.Material.globalIlluminationFlags = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Material.doubleSidedGI = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Material.enableInstancing = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Material.passCount = nil
--[[
	System.String{}
	 Get 	 Set 
--]]
UnityEngine.Material.shaderKeywords = nil
--[[
	@source UnityEngine.Material
	@return [luaIde#UnityEngine.Material]
]]
function UnityEngine.Material:New(source) end
--[[
	@shader UnityEngine.Shader
	@return [luaIde#UnityEngine.Material]
]]
function UnityEngine.Material:New(shader) end
--[[
	@nameID System.Int32
	return System.Boolean
--]]
function UnityEngine.Material:HasProperty(nameID) end
--[[
	@keyword System.String
--]]
function UnityEngine.Material:EnableKeyword(keyword) end
--[[
	@keyword System.String
--]]
function UnityEngine.Material:DisableKeyword(keyword) end
--[[
	@keyword System.String
	return System.Boolean
--]]
function UnityEngine.Material:IsKeywordEnabled(keyword) end
--[[
	@passName System.String
	@enabled System.Boolean
--]]
function UnityEngine.Material:SetShaderPassEnabled(passName,enabled) end
--[[
	@passName System.String
	return System.Boolean
--]]
function UnityEngine.Material:GetShaderPassEnabled(passName) end
--[[
	@pass System.Int32
	return System.String
--]]
function UnityEngine.Material:GetPassName(pass) end
--[[
	@passName System.String
	return System.Int32
--]]
function UnityEngine.Material:FindPass(passName) end
--[[
	@tag System.String
	@val System.String
--]]
function UnityEngine.Material:SetOverrideTag(tag,val) end
--[[
	@tag System.String
	@searchFallbacks System.Boolean
	@defaultValue System.String
	return System.String
--]]
function UnityEngine.Material:GetTag(tag,searchFallbacks,defaultValue) end
--[[
	@start UnityEngine.Material
	@end_ UnityEngine.Material
	@t System.Single
--]]
function UnityEngine.Material:Lerp(start,end_,t) end
--[[
	@pass System.Int32
	return System.Boolean
--]]
function UnityEngine.Material:SetPass(pass) end
--[[
	@mat UnityEngine.Material
--]]
function UnityEngine.Material:CopyPropertiesFromMaterial(mat) end
function UnityEngine.Material:GetTexturePropertyNames() end
function UnityEngine.Material:GetTexturePropertyNameIDs() end
--[[
	@name System.String
	@value System.Single
--]]
function UnityEngine.Material:SetFloat(name,value) end
--[[
	@name System.String
	@value System.Int32
--]]
function UnityEngine.Material:SetInt(name,value) end
--[[
	@name System.String
	@value UnityEngine.Color
--]]
function UnityEngine.Material:SetColor(name,value) end
--[[
	@name System.String
	@value UnityEngine.Vector4
--]]
function UnityEngine.Material:SetVector(name,value) end
--[[
	@name System.String
	@value UnityEngine.Matrix4x4
--]]
function UnityEngine.Material:SetMatrix(name,value) end
--[[
	@name System.String
	@value UnityEngine.Texture
--]]
function UnityEngine.Material:SetTexture(name,value) end
--[[
	@name System.String
	@value UnityEngine.ComputeBuffer
--]]
function UnityEngine.Material:SetBuffer(name,value) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEngine.Material:SetFloatArray(name,values) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Material:SetColorArray(name,values) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{UnityEngine.Vector4, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Material:SetVectorArray(name,values) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{UnityEngine.Matrix4x4, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Material:SetMatrixArray(name,values) end
--[[
	@name System.String
	return System.Single
--]]
function UnityEngine.Material:GetFloat(name) end
--[[
	@name System.String
	return System.Int32
--]]
function UnityEngine.Material:GetInt(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Material:GetColor(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Material:GetVector(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Material:GetMatrix(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Texture]
--]]
function UnityEngine.Material:GetTexture(name) end
--[[
	@name System.String
	return System.Single{}
--]]
function UnityEngine.Material:GetFloatArray(name) end
--[[
	@name System.String
	return UnityEngine.Color{}
--]]
function UnityEngine.Material:GetColorArray(name) end
--[[
	@name System.String
	return UnityEngine.Vector4{}
--]]
function UnityEngine.Material:GetVectorArray(name) end
--[[
	@name System.String
	return UnityEngine.Matrix4x4{}
--]]
function UnityEngine.Material:GetMatrixArray(name) end
--[[
	@name System.String
	@value UnityEngine.Vector2
--]]
function UnityEngine.Material:SetTextureOffset(name,value) end
--[[
	@name System.String
	@value UnityEngine.Vector2
--]]
function UnityEngine.Material:SetTextureScale(name,value) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Material:GetTextureOffset(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Material:GetTextureScale(name) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOTogglePause(target) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Material
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Material:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Material
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Material:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOPlayForward(target) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOPlay(target) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOPause(target) end
--[[
	@target UnityEngine.Material
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.Material:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Material
	return System.Int32
--]]
function UnityEngine.Material:DOFlip(target) end
--[[
	@target UnityEngine.Material
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.Material:DOKill(target,complete) end
--[[
	@target UnityEngine.Material
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.Material:DOComplete(target,withCallbacks) end
--[[
	@target UnityEngine.Material
	@endValue UnityEngine.Color
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOBlendableColor(target,endValue,property,duration) end
--[[
	@target UnityEngine.Material
	@endValue UnityEngine.Vector4
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOVector(target,endValue,property,duration) end
--[[
	@target UnityEngine.Material
	@endValue UnityEngine.Vector2
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOTiling(target,endValue,property,duration) end
--[[
	@target UnityEngine.Material
	@endValue UnityEngine.Vector2
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOOffset(target,endValue,property,duration) end
--[[
	@target UnityEngine.Material
	@endValue System.Single
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOFloat(target,endValue,property,duration) end
--[[
	@target UnityEngine.Material
	@endValue System.Single
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOFade(target,endValue,property,duration) end
--[[
	@target UnityEngine.Material
	@endValue UnityEngine.Color
	@property System.String
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Material:DOColor(target,endValue,property,duration) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.Rigidbody = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.velocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.angularVelocity = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.drag = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.angularDrag = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.mass = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.useGravity = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.maxDepenetrationVelocity = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.isKinematic = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.freezeRotation = nil
--[[
	UnityEngine.RigidbodyConstraints
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.constraints = nil
--[[
	UnityEngine.CollisionDetectionMode
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.collisionDetectionMode = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.centerOfMass = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Rigidbody.worldCenterOfMass = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.inertiaTensorRotation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.inertiaTensor = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.detectCollisions = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.position = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.rotation = nil
--[[
	UnityEngine.RigidbodyInterpolation
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.interpolation = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.solverIterations = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.sleepThreshold = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.maxAngularVelocity = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Rigidbody.solverVelocityIterations = nil
--[[
	@return [luaIde#UnityEngine.Rigidbody]
]]
function UnityEngine.Rigidbody:New() end
--[[
	@density System.Single
--]]
function UnityEngine.Rigidbody:SetDensity(density) end
--[[
	@position UnityEngine.Vector3
--]]
function UnityEngine.Rigidbody:MovePosition(position) end
--[[
	@rot UnityEngine.Quaternion
--]]
function UnityEngine.Rigidbody:MoveRotation(rot) end
function UnityEngine.Rigidbody:Sleep() end
function UnityEngine.Rigidbody:IsSleeping() end
function UnityEngine.Rigidbody:WakeUp() end
function UnityEngine.Rigidbody:ResetCenterOfMass() end
function UnityEngine.Rigidbody:ResetInertiaTensor() end
--[[
	@relativePoint UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Rigidbody:GetRelativePointVelocity(relativePoint) end
--[[
	@worldPoint UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Rigidbody:GetPointVelocity(worldPoint) end
--[[
	@force UnityEngine.Vector3
	@mode UnityEngine.ForceMode
--]]
function UnityEngine.Rigidbody:AddForce(force,mode) end
--[[
	@force UnityEngine.Vector3
	@mode UnityEngine.ForceMode
--]]
function UnityEngine.Rigidbody:AddRelativeForce(force,mode) end
--[[
	@torque UnityEngine.Vector3
	@mode UnityEngine.ForceMode
--]]
function UnityEngine.Rigidbody:AddTorque(torque,mode) end
--[[
	@torque UnityEngine.Vector3
	@mode UnityEngine.ForceMode
--]]
function UnityEngine.Rigidbody:AddRelativeTorque(torque,mode) end
--[[
	@force UnityEngine.Vector3
	@position UnityEngine.Vector3
	@mode UnityEngine.ForceMode
--]]
function UnityEngine.Rigidbody:AddForceAtPosition(force,position,mode) end
--[[
	@explosionForce System.Single
	@explosionPosition UnityEngine.Vector3
	@explosionRadius System.Single
	@upwardsModifier System.Single
	@mode UnityEngine.ForceMode
--]]
function UnityEngine.Rigidbody:AddExplosionForce(explosionForce,explosionPosition,explosionRadius,upwardsModifier,mode) end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Rigidbody:ClosestPointOnBounds(position) end
--[[
	@direction UnityEngine.Vector3
	@hitInfo UnityEngine.RaycastHit&
	@maxDistance System.Single
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function UnityEngine.Rigidbody:SweepTest(direction,hitInfo,maxDistance,queryTriggerInteraction) end
--[[
	@direction UnityEngine.Vector3
	@maxDistance System.Single
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.RaycastHit{}
--]]
function UnityEngine.Rigidbody:SweepTestAll(direction,maxDistance,queryTriggerInteraction) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Rigidbody:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Rigidbody:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.Rigidbody:DOComplete(target,withCallbacks) end
--[[
	@target UnityEngine.Rigidbody
	@path UnityEngine.Vector3{}
	@duration System.Single
	@pathType DG.Tweening.PathType
	@pathMode DG.Tweening.PathMode
	@resolution System.Int32
	@gizmoColor System.Nullable`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Core.PathCore.Path, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.PathOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Rigidbody:DOLocalPath(target,path,duration,pathType,pathMode,resolution,gizmoColor) end
--[[
	@target UnityEngine.Rigidbody
	@path UnityEngine.Vector3{}
	@duration System.Single
	@pathType DG.Tweening.PathType
	@pathMode DG.Tweening.PathMode
	@resolution System.Int32
	@gizmoColor System.Nullable`1{{UnityEngine.Color, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return DG.Tweening.Core.TweenerCore`3{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Core.PathCore.Path, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null},{DG.Tweening.Plugins.Options.PathOptions, DOTween, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Rigidbody:DOPath(target,path,duration,pathType,pathMode,resolution,gizmoColor) end
--[[
	@target UnityEngine.Rigidbody
	@endValue UnityEngine.Vector3
	@jumpPower System.Single
	@numJumps System.Int32
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Sequence]
--]]
function UnityEngine.Rigidbody:DOJump(target,endValue,jumpPower,numJumps,duration,snapping) end
--[[
	@target UnityEngine.Rigidbody
	@towards UnityEngine.Vector3
	@duration System.Single
	@axisConstraint DG.Tweening.AxisConstraint
	@up System.Nullable`1{{UnityEngine.Vector3, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Rigidbody:DOLookAt(target,towards,duration,axisConstraint,up) end
--[[
	@target UnityEngine.Rigidbody
	@endValue UnityEngine.Vector3
	@duration System.Single
	@mode DG.Tweening.RotateMode
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Rigidbody:DORotate(target,endValue,duration,mode) end
--[[
	@target UnityEngine.Rigidbody
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Rigidbody:DOMoveZ(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Rigidbody
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Rigidbody:DOMoveY(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Rigidbody
	@endValue System.Single
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Rigidbody:DOMoveX(target,endValue,duration,snapping) end
--[[
	@target UnityEngine.Rigidbody
	@endValue UnityEngine.Vector3
	@duration System.Single
	@snapping System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Rigidbody:DOMove(target,endValue,duration,snapping) end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.Camera = {}
--[[
	UnityEngine.Camera.CameraCallback
	 Get 	 Set 
--]]
UnityEngine.Camera.onPreCull = nil
--[[
	UnityEngine.Camera.CameraCallback
	 Get 	 Set 
--]]
UnityEngine.Camera.onPreRender = nil
--[[
	UnityEngine.Camera.CameraCallback
	 Get 	 Set 
--]]
UnityEngine.Camera.onPostRender = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.nearClipPlane = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.farClipPlane = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.fieldOfView = nil
--[[
	UnityEngine.RenderingPath
	 Get 	 Set 
--]]
UnityEngine.Camera.renderingPath = nil
--[[
	UnityEngine.RenderingPath
	 Get 
--]]
UnityEngine.Camera.actualRenderingPath = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.allowHDR = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.allowMSAA = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.allowDynamicResolution = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.forceIntoRenderTexture = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.orthographicSize = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.orthographic = nil
--[[
	UnityEngine.Rendering.OpaqueSortMode
	 Get 	 Set 
--]]
UnityEngine.Camera.opaqueSortMode = nil
--[[
	UnityEngine.TransparencySortMode
	 Get 	 Set 
--]]
UnityEngine.Camera.transparencySortMode = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Camera.transparencySortAxis = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.depth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.aspect = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Camera.velocity = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Camera.cullingMask = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Camera.eventMask = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.layerCullSpherical = nil
--[[
	UnityEngine.CameraType
	 Get 	 Set 
--]]
UnityEngine.Camera.cameraType = nil
--[[
	System.Single{}
	 Get 	 Set 
--]]
UnityEngine.Camera.layerCullDistances = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.useOcclusionCulling = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 	 Set 
--]]
UnityEngine.Camera.cullingMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Camera.backgroundColor = nil
--[[
	UnityEngine.CameraClearFlags
	 Get 	 Set 
--]]
UnityEngine.Camera.clearFlags = nil
--[[
	UnityEngine.DepthTextureMode
	 Get 	 Set 
--]]
UnityEngine.Camera.depthTextureMode = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.clearStencilAfterLightingPass = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.usePhysicalProperties = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Camera.sensorSize = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Camera.lensShift = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.focalLength = nil
--[[
	UnityEngine.Camera.GateFitMode
	 Get 	 Set 
--]]
UnityEngine.Camera.gateFit = nil
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 	 Set 
--]]
UnityEngine.Camera.rect = nil
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 	 Set 
--]]
UnityEngine.Camera.pixelRect = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Camera.pixelWidth = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Camera.pixelHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Camera.scaledPixelWidth = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Camera.scaledPixelHeight = nil
--[[
	@RefType [luaIde#UnityEngine.RenderTexture]
	 Get 	 Set 
--]]
UnityEngine.Camera.targetTexture = nil
--[[
	@RefType [luaIde#UnityEngine.RenderTexture]
	 Get 
--]]
UnityEngine.Camera.activeTexture = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Camera.targetDisplay = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Camera.cameraToWorldMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 	 Set 
--]]
UnityEngine.Camera.worldToCameraMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 	 Set 
--]]
UnityEngine.Camera.projectionMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 	 Set 
--]]
UnityEngine.Camera.nonJitteredProjectionMatrix = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Camera.useJitteredProjectionMatrixForTransparentRendering = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Camera.previousViewProjectionMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Camera]
	 Get 
--]]
UnityEngine.Camera.main = nil
--[[
	@RefType [luaIde#UnityEngine.Camera]
	 Get 
--]]
UnityEngine.Camera.current = nil
--[[
	UnityEngine.SceneManagement.Scene
	 Get 	 Set 
--]]
UnityEngine.Camera.scene = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Camera.stereoEnabled = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.stereoSeparation = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Camera.stereoConvergence = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Camera.areVRStereoViewMatricesWithinSingleCullTolerance = nil
--[[
	UnityEngine.StereoTargetEyeMask
	 Get 	 Set 
--]]
UnityEngine.Camera.stereoTargetEye = nil
--[[
	UnityEngine.Camera.MonoOrStereoscopicEye
	 Get 
--]]
UnityEngine.Camera.stereoActiveEye = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Camera.allCamerasCount = nil
--[[
	UnityEngine.Camera{}
	 Get 
--]]
UnityEngine.Camera.allCameras = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Camera.commandBufferCount = nil
--[[
	@return [luaIde#UnityEngine.Camera]
]]
function UnityEngine.Camera:New() end
function UnityEngine.Camera:Reset() end
function UnityEngine.Camera:ResetTransparencySortSettings() end
function UnityEngine.Camera:ResetAspect() end
function UnityEngine.Camera:ResetCullingMatrix() end
--[[
	@shader UnityEngine.Shader
	@replacementTag System.String
--]]
function UnityEngine.Camera:SetReplacementShader(shader,replacementTag) end
function UnityEngine.Camera:ResetReplacementShader() end
--[[
	@colorBuffer UnityEngine.RenderBuffer
	@depthBuffer UnityEngine.RenderBuffer
--]]
function UnityEngine.Camera:SetTargetBuffers(colorBuffer,depthBuffer) end
function UnityEngine.Camera:ResetWorldToCameraMatrix() end
function UnityEngine.Camera:ResetProjectionMatrix() end
--[[
	@clipPlane UnityEngine.Vector4
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Camera:CalculateObliqueMatrix(clipPlane) end
--[[
	@position UnityEngine.Vector3
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Camera:WorldToScreenPoint(position,eye) end
--[[
	@position UnityEngine.Vector3
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Camera:WorldToViewportPoint(position,eye) end
--[[
	@position UnityEngine.Vector3
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Camera:ViewportToWorldPoint(position,eye) end
--[[
	@position UnityEngine.Vector3
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Camera:ScreenToWorldPoint(position,eye) end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Camera:ScreenToViewportPoint(position) end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Camera:ViewportToScreenPoint(position) end
--[[
	@pos UnityEngine.Vector3
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@return [luaIde#UnityEngine.Ray]
--]]
function UnityEngine.Camera:ViewportPointToRay(pos,eye) end
--[[
	@pos UnityEngine.Vector3
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@return [luaIde#UnityEngine.Ray]
--]]
function UnityEngine.Camera:ScreenPointToRay(pos,eye) end
--[[
	@viewport UnityEngine.Rect
	@z System.Single
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
	@outCorners UnityEngine.Vector3{}
--]]
function UnityEngine.Camera:CalculateFrustumCorners(viewport,z,eye,outCorners) end
--[[
	@output UnityEngine.Matrix4x4&
	@focalLength System.Single
	@sensorSize UnityEngine.Vector2
	@lensShift UnityEngine.Vector2
	@nearClip System.Single
	@farClip System.Single
	@gateFitParameters UnityEngine.Camera.GateFitParameters
--]]
function UnityEngine.Camera:CalculateProjectionMatrixFromPhysicalProperties(output,focalLength,sensorSize,lensShift,nearClip,farClip,gateFitParameters) end
--[[
	@focalLength System.Single
	@sensorSize System.Single
	return System.Single
--]]
function UnityEngine.Camera:FocalLengthToFOV(focalLength,sensorSize) end
--[[
	@fov System.Single
	@sensorSize System.Single
	return System.Single
--]]
function UnityEngine.Camera:FOVToFocalLength(fov,sensorSize) end
--[[
	@eye UnityEngine.Camera.StereoscopicEye
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Camera:GetStereoNonJitteredProjectionMatrix(eye) end
--[[
	@eye UnityEngine.Camera.StereoscopicEye
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Camera:GetStereoViewMatrix(eye) end
--[[
	@eye UnityEngine.Camera.StereoscopicEye
--]]
function UnityEngine.Camera:CopyStereoDeviceProjectionMatrixToNonJittered(eye) end
--[[
	@eye UnityEngine.Camera.StereoscopicEye
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Camera:GetStereoProjectionMatrix(eye) end
--[[
	@eye UnityEngine.Camera.StereoscopicEye
	@matrix UnityEngine.Matrix4x4
--]]
function UnityEngine.Camera:SetStereoProjectionMatrix(eye,matrix) end
function UnityEngine.Camera:ResetStereoProjectionMatrices() end
--[[
	@eye UnityEngine.Camera.StereoscopicEye
	@matrix UnityEngine.Matrix4x4
--]]
function UnityEngine.Camera:SetStereoViewMatrix(eye,matrix) end
function UnityEngine.Camera:ResetStereoViewMatrices() end
--[[
	@cameras UnityEngine.Camera{}
	return System.Int32
--]]
function UnityEngine.Camera:GetAllCameras(cameras) end
--[[
	@cubemap UnityEngine.Cubemap
	@faceMask System.Int32
	return System.Boolean
--]]
function UnityEngine.Camera:RenderToCubemap(cubemap,faceMask) end
function UnityEngine.Camera:Render() end
--[[
	@shader UnityEngine.Shader
	@replacementTag System.String
--]]
function UnityEngine.Camera:RenderWithShader(shader,replacementTag) end
function UnityEngine.Camera:RenderDontRestore() end
--[[
	@cur UnityEngine.Camera
--]]
function UnityEngine.Camera:SetupCurrent(cur) end
--[[
	@other UnityEngine.Camera
--]]
function UnityEngine.Camera:CopyFrom(other) end
--[[
	@evt UnityEngine.Rendering.CameraEvent
--]]
function UnityEngine.Camera:RemoveCommandBuffers(evt) end
function UnityEngine.Camera:RemoveAllCommandBuffers() end
--[[
	@evt UnityEngine.Rendering.CameraEvent
	@buffer UnityEngine.Rendering.CommandBuffer
--]]
function UnityEngine.Camera:AddCommandBuffer(evt,buffer) end
--[[
	@evt UnityEngine.Rendering.CameraEvent
	@buffer UnityEngine.Rendering.CommandBuffer
	@queueType UnityEngine.Rendering.ComputeQueueType
--]]
function UnityEngine.Camera:AddCommandBufferAsync(evt,buffer,queueType) end
--[[
	@evt UnityEngine.Rendering.CameraEvent
	@buffer UnityEngine.Rendering.CommandBuffer
--]]
function UnityEngine.Camera:RemoveCommandBuffer(evt,buffer) end
--[[
	@evt UnityEngine.Rendering.CameraEvent
	return UnityEngine.Rendering.CommandBuffer{}
--]]
function UnityEngine.Camera:GetCommandBuffers(evt) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Camera:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.Camera:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.Camera:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.Camera:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.Camera:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.Camera:DOComplete(target,withCallbacks) end
--[[
	@target UnityEngine.Camera
	@duration System.Single
	@strength UnityEngine.Vector3
	@vibrato System.Int32
	@randomness System.Single
	@fadeOut System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOShakeRotation(target,duration,strength,vibrato,randomness,fadeOut) end
--[[
	@target UnityEngine.Camera
	@duration System.Single
	@strength UnityEngine.Vector3
	@vibrato System.Int32
	@randomness System.Single
	@fadeOut System.Boolean
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOShakePosition(target,duration,strength,vibrato,randomness,fadeOut) end
--[[
	@target UnityEngine.Camera
	@endValue UnityEngine.Rect
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DORect(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue UnityEngine.Rect
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOPixelRect(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOOrthoSize(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DONearClipPlane(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOFieldOfView(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOFarClipPlane(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue UnityEngine.Color
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOColor(target,endValue,duration) end
--[[
	@target UnityEngine.Camera
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.Camera:DOAspect(target,endValue,duration) end

--@SuperType [luaIde#UnityEngine.AudioBehaviour]
UnityEngine.AudioSource = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.volume = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.pitch = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.time = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.AudioSource.timeSamples = nil
--[[
	@RefType [luaIde#UnityEngine.AudioClip]
	 Get 	 Set 
--]]
UnityEngine.AudioSource.clip = nil
--[[
	UnityEngine.Audio.AudioMixerGroup
	 Get 	 Set 
--]]
UnityEngine.AudioSource.outputAudioMixerGroup = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AudioSource.isPlaying = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AudioSource.isVirtual = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.loop = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.ignoreListenerVolume = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.playOnAwake = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.ignoreListenerPause = nil
--[[
	UnityEngine.AudioVelocityUpdateMode
	 Get 	 Set 
--]]
UnityEngine.AudioSource.velocityUpdateMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.panStereo = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.spatialBlend = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.spatialize = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.spatializePostEffects = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.reverbZoneMix = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.bypassEffects = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.bypassListenerEffects = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.bypassReverbZones = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.dopplerLevel = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.spread = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.AudioSource.priority = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AudioSource.mute = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.minDistance = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AudioSource.maxDistance = nil
--[[
	UnityEngine.AudioRolloffMode
	 Get 	 Set 
--]]
UnityEngine.AudioSource.rolloffMode = nil
--[[
	@return [luaIde#UnityEngine.AudioSource]
]]
function UnityEngine.AudioSource:New() end
--[[
	@delay System.UInt64
--]]
function UnityEngine.AudioSource:Play(delay) end
--[[
	@delay System.Single
--]]
function UnityEngine.AudioSource:PlayDelayed(delay) end
--[[
	@time System.Double
--]]
function UnityEngine.AudioSource:PlayScheduled(time) end
--[[
	@time System.Double
--]]
function UnityEngine.AudioSource:SetScheduledStartTime(time) end
--[[
	@time System.Double
--]]
function UnityEngine.AudioSource:SetScheduledEndTime(time) end
function UnityEngine.AudioSource:Stop() end
function UnityEngine.AudioSource:Pause() end
function UnityEngine.AudioSource:UnPause() end
--[[
	@clip UnityEngine.AudioClip
--]]
function UnityEngine.AudioSource:PlayOneShot(clip) end
--[[
	@clip UnityEngine.AudioClip
	@position UnityEngine.Vector3
--]]
function UnityEngine.AudioSource:PlayClipAtPoint(clip,position) end
--[[
	@type UnityEngine.AudioSourceCurveType
	@curve UnityEngine.AnimationCurve
--]]
function UnityEngine.AudioSource:SetCustomCurve(type,curve) end
--[[
	@type UnityEngine.AudioSourceCurveType
	return UnityEngine.AnimationCurve
--]]
function UnityEngine.AudioSource:GetCustomCurve(type) end
--[[
	@samples System.Single{}
	@channel System.Int32
--]]
function UnityEngine.AudioSource:GetOutputData(samples,channel) end
--[[
	@samples System.Single{}
	@channel System.Int32
	@window UnityEngine.FFTWindow
--]]
function UnityEngine.AudioSource:GetSpectrumData(samples,channel,window) end
--[[
	@index System.Int32
	@value System.Single
	return System.Boolean
--]]
function UnityEngine.AudioSource:SetSpatializerFloat(index,value) end
--[[
	@index System.Int32
	@value System.Single&
	return System.Boolean
--]]
function UnityEngine.AudioSource:GetSpatializerFloat(index,value) end
--[[
	@index System.Int32
	@value System.Single
	return System.Boolean
--]]
function UnityEngine.AudioSource:SetAmbisonicDecoderFloat(index,value) end
--[[
	@index System.Int32
	@value System.Single&
	return System.Boolean
--]]
function UnityEngine.AudioSource:GetAmbisonicDecoderFloat(index,value) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.AudioSource:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.AudioSource:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.AudioSource:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.AudioSource:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.AudioSource:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.AudioSource:DOComplete(target,withCallbacks) end
--[[
	@target UnityEngine.AudioSource
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.AudioSource:DOPitch(target,endValue,duration) end
--[[
	@target UnityEngine.AudioSource
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.AudioSource:DOFade(target,endValue,duration) end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.CanvasGroup = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CanvasGroup.alpha = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.CanvasGroup.interactable = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.CanvasGroup.blocksRaycasts = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.CanvasGroup.ignoreParentGroups = nil
--[[
	@return [luaIde#UnityEngine.CanvasGroup]
]]
function UnityEngine.CanvasGroup:New() end
--[[
	@sp UnityEngine.Vector2
	@eventCamera UnityEngine.Camera
	return System.Boolean
--]]
function UnityEngine.CanvasGroup:IsRaycastLocationValid(sp,eventCamera) end
--[[
	@target UnityEngine.CanvasGroup
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.CanvasGroup:DOFade(target,endValue,duration) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.CanvasGroup:DOComplete(target,withCallbacks) end

--@SuperType [luaIde#UnityEngine.UI.MaskableGraphic]
UnityEngine.UI.Image = {}
--[[
	@RefType [luaIde#UnityEngine.Sprite]
	 Get 	 Set 
--]]
UnityEngine.UI.Image.sprite = nil
--[[
	@RefType [luaIde#UnityEngine.Sprite]
	 Get 	 Set 
--]]
UnityEngine.UI.Image.overrideSprite = nil
--[[
	UnityEngine.UI.Image.Type
	 Get 	 Set 
--]]
UnityEngine.UI.Image.type = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Image.preserveAspect = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Image.fillCenter = nil
--[[
	UnityEngine.UI.Image.FillMethod
	 Get 	 Set 
--]]
UnityEngine.UI.Image.fillMethod = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Image.fillAmount = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Image.fillClockwise = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.Image.fillOrigin = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Image.alphaHitTestMinimumThreshold = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Image.useSpriteMesh = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 
--]]
UnityEngine.UI.Image.defaultETC1GraphicMaterial = nil
--[[
	@RefType [luaIde#UnityEngine.Texture]
	 Get 
--]]
UnityEngine.UI.Image.mainTexture = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.UI.Image.hasBorder = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.pixelsPerUnit = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 	 Set 
--]]
UnityEngine.UI.Image.material = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.minWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.flexibleWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.minHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.preferredHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Image.flexibleHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.Image.layoutPriority = nil
function UnityEngine.UI.Image:OnBeforeSerialize() end
function UnityEngine.UI.Image:OnAfterDeserialize() end
function UnityEngine.UI.Image:SetNativeSize() end
function UnityEngine.UI.Image:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.Image:CalculateLayoutInputVertical() end
--[[
	@screenPoint UnityEngine.Vector2
	@eventCamera UnityEngine.Camera
	return System.Boolean
--]]
function UnityEngine.UI.Image:IsRaycastLocationValid(screenPoint,eventCamera) end
--[[
	@target UnityEngine.UI.Image
	@endValue UnityEngine.Color
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.UI.Image:DOBlendableColor(target,endValue,duration) end
--[[
	@target UnityEngine.UI.Image
	@gradient UnityEngine.Gradient
	@duration System.Single
	@return [luaIde#DG.Tweening.Sequence]
--]]
function UnityEngine.UI.Image:DOGradientColor(target,gradient,duration) end
--[[
	@target UnityEngine.UI.Image
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.UI.Image:DOFillAmount(target,endValue,duration) end
--[[
	@target UnityEngine.UI.Image
	@endValue System.Single
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.UI.Image:DOFade(target,endValue,duration) end
--[[
	@target UnityEngine.UI.Image
	@endValue UnityEngine.Color
	@duration System.Single
	@return [luaIde#DG.Tweening.Tweener]
--]]
function UnityEngine.UI.Image:DOColor(target,endValue,duration) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Image:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Image:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Image:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Image:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Image:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Image:DOComplete(target,withCallbacks) end

--@SuperType [luaIde#UnityEngine.UI.Selectable]
UnityEngine.UI.Button = {}
--[[
	UnityEngine.UI.Button.ButtonClickedEvent
	 Get 	 Set 
--]]
UnityEngine.UI.Button.onClick = nil
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Button:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.Button:OnSubmit(eventData) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOTogglePause(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOSmoothRewind(target) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Button:DORewind(target,includeDelay) end
--[[
	@target UnityEngine.Component
	@includeDelay System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Button:DORestart(target,includeDelay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOPlayForward(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOPlayBackwards(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOPlay(target) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOPause(target) end
--[[
	@target UnityEngine.Component
	@to System.Single
	@andPlay System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Button:DOGoto(target,to,andPlay) end
--[[
	@target UnityEngine.Component
	return System.Int32
--]]
function UnityEngine.UI.Button:DOFlip(target) end
--[[
	@target UnityEngine.Component
	@complete System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Button:DOKill(target,complete) end
--[[
	@target UnityEngine.Component
	@withCallbacks System.Boolean
	return System.Int32
--]]
function UnityEngine.UI.Button:DOComplete(target,withCallbacks) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.Behaviour = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Behaviour.enabled = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Behaviour.isActiveAndEnabled = nil
--[[
	@return [luaIde#UnityEngine.Behaviour]
]]
function UnityEngine.Behaviour:New() end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.MonoBehaviour = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.MonoBehaviour.useGUILayout = nil
function UnityEngine.MonoBehaviour:IsInvoking() end
function UnityEngine.MonoBehaviour:CancelInvoke() end
--[[
	@methodName System.String
	@time System.Single
--]]
function UnityEngine.MonoBehaviour:Invoke(methodName,time) end
--[[
	@methodName System.String
	@time System.Single
	@repeatRate System.Single
--]]
function UnityEngine.MonoBehaviour:InvokeRepeating(methodName,time,repeatRate) end
--[[
	@methodName System.String
	return UnityEngine.Coroutine
--]]
function UnityEngine.MonoBehaviour:StartCoroutine(methodName) end
--[[
	@routine System.Collections.IEnumerator
--]]
function UnityEngine.MonoBehaviour:StopCoroutine(routine) end
function UnityEngine.MonoBehaviour:StopAllCoroutines() end
--[[
	@message System.Object
--]]
function UnityEngine.MonoBehaviour:print(message) end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.GameObject = {}
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 
--]]
UnityEngine.GameObject.transform = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.GameObject.layer = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.GameObject.activeSelf = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.GameObject.activeInHierarchy = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.GameObject.isStatic = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.GameObject.tag = nil
--[[
	UnityEngine.SceneManagement.Scene
	 Get 
--]]
UnityEngine.GameObject.scene = nil
--[[
	@RefType [luaIde#UnityEngine.GameObject]
	 Get 
--]]
UnityEngine.GameObject.gameObject = nil
--[[
	@return [luaIde#UnityEngine.GameObject]
]]
function UnityEngine.GameObject:New() end
--[[
	@name System.String
	@return [luaIde#UnityEngine.GameObject]
]]
function UnityEngine.GameObject:New(name) end
--[[
	@name System.String
	@components System.Type{}
	@return [luaIde#UnityEngine.GameObject]
]]
function UnityEngine.GameObject:New(name,components) end
--[[
	@type UnityEngine.PrimitiveType
	@return [luaIde#UnityEngine.GameObject]
--]]
function UnityEngine.GameObject:CreatePrimitive(type) end
--[[
	@type System.Type
	@return [luaIde#UnityEngine.Component]
--]]
function UnityEngine.GameObject:GetComponent(type) end
--[[
	@type System.Type
	@includeInactive System.Boolean
	@return [luaIde#UnityEngine.Component]
--]]
function UnityEngine.GameObject:GetComponentInChildren(type,includeInactive) end
--[[
	@type System.Type
	@return [luaIde#UnityEngine.Component]
--]]
function UnityEngine.GameObject:GetComponentInParent(type) end
--[[
	@type System.Type
	return UnityEngine.Component{}
--]]
function UnityEngine.GameObject:GetComponents(type) end
--[[
	@type System.Type
	return UnityEngine.Component{}
--]]
function UnityEngine.GameObject:GetComponentsInChildren(type) end
--[[
	@type System.Type
	return UnityEngine.Component{}
--]]
function UnityEngine.GameObject:GetComponentsInParent(type) end
--[[
	@tag System.String
	@return [luaIde#UnityEngine.GameObject]
--]]
function UnityEngine.GameObject:FindWithTag(tag) end
--[[
	@value System.Boolean
--]]
function UnityEngine.GameObject:SetActive(value) end
--[[
	@tag System.String
	return System.Boolean
--]]
function UnityEngine.GameObject:CompareTag(tag) end
--[[
	@tag System.String
	@return [luaIde#UnityEngine.GameObject]
--]]
function UnityEngine.GameObject:FindGameObjectWithTag(tag) end
--[[
	@tag System.String
	return UnityEngine.GameObject{}
--]]
function UnityEngine.GameObject:FindGameObjectsWithTag(tag) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.GameObject]
--]]
function UnityEngine.GameObject:Find(name) end
--[[
	@t System.Type
--]]
function UnityEngine.GameObject:AddComponent(t) end
--[[
	@methodName System.String
--]]
function UnityEngine.GameObject:BroadcastMessage(methodName) end
--[[
	@methodName System.String
--]]
function UnityEngine.GameObject:SendMessageUpwards(methodName) end
--[[
	@methodName System.String
--]]
function UnityEngine.GameObject:SendMessage(methodName) end
--[[
	@obj UnityEngine.GameObject
	@className System.String
	return System.Object
--]]
function UnityEngine.GameObject:AddComponentEX(obj,className) end

--@SuperType [luaIde#System.Object]
UnityEngine.TrackedReference = {}
--[[
	@o System.Object
	return System.Boolean
--]]
function UnityEngine.TrackedReference:Equals(o) end
function UnityEngine.TrackedReference:GetHashCode() end

Application = {}
--[[
	System.Boolean
	 Get 
--]]
Application.isPlaying = nil
--[[
	System.Boolean
	 Get 
--]]
Application.isFocused = nil
--[[
	UnityEngine.RuntimePlatform
	 Get 
--]]
Application.platform = nil
--[[
	System.String
	 Get 
--]]
Application.buildGUID = nil
--[[
	System.Boolean
	 Get 
--]]
Application.isMobilePlatform = nil
--[[
	System.Boolean
	 Get 
--]]
Application.isConsolePlatform = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Application.runInBackground = nil
--[[
	System.Boolean
	 Get 
--]]
Application.isBatchMode = nil
--[[
	System.String
	 Get 
--]]
Application.dataPath = nil
--[[
	System.String
	 Get 
--]]
Application.streamingAssetsPath = nil
--[[
	System.String
	 Get 
--]]
Application.persistentDataPath = nil
--[[
	System.String
	 Get 
--]]
Application.temporaryCachePath = nil
--[[
	System.String
	 Get 
--]]
Application.absoluteURL = nil
--[[
	System.String
	 Get 
--]]
Application.unityVersion = nil
--[[
	System.String
	 Get 
--]]
Application.version = nil
--[[
	System.String
	 Get 
--]]
Application.installerName = nil
--[[
	System.String
	 Get 
--]]
Application.identifier = nil
--[[
	UnityEngine.ApplicationInstallMode
	 Get 
--]]
Application.installMode = nil
--[[
	UnityEngine.ApplicationSandboxType
	 Get 
--]]
Application.sandboxType = nil
--[[
	System.String
	 Get 
--]]
Application.productName = nil
--[[
	System.String
	 Get 
--]]
Application.companyName = nil
--[[
	System.String
	 Get 
--]]
Application.cloudProjectId = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
Application.targetFrameRate = nil
--[[
	UnityEngine.SystemLanguage
	 Get 
--]]
Application.systemLanguage = nil
--[[
	System.String
	 Get 
--]]
Application.consoleLogPath = nil
--[[
	UnityEngine.ThreadPriority
	 Get 	 Set 
--]]
Application.backgroundLoadingPriority = nil
--[[
	UnityEngine.NetworkReachability
	 Get 
--]]
Application.internetReachability = nil
--[[
	System.Boolean
	 Get 
--]]
Application.genuine = nil
--[[
	System.Boolean
	 Get 
--]]
Application.genuineCheckAvailable = nil
--[[
	System.Boolean
	 Get 
--]]
Application.isEditor = nil
--[[
	UnityEngine.Application.LowMemoryCallback
	 Get 	 Set 
--]]
Application.lowMemory = nil
--[[
	UnityEngine.Application.LogCallback
	 Get 	 Set 
--]]
Application.logMessageReceived = nil
--[[
	UnityEngine.Application.LogCallback
	 Get 	 Set 
--]]
Application.logMessageReceivedThreaded = nil
--[[
	UnityEngine.Events.UnityAction
	 Get 	 Set 
--]]
Application.onBeforeRender = nil
--[[
	System.Action`1{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	 Get 	 Set 
--]]
Application.focusChanged = nil
--[[
	System.Func`1{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	 Get 	 Set 
--]]
Application.wantsToQuit = nil
--[[
	System.Action
	 Get 	 Set 
--]]
Application.quitting = nil
--[[
	@exitCode System.Int32
--]]
function Application:Quit(exitCode) end
function Application:Unload() end
--[[
	@levelIndex System.Int32
	return System.Boolean
--]]
function Application:CanStreamedLevelBeLoaded(levelIndex) end
--[[
	@obj UnityEngine.Object
	return System.Boolean
--]]
function Application:IsPlaying(obj) end
function Application:GetBuildTags() end
--[[
	@buildTags System.String{}
--]]
function Application:SetBuildTags(buildTags) end
function Application:HasProLicense() end
--[[
	@delegateMethod UnityEngine.Application.AdvertisingIdentifierCallback
	return System.Boolean
--]]
function Application:RequestAdvertisingIdentifierAsync(delegateMethod) end
--[[
	@url System.String
--]]
function Application:OpenURL(url) end
--[[
	@logType UnityEngine.LogType
	return UnityEngine.StackTraceLogType
--]]
function Application:GetStackTraceLogType(logType) end
--[[
	@logType UnityEngine.LogType
	@stackTraceType UnityEngine.StackTraceLogType
--]]
function Application:SetStackTraceLogType(logType,stackTraceType) end
--[[
	@mode UnityEngine.UserAuthorization
	@return [luaIde#UnityEngine.AsyncOperation]
--]]
function Application:RequestUserAuthorization(mode) end
--[[
	@mode UnityEngine.UserAuthorization
	return System.Boolean
--]]
function Application:HasUserAuthorization(mode) end

Physics = {}
--[[
	System.Int32
	 Get 
--]]
Physics.IgnoreRaycastLayer = 4
--[[
	System.Int32
	 Get 
--]]
Physics.DefaultRaycastLayers = -5
--[[
	System.Int32
	 Get 
--]]
Physics.AllLayers = -1
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
Physics.gravity = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Physics.defaultContactOffset = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Physics.sleepThreshold = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Physics.queriesHitTriggers = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Physics.queriesHitBackfaces = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Physics.bounceThreshold = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
Physics.defaultSolverIterations = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
Physics.defaultSolverVelocityIterations = nil
--[[
	UnityEngine.PhysicsScene
	 Get 
--]]
Physics.defaultPhysicsScene = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Physics.autoSimulation = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Physics.autoSyncTransforms = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Physics.reuseCollisionCallbacks = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Physics.interCollisionDistance = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Physics.interCollisionStiffness = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Physics.interCollisionSettingsToggle = nil
--[[
	@collider1 UnityEngine.Collider
	@collider2 UnityEngine.Collider
	@ignore System.Boolean
--]]
function Physics:IgnoreCollision(collider1,collider2,ignore) end
--[[
	@layer1 System.Int32
	@layer2 System.Int32
	@ignore System.Boolean
--]]
function Physics:IgnoreLayerCollision(layer1,layer2,ignore) end
--[[
	@layer1 System.Int32
	@layer2 System.Int32
	return System.Boolean
--]]
function Physics:GetIgnoreLayerCollision(layer1,layer2) end
--[[
	@origin UnityEngine.Vector3
	@direction UnityEngine.Vector3
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:Raycast(origin,direction,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@start UnityEngine.Vector3
	@end_ UnityEngine.Vector3
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:Linecast(start,end_,layerMask,queryTriggerInteraction) end
--[[
	@point1 UnityEngine.Vector3
	@point2 UnityEngine.Vector3
	@radius System.Single
	@direction UnityEngine.Vector3
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:CapsuleCast(point1,point2,radius,direction,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@origin UnityEngine.Vector3
	@radius System.Single
	@direction UnityEngine.Vector3
	@hitInfo UnityEngine.RaycastHit&
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:SphereCast(origin,radius,direction,hitInfo,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@center UnityEngine.Vector3
	@halfExtents UnityEngine.Vector3
	@direction UnityEngine.Vector3
	@orientation UnityEngine.Quaternion
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:BoxCast(center,halfExtents,direction,orientation,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@origin UnityEngine.Vector3
	@direction UnityEngine.Vector3
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.RaycastHit{}
--]]
function Physics:RaycastAll(origin,direction,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@ray UnityEngine.Ray
	@results UnityEngine.RaycastHit{}
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:RaycastNonAlloc(ray,results,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@point1 UnityEngine.Vector3
	@point2 UnityEngine.Vector3
	@radius System.Single
	@direction UnityEngine.Vector3
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.RaycastHit{}
--]]
function Physics:CapsuleCastAll(point1,point2,radius,direction,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@origin UnityEngine.Vector3
	@radius System.Single
	@direction UnityEngine.Vector3
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.RaycastHit{}
--]]
function Physics:SphereCastAll(origin,radius,direction,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@point0 UnityEngine.Vector3
	@point1 UnityEngine.Vector3
	@radius System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.Collider{}
--]]
function Physics:OverlapCapsule(point0,point1,radius,layerMask,queryTriggerInteraction) end
--[[
	@position UnityEngine.Vector3
	@radius System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.Collider{}
--]]
function Physics:OverlapSphere(position,radius,layerMask,queryTriggerInteraction) end
--[[
	@step System.Single
--]]
function Physics:Simulate(step) end
function Physics:SyncTransforms() end
--[[
	@colliderA UnityEngine.Collider
	@positionA UnityEngine.Vector3
	@rotationA UnityEngine.Quaternion
	@colliderB UnityEngine.Collider
	@positionB UnityEngine.Vector3
	@rotationB UnityEngine.Quaternion
	@direction UnityEngine.Vector3&
	@distance System.Single&
	return System.Boolean
--]]
function Physics:ComputePenetration(colliderA,positionA,rotationA,colliderB,positionB,rotationB,direction,distance) end
--[[
	@point UnityEngine.Vector3
	@collider UnityEngine.Collider
	@position UnityEngine.Vector3
	@rotation UnityEngine.Quaternion
	@return [luaIde#UnityEngine.Vector3]
--]]
function Physics:ClosestPoint(point,collider,position,rotation) end
--[[
	@position UnityEngine.Vector3
	@radius System.Single
	@results UnityEngine.Collider{}
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:OverlapSphereNonAlloc(position,radius,results,layerMask,queryTriggerInteraction) end
--[[
	@position UnityEngine.Vector3
	@radius System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:CheckSphere(position,radius,layerMask,queryTriggerInteraction) end
--[[
	@point1 UnityEngine.Vector3
	@point2 UnityEngine.Vector3
	@radius System.Single
	@direction UnityEngine.Vector3
	@results UnityEngine.RaycastHit{}
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:CapsuleCastNonAlloc(point1,point2,radius,direction,results,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@origin UnityEngine.Vector3
	@radius System.Single
	@direction UnityEngine.Vector3
	@results UnityEngine.RaycastHit{}
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:SphereCastNonAlloc(origin,radius,direction,results,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@start UnityEngine.Vector3
	@end_ UnityEngine.Vector3
	@radius System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:CheckCapsule(start,end_,radius,layerMask,queryTriggerInteraction) end
--[[
	@center UnityEngine.Vector3
	@halfExtents UnityEngine.Vector3
	@orientation UnityEngine.Quaternion
	@layermask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Boolean
--]]
function Physics:CheckBox(center,halfExtents,orientation,layermask,queryTriggerInteraction) end
--[[
	@center UnityEngine.Vector3
	@halfExtents UnityEngine.Vector3
	@orientation UnityEngine.Quaternion
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.Collider{}
--]]
function Physics:OverlapBox(center,halfExtents,orientation,layerMask,queryTriggerInteraction) end
--[[
	@center UnityEngine.Vector3
	@halfExtents UnityEngine.Vector3
	@results UnityEngine.Collider{}
	@orientation UnityEngine.Quaternion
	@mask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:OverlapBoxNonAlloc(center,halfExtents,results,orientation,mask,queryTriggerInteraction) end
--[[
	@center UnityEngine.Vector3
	@halfExtents UnityEngine.Vector3
	@direction UnityEngine.Vector3
	@results UnityEngine.RaycastHit{}
	@orientation UnityEngine.Quaternion
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:BoxCastNonAlloc(center,halfExtents,direction,results,orientation,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@center UnityEngine.Vector3
	@halfExtents UnityEngine.Vector3
	@direction UnityEngine.Vector3
	@orientation UnityEngine.Quaternion
	@maxDistance System.Single
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return UnityEngine.RaycastHit{}
--]]
function Physics:BoxCastAll(center,halfExtents,direction,orientation,maxDistance,layerMask,queryTriggerInteraction) end
--[[
	@point0 UnityEngine.Vector3
	@point1 UnityEngine.Vector3
	@radius System.Single
	@results UnityEngine.Collider{}
	@layerMask System.Int32
	@queryTriggerInteraction UnityEngine.QueryTriggerInteraction
	return System.Int32
--]]
function Physics:OverlapCapsuleNonAlloc(point0,point1,radius,results,layerMask,queryTriggerInteraction) end
--[[
	@worldBounds UnityEngine.Bounds
	@subdivisions System.Int32
--]]
function Physics:RebuildBroadphaseRegions(worldBounds,subdivisions) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.Collider = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Collider.enabled = nil
--[[
	@RefType [luaIde#UnityEngine.Rigidbody]
	 Get 
--]]
UnityEngine.Collider.attachedRigidbody = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Collider.isTrigger = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Collider.contactOffset = nil
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 
--]]
UnityEngine.Collider.bounds = nil
--[[
	UnityEngine.PhysicMaterial
	 Get 	 Set 
--]]
UnityEngine.Collider.sharedMaterial = nil
--[[
	UnityEngine.PhysicMaterial
	 Get 	 Set 
--]]
UnityEngine.Collider.material = nil
--[[
	@return [luaIde#UnityEngine.Collider]
]]
function UnityEngine.Collider:New() end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Collider:ClosestPoint(position) end
--[[
	@ray UnityEngine.Ray
	@hitInfo UnityEngine.RaycastHit&
	@maxDistance System.Single
	return System.Boolean
--]]
function UnityEngine.Collider:Raycast(ray,hitInfo,maxDistance) end
--[[
	@position UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Collider:ClosestPointOnBounds(position) end

Time = {}
--[[
	System.Single
	 Get 
--]]
Time.time = nil
--[[
	System.Single
	 Get 
--]]
Time.timeSinceLevelLoad = nil
--[[
	System.Single
	 Get 
--]]
Time.deltaTime = nil
--[[
	System.Single
	 Get 
--]]
Time.fixedTime = nil
--[[
	System.Single
	 Get 
--]]
Time.unscaledTime = nil
--[[
	System.Single
	 Get 
--]]
Time.fixedUnscaledTime = nil
--[[
	System.Single
	 Get 
--]]
Time.unscaledDeltaTime = nil
--[[
	System.Single
	 Get 
--]]
Time.fixedUnscaledDeltaTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Time.fixedDeltaTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Time.maximumDeltaTime = nil
--[[
	System.Single
	 Get 
--]]
Time.smoothDeltaTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Time.maximumParticleDeltaTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Time.timeScale = nil
--[[
	System.Int32
	 Get 
--]]
Time.frameCount = nil
--[[
	System.Int32
	 Get 
--]]
Time.renderedFrameCount = nil
--[[
	System.Single
	 Get 
--]]
Time.realtimeSinceStartup = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
Time.captureFramerate = nil
--[[
	System.Boolean
	 Get 
--]]
Time.inFixedTimeStep = nil

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.Texture = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Texture.masterTextureLimit = nil
--[[
	UnityEngine.AnisotropicFiltering
	 Get 	 Set 
--]]
UnityEngine.Texture.anisotropicFiltering = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Texture.width = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Texture.height = nil
--[[
	UnityEngine.Rendering.TextureDimension
	 Get 	 Set 
--]]
UnityEngine.Texture.dimension = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Texture.isReadable = nil
--[[
	UnityEngine.TextureWrapMode
	 Get 	 Set 
--]]
UnityEngine.Texture.wrapMode = nil
--[[
	UnityEngine.TextureWrapMode
	 Get 	 Set 
--]]
UnityEngine.Texture.wrapModeU = nil
--[[
	UnityEngine.TextureWrapMode
	 Get 	 Set 
--]]
UnityEngine.Texture.wrapModeV = nil
--[[
	UnityEngine.TextureWrapMode
	 Get 	 Set 
--]]
UnityEngine.Texture.wrapModeW = nil
--[[
	UnityEngine.FilterMode
	 Get 	 Set 
--]]
UnityEngine.Texture.filterMode = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Texture.anisoLevel = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Texture.mipMapBias = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Texture.texelSize = nil
--[[
	System.UInt32
	 Get 
--]]
UnityEngine.Texture.updateCount = nil
--[[
	UnityEngine.Hash128
	 Get 	 Set 
--]]
UnityEngine.Texture.imageContentsHash = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.totalTextureMemory = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.desiredTextureMemory = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.targetTextureMemory = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.currentTextureMemory = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.nonStreamingTextureMemory = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.streamingMipmapUploadCount = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.streamingRendererCount = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.streamingTextureCount = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.nonStreamingTextureCount = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.streamingTexturePendingLoadCount = nil
--[[
	System.UInt64
	 Get 
--]]
UnityEngine.Texture.streamingTextureLoadingCount = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Texture.streamingTextureForceLoadAll = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Texture.streamingTextureDiscardUnusedMips = nil
--[[
	@forcedMin System.Int32
	@globalMax System.Int32
--]]
function UnityEngine.Texture:SetGlobalAnisotropicFilteringLimits(forcedMin,globalMax) end
function UnityEngine.Texture:GetNativeTexturePtr() end
function UnityEngine.Texture:IncrementUpdateCount() end
function UnityEngine.Texture:SetStreamingTextureMaterialDebugProperties() end

--@SuperType [luaIde#UnityEngine.Texture]
UnityEngine.Texture2D = {}
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Texture2D.mipmapCount = nil
--[[
	UnityEngine.TextureFormat
	 Get 
--]]
UnityEngine.Texture2D.format = nil
--[[
	@RefType [luaIde#UnityEngine.Texture2D]
	 Get 
--]]
UnityEngine.Texture2D.whiteTexture = nil
--[[
	@RefType [luaIde#UnityEngine.Texture2D]
	 Get 
--]]
UnityEngine.Texture2D.blackTexture = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Texture2D.isReadable = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Texture2D.streamingMipmaps = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Texture2D.streamingMipmapsPriority = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Texture2D.requestedMipmapLevel = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Texture2D.desiredMipmapLevel = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Texture2D.loadingMipmapLevel = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Texture2D.loadedMipmapLevel = nil
--[[
	@width System.Int32
	@height System.Int32
	@return [luaIde#UnityEngine.Texture2D]
]]
function UnityEngine.Texture2D:New(width,height) end
--[[
	@width System.Int32
	@height System.Int32
	@textureFormat UnityEngine.TextureFormat
	@mipChain System.Boolean
	@return [luaIde#UnityEngine.Texture2D]
]]
function UnityEngine.Texture2D:New(width,height,textureFormat,mipChain) end
--[[
	@width System.Int32
	@height System.Int32
	@format UnityEngine.Experimental.Rendering.GraphicsFormat
	@flags UnityEngine.Experimental.Rendering.TextureCreationFlags
	@return [luaIde#UnityEngine.Texture2D]
]]
function UnityEngine.Texture2D:New(width,height,format,flags) end
--[[
	@width System.Int32
	@height System.Int32
	@textureFormat UnityEngine.TextureFormat
	@mipChain System.Boolean
	@linear System.Boolean
	@return [luaIde#UnityEngine.Texture2D]
]]
function UnityEngine.Texture2D:New(width,height,textureFormat,mipChain,linear) end
--[[
	@highQuality System.Boolean
--]]
function UnityEngine.Texture2D:Compress(highQuality) end
function UnityEngine.Texture2D:ClearRequestedMipmapLevel() end
function UnityEngine.Texture2D:IsRequestedMipmapLevelLoaded() end
--[[
	@nativeTex System.IntPtr
--]]
function UnityEngine.Texture2D:UpdateExternalTexture(nativeTex) end
function UnityEngine.Texture2D:GetRawTextureData() end
--[[
	@x System.Int32
	@y System.Int32
	@blockWidth System.Int32
	@blockHeight System.Int32
	@miplevel System.Int32
	return UnityEngine.Color{}
--]]
function UnityEngine.Texture2D:GetPixels(x,y,blockWidth,blockHeight,miplevel) end
--[[
	@miplevel System.Int32
	return UnityEngine.Color32{}
--]]
function UnityEngine.Texture2D:GetPixels32(miplevel) end
--[[
	@textures UnityEngine.Texture2D{}
	@padding System.Int32
	@maximumAtlasSize System.Int32
	@makeNoLongerReadable System.Boolean
	return UnityEngine.Rect{}
--]]
function UnityEngine.Texture2D:PackTextures(textures,padding,maximumAtlasSize,makeNoLongerReadable) end
--[[
	@width System.Int32
	@height System.Int32
	@format UnityEngine.TextureFormat
	@mipChain System.Boolean
	@linear System.Boolean
	@nativeTex System.IntPtr
	@return [luaIde#UnityEngine.Texture2D]
--]]
function UnityEngine.Texture2D:CreateExternalTexture(width,height,format,mipChain,linear,nativeTex) end
--[[
	@x System.Int32
	@y System.Int32
	@color UnityEngine.Color
--]]
function UnityEngine.Texture2D:SetPixel(x,y,color) end
--[[
	@x System.Int32
	@y System.Int32
	@blockWidth System.Int32
	@blockHeight System.Int32
	@colors UnityEngine.Color{}
	@miplevel System.Int32
--]]
function UnityEngine.Texture2D:SetPixels(x,y,blockWidth,blockHeight,colors,miplevel) end
--[[
	@x System.Int32
	@y System.Int32
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Texture2D:GetPixel(x,y) end
--[[
	@x System.Single
	@y System.Single
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Texture2D:GetPixelBilinear(x,y) end
--[[
	@data System.IntPtr
	@size System.Int32
--]]
function UnityEngine.Texture2D:LoadRawTextureData(data,size) end
--[[
	@updateMipmaps System.Boolean
	@makeNoLongerReadable System.Boolean
--]]
function UnityEngine.Texture2D:Apply(updateMipmaps,makeNoLongerReadable) end
--[[
	@width System.Int32
	@height System.Int32
	return System.Boolean
--]]
function UnityEngine.Texture2D:Resize(width,height) end
--[[
	@source UnityEngine.Rect
	@destX System.Int32
	@destY System.Int32
	@recalculateMipMaps System.Boolean
--]]
function UnityEngine.Texture2D:ReadPixels(source,destX,destY,recalculateMipMaps) end
--[[
	@sizes UnityEngine.Vector2{}
	@padding System.Int32
	@atlasSize System.Int32
	@results System.Collections.Generic.List`1{{UnityEngine.Rect, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return System.Boolean
--]]
function UnityEngine.Texture2D:GenerateAtlas(sizes,padding,atlasSize,results) end
--[[
	@colors UnityEngine.Color32{}
	@miplevel System.Int32
--]]
function UnityEngine.Texture2D:SetPixels32(colors,miplevel) end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.Shader = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Shader.maximumLOD = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Shader.globalMaximumLOD = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Shader.isSupported = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.Shader.globalRenderPipeline = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Shader.renderQueue = nil
--[[
	@name System.String
	@return [luaIde#UnityEngine.Shader]
--]]
function UnityEngine.Shader:Find(name) end
--[[
	@keyword System.String
--]]
function UnityEngine.Shader:EnableKeyword(keyword) end
--[[
	@keyword System.String
--]]
function UnityEngine.Shader:DisableKeyword(keyword) end
--[[
	@keyword System.String
	return System.Boolean
--]]
function UnityEngine.Shader:IsKeywordEnabled(keyword) end
function UnityEngine.Shader:WarmupAllShaders() end
--[[
	@name System.String
	return System.Int32
--]]
function UnityEngine.Shader:PropertyToID(name) end
--[[
	@name System.String
	@value System.Single
--]]
function UnityEngine.Shader:SetGlobalFloat(name,value) end
--[[
	@name System.String
	@value System.Int32
--]]
function UnityEngine.Shader:SetGlobalInt(name,value) end
--[[
	@name System.String
	@value UnityEngine.Vector4
--]]
function UnityEngine.Shader:SetGlobalVector(name,value) end
--[[
	@name System.String
	@value UnityEngine.Color
--]]
function UnityEngine.Shader:SetGlobalColor(name,value) end
--[[
	@name System.String
	@value UnityEngine.Matrix4x4
--]]
function UnityEngine.Shader:SetGlobalMatrix(name,value) end
--[[
	@name System.String
	@value UnityEngine.Texture
--]]
function UnityEngine.Shader:SetGlobalTexture(name,value) end
--[[
	@name System.String
	@value UnityEngine.ComputeBuffer
--]]
function UnityEngine.Shader:SetGlobalBuffer(name,value) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEngine.Shader:SetGlobalFloatArray(name,values) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{UnityEngine.Vector4, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Shader:SetGlobalVectorArray(name,values) end
--[[
	@name System.String
	@values System.Collections.Generic.List`1{{UnityEngine.Matrix4x4, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Shader:SetGlobalMatrixArray(name,values) end
--[[
	@name System.String
	return System.Single
--]]
function UnityEngine.Shader:GetGlobalFloat(name) end
--[[
	@name System.String
	return System.Int32
--]]
function UnityEngine.Shader:GetGlobalInt(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Shader:GetGlobalVector(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Color]
--]]
function UnityEngine.Shader:GetGlobalColor(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Shader:GetGlobalMatrix(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.Texture]
--]]
function UnityEngine.Shader:GetGlobalTexture(name) end
--[[
	@name System.String
	return System.Single{}
--]]
function UnityEngine.Shader:GetGlobalFloatArray(name) end
--[[
	@name System.String
	return UnityEngine.Vector4{}
--]]
function UnityEngine.Shader:GetGlobalVectorArray(name) end
--[[
	@name System.String
	return UnityEngine.Matrix4x4{}
--]]
function UnityEngine.Shader:GetGlobalMatrixArray(name) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.Renderer = {}
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 
--]]
UnityEngine.Renderer.bounds = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Renderer.enabled = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Renderer.isVisible = nil
--[[
	UnityEngine.Rendering.ShadowCastingMode
	 Get 	 Set 
--]]
UnityEngine.Renderer.shadowCastingMode = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Renderer.receiveShadows = nil
--[[
	UnityEngine.MotionVectorGenerationMode
	 Get 	 Set 
--]]
UnityEngine.Renderer.motionVectorGenerationMode = nil
--[[
	UnityEngine.Rendering.LightProbeUsage
	 Get 	 Set 
--]]
UnityEngine.Renderer.lightProbeUsage = nil
--[[
	UnityEngine.Rendering.ReflectionProbeUsage
	 Get 	 Set 
--]]
UnityEngine.Renderer.reflectionProbeUsage = nil
--[[
	System.UInt32
	 Get 	 Set 
--]]
UnityEngine.Renderer.renderingLayerMask = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Renderer.rendererPriority = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.Renderer.sortingLayerName = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Renderer.sortingLayerID = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Renderer.sortingOrder = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Renderer.allowOcclusionWhenDynamic = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Renderer.isPartOfStaticBatch = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Renderer.worldToLocalMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Renderer.localToWorldMatrix = nil
--[[
	@RefType [luaIde#UnityEngine.GameObject]
	 Get 	 Set 
--]]
UnityEngine.Renderer.lightProbeProxyVolumeOverride = nil
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 	 Set 
--]]
UnityEngine.Renderer.probeAnchor = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Renderer.lightmapIndex = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Renderer.realtimeLightmapIndex = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 	 Set 
--]]
UnityEngine.Renderer.lightmapScaleOffset = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 	 Set 
--]]
UnityEngine.Renderer.realtimeLightmapScaleOffset = nil
--[[
	UnityEngine.Material{}
	 Get 	 Set 
--]]
UnityEngine.Renderer.materials = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 	 Set 
--]]
UnityEngine.Renderer.material = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 	 Set 
--]]
UnityEngine.Renderer.sharedMaterial = nil
--[[
	UnityEngine.Material{}
	 Get 	 Set 
--]]
UnityEngine.Renderer.sharedMaterials = nil
--[[
	@return [luaIde#UnityEngine.Renderer]
]]
function UnityEngine.Renderer:New() end
function UnityEngine.Renderer:HasPropertyBlock() end
--[[
	@properties UnityEngine.MaterialPropertyBlock
--]]
function UnityEngine.Renderer:SetPropertyBlock(properties) end
--[[
	@properties UnityEngine.MaterialPropertyBlock
--]]
function UnityEngine.Renderer:GetPropertyBlock(properties) end
--[[
	@m System.Collections.Generic.List`1{{UnityEngine.Material, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Renderer:GetMaterials(m) end
--[[
	@m System.Collections.Generic.List`1{{UnityEngine.Material, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Renderer:GetSharedMaterials(m) end
--[[
	@result System.Collections.Generic.List`1{{UnityEngine.Rendering.ReflectionProbeBlendInfo, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Renderer:GetClosestReflectionProbes(result) end

Screen = {}
--[[
	System.Int32
	 Get 
--]]
Screen.width = nil
--[[
	System.Int32
	 Get 
--]]
Screen.height = nil
--[[
	System.Single
	 Get 
--]]
Screen.dpi = nil
--[[
	UnityEngine.ScreenOrientation
	 Get 	 Set 
--]]
Screen.orientation = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
Screen.sleepTimeout = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Screen.autorotateToPortrait = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Screen.autorotateToPortraitUpsideDown = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Screen.autorotateToLandscapeLeft = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Screen.autorotateToLandscapeRight = nil
--[[
	UnityEngine.Resolution
	 Get 
--]]
Screen.currentResolution = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Screen.fullScreen = nil
--[[
	UnityEngine.FullScreenMode
	 Get 	 Set 
--]]
Screen.fullScreenMode = nil
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 
--]]
Screen.safeArea = nil
--[[
	UnityEngine.Resolution{}
	 Get 
--]]
Screen.resolutions = nil
--[[
	@width System.Int32
	@height System.Int32
	@fullscreenMode UnityEngine.FullScreenMode
	@preferredRefreshRate System.Int32
--]]
function Screen:SetResolution(width,height,fullscreenMode,preferredRefreshRate) end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.Canvas = {}
--[[
	UnityEngine.RenderMode
	 Get 	 Set 
--]]
UnityEngine.Canvas.renderMode = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Canvas.isRootCanvas = nil
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 
--]]
UnityEngine.Canvas.pixelRect = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Canvas.scaleFactor = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Canvas.referencePixelsPerUnit = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Canvas.overridePixelPerfect = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Canvas.pixelPerfect = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Canvas.planeDistance = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Canvas.renderOrder = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Canvas.overrideSorting = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Canvas.sortingOrder = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Canvas.targetDisplay = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Canvas.sortingLayerID = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Canvas.cachedSortingLayerValue = nil
--[[
	UnityEngine.AdditionalCanvasShaderChannels
	 Get 	 Set 
--]]
UnityEngine.Canvas.additionalShaderChannels = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.Canvas.sortingLayerName = nil
--[[
	@RefType [luaIde#UnityEngine.Canvas]
	 Get 
--]]
UnityEngine.Canvas.rootCanvas = nil
--[[
	@RefType [luaIde#UnityEngine.Camera]
	 Get 	 Set 
--]]
UnityEngine.Canvas.worldCamera = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Canvas.normalizedSortingGridSize = nil
--[[
	UnityEngine.Canvas.WillRenderCanvases
	 Get 	 Set 
--]]
UnityEngine.Canvas.willRenderCanvases = nil
--[[
	@return [luaIde#UnityEngine.Canvas]
]]
function UnityEngine.Canvas:New() end
function UnityEngine.Canvas:GetDefaultCanvasMaterial() end
function UnityEngine.Canvas:GetETC1SupportedCanvasMaterial() end
function UnityEngine.Canvas:ForceUpdateCanvases() end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.CanvasScaler = {}
--[[
	UnityEngine.UI.CanvasScaler.ScaleMode
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.uiScaleMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.referencePixelsPerUnit = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.scaleFactor = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.referenceResolution = nil
--[[
	UnityEngine.UI.CanvasScaler.ScreenMatchMode
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.screenMatchMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.matchWidthOrHeight = nil
--[[
	UnityEngine.UI.CanvasScaler.Unit
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.physicalUnit = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.fallbackScreenDPI = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.defaultSpriteDPI = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.CanvasScaler.dynamicPixelsPerUnit = nil

--UnityEngine.CameraClearFlags  Enum
UnityEngine.CameraClearFlags = {}
--[[

	 Get 
--]]
UnityEngine.CameraClearFlags.Skybox = 1
--[[

	 Get 
--]]
UnityEngine.CameraClearFlags.Color = 2
--[[

	 Get 
--]]
UnityEngine.CameraClearFlags.SolidColor = 2
--[[

	 Get 
--]]
UnityEngine.CameraClearFlags.Depth = 3
--[[

	 Get 
--]]
UnityEngine.CameraClearFlags.Nothing = 4

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.AudioClip = {}
--[[
	System.Single
	 Get 
--]]
UnityEngine.AudioClip.length = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.AudioClip.samples = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.AudioClip.channels = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.AudioClip.frequency = nil
--[[
	UnityEngine.AudioClipLoadType
	 Get 
--]]
UnityEngine.AudioClip.loadType = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AudioClip.preloadAudioData = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AudioClip.ambisonic = nil
--[[
	UnityEngine.AudioDataLoadState
	 Get 
--]]
UnityEngine.AudioClip.loadState = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AudioClip.loadInBackground = nil
function UnityEngine.AudioClip:LoadAudioData() end
function UnityEngine.AudioClip:UnloadAudioData() end
--[[
	@data System.Single{}
	@offsetSamples System.Int32
	return System.Boolean
--]]
function UnityEngine.AudioClip:GetData(data,offsetSamples) end
--[[
	@data System.Single{}
	@offsetSamples System.Int32
	return System.Boolean
--]]
function UnityEngine.AudioClip:SetData(data,offsetSamples) end
--[[
	@name System.String
	@lengthSamples System.Int32
	@channels System.Int32
	@frequency System.Int32
	@stream System.Boolean
	@return [luaIde#UnityEngine.AudioClip]
--]]
function UnityEngine.AudioClip:Create(name,lengthSamples,channels,frequency,stream) end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.AssetBundle = {}
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AssetBundle.isStreamedSceneAssetBundle = nil
--[[
	@unloadAllObjects System.Boolean
--]]
function UnityEngine.AssetBundle:UnloadAllAssetBundles(unloadAllObjects) end
function UnityEngine.AssetBundle:GetAllLoadedAssetBundles() end
--[[
	@path System.String
	return UnityEngine.AssetBundleCreateRequest
--]]
function UnityEngine.AssetBundle:LoadFromFileAsync(path) end
--[[
	@path System.String
	@return [luaIde#UnityEngine.AssetBundle]
--]]
function UnityEngine.AssetBundle:LoadFromFile(path) end
--[[
	@binary System.Byte{}
	return UnityEngine.AssetBundleCreateRequest
--]]
function UnityEngine.AssetBundle:LoadFromMemoryAsync(binary) end
--[[
	@binary System.Byte{}
	@return [luaIde#UnityEngine.AssetBundle]
--]]
function UnityEngine.AssetBundle:LoadFromMemory(binary) end
--[[
	@stream System.IO.Stream
	@crc System.UInt32
	@managedReadBufferSize System.UInt32
	return UnityEngine.AssetBundleCreateRequest
--]]
function UnityEngine.AssetBundle:LoadFromStreamAsync(stream,crc,managedReadBufferSize) end
--[[
	@stream System.IO.Stream
	@crc System.UInt32
	@managedReadBufferSize System.UInt32
	@return [luaIde#UnityEngine.AssetBundle]
--]]
function UnityEngine.AssetBundle:LoadFromStream(stream,crc,managedReadBufferSize) end
--[[
	@name System.String
	return System.Boolean
--]]
function UnityEngine.AssetBundle:Contains(name) end
--[[
	@name System.String
	return UnityEngine.Object
--]]
function UnityEngine.AssetBundle:LoadAsset(name) end
--[[
	@name System.String
	return UnityEngine.AssetBundleRequest
--]]
function UnityEngine.AssetBundle:LoadAssetAsync(name) end
--[[
	@name System.String
	return UnityEngine.Object{}
--]]
function UnityEngine.AssetBundle:LoadAssetWithSubAssets(name) end
--[[
	@name System.String
	return UnityEngine.AssetBundleRequest
--]]
function UnityEngine.AssetBundle:LoadAssetWithSubAssetsAsync(name) end
function UnityEngine.AssetBundle:LoadAllAssets() end
function UnityEngine.AssetBundle:LoadAllAssetsAsync() end
--[[
	@unloadAllLoadedObjects System.Boolean
--]]
function UnityEngine.AssetBundle:Unload(unloadAllLoadedObjects) end
function UnityEngine.AssetBundle:GetAllAssetNames() end
function UnityEngine.AssetBundle:GetAllScenePaths() end
--[[
	@inputPath System.String
	@outputPath System.String
	@method UnityEngine.BuildCompression
	@expectedCRC System.UInt32
	@priority UnityEngine.ThreadPriority
	return UnityEngine.AssetBundleRecompressOperation
--]]
function UnityEngine.AssetBundle:RecompressAssetBundleAsync(inputPath,outputPath,method,expectedCRC,priority) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.ParticleSystem = {}
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.ParticleSystem.isPlaying = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.ParticleSystem.isEmitting = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.ParticleSystem.isStopped = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.ParticleSystem.isPaused = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.ParticleSystem.particleCount = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.time = nil
--[[
	System.UInt32
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.randomSeed = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.useAutoRandomSeed = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.ParticleSystem.proceduralSimulationSupported = nil
--[[
	UnityEngine.ParticleSystem.MainModule
	 Get 
--]]
UnityEngine.ParticleSystem.main = nil
--[[
	UnityEngine.ParticleSystem.EmissionModule
	 Get 
--]]
UnityEngine.ParticleSystem.emission = nil
--[[
	UnityEngine.ParticleSystem.ShapeModule
	 Get 
--]]
UnityEngine.ParticleSystem.shape = nil
--[[
	UnityEngine.ParticleSystem.VelocityOverLifetimeModule
	 Get 
--]]
UnityEngine.ParticleSystem.velocityOverLifetime = nil
--[[
	UnityEngine.ParticleSystem.LimitVelocityOverLifetimeModule
	 Get 
--]]
UnityEngine.ParticleSystem.limitVelocityOverLifetime = nil
--[[
	UnityEngine.ParticleSystem.InheritVelocityModule
	 Get 
--]]
UnityEngine.ParticleSystem.inheritVelocity = nil
--[[
	UnityEngine.ParticleSystem.ForceOverLifetimeModule
	 Get 
--]]
UnityEngine.ParticleSystem.forceOverLifetime = nil
--[[
	UnityEngine.ParticleSystem.ColorOverLifetimeModule
	 Get 
--]]
UnityEngine.ParticleSystem.colorOverLifetime = nil
--[[
	UnityEngine.ParticleSystem.ColorBySpeedModule
	 Get 
--]]
UnityEngine.ParticleSystem.colorBySpeed = nil
--[[
	UnityEngine.ParticleSystem.SizeOverLifetimeModule
	 Get 
--]]
UnityEngine.ParticleSystem.sizeOverLifetime = nil
--[[
	UnityEngine.ParticleSystem.SizeBySpeedModule
	 Get 
--]]
UnityEngine.ParticleSystem.sizeBySpeed = nil
--[[
	UnityEngine.ParticleSystem.RotationOverLifetimeModule
	 Get 
--]]
UnityEngine.ParticleSystem.rotationOverLifetime = nil
--[[
	UnityEngine.ParticleSystem.RotationBySpeedModule
	 Get 
--]]
UnityEngine.ParticleSystem.rotationBySpeed = nil
--[[
	UnityEngine.ParticleSystem.ExternalForcesModule
	 Get 
--]]
UnityEngine.ParticleSystem.externalForces = nil
--[[
	UnityEngine.ParticleSystem.NoiseModule
	 Get 
--]]
UnityEngine.ParticleSystem.noise = nil
--[[
	UnityEngine.ParticleSystem.CollisionModule
	 Get 
--]]
UnityEngine.ParticleSystem.collision = nil
--[[
	UnityEngine.ParticleSystem.TriggerModule
	 Get 
--]]
UnityEngine.ParticleSystem.trigger = nil
--[[
	UnityEngine.ParticleSystem.SubEmittersModule
	 Get 
--]]
UnityEngine.ParticleSystem.subEmitters = nil
--[[
	UnityEngine.ParticleSystem.TextureSheetAnimationModule
	 Get 
--]]
UnityEngine.ParticleSystem.textureSheetAnimation = nil
--[[
	UnityEngine.ParticleSystem.LightsModule
	 Get 
--]]
UnityEngine.ParticleSystem.lights = nil
--[[
	UnityEngine.ParticleSystem.TrailModule
	 Get 
--]]
UnityEngine.ParticleSystem.trails = nil
--[[
	UnityEngine.ParticleSystem.CustomDataModule
	 Get 
--]]
UnityEngine.ParticleSystem.customData = nil
--[[
	@return [luaIde#UnityEngine.ParticleSystem]
]]
function UnityEngine.ParticleSystem:New() end
--[[
	@customData System.Collections.Generic.List`1{{UnityEngine.Vector4, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@streamIndex UnityEngine.ParticleSystemCustomData
--]]
function UnityEngine.ParticleSystem:SetCustomParticleData(customData,streamIndex) end
--[[
	@customData System.Collections.Generic.List`1{{UnityEngine.Vector4, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	@streamIndex UnityEngine.ParticleSystemCustomData
	return System.Int32
--]]
function UnityEngine.ParticleSystem:GetCustomParticleData(customData,streamIndex) end
--[[
	@subEmitterIndex System.Int32
--]]
function UnityEngine.ParticleSystem:TriggerSubEmitter(subEmitterIndex) end
--[[
	@particles UnityEngine.ParticleSystem.Particle{}
	@size System.Int32
	@offset System.Int32
--]]
function UnityEngine.ParticleSystem:SetParticles(particles,size,offset) end
--[[
	@particles UnityEngine.ParticleSystem.Particle{}
	@size System.Int32
	@offset System.Int32
	return System.Int32
--]]
function UnityEngine.ParticleSystem:GetParticles(particles,size,offset) end
--[[
	@t System.Single
	@withChildren System.Boolean
	@restart System.Boolean
	@fixedTimeStep System.Boolean
--]]
function UnityEngine.ParticleSystem:Simulate(t,withChildren,restart,fixedTimeStep) end
--[[
	@withChildren System.Boolean
--]]
function UnityEngine.ParticleSystem:Play(withChildren) end
--[[
	@withChildren System.Boolean
--]]
function UnityEngine.ParticleSystem:Pause(withChildren) end
--[[
	@withChildren System.Boolean
	@stopBehavior UnityEngine.ParticleSystemStopBehavior
--]]
function UnityEngine.ParticleSystem:Stop(withChildren,stopBehavior) end
--[[
	@withChildren System.Boolean
--]]
function UnityEngine.ParticleSystem:Clear(withChildren) end
--[[
	@withChildren System.Boolean
	return System.Boolean
--]]
function UnityEngine.ParticleSystem:IsAlive(withChildren) end
--[[
	@count System.Int32
--]]
function UnityEngine.ParticleSystem:Emit(count) end
function UnityEngine.ParticleSystem:ResetPreMappedBufferMemory() end

--@SuperType [luaIde#System.Object]
UnityEngine.AsyncOperation = {}
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AsyncOperation.isDone = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.AsyncOperation.progress = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.AsyncOperation.priority = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AsyncOperation.allowSceneActivation = nil
--[[
	System.Action`1{{UnityEngine.AsyncOperation, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
UnityEngine.AsyncOperation.completed = nil
--[[
	@return [luaIde#UnityEngine.AsyncOperation]
]]
function UnityEngine.AsyncOperation:New() end

--UnityEngine.LightType  Enum
UnityEngine.LightType = {}
--[[

	 Get 
--]]
UnityEngine.LightType.Spot = 0
--[[

	 Get 
--]]
UnityEngine.LightType.Directional = 1
--[[

	 Get 
--]]
UnityEngine.LightType.Point = 2
--[[

	 Get 
--]]
UnityEngine.LightType.Area = 3
--[[

	 Get 
--]]
UnityEngine.LightType.Rectangle = 3
--[[

	 Get 
--]]
UnityEngine.LightType.Disc = 4

SleepTimeout = {}
--[[
	System.Int32
	 Get 
--]]
SleepTimeout.NeverSleep = -1
--[[
	System.Int32
	 Get 
--]]
SleepTimeout.SystemSetting = -2

Directory = {}
--[[
	@path System.String
	return System.IO.DirectoryInfo
--]]
function Directory:CreateDirectory(path) end
--[[
	@path System.String
--]]
function Directory:Delete(path) end
--[[
	@path System.String
	return System.Boolean
--]]
function Directory:Exists(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function Directory:GetLastAccessTime(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function Directory:GetLastAccessTimeUtc(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function Directory:GetLastWriteTime(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function Directory:GetLastWriteTimeUtc(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function Directory:GetCreationTime(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function Directory:GetCreationTimeUtc(path) end
function Directory:GetCurrentDirectory() end
--[[
	@path System.String
	return System.String{}
--]]
function Directory:GetDirectories(path) end
--[[
	@path System.String
	return System.String
--]]
function Directory:GetDirectoryRoot(path) end
--[[
	@path System.String
	return System.String{}
--]]
function Directory:GetFiles(path) end
--[[
	@path System.String
	return System.String{}
--]]
function Directory:GetFileSystemEntries(path) end
function Directory:GetLogicalDrives() end
--[[
	@path System.String
	return System.IO.DirectoryInfo
--]]
function Directory:GetParent(path) end
--[[
	@sourceDirName System.String
	@destDirName System.String
--]]
function Directory:Move(sourceDirName,destDirName) end
--[[
	@path System.String
	@creationTime System.DateTime
--]]
function Directory:SetCreationTime(path,creationTime) end
--[[
	@path System.String
	@creationTimeUtc System.DateTime
--]]
function Directory:SetCreationTimeUtc(path,creationTimeUtc) end
--[[
	@path System.String
--]]
function Directory:SetCurrentDirectory(path) end
--[[
	@path System.String
	@lastAccessTime System.DateTime
--]]
function Directory:SetLastAccessTime(path,lastAccessTime) end
--[[
	@path System.String
	@lastAccessTimeUtc System.DateTime
--]]
function Directory:SetLastAccessTimeUtc(path,lastAccessTimeUtc) end
--[[
	@path System.String
	@lastWriteTime System.DateTime
--]]
function Directory:SetLastWriteTime(path,lastWriteTime) end
--[[
	@path System.String
	@lastWriteTimeUtc System.DateTime
--]]
function Directory:SetLastWriteTimeUtc(path,lastWriteTimeUtc) end

File = {}
--[[
	@path System.String
	@contents System.String
--]]
function File:AppendAllText(path,contents) end
--[[
	@path System.String
	return System.IO.StreamWriter
--]]
function File:AppendText(path) end
--[[
	@sourceFileName System.String
	@destFileName System.String
--]]
function File:Copy(sourceFileName,destFileName) end
--[[
	@path System.String
	return System.IO.FileStream
--]]
function File:Create(path) end
--[[
	@path System.String
	return System.IO.StreamWriter
--]]
function File:CreateText(path) end
--[[
	@path System.String
--]]
function File:Delete(path) end
--[[
	@path System.String
	return System.Boolean
--]]
function File:Exists(path) end
--[[
	@path System.String
	return System.IO.FileAttributes
--]]
function File:GetAttributes(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function File:GetCreationTime(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function File:GetCreationTimeUtc(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function File:GetLastAccessTime(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function File:GetLastAccessTimeUtc(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function File:GetLastWriteTime(path) end
--[[
	@path System.String
	return System.DateTime
--]]
function File:GetLastWriteTimeUtc(path) end
--[[
	@sourceFileName System.String
	@destFileName System.String
--]]
function File:Move(sourceFileName,destFileName) end
--[[
	@path System.String
	@mode System.IO.FileMode
	return System.IO.FileStream
--]]
function File:Open(path,mode) end
--[[
	@path System.String
	return System.IO.FileStream
--]]
function File:OpenRead(path) end
--[[
	@path System.String
	return System.IO.StreamReader
--]]
function File:OpenText(path) end
--[[
	@path System.String
	return System.IO.FileStream
--]]
function File:OpenWrite(path) end
--[[
	@sourceFileName System.String
	@destinationFileName System.String
	@destinationBackupFileName System.String
--]]
function File:Replace(sourceFileName,destinationFileName,destinationBackupFileName) end
--[[
	@path System.String
	@fileAttributes System.IO.FileAttributes
--]]
function File:SetAttributes(path,fileAttributes) end
--[[
	@path System.String
	@creationTime System.DateTime
--]]
function File:SetCreationTime(path,creationTime) end
--[[
	@path System.String
	@creationTimeUtc System.DateTime
--]]
function File:SetCreationTimeUtc(path,creationTimeUtc) end
--[[
	@path System.String
	@lastAccessTime System.DateTime
--]]
function File:SetLastAccessTime(path,lastAccessTime) end
--[[
	@path System.String
	@lastAccessTimeUtc System.DateTime
--]]
function File:SetLastAccessTimeUtc(path,lastAccessTimeUtc) end
--[[
	@path System.String
	@lastWriteTime System.DateTime
--]]
function File:SetLastWriteTime(path,lastWriteTime) end
--[[
	@path System.String
	@lastWriteTimeUtc System.DateTime
--]]
function File:SetLastWriteTimeUtc(path,lastWriteTimeUtc) end
--[[
	@path System.String
	return System.Byte{}
--]]
function File:ReadAllBytes(path) end
--[[
	@path System.String
	return System.String{}
--]]
function File:ReadAllLines(path) end
--[[
	@path System.String
	return System.String
--]]
function File:ReadAllText(path) end
--[[
	@path System.String
	@bytes System.Byte{}
--]]
function File:WriteAllBytes(path,bytes) end
--[[
	@path System.String
	@contents System.String{}
--]]
function File:WriteAllLines(path,contents) end
--[[
	@path System.String
	@contents System.String
--]]
function File:WriteAllText(path,contents) end
--[[
	@path System.String
--]]
function File:Encrypt(path) end
--[[
	@path System.String
--]]
function File:Decrypt(path) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
MyButton = {}
--[[
	MyButton.MyButtonClickedEvent
	 Get 	 Set 
--]]
MyButton.onClick = nil
--[[
	MyButton.MyButtonClickedEvent
	 Get 	 Set 
--]]
MyButton.onDown = nil
--[[
	MyButton.MyButtonClickedEvent
	 Get 	 Set 
--]]
MyButton.onUp = nil
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function MyButton:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function MyButton:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function MyButton:OnPointerClick(eventData) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
ShotSceneTools = {}
--[[
	@mCam UnityEngine.Camera
	@x System.Int32
	@y System.Int32
	@width System.Int32
	@height System.Int32
	@path System.String
	@isRotate System.Boolean
--]]
function ShotSceneTools:MakeCameraImgAsync(mCam,x,y,width,height,path,isRotate) end
--[[
	@mCam UnityEngine.Camera
	@width System.Int32
	@height System.Int32
	@path System.String
	@isRotate System.Boolean
--]]
function ShotSceneTools:MakeCameraImg(mCam,width,height,path,isRotate) end

--@SuperType [luaIde#UnityEngine.UI.Image]
PolygonClick = {}
--[[
	PolygonClick.PolygonClickedEvent
	 Get 
	点下时发生
--]]
PolygonClick.PointerDown = nil
--[[
	PolygonClick.PolygonClickedEvent
	 Get 
	点击时发生
--]]
PolygonClick.PointerClick = nil
--[[
	PolygonClick.PolygonClickedEvent
	 Get 
	点击松开时发生
--]]
PolygonClick.PointerUp = nil
--[[
	重写方法，用于干涉点击射线有效性
	@screenPoint UnityEngine.Vector2
	@eventCamera UnityEngine.Camera
	return System.Boolean
--]]
function PolygonClick:IsRaycastLocationValid(screenPoint,eventCamera) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PolygonClick:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PolygonClick:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PolygonClick:OnPointerDown(eventData) end

--@SuperType [luaIde#UnityEngine.UI.Selectable]
UnityEngine.UI.Dropdown = {}
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.template = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Text]
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.captionText = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Image]
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.captionImage = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Text]
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.itemText = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Image]
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.itemImage = nil
--[[
	System.Collections.Generic.List`1{{UnityEngine.UI.Dropdown.OptionData, UnityEngine.UI, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.options = nil
--[[
	UnityEngine.UI.Dropdown.DropdownEvent
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.onValueChanged = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.value = nil
function UnityEngine.UI.Dropdown:RefreshShownValue() end
--[[
	@options System.Collections.Generic.List`1{{UnityEngine.UI.Dropdown.OptionData, UnityEngine.UI, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.UI.Dropdown:AddOptions(options) end
function UnityEngine.UI.Dropdown:ClearOptions() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Dropdown:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.Dropdown:OnSubmit(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.Dropdown:OnCancel(eventData) end
function UnityEngine.UI.Dropdown:Show() end
function UnityEngine.UI.Dropdown:Hide() end
--[[
	@obj UnityEngine.UI.Dropdown
	@data UnityEngine.UI.Dropdown.OptionData
--]]
function UnityEngine.UI.Dropdown:AddOptionData(obj,data) end

--@SuperType [luaIde#System.Object]
UnityEngine.UI.Dropdown.OptionData = {}
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.OptionData.text = nil
--[[
	@RefType [luaIde#UnityEngine.Sprite]
	 Get 	 Set 
--]]
UnityEngine.UI.Dropdown.OptionData.image = nil
--[[
	@return [luaIde#UnityEngine.UI.Dropdown.OptionData]
]]
function UnityEngine.UI.Dropdown.OptionData:New() end
--[[
	@image UnityEngine.Sprite
	@return [luaIde#UnityEngine.UI.Dropdown.OptionData]
]]
function UnityEngine.UI.Dropdown.OptionData:New(image) end
--[[
	@text System.String
	@return [luaIde#UnityEngine.UI.Dropdown.OptionData]
]]
function UnityEngine.UI.Dropdown.OptionData:New(text) end
--[[
	@text System.String
	@image UnityEngine.Sprite
	@return [luaIde#UnityEngine.UI.Dropdown.OptionData]
]]
function UnityEngine.UI.Dropdown.OptionData:New(text,image) end

--@SuperType [luaIde#Spine.Unity.SkeletonRenderer]
Spine.Unity.SkeletonAnimation = {}
--[[
	@RefType [luaIde#Spine.AnimationState]
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.state = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.loop = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.timeScale = nil
--[[
	@RefType [luaIde#Spine.AnimationState]
	 Get 
--]]
Spine.Unity.SkeletonAnimation.AnimationState = nil
--[[
	System.String
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.AnimationName = nil
--[[
	Spine.Unity.UpdateBonesDelegate
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.UpdateLocal = nil
--[[
	Spine.Unity.UpdateBonesDelegate
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.UpdateWorld = nil
--[[
	Spine.Unity.UpdateBonesDelegate
	 Get 	 Set 
--]]
Spine.Unity.SkeletonAnimation.UpdateComplete = nil
--[[
	@gameObject UnityEngine.GameObject
	@skeletonDataAsset Spine.Unity.SkeletonDataAsset
	@return [luaIde#Spine.Unity.SkeletonAnimation]
--]]
function Spine.Unity.SkeletonAnimation:AddToGameObject(gameObject,skeletonDataAsset) end
--[[
	@skeletonDataAsset Spine.Unity.SkeletonDataAsset
	@return [luaIde#Spine.Unity.SkeletonAnimation]
--]]
function Spine.Unity.SkeletonAnimation:NewSkeletonAnimationGameObject(skeletonDataAsset) end
function Spine.Unity.SkeletonAnimation:ClearState() end
--[[
	@overwrite System.Boolean
--]]
function Spine.Unity.SkeletonAnimation:Initialize(overwrite) end
--[[
	@deltaTime System.Single
--]]
function Spine.Unity.SkeletonAnimation:Update(deltaTime) end

--@SuperType [luaIde#System.Object]
Spine.AnimationState = {}
--[[
	Spine.AnimationStateData
	 Get 
--]]
Spine.AnimationState.Data = nil
--[[
	Spine.ExposedList`1{{Spine.TrackEntry, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.AnimationState.Tracks = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.AnimationState.TimeScale = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.AnimationState.Start = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.AnimationState.Interrupt = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.AnimationState.End = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.AnimationState.Dispose = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.AnimationState.Complete = nil
--[[
	Spine.AnimationState.TrackEntryEventDelegate
	 Get 	 Set 
--]]
Spine.AnimationState.Event = nil
--[[
	@data Spine.AnimationStateData
	@return [luaIde#Spine.AnimationState]
]]
function Spine.AnimationState:New(data) end
--[[
	@delta System.Single
--]]
function Spine.AnimationState:Update(delta) end
--[[
	@skeleton Spine.Skeleton
	return System.Boolean
--]]
function Spine.AnimationState:Apply(skeleton) end
function Spine.AnimationState:ClearTracks() end
--[[
	@trackIndex System.Int32
--]]
function Spine.AnimationState:ClearTrack(trackIndex) end
--[[
	@trackIndex System.Int32
	@animationName System.String
	@loop System.Boolean
	@return [luaIde#Spine.TrackEntry]
--]]
function Spine.AnimationState:SetAnimation(trackIndex,animationName,loop) end
--[[
	@trackIndex System.Int32
	@animationName System.String
	@loop System.Boolean
	@delay System.Single
	@return [luaIde#Spine.TrackEntry]
--]]
function Spine.AnimationState:AddAnimation(trackIndex,animationName,loop,delay) end
--[[
	@trackIndex System.Int32
	@mixDuration System.Single
	@return [luaIde#Spine.TrackEntry]
--]]
function Spine.AnimationState:SetEmptyAnimation(trackIndex,mixDuration) end
--[[
	@trackIndex System.Int32
	@mixDuration System.Single
	@delay System.Single
	@return [luaIde#Spine.TrackEntry]
--]]
function Spine.AnimationState:AddEmptyAnimation(trackIndex,mixDuration,delay) end
--[[
	@mixDuration System.Single
--]]
function Spine.AnimationState:SetEmptyAnimations(mixDuration) end
--[[
	@trackIndex System.Int32
	@return [luaIde#Spine.TrackEntry]
--]]
function Spine.AnimationState:GetCurrent(trackIndex) end
function Spine.AnimationState:ToString() end

--@SuperType [luaIde#System.Object]
Spine.TrackEntry = {}
--[[
	System.Int32
	 Get 
--]]
Spine.TrackEntry.TrackIndex = nil
--[[
	Spine.Animation
	 Get 
--]]
Spine.TrackEntry.Animation = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.TrackEntry.Loop = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.Delay = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.TrackTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.TrackEnd = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.AnimationStart = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.AnimationEnd = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.AnimationLast = nil
--[[
	System.Single
	 Get 
--]]
Spine.TrackEntry.AnimationTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.TimeScale = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.Alpha = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.EventThreshold = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.AttachmentThreshold = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.DrawOrderThreshold = nil
--[[
	@RefType [luaIde#Spine.TrackEntry]
	 Get 
--]]
Spine.TrackEntry.Next = nil
--[[
	System.Boolean
	 Get 
--]]
Spine.TrackEntry.IsComplete = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.MixTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.TrackEntry.MixDuration = nil
--[[
	@RefType [luaIde#Spine.TrackEntry]
	 Get 
--]]
Spine.TrackEntry.MixingFrom = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.TrackEntry.Start = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.TrackEntry.Interrupt = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.TrackEntry.End = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.TrackEntry.Dispose = nil
--[[
	Spine.AnimationState.TrackEntryDelegate
	 Get 	 Set 
--]]
Spine.TrackEntry.Complete = nil
--[[
	Spine.AnimationState.TrackEntryEventDelegate
	 Get 	 Set 
--]]
Spine.TrackEntry.Event = nil
--[[
	@return [luaIde#Spine.TrackEntry]
]]
function Spine.TrackEntry:New() end
function Spine.TrackEntry:Reset() end
function Spine.TrackEntry:ResetRotationDirections() end
function Spine.TrackEntry:ToString() end

--@SuperType [luaIde#System.Object]
Spine.Skeleton = {}
--[[
	Spine.SkeletonData
	 Get 
--]]
Spine.Skeleton.Data = nil
--[[
	Spine.ExposedList`1{{Spine.Bone, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.Bones = nil
--[[
	Spine.ExposedList`1{{Spine.IUpdatable, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.UpdateCacheList = nil
--[[
	Spine.ExposedList`1{{Spine.Slot, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.Slots = nil
--[[
	Spine.ExposedList`1{{Spine.Slot, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.DrawOrder = nil
--[[
	Spine.ExposedList`1{{Spine.IkConstraint, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.IkConstraints = nil
--[[
	Spine.ExposedList`1{{Spine.PathConstraint, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.PathConstraints = nil
--[[
	Spine.ExposedList`1{{Spine.TransformConstraint, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Skeleton.TransformConstraints = nil
--[[
	Spine.Skin
	 Get 	 Set 
--]]
Spine.Skeleton.Skin = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.R = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.G = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.B = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.A = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.Time = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.X = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Skeleton.Y = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Skeleton.FlipX = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Skeleton.FlipY = nil
--[[
	Spine.Bone
	 Get 
--]]
Spine.Skeleton.RootBone = nil
--[[
	@data Spine.SkeletonData
	@return [luaIde#Spine.Skeleton]
]]
function Spine.Skeleton:New(data) end
function Spine.Skeleton:UpdateCache() end
function Spine.Skeleton:UpdateWorldTransform() end
function Spine.Skeleton:SetToSetupPose() end
function Spine.Skeleton:SetBonesToSetupPose() end
function Spine.Skeleton:SetSlotsToSetupPose() end
--[[
	@boneName System.String
	return Spine.Bone
--]]
function Spine.Skeleton:FindBone(boneName) end
--[[
	@boneName System.String
	return System.Int32
--]]
function Spine.Skeleton:FindBoneIndex(boneName) end
--[[
	@slotName System.String
	return Spine.Slot
--]]
function Spine.Skeleton:FindSlot(slotName) end
--[[
	@slotName System.String
	return System.Int32
--]]
function Spine.Skeleton:FindSlotIndex(slotName) end
--[[
	@skinName System.String
--]]
function Spine.Skeleton:SetSkin(skinName) end
--[[
	@slotName System.String
	@attachmentName System.String
	return Spine.Attachment
--]]
function Spine.Skeleton:GetAttachment(slotName,attachmentName) end
--[[
	@slotName System.String
	@attachmentName System.String
--]]
function Spine.Skeleton:SetAttachment(slotName,attachmentName) end
--[[
	@constraintName System.String
	return Spine.IkConstraint
--]]
function Spine.Skeleton:FindIkConstraint(constraintName) end
--[[
	@constraintName System.String
	return Spine.TransformConstraint
--]]
function Spine.Skeleton:FindTransformConstraint(constraintName) end
--[[
	@constraintName System.String
	return Spine.PathConstraint
--]]
function Spine.Skeleton:FindPathConstraint(constraintName) end
--[[
	@delta System.Single
--]]
function Spine.Skeleton:Update(delta) end
--[[
	@x System.Single&
	@y System.Single&
	@width System.Single&
	@height System.Single&
	@vertexBuffer System.Single{}&
--]]
function Spine.Skeleton:GetBounds(x,y,width,height,vertexBuffer) end

--@SuperType [luaIde#UnityEngine.UI.Text]
InlineText = {}
--[[
	@RefType [luaIde#InlineText.HrefClickEvent]
	 Get 	 Set 
--]]
InlineText.OnHrefClick = nil
--[[
	System.Single
	 Get 
--]]
InlineText.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
InlineText.preferredHeight = nil
function InlineText:ActiveText() end
function InlineText:SetVerticesDirty() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function InlineText:OnPointerClick(eventData) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
SG.PoolObject = {}
--[[
	System.String
	 Get 	 Set 
--]]
SG.PoolObject.poolName = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
SG.PoolObject.isPooled = nil

--@SuperType [luaIde#UnityEngine.UI.LoopScrollRect]
UnityEngine.UI.LoopHorizontalScrollRect = {}

--@SuperType [luaIde#UnityEngine.UI.LoopScrollDataSource]
UnityEngine.UI.LoopScrollSendIndexSource = {}
--[[
	@RefType [luaIde#UnityEngine.UI.LoopScrollSendIndexSource]
	 Get 
--]]
UnityEngine.UI.LoopScrollSendIndexSource.Instance = nil
--[[
	@transform UnityEngine.Transform
	@idx System.Int32
--]]
function UnityEngine.UI.LoopScrollSendIndexSource:ProvideData(transform,idx) end

--@SuperType [luaIde#System.Object]
UnityEngine.UI.LoopScrollPrefabSource = {}
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollPrefabSource.prefabName = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollPrefabSource.poolSize = nil
--[[
	@return [luaIde#UnityEngine.UI.LoopScrollPrefabSource]
]]
function UnityEngine.UI.LoopScrollPrefabSource:New() end
function UnityEngine.UI.LoopScrollPrefabSource:GetObject() end

--@SuperType [luaIde#UnityEngine.UI.LoopScrollRect]
UnityEngine.UI.LoopVerticalScrollRect = {}

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
ScrollIndexCallback = {}
--[[
	@RefType [luaIde#UnityEngine.UI.LayoutElement]
	 Get 	 Set 
--]]
ScrollIndexCallback.element = nil

ImageConversion = {}
--[[
	@tex UnityEngine.Texture2D
	return System.Byte{}
--]]
function ImageConversion:EncodeToTGA(tex) end
--[[
	@tex UnityEngine.Texture2D
	return System.Byte{}
--]]
function ImageConversion:EncodeToPNG(tex) end
--[[
	@tex UnityEngine.Texture2D
	@quality System.Int32
	return System.Byte{}
--]]
function ImageConversion:EncodeToJPG(tex,quality) end
--[[
	@tex UnityEngine.Texture2D
	@flags UnityEngine.Texture2D.EXRFlags
	return System.Byte{}
--]]
function ImageConversion:EncodeToEXR(tex,flags) end
--[[
	@tex UnityEngine.Texture2D
	@data System.Byte{}
	@markNonReadable System.Boolean
	return System.Boolean
--]]
function ImageConversion:LoadImage(tex,data,markNonReadable) end

--@SuperType [luaIde#System.Object]
UnityEngine.SceneManagement.SceneManager = {}
--[[
	System.Int32
	 Get 
--]]
UnityEngine.SceneManagement.SceneManager.sceneCount = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.SceneManagement.SceneManager.sceneCountInBuildSettings = nil
--[[
	UnityEngine.Events.UnityAction`2{{UnityEngine.SceneManagement.Scene, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.SceneManagement.LoadSceneMode, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
UnityEngine.SceneManagement.SceneManager.sceneLoaded = nil
--[[
	UnityEngine.Events.UnityAction`1{{UnityEngine.SceneManagement.Scene, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
UnityEngine.SceneManagement.SceneManager.sceneUnloaded = nil
--[[
	UnityEngine.Events.UnityAction`2{{UnityEngine.SceneManagement.Scene, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.SceneManagement.Scene, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
UnityEngine.SceneManagement.SceneManager.activeSceneChanged = nil
--[[
	@return [luaIde#UnityEngine.SceneManagement.SceneManager]
]]
function UnityEngine.SceneManagement.SceneManager:New() end
function UnityEngine.SceneManagement.SceneManager:GetActiveScene() end
--[[
	@scene UnityEngine.SceneManagement.Scene
	return System.Boolean
--]]
function UnityEngine.SceneManagement.SceneManager:SetActiveScene(scene) end
--[[
	@scenePath System.String
	return UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:GetSceneByPath(scenePath) end
--[[
	@name System.String
	return UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:GetSceneByName(name) end
--[[
	@buildIndex System.Int32
	return UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:GetSceneByBuildIndex(buildIndex) end
--[[
	@index System.Int32
	return UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:GetSceneAt(index) end
--[[
	@sceneName System.String
	@parameters UnityEngine.SceneManagement.CreateSceneParameters
	return UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:CreateScene(sceneName,parameters) end
--[[
	@sourceScene UnityEngine.SceneManagement.Scene
	@destinationScene UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:MergeScenes(sourceScene,destinationScene) end
--[[
	@go UnityEngine.GameObject
	@scene UnityEngine.SceneManagement.Scene
--]]
function UnityEngine.SceneManagement.SceneManager:MoveGameObjectToScene(go,scene) end
--[[
	@sceneName System.String
	@mode UnityEngine.SceneManagement.LoadSceneMode
--]]
function UnityEngine.SceneManagement.SceneManager:LoadScene(sceneName,mode) end
--[[
	@sceneBuildIndex System.Int32
	@mode UnityEngine.SceneManagement.LoadSceneMode
	@return [luaIde#UnityEngine.AsyncOperation]
--]]
function UnityEngine.SceneManagement.SceneManager:LoadSceneAsync(sceneBuildIndex,mode) end
--[[
	@sceneBuildIndex System.Int32
	@return [luaIde#UnityEngine.AsyncOperation]
--]]
function UnityEngine.SceneManagement.SceneManager:UnloadSceneAsync(sceneBuildIndex) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEngine.Events.UnityEvent = {}
--[[
	@return [luaIde#UnityEngine.Events.UnityEvent]
]]
function UnityEngine.Events.UnityEvent:New() end
--[[
	@call UnityEngine.Events.UnityAction
--]]
function UnityEngine.Events.UnityEvent:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction
--]]
function UnityEngine.Events.UnityEvent:RemoveListener(call) end
function UnityEngine.Events.UnityEvent:Invoke() end

--@SuperType [luaIde#UnityEngine.Events.UnityEvent<string,int>]
InlineText.HrefClickEvent = {}
--[[
	@return [luaIde#InlineText.HrefClickEvent]
]]
function InlineText.HrefClickEvent:New() end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_float = {}
--[[
	@call UnityEngine.Events.UnityAction`1{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_float:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`1{{System.Single, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_float:RemoveListener(call) end
--[[
	@arg0 System.Single
--]]
function UnityEvent_float:Invoke(arg0) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_bool = {}
--[[
	@call UnityEngine.Events.UnityAction`1{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_bool:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`1{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_bool:RemoveListener(call) end
--[[
	@arg0 System.Boolean
--]]
function UnityEvent_bool:Invoke(arg0) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_string = {}
--[[
	@call UnityEngine.Events.UnityAction`1{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_string:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`1{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_string:RemoveListener(call) end
--[[
	@arg0 System.String
--]]
function UnityEvent_string:Invoke(arg0) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_int = {}
--[[
	@call UnityEngine.Events.UnityAction`1{{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_int:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`1{{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_int:RemoveListener(call) end
--[[
	@arg0 System.Int32
--]]
function UnityEvent_int:Invoke(arg0) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_string_int = {}
--[[
	@call UnityEngine.Events.UnityAction`2{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089},{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_string_int:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`2{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089},{System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function UnityEvent_string_int:RemoveListener(call) end
--[[
	@arg0 System.String
	@arg1 System.Int32
--]]
function UnityEvent_string_int:Invoke(arg0,arg1) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_PolygonClick = {}
--[[
	@call UnityEngine.Events.UnityAction`1{{PolygonClick, Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEvent_PolygonClick:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`1{{PolygonClick, Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEvent_PolygonClick:RemoveListener(call) end
--[[
	@arg0 PolygonClick
--]]
function UnityEvent_PolygonClick:Invoke(arg0) end

--@SuperType [luaIde#UnityEngine.Events.UnityEventBase]
UnityEvent_UnityEngine_Vector2 = {}
--[[
	@call UnityEngine.Events.UnityAction`1{{UnityEngine.Vector2, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEvent_UnityEngine_Vector2:AddListener(call) end
--[[
	@call UnityEngine.Events.UnityAction`1{{UnityEngine.Vector2, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEvent_UnityEngine_Vector2:RemoveListener(call) end
--[[
	@arg0 UnityEngine.Vector2
--]]
function UnityEvent_UnityEngine_Vector2:Invoke(arg0) end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.Animator = {}
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.isOptimizable = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.isHuman = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.hasRootMotion = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Animator.humanScale = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.isInitialized = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Animator.deltaPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 
--]]
UnityEngine.Animator.deltaRotation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Animator.velocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Animator.angularVelocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Animator.rootPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 	 Set 
--]]
UnityEngine.Animator.rootRotation = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animator.applyRootMotion = nil
--[[
	UnityEngine.AnimatorUpdateMode
	 Get 	 Set 
--]]
UnityEngine.Animator.updateMode = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.hasTransformHierarchy = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Animator.gravityWeight = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.Animator.bodyPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 	 Set 
--]]
UnityEngine.Animator.bodyRotation = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animator.stabilizeFeet = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Animator.layerCount = nil
--[[
	UnityEngine.AnimatorControllerParameter{}
	 Get 
--]]
UnityEngine.Animator.parameters = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Animator.parameterCount = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Animator.feetPivotActive = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Animator.pivotWeight = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Animator.pivotPosition = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.isMatchingTarget = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Animator.speed = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Animator.targetPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 
--]]
UnityEngine.Animator.targetRotation = nil
--[[
	UnityEngine.AnimatorCullingMode
	 Get 	 Set 
--]]
UnityEngine.Animator.cullingMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Animator.playbackTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Animator.recorderStartTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Animator.recorderStopTime = nil
--[[
	UnityEngine.AnimatorRecorderMode
	 Get 
--]]
UnityEngine.Animator.recorderMode = nil
--[[
	UnityEngine.RuntimeAnimatorController
	 Get 	 Set 
--]]
UnityEngine.Animator.runtimeAnimatorController = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animator.hasBoundPlayables = nil
--[[
	UnityEngine.Avatar
	 Get 	 Set 
--]]
UnityEngine.Animator.avatar = nil
--[[
	UnityEngine.Playables.PlayableGraph
	 Get 
--]]
UnityEngine.Animator.playableGraph = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animator.layersAffectMassCenter = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Animator.leftFeetBottomHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Animator.rightFeetBottomHeight = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animator.logWarnings = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animator.fireEvents = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animator.keepAnimatorControllerStateOnDisable = nil
--[[
	@return [luaIde#UnityEngine.Animator]
]]
function UnityEngine.Animator:New() end
--[[
	@name System.String
	return System.Single
--]]
function UnityEngine.Animator:GetFloat(name) end
--[[
	@name System.String
	@value System.Single
--]]
function UnityEngine.Animator:SetFloat(name,value) end
--[[
	@name System.String
	return System.Boolean
--]]
function UnityEngine.Animator:GetBool(name) end
--[[
	@name System.String
	@value System.Boolean
--]]
function UnityEngine.Animator:SetBool(name,value) end
--[[
	@name System.String
	return System.Int32
--]]
function UnityEngine.Animator:GetInteger(name) end
--[[
	@name System.String
	@value System.Int32
--]]
function UnityEngine.Animator:SetInteger(name,value) end
--[[
	@name System.String
--]]
function UnityEngine.Animator:SetTrigger(name) end
--[[
	@name System.String
--]]
function UnityEngine.Animator:ResetTrigger(name) end
--[[
	@name System.String
	return System.Boolean
--]]
function UnityEngine.Animator:IsParameterControlledByCurve(name) end
--[[
	@goal UnityEngine.AvatarIKGoal
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Animator:GetIKPosition(goal) end
--[[
	@goal UnityEngine.AvatarIKGoal
	@goalPosition UnityEngine.Vector3
--]]
function UnityEngine.Animator:SetIKPosition(goal,goalPosition) end
--[[
	@goal UnityEngine.AvatarIKGoal
	@return [luaIde#UnityEngine.Quaternion]
--]]
function UnityEngine.Animator:GetIKRotation(goal) end
--[[
	@goal UnityEngine.AvatarIKGoal
	@goalRotation UnityEngine.Quaternion
--]]
function UnityEngine.Animator:SetIKRotation(goal,goalRotation) end
--[[
	@goal UnityEngine.AvatarIKGoal
	return System.Single
--]]
function UnityEngine.Animator:GetIKPositionWeight(goal) end
--[[
	@goal UnityEngine.AvatarIKGoal
	@value System.Single
--]]
function UnityEngine.Animator:SetIKPositionWeight(goal,value) end
--[[
	@goal UnityEngine.AvatarIKGoal
	return System.Single
--]]
function UnityEngine.Animator:GetIKRotationWeight(goal) end
--[[
	@goal UnityEngine.AvatarIKGoal
	@value System.Single
--]]
function UnityEngine.Animator:SetIKRotationWeight(goal,value) end
--[[
	@hint UnityEngine.AvatarIKHint
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Animator:GetIKHintPosition(hint) end
--[[
	@hint UnityEngine.AvatarIKHint
	@hintPosition UnityEngine.Vector3
--]]
function UnityEngine.Animator:SetIKHintPosition(hint,hintPosition) end
--[[
	@hint UnityEngine.AvatarIKHint
	return System.Single
--]]
function UnityEngine.Animator:GetIKHintPositionWeight(hint) end
--[[
	@hint UnityEngine.AvatarIKHint
	@value System.Single
--]]
function UnityEngine.Animator:SetIKHintPositionWeight(hint,value) end
--[[
	@lookAtPosition UnityEngine.Vector3
--]]
function UnityEngine.Animator:SetLookAtPosition(lookAtPosition) end
--[[
	@weight System.Single
--]]
function UnityEngine.Animator:SetLookAtWeight(weight) end
--[[
	@humanBoneId UnityEngine.HumanBodyBones
	@rotation UnityEngine.Quaternion
--]]
function UnityEngine.Animator:SetBoneLocalRotation(humanBoneId,rotation) end
--[[
	@fullPathHash System.Int32
	@layerIndex System.Int32
	return UnityEngine.StateMachineBehaviour{}
--]]
function UnityEngine.Animator:GetBehaviours(fullPathHash,layerIndex) end
--[[
	@layerIndex System.Int32
	return System.String
--]]
function UnityEngine.Animator:GetLayerName(layerIndex) end
--[[
	@layerName System.String
	return System.Int32
--]]
function UnityEngine.Animator:GetLayerIndex(layerName) end
--[[
	@layerIndex System.Int32
	return System.Single
--]]
function UnityEngine.Animator:GetLayerWeight(layerIndex) end
--[[
	@layerIndex System.Int32
	@weight System.Single
--]]
function UnityEngine.Animator:SetLayerWeight(layerIndex,weight) end
--[[
	@layerIndex System.Int32
	return UnityEngine.AnimatorStateInfo
--]]
function UnityEngine.Animator:GetCurrentAnimatorStateInfo(layerIndex) end
--[[
	@layerIndex System.Int32
	return UnityEngine.AnimatorStateInfo
--]]
function UnityEngine.Animator:GetNextAnimatorStateInfo(layerIndex) end
--[[
	@layerIndex System.Int32
	return UnityEngine.AnimatorTransitionInfo
--]]
function UnityEngine.Animator:GetAnimatorTransitionInfo(layerIndex) end
--[[
	@layerIndex System.Int32
	return System.Int32
--]]
function UnityEngine.Animator:GetCurrentAnimatorClipInfoCount(layerIndex) end
--[[
	@layerIndex System.Int32
	return System.Int32
--]]
function UnityEngine.Animator:GetNextAnimatorClipInfoCount(layerIndex) end
--[[
	@layerIndex System.Int32
	return UnityEngine.AnimatorClipInfo{}
--]]
function UnityEngine.Animator:GetCurrentAnimatorClipInfo(layerIndex) end
--[[
	@layerIndex System.Int32
	return UnityEngine.AnimatorClipInfo{}
--]]
function UnityEngine.Animator:GetNextAnimatorClipInfo(layerIndex) end
--[[
	@layerIndex System.Int32
	return System.Boolean
--]]
function UnityEngine.Animator:IsInTransition(layerIndex) end
--[[
	@index System.Int32
	return UnityEngine.AnimatorControllerParameter
--]]
function UnityEngine.Animator:GetParameter(index) end
--[[
	@matchPosition UnityEngine.Vector3
	@matchRotation UnityEngine.Quaternion
	@targetBodyPart UnityEngine.AvatarTarget
	@weightMask UnityEngine.MatchTargetWeightMask
	@startNormalizedTime System.Single
--]]
function UnityEngine.Animator:MatchTarget(matchPosition,matchRotation,targetBodyPart,weightMask,startNormalizedTime) end
function UnityEngine.Animator:InterruptMatchTarget() end
--[[
	@stateName System.String
	@fixedTransitionDuration System.Single
--]]
function UnityEngine.Animator:CrossFadeInFixedTime(stateName,fixedTransitionDuration) end
function UnityEngine.Animator:WriteDefaultValues() end
--[[
	@stateName System.String
	@normalizedTransitionDuration System.Single
	@layer System.Int32
	@normalizedTimeOffset System.Single
--]]
function UnityEngine.Animator:CrossFade(stateName,normalizedTransitionDuration,layer,normalizedTimeOffset) end
--[[
	@stateName System.String
	@layer System.Int32
--]]
function UnityEngine.Animator:PlayInFixedTime(stateName,layer) end
--[[
	@stateName System.String
	@layer System.Int32
--]]
function UnityEngine.Animator:Play(stateName,layer) end
--[[
	@targetIndex UnityEngine.AvatarTarget
	@targetNormalizedTime System.Single
--]]
function UnityEngine.Animator:SetTarget(targetIndex,targetNormalizedTime) end
--[[
	@humanBoneId UnityEngine.HumanBodyBones
	@return [luaIde#UnityEngine.Transform]
--]]
function UnityEngine.Animator:GetBoneTransform(humanBoneId) end
function UnityEngine.Animator:StartPlayback() end
function UnityEngine.Animator:StopPlayback() end
--[[
	@frameCount System.Int32
--]]
function UnityEngine.Animator:StartRecording(frameCount) end
function UnityEngine.Animator:StopRecording() end
--[[
	@layerIndex System.Int32
	@stateID System.Int32
	return System.Boolean
--]]
function UnityEngine.Animator:HasState(layerIndex,stateID) end
--[[
	@name System.String
	return System.Int32
--]]
function UnityEngine.Animator:StringToHash(name) end
--[[
	@deltaTime System.Single
--]]
function UnityEngine.Animator:Update(deltaTime) end
function UnityEngine.Animator:Rebind() end
function UnityEngine.Animator:ApplyBuiltinRootMotion() end

Input = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
Input.simulateMouseWithTouches = nil
--[[
	System.Boolean
	 Get 
--]]
Input.anyKey = nil
--[[
	System.Boolean
	 Get 
--]]
Input.anyKeyDown = nil
--[[
	System.String
	 Get 
--]]
Input.inputString = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
Input.mousePosition = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
Input.mouseScrollDelta = nil
--[[
	UnityEngine.IMECompositionMode
	 Get 	 Set 
--]]
Input.imeCompositionMode = nil
--[[
	System.String
	 Get 
--]]
Input.compositionString = nil
--[[
	System.Boolean
	 Get 
--]]
Input.imeIsSelected = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
Input.compositionCursorPos = nil
--[[
	System.Boolean
	 Get 
--]]
Input.mousePresent = nil
--[[
	System.Int32
	 Get 
--]]
Input.touchCount = nil
--[[
	System.Boolean
	 Get 
--]]
Input.touchPressureSupported = nil
--[[
	System.Boolean
	 Get 
--]]
Input.stylusTouchSupported = nil
--[[
	System.Boolean
	 Get 
--]]
Input.touchSupported = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Input.multiTouchEnabled = nil
--[[
	UnityEngine.DeviceOrientation
	 Get 
--]]
Input.deviceOrientation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
Input.acceleration = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Input.compensateSensors = nil
--[[
	System.Int32
	 Get 
--]]
Input.accelerationEventCount = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Input.backButtonLeavesApp = nil
--[[
	UnityEngine.LocationService
	 Get 
--]]
Input.location = nil
--[[
	UnityEngine.Compass
	 Get 
--]]
Input.compass = nil
--[[
	UnityEngine.Gyroscope
	 Get 
--]]
Input.gyro = nil
--[[
	UnityEngine.Touch{}
	 Get 
--]]
Input.touches = nil
--[[
	UnityEngine.AccelerationEvent{}
	 Get 
--]]
Input.accelerationEvents = nil
--[[
	@axisName System.String
	return System.Single
--]]
function Input:GetAxis(axisName) end
--[[
	@axisName System.String
	return System.Single
--]]
function Input:GetAxisRaw(axisName) end
--[[
	@buttonName System.String
	return System.Boolean
--]]
function Input:GetButton(buttonName) end
--[[
	@buttonName System.String
	return System.Boolean
--]]
function Input:GetButtonDown(buttonName) end
--[[
	@buttonName System.String
	return System.Boolean
--]]
function Input:GetButtonUp(buttonName) end
--[[
	@button System.Int32
	return System.Boolean
--]]
function Input:GetMouseButton(button) end
--[[
	@button System.Int32
	return System.Boolean
--]]
function Input:GetMouseButtonDown(button) end
--[[
	@button System.Int32
	return System.Boolean
--]]
function Input:GetMouseButtonUp(button) end
function Input:ResetInputAxes() end
function Input:GetJoystickNames() end
--[[
	@index System.Int32
	return UnityEngine.AccelerationEvent
--]]
function Input:GetAccelerationEvent(index) end
--[[
	@key UnityEngine.KeyCode
	return System.Boolean
--]]
function Input:GetKey(key) end
--[[
	@key UnityEngine.KeyCode
	return System.Boolean
--]]
function Input:GetKeyUp(key) end
--[[
	@key UnityEngine.KeyCode
	return System.Boolean
--]]
function Input:GetKeyDown(key) end
--[[
	@index System.Int32
	@flag System.Int32
	@return [luaIde#UnityEngine.Touch]
--]]
function Input:GetTouch(index,flag) end

--UnityEngine.KeyCode  Enum
UnityEngine.KeyCode = {}
--[[

	 Get 
--]]
UnityEngine.KeyCode.None = 0
--[[

	 Get 
--]]
UnityEngine.KeyCode.Backspace = 8
--[[

	 Get 
--]]
UnityEngine.KeyCode.Delete = 127
--[[

	 Get 
--]]
UnityEngine.KeyCode.Tab = 9
--[[

	 Get 
--]]
UnityEngine.KeyCode.Clear = 12
--[[

	 Get 
--]]
UnityEngine.KeyCode.Return = 13
--[[

	 Get 
--]]
UnityEngine.KeyCode.Pause = 19
--[[

	 Get 
--]]
UnityEngine.KeyCode.Escape = 27
--[[

	 Get 
--]]
UnityEngine.KeyCode.Space = 32
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad0 = 256
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad1 = 257
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad2 = 258
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad3 = 259
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad4 = 260
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad5 = 261
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad6 = 262
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad7 = 263
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad8 = 264
--[[

	 Get 
--]]
UnityEngine.KeyCode.Keypad9 = 265
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadPeriod = 266
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadDivide = 267
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadMultiply = 268
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadMinus = 269
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadPlus = 270
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadEnter = 271
--[[

	 Get 
--]]
UnityEngine.KeyCode.KeypadEquals = 272
--[[

	 Get 
--]]
UnityEngine.KeyCode.UpArrow = 273
--[[

	 Get 
--]]
UnityEngine.KeyCode.DownArrow = 274
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightArrow = 275
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftArrow = 276
--[[

	 Get 
--]]
UnityEngine.KeyCode.Insert = 277
--[[

	 Get 
--]]
UnityEngine.KeyCode.Home = 278
--[[

	 Get 
--]]
UnityEngine.KeyCode.End = 279
--[[

	 Get 
--]]
UnityEngine.KeyCode.PageUp = 280
--[[

	 Get 
--]]
UnityEngine.KeyCode.PageDown = 281
--[[

	 Get 
--]]
UnityEngine.KeyCode.F1 = 282
--[[

	 Get 
--]]
UnityEngine.KeyCode.F2 = 283
--[[

	 Get 
--]]
UnityEngine.KeyCode.F3 = 284
--[[

	 Get 
--]]
UnityEngine.KeyCode.F4 = 285
--[[

	 Get 
--]]
UnityEngine.KeyCode.F5 = 286
--[[

	 Get 
--]]
UnityEngine.KeyCode.F6 = 287
--[[

	 Get 
--]]
UnityEngine.KeyCode.F7 = 288
--[[

	 Get 
--]]
UnityEngine.KeyCode.F8 = 289
--[[

	 Get 
--]]
UnityEngine.KeyCode.F9 = 290
--[[

	 Get 
--]]
UnityEngine.KeyCode.F10 = 291
--[[

	 Get 
--]]
UnityEngine.KeyCode.F11 = 292
--[[

	 Get 
--]]
UnityEngine.KeyCode.F12 = 293
--[[

	 Get 
--]]
UnityEngine.KeyCode.F13 = 294
--[[

	 Get 
--]]
UnityEngine.KeyCode.F14 = 295
--[[

	 Get 
--]]
UnityEngine.KeyCode.F15 = 296
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha0 = 48
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha1 = 49
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha2 = 50
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha3 = 51
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha4 = 52
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha5 = 53
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha6 = 54
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha7 = 55
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha8 = 56
--[[

	 Get 
--]]
UnityEngine.KeyCode.Alpha9 = 57
--[[

	 Get 
--]]
UnityEngine.KeyCode.Exclaim = 33
--[[

	 Get 
--]]
UnityEngine.KeyCode.DoubleQuote = 34
--[[

	 Get 
--]]
UnityEngine.KeyCode.Hash = 35
--[[

	 Get 
--]]
UnityEngine.KeyCode.Dollar = 36
--[[

	 Get 
--]]
UnityEngine.KeyCode.Percent = 37
--[[

	 Get 
--]]
UnityEngine.KeyCode.Ampersand = 38
--[[

	 Get 
--]]
UnityEngine.KeyCode.Quote = 39
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftParen = 40
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightParen = 41
--[[

	 Get 
--]]
UnityEngine.KeyCode.Asterisk = 42
--[[

	 Get 
--]]
UnityEngine.KeyCode.Plus = 43
--[[

	 Get 
--]]
UnityEngine.KeyCode.Comma = 44
--[[

	 Get 
--]]
UnityEngine.KeyCode.Minus = 45
--[[

	 Get 
--]]
UnityEngine.KeyCode.Period = 46
--[[

	 Get 
--]]
UnityEngine.KeyCode.Slash = 47
--[[

	 Get 
--]]
UnityEngine.KeyCode.Colon = 58
--[[

	 Get 
--]]
UnityEngine.KeyCode.Semicolon = 59
--[[

	 Get 
--]]
UnityEngine.KeyCode.Less = 60
--[[

	 Get 
--]]
UnityEngine.KeyCode.Equals = 61
--[[

	 Get 
--]]
UnityEngine.KeyCode.Greater = 62
--[[

	 Get 
--]]
UnityEngine.KeyCode.Question = 63
--[[

	 Get 
--]]
UnityEngine.KeyCode.At = 64
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftBracket = 91
--[[

	 Get 
--]]
UnityEngine.KeyCode.Backslash = 92
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightBracket = 93
--[[

	 Get 
--]]
UnityEngine.KeyCode.Caret = 94
--[[

	 Get 
--]]
UnityEngine.KeyCode.Underscore = 95
--[[

	 Get 
--]]
UnityEngine.KeyCode.BackQuote = 96
--[[

	 Get 
--]]
UnityEngine.KeyCode.A = 97
--[[

	 Get 
--]]
UnityEngine.KeyCode.B = 98
--[[

	 Get 
--]]
UnityEngine.KeyCode.C = 99
--[[

	 Get 
--]]
UnityEngine.KeyCode.D = 100
--[[

	 Get 
--]]
UnityEngine.KeyCode.E = 101
--[[

	 Get 
--]]
UnityEngine.KeyCode.F = 102
--[[

	 Get 
--]]
UnityEngine.KeyCode.G = 103
--[[

	 Get 
--]]
UnityEngine.KeyCode.H = 104
--[[

	 Get 
--]]
UnityEngine.KeyCode.I = 105
--[[

	 Get 
--]]
UnityEngine.KeyCode.J = 106
--[[

	 Get 
--]]
UnityEngine.KeyCode.K = 107
--[[

	 Get 
--]]
UnityEngine.KeyCode.L = 108
--[[

	 Get 
--]]
UnityEngine.KeyCode.M = 109
--[[

	 Get 
--]]
UnityEngine.KeyCode.N = 110
--[[

	 Get 
--]]
UnityEngine.KeyCode.O = 111
--[[

	 Get 
--]]
UnityEngine.KeyCode.P = 112
--[[

	 Get 
--]]
UnityEngine.KeyCode.Q = 113
--[[

	 Get 
--]]
UnityEngine.KeyCode.R = 114
--[[

	 Get 
--]]
UnityEngine.KeyCode.S = 115
--[[

	 Get 
--]]
UnityEngine.KeyCode.T = 116
--[[

	 Get 
--]]
UnityEngine.KeyCode.U = 117
--[[

	 Get 
--]]
UnityEngine.KeyCode.V = 118
--[[

	 Get 
--]]
UnityEngine.KeyCode.W = 119
--[[

	 Get 
--]]
UnityEngine.KeyCode.X = 120
--[[

	 Get 
--]]
UnityEngine.KeyCode.Y = 121
--[[

	 Get 
--]]
UnityEngine.KeyCode.Z = 122
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftCurlyBracket = 123
--[[

	 Get 
--]]
UnityEngine.KeyCode.Pipe = 124
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightCurlyBracket = 125
--[[

	 Get 
--]]
UnityEngine.KeyCode.Tilde = 126
--[[

	 Get 
--]]
UnityEngine.KeyCode.Numlock = 300
--[[

	 Get 
--]]
UnityEngine.KeyCode.CapsLock = 301
--[[

	 Get 
--]]
UnityEngine.KeyCode.ScrollLock = 302
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightShift = 303
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftShift = 304
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightControl = 305
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftControl = 306
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightAlt = 307
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftAlt = 308
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftCommand = 310
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftApple = 310
--[[

	 Get 
--]]
UnityEngine.KeyCode.LeftWindows = 311
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightCommand = 309
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightApple = 309
--[[

	 Get 
--]]
UnityEngine.KeyCode.RightWindows = 312
--[[

	 Get 
--]]
UnityEngine.KeyCode.AltGr = 313
--[[

	 Get 
--]]
UnityEngine.KeyCode.Help = 315
--[[

	 Get 
--]]
UnityEngine.KeyCode.Print = 316
--[[

	 Get 
--]]
UnityEngine.KeyCode.SysReq = 317
--[[

	 Get 
--]]
UnityEngine.KeyCode.Break = 318
--[[

	 Get 
--]]
UnityEngine.KeyCode.Menu = 319
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse0 = 323
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse1 = 324
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse2 = 325
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse3 = 326
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse4 = 327
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse5 = 328
--[[

	 Get 
--]]
UnityEngine.KeyCode.Mouse6 = 329
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton0 = 330
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton1 = 331
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton2 = 332
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton3 = 333
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton4 = 334
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton5 = 335
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton6 = 336
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton7 = 337
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton8 = 338
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton9 = 339
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton10 = 340
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton11 = 341
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton12 = 342
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton13 = 343
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton14 = 344
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton15 = 345
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton16 = 346
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton17 = 347
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton18 = 348
--[[

	 Get 
--]]
UnityEngine.KeyCode.JoystickButton19 = 349
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button0 = 350
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button1 = 351
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button2 = 352
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button3 = 353
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button4 = 354
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button5 = 355
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button6 = 356
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button7 = 357
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button8 = 358
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button9 = 359
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button10 = 360
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button11 = 361
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button12 = 362
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button13 = 363
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button14 = 364
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button15 = 365
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button16 = 366
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button17 = 367
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button18 = 368
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick1Button19 = 369
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button0 = 370
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button1 = 371
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button2 = 372
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button3 = 373
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button4 = 374
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button5 = 375
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button6 = 376
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button7 = 377
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button8 = 378
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button9 = 379
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button10 = 380
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button11 = 381
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button12 = 382
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button13 = 383
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button14 = 384
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button15 = 385
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button16 = 386
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button17 = 387
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button18 = 388
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick2Button19 = 389
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button0 = 390
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button1 = 391
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button2 = 392
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button3 = 393
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button4 = 394
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button5 = 395
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button6 = 396
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button7 = 397
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button8 = 398
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button9 = 399
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button10 = 400
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button11 = 401
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button12 = 402
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button13 = 403
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button14 = 404
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button15 = 405
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button16 = 406
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button17 = 407
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button18 = 408
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick3Button19 = 409
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button0 = 410
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button1 = 411
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button2 = 412
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button3 = 413
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button4 = 414
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button5 = 415
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button6 = 416
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button7 = 417
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button8 = 418
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button9 = 419
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button10 = 420
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button11 = 421
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button12 = 422
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button13 = 423
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button14 = 424
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button15 = 425
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button16 = 426
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button17 = 427
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button18 = 428
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick4Button19 = 429
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button0 = 430
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button1 = 431
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button2 = 432
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button3 = 433
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button4 = 434
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button5 = 435
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button6 = 436
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button7 = 437
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button8 = 438
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button9 = 439
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button10 = 440
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button11 = 441
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button12 = 442
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button13 = 443
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button14 = 444
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button15 = 445
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button16 = 446
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button17 = 447
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button18 = 448
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick5Button19 = 449
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button0 = 450
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button1 = 451
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button2 = 452
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button3 = 453
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button4 = 454
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button5 = 455
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button6 = 456
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button7 = 457
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button8 = 458
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button9 = 459
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button10 = 460
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button11 = 461
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button12 = 462
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button13 = 463
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button14 = 464
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button15 = 465
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button16 = 466
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button17 = 467
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button18 = 468
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick6Button19 = 469
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button0 = 470
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button1 = 471
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button2 = 472
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button3 = 473
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button4 = 474
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button5 = 475
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button6 = 476
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button7 = 477
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button8 = 478
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button9 = 479
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button10 = 480
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button11 = 481
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button12 = 482
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button13 = 483
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button14 = 484
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button15 = 485
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button16 = 486
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button17 = 487
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button18 = 488
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick7Button19 = 489
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button0 = 490
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button1 = 491
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button2 = 492
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button3 = 493
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button4 = 494
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button5 = 495
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button6 = 496
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button7 = 497
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button8 = 498
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button9 = 499
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button10 = 500
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button11 = 501
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button12 = 502
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button13 = 503
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button14 = 504
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button15 = 505
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button16 = 506
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button17 = 507
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button18 = 508
--[[

	 Get 
--]]
UnityEngine.KeyCode.Joystick8Button19 = 509

--@SuperType [luaIde#UnityEngine.Renderer]
UnityEngine.SkinnedMeshRenderer = {}
--[[
	UnityEngine.SkinQuality
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.quality = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.updateWhenOffscreen = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.forceMatrixRecalculationPerRender = nil
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.rootBone = nil
--[[
	UnityEngine.Transform{}
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.bones = nil
--[[
	UnityEngine.Mesh
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.sharedMesh = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.skinnedMotionVectors = nil
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 	 Set 
--]]
UnityEngine.SkinnedMeshRenderer.localBounds = nil
--[[
	@return [luaIde#UnityEngine.SkinnedMeshRenderer]
]]
function UnityEngine.SkinnedMeshRenderer:New() end
--[[
	@index System.Int32
	return System.Single
--]]
function UnityEngine.SkinnedMeshRenderer:GetBlendShapeWeight(index) end
--[[
	@index System.Int32
	@value System.Single
--]]
function UnityEngine.SkinnedMeshRenderer:SetBlendShapeWeight(index,value) end
--[[
	@mesh UnityEngine.Mesh
--]]
function UnityEngine.SkinnedMeshRenderer:BakeMesh(mesh) end

--UnityEngine.Space  Enum
UnityEngine.Space = {}
--[[

	 Get 
--]]
UnityEngine.Space.World = 0
--[[

	 Get 
--]]
UnityEngine.Space.Self = 1

--@SuperType [luaIde#UnityEngine.Renderer]
UnityEngine.MeshRenderer = {}
--[[
	UnityEngine.Mesh
	 Get 	 Set 
--]]
UnityEngine.MeshRenderer.additionalVertexStreams = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.MeshRenderer.subMeshStartIndex = nil
--[[
	@return [luaIde#UnityEngine.MeshRenderer]
]]
function UnityEngine.MeshRenderer:New() end

--@SuperType [luaIde#UnityEngine.Renderer]
UnityEngine.ParticleSystemRenderer = {}
--[[
	UnityEngine.Mesh
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.mesh = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.ParticleSystemRenderer.meshCount = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.ParticleSystemRenderer.activeVertexStreamsCount = nil
--[[
	UnityEngine.ParticleSystemRenderSpace
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.alignment = nil
--[[
	UnityEngine.ParticleSystemRenderMode
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.renderMode = nil
--[[
	UnityEngine.ParticleSystemSortMode
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.sortMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.lengthScale = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.velocityScale = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.cameraVelocityScale = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.normalDirection = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.shadowBias = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.sortingFudge = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.minParticleSize = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.maxParticleSize = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.pivot = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.flip = nil
--[[
	UnityEngine.SpriteMaskInteraction
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.maskInteraction = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.trailMaterial = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.enableGPUInstancing = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.ParticleSystemRenderer.allowRoll = nil
--[[
	@return [luaIde#UnityEngine.ParticleSystemRenderer]
]]
function UnityEngine.ParticleSystemRenderer:New() end
--[[
	@meshes UnityEngine.Mesh{}
	return System.Int32
--]]
function UnityEngine.ParticleSystemRenderer:GetMeshes(meshes) end
--[[
	@meshes UnityEngine.Mesh{}
--]]
function UnityEngine.ParticleSystemRenderer:SetMeshes(meshes) end
--[[
	@streams System.Collections.Generic.List`1{{UnityEngine.ParticleSystemVertexStream, UnityEngine.ParticleSystemModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.ParticleSystemRenderer:SetActiveVertexStreams(streams) end
--[[
	@streams System.Collections.Generic.List`1{{UnityEngine.ParticleSystemVertexStream, UnityEngine.ParticleSystemModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.ParticleSystemRenderer:GetActiveVertexStreams(streams) end
--[[
	@mesh UnityEngine.Mesh
	@useTransform System.Boolean
--]]
function UnityEngine.ParticleSystemRenderer:BakeMesh(mesh,useTransform) end
--[[
	@mesh UnityEngine.Mesh
	@useTransform System.Boolean
--]]
function UnityEngine.ParticleSystemRenderer:BakeTrailsMesh(mesh,useTransform) end

UnityEngine.ParticleSystem.Particle = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.position = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.velocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.ParticleSystem.Particle.animatedVelocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.ParticleSystem.Particle.totalVelocity = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.remainingLifetime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.startLifetime = nil
--[[
	UnityEngine.Color32
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.startColor = nil
--[[
	System.UInt32
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.randomSeed = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.axisOfRotation = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.startSize = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.startSize3D = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.rotation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.rotation3D = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.angularVelocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.ParticleSystem.Particle.angularVelocity3D = nil
function UnityEngine.ParticleSystem.Particle:New () end
--[[
	@system UnityEngine.ParticleSystem
	return System.Single
--]]
function UnityEngine.ParticleSystem.Particle:GetCurrentSize(system) end
--[[
	@system UnityEngine.ParticleSystem
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.ParticleSystem.Particle:GetCurrentSize3D(system) end
--[[
	@system UnityEngine.ParticleSystem
	return UnityEngine.Color32
--]]
function UnityEngine.ParticleSystem.Particle:GetCurrentColor(system) end

--@SuperType [luaIde#UnityEngine.Collider]
UnityEngine.BoxCollider = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.BoxCollider.center = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.BoxCollider.size = nil
--[[
	@return [luaIde#UnityEngine.BoxCollider]
]]
function UnityEngine.BoxCollider:New() end

--@SuperType [luaIde#UnityEngine.Collider]
UnityEngine.MeshCollider = {}
--[[
	UnityEngine.Mesh
	 Get 	 Set 
--]]
UnityEngine.MeshCollider.sharedMesh = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.MeshCollider.convex = nil
--[[
	UnityEngine.MeshColliderCookingOptions
	 Get 	 Set 
--]]
UnityEngine.MeshCollider.cookingOptions = nil
--[[
	@return [luaIde#UnityEngine.MeshCollider]
]]
function UnityEngine.MeshCollider:New() end

--@SuperType [luaIde#UnityEngine.Collider]
UnityEngine.SphereCollider = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.SphereCollider.center = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.SphereCollider.radius = nil
--[[
	@return [luaIde#UnityEngine.SphereCollider]
]]
function UnityEngine.SphereCollider:New() end

--@SuperType [luaIde#UnityEngine.Collider]
UnityEngine.CharacterController = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.CharacterController.velocity = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.CharacterController.isGrounded = nil
--[[
	UnityEngine.CollisionFlags
	 Get 
--]]
UnityEngine.CharacterController.collisionFlags = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CharacterController.radius = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CharacterController.height = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.CharacterController.center = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CharacterController.slopeLimit = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CharacterController.stepOffset = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CharacterController.skinWidth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CharacterController.minMoveDistance = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.CharacterController.detectCollisions = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.CharacterController.enableOverlapRecovery = nil
--[[
	@return [luaIde#UnityEngine.CharacterController]
]]
function UnityEngine.CharacterController:New() end
--[[
	@speed UnityEngine.Vector3
	return System.Boolean
--]]
function UnityEngine.CharacterController:SimpleMove(speed) end
--[[
	@motion UnityEngine.Vector3
	return UnityEngine.CollisionFlags
--]]
function UnityEngine.CharacterController:Move(motion) end

--@SuperType [luaIde#UnityEngine.Collider]
UnityEngine.CapsuleCollider = {}
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.CapsuleCollider.center = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CapsuleCollider.radius = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.CapsuleCollider.height = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.CapsuleCollider.direction = nil
--[[
	@return [luaIde#UnityEngine.CapsuleCollider]
]]
function UnityEngine.CapsuleCollider:New() end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.Animation = {}
--[[
	@RefType [luaIde#UnityEngine.AnimationClip]
	 Get 	 Set 
--]]
UnityEngine.Animation.clip = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animation.playAutomatically = nil
--[[
	UnityEngine.WrapMode
	 Get 	 Set 
--]]
UnityEngine.Animation.wrapMode = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Animation.isPlaying = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Animation.animatePhysics = nil
--[[
	UnityEngine.AnimationCullingType
	 Get 	 Set 
--]]
UnityEngine.Animation.cullingType = nil
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 	 Set 
--]]
UnityEngine.Animation.localBounds = nil
--[[
	@return [luaIde#UnityEngine.Animation]
]]
function UnityEngine.Animation:New() end
function UnityEngine.Animation:Stop() end
--[[
	@name System.String
--]]
function UnityEngine.Animation:Rewind(name) end
function UnityEngine.Animation:Sample() end
--[[
	@name System.String
	return System.Boolean
--]]
function UnityEngine.Animation:IsPlaying(name) end
--[[
	@name System.String
	@return [luaIde#UnityEngine.AnimationState]
--]]
function UnityEngine.Animation:get_Item(name) end
function UnityEngine.Animation:Play() end
--[[
	@animation System.String
	@fadeLength System.Single
	@mode UnityEngine.PlayMode
--]]
function UnityEngine.Animation:CrossFade(animation,fadeLength,mode) end
--[[
	@animation System.String
	@targetWeight System.Single
	@fadeLength System.Single
--]]
function UnityEngine.Animation:Blend(animation,targetWeight,fadeLength) end
--[[
	@animation System.String
	@fadeLength System.Single
	@queue UnityEngine.QueueMode
	@mode UnityEngine.PlayMode
	@return [luaIde#UnityEngine.AnimationState]
--]]
function UnityEngine.Animation:CrossFadeQueued(animation,fadeLength,queue,mode) end
--[[
	@animation System.String
	@queue UnityEngine.QueueMode
	@mode UnityEngine.PlayMode
	@return [luaIde#UnityEngine.AnimationState]
--]]
function UnityEngine.Animation:PlayQueued(animation,queue,mode) end
--[[
	@clip UnityEngine.AnimationClip
	@newName System.String
--]]
function UnityEngine.Animation:AddClip(clip,newName) end
--[[
	@clip UnityEngine.AnimationClip
--]]
function UnityEngine.Animation:RemoveClip(clip) end
function UnityEngine.Animation:GetClipCount() end
--[[
	@layer System.Int32
--]]
function UnityEngine.Animation:SyncLayer(layer) end
function UnityEngine.Animation:GetEnumerator() end
--[[
	@name System.String
	@return [luaIde#UnityEngine.AnimationClip]
--]]
function UnityEngine.Animation:GetClip(name) end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.AnimationClip = {}
--[[
	UnityEngine.AnimationEvent{}
	 Get 	 Set 
--]]
UnityEngine.AnimationClip.events = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.AnimationClip.length = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AnimationClip.frameRate = nil
--[[
	UnityEngine.WrapMode
	 Get 	 Set 
--]]
UnityEngine.AnimationClip.wrapMode = nil
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 	 Set 
--]]
UnityEngine.AnimationClip.localBounds = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AnimationClip.legacy = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AnimationClip.humanMotion = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AnimationClip.empty = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AnimationClip.hasGenericRootTransform = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AnimationClip.hasMotionFloatCurves = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AnimationClip.hasMotionCurves = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.AnimationClip.hasRootCurves = nil
--[[
	@return [luaIde#UnityEngine.AnimationClip]
]]
function UnityEngine.AnimationClip:New() end
--[[
	@evt UnityEngine.AnimationEvent
--]]
function UnityEngine.AnimationClip:AddEvent(evt) end
--[[
	@go UnityEngine.GameObject
	@time System.Single
--]]
function UnityEngine.AnimationClip:SampleAnimation(go,time) end
--[[
	@relativePath System.String
	@type System.Type
	@propertyName System.String
	@curve UnityEngine.AnimationCurve
--]]
function UnityEngine.AnimationClip:SetCurve(relativePath,type,propertyName,curve) end
function UnityEngine.AnimationClip:EnsureQuaternionContinuity() end
function UnityEngine.AnimationClip:ClearCurves() end

--@SuperType [luaIde#UnityEngine.TrackedReference]
UnityEngine.AnimationState = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.AnimationState.enabled = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AnimationState.weight = nil
--[[
	UnityEngine.WrapMode
	 Get 	 Set 
--]]
UnityEngine.AnimationState.wrapMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AnimationState.time = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AnimationState.normalizedTime = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AnimationState.speed = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.AnimationState.normalizedSpeed = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.AnimationState.length = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.AnimationState.layer = nil
--[[
	@RefType [luaIde#UnityEngine.AnimationClip]
	 Get 
--]]
UnityEngine.AnimationState.clip = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.AnimationState.name = nil
--[[
	UnityEngine.AnimationBlendMode
	 Get 	 Set 
--]]
UnityEngine.AnimationState.blendMode = nil
--[[
	@return [luaIde#UnityEngine.AnimationState]
]]
function UnityEngine.AnimationState:New() end
--[[
	@mix UnityEngine.Transform
	@recursive System.Boolean
--]]
function UnityEngine.AnimationState:AddMixingTransform(mix,recursive) end
--[[
	@mix UnityEngine.Transform
--]]
function UnityEngine.AnimationState:RemoveMixingTransform(mix) end

--UnityEngine.AnimationBlendMode  Enum
UnityEngine.AnimationBlendMode = {}
--[[

	 Get 
--]]
UnityEngine.AnimationBlendMode.Blend = 0
--[[

	 Get 
--]]
UnityEngine.AnimationBlendMode.Additive = 1

--UnityEngine.QueueMode  Enum
UnityEngine.QueueMode = {}
--[[

	 Get 
--]]
UnityEngine.QueueMode.CompleteOthers = 0
--[[

	 Get 
--]]
UnityEngine.QueueMode.PlayNow = 2

--UnityEngine.PlayMode  Enum
UnityEngine.PlayMode = {}
--[[

	 Get 
--]]
UnityEngine.PlayMode.StopSameLayer = 0
--[[

	 Get 
--]]
UnityEngine.PlayMode.StopAll = 4

--UnityEngine.WrapMode  Enum
UnityEngine.WrapMode = {}
--[[

	 Get 
--]]
UnityEngine.WrapMode.Once = 1
--[[

	 Get 
--]]
UnityEngine.WrapMode.Loop = 2
--[[

	 Get 
--]]
UnityEngine.WrapMode.PingPong = 4
--[[

	 Get 
--]]
UnityEngine.WrapMode.Default = 0
--[[

	 Get 
--]]
UnityEngine.WrapMode.ClampForever = 8
--[[

	 Get 
--]]
UnityEngine.WrapMode.Clamp = 1

QualitySettings = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.pixelLightCount = nil
--[[
	UnityEngine.ShadowQuality
	 Get 	 Set 
--]]
QualitySettings.shadows = nil
--[[
	UnityEngine.ShadowProjection
	 Get 	 Set 
--]]
QualitySettings.shadowProjection = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.shadowCascades = nil
--[[
	System.Single
	 Get 	 Set 
--]]
QualitySettings.shadowDistance = nil
--[[
	UnityEngine.ShadowResolution
	 Get 	 Set 
--]]
QualitySettings.shadowResolution = nil
--[[
	UnityEngine.ShadowmaskMode
	 Get 	 Set 
--]]
QualitySettings.shadowmaskMode = nil
--[[
	System.Single
	 Get 	 Set 
--]]
QualitySettings.shadowNearPlaneOffset = nil
--[[
	System.Single
	 Get 	 Set 
--]]
QualitySettings.shadowCascade2Split = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
QualitySettings.shadowCascade4Split = nil
--[[
	System.Single
	 Get 	 Set 
--]]
QualitySettings.lodBias = nil
--[[
	UnityEngine.AnisotropicFiltering
	 Get 	 Set 
--]]
QualitySettings.anisotropicFiltering = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.masterTextureLimit = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.maximumLODLevel = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.particleRaycastBudget = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.softParticles = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.softVegetation = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.vSyncCount = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.antiAliasing = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.asyncUploadTimeSlice = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.asyncUploadBufferSize = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.asyncUploadPersistentBuffer = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.realtimeReflectionProbes = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.billboardsFaceCameraPosition = nil
--[[
	System.Single
	 Get 	 Set 
--]]
QualitySettings.resolutionScalingFixedDPIFactor = nil
--[[
	UnityEngine.BlendWeights
	 Get 	 Set 
--]]
QualitySettings.blendWeights = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.streamingMipmapsActive = nil
--[[
	System.Single
	 Get 	 Set 
--]]
QualitySettings.streamingMipmapsMemoryBudget = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.streamingMipmapsRenderersPerFrame = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.streamingMipmapsMaxLevelReduction = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
QualitySettings.streamingMipmapsAddAllCameras = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.streamingMipmapsMaxFileIORequests = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
QualitySettings.maxQueuedFrames = nil
--[[
	System.String{}
	 Get 
--]]
QualitySettings.names = nil
--[[
	UnityEngine.ColorSpace
	 Get 
--]]
QualitySettings.desiredColorSpace = nil
--[[
	UnityEngine.ColorSpace
	 Get 
--]]
QualitySettings.activeColorSpace = nil
--[[
	@applyExpensiveChanges System.Boolean
--]]
function QualitySettings:IncreaseLevel(applyExpensiveChanges) end
--[[
	@applyExpensiveChanges System.Boolean
--]]
function QualitySettings:DecreaseLevel(applyExpensiveChanges) end
--[[
	@index System.Int32
--]]
function QualitySettings:SetQualityLevel(index) end
function QualitySettings:GetQualityLevel() end

RenderSettings = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
RenderSettings.fog = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.fogStartDistance = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.fogEndDistance = nil
--[[
	UnityEngine.FogMode
	 Get 	 Set 
--]]
RenderSettings.fogMode = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
RenderSettings.fogColor = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.fogDensity = nil
--[[
	UnityEngine.Rendering.AmbientMode
	 Get 	 Set 
--]]
RenderSettings.ambientMode = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
RenderSettings.ambientSkyColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
RenderSettings.ambientEquatorColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
RenderSettings.ambientGroundColor = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.ambientIntensity = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
RenderSettings.ambientLight = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
RenderSettings.subtractiveShadowColor = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 	 Set 
--]]
RenderSettings.skybox = nil
--[[
	@RefType [luaIde#UnityEngine.Light]
	 Get 	 Set 
--]]
RenderSettings.sun = nil
--[[
	UnityEngine.Rendering.SphericalHarmonicsL2
	 Get 	 Set 
--]]
RenderSettings.ambientProbe = nil
--[[
	UnityEngine.Cubemap
	 Get 	 Set 
--]]
RenderSettings.customReflection = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.reflectionIntensity = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
RenderSettings.reflectionBounces = nil
--[[
	UnityEngine.Rendering.DefaultReflectionMode
	 Get 	 Set 
--]]
RenderSettings.defaultReflectionMode = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
RenderSettings.defaultReflectionResolution = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.haloStrength = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.flareStrength = nil
--[[
	System.Single
	 Get 	 Set 
--]]
RenderSettings.flareFadeSpeed = nil

--UnityEngine.BlendWeights  Enum
UnityEngine.BlendWeights = {}
--[[

	 Get 
--]]
UnityEngine.BlendWeights.OneBone = 1
--[[

	 Get 
--]]
UnityEngine.BlendWeights.TwoBones = 2
--[[

	 Get 
--]]
UnityEngine.BlendWeights.FourBones = 4

--@SuperType [luaIde#UnityEngine.Texture]
UnityEngine.RenderTexture = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.width = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.height = nil
--[[
	UnityEngine.Rendering.TextureDimension
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.dimension = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.useMipMap = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.RenderTexture.sRGB = nil
--[[
	UnityEngine.RenderTextureFormat
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.format = nil
--[[
	UnityEngine.VRTextureUsage
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.vrUsage = nil
--[[
	UnityEngine.RenderTextureMemoryless
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.memorylessMode = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.autoGenerateMips = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.volumeDepth = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.antiAliasing = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.bindTextureMS = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.enableRandomWrite = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.useDynamicScale = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.isPowerOfTwo = nil
--[[
	@RefType [luaIde#UnityEngine.RenderTexture]
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.active = nil
--[[
	UnityEngine.RenderBuffer
	 Get 
--]]
UnityEngine.RenderTexture.colorBuffer = nil
--[[
	UnityEngine.RenderBuffer
	 Get 
--]]
UnityEngine.RenderTexture.depthBuffer = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.depth = nil
--[[
	UnityEngine.RenderTextureDescriptor
	 Get 	 Set 
--]]
UnityEngine.RenderTexture.descriptor = nil
--[[
	@textureToCopy UnityEngine.RenderTexture
	@return [luaIde#UnityEngine.RenderTexture]
]]
function UnityEngine.RenderTexture:New(textureToCopy) end
--[[
	@desc UnityEngine.RenderTextureDescriptor
	@return [luaIde#UnityEngine.RenderTexture]
]]
function UnityEngine.RenderTexture:New(desc) end
--[[
	@width System.Int32
	@height System.Int32
	@depth System.Int32
	@return [luaIde#UnityEngine.RenderTexture]
]]
function UnityEngine.RenderTexture:New(width,height,depth) end
--[[
	@width System.Int32
	@height System.Int32
	@depth System.Int32
	@format UnityEngine.RenderTextureFormat
	@return [luaIde#UnityEngine.RenderTexture]
]]
function UnityEngine.RenderTexture:New(width,height,depth,format) end
--[[
	@width System.Int32
	@height System.Int32
	@depth System.Int32
	@format UnityEngine.Experimental.Rendering.GraphicsFormat
	@return [luaIde#UnityEngine.RenderTexture]
]]
function UnityEngine.RenderTexture:New(width,height,depth,format) end
--[[
	@width System.Int32
	@height System.Int32
	@depth System.Int32
	@format UnityEngine.RenderTextureFormat
	@readWrite UnityEngine.RenderTextureReadWrite
	@return [luaIde#UnityEngine.RenderTexture]
]]
function UnityEngine.RenderTexture:New(width,height,depth,format,readWrite) end
function UnityEngine.RenderTexture:GetNativeDepthBufferPtr() end
--[[
	@discardColor System.Boolean
	@discardDepth System.Boolean
--]]
function UnityEngine.RenderTexture:DiscardContents(discardColor,discardDepth) end
function UnityEngine.RenderTexture:MarkRestoreExpected() end
function UnityEngine.RenderTexture:ResolveAntiAliasedSurface() end
--[[
	@propertyName System.String
--]]
function UnityEngine.RenderTexture:SetGlobalShaderProperty(propertyName) end
function UnityEngine.RenderTexture:Create() end
function UnityEngine.RenderTexture:Release() end
function UnityEngine.RenderTexture:IsCreated() end
function UnityEngine.RenderTexture:GenerateMips() end
--[[
	@equirect UnityEngine.RenderTexture
	@eye UnityEngine.Camera.MonoOrStereoscopicEye
--]]
function UnityEngine.RenderTexture:ConvertToEquirect(equirect,eye) end
--[[
	@rt UnityEngine.RenderTexture
	return System.Boolean
--]]
function UnityEngine.RenderTexture:SupportsStencil(rt) end
--[[
	@temp UnityEngine.RenderTexture
--]]
function UnityEngine.RenderTexture:ReleaseTemporary(temp) end
--[[
	@desc UnityEngine.RenderTextureDescriptor
	@return [luaIde#UnityEngine.RenderTexture]
--]]
function UnityEngine.RenderTexture:GetTemporary(desc) end

Resources = {}
--[[
	@type System.Type
	return UnityEngine.Object{}
--]]
function Resources:FindObjectsOfTypeAll(type) end
--[[
	@path System.String
	return UnityEngine.Object
--]]
function Resources:Load(path) end
--[[
	@path System.String
	return UnityEngine.ResourceRequest
--]]
function Resources:LoadAsync(path) end
--[[
	@path System.String
	@systemTypeInstance System.Type
	return UnityEngine.Object{}
--]]
function Resources:LoadAll(path,systemTypeInstance) end
--[[
	@type System.Type
	@path System.String
	return UnityEngine.Object
--]]
function Resources:GetBuiltinResource(type,path) end
--[[
	@assetToUnload UnityEngine.Object
--]]
function Resources:UnloadAsset(assetToUnload) end
function Resources:UnloadUnusedAssets() end

LuaProfiler = {}
--[[
	System.Collections.Generic.List`1{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	 Get 	 Set 
--]]
LuaProfiler.list = nil
function LuaProfiler:Clear() end
--[[
	@name System.String
	return System.Int32
--]]
function LuaProfiler:GetID(name) end
--[[
	@id System.Int32
--]]
function LuaProfiler:BeginSample(id) end
function LuaProfiler:EndSample() end

--@SuperType [luaIde#UnityEngine.UI.Selectable]
UnityEngine.UI.InputField = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.shouldHideMobileInput = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.text = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.UI.InputField.isFocused = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.caretBlinkRate = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.caretWidth = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Text]
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.textComponent = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Graphic]
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.placeholder = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.caretColor = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.customCaretColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.selectionColor = nil
--[[
	UnityEngine.UI.InputField.SubmitEvent
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.onEndEdit = nil
--[[
	UnityEngine.UI.InputField.OnChangeEvent
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.onValueChanged = nil
--[[
	UnityEngine.UI.InputField.OnValidateInput
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.onValidateInput = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.characterLimit = nil
--[[
	UnityEngine.UI.InputField.ContentType
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.contentType = nil
--[[
	UnityEngine.UI.InputField.LineType
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.lineType = nil
--[[
	UnityEngine.UI.InputField.InputType
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.inputType = nil
--[[
	UnityEngine.TouchScreenKeyboard
	 Get 
--]]
UnityEngine.UI.InputField.touchScreenKeyboard = nil
--[[
	UnityEngine.TouchScreenKeyboardType
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.keyboardType = nil
--[[
	UnityEngine.UI.InputField.CharacterValidation
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.characterValidation = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.readOnly = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.UI.InputField.multiLine = nil
--[[
	System.Char
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.asteriskChar = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.UI.InputField.wasCanceled = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.caretPosition = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.selectionAnchorPosition = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.InputField.selectionFocusPosition = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.InputField.minWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.InputField.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.InputField.flexibleWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.InputField.minHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.InputField.preferredHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.InputField.flexibleHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.InputField.layoutPriority = nil
--[[
	@shift System.Boolean
--]]
function UnityEngine.UI.InputField:MoveTextEnd(shift) end
--[[
	@shift System.Boolean
--]]
function UnityEngine.UI.InputField:MoveTextStart(shift) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.InputField:OnBeginDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.InputField:OnDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.InputField:OnEndDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.InputField:OnPointerDown(eventData) end
--[[
	@e UnityEngine.Event
--]]
function UnityEngine.UI.InputField:ProcessEvent(e) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.InputField:OnUpdateSelected(eventData) end
function UnityEngine.UI.InputField:ForceLabelUpdate() end
--[[
	@update UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.InputField:Rebuild(update) end
function UnityEngine.UI.InputField:LayoutComplete() end
function UnityEngine.UI.InputField:GraphicUpdateComplete() end
function UnityEngine.UI.InputField:ActivateInputField() end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.InputField:OnSelect(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.InputField:OnPointerClick(eventData) end
function UnityEngine.UI.InputField:DeactivateInputField() end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.InputField:OnDeselect(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.InputField:OnSubmit(eventData) end
function UnityEngine.UI.InputField:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.InputField:CalculateLayoutInputVertical() end

--@SuperType [luaIde#UnityEngine.UI.LayoutGroup]
UnityEngine.UI.GridLayoutGroup = {}
--[[
	UnityEngine.UI.GridLayoutGroup.Corner
	 Get 	 Set 
--]]
UnityEngine.UI.GridLayoutGroup.startCorner = nil
--[[
	UnityEngine.UI.GridLayoutGroup.Axis
	 Get 	 Set 
--]]
UnityEngine.UI.GridLayoutGroup.startAxis = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.GridLayoutGroup.cellSize = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.GridLayoutGroup.spacing = nil
--[[
	UnityEngine.UI.GridLayoutGroup.Constraint
	 Get 	 Set 
--]]
UnityEngine.UI.GridLayoutGroup.constraint = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.GridLayoutGroup.constraintCount = nil
function UnityEngine.UI.GridLayoutGroup:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.GridLayoutGroup:CalculateLayoutInputVertical() end
function UnityEngine.UI.GridLayoutGroup:SetLayoutHorizontal() end
function UnityEngine.UI.GridLayoutGroup:SetLayoutVertical() end

--@SuperType [luaIde#UnityEngine.UI.HorizontalOrVerticalLayoutGroup]
UnityEngine.UI.HorizontalLayoutGroup = {}
function UnityEngine.UI.HorizontalLayoutGroup:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.HorizontalLayoutGroup:CalculateLayoutInputVertical() end
function UnityEngine.UI.HorizontalLayoutGroup:SetLayoutHorizontal() end
function UnityEngine.UI.HorizontalLayoutGroup:SetLayoutVertical() end

--@SuperType [luaIde#UnityEngine.UI.Selectable]
UnityEngine.UI.Slider = {}
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.fillRect = nil
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.handleRect = nil
--[[
	UnityEngine.UI.Slider.Direction
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.direction = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.minValue = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.maxValue = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.wholeNumbers = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.value = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.normalizedValue = nil
--[[
	UnityEngine.UI.Slider.SliderEvent
	 Get 	 Set 
--]]
UnityEngine.UI.Slider.onValueChanged = nil
--[[
	@executing UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.Slider:Rebuild(executing) end
function UnityEngine.UI.Slider:LayoutComplete() end
function UnityEngine.UI.Slider:GraphicUpdateComplete() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Slider:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Slider:OnDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.AxisEventData
--]]
function UnityEngine.UI.Slider:OnMove(eventData) end
function UnityEngine.UI.Slider:FindSelectableOnLeft() end
function UnityEngine.UI.Slider:FindSelectableOnRight() end
function UnityEngine.UI.Slider:FindSelectableOnUp() end
function UnityEngine.UI.Slider:FindSelectableOnDown() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Slider:OnInitializePotentialDrag(eventData) end
--[[
	@direction UnityEngine.UI.Slider.Direction
	@includeRectLayouts System.Boolean
--]]
function UnityEngine.UI.Slider:SetDirection(direction,includeRectLayouts) end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.LayoutElement = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.ignoreLayout = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.minWidth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.minHeight = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.preferredWidth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.preferredHeight = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.flexibleWidth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.flexibleHeight = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutElement.layoutPriority = nil
function UnityEngine.UI.LayoutElement:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.LayoutElement:CalculateLayoutInputVertical() end

UnityEngine.Rect = {}
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 
--]]
UnityEngine.Rect.zero = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.x = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.y = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rect.position = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rect.center = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rect.min = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rect.max = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.width = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.height = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rect.size = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.xMin = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.yMin = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.xMax = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rect.yMax = nil
--[[
	@source UnityEngine.Rect
	@return [luaIde#UnityEngine.Rect]
]]
function UnityEngine.Rect:New(source) end
--[[
	@position UnityEngine.Vector2
	@size UnityEngine.Vector2
	@return [luaIde#UnityEngine.Rect]
]]
function UnityEngine.Rect:New(position,size) end
--[[
	@x System.Single
	@y System.Single
	@width System.Single
	@height System.Single
	@return [luaIde#UnityEngine.Rect]
]]
function UnityEngine.Rect:New(x,y,width,height) end
--[[
	@xmin System.Single
	@ymin System.Single
	@xmax System.Single
	@ymax System.Single
	@return [luaIde#UnityEngine.Rect]
--]]
function UnityEngine.Rect:MinMaxRect(xmin,ymin,xmax,ymax) end
--[[
	@x System.Single
	@y System.Single
	@width System.Single
	@height System.Single
--]]
function UnityEngine.Rect:Set(x,y,width,height) end
--[[
	@point UnityEngine.Vector2
	return System.Boolean
--]]
function UnityEngine.Rect:Contains(point) end
--[[
	@other UnityEngine.Rect
	return System.Boolean
--]]
function UnityEngine.Rect:Overlaps(other) end
--[[
	@rectangle UnityEngine.Rect
	@normalizedRectCoordinates UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rect:NormalizedToPoint(rectangle,normalizedRectCoordinates) end
--[[
	@rectangle UnityEngine.Rect
	@point UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rect:PointToNormalized(rectangle,point) end
function UnityEngine.Rect:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Rect:Equals(other) end
function UnityEngine.Rect:ToString() end

--@SuperType [luaIde#UnityEngine.Transform]
UnityEngine.RectTransform = {}
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 
--]]
UnityEngine.RectTransform.rect = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.anchorMin = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.anchorMax = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.anchoredPosition = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.sizeDelta = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.pivot = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.anchoredPosition3D = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.offsetMin = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RectTransform.offsetMax = nil
--[[
	UnityEngine.RectTransform.ReapplyDrivenProperties
	 Get 	 Set 
--]]
UnityEngine.RectTransform.reapplyDrivenProperties = nil
--[[
	@return [luaIde#UnityEngine.RectTransform]
]]
function UnityEngine.RectTransform:New() end
function UnityEngine.RectTransform:ForceUpdateRectTransforms() end
--[[
	@edge UnityEngine.RectTransform.Edge
	@inset System.Single
	@size System.Single
--]]
function UnityEngine.RectTransform:SetInsetAndSizeFromParentEdge(edge,inset,size) end
--[[
	@axis UnityEngine.RectTransform.Axis
	@size System.Single
--]]
function UnityEngine.RectTransform:SetSizeWithCurrentAnchors(axis,size) end
function UnityEngine.RectTransform:GetWorldCorners() end
function UnityEngine.RectTransform:GetLocalCorners() end

UnityEngine.Matrix4x4 = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m00 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m10 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m20 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m30 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m01 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m11 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m21 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m31 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m02 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m12 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m22 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m32 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m03 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m13 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m23 = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Matrix4x4.m33 = nil
--[[
	@RefType [luaIde#UnityEngine.Quaternion]
	 Get 
--]]
UnityEngine.Matrix4x4.rotation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector3]
	 Get 
--]]
UnityEngine.Matrix4x4.lossyScale = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Matrix4x4.isIdentity = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Matrix4x4.determinant = nil
--[[
	UnityEngine.FrustumPlanes
	 Get 
--]]
UnityEngine.Matrix4x4.decomposeProjection = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Matrix4x4.inverse = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Matrix4x4.transpose = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Matrix4x4.zero = nil
--[[
	@RefType [luaIde#UnityEngine.Matrix4x4]
	 Get 
--]]
UnityEngine.Matrix4x4.identity = nil
--[[
	@column0 UnityEngine.Vector4
	@column1 UnityEngine.Vector4
	@column2 UnityEngine.Vector4
	@column3 UnityEngine.Vector4
	@return [luaIde#UnityEngine.Matrix4x4]
]]
function UnityEngine.Matrix4x4:New(column0,column1,column2,column3) end
function UnityEngine.Matrix4x4:ValidTRS() end
--[[
	@m UnityEngine.Matrix4x4
	return System.Single
--]]
function UnityEngine.Matrix4x4:Determinant(m) end
--[[
	@pos UnityEngine.Vector3
	@q UnityEngine.Quaternion
	@s UnityEngine.Vector3
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:TRS(pos,q,s) end
--[[
	@pos UnityEngine.Vector3
	@q UnityEngine.Quaternion
	@s UnityEngine.Vector3
--]]
function UnityEngine.Matrix4x4:SetTRS(pos,q,s) end
--[[
	@m UnityEngine.Matrix4x4
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Inverse(m) end
--[[
	@m UnityEngine.Matrix4x4
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Transpose(m) end
--[[
	@left System.Single
	@right System.Single
	@bottom System.Single
	@top System.Single
	@zNear System.Single
	@zFar System.Single
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Ortho(left,right,bottom,top,zNear,zFar) end
--[[
	@fov System.Single
	@aspect System.Single
	@zNear System.Single
	@zFar System.Single
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Perspective(fov,aspect,zNear,zFar) end
--[[
	@from UnityEngine.Vector3
	@to UnityEngine.Vector3
	@up UnityEngine.Vector3
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:LookAt(from,to,up) end
--[[
	@left System.Single
	@right System.Single
	@bottom System.Single
	@top System.Single
	@zNear System.Single
	@zFar System.Single
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Frustum(left,right,bottom,top,zNear,zFar) end
--[[
	@row System.Int32
	@column System.Int32
	return System.Single
--]]
function UnityEngine.Matrix4x4:get_Item(row,column) end
--[[
	@row System.Int32
	@column System.Int32
	@value System.Single
--]]
function UnityEngine.Matrix4x4:set_Item(row,column,value) end
function UnityEngine.Matrix4x4:GetHashCode() end
--[[
	@other System.Object
	return System.Boolean
--]]
function UnityEngine.Matrix4x4:Equals(other) end
--[[
	@index System.Int32
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Matrix4x4:GetColumn(index) end
--[[
	@index System.Int32
	@return [luaIde#UnityEngine.Vector4]
--]]
function UnityEngine.Matrix4x4:GetRow(index) end
--[[
	@index System.Int32
	@column UnityEngine.Vector4
--]]
function UnityEngine.Matrix4x4:SetColumn(index,column) end
--[[
	@index System.Int32
	@row UnityEngine.Vector4
--]]
function UnityEngine.Matrix4x4:SetRow(index,row) end
--[[
	@point UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Matrix4x4:MultiplyPoint(point) end
--[[
	@point UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Matrix4x4:MultiplyPoint3x4(point) end
--[[
	@vector UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.Matrix4x4:MultiplyVector(vector) end
--[[
	@plane UnityEngine.Plane
	return UnityEngine.Plane
--]]
function UnityEngine.Matrix4x4:TransformPlane(plane) end
--[[
	@vector UnityEngine.Vector3
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Scale(vector) end
--[[
	@vector UnityEngine.Vector3
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Translate(vector) end
--[[
	@q UnityEngine.Quaternion
	@return [luaIde#UnityEngine.Matrix4x4]
--]]
function UnityEngine.Matrix4x4:Rotate(q) end
function UnityEngine.Matrix4x4:ToString() end

--@SuperType [luaIde#UnityEngine.UI.MaskableGraphic]
UnityEngine.UI.Text = {}
--[[
	UnityEngine.TextGenerator
	 Get 
--]]
UnityEngine.UI.Text.cachedTextGenerator = nil
--[[
	UnityEngine.TextGenerator
	 Get 
--]]
UnityEngine.UI.Text.cachedTextGeneratorForLayout = nil
--[[
	@RefType [luaIde#UnityEngine.Texture]
	 Get 
--]]
UnityEngine.UI.Text.mainTexture = nil
--[[
	UnityEngine.Font
	 Get 	 Set 
--]]
UnityEngine.UI.Text.font = nil
--[[
	System.String
	 Get 	 Set 
--]]
UnityEngine.UI.Text.text = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Text.supportRichText = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Text.resizeTextForBestFit = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.Text.resizeTextMinSize = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.Text.resizeTextMaxSize = nil
--[[
	UnityEngine.TextAnchor
	 Get 	 Set 
--]]
UnityEngine.UI.Text.alignment = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Text.alignByGeometry = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.Text.fontSize = nil
--[[
	UnityEngine.HorizontalWrapMode
	 Get 	 Set 
--]]
UnityEngine.UI.Text.horizontalOverflow = nil
--[[
	UnityEngine.VerticalWrapMode
	 Get 	 Set 
--]]
UnityEngine.UI.Text.verticalOverflow = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Text.lineSpacing = nil
--[[
	UnityEngine.FontStyle
	 Get 	 Set 
--]]
UnityEngine.UI.Text.fontStyle = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.pixelsPerUnit = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.minWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.flexibleWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.minHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.preferredHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.Text.flexibleHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.Text.layoutPriority = nil
function UnityEngine.UI.Text:FontTextureChanged() end
--[[
	@extents UnityEngine.Vector2
	return UnityEngine.TextGenerationSettings
--]]
function UnityEngine.UI.Text:GetGenerationSettings(extents) end
--[[
	@anchor UnityEngine.TextAnchor
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.UI.Text:GetTextAnchorPivot(anchor) end
function UnityEngine.UI.Text:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.Text:CalculateLayoutInputVertical() end

--@SuperType [luaIde#UnityEngine.Object]
UnityEngine.Sprite = {}
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 
--]]
UnityEngine.Sprite.bounds = nil
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 
--]]
UnityEngine.Sprite.rect = nil
--[[
	@RefType [luaIde#UnityEngine.Vector4]
	 Get 
--]]
UnityEngine.Sprite.border = nil
--[[
	@RefType [luaIde#UnityEngine.Texture2D]
	 Get 
--]]
UnityEngine.Sprite.texture = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Sprite.pixelsPerUnit = nil
--[[
	@RefType [luaIde#UnityEngine.Texture2D]
	 Get 
--]]
UnityEngine.Sprite.associatedAlphaSplitTexture = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Sprite.pivot = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.Sprite.packed = nil
--[[
	UnityEngine.SpritePackingMode
	 Get 
--]]
UnityEngine.Sprite.packingMode = nil
--[[
	UnityEngine.SpritePackingRotation
	 Get 
--]]
UnityEngine.Sprite.packingRotation = nil
--[[
	@RefType [luaIde#UnityEngine.Rect]
	 Get 
--]]
UnityEngine.Sprite.textureRect = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Sprite.textureRectOffset = nil
--[[
	UnityEngine.Vector2{}
	 Get 
--]]
UnityEngine.Sprite.vertices = nil
--[[
	System.UInt16{}
	 Get 
--]]
UnityEngine.Sprite.triangles = nil
--[[
	UnityEngine.Vector2{}
	 Get 
--]]
UnityEngine.Sprite.uv = nil
function UnityEngine.Sprite:GetPhysicsShapeCount() end
--[[
	@shapeIdx System.Int32
	return System.Int32
--]]
function UnityEngine.Sprite:GetPhysicsShapePointCount(shapeIdx) end
--[[
	@shapeIdx System.Int32
	@physicsShape System.Collections.Generic.List`1{{UnityEngine.Vector2, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	return System.Int32
--]]
function UnityEngine.Sprite:GetPhysicsShape(shapeIdx,physicsShape) end
--[[
	@physicsShapes System.Collections.Generic.IList`1{{UnityEngine.Vector2{}, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.Sprite:OverridePhysicsShape(physicsShapes) end
--[[
	@vertices UnityEngine.Vector2{}
	@triangles System.UInt16{}
--]]
function UnityEngine.Sprite:OverrideGeometry(vertices,triangles) end
--[[
	@texture UnityEngine.Texture2D
	@rect UnityEngine.Rect
	@pivot UnityEngine.Vector2
	@pixelsPerUnit System.Single
	@extrude System.UInt32
	@meshType UnityEngine.SpriteMeshType
	@border UnityEngine.Vector4
	@generateFallbackPhysicsShape System.Boolean
	@return [luaIde#UnityEngine.Sprite]
--]]
function UnityEngine.Sprite:Create(texture,rect,pivot,pixelsPerUnit,extrude,meshType,border,generateFallbackPhysicsShape) end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.ScrollRect = {}
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.content = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.horizontal = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.vertical = nil
--[[
	UnityEngine.UI.ScrollRect.MovementType
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.movementType = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.elasticity = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.inertia = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.decelerationRate = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.scrollSensitivity = nil
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.viewport = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Scrollbar]
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.horizontalScrollbar = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Scrollbar]
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.verticalScrollbar = nil
--[[
	UnityEngine.UI.ScrollRect.ScrollbarVisibility
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.horizontalScrollbarVisibility = nil
--[[
	UnityEngine.UI.ScrollRect.ScrollbarVisibility
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.verticalScrollbarVisibility = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.horizontalScrollbarSpacing = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.verticalScrollbarSpacing = nil
--[[
	UnityEngine.UI.ScrollRect.ScrollRectEvent
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.onValueChanged = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.velocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.normalizedPosition = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.horizontalNormalizedPosition = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.ScrollRect.verticalNormalizedPosition = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.ScrollRect.minWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.ScrollRect.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.ScrollRect.flexibleWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.ScrollRect.minHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.ScrollRect.preferredHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.ScrollRect.flexibleHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.ScrollRect.layoutPriority = nil
--[[
	@executing UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.ScrollRect:Rebuild(executing) end
function UnityEngine.UI.ScrollRect:LayoutComplete() end
function UnityEngine.UI.ScrollRect:GraphicUpdateComplete() end
function UnityEngine.UI.ScrollRect:IsActive() end
function UnityEngine.UI.ScrollRect:StopMovement() end
--[[
	@data UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.ScrollRect:OnScroll(data) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.ScrollRect:OnInitializePotentialDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.ScrollRect:OnBeginDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.ScrollRect:OnEndDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.ScrollRect:OnDrag(eventData) end
function UnityEngine.UI.ScrollRect:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.ScrollRect:CalculateLayoutInputVertical() end
function UnityEngine.UI.ScrollRect:SetLayoutHorizontal() end
function UnityEngine.UI.ScrollRect:SetLayoutVertical() end

--@SuperType [luaIde#UnityEngine.UI.Selectable]
UnityEngine.UI.Scrollbar = {}
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.Scrollbar.handleRect = nil
--[[
	UnityEngine.UI.Scrollbar.Direction
	 Get 	 Set 
--]]
UnityEngine.UI.Scrollbar.direction = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Scrollbar.value = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.Scrollbar.size = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.Scrollbar.numberOfSteps = nil
--[[
	UnityEngine.UI.Scrollbar.ScrollEvent
	 Get 	 Set 
--]]
UnityEngine.UI.Scrollbar.onValueChanged = nil
--[[
	@executing UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.Scrollbar:Rebuild(executing) end
function UnityEngine.UI.Scrollbar:LayoutComplete() end
function UnityEngine.UI.Scrollbar:GraphicUpdateComplete() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Scrollbar:OnBeginDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Scrollbar:OnDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Scrollbar:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Scrollbar:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.AxisEventData
--]]
function UnityEngine.UI.Scrollbar:OnMove(eventData) end
function UnityEngine.UI.Scrollbar:FindSelectableOnLeft() end
function UnityEngine.UI.Scrollbar:FindSelectableOnRight() end
function UnityEngine.UI.Scrollbar:FindSelectableOnUp() end
function UnityEngine.UI.Scrollbar:FindSelectableOnDown() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Scrollbar:OnInitializePotentialDrag(eventData) end
--[[
	@direction UnityEngine.UI.Scrollbar.Direction
	@includeRectLayouts System.Boolean
--]]
function UnityEngine.UI.Scrollbar:SetDirection(direction,includeRectLayouts) end

--@SuperType [luaIde#System.Object]
LuaFramework.Util = {}
--[[
	System.String
	 Get 
	取得数据存放目录
--]]
LuaFramework.Util.DataPath = nil
--[[
	System.Boolean
	 Get 
	网络可用
--]]
LuaFramework.Util.NetAvailable = nil
--[[
	System.Boolean
	 Get 
	是否是无线
--]]
LuaFramework.Util.IsWifi = nil
--[[
	@return [luaIde#LuaFramework.Util]
]]
function LuaFramework.Util:New() end
--[[
	@o System.Object
	return System.Int32
--]]
function LuaFramework.Util:Int(o) end
--[[
	@o System.Object
	return System.Single
--]]
function LuaFramework.Util:Float(o) end
--[[
	@o System.Object
	return System.Int64
--]]
function LuaFramework.Util:Long(o) end
--[[
	@min System.Int32
	@max System.Int32
	return System.Int32
--]]
function LuaFramework.Util:Random(min,max) end
--[[
	@uid System.String
	return System.String
--]]
function LuaFramework.Util:Uid(uid) end
function LuaFramework.Util:GetTime() end
--[[
	查找子对象
	@go UnityEngine.GameObject
	@subnode System.String
	@return [luaIde#UnityEngine.GameObject]
--]]
function LuaFramework.Util:Child(go,subnode) end
--[[
	取平级对象
	@go UnityEngine.GameObject
	@subnode System.String
	@return [luaIde#UnityEngine.GameObject]
--]]
function LuaFramework.Util:Peer(go,subnode) end
--[[
	计算字符串的MD5值
	@source System.String
	return System.String
--]]
function LuaFramework.Util:md5(source) end
--[[
	计算文件的MD5值
	@file System.String
	return System.String
--]]
function LuaFramework.Util:md5file(file) end
--[[
	@input System.String
	@key System.String
	return System.String
--]]
function LuaFramework.Util:HMACSHA1Encrypt(input,key) end
--[[
	清除所有子节点
	@go UnityEngine.Transform
--]]
function LuaFramework.Util:ClearChild(go) end
--[[
	清理内存
--]]
function LuaFramework.Util:ClearMemory() end
function LuaFramework.Util:GetRelativePath() end
--[[
	取得行文本
	@path System.String
	return System.String
--]]
function LuaFramework.Util:GetFileText(path) end
--[[
	应用程序内容路径
	return System.String
--]]
function LuaFramework.Util:AppContentPath() end
--[[
	@str System.String
--]]
function LuaFramework.Util:Log(str) end
--[[
	@str System.String
--]]
function LuaFramework.Util:LogWarning(str) end
--[[
	@str System.String
--]]
function LuaFramework.Util:LogError(str) end
--[[
	防止初学者不按步骤来操作
	return System.Int32
--]]
function LuaFramework.Util:CheckRuntimeFile() end
--[[
	执行Lua方法
	@module System.String
	@func System.String
	@args System.Object{}
	return System.Object{}
--]]
function LuaFramework.Util:CallMethod(module,func,args) end
--[[
	检查运行环境
	return System.Boolean
--]]
function LuaFramework.Util:CheckEnvironment() end
function LuaFramework.Util:getDeviceInfo() end
--[[
	@srcFile System.String
	@dstFile System.String
--]]
function LuaFramework.Util:CopyFile(srcFile,dstFile) end
--[[
	@srcDir System.String
	@dstDir System.String
--]]
function LuaFramework.Util:CopyDir(srcDir,dstDir) end
--[[
	@rootDir System.String
	@tagName System.String
	@channel System.String
--]]
function LuaFramework.Util:ClearPluginDir(rootDir,tagName,channel) end

--@SuperType [luaIde#System.Object]
LuaFramework.AppConst = {}
--[[
	System.Boolean
	 Get 
--]]
LuaFramework.AppConst.DebugMode = 1
--[[
	System.Boolean
	 Get 
	如果开启更新模式，前提必须启动框架自带服务器端。
	
	否则就需要自己将StreamingAssets里面的所有内容
	
	复制到自己的Webserver上面，并修改下面的WebUrl。
--]]
LuaFramework.AppConst.UpdateMode = 0
--[[
	System.Boolean
	 Get 
--]]
LuaFramework.AppConst.LuaByteMode = 0
--[[
	System.Boolean
	 Get 	 Set 
--]]
LuaFramework.AppConst.LuaBundleMode = nil
--[[
	System.Boolean
	 Get 
--]]
LuaFramework.AppConst.CheckVersionMode = 1
--[[
	System.Boolean
	 Get 
--]]
LuaFramework.AppConst.UseXTEA = 1
--[[
	System.Int32
	 Get 
--]]
LuaFramework.AppConst.PubXTEA = 123
--[[
	System.Int32
	 Get 
--]]
LuaFramework.AppConst.TimerInterval = 1
--[[
	System.Int32
	 Get 
--]]
LuaFramework.AppConst.GameFrameRate = 30
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.AppName = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.AppIcon = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.LuaTempDir = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.AppPrefix = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.ExtName = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.AssetDir = nil
--[[
	System.String
	 Get 
	测试更新地址
--]]
LuaFramework.AppConst.WebUrl = nil
--[[
	System.String
	 Get 	 Set 
--]]
LuaFramework.AppConst.UserId = nil
--[[
	System.String
	 Get 	 Set 
--]]
LuaFramework.AppConst.SocketAddress = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.AppConst.FrameworkRoot = nil
--[[
	@return [luaIde#LuaFramework.AppConst]
]]
function LuaFramework.AppConst:New() end

LuaHelper = {}
--[[
	LuaInterface.LuaFunction
	 Get 	 Set 
--]]
LuaHelper.deferredFunc = nil
--[[
	LuaInterface.LuaFunction
	 Get 	 Set 
--]]
LuaHelper.purchasingUnavailableFunc = nil
--[[
	LuaInterface.LuaFunction
	 Get 	 Set 
--]]
LuaHelper.purchaseFailedFunc = nil
--[[
	ShowFPS
	 Get 	 Set 
--]]
LuaHelper.fpsObj = nil
--[[
	@classname System.String
	return System.Type
--]]
function LuaHelper:GetType(classname) end
function LuaHelper:GetPanelManager() end
function LuaHelper:GetResManager() end
function LuaHelper:GetNetManager() end
function LuaHelper:GetSoundManager() end
function LuaHelper:GetSDKManager() end
function LuaHelper:GetGameManager() end
function LuaHelper:GetWebManager() end
function LuaHelper:GetGestureManager() end
function LuaHelper:GetLuaManager() end
--[[
	@data LuaInterface.LuaByteBuffer
	@func LuaInterface.LuaFunction
--]]
function LuaHelper:OnCallLuaFunc(data,func) end
--[[
	@data System.String
	@func LuaInterface.LuaFunction
--]]
function LuaHelper:OnJsonCallFunc(data,func) end
--[[
	@parent UnityEngine.Transform
	@table LuaInterface.LuaTable
	return LuaInterface.LuaTable
--]]
function LuaHelper:GeneratingVar(parent,table) end
--[[
	@parent UnityEngine.Transform
	@table LuaInterface.LuaTable
	return LuaInterface.LuaTable
--]]
function LuaHelper:GetComponentsInChildrenParticle(parent,table) end
--[[
	@rect UnityEngine.RectTransform
	@screenPoint UnityEngine.Vector2
	@cam UnityEngine.Camera
	return LuaInterface.LuaTable
--]]
function LuaHelper:MyScreenPointToLocalPointInRectangle(rect,screenPoint,cam) end
function LuaHelper:AddInAppPurchasing() end
--[[
	@idTable LuaInterface.LuaTable
--]]
function LuaHelper:InitInAppPurchasing(idTable) end
function LuaHelper:GetInAppPurchasing() end
--[[
	@func LuaInterface.LuaFunction
--]]
function LuaHelper:RegistluaPurchaseCallback(func) end
--[[
	@receipt System.String
	@transactionID System.String
	@definition_id System.String
--]]
function LuaHelper:OnPurchaseCallback(receipt,transactionID,definition_id) end
--[[
	@purchaseId System.String
	@func LuaInterface.LuaFunction
	return System.Boolean
--]]
function LuaHelper:OnPurchaseClicked(purchaseId,func) end
--[[
	@definition_id System.String
--]]
function LuaHelper:APPSeverConfirmPendingPurchase(definition_id) end
--[[
	@func LuaInterface.LuaFunction
--]]
function LuaHelper:AddDeferred(func) end
function LuaHelper:OnDeferred() end
--[[
	@func LuaInterface.LuaFunction
--]]
function LuaHelper:AddPurchasingUnavailable(func) end
function LuaHelper:OnPurchasingUnavailable() end
--[[
	@func LuaInterface.LuaFunction
--]]
function LuaHelper:AddPurchaseFailed(func) end
function LuaHelper:OnPurchaseFailed() end
function LuaHelper:GetRuntimePlatform() end
--[[
	@content UnityEngine.Transform
	@softArgs UnityEngine.Vector2
	@direction UnityEngine.Vector2
	@depth System.Single
	@force System.Single
--]]
function LuaHelper:SoftClipFactors(content,softArgs,direction,depth,force) end
--[[
	@ping System.Single
--]]
function LuaHelper:OnPing(ping) end

--@SuperType [luaIde#System.Object]
LuaFramework.ByteBuffer = {}
--[[
	@return [luaIde#LuaFramework.ByteBuffer]
]]
function LuaFramework.ByteBuffer:New() end
--[[
	@data System.Byte{}
	@return [luaIde#LuaFramework.ByteBuffer]
]]
function LuaFramework.ByteBuffer:New(data) end
function LuaFramework.ByteBuffer:Close() end
--[[
	@v System.Byte
--]]
function LuaFramework.ByteBuffer:WriteByte(v) end
--[[
	@v System.Int32
--]]
function LuaFramework.ByteBuffer:WriteInt(v) end
--[[
	@v System.UInt16
--]]
function LuaFramework.ByteBuffer:WriteShort(v) end
--[[
	@v System.Int64
--]]
function LuaFramework.ByteBuffer:WriteLong(v) end
--[[
	@v System.Single
--]]
function LuaFramework.ByteBuffer:WriteFloat(v) end
--[[
	@v System.Double
--]]
function LuaFramework.ByteBuffer:WriteDouble(v) end
--[[
	@v System.String
--]]
function LuaFramework.ByteBuffer:WriteString(v) end
--[[
	@v System.Byte{}
--]]
function LuaFramework.ByteBuffer:WriteBytes(v) end
--[[
	@strBuffer LuaInterface.LuaByteBuffer
--]]
function LuaFramework.ByteBuffer:WriteBuffer(strBuffer) end
function LuaFramework.ByteBuffer:ReadByte() end
function LuaFramework.ByteBuffer:ReadInt() end
function LuaFramework.ByteBuffer:ReadShort() end
function LuaFramework.ByteBuffer:ReadLong() end
function LuaFramework.ByteBuffer:ReadFloat() end
function LuaFramework.ByteBuffer:ReadDouble() end
function LuaFramework.ByteBuffer:ReadString() end
function LuaFramework.ByteBuffer:ReadBytes() end
function LuaFramework.ByteBuffer:ReadBuffer() end
function LuaFramework.ByteBuffer:ToBytes() end
function LuaFramework.ByteBuffer:Flush() end

--@SuperType [luaIde#View]
LuaFramework.LuaBehaviour = {}
--[[
	LuaInterface.LuaTable
	 Get 	 Set 
--]]
LuaFramework.LuaBehaviour.luaTable = nil
--[[
	@collision UnityEngine.Collider2D
--]]
function LuaFramework.LuaBehaviour:OnTriggerEnter2D(collision) end
--[[
	@collision UnityEngine.Collider
--]]
function LuaFramework.LuaBehaviour:OnTriggerEnter(collision) end
function LuaFramework.LuaBehaviour:GetLuaTable() end
--[[
	添加单击事件
	@go UnityEngine.GameObject
	@luafunc LuaInterface.LuaFunction
	@self LuaInterface.LuaTable
--]]
function LuaFramework.LuaBehaviour:AddClick(go,luafunc,self) end
--[[
	删除单击事件
	@go UnityEngine.GameObject
--]]
function LuaFramework.LuaBehaviour:RemoveClick(go) end
--[[
	清除单击事件
--]]
function LuaFramework.LuaBehaviour:ClearClick() end
--[[
	添加输入结束事件
	@go UnityEngine.GameObject
	@luafunc LuaInterface.LuaFunction
	@self LuaInterface.LuaTable
--]]
function LuaFramework.LuaBehaviour:AddEndEdit(go,luafunc,self) end
--[[
	删除输入结束事件
	@go UnityEngine.GameObject
--]]
function LuaFramework.LuaBehaviour:RemoveEndEdit(go) end
--[[
	清除输入结束事件
--]]
function LuaFramework.LuaBehaviour:ClearEndEdit() end

--@SuperType [luaIde#View]
LuaFramework.LuaBehaviourScroll = {}
--[[
	LuaInterface.LuaTable
	 Get 	 Set 
--]]
LuaFramework.LuaBehaviourScroll.luaTable = nil
function LuaFramework.LuaBehaviourScroll:GetLuaTable() end
--[[
	添加单击事件
	@go UnityEngine.GameObject
	@luafunc LuaInterface.LuaFunction
	@self LuaInterface.LuaTable
--]]
function LuaFramework.LuaBehaviourScroll:AddClick(go,luafunc,self) end
--[[
	删除单击事件
	@go UnityEngine.GameObject
--]]
function LuaFramework.LuaBehaviourScroll:RemoveClick(go) end
--[[
	清除单击事件
--]]
function LuaFramework.LuaBehaviourScroll:ClearClick() end
--[[
	添加输入结束事件
	@go UnityEngine.GameObject
	@luafunc LuaInterface.LuaFunction
	@self LuaInterface.LuaTable
--]]
function LuaFramework.LuaBehaviourScroll:AddEndEdit(go,luafunc,self) end
--[[
	删除输入结束事件
	@go UnityEngine.GameObject
--]]
function LuaFramework.LuaBehaviourScroll:RemoveEndEdit(go) end
--[[
	清除输入结束事件
--]]
function LuaFramework.LuaBehaviourScroll:ClearEndEdit() end

--@SuperType [luaIde#Manager]
LuaFramework.GameManager = {}
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.VERSION_MAP = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.REMOTE_VERSION_MAP = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.BASIC_IDENT = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.EXTRACT_FILE = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.TMP_EXTRACT_FILE = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.FILE_LIST = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.TMP_FILE_LIST = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.UDF_FILE = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.CINEMATIC_FILE = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.GameManager.CINEMATIC_CHANNEL = nil
function LuaFramework.GameManager:IsFirstRun() end
function LuaFramework.GameManager:GetVersionNumber() end
function LuaFramework.GameManager:GetConfigVersion() end
function LuaFramework.GameManager:ReinstallApp() end
function LuaFramework.GameManager:HasException() end
function LuaFramework.GameManager:HasUpdated() end
function LuaFramework.GameManager:NeedRestart() end
function LuaFramework.GameManager:CheckMD5() end
function LuaFramework.GameManager:UseLuaPatch() end
function LuaFramework.GameManager:GetRootURL() end
function LuaFramework.GameManager:GetAllRootURL() end
function LuaFramework.GameManager:getOverrideServerList() end
function LuaFramework.GameManager:getServerList() end
function LuaFramework.GameManager:getServerStatus() end
--[[
	@name System.String
	return System.String
--]]
function LuaFramework.GameManager:getLocalPath(name) end
function LuaFramework.GameManager:getConfigVersion() end
--[[
	@fileName System.String
	@md5 System.String&
	@size System.Int32&
	return System.Boolean
--]]
function LuaFramework.GameManager:getRemoteFileListInfo(fileName,md5,size) end
function LuaFramework.GameManager:getEmbedChannel() end
function LuaFramework.GameManager:getMarketChannel() end
function LuaFramework.GameManager:getMarketPlatform() end
function LuaFramework.GameManager:IsAndroid() end
function LuaFramework.GameManager:IsIOS() end
function LuaFramework.GameManager:HandleBtnInternetCarrierDlgOK() end
function LuaFramework.GameManager:HandleBtnInternetCarrierDlgCancel() end
function LuaFramework.GameManager:HandleBtnHintNoticeDlgOK() end
function LuaFramework.GameManager:IsCheckVersion() end
function LuaFramework.GameManager:QuitAll() end
--[[
	@gameKey System.String
	return System.Int32
--]]
function LuaFramework.GameManager:GetRemoteGameSize(gameKey) end
--[[
	@gameKey System.String
	return System.Int32
--]]
function LuaFramework.GameManager:GetLocalGameSize(gameKey) end
--[[
	@gameKey System.String
	return System.String
--]]
function LuaFramework.GameManager:CheckUpdate(gameKey) end
function LuaFramework.GameManager:GetGameStatus() end
--[[
	@gameID System.String
	@luaStateCallback LuaInterface.LuaFunction
	@luaUpdateCallback LuaInterface.LuaFunction
--]]
function LuaFramework.GameManager:DownloadUpdate(gameID,luaStateCallback,luaUpdateCallback) end
function LuaFramework.GameManager:LoadSceneStart() end
function LuaFramework.GameManager:LoadSceneFinish() end
--[[
	@version System.String
--]]
function LuaFramework.GameManager:SetForceVersion(version) end
--[[
	@version System.String
--]]
function LuaFramework.GameManager:SetForceConfig(version) end
--[[
	@udfFile System.String
	return LuaFramework.UDF
--]]
function LuaFramework.GameManager:LoadUDF(udfFile) end
function LuaFramework.GameManager:IsHangUp() end
function LuaFramework.GameManager:HandleOnBackGround() end
function LuaFramework.GameManager:HandleOnForeGround() end
function LuaFramework.GameManager:GetCityName() end
function LuaFramework.GameManager:GetLatitude() end
function LuaFramework.GameManager:GetLongitude() end
--[[
	@fileName System.String
	return System.Boolean
--]]
function LuaFramework.GameManager:CheckLuaExist(fileName) end
--[[
	@fileName System.String
	@data System.Byte{}&
	return System.Boolean
--]]
function LuaFramework.GameManager:ReadLuaPatch(fileName,data) end
--[[
	@urlFile System.String
	@localFile System.String
	@func LuaInterface.LuaFunction
--]]
function LuaFramework.GameManager:DownloadURLFile(urlFile,localFile,func) end
--[[
	@remoteFile System.String
	@md5 System.String
	@localFile System.String
	@func LuaInterface.LuaFunction
--]]
function LuaFramework.GameManager:DownloadFile(remoteFile,md5,localFile,func) end
--[[
	@remotePath System.String
	@localPath System.String
	@assetNames System.String{}
	@func LuaInterface.LuaFunction
	@percentCallback LuaInterface.LuaFunction
--]]
function LuaFramework.GameManager:DownloadFiles(remotePath,localPath,assetNames,func,percentCallback) end
--[[
	@remotePath System.String
	@localPath System.String
	@fileListName System.String
	@md5 System.String
	@percentCallback LuaInterface.LuaFunction
	@func LuaInterface.LuaFunction
--]]
function LuaFramework.GameManager:CheckFilesUpdate(remotePath,localPath,fileListName,md5,percentCallback,func) end

--@SuperType [luaIde#Manager]
LuaFramework.LuaManager = {}
function LuaFramework.LuaManager:InitStart() end
--[[
	@bundleFile System.String
--]]
function LuaFramework.LuaManager:RegisterBundle(bundleFile) end
--[[
	@filename System.String
--]]
function LuaFramework.LuaManager:DoFile(filename) end
--[[
	@fileName System.String
	return System.Boolean
--]]
function LuaFramework.LuaManager:CheckExistFile(fileName) end
--[[
	@funcName System.String
	@args System.Object{}
	return System.Object{}
--]]
function LuaFramework.LuaManager:CallFunction(funcName,args) end
function LuaFramework.LuaManager:LuaGC() end
function LuaFramework.LuaManager:Close() end

--@SuperType [luaIde#Manager]
LuaFramework.PanelManager = {}
--[[
	
	@panel_name System.String
	@func LuaInterface.LuaFunction
	@isCache System.Boolean
	@params_table LuaInterface.LuaTable创建面板是需要传递的参数
--]]
function LuaFramework.PanelManager:CreatePanel(panel_name,func,isCache,params_table) end
--[[
	关闭面板
	@name System.String
--]]
function LuaFramework.PanelManager:ClosePanel(name) end
--[[
	@x System.Int32
	@y System.Int32
	@width System.Int32
	@height System.Int32
	@path System.String
	@func LuaInterface.LuaFunction
	@isRotate System.Boolean
--]]
function LuaFramework.PanelManager:MakeCameraImgAsync(x,y,width,height,path,func,isRotate) end

--@SuperType [luaIde#Manager]
LuaFramework.SoundManager = {}
--[[
	@pattern System.String
	return System.Boolean
--]]
function LuaFramework.SoundManager:GetIsShakeOn(pattern) end
--[[
	@val System.Boolean
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetIsShakeOn(val,pattern) end
--[[
	@pattern System.String
	return System.Boolean
--]]
function LuaFramework.SoundManager:GetIsSoundOn(pattern) end
--[[
	@val System.Boolean
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetIsSoundOn(val,pattern) end
--[[
	@pattern System.String
	return System.Boolean
--]]
function LuaFramework.SoundManager:GetIsMusicOn(pattern) end
--[[
	@val System.Boolean
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetIsMusicOn(val,pattern) end
--[[
	@pattern System.String
	return System.Boolean
--]]
function LuaFramework.SoundManager:GetIsCenterOn(pattern) end
--[[
	@val System.Boolean
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetIsCenterOn(val,pattern) end
--[[
	@pattern System.String
	return System.Single
--]]
function LuaFramework.SoundManager:GetCenterVolume(pattern) end
--[[
	@value System.Single
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetCenterVolume(value,pattern) end
--[[
	@pattern System.String
	return System.Single
--]]
function LuaFramework.SoundManager:GetMusicVolume(pattern) end
--[[
	@value System.Single
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetMusicVolume(value,pattern) end
--[[
	@pattern System.String
	return System.Single
--]]
function LuaFramework.SoundManager:GetSoundVolume(pattern) end
--[[
	@value System.Single
	@pattern System.String
--]]
function LuaFramework.SoundManager:SetSoundVolume(value,pattern) end
--[[
	播放背景音
	@audioClipName System.String
	@pattern System.String
--]]
function LuaFramework.SoundManager:PlayBGM(audioClipName,pattern) end
--[[
	播放一个声音
	@audioClipName System.String
	@loopNum System.Int32
	@call LuaInterface.LuaFunction
	@pattern System.String
	return System.String
--]]
function LuaFramework.SoundManager:PlaySound(audioClipName,loopNum,call,pattern) end
--[[
	暂停音效
	@audioKey System.String
--]]
function LuaFramework.SoundManager:Pause(audioKey) end
--[[
	继续播放被暂停的音效
	@audioKey System.String
--]]
function LuaFramework.SoundManager:ContinuePlay(audioKey) end
--[[
	暂停背景音乐
--]]
function LuaFramework.SoundManager:PauseBG() end
--[[
	继续播放被暂停的背景音乐
--]]
function LuaFramework.SoundManager:ContinuePlayBG() end
--[[
	清除某个音效
	@audioKey System.String
--]]
function LuaFramework.SoundManager:CloseLoopSound(audioKey) end
--[[
	清除所有音效
--]]
function LuaFramework.SoundManager:CloseSound() end
--[[
	清除背景音
--]]
function LuaFramework.SoundManager:CloseBGMSound() end

--@SuperType [luaIde#Manager]
LuaFramework.WebManager = {}
--[[
	@value System.Boolean
--]]
function LuaFramework.WebManager:EnableWKWebView(value) end
--[[
	@url System.String
	@isHide System.Boolean
--]]
function LuaFramework.WebManager:OnShopClick(url,isHide) end
--[[
	@url System.String
--]]
function LuaFramework.WebManager:OnShopClickLoadURL(url) end

--@SuperType [luaIde#Manager]
LuaFramework.TimerManager = {}
--[[
	System.Single
	 Get 	 Set 
--]]
LuaFramework.TimerManager.Interval = nil
--[[
	�����ʱ��
	@value System.Single
--]]
function LuaFramework.TimerManager:StartTimer(value) end
--[[
	ֹͣ��ʱ��
--]]
function LuaFramework.TimerManager:StopTimer() end
--[[
	��Ӽ�ʱ���¼�
	@info LuaFramework.TimerInfo
--]]
function LuaFramework.TimerManager:AddTimerEvent(info) end
--[[
	ɾ����ʱ���¼�
	@info LuaFramework.TimerInfo
--]]
function LuaFramework.TimerManager:RemoveTimerEvent(info) end
--[[
	ֹͣ��ʱ���¼�
	@info LuaFramework.TimerInfo
--]]
function LuaFramework.TimerManager:StopTimerEvent(info) end
--[[
	������ʱ���¼�
	@info LuaFramework.TimerInfo
--]]
function LuaFramework.TimerManager:ResumeTimerEvent(info) end

--@SuperType [luaIde#Manager]
LuaFramework.ThreadManager = {}
--[[
	添加到事件队列
	@ev ThreadEvent
	@func System.Action`1{{NotiData, Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ThreadManager:AddEvent(ev,func) end

--@SuperType [luaIde#Manager]
LuaFramework.NetworkManager = {}
function LuaFramework.NetworkManager:Init() end
function LuaFramework.NetworkManager:OnInit() end
function LuaFramework.NetworkManager:Unload() end
--[[
	ִ��Lua����
	@func System.String
	@args System.Object{}
	return System.Object{}
--]]
function LuaFramework.NetworkManager:CallMethod(func,args) end
--[[
	������������
--]]
function LuaFramework.NetworkManager:SendConnect() end
--[[
	����SOCKET��Ϣ
	@buffer LuaFramework.ByteBuffer
--]]
function LuaFramework.NetworkManager:SendMessage(buffer) end
--[[
	����SOCKET��Ϣ
	
	SendMessage ����̫�࣬��ǰ�໹�̳���mono���޷�ʶ��ǰ����
	@buffer LuaInterface.LuaByteBuffer
--]]
function LuaFramework.NetworkManager:SendMessageData(buffer) end
--[[
	DestroyConnect SOCKET
--]]
function LuaFramework.NetworkManager:DestroyConnect() end
--[[
	@url System.String
	@data System.String
	@contentType System.String
	@authorization System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.NetworkManager:SendPostRequest(url,data,contentType,authorization,callback) end

--@SuperType [luaIde#Manager]
LuaFramework.ResourceManager = {}
--[[
	System.String
	 Get 
--]]
LuaFramework.ResourceManager.ASSET_TO_BUNDLE = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.ResourceManager.NAME_TO_ASSET = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.ResourceManager.SCENE_LUA_BUNDLE_NAME = nil
--[[
	System.String
	 Get 
--]]
LuaFramework.ResourceManager.DataPath = nil
--[[
	@dirName System.String
	return System.Boolean
--]]
function LuaFramework.ResourceManager:IsBasicDir(dirName) end
--[[
	@sceneName System.String
--]]
function LuaFramework.ResourceManager:LoadSceneLuaBundle(sceneName) end
--[[
	@assetName System.String
	@lifeType LuaFramework.AssetLife
--]]
function LuaFramework.ResourceManager:AddToAssetTable(assetName,lifeType) end
--[[
	@preloadList System.Collections.Generic.List`1{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}&
	@catchTable System.Collections.Generic.Dictionary`2{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089},{LuaFramework.AssetUnit, Assembly-CSharp, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}&
	return System.Boolean
--]]
function LuaFramework.ResourceManager:GetAssetTable(preloadList,catchTable) end
function LuaFramework.ResourceManager:GetAssetTableList() end
function LuaFramework.ResourceManager:GetAssetTableDict() end
--[[
	@data LuaFramework.AssetUnit
	return System.Int32
--]]
function LuaFramework.ResourceManager:GetAssetTableDictLifeType(data) end
--[[
	@data LuaFramework.AssetUnit
	@return [luaIde#UnityEngine.GameObject]
--]]
function LuaFramework.ResourceManager:GetAssetTableDictTemplete(data) end
--[[
	@objKey System.String
--]]
function LuaFramework.ResourceManager:DestroyAssetObject(objKey) end
function LuaFramework.ResourceManager:Awake() end
function LuaFramework.ResourceManager:Initialize() end
function LuaFramework.ResourceManager:SetupManifest() end
function LuaFramework.ResourceManager:UseAssetBundle() end
--[[
	@sceneName System.String
	@luaFunc LuaInterface.LuaFunction
--]]
function LuaFramework.ResourceManager:LoadSceneAsync(sceneName,luaFunc) end
--[[
	@sceneName System.String
	@luaFunc LuaInterface.LuaFunction
--]]
function LuaFramework.ResourceManager:LoadSceneSync(sceneName,luaFunc) end
--[[
	场景加载完成
	@sceneName System.String
--]]
function LuaFramework.ResourceManager:LoadSceneFinish(sceneName) end
--[[
	@sceneName System.String
	@callback System.Action`1{{System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
--]]
function LuaFramework.ResourceManager:LoadScene(sceneName,callback) end
--[[
	@sceneName System.String
	return System.String
--]]
function LuaFramework.ResourceManager:FormatSceneName(sceneName) end
--[[
	@assetName System.String
	@assetPath System.String&
	return System.Boolean
--]]
function LuaFramework.ResourceManager:FindAssetPath(assetName,assetPath) end
--[[
	@assetName System.String
	@bundleName System.String&
	return System.Boolean
--]]
function LuaFramework.ResourceManager:FindAssetBundle(assetName,bundleName) end
function LuaFramework.ResourceManager:StreamingDataPath() end
--[[
	@fileName System.String
	@return [luaIde#UnityEngine.AssetBundle]
--]]
function LuaFramework.ResourceManager:ReadBundle(fileName) end
--[[
	@bundleName System.String
	@loadDependencies System.Boolean
	@return [luaIde#UnityEngine.AssetBundle]
--]]
function LuaFramework.ResourceManager:LoadBundleSync(bundleName,loadDependencies) end
--[[
	@bundleName System.String
	@loadDependencies System.Boolean
	@return [luaIde#UnityEngine.AssetBundle]
--]]
function LuaFramework.ResourceManager:ReloadBundle(bundleName,loadDependencies) end
--[[
	@fileName System.String
	@callback System.Action`2{{System.Boolean, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089},{System.Byte{}, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089}}
	return System.Collections.IEnumerator
--]]
function LuaFramework.ResourceManager:ReadFile(fileName,callback) end
--[[
	@fileName System.String
	@data System.Byte{}
	@offset System.Int32
	@length System.Int32
--]]
function LuaFramework.ResourceManager:WriteFile(fileName,data,offset,length) end
--[[
	@assetName System.String
	@func System.Action`1{{UnityEngine.Object{}, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ResourceManager:LoadPrefab(assetName,func) end
--[[
	@assetNames System.String{}
	return System.Collections.Generic.List`1{{UnityEngine.GameObject, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ResourceManager:GetPrefabsSync(assetNames) end
--[[
	@assetName System.String
	@return [luaIde#UnityEngine.GameObject]
--]]
function LuaFramework.ResourceManager:GetPrefabSync(assetName) end
--[[
	@assetNames System.String{}
	return System.Collections.Generic.List`1{{UnityEngine.Sprite, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ResourceManager:GetTexturesSync(assetNames) end
--[[
	@assetName System.String
	@return [luaIde#UnityEngine.Sprite]
--]]
function LuaFramework.ResourceManager:GetTextureSync(assetName) end
--[[
	@width System.Int32
	@height System.Int32
	@format System.Int32
	@return [luaIde#UnityEngine.Texture2D]
--]]
function LuaFramework.ResourceManager:CreateTexture2D(width,height,format) end
--[[
	@assetNames System.String{}
	return System.Collections.Generic.List`1{{UnityEngine.Texture, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ResourceManager:Get3DTexturesSync(assetNames) end
--[[
	@assetName System.String
	@return [luaIde#UnityEngine.Texture]
--]]
function LuaFramework.ResourceManager:Get3DTextureSync(assetName) end
--[[
	@spriteName System.String
	@saveName System.String
	return System.Boolean
--]]
function LuaFramework.ResourceManager:ExtractSprite(spriteName,saveName) end
--[[
	@textureName System.String
	@saveName System.String
	return System.Boolean
--]]
function LuaFramework.ResourceManager:ExtractTexture(textureName,saveName) end
--[[
	@assetName System.String
	@return [luaIde#UnityEngine.Material]
--]]
function LuaFramework.ResourceManager:GetMaterial(assetName) end
--[[
	@assetNames System.String{}
	return System.Collections.Generic.List`1{{UnityEngine.AudioClip, UnityEngine.AudioModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ResourceManager:GetAudiosSync(assetNames) end
--[[
	@assetName System.String
	@return [luaIde#UnityEngine.AudioClip]
--]]
function LuaFramework.ResourceManager:GetAudioSync(assetName) end
--[[
	@assetNames System.String{}
	return System.Collections.Generic.List`1{{UnityEngine.Font, UnityEngine.TextRenderingModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function LuaFramework.ResourceManager:GetFontsSync(assetNames) end
--[[
	@assetName System.String
	return UnityEngine.Font
--]]
function LuaFramework.ResourceManager:GetFontSync(assetName) end
--[[
	@assetNames System.String{}
	@func LuaInterface.LuaFunction
--]]
function LuaFramework.ResourceManager:LoadTextture(assetNames,func) end
--[[
	@assetName System.String
	@func LuaInterface.LuaFunction
	return System.String
--]]
function LuaFramework.ResourceManager:LoadText(assetName,func) end
--[[
	@func LuaInterface.LuaFunction
--]]
function LuaFramework.ResourceManager:LoadSProtoStr2(func) end
--[[
	@func LuaInterface.LuaFunction
--]]
function LuaFramework.ResourceManager:LoadSProtoStr(func) end
--[[
	@poolName System.String
	@size System.Int32
	@type SG.PoolInflationType
--]]
function LuaFramework.ResourceManager:InitPool(poolName,size,type) end
--[[
	@poolName System.String
	@autoActive System.Boolean
	@autoCreate System.Int32
	@return [luaIde#UnityEngine.GameObject]
--]]
function LuaFramework.ResourceManager:GetObjectFromPool(poolName,autoActive,autoCreate) end
--[[
	Return obj to the pool
	@go UnityEngine.GameObject
--]]
function LuaFramework.ResourceManager:ReturnObjectToPool(go) end
--[[
	Return obj to the pool
	@t UnityEngine.Transform
--]]
function LuaFramework.ResourceManager:ReturnTransformToPool(t) end

--@SuperType [luaIde#Manager]
LuaFramework.SDKManager = {}
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:Init(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:Login(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:LoginOut(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:Relogin(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:Pay(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:PostPay(json_data,callback) end
--[[
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:SetPayCallback(callback) end
--[[
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:SetPostPayCallback(callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:Share(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:ShowAccountCenter(json_data,callback) end
--[[
	@json_data System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:SetupAD(json_data,callback) end
--[[
	@codeID System.String
	@rewardName System.String
	@rewardAmount System.Int32
	@userID System.String
	@extraData System.String
	@width System.Int32
	@height System.Int32
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:PrepareAD(codeID,rewardName,rewardAmount,userID,extraData,width,height,callback) end
--[[
	@codeID System.String
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:PlayAD(codeID,callback) end
--[[
	@RewardVideoAdListener LuaInterface.LuaFunction
	@OnError LuaInterface.LuaFunction
	@OnRewardVideoAdLoad LuaInterface.LuaFunction
	@OnRewardVideoCached LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:AddRewardVideoAdListener(RewardVideoAdListener,OnError,OnRewardVideoAdLoad,OnRewardVideoCached) end
--[[
	@RewardAdInteractionListener LuaInterface.LuaFunction
	@OnAdShowCallback LuaInterface.LuaFunction
	@OnAdVideoBarClickCallback LuaInterface.LuaFunction
	@OnAdCloseCallback LuaInterface.LuaFunction
	@OnVideoCompleteCallback LuaInterface.LuaFunction
	@OnVideoErrorCallback LuaInterface.LuaFunction
	@OnRewardVerifyCallback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:AddRewardAdInteractionListener(RewardAdInteractionListener,OnAdShowCallback,OnAdVideoBarClickCallback,OnAdCloseCallback,OnVideoCompleteCallback,OnVideoErrorCallback,OnRewardVerifyCallback) end
function LuaFramework.SDKManager:RemoveRewardVideoAdListener() end
function LuaFramework.SDKManager:RemoveRewardAdInteractionListener() end
--[[
	@codeID System.String
--]]
function LuaFramework.SDKManager:ClearAD(codeID) end
function LuaFramework.SDKManager:ClearAllAD() end
--[[
	@cityName System.String
--]]
function LuaFramework.SDKManager:OnUpdCityName(cityName) end
--[[
	@detail System.String
--]]
function LuaFramework.SDKManager:OnGPS(detail) end
function LuaFramework.SDKManager:GetLatitude() end
function LuaFramework.SDKManager:GetLongitude() end
function LuaFramework.SDKManager:GetLocation() end
--[[
	@fileName System.String
--]]
function LuaFramework.SDKManager:OnRecord(fileName) end
--[[
	@fileName System.String
--]]
function LuaFramework.SDKManager:OnPlayRecordFinish(fileName) end
function LuaFramework.SDKManager:GetDeviceID() end
function LuaFramework.SDKManager:GetDeeplink() end
function LuaFramework.SDKManager:GetPushDeviceToken() end
--[[
	@tt System.Int64
--]]
function LuaFramework.SDKManager:RunVibrator(tt) end
--[[
	@val System.String
--]]
function LuaFramework.SDKManager:CallUp(val) end
--[[
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:StartGPS(callback) end
--[[
	@latitude System.Single
	@longitude System.Single
--]]
function LuaFramework.SDKManager:QueryCityName(latitude,longitude) end
--[[
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.SDKManager:QueryGPS(callback) end
function LuaFramework.SDKManager:GetRecordTime() end
--[[
	@fileName System.String
	@callback LuaInterface.LuaFunction
	return System.Int32
--]]
function LuaFramework.SDKManager:StartRecord(fileName,callback) end
--[[
	@callback System.Boolean
--]]
function LuaFramework.SDKManager:StopRecord(callback) end
--[[
	@fileName System.String
	@callback LuaInterface.LuaFunction
	return System.Int32
--]]
function LuaFramework.SDKManager:PlayRecord(fileName,callback) end
function LuaFramework.SDKManager:StopPlayRecord() end
--[[
	@forceWeb System.Boolean
--]]
function LuaFramework.SDKManager:ShowProductRate(forceWeb) end
function LuaFramework.SDKManager:GetCanLocation() end
function LuaFramework.SDKManager:GetCanVoice() end
--[[
	@deep System.Boolean
	return System.Int32
--]]
function LuaFramework.SDKManager:GetCanCamera(deep) end
function LuaFramework.SDKManager:GetCanPushNotification() end
function LuaFramework.SDKManager:OpenLocation() end
function LuaFramework.SDKManager:OpenVoice() end
function LuaFramework.SDKManager:OpenCamera() end
--[[
	@mode System.String
--]]
function LuaFramework.SDKManager:GotoSetScene(mode) end
--[[
	@fileName System.String
	return System.Byte{}
--]]
function LuaFramework.SDKManager:LoadFile(fileName) end
function LuaFramework.SDKManager:ForceQuit() end

--@SuperType [luaIde#Manager]
LuaFramework.GestureManager = {}
--[[
	@ident System.String
--]]
function LuaFramework.GestureManager:TryAddGesture(ident) end

--@SuperType [luaIde#System.Object]
UniClipboard = {}
--[[
	@return [luaIde#UniClipboard]
]]
function UniClipboard:New() end
--[[
	@str System.String
--]]
function UniClipboard:SetText(str) end
function UniClipboard:GetText() end

--@SuperType [luaIde#System.Object]
AppDefine = {}
--[[
	System.String
	 Get 	 Set 
--]]
AppDefine.m_CurrentProjectPath = nil
--[[
	System.String
	 Get 	 Set 
	平台路径
--]]
AppDefine.PlatformPath = nil
--[[
	System.String
	 Get 	 Set 
	当前项目名
--]]
AppDefine.CurrentProjectPath = nil
--[[
	System.String
	 Get 
	本地数据根目录
--]]
AppDefine.LOCAL_DATA_PATH = nil
--[[
	System.Boolean
	 Get 	 Set 
	AssetBundle模式
--]]
AppDefine.IsLuaBundleMode = nil
--[[
	System.Boolean
	 Get 	 Set 
	AssetBundle模式
--]]
AppDefine.IsDebug = nil
--[[
	System.String
	 Get 	 Set 
	当前渠道
--]]
AppDefine.CurQuDao = nil
--[[
	System.String
	 Get 	 Set 
--]]
AppDefine.CurEmbed = nil
--[[
	@return [luaIde#AppDefine]
]]
function AppDefine:New() end
function AppDefine:IsEDITOR() end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
LuaFramework.ScannerQRCode = {}
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 	 Set 
--]]
LuaFramework.ScannerQRCode.rootNode = nil
--[[
	UnityEngine.UI.RawImage
	 Get 	 Set 
--]]
LuaFramework.ScannerQRCode.rawImage = nil
--[[
	@callback LuaInterface.LuaFunction
	return System.Boolean
--]]
function LuaFramework.ScannerQRCode:StartScan(callback) end
--[[
	@callback LuaInterface.LuaFunction
--]]
function LuaFramework.ScannerQRCode:StopScan(callback) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
UI2DSpriteAnimation = {}
--[[
	System.Int32
	 Get 	 Set 
	Index of the current frame in the sprite animation.
--]]
UI2DSpriteAnimation.frameIndex = nil
--[[
	System.Int32
	 Get 	 Set 
	How many frames there are in the animation per second.
--]]
UI2DSpriteAnimation.framerate = nil
--[[
	System.Boolean
	 Get 	 Set 
	Should this animation be affected by time scale?
--]]
UI2DSpriteAnimation.ignoreTimeScale = nil
--[[
	System.Boolean
	 Get 	 Set 
	Should this animation be looped?
--]]
UI2DSpriteAnimation.loop = nil
--[[
	UnityEngine.Sprite{}
	 Get 	 Set 
	Actual sprites used for the animation.
--]]
UI2DSpriteAnimation.frames = nil
--[[
	LuaInterface.LuaFunction
	 Get 	 Set 
--]]
UI2DSpriteAnimation.aniPlayEndfun = nil
--[[
	System.Boolean
	 Get 
	Returns is the animation is still playing or not
--]]
UI2DSpriteAnimation.isPlaying = nil
--[[
	System.Int32
	 Get 	 Set 
	Animation framerate.
--]]
UI2DSpriteAnimation.framesPerSecond = nil
--[[
	Continue playing the animation. If the animation has reached the end, it will restart from beginning
	@endFun LuaInterface.LuaFunction
	@startFun LuaInterface.LuaFunction
--]]
function UI2DSpriteAnimation:Play(endFun,startFun) end
--[[
	Pause the animation.
	@fun LuaInterface.LuaFunction
--]]
function UI2DSpriteAnimation:Pause(fun) end
--[[
	Reset the animation to the beginning.
	@fun LuaInterface.LuaFunction
--]]
function UI2DSpriteAnimation:ResetToBeginning(fun) end
--[[
	Wrap the index using repeating logic, so that for example +1 past the end means index of '1'.
	@val System.Int32
	@max System.Int32
	return System.Int32
--]]
function UI2DSpriteAnimation:RepeatIndex(val,max) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
UI2DImageAnimation = {}
--[[
	System.Int32
	 Get 	 Set 
	Index of the current frame in the sprite animation.
--]]
UI2DImageAnimation.frameIndex = nil
--[[
	System.Int32
	 Get 	 Set 
	How many frames there are in the animation per second.
--]]
UI2DImageAnimation.framerate = nil
--[[
	System.Boolean
	 Get 	 Set 
	Should this animation be affected by time scale?
--]]
UI2DImageAnimation.ignoreTimeScale = nil
--[[
	System.Boolean
	 Get 	 Set 
	Should this animation be looped?
--]]
UI2DImageAnimation.loop = nil
--[[
	UnityEngine.Sprite{}
	 Get 	 Set 
	Actual sprites used for the animation.
--]]
UI2DImageAnimation.bgFrames = nil
--[[
	UnityEngine.Sprite{}
	 Get 	 Set 
--]]
UI2DImageAnimation.fgFrames = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Image]
	 Get 	 Set 
--]]
UI2DImageAnimation.bgImage = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Image]
	 Get 	 Set 
--]]
UI2DImageAnimation.fgImage = nil
--[[
	LuaInterface.LuaFunction
	 Get 	 Set 
--]]
UI2DImageAnimation.aniPlayEndfun = nil
--[[
	System.Boolean
	 Get 
	Returns is the animation is still playing or not
--]]
UI2DImageAnimation.isPlaying = nil
--[[
	System.Int32
	 Get 	 Set 
	Animation framerate.
--]]
UI2DImageAnimation.framesPerSecond = nil
--[[
	@idx System.Int32
	@sprite UnityEngine.Sprite
--]]
function UI2DImageAnimation:SetBGFrame(idx,sprite) end
--[[
	@idx System.Int32
	@sprite UnityEngine.Sprite
--]]
function UI2DImageAnimation:SetFGFrame(idx,sprite) end
--[[
	Continue playing the animation. If the animation has reached the end, it will restart from beginning
	@endFun LuaInterface.LuaFunction
	@startFun LuaInterface.LuaFunction
--]]
function UI2DImageAnimation:Play(endFun,startFun) end
--[[
	Pause the animation.
	@fun LuaInterface.LuaFunction
--]]
function UI2DImageAnimation:Pause(fun) end
--[[
	Reset the animation to the beginning.
	@fun LuaInterface.LuaFunction
--]]
function UI2DImageAnimation:ResetToBeginning(fun) end
--[[
	Wrap the index using repeating logic, so that for example +1 past the end means index of '1'.
	@val System.Int32
	@max System.Int32
	return System.Int32
--]]
function UI2DImageAnimation:RepeatIndex(val,max) end

--@SuperType [luaIde#System.Object]
UnityEngine.PlayerPrefs = {}
--[[
	@return [luaIde#UnityEngine.PlayerPrefs]
]]
function UnityEngine.PlayerPrefs:New() end
--[[
	@key System.String
	@value System.Int32
--]]
function UnityEngine.PlayerPrefs:SetInt(key,value) end
--[[
	@key System.String
	@defaultValue System.Int32
	return System.Int32
--]]
function UnityEngine.PlayerPrefs:GetInt(key,defaultValue) end
--[[
	@key System.String
	@value System.Single
--]]
function UnityEngine.PlayerPrefs:SetFloat(key,value) end
--[[
	@key System.String
	@defaultValue System.Single
	return System.Single
--]]
function UnityEngine.PlayerPrefs:GetFloat(key,defaultValue) end
--[[
	@key System.String
	@value System.String
--]]
function UnityEngine.PlayerPrefs:SetString(key,value) end
--[[
	@key System.String
	@defaultValue System.String
	return System.String
--]]
function UnityEngine.PlayerPrefs:GetString(key,defaultValue) end
--[[
	@key System.String
	return System.Boolean
--]]
function UnityEngine.PlayerPrefs:HasKey(key) end
--[[
	@key System.String
--]]
function UnityEngine.PlayerPrefs:DeleteKey(key) end
function UnityEngine.PlayerPrefs:DeleteAll() end
function UnityEngine.PlayerPrefs:Save() end

--@SuperType [luaIde#UnityEngine.EventSystems.EventTrigger]
EventTriggerListener = {}
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onClick = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onDown = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onEnter = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onExit = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onUp = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onSelect = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onUpdateSelect = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onBeginDrag = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onEndDrag = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onDrag = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onPointerEnter = nil
--[[
	EventTriggerListener.VoidDelegate
	 Get 	 Set 
--]]
EventTriggerListener.onScroll = nil
--[[
	@go UnityEngine.GameObject
	@return [luaIde#EventTriggerListener]
--]]
function EventTriggerListener:Get(go) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnPointerEnter(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnPointerExit(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function EventTriggerListener:OnSelect(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function EventTriggerListener:OnUpdateSelected(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnBeginDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnEndDrag(eventData) end
--[[
	@data UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnDrag(data) end
--[[
	@data UnityEngine.EventSystems.PointerEventData
--]]
function EventTriggerListener:OnScroll(data) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
PointerEventListener = {}
--[[
	PointerEventListener.VoidDelegate
	 Get 	 Set 
--]]
PointerEventListener.onClick = nil
--[[
	PointerEventListener.VoidDelegate
	 Get 	 Set 
--]]
PointerEventListener.onDown = nil
--[[
	PointerEventListener.VoidDelegate
	 Get 	 Set 
--]]
PointerEventListener.onEnter = nil
--[[
	PointerEventListener.VoidDelegate
	 Get 	 Set 
--]]
PointerEventListener.onExit = nil
--[[
	PointerEventListener.VoidDelegate
	 Get 	 Set 
--]]
PointerEventListener.onUp = nil
--[[
	@go UnityEngine.GameObject
	@return [luaIde#PointerEventListener]
--]]
function PointerEventListener:Get(go) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PointerEventListener:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PointerEventListener:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PointerEventListener:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PointerEventListener:OnPointerEnter(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function PointerEventListener:OnPointerExit(eventData) end

--UnityEngine.TextAnchor  Enum
UnityEngine.TextAnchor = {}
--[[

	 Get 
--]]
UnityEngine.TextAnchor.UpperLeft = 0
--[[

	 Get 
--]]
UnityEngine.TextAnchor.UpperCenter = 1
--[[

	 Get 
--]]
UnityEngine.TextAnchor.UpperRight = 2
--[[

	 Get 
--]]
UnityEngine.TextAnchor.MiddleLeft = 3
--[[

	 Get 
--]]
UnityEngine.TextAnchor.MiddleCenter = 4
--[[

	 Get 
--]]
UnityEngine.TextAnchor.MiddleRight = 5
--[[

	 Get 
--]]
UnityEngine.TextAnchor.LowerLeft = 6
--[[

	 Get 
--]]
UnityEngine.TextAnchor.LowerCenter = 7
--[[

	 Get 
--]]
UnityEngine.TextAnchor.LowerRight = 8

--@SuperType [luaIde#UnityEngine.UI.Selectable]
UnityEngine.UI.Toggle = {}
--[[
	UnityEngine.UI.Toggle.ToggleTransition
	 Get 	 Set 
--]]
UnityEngine.UI.Toggle.toggleTransition = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Graphic]
	 Get 	 Set 
--]]
UnityEngine.UI.Toggle.graphic = nil
--[[
	UnityEngine.UI.Toggle.ToggleEvent
	 Get 	 Set 
--]]
UnityEngine.UI.Toggle.onValueChanged = nil
--[[
	@RefType [luaIde#UnityEngine.UI.ToggleGroup]
	 Get 	 Set 
--]]
UnityEngine.UI.Toggle.group = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Toggle.isOn = nil
--[[
	@executing UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.Toggle:Rebuild(executing) end
function UnityEngine.UI.Toggle:LayoutComplete() end
function UnityEngine.UI.Toggle:GraphicUpdateComplete() end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Toggle:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.Toggle:OnSubmit(eventData) end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.ToggleGroup = {}
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.ToggleGroup.allowSwitchOff = nil
--[[
	@toggle UnityEngine.UI.Toggle
--]]
function UnityEngine.UI.ToggleGroup:NotifyToggleOn(toggle) end
--[[
	@toggle UnityEngine.UI.Toggle
--]]
function UnityEngine.UI.ToggleGroup:UnregisterToggle(toggle) end
--[[
	@toggle UnityEngine.UI.Toggle
--]]
function UnityEngine.UI.ToggleGroup:RegisterToggle(toggle) end
function UnityEngine.UI.ToggleGroup:AnyTogglesOn() end
function UnityEngine.UI.ToggleGroup:ActiveToggles() end
function UnityEngine.UI.ToggleGroup:SetAllTogglesOff() end

--@SuperType [luaIde#System.Object]
UnityEngine.RectTransformUtility = {}
--[[
	@rect UnityEngine.RectTransform
	@screenPoint UnityEngine.Vector2
	return System.Boolean
--]]
function UnityEngine.RectTransformUtility:RectangleContainsScreenPoint(rect,screenPoint) end
--[[
	@rect UnityEngine.RectTransform
	@screenPoint UnityEngine.Vector2
	@cam UnityEngine.Camera
	@worldPoint UnityEngine.Vector3&
	return System.Boolean
--]]
function UnityEngine.RectTransformUtility:ScreenPointToWorldPointInRectangle(rect,screenPoint,cam,worldPoint) end
--[[
	@rect UnityEngine.RectTransform
	@screenPoint UnityEngine.Vector2
	@cam UnityEngine.Camera
	@localPoint UnityEngine.Vector2&
	return System.Boolean
--]]
function UnityEngine.RectTransformUtility:ScreenPointToLocalPointInRectangle(rect,screenPoint,cam,localPoint) end
--[[
	@cam UnityEngine.Camera
	@screenPos UnityEngine.Vector2
	@return [luaIde#UnityEngine.Ray]
--]]
function UnityEngine.RectTransformUtility:ScreenPointToRay(cam,screenPos) end
--[[
	@cam UnityEngine.Camera
	@worldPoint UnityEngine.Vector3
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.RectTransformUtility:WorldToScreenPoint(cam,worldPoint) end
--[[
	@root UnityEngine.Transform
	@child UnityEngine.Transform
	@return [luaIde#UnityEngine.Bounds]
--]]
function UnityEngine.RectTransformUtility:CalculateRelativeRectTransformBounds(root,child) end
--[[
	@rect UnityEngine.RectTransform
	@axis System.Int32
	@keepPositioning System.Boolean
	@recursive System.Boolean
--]]
function UnityEngine.RectTransformUtility:FlipLayoutOnAxis(rect,axis,keepPositioning,recursive) end
--[[
	@rect UnityEngine.RectTransform
	@keepPositioning System.Boolean
	@recursive System.Boolean
--]]
function UnityEngine.RectTransformUtility:FlipLayoutAxes(rect,keepPositioning,recursive) end
--[[
	@point UnityEngine.Vector2
	@elementTransform UnityEngine.Transform
	@canvas UnityEngine.Canvas
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.RectTransformUtility:PixelAdjustPoint(point,elementTransform,canvas) end
--[[
	@rectTransform UnityEngine.RectTransform
	@canvas UnityEngine.Canvas
	@return [luaIde#UnityEngine.Rect]
--]]
function UnityEngine.RectTransformUtility:PixelAdjustRect(rectTransform,canvas) end

--@SuperType [luaIde#UnityEngine.UI.Shadow]
UnityEngine.UI.Outline = {}
--[[
	@vh UnityEngine.UI.VertexHelper
--]]
function UnityEngine.UI.Outline:ModifyMesh(vh) end

--@SuperType [luaIde#System.Object]
UnityEngine.UI.LayoutRebuilder = {}
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 
--]]
UnityEngine.UI.LayoutRebuilder.transform = nil
--[[
	@return [luaIde#UnityEngine.UI.LayoutRebuilder]
]]
function UnityEngine.UI.LayoutRebuilder:New() end
function UnityEngine.UI.LayoutRebuilder:IsDestroyed() end
--[[
	@layoutRoot UnityEngine.RectTransform
--]]
function UnityEngine.UI.LayoutRebuilder:ForceRebuildLayoutImmediate(layoutRoot) end
--[[
	@executing UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.LayoutRebuilder:Rebuild(executing) end
--[[
	@rect UnityEngine.RectTransform
--]]
function UnityEngine.UI.LayoutRebuilder:MarkLayoutForRebuild(rect) end
function UnityEngine.UI.LayoutRebuilder:LayoutComplete() end
function UnityEngine.UI.LayoutRebuilder:GraphicUpdateComplete() end
function UnityEngine.UI.LayoutRebuilder:GetHashCode() end
--[[
	@obj System.Object
	return System.Boolean
--]]
function UnityEngine.UI.LayoutRebuilder:Equals(obj) end
function UnityEngine.UI.LayoutRebuilder:ToString() end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.Collider2D = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Collider2D.density = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Collider2D.isTrigger = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Collider2D.usedByEffector = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Collider2D.usedByComposite = nil
--[[
	UnityEngine.CompositeCollider2D
	 Get 
--]]
UnityEngine.Collider2D.composite = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Collider2D.offset = nil
--[[
	@RefType [luaIde#UnityEngine.Rigidbody2D]
	 Get 
--]]
UnityEngine.Collider2D.attachedRigidbody = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Collider2D.shapeCount = nil
--[[
	@RefType [luaIde#UnityEngine.Bounds]
	 Get 
--]]
UnityEngine.Collider2D.bounds = nil
--[[
	UnityEngine.PhysicsMaterial2D
	 Get 	 Set 
--]]
UnityEngine.Collider2D.sharedMaterial = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Collider2D.friction = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.Collider2D.bounciness = nil
--[[
	@return [luaIde#UnityEngine.Collider2D]
]]
function UnityEngine.Collider2D:New() end
--[[
	@collider UnityEngine.Collider2D
	return System.Boolean
--]]
function UnityEngine.Collider2D:IsTouching(collider) end
function UnityEngine.Collider2D:IsTouchingLayers() end
--[[
	@point UnityEngine.Vector2
	return System.Boolean
--]]
function UnityEngine.Collider2D:OverlapPoint(point) end
--[[
	@collider UnityEngine.Collider2D
	return UnityEngine.ColliderDistance2D
--]]
function UnityEngine.Collider2D:Distance(collider) end
--[[
	@contactFilter UnityEngine.ContactFilter2D
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Collider2D:OverlapCollider(contactFilter,results) end
--[[
	@contacts UnityEngine.ContactPoint2D{}
	return System.Int32
--]]
function UnityEngine.Collider2D:GetContacts(contacts) end
--[[
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Collider2D:Cast(direction,results) end
--[[
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Collider2D:Raycast(direction,results) end

--@SuperType [luaIde#UnityEngine.Component]
UnityEngine.Rigidbody2D = {}
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.position = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.rotation = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.velocity = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.angularVelocity = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.useAutoMass = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.mass = nil
--[[
	UnityEngine.PhysicsMaterial2D
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.sharedMaterial = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.centerOfMass = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 
--]]
UnityEngine.Rigidbody2D.worldCenterOfMass = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.inertia = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.drag = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.angularDrag = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.gravityScale = nil
--[[
	UnityEngine.RigidbodyType2D
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.bodyType = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.useFullKinematicContacts = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.isKinematic = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.freezeRotation = nil
--[[
	UnityEngine.RigidbodyConstraints2D
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.constraints = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.simulated = nil
--[[
	UnityEngine.RigidbodyInterpolation2D
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.interpolation = nil
--[[
	UnityEngine.RigidbodySleepMode2D
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.sleepMode = nil
--[[
	UnityEngine.CollisionDetectionMode2D
	 Get 	 Set 
--]]
UnityEngine.Rigidbody2D.collisionDetectionMode = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Rigidbody2D.attachedColliderCount = nil
--[[
	@return [luaIde#UnityEngine.Rigidbody2D]
]]
function UnityEngine.Rigidbody2D:New() end
--[[
	@position UnityEngine.Vector2
--]]
function UnityEngine.Rigidbody2D:MovePosition(position) end
--[[
	@angle System.Single
--]]
function UnityEngine.Rigidbody2D:MoveRotation(angle) end
function UnityEngine.Rigidbody2D:IsSleeping() end
function UnityEngine.Rigidbody2D:IsAwake() end
function UnityEngine.Rigidbody2D:Sleep() end
function UnityEngine.Rigidbody2D:WakeUp() end
--[[
	@collider UnityEngine.Collider2D
	return System.Boolean
--]]
function UnityEngine.Rigidbody2D:IsTouching(collider) end
function UnityEngine.Rigidbody2D:IsTouchingLayers() end
--[[
	@point UnityEngine.Vector2
	return System.Boolean
--]]
function UnityEngine.Rigidbody2D:OverlapPoint(point) end
--[[
	@collider UnityEngine.Collider2D
	return UnityEngine.ColliderDistance2D
--]]
function UnityEngine.Rigidbody2D:Distance(collider) end
--[[
	@force UnityEngine.Vector2
--]]
function UnityEngine.Rigidbody2D:AddForce(force) end
--[[
	@relativeForce UnityEngine.Vector2
--]]
function UnityEngine.Rigidbody2D:AddRelativeForce(relativeForce) end
--[[
	@force UnityEngine.Vector2
	@position UnityEngine.Vector2
--]]
function UnityEngine.Rigidbody2D:AddForceAtPosition(force,position) end
--[[
	@torque System.Single
--]]
function UnityEngine.Rigidbody2D:AddTorque(torque) end
--[[
	@point UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rigidbody2D:GetPoint(point) end
--[[
	@relativePoint UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rigidbody2D:GetRelativePoint(relativePoint) end
--[[
	@vector UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rigidbody2D:GetVector(vector) end
--[[
	@relativeVector UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rigidbody2D:GetRelativeVector(relativeVector) end
--[[
	@point UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rigidbody2D:GetPointVelocity(point) end
--[[
	@relativePoint UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.Rigidbody2D:GetRelativePointVelocity(relativePoint) end
--[[
	@contactFilter UnityEngine.ContactFilter2D
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Rigidbody2D:OverlapCollider(contactFilter,results) end
--[[
	@contacts UnityEngine.ContactPoint2D{}
	return System.Int32
--]]
function UnityEngine.Rigidbody2D:GetContacts(contacts) end
--[[
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Rigidbody2D:GetAttachedColliders(results) end
--[[
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Rigidbody2D:Cast(direction,results) end

--@SuperType [luaIde#UnityEngine.Renderer]
UnityEngine.SpriteRenderer = {}
--[[
	@RefType [luaIde#UnityEngine.Sprite]
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.sprite = nil
--[[
	UnityEngine.SpriteDrawMode
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.drawMode = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.size = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.adaptiveModeThreshold = nil
--[[
	UnityEngine.SpriteTileMode
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.tileMode = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.color = nil
--[[
	UnityEngine.SpriteMaskInteraction
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.maskInteraction = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.flipX = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.flipY = nil
--[[
	UnityEngine.SpriteSortPoint
	 Get 	 Set 
--]]
UnityEngine.SpriteRenderer.spriteSortPoint = nil
--[[
	@return [luaIde#UnityEngine.SpriteRenderer]
]]
function UnityEngine.SpriteRenderer:New() end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.EventSystems.EventSystem = {}
--[[
	@RefType [luaIde#UnityEngine.EventSystems.EventSystem]
	 Get 	 Set 
--]]
UnityEngine.EventSystems.EventSystem.current = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.EventSystems.EventSystem.sendNavigationEvents = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.EventSystems.EventSystem.pixelDragThreshold = nil
--[[
	UnityEngine.EventSystems.BaseInputModule
	 Get 
--]]
UnityEngine.EventSystems.EventSystem.currentInputModule = nil
--[[
	@RefType [luaIde#UnityEngine.GameObject]
	 Get 	 Set 
--]]
UnityEngine.EventSystems.EventSystem.firstSelectedGameObject = nil
--[[
	@RefType [luaIde#UnityEngine.GameObject]
	 Get 
--]]
UnityEngine.EventSystems.EventSystem.currentSelectedGameObject = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.EventSystems.EventSystem.isFocused = nil
--[[
	System.Boolean
	 Get 
--]]
UnityEngine.EventSystems.EventSystem.alreadySelecting = nil
function UnityEngine.EventSystems.EventSystem:UpdateModules() end
--[[
	@selected UnityEngine.GameObject
	@pointer UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.EventSystems.EventSystem:SetSelectedGameObject(selected,pointer) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
	@raycastResults System.Collections.Generic.List`1{{UnityEngine.EventSystems.RaycastResult, UnityEngine.UI, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
--]]
function UnityEngine.EventSystems.EventSystem:RaycastAll(eventData,raycastResults) end
function UnityEngine.EventSystems.EventSystem:IsPointerOverGameObject() end
function UnityEngine.EventSystems.EventSystem:ToString() end

--@SuperType [luaIde#System.Object]
UnityEngine.Physics2D = {}
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Physics2D.IgnoreRaycastLayer = 4
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Physics2D.DefaultRaycastLayers = -5
--[[
	System.Int32
	 Get 
--]]
UnityEngine.Physics2D.AllLayers = -1
--[[
	UnityEngine.PhysicsScene2D
	 Get 
--]]
UnityEngine.Physics2D.defaultPhysicsScene = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Physics2D.velocityIterations = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.Physics2D.positionIterations = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.Physics2D.gravity = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.queriesHitTriggers = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.queriesStartInColliders = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.callbacksOnDisable = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.reuseCollisionCallbacks = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.autoSyncTransforms = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.autoSimulation = nil
--[[
	UnityEngine.PhysicsJobOptions2D
	 Get 	 Set 
--]]
UnityEngine.Physics2D.jobOptions = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.velocityThreshold = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.maxLinearCorrection = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.maxAngularCorrection = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.maxTranslationSpeed = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.maxRotationSpeed = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.defaultContactOffset = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.baumgarteScale = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.baumgarteTOIScale = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.timeToSleep = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.linearSleepTolerance = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.angularSleepTolerance = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.alwaysShowColliders = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.showColliderSleep = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.showColliderContacts = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.Physics2D.showColliderAABB = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.Physics2D.contactArrowScale = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Physics2D.colliderAwakeColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Physics2D.colliderAsleepColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Physics2D.colliderContactColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.Physics2D.colliderAABBColor = nil
--[[
	@return [luaIde#UnityEngine.Physics2D]
]]
function UnityEngine.Physics2D:New() end
--[[
	@step System.Single
	return System.Boolean
--]]
function UnityEngine.Physics2D:Simulate(step) end
function UnityEngine.Physics2D:SyncTransforms() end
--[[
	@collider1 UnityEngine.Collider2D
	@collider2 UnityEngine.Collider2D
--]]
function UnityEngine.Physics2D:IgnoreCollision(collider1,collider2) end
--[[
	@collider1 UnityEngine.Collider2D
	@collider2 UnityEngine.Collider2D
	return System.Boolean
--]]
function UnityEngine.Physics2D:GetIgnoreCollision(collider1,collider2) end
--[[
	@layer1 System.Int32
	@layer2 System.Int32
--]]
function UnityEngine.Physics2D:IgnoreLayerCollision(layer1,layer2) end
--[[
	@layer1 System.Int32
	@layer2 System.Int32
	return System.Boolean
--]]
function UnityEngine.Physics2D:GetIgnoreLayerCollision(layer1,layer2) end
--[[
	@layer System.Int32
	@layerMask System.Int32
--]]
function UnityEngine.Physics2D:SetLayerCollisionMask(layer,layerMask) end
--[[
	@layer System.Int32
	return System.Int32
--]]
function UnityEngine.Physics2D:GetLayerCollisionMask(layer) end
--[[
	@collider1 UnityEngine.Collider2D
	@collider2 UnityEngine.Collider2D
	return System.Boolean
--]]
function UnityEngine.Physics2D:IsTouching(collider1,collider2) end
--[[
	@collider UnityEngine.Collider2D
	return System.Boolean
--]]
function UnityEngine.Physics2D:IsTouchingLayers(collider) end
--[[
	@colliderA UnityEngine.Collider2D
	@colliderB UnityEngine.Collider2D
	return UnityEngine.ColliderDistance2D
--]]
function UnityEngine.Physics2D:Distance(colliderA,colliderB) end
--[[
	@start UnityEngine.Vector2
	@end_ UnityEngine.Vector2
	@return [luaIde#UnityEngine.RaycastHit2D]
--]]
function UnityEngine.Physics2D:Linecast(start,end_) end
--[[
	@start UnityEngine.Vector2
	@end_ UnityEngine.Vector2
	return UnityEngine.RaycastHit2D{}
--]]
function UnityEngine.Physics2D:LinecastAll(start,end_) end
--[[
	@start UnityEngine.Vector2
	@end_ UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:LinecastNonAlloc(start,end_,results) end
--[[
	@origin UnityEngine.Vector2
	@direction UnityEngine.Vector2
	@return [luaIde#UnityEngine.RaycastHit2D]
--]]
function UnityEngine.Physics2D:Raycast(origin,direction) end
--[[
	@origin UnityEngine.Vector2
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:RaycastNonAlloc(origin,direction,results) end
--[[
	@origin UnityEngine.Vector2
	@direction UnityEngine.Vector2
	return UnityEngine.RaycastHit2D{}
--]]
function UnityEngine.Physics2D:RaycastAll(origin,direction) end
--[[
	@origin UnityEngine.Vector2
	@radius System.Single
	@direction UnityEngine.Vector2
	@return [luaIde#UnityEngine.RaycastHit2D]
--]]
function UnityEngine.Physics2D:CircleCast(origin,radius,direction) end
--[[
	@origin UnityEngine.Vector2
	@radius System.Single
	@direction UnityEngine.Vector2
	return UnityEngine.RaycastHit2D{}
--]]
function UnityEngine.Physics2D:CircleCastAll(origin,radius,direction) end
--[[
	@origin UnityEngine.Vector2
	@radius System.Single
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:CircleCastNonAlloc(origin,radius,direction,results) end
--[[
	@origin UnityEngine.Vector2
	@size UnityEngine.Vector2
	@angle System.Single
	@direction UnityEngine.Vector2
	@return [luaIde#UnityEngine.RaycastHit2D]
--]]
function UnityEngine.Physics2D:BoxCast(origin,size,angle,direction) end
--[[
	@origin UnityEngine.Vector2
	@size UnityEngine.Vector2
	@angle System.Single
	@direction UnityEngine.Vector2
	return UnityEngine.RaycastHit2D{}
--]]
function UnityEngine.Physics2D:BoxCastAll(origin,size,angle,direction) end
--[[
	@origin UnityEngine.Vector2
	@size UnityEngine.Vector2
	@angle System.Single
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:BoxCastNonAlloc(origin,size,angle,direction,results) end
--[[
	@origin UnityEngine.Vector2
	@size UnityEngine.Vector2
	@capsuleDirection UnityEngine.CapsuleDirection2D
	@angle System.Single
	@direction UnityEngine.Vector2
	@return [luaIde#UnityEngine.RaycastHit2D]
--]]
function UnityEngine.Physics2D:CapsuleCast(origin,size,capsuleDirection,angle,direction) end
--[[
	@origin UnityEngine.Vector2
	@size UnityEngine.Vector2
	@capsuleDirection UnityEngine.CapsuleDirection2D
	@angle System.Single
	@direction UnityEngine.Vector2
	return UnityEngine.RaycastHit2D{}
--]]
function UnityEngine.Physics2D:CapsuleCastAll(origin,size,capsuleDirection,angle,direction) end
--[[
	@origin UnityEngine.Vector2
	@size UnityEngine.Vector2
	@capsuleDirection UnityEngine.CapsuleDirection2D
	@angle System.Single
	@direction UnityEngine.Vector2
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:CapsuleCastNonAlloc(origin,size,capsuleDirection,angle,direction,results) end
--[[
	@ray UnityEngine.Ray
	@return [luaIde#UnityEngine.RaycastHit2D]
--]]
function UnityEngine.Physics2D:GetRayIntersection(ray) end
--[[
	@ray UnityEngine.Ray
	return UnityEngine.RaycastHit2D{}
--]]
function UnityEngine.Physics2D:GetRayIntersectionAll(ray) end
--[[
	@ray UnityEngine.Ray
	@results UnityEngine.RaycastHit2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:GetRayIntersectionNonAlloc(ray,results) end
--[[
	@point UnityEngine.Vector2
	@return [luaIde#UnityEngine.Collider2D]
--]]
function UnityEngine.Physics2D:OverlapPoint(point) end
--[[
	@point UnityEngine.Vector2
	return UnityEngine.Collider2D{}
--]]
function UnityEngine.Physics2D:OverlapPointAll(point) end
--[[
	@point UnityEngine.Vector2
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:OverlapPointNonAlloc(point,results) end
--[[
	@point UnityEngine.Vector2
	@radius System.Single
	@return [luaIde#UnityEngine.Collider2D]
--]]
function UnityEngine.Physics2D:OverlapCircle(point,radius) end
--[[
	@point UnityEngine.Vector2
	@radius System.Single
	return UnityEngine.Collider2D{}
--]]
function UnityEngine.Physics2D:OverlapCircleAll(point,radius) end
--[[
	@point UnityEngine.Vector2
	@radius System.Single
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:OverlapCircleNonAlloc(point,radius,results) end
--[[
	@point UnityEngine.Vector2
	@size UnityEngine.Vector2
	@angle System.Single
	@return [luaIde#UnityEngine.Collider2D]
--]]
function UnityEngine.Physics2D:OverlapBox(point,size,angle) end
--[[
	@point UnityEngine.Vector2
	@size UnityEngine.Vector2
	@angle System.Single
	return UnityEngine.Collider2D{}
--]]
function UnityEngine.Physics2D:OverlapBoxAll(point,size,angle) end
--[[
	@point UnityEngine.Vector2
	@size UnityEngine.Vector2
	@angle System.Single
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:OverlapBoxNonAlloc(point,size,angle,results) end
--[[
	@pointA UnityEngine.Vector2
	@pointB UnityEngine.Vector2
	@return [luaIde#UnityEngine.Collider2D]
--]]
function UnityEngine.Physics2D:OverlapArea(pointA,pointB) end
--[[
	@pointA UnityEngine.Vector2
	@pointB UnityEngine.Vector2
	return UnityEngine.Collider2D{}
--]]
function UnityEngine.Physics2D:OverlapAreaAll(pointA,pointB) end
--[[
	@pointA UnityEngine.Vector2
	@pointB UnityEngine.Vector2
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:OverlapAreaNonAlloc(pointA,pointB,results) end
--[[
	@point UnityEngine.Vector2
	@size UnityEngine.Vector2
	@direction UnityEngine.CapsuleDirection2D
	@angle System.Single
	@return [luaIde#UnityEngine.Collider2D]
--]]
function UnityEngine.Physics2D:OverlapCapsule(point,size,direction,angle) end
--[[
	@point UnityEngine.Vector2
	@size UnityEngine.Vector2
	@direction UnityEngine.CapsuleDirection2D
	@angle System.Single
	return UnityEngine.Collider2D{}
--]]
function UnityEngine.Physics2D:OverlapCapsuleAll(point,size,direction,angle) end
--[[
	@point UnityEngine.Vector2
	@size UnityEngine.Vector2
	@direction UnityEngine.CapsuleDirection2D
	@angle System.Single
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:OverlapCapsuleNonAlloc(point,size,direction,angle,results) end
--[[
	@collider UnityEngine.Collider2D
	@contactFilter UnityEngine.ContactFilter2D
	@results UnityEngine.Collider2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:OverlapCollider(collider,contactFilter,results) end
--[[
	@collider1 UnityEngine.Collider2D
	@collider2 UnityEngine.Collider2D
	@contactFilter UnityEngine.ContactFilter2D
	@contacts UnityEngine.ContactPoint2D{}
	return System.Int32
--]]
function UnityEngine.Physics2D:GetContacts(collider1,collider2,contactFilter,contacts) end

--@SuperType [luaIde#UnityEngine.Renderer]
UnityEngine.LineRenderer = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.startWidth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.endWidth = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.widthMultiplier = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.numCornerVertices = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.numCapVertices = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.useWorldSpace = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.loop = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.startColor = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.endColor = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.positionCount = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.shadowBias = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.generateLightingData = nil
--[[
	UnityEngine.LineTextureMode
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.textureMode = nil
--[[
	UnityEngine.LineAlignment
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.alignment = nil
--[[
	UnityEngine.AnimationCurve
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.widthCurve = nil
--[[
	UnityEngine.Gradient
	 Get 	 Set 
--]]
UnityEngine.LineRenderer.colorGradient = nil
--[[
	@return [luaIde#UnityEngine.LineRenderer]
]]
function UnityEngine.LineRenderer:New() end
--[[
	@index System.Int32
	@position UnityEngine.Vector3
--]]
function UnityEngine.LineRenderer:SetPosition(index,position) end
--[[
	@index System.Int32
	@return [luaIde#UnityEngine.Vector3]
--]]
function UnityEngine.LineRenderer:GetPosition(index) end
--[[
	@tolerance System.Single
--]]
function UnityEngine.LineRenderer:Simplify(tolerance) end
--[[
	@mesh UnityEngine.Mesh
	@useTransform System.Boolean
--]]
function UnityEngine.LineRenderer:BakeMesh(mesh,useTransform) end
--[[
	@positions UnityEngine.Vector3{}
	return System.Int32
--]]
function UnityEngine.LineRenderer:GetPositions(positions) end
--[[
	@positions UnityEngine.Vector3{}
--]]
function UnityEngine.LineRenderer:SetPositions(positions) end

UnityEngine.RaycastHit2D = {}
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RaycastHit2D.centroid = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RaycastHit2D.point = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.RaycastHit2D.normal = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.RaycastHit2D.distance = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.RaycastHit2D.fraction = nil
--[[
	@RefType [luaIde#UnityEngine.Collider2D]
	 Get 
--]]
UnityEngine.RaycastHit2D.collider = nil
--[[
	@RefType [luaIde#UnityEngine.Rigidbody2D]
	 Get 
--]]
UnityEngine.RaycastHit2D.rigidbody = nil
--[[
	@RefType [luaIde#UnityEngine.Transform]
	 Get 
--]]
UnityEngine.RaycastHit2D.transform = nil
function UnityEngine.RaycastHit2D:New () end
--[[
	@other UnityEngine.RaycastHit2D
	return System.Int32
--]]
function UnityEngine.RaycastHit2D:CompareTo(other) end

--UnityEngine.UI.Image.FillMethod  Enum
UnityEngine.UI.Image.FillMethod = {}
--[[

	 Get 
--]]
UnityEngine.UI.Image.FillMethod.Horizontal = 0
--[[

	 Get 
--]]
UnityEngine.UI.Image.FillMethod.Vertical = 1
--[[

	 Get 
--]]
UnityEngine.UI.Image.FillMethod.Radial90 = 2
--[[

	 Get 
--]]
UnityEngine.UI.Image.FillMethod.Radial180 = 3
--[[

	 Get 
--]]
UnityEngine.UI.Image.FillMethod.Radial360 = 4

--@SuperType [luaIde#UnityEngine.Renderer]
UnityEngine.SpriteMask = {}
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.frontSortingLayerID = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.frontSortingOrder = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.backSortingLayerID = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.backSortingOrder = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.alphaCutoff = nil
--[[
	@RefType [luaIde#UnityEngine.Sprite]
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.sprite = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.isCustomRangeActive = nil
--[[
	UnityEngine.SpriteSortPoint
	 Get 	 Set 
--]]
UnityEngine.SpriteMask.spriteSortPoint = nil
--[[
	@return [luaIde#UnityEngine.SpriteMask]
]]
function UnityEngine.SpriteMask:New() end

--@SuperType [luaIde#UnityEngine.Collider2D]
UnityEngine.BoxCollider2D = {}
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.BoxCollider2D.size = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.BoxCollider2D.edgeRadius = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.BoxCollider2D.autoTiling = nil
--[[
	@return [luaIde#UnityEngine.BoxCollider2D]
]]
function UnityEngine.BoxCollider2D:New() end

--System.IO.SearchOption  Enum
System.IO.SearchOption = {}
--[[

	 Get 
--]]
System.IO.SearchOption.TopDirectoryOnly = 0
--[[

	 Get 
--]]
System.IO.SearchOption.AllDirectories = 1

--@SuperType [luaIde#System.Object]
System.Diagnostics.Stopwatch = {}
--[[
	System.Int64
	 Get 
--]]
System.Diagnostics.Stopwatch.Frequency = nil
--[[
	System.Boolean
	 Get 
--]]
System.Diagnostics.Stopwatch.IsHighResolution = nil
--[[
	System.TimeSpan
	 Get 
--]]
System.Diagnostics.Stopwatch.Elapsed = nil
--[[
	System.Int64
	 Get 
--]]
System.Diagnostics.Stopwatch.ElapsedMilliseconds = nil
--[[
	System.Int64
	 Get 
--]]
System.Diagnostics.Stopwatch.ElapsedTicks = nil
--[[
	System.Boolean
	 Get 
--]]
System.Diagnostics.Stopwatch.IsRunning = nil
--[[
	@return [luaIde#System.Diagnostics.Stopwatch]
]]
function System.Diagnostics.Stopwatch:New() end
function System.Diagnostics.Stopwatch:GetTimestamp() end
function System.Diagnostics.Stopwatch:StartNew() end
function System.Diagnostics.Stopwatch:Reset() end
function System.Diagnostics.Stopwatch:Start() end
function System.Diagnostics.Stopwatch:Stop() end

--@SuperType [luaIde#UnityEngine.Behaviour]
UnityEngine.AudioBehaviour = {}
--[[
	@return [luaIde#UnityEngine.AudioBehaviour]
]]
function UnityEngine.AudioBehaviour:New() end

--@SuperType [luaIde#UnityEngine.UI.Graphic]
UnityEngine.UI.MaskableGraphic = {}
--[[
	UnityEngine.UI.MaskableGraphic.CullStateChangedEvent
	 Get 	 Set 
--]]
UnityEngine.UI.MaskableGraphic.onCullStateChanged = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.MaskableGraphic.maskable = nil
--[[
	@baseMaterial UnityEngine.Material
	@return [luaIde#UnityEngine.Material]
--]]
function UnityEngine.UI.MaskableGraphic:GetModifiedMaterial(baseMaterial) end
--[[
	@clipRect UnityEngine.Rect
	@validRect System.Boolean
--]]
function UnityEngine.UI.MaskableGraphic:Cull(clipRect,validRect) end
--[[
	@clipRect UnityEngine.Rect
	@validRect System.Boolean
--]]
function UnityEngine.UI.MaskableGraphic:SetClipRect(clipRect,validRect) end
function UnityEngine.UI.MaskableGraphic:RecalculateClipping() end
function UnityEngine.UI.MaskableGraphic:RecalculateMasking() end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.Graphic = {}
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 
--]]
UnityEngine.UI.Graphic.defaultGraphicMaterial = nil
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.UI.Graphic.color = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Graphic.raycastTarget = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.Graphic.depth = nil
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 
--]]
UnityEngine.UI.Graphic.rectTransform = nil
--[[
	@RefType [luaIde#UnityEngine.Canvas]
	 Get 
--]]
UnityEngine.UI.Graphic.canvas = nil
--[[
	UnityEngine.CanvasRenderer
	 Get 
--]]
UnityEngine.UI.Graphic.canvasRenderer = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 
--]]
UnityEngine.UI.Graphic.defaultMaterial = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 	 Set 
--]]
UnityEngine.UI.Graphic.material = nil
--[[
	@RefType [luaIde#UnityEngine.Material]
	 Get 
--]]
UnityEngine.UI.Graphic.materialForRendering = nil
--[[
	@RefType [luaIde#UnityEngine.Texture]
	 Get 
--]]
UnityEngine.UI.Graphic.mainTexture = nil
function UnityEngine.UI.Graphic:SetAllDirty() end
function UnityEngine.UI.Graphic:SetLayoutDirty() end
function UnityEngine.UI.Graphic:SetVerticesDirty() end
function UnityEngine.UI.Graphic:SetMaterialDirty() end
function UnityEngine.UI.Graphic:OnCullingChanged() end
--[[
	@update UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.Graphic:Rebuild(update) end
function UnityEngine.UI.Graphic:LayoutComplete() end
function UnityEngine.UI.Graphic:GraphicUpdateComplete() end
function UnityEngine.UI.Graphic:SetNativeSize() end
--[[
	@sp UnityEngine.Vector2
	@eventCamera UnityEngine.Camera
	return System.Boolean
--]]
function UnityEngine.UI.Graphic:Raycast(sp,eventCamera) end
--[[
	@point UnityEngine.Vector2
	@return [luaIde#UnityEngine.Vector2]
--]]
function UnityEngine.UI.Graphic:PixelAdjustPoint(point) end
function UnityEngine.UI.Graphic:GetPixelAdjustedRect() end
--[[
	@targetColor UnityEngine.Color
	@duration System.Single
	@ignoreTimeScale System.Boolean
	@useAlpha System.Boolean
--]]
function UnityEngine.UI.Graphic:CrossFadeColor(targetColor,duration,ignoreTimeScale,useAlpha) end
--[[
	@alpha System.Single
	@duration System.Single
	@ignoreTimeScale System.Boolean
--]]
function UnityEngine.UI.Graphic:CrossFadeAlpha(alpha,duration,ignoreTimeScale) end
--[[
	@action UnityEngine.Events.UnityAction
--]]
function UnityEngine.UI.Graphic:RegisterDirtyLayoutCallback(action) end
--[[
	@action UnityEngine.Events.UnityAction
--]]
function UnityEngine.UI.Graphic:UnregisterDirtyLayoutCallback(action) end
--[[
	@action UnityEngine.Events.UnityAction
--]]
function UnityEngine.UI.Graphic:RegisterDirtyVerticesCallback(action) end
--[[
	@action UnityEngine.Events.UnityAction
--]]
function UnityEngine.UI.Graphic:UnregisterDirtyVerticesCallback(action) end
--[[
	@action UnityEngine.Events.UnityAction
--]]
function UnityEngine.UI.Graphic:RegisterDirtyMaterialCallback(action) end
--[[
	@action UnityEngine.Events.UnityAction
--]]
function UnityEngine.UI.Graphic:UnregisterDirtyMaterialCallback(action) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
UnityEngine.EventSystems.UIBehaviour = {}
function UnityEngine.EventSystems.UIBehaviour:IsActive() end
function UnityEngine.EventSystems.UIBehaviour:IsDestroyed() end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.Selectable = {}
--[[
	System.Collections.Generic.List`1{{UnityEngine.UI.Selectable, UnityEngine.UI, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
UnityEngine.UI.Selectable.allSelectables = nil
--[[
	UnityEngine.UI.Navigation
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.navigation = nil
--[[
	UnityEngine.UI.Selectable.Transition
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.transition = nil
--[[
	UnityEngine.UI.ColorBlock
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.colors = nil
--[[
	UnityEngine.UI.SpriteState
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.spriteState = nil
--[[
	UnityEngine.UI.AnimationTriggers
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.animationTriggers = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Graphic]
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.targetGraphic = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.interactable = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Image]
	 Get 	 Set 
--]]
UnityEngine.UI.Selectable.image = nil
--[[
	@RefType [luaIde#UnityEngine.Animator]
	 Get 
--]]
UnityEngine.UI.Selectable.animator = nil
function UnityEngine.UI.Selectable:IsInteractable() end
--[[
	@dir UnityEngine.Vector3
	@return [luaIde#UnityEngine.UI.Selectable]
--]]
function UnityEngine.UI.Selectable:FindSelectable(dir) end
function UnityEngine.UI.Selectable:FindSelectableOnLeft() end
function UnityEngine.UI.Selectable:FindSelectableOnRight() end
function UnityEngine.UI.Selectable:FindSelectableOnUp() end
function UnityEngine.UI.Selectable:FindSelectableOnDown() end
--[[
	@eventData UnityEngine.EventSystems.AxisEventData
--]]
function UnityEngine.UI.Selectable:OnMove(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Selectable:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Selectable:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Selectable:OnPointerEnter(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.Selectable:OnPointerExit(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.Selectable:OnSelect(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.UI.Selectable:OnDeselect(eventData) end
function UnityEngine.UI.Selectable:Select() end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
Spine.Unity.SkeletonRenderer = {}
--[[
	Spine.Unity.SkeletonDataAsset
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.skeletonDataAsset = nil
--[[
	System.String
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.initialSkinName = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.initialFlipX = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.initialFlipY = nil
--[[
	System.String{}
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.separatorSlotNames = nil
--[[
	System.Collections.Generic.List`1{{Spine.Slot, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Unity.SkeletonRenderer.separatorSlots = nil
--[[
	System.Single
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.zSpacing = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.useClipping = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.immutableTriangles = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.pmaVertexColors = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.clearStateOnDisable = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.tintBlack = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.singleSubmesh = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.addNormals = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.calculateTangents = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.logErrors = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.disableRenderingOnOverride = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.valid = nil
--[[
	@RefType [luaIde#Spine.Skeleton]
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.skeleton = nil
--[[
	Spine.Unity.SkeletonDataAsset
	 Get 
--]]
Spine.Unity.SkeletonRenderer.SkeletonDataAsset = nil
--[[
	System.Collections.Generic.Dictionary`2{{UnityEngine.Material, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.Material, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Unity.SkeletonRenderer.CustomMaterialOverride = nil
--[[
	System.Collections.Generic.Dictionary`2{{Spine.Slot, Assembly-CSharp-firstpass, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null},{UnityEngine.Material, UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 
--]]
Spine.Unity.SkeletonRenderer.CustomSlotMaterials = nil
--[[
	@RefType [luaIde#Spine.Skeleton]
	 Get 
--]]
Spine.Unity.SkeletonRenderer.Skeleton = nil
--[[
	Spine.Unity.SkeletonRenderer.SkeletonRendererDelegate
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.OnRebuild = nil
--[[
	Spine.Unity.MeshGeneratorDelegate
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.OnPostProcessVertices = nil
--[[
	Spine.Unity.SkeletonRenderer.InstructionDelegate
	 Get 	 Set 
--]]
Spine.Unity.SkeletonRenderer.GenerateMeshOverride = nil
--[[
	@settings Spine.Unity.MeshGenerator.Settings
--]]
function Spine.Unity.SkeletonRenderer:SetMeshSettings(settings) end
function Spine.Unity.SkeletonRenderer:Awake() end
function Spine.Unity.SkeletonRenderer:ClearState() end
--[[
	@overwrite System.Boolean
--]]
function Spine.Unity.SkeletonRenderer:Initialize(overwrite) end
function Spine.Unity.SkeletonRenderer:LateUpdate() end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.LoopScrollRect = {}
--[[
	@RefType [luaIde#UnityEngine.UI.LoopScrollPrefabSource]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.prefabSource = nil
--[[
	System.Int32
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.totalCount = nil
--[[
	@RefType [luaIde#UnityEngine.UI.LoopScrollDataSource]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.dataSource = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.threshold = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.reverseDirection = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.rubberScale = nil
--[[
	System.Object{}
	 Set 
--]]
UnityEngine.UI.LoopScrollRect.objectsToFill = nil
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.content = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.horizontal = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.vertical = nil
--[[
	UnityEngine.UI.LoopScrollRect.MovementType
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.movementType = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.elasticity = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.inertia = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.decelerationRate = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.scrollSensitivity = nil
--[[
	@RefType [luaIde#UnityEngine.RectTransform]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.viewport = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Scrollbar]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.horizontalScrollbar = nil
--[[
	@RefType [luaIde#UnityEngine.UI.Scrollbar]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.verticalScrollbar = nil
--[[
	UnityEngine.UI.LoopScrollRect.ScrollbarVisibility
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.horizontalScrollbarVisibility = nil
--[[
	UnityEngine.UI.LoopScrollRect.ScrollbarVisibility
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.verticalScrollbarVisibility = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.horizontalScrollbarSpacing = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.verticalScrollbarSpacing = nil
--[[
	UnityEngine.UI.LoopScrollRect.ScrollRectEvent
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.onValueChanged = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.velocity = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.normalizedPosition = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.horizontalNormalizedPosition = nil
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.LoopScrollRect.verticalNormalizedPosition = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.minWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.flexibleWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.minHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.preferredHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.flexibleHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.LoopScrollRect.layoutPriority = nil
function UnityEngine.UI.LoopScrollRect:ClearCells() end
function UnityEngine.UI.LoopScrollRect:RefreshCells() end
--[[
	@offset System.Int32
--]]
function UnityEngine.UI.LoopScrollRect:RefillCellsFromEnd(offset) end
--[[
	@offset System.Int32
--]]
function UnityEngine.UI.LoopScrollRect:RefillCells(offset) end
--[[
	@executing UnityEngine.UI.CanvasUpdate
--]]
function UnityEngine.UI.LoopScrollRect:Rebuild(executing) end
function UnityEngine.UI.LoopScrollRect:LayoutComplete() end
function UnityEngine.UI.LoopScrollRect:GraphicUpdateComplete() end
function UnityEngine.UI.LoopScrollRect:IsActive() end
function UnityEngine.UI.LoopScrollRect:StopMovement() end
--[[
	@data UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.LoopScrollRect:OnScroll(data) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.LoopScrollRect:OnInitializePotentialDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.LoopScrollRect:OnBeginDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.LoopScrollRect:OnEndDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.UI.LoopScrollRect:OnDrag(eventData) end
function UnityEngine.UI.LoopScrollRect:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.LoopScrollRect:CalculateLayoutInputVertical() end
function UnityEngine.UI.LoopScrollRect:SetLayoutHorizontal() end
function UnityEngine.UI.LoopScrollRect:SetLayoutVertical() end

--@SuperType [luaIde#System.Object]
UnityEngine.UI.LoopScrollDataSource = {}
--[[
	@transform UnityEngine.Transform
	@idx System.Int32
--]]
function UnityEngine.UI.LoopScrollDataSource:ProvideData(transform,idx) end

--@SuperType [luaIde#System.Object]
UnityEngine.Events.UnityEventBase = {}
function UnityEngine.Events.UnityEventBase:GetPersistentEventCount() end
--[[
	@index System.Int32
	return UnityEngine.Object
--]]
function UnityEngine.Events.UnityEventBase:GetPersistentTarget(index) end
--[[
	@index System.Int32
	return System.String
--]]
function UnityEngine.Events.UnityEventBase:GetPersistentMethodName(index) end
--[[
	@index System.Int32
	@state UnityEngine.Events.UnityEventCallState
--]]
function UnityEngine.Events.UnityEventBase:SetPersistentListenerState(index,state) end
function UnityEngine.Events.UnityEventBase:RemoveAllListeners() end
function UnityEngine.Events.UnityEventBase:ToString() end
--[[
	@obj System.Object
	@functionName System.String
	@argumentTypes System.Type{}
	return System.Reflection.MethodInfo
--]]
function UnityEngine.Events.UnityEventBase:GetValidMethodInfo(obj,functionName,argumentTypes) end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.LayoutGroup = {}
--[[
	UnityEngine.RectOffset
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutGroup.padding = nil
--[[
	UnityEngine.TextAnchor
	 Get 	 Set 
--]]
UnityEngine.UI.LayoutGroup.childAlignment = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LayoutGroup.minWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LayoutGroup.preferredWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LayoutGroup.flexibleWidth = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LayoutGroup.minHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LayoutGroup.preferredHeight = nil
--[[
	System.Single
	 Get 
--]]
UnityEngine.UI.LayoutGroup.flexibleHeight = nil
--[[
	System.Int32
	 Get 
--]]
UnityEngine.UI.LayoutGroup.layoutPriority = nil
function UnityEngine.UI.LayoutGroup:CalculateLayoutInputHorizontal() end
function UnityEngine.UI.LayoutGroup:CalculateLayoutInputVertical() end
function UnityEngine.UI.LayoutGroup:SetLayoutHorizontal() end
function UnityEngine.UI.LayoutGroup:SetLayoutVertical() end

--@SuperType [luaIde#UnityEngine.UI.LayoutGroup]
UnityEngine.UI.HorizontalOrVerticalLayoutGroup = {}
--[[
	System.Single
	 Get 	 Set 
--]]
UnityEngine.UI.HorizontalOrVerticalLayoutGroup.spacing = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.HorizontalOrVerticalLayoutGroup.childForceExpandWidth = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.HorizontalOrVerticalLayoutGroup.childForceExpandHeight = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.HorizontalOrVerticalLayoutGroup.childControlWidth = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.HorizontalOrVerticalLayoutGroup.childControlHeight = nil

--@SuperType [luaIde#Base]
View = {}
--[[
	@message IMessage
--]]
function View:OnMessage(message) end

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
Base = {}

--@SuperType [luaIde#Base]
Manager = {}

--@SuperType [luaIde#UnityEngine.MonoBehaviour]
UnityEngine.EventSystems.EventTrigger = {}
--[[
	System.Collections.Generic.List`1{{UnityEngine.EventSystems.EventTrigger.Entry, UnityEngine.UI, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null}}
	 Get 	 Set 
--]]
UnityEngine.EventSystems.EventTrigger.triggers = nil
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnPointerEnter(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnPointerExit(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnDrop(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnPointerDown(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnPointerUp(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnPointerClick(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnSelect(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnDeselect(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnScroll(eventData) end
--[[
	@eventData UnityEngine.EventSystems.AxisEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnMove(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnUpdateSelected(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnInitializePotentialDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnBeginDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.PointerEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnEndDrag(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnSubmit(eventData) end
--[[
	@eventData UnityEngine.EventSystems.BaseEventData
--]]
function UnityEngine.EventSystems.EventTrigger:OnCancel(eventData) end

--@SuperType [luaIde#UnityEngine.UI.BaseMeshEffect]
UnityEngine.UI.Shadow = {}
--[[
	@RefType [luaIde#UnityEngine.Color]
	 Get 	 Set 
--]]
UnityEngine.UI.Shadow.effectColor = nil
--[[
	@RefType [luaIde#UnityEngine.Vector2]
	 Get 	 Set 
--]]
UnityEngine.UI.Shadow.effectDistance = nil
--[[
	System.Boolean
	 Get 	 Set 
--]]
UnityEngine.UI.Shadow.useGraphicAlpha = nil
--[[
	@vh UnityEngine.UI.VertexHelper
--]]
function UnityEngine.UI.Shadow:ModifyMesh(vh) end

--@SuperType [luaIde#UnityEngine.EventSystems.UIBehaviour]
UnityEngine.UI.BaseMeshEffect = {}
--[[
	@mesh UnityEngine.Mesh
--]]
function UnityEngine.UI.BaseMeshEffect:ModifyMesh(mesh) end

