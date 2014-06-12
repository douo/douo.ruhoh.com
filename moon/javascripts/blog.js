!function(moon,$){
    function toc(content,toc_container,toc_class,options){
	var _toc = content.toc(
	    function build(root){
		var node ;
		var result ="";
		for(var i =0;i<root.c.length;i++){
		    node = root.c[i];
		    if(!node.v.attr('id')){
			node.v.attr('id','toc_'+node.count);
		    }
		    result += ("<li class='toc-li toc-h"+node.depth+"'><a href='#"+node.v.attr('id')+"'>"+node.v.text()+"</a></li>");
		    if(node.c){
			result += build(node);
		    }
		}
		return result;
	    },options);
	if(_toc){
	    toc_container.append(jQuery("<div class='"+toc_class+"'>"+_toc+"</div>"));
	    toc_container.removeClass('hide');
	}
    }
    function glowheader(){
	$('.toc-li > a:first-child').on('click', function() {
	    moon.scrollTo(this.hash);
	});
    }
    
    function postToc(){
	toc($('.post'),$('.post-toc'),"post-toc-content",{
            startLevel: 2,
	    minCount: 4,
	});
	glowheader();
    }
    function archivesToc(){
	toc($('.archives-content'),$('.archives-toc'),"archives-toc-content",{
            startLevel: 2
	});
	glowheader();
    }

    var resizeHeader = function(){
	var _f = function(){
	    var fontSize,
		headHeight = $('.header hgroup').height(),
		titleWidth = $('.site-name a').width(),
		parentWidth = $('.site-name').parent().width(),
		p = 35/230;
		baseFontSize = headHeight / 3.5,		
		basePaddingTop = headHeight / 3;
	    fontSize = (parentWidth - headHeight) * p;
	    if(fontSize > 48){
		fontSize = 48;
	    }
	    $('.site-name').css({
		'font-size': fontSize,
		'padding-top': basePaddingTop + baseFontSize - fontSize - (8 * fontSize / 35)
	    });

	    $('.tagline').css({'font-size': fontSize / 2.3});
	}
	return _f;
    }();

    function toggleNav(){
	var _f = function(){
	    var nav = $('.nav');
	    nav.slideToggle(200);
	}
	return _f;
    }
    
    moon.postToc = postToc;
    moon.archivesToc = archivesToc;
    moon.resizeHeader = resizeHeader;

    $( window ).resize(function(){
	var w = $(window).width();  
	resizeHeader();
	console.log(matchMedia('screen and (min-width: 48em)').matches);
	if(matchMedia('screen and (min-width: 48em)').matches){
	    $('.nav').removeAttr('style');
	}
    });
    
    $(function(){
	$(".button-nav").click(toggleNav());
    });
    
}(moon,jQuery);


