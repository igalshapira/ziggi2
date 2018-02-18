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
//= require jquery.sha1.js

Foundation.libs.abide.settings.patterns.password = /^.{3,}$/;
$(function(){ $(document).foundation(); });

function dialog(title, button) {
    var buttons = [ ];
    if (button) buttons.push(button);
    buttons.push({ "text": "סגור",
            click: function () {
                $(this).dialog("close");
            } }
    );
    $("#dialog").dialog({
        resizable: false,
        title: title,
        buttons: buttons,
    });
}

function next_location() {
    if (window.matchMedia(Foundation.media_queries['small']).matches)
	return "/w/agenda";
    return "/schedule"
}

$(document).ready(function () {
    var login = {};
    $('#login-form').on('invalid', function () {
//	var invalid_fields = $(this).find('[data-invalid]');
    }).on('valid', function () {
	login.remember = $("#remember_me").is(':checked');
        login.email = $("#email").val();
        login.password = $.sha1($("#password").val());
        $.getJSON("/login", login, function (data) {
            if (data.login)
                window.location = next_location();
            else if (data.email) {
		$("#error-login-dlg").foundation('reveal', 'open');
            }
            else /* Signup */
            {
		$("#login-email").text(login.email);
		$("#signup-dlg").foundation('reveal', 'open');
            }
        });
    });

    $('#signup-form').on('valid', function () {
        $.getJSON("/signup", login, function (data) {
            if (data.login)
                window.location = next_location();
            else if (!data.email) {
        	$("#dialog div").html("קיים כבר משתמש בכתובת דואר האלקטרוני הזה.");
        	dialog("");
            }
        });
    });

    $(document).on('open', '[data-reveal]', function () {
	$("#recover-email").val($("#email").val());
	$("#forgot-form button").removeAttr("disabled");
    });

    $('#forgot-form').on('valid', function () {
	$("#forgot-form button").attr("disabled", "disabled");
	$.post('/password_recovery', { "email": $("#recover-email").val()},
	    function (res) {
		$("#answer-dlg div").html(res);
		$("#answer-dlg").foundation('reveal', 'open');
	    });
    });
});
