!function(){
    var moon = {};
    moon.scrollTo = scrollTo;
    function scrollTo(hash,scrollDuration,flashDuration){
	var target = $(hash);
	scrollDuration = scrollDuration || 500;
	flashDuration = flashDuration || 700;
	var container = $('body,html'); 
	//为 toc 添加滚动动画
	container.animate({scrollTop: target.offset().top}, 500, function() {
	    //滚动完成，闪动 header
	    target.addClass('glowheader').delay(700).queue(function() {
		$(this).removeClass('glowheader').dequeue();
	    });
	});
    }

    this.moon = moon;
}();
