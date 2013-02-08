LoadModule("Util",[[
tUtil = {
	
};

--used in Util.TableToString
tEscapeChars = {
	[1] = {
		Char = "\\",
		RelacementChar = "\\\\",
	},
	[2] = {
		Char = "\a",
		RelacementChar = "\\a",
	},
	[3] = {
		Char = "\b",
		RelacementChar = "\\b",
	},
	[4] = {
		Char = "\f",
		RelacementChar = "\\f",
	},
	[5] = {
		Char = "\r\n",
		RelacementChar = "\\r\\n",
	},
	[6] = {
		Char = "\t",
		RelacementChar = "\\t",
	},
	[7] = {
		Char = "\v",
		RelacementChar = "\\v",
	},
	[8] = {
		Char = "\"",
		RelacementChar = "\\\"",
		},
	[9] = {
		Char = "\'",
		RelacementChar = "\\'",
	},	
	[10] = {
		Char = "%[",
		RelacementChar = "%%[",
		},
	[11] = {
		Char = "%]",
		RelacementChar = "%%]",
	},	
};

--================================================================================
--								<<<All Util Methods>>>
--================================================================================

function VarIsValid(tTypes, vVar)
local tValidTypes = {
	b = "boolean",
	f = "funciton",
	l = "nil",
	n = "number",
	s = "string",
	t = "table",
};

	if type(tTypes) == "table" then
	local sVarType = type(vVar);
	
		for nTypeID, sTypeID in pairs(tTypes) do
		sTypeID = string.lower(sTypeID);
		
			---check that the input type exists
			if tValidTypes[sTypeID] then
				
				--check to see if the input variable meets one of the allowed types input
				if sVarType == tValidTypes[sTypeID] then				
				return true
				end
		
			end			
			
		end		
			
	end
	
return false
end


--================================================================================
--									<<<DUNGEON>>>
--================================================================================



function Dungeon_AdjacentCellIsWall(nLevel, nFacing, nX, nY)

	if nFacing == 0 then
	nY = nY - 1;
	
	elseif nFacing == 1 then
	nX = nX + 1;
	
	elseif nFacing == 2 then
	nY = nY + 1;
	
	elseif nFacing == 3 then
	nX = nX - 1;
	
	end
	
	if nX > -1 and nX < 32 and nY > -1 and nY < 32 then
	return isWall(nLevel, nX, nY)
	end
	
return true
end


--================================================================================
--									<<<MATH>>>
--================================================================================



function Math_GetAlternator()
return (-1) ^ math.random(1,2)
end



function Math_UpOrDown(nValue)
		
	if math.random() < 0.5 then
	return math.floor(nValue)
	else
	return math.ceil(nValue)
	end

end

--================================================================================
--									<<<POSITION>>>
--================================================================================
function Position_GetOppositeFacing(nFacing)

	if nFacing == 0 then
	return 2
	elseif nFacing == 1 then
	return 3
	elseif nFacing == 2 then
	return 0	
	elseif nFacing == 3 then
	return 1
	end

return 0
end


--================================================================================
--									<<<STRING>>>
--================================================================================



function String_GenerateUUID(sPrefix)
local tChars = {"x","3","y","1","b","2","p","e","8","f","v","t","g","9","h","7","u","4","i","z","a","j","0","c","k","l","5","m","n","w","o","q","r","s","d","6"};
local tSequence = {1,4,4,4,12};
local sUUID = "";
local nMaxPrefixLength = 6; --range from 0 to 8
local sDelimiter = "-";

if type(sPrefix) == "string" then
local nLength = string.len(sPrefix);
	
	if nLength > nMaxPrefixLength then
	sPrefix = string.sub(sPrefix, 1, nMaxPrefixLength);
	end
	
	if string.gsub(sPrefix, " ", "") ~= "" then
	sUUID = sPrefix..sDelimiter;
	end
	
	if nLength < nMaxPrefixLength then
	tSequence[1] = tSequence[1] + (nMaxPrefixLength - nLength);
	end
	
else
tSequence[1] = 8;
end

--fix the - at the end...
for nIndex, nSequence in pairs(tSequence) do
	
	for x = 1, nSequence do
	sUUID = sUUID..tChars[math.random(1, 36)];
	end

sUUID = sUUID.."-";
end

return sUUID
end


--================================================================================
--									<<<TABLE>>>
--================================================================================



function Table_ToString(tInput, nCount)
--the string to return
local sRet = "";
local nCount = nCount;

	--initialize the count variable if it's not
	if type(nCount) ~= "number" then
	nCount = 0;
	end
	
--step the count variable
nCount = nCount + 1;
--convert to string for use with the tags
local sCount = tostring(nCount);
	
	--if the input type is a table...
	if type(tInput) == "table" then
	sRet = sRet.."<t"..sCount..">";
		
		--process each item in the table
		for vIndex, vItem in pairs(tInput) do
		local sIndexType = type(vIndex);
		local sItemType = type(vItem);
		local sIndex = "";
				
			--write the index to string
			local sMyType = "n";
			if sIndexType == "string" then
			sMyType = "s";
			end
			
			--set up the key, value pair start tag
			sRet = sRet.."<p"..sCount..">"..sMyType;
			
			--write the	item to string
			if sItemType == "number" then
			sRet = sRet.."n<k>"..vIndex.."</k><v>"..vItem.."</v>";
			
			elseif sItemType == "string" then
			
				for nIndex, tChar in pairs(tEscapeChars) do
				vItem = string.gsub(vItem, tChar.Char, tChar.RelacementChar);
				end
			
			sRet = sRet.."s<k>"..vIndex.."</k><v>"..vItem.."</v>";
			
			elseif sItemType == "boolean" then
			
				if vItem then
				sRet = sRet.."b<k>"..vIndex.."</k><v>".."true</v>";
				else
				sRet = sRet.."b<k>"..vIndex.."</k><v>".."false</v>";
				end
			
			elseif sItemType == "nil" then
			sRet = sRet.."l<k>"..vIndex.."</k><v>".."nil</v>";
						
			elseif sItemType == "function" then
			--Can't use this, don't have access to the getfenv function in LoG
									
			elseif sItemType == "userdata" then
			--do the userdata stuff here...
			
			elseif sItemType == "table" then
			sRet = sRet.."t<k>"..vIndex.."</k><v>"..Util.TableToString(vItem, nCount).."</v>";
			
			end
		
		--finish this key, value pair
		sRet = sRet.."</p"..sCount..">";
		end
			
	end

sRet = sRet.."</t"..sCount..">";

return sRet
end



function Table_FromString(sInput, nCount)
local nCount = nCount;

	--initialize the count variable if it's not
	if type(nCount) ~= "number" then
	nCount = 0;
	end
	
--step the count variable
nCount = nCount + 1;
--convert to string for use with the tags
local sCount = tostring(nCount);

--the table that will be returned
local tRet = {};
--used for simplicity
local tTypes = {
	b = "boolean",
	l = "nil",
	n = "number",
	s = "string",
	t = "table",
};
--a list of the tags being used
local tTags = {
	KVP = {
		Open = {
			Length = 0,
			String = "<p"..sCount..">",
		},
		Close = {
			Length = 0,
			String = "</p"..sCount..">",
		},
	},
	Key = {
		Open = {
			Length = 0,
			String = "<k>",
		},
		Close = {
			Length = 0,
			String = "</k>",
		},
	},
	Value = {
		Open = {
			Length = 0,
			String = "<v>",
		},
		Close = {
			Length = 0,
			String = ">v/<", --reversed to accommodate the reverse-string search for the last close tag
		},
	},
};

	--get the length of all of the tags
	for sTagClass, tTag in pairs(tTags) do
	tTags[sTagClass].Open.Length = string.len(tTag.Open.String);
	tTags[sTagClass].Close.Length = string.len(tTag.Close.String);
	end

--where the last search ended (and the next search wil start)
local nSearch_E = 1;
local bContinue = true;
local nSearchKVP_S, nSearchKVP_E = 0, 0;
	
	--this loop will continue until no more key, value pairs are found
	while bContinue do
	--make sure no loopy happens
	bContinue = false;
	--find the point where the next key,value pair open tag begins
	nSearchKVP_S, nSearchKVP_E = string.find(sInput, tTags.KVP.Open.String, nSearch_E);
		
		if nSearchKVP_S and nSearchKVP_E then
		--get the start point of the key tag
		local nKeyStart = nSearchKVP_E + 3;
		--get the index type
		local sKeyType = tTypes[string.sub(sInput, nSearchKVP_E + 1, nSearchKVP_E + 1)];
		--get the item type
		local sValueType = tTypes[string.sub(sInput, nSearchKVP_E + 2, nSearchKVP_E + 2)];
		--find the start of the close tag in this key, value pair
		local nMyEnd = string.find(sInput, tTags.KVP.Close.String, nKeyStart);
			
			if nMyEnd then
			--get the string containing the type strings, index and item of the key, value pair
			local sKVPRaw = string.sub(sInput, nKeyStart, nMyEnd - 1);
			--get the start and end points for the key open tag
			local nKeyOpen_S, nKeyOpen_E = string.find(sKVPRaw, tTags.Key.Open.String, 1);
				
				if nKeyOpen_S and nKeyOpen_E then
				--get the start and end points for the key close tag
				local nKeyClose_S, nKeyClose_E = string.find(sKVPRaw, tTags.Key.Close.String, 1);
					
					if nKeyClose_S and nKeyClose_E then
					--get the start and end points for the value open tag
					local nValueOpen_S, nValueOpen_E = string.find(sKVPRaw, tTags.Value.Open.String, 1);
					
						if nValueOpen_S and nValueOpen_E then
						--reverse the string to ensure the last value close tag is found
						local sReverse = string.reverse(sKVPRaw);
						--get the start and end points for the value close tag
						local nValueClose_S, nValueClose_E = string.find(sReverse, tTags.Value.Close.String, 1);
							
							if nValueClose_S and nValueClose_E then
							--get the key
							local vKey = string.sub(sKVPRaw, nKeyOpen_E + 1, nKeyClose_S - 1);
							--get the value
							local vValue = string.sub(sKVPRaw, nValueOpen_E + 1, string.len(sKVPRaw) - nValueClose_E);
							--store the info to be returned
								
								-- the modified key (to be)
								local vModKey = "_PLACEHOLDER_KEY_";
								
								--set the key according to its type
								if sKeyType == "number" then
								vModKey = tonumber(vKey);
								elseif sKeyType == "string" then
								vModKey = tostring(vKey);
								end
							
								--the modified value (to be)
								local vModValue = "_PLACEHOLDER_VALUE_"
								
								--set the value according to its type
								if sValueType == "boolean" then
									
									if vValue == "true" then
									vModValue = true;
									
									elseif vValue == "false" then
									vModValue = false;
									
									end
								
								elseif sValueType == "nil" then
								vModValue = nil;
								
								elseif sValueType == "number" then
								vModValue = tonumber(vValue);
								
								elseif sValueType == "string" then
								vModValue = tostring(vValue);
								
								elseif sValueType == "table" then
								vModValue = Util.StringToTable(vValue, nCount);
								
								end								
								
								--set the table item
								tRet[vModKey] = vModValue;
								
							--mark the start of the next search (and the end of this one)
							nSearch_E = nMyEnd - 1;
							bContinue = true;
							end
							
						end
						
					end
					
				end
				
			end
		
		end
	
	end

return tRet
end
]]);