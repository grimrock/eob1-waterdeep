fw_addModule('gw_book',[[
function create(id,x,y)
	x = x or 20
	y = y or 20
	local book = gw.new{
		'image',
		id = id,
		image="mod_assets/textures/book2_900.tga",
		x=x,
		y=y,
		width=900,
		height=800
	}
	book.addPageText = _addPageText
	book.addPageHeader = _addPageHeader
	book.addPageImage = _addPageImage
	book.getPage = _getPage	
	book.addPageElement = _addPageElement
	book.createPage = _createPage
	book.activePagePair = 1
	book.openPagePair = _openPagePair
	book.nextPage = _nextPage
	book.prevPage = _prevPage
	book.onClose = function(self)
		gw.removeElement(self:getAncestor().id)
	end
	local closeButton = book:addChild('text','close_book',0,0,20,20,'X')
	closeButton:setRelativePosition{'top','right'}
	closeButton.x = closeButton.x -10 
	closeButton.y = closeButton.y + 10
	closeButton.textColor = {100,100,100,210}
	closeButton.onPress = book.onClose
	
	
	return book
end

function _addPageHeader(book,pageNum,header)
	return  book:addPageText(pageNum,header,'large')
end

function _addPageText(book,pageNum,header,size)
	size=size or 'medium'
	local text = gw.new{'text',text=header,width=330,height=100,textSize=size}
	text:calculateHeight()
	text.marginTop = 10
	text.textColor = book.textColor
	book:addPageElement(pageNum,text)
	return text
end

function _addPageImage(book,pageNum,filename,w,h,relativePosition)
	size=size or 'medium'
	local img = gw.new{'image',width=w,height=h,image=filename}
	img.marginTop = 10
	book:addPageElement(pageNum,img)
	relativePosition = relativePosition or 'left'
	img:setRelativePosition(relativePosition)
	return img
end


function _addPageElement(book,pageNum,elem)
	local page = book:getPage(pageNum)
	page:addChild(elem)	
	elem:setRelativePosition{'below_previous'}
	return elem
end

function _getPage(book,pageNum)
	local page = book:getChild('page_'..pageNum)
	if page == nil then
		page = book:createPage(pageNum)
	end
	return page
end

function _createPage(book,pageNum)
	local x,y = 30,30
	
	if pageNum % 2 == 0 then
		x = 480
	end
	local page = book:addChild('element','page_'..pageNum,x,y,350,530)
	page.pagePair = math.ceil(pageNum/2)
	page.onPress = function(self) 
		self.parent:nextPage()
	end


	return page
end

function _nextPage(self)
	self:openPagePair(self.activePagePair+1)
end
function _prevPage(self)
	self:openPagePair(self.activePagePair-1)
end

function _openPagePair(self,pairNum)
	local outOfBounds = true
	for i,elem in ipairs(self.children) do 
		if elem.pagePair then
			if elem.pagePair == pairNum then
				elem:activate()
				outOfBounds = false
			else
				elem:deactivate()
			end
		end
	end

	self.activePagePair = pairNum
	if outOfBounds then
		self:openPagePair(1)
	end	
end
]])