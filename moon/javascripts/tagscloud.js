var waitForFinalEvent = (function () {
  var timers = {};
  return function (callback, ms, uniqueId) {
    if (!uniqueId) {
      uniqueId = "Don't call this twice without a uniqueId";
    }
    if (timers[uniqueId]) {
      clearTimeout (timers[uniqueId]);
    }
    timers[uniqueId] = setTimeout(callback, ms);
  };
})();

!function($){
    var cloud = {},
	font = 'Helvetica, Tahoma, Arial, STXihei, "华文细黑", "Microsoft YaHei", "微软雅黑", SimSun, "宋体", Heiti, "黑体", sans-serif',
    	w,
	h,
        fontSize,

	fill = d3.scale.category20(), // 设置填充的颜色，这里表示用 20 种颜色进行填充
	layout = d3.layout.cloud()
	.timeInterval(10)
	.font(font)
	.fontSize(function(d) {return d.size;})
	.rotate(function() { return ~~(Math.random() * 2) * 90; }) // 0/90
	//.on("word", progress) // 每处理一个单词调用一次 progress
	.on("end", draw), // 处理完成后调用 draw
	
	svg,
	background,
	vis; 
   
    function init(){
	// 插入 svg
	svg = d3.select("#tagscloud").append("svg"),
	background = svg.append("g"),
	vis = svg.append("g"),
	generate();
    }

    function jump(d){
	moon.scrollTo("#"+d.text+"-ref")
    }

    function progress(d) {
	console.log(d);
    }

    function generate() {
	// 每次生成重新获取 tagscloud 的宽度
	w = $('#tagscloud').width();
	h = w / 1.6;
	svg.attr("width", w).attr("height", h);
	vis.attr("width", w).attr("height", h).attr("transform", "translate(" + [w >> 1, h >> 1] + ")");
	layout.stop().size([w, h]).words(tags.map(function(d) {
            return {text: d,size: 12 + Math.random() * 90};
	})).start();
    }

    function draw(data, bounds) {

    	scale = bounds ? Math.min(
    	    w / Math.abs(bounds[1].x - w / 2),
    	    w / Math.abs(bounds[0].x - w / 2),
    	    h / Math.abs(bounds[1].y - h / 2),
    	    h / Math.abs(bounds[0].y - h / 2)) / 2 : 1;
    	words = data;
    	var text = vis.selectAll("text")
    	    .data(words, function(d) { return d.text.toLowerCase(); }); //将 data 绑定到 text
	// 设置每个 text 的位置角度等等，
    	text.transition()
    	    .duration(1000)
    	    .attr("transform", function(d) { return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")"; })
    	    .style("font-size", function(d) { return d.size + "px"; });
    	text.enter().append("text")
    	    .attr("text-anchor", "middle")
    	    .attr("transform", function(d) { return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")"; })
    	    .style("font-size", function(d) { return d.size + "px"; })
    	    .on("click", cloud.jump)
    	    .style("opacity", 1e-6)
    	    .transition()
    	    .duration(1000)
    	    .style("opacity", 1);
    	text.style("font-family", function(d) { return d.font; })
    	    .style("fill", function(d) { return fill(d.text.toLowerCase()); })
    	    .text(function(d) { return d.text; });
	//
    	var exitGroup = background.append("g")
    	    .attr("transform", vis.attr("transform"));
    	var exitGroupNode = exitGroup.node();
    	text.exit().each(function() {
    	    exitGroupNode.appendChild(this);
    	});
    	exitGroup.transition()
    	    .duration(1000)
    	    .style("opacity", 1e-6)
    	    .remove();
    	vis.transition()
    	    .delay(1000)
    	    .duration(750)
    	    .attr("transform", "translate(" + [w >> 1, h >> 1] + ")scale(" + scale + ")");
    }
    cloud.init = init;
    cloud.generate = generate;
    cloud.jump = jump;
    this.cloud = cloud;
    
    // 只有当 resize 完成的时候才重新生成 tagscloud
    $(window).resize(function () {
	// 判断 resize 是否完成是通过在 500ms 内窗口大小没变化来判断的 -_-\\
	// 作用不大
	//waitForFinalEvent(function(){
	    var _w =  $('#tagscloud').width();
	    if(w != _w){ // 只有宽度变化才需要重新生成
		generate();
	    }
	//console.log('Resize...');
	//}, 200, "resize tagscloud");
    });
}(jQuery);

