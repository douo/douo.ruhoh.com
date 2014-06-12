!function(moon,$){
    function toc(content,toc_container,toc_class,options){
	var sections = [],
	    _height  = $(window).height(),
	    _toc = content.toc(
		function build(root){
		    var node ,
			heading,
			result ="";
		    for(var i =0;i<root.c.length;i++){
			node = root.c[i];
			heading = node.v;
			// 如果 heading 没有 id 则自动生成一个id
			if(!heading.attr('id')){
			    heading.attr('id','toc_'+node.count);
			}
			// 保存 heading 所在页面的高度
			sections.push({
			    "id"    : heading.attr('id'),
			    "top"   : heading.offset().top,
			    "height": heading.height()
			});

			result += ("<li id='li_"+heading.attr('id').replace(/\s/g,"-")+"' class='toc-li toc-h"+node.depth+"'><a href='#"+heading.attr('id')+"'>"+heading.text()+"</a></li>");
			if(node.c){
			    result += "<ul>"+build(node)+"</ul>";
			}
		    }
		    return result;
		},options);

	_highlight_section = function() {
	    var $this = $(this),
		i, section, 
		pre_dst, dst,
            pos   = $this.scrollTop();
	    for(i = 0; i< sections.length ;i++){
		section = sections[i];
		dst = section.top - pos;
		if(dst > 0){
		    if( i == 0 || dst <= _height/2){
			break;
		    }else{
			section = sections[i-1];
			break;
		    }
		}
	    }
	    $('.toc-li').removeClass('active');
            $('#li_' + section.id.replace(/\s/g,"-")).addClass('active');
	    return section.id;
	};
	if(_toc){
	    toc_container.append(jQuery("<div class='"+toc_class+"'>"+_toc+"</div>"));
	    toc_container.removeClass('hide');
	    $(document).scroll(_highlight_section);
	    toc_container.find('#li_'+_highlight_section()).addClass('active');
	}
	return _toc;
    }

    function glowheader(){
	$('.toc-li > a:first-child').on('click', function() {
	    moon.scrollTo(this.hash);
	    // 点击的时候强制将TOC条目标记为 Active
	    // 注释掉是因为觉得没什么用处
	    // var li = $(this).parent();
	    // li.delay(600).queue(function(){
	    // 	$('.toc-li').removeClass('active');
	    // 	li.addClass('active');
	    // });
	    return false;
	});
    }

    function renderItem(parent,item,level){
	if (typeof(level) === "undefined") { level = 0; }
	var li;
	var ul; //children
	var isActive = item.url == window.location.pathname; // 用于找到激活的菜单项
	var childActive;
	if(item.url){
	    li = $("<li><a href='"+item.url+"'>"+item.title+"</a></li>");
	}else{
	    li = $("<li>"+item.title+"</li>");
	}
	li.addClass('list-h'+level);
	if(isActive){
	    li.addClass('actived');
	}
	parent.append(li);
	if(item.children){
	    li.addClass('heading')
	    ul = $("<ul></ul>");
	    ul.addClass('ul-h'+level);
	    for(var i=0;i<item.children.length;i++){
		isActive |= renderItem(ul,item.children[i],level+1);
	    }
	    if(level >= 1 && !isActive){
		ul.hide();
	    }
	    parent.append(ul);
	    
	}
	li.click(function(){
	    var show = ul.is(":visible");
	    li.parent().find('ul').slideUp(200);
	    if(!show){
		ul.slideDown(200);
	    }
	})
	return isActive;
    }
    
    function buildNavigation(){
	var nav = $("#nav");
	renderItem(nav,this.navigation);
    };
    function buildToc(){
	var tocContainer = $("<div class='toc'></div>");
	
	var result = toc($('.post-content'),tocContainer,"post-toc-content",{
            startLevel: 2,
	    minCount: 4,
	});
	if(result){	    
	    $('.content').addClass('with-toc')
	    tocContainer.insertBefore('.content');
	    glowheader();
	}
    }
    function jumpToTag(tag){
	window.location = "/notes/Uncategory/tags/#"+tag+"-ref";
    }
    moon.jumpToTag = jumpToTag;
    moon.buildNavigation = buildNavigation;
    moon.buildToc = buildToc;
}(moon,jQuery);



