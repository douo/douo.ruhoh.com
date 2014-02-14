$(document).ready(function() {
				$('.sidebar').sidebar('attach events', '.attached.button');
				$('.ui.accordion').accordion();
				$('.attached.button').on('mouseenter', function() {
					$(this).stop().animate({
						width : '155px'
					}, 300, function() {
						$(this).find('.text').show();
					});
				}).on('mouseleave', function(event) {
					$(this).find('.text').hide();
					$(this).stop().animate({
						width : '70px'
					}, 300);
				});
			});