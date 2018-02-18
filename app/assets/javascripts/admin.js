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
// require jquery.ui.all

var send = {};
var s;
$(document).ready(function () {
    $(".get").click(function () {
        $(".set").html("").unbind('click');
        self = $(this);
        s = self;
        var id = self.html();
        $.getJSON("/admin/event/" + self.attr('data'), function (data) {
            send = data;
            console.log(data);
            s.nextAll(".set").html("S").click(function () {
                $.getJSON("/admin/event/" + self.attr('data'), send,
                    function (data) {
                        window.location.reload(true);
                    });
            });
        });
    });
});
