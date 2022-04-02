--[[
	二维码数据生成
--]]
--[[
	二维码数据结构
	version  --版本
	width 	--宽度  像素
	data   --一位数组  1表示白色  0表示黑色
--]]


local qrencode = require "qrencode.core"
local ewmTools={}

ewmTools.EncodingMode={
	QR_MODE_NUL = -1, 
	QR_MODE_NUM = 0,   
	QR_MODE_AN=1,        
	QR_MODE_8=2,         
	QR_MODE_KANJI=3,     
	QR_MODE_STRUCTURE=4, 
}
--Level of error correction.
ewmTools.EcLevel={
	QR_ECLEVEL_L= 0,
	QR_ECLEVEL_M=1,
	QR_ECLEVEL_Q=2,
	QR_ECLEVEL_H=3      
}

--缩放ewm
local function scaleEwm(data,scale)
	scale=scale or 1
	scale=math.floor(scale)
	if scale>1 then
		local scaleData={width=data.width*scale,data={}}
		for i=1,data.width do
			for j=1,data.width do
				local pos=(i-1) * data.width +j

				local start_i=(i-1)*scale
            	local start_j=(j-1)*scale
            	local w=scaleData.width

				for ki=1,scale do
                    for kj=1,scale do
                        local pos1=(start_i+ki)*w + start_j+kj
                        scaleData.data[pos1]=data.data[pos]
                    end
                end
			end
			
		end
		return scaleData
	end
	return data
end
--基础数据转化为数据列表
local function baseDtaToC3bList(data)
	--转化
	local list={}
	local len=data.width*data.width
	for i=1,len do
		local byte = string.byte(data.data,i)
		if byte % 2 == 0 then
			list[#list+1] = 0
		else
			list[#list+1] = 1
		end
   	end
   	data.data=list
   	return data
end

function ewmTools.getEwmData(str,scale,version,EcLevel,EncodingMode,casesensitive)
	if not str then
		return nil
	end
	scale=scale or 1
	scale=math.floor(scale)

	version=version or 0
	EcLevel=EcLevel or ewmTools.EcLevel.QR_ECLEVEL_H
	EncodingMode=EncodingMode or ewmTools.EncodingMode.QR_MODE_8
	casesensitive=casesensitive or 1

	local data=qrencode.encode(str,version,EcLevel,EncodingMode,casesensitive)
	baseDtaToC3bList(data)

	return scaleEwm(data,scale)
end

function ewmTools.getEwmDataWithPixel(str,pixel,version,EcLevel,EncodingMode,casesensitive)
	if not str then
		return nil
	end

	version=version or 0
	EcLevel=EcLevel or ewmTools.EcLevel.QR_ECLEVEL_H
	EncodingMode=EncodingMode or ewmTools.EncodingMode.QR_MODE_8
	casesensitive=casesensitive or 1

	local data=qrencode.encode(str,version,EcLevel,EncodingMode,casesensitive)
	baseDtaToC3bList(data)

	pixel=pixel or data.width
	--根据width转化为对应scale
	local scale=pixel/data.width
	scale=math.floor(scale)

	return scaleEwm(data,scale)
	
end



return ewmTools






