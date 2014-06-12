(function($){
    function level(header){
	return parseInt(header.nodeName.toLowerCase().substr(1,1));
    }

    function last(array){
	return array[array.length-1];
    }

    function generate(scope, options){
	options = $.extend({},$.fn.toc.defaultOptions, options);
	var tags = ["h1","h2","h3","h4","h5","h6"]; // The six header tags
	var filtered_tags = tags.splice(options.startLevel - 1, options.depth);
	var $headings = scope.find(filtered_tags.join(', '));
	if($headings.length < options.minCount){
	    return false;
	}
	var root = {c:[],depth:0};
	var stack = [root];
	for(var i=0;i<$headings.length;i++){
	    var h=$headings[i];
	    var parent = last(stack);
	    while(parent != root && level(parent.v[0]) >= level(h)){//找到父节点
		stack.pop();
		parent = last(stack);
	    }
	    node = {v:$(h),depth:parent.depth+1,count:i};
	    if(parent.c){
		parent.c.push(node);
	    }else{
		parent.c = [node];
	    }
	    stack.push(node);
	}
	return root
    }

    function build_recursion(root){
	var node ;
	var result = "";
	for(var i =0;i<root.c.length;i++){
	    node = root.c[i];
	    node.v.attr('id','toc_'+node.count);
	    result += ("<li><a href='#"+node.v.attr('id')+"'>"+node.v.text()+"</a></li>");
	    if(node.c){
		result += ("<ol>"+build_recursion(node)+"</ol>");
	    }
	}
	return result;
    }

    function build_with_stack(root){
	var node ;
	var result = "";
	var stack = [];
	for(var i=root.c.length-1;i>=0;i--){
	    stack.push(root.c[i]);
	}
	var last_depth = 1;
	while(stack.length != 0){

	    node = stack.pop();
	    node.v.attr('id','toc_'+node.count);
	    var str = ("<li><a href='#"+node.v.attr('id')+"'>"+node.v.text()+"</a>");
	    console.log(last_depth+":"+node.depth);
	    if(last_depth < node.depth){
		result += ("<ol>"+str);
	    }else if(last_depth > node.depth){
		for(var j=0;j<last_depth-node.depth;j++)
		    result += "</li></ol>";
		result += (str+"</li>");
	    }else{
		result += (str+"</li>");
	    }
	    last_depth = node.depth;
	    if(node.c){
		for(var i=node.c.length-1;i>=0;i--){
		    stack.push(node.c[i]);
		}
	    }
	}
	return result;

    }

    $.fn.toc = function(build,options){
	var root = generate(this,options);
	console.log(root);
	if(root){
	    if(build){
		return build(root);
	    }else{
		return build_recursion(root);
	    }
	}
    };
    $.fn.toc.defaultOptions = {
	startLevel: 2,
        depth: 3,
	minCount: 1
    };
	
})(jQuery);


