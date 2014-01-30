// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/ui/jquery-ui
//= require jqueryui-timepicker-addon/dist/jquery-ui-timepicker-addon
//= require editable_select/jquery.editableSelect
//= require bootstrap
//= require highcharts
//= require highcharts/themes/grid
//= require highcharts/modules/exporting
//= require jquery.pjax
//= require_tree .

$(document).ready(function(){
	$("#commands").on("change", "select", function(){
		var url=$(this).parents(".event-update").attr("data-url");
		var com = $(this).find("option:selected").val();
		$(this).parents(".event-update").load(url, "command="+com);
	});

  $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]', {timeout: 3000});
});

$.fn.poll = function(fn, timeout) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.polling) {
      clearTimeout(data.polling);
    }
    if (fn !== false) {
      var callback = function() { $this.poll(fn, timeout) };
      data.polling = setTimeout(function() { fn(callback); }, timeout || 5000);
    }
  });
}