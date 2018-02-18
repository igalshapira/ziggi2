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
//= require jquery.weekcalendar.js
//= require jquery.jeditable.js
//= require jquery.rateit.min.js
//= require jquery.ba-bbq.min.js
//= require jquery.sizes.js
//= require jlayout.border.js
//= require jquery.jlayout.js
//= require jquery.tmpl.min.js
//= require knockout-2.2.1.js
//= require jquery.sha1.js
//= require jquery.jgrowl.min.js
//= require html2canvas.js
//= require FileSaver.js
//= require canvas-toBlob.js

var myCourses = {data: [], saved: false};
var worker;
var shortDays = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];
var longDays = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];
var longMonths = ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי',
    'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'];
var isReadOnly;

var MINUTE = 1000 * 60;
var HOUR = MINUTE * 60;
var DAY = HOUR * 24;
var WEEK = DAY * 7;

String.prototype.crs = function () {
    return this.replace(/[.]/g, "_");
};

String.prototype.escapeHTML = function () {
    return $('<div/>').text(this).html();
};

Number.prototype.tos2 = function () {
    return ((this < 10) ? "0" : "") + this;
};

Date.prototype.to_weekly = function (sunday) {
    var d = new Date(sunday);
    var tz = d.getTimezoneOffset() * MINUTE;
    /* Ugliest workaround ever */
    if (this.getDay() == 0)
	tz -= 60 * MINUTE;
    d.setUTCHours(parseInt((this.getTime() - d.getTime()) / WEEK));
    d.setTime(d.getTime() + this.getUTCDay() * DAY + tz);
    return d;
};

Date.prototype.notz = function () {
    this.setTime(this.getTime() - this.getTimezoneOffset() * MINUTE);
    return this;
};

Date.prototype.hours = function () {
    var h = this.getUTCHours(), m = this.getUTCMinutes();
    return h + ":" + (m < 10 ? "0" : "") + m;
};

Date.prototype.date = function () {
    return this.getDate() + "-" +
        $.datepicker.regional['he'].monthNamesShort[this.getMonth()];
};

/* Changes decimal 10.5 to hour 10:30 */
Number.prototype.hour = function () {
    var h, m;
    h = parseInt(this, 10);
    m = (this - h) * 60;

    return h + ":" + (m || "00");
};


function _ajax_request(url, data, callback, type, method) {
    if (jQuery.isFunction(data)) {
        callback = data;
        data = {};
    }
    return jQuery.ajax({
        type: method,
        url: url,
        data: data,
        success: callback,
        dataType: type
    });
}

jQuery.extend({
    put: function (url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'PUT');
    },
    restDelete: function (url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'DELETE');
    }
});

(function () {
    var all_courses = [];
    var all_events = [];
    var summaryData = [];
    var to_save = { 'groups': [], 'events': []};
    var save_timer = null;
    var event_timer = null;
    var isSuper = false;
    var calendarInit = null;
    var weekly_start, weekly_end;
    var calOptions = {
        is_monthly: false,
        timeFormat: "h:i a",
        daysToShow: 6,
        use24Hour: true,
        firstDayOfWeek: 0,
        useShortDayNames: false,
        timeSeparator: " עד ",
        useTimeSeparator: false,
        startParam: "start",
        endParam: "end",
        newEventText: "יוצר אירוע חדש...",
        timeslotHeight: 18,
        timeslotsPerHour: 2,
        defaultEventLength: 2,
        buttons: false,
        readonly: true,
        scrollToHourMillis: 500,
        allowCalEventOverlap: true,
        overlapEventsSeparate: true,
        eventRender: function (calEvent, element) {
            return element;
        },
        eventAfterRender: function (calEvent, element) {
            return element;
        },
        eventClick: function (calEvent, element) {
        },
        eventMouseover: function (calEvent, $event) {
        },
        eventMouseout: function (calEvent, $event) {
        },
        draggable: function (calEvent, element) {
            return false;
        },
        resizable: function (calEvent, element) {
            return false;
        },
        eventDrag: function (calEvent, element) {
        },
        eventDrop: function (calEvent, element) {
        },
        eventResize: function (calEvent, element) {
        },
        eventNew: function (calEvent, element) {
        },
        weeklyClick: function (event) {
        },
        calendarBeforeLoad: function (calendar) {
        },
        calendarAfterLoad: function (calendar) {
            calendarExtraElements();
        },
        noEvents: function () {
        },
        shortMonths: ['ינו', 'פבר', 'מרץ', 'אפר', 'מאי', 'יונ', 'יולי', 'אוג', 'ספט', 'אוק', 'נוב', 'דצמ'],
        longMonths: longMonths,
        shortDays: shortDays,
        longDays: longDays,
        height: function ($calendar) {
            return $("#calendar").height();
        }
    };


    var ziggi = function () {
        return new ziggi.fn.init();
    };

    ziggi.data = function () {
        var s, e, d, all_dates = [];
        var today = new Date();
        today.setUTCHours(0, 0, 0, 0);
        today = today.getTime();
        s = semester.start.getTime();
        var maxDate = semester.exams_end || semester.end;
        e = maxDate.getTime();
        for (d = s; d <= e; d += DAY) {
            var da = new Date(d);

            all_dates.push({ "month": da.getMonth(), "day": da.getDate(),
                year: da.getFullYear(), "today": today == d});
        }
        return {
            /* XXX Return courses order by name */
            "courses": all_courses,
            "events": all_events,
            "dates": all_dates,
        };
    }

    ziggi.fn = ziggi.prototype = {
        constructor: ziggi,
        init: function () {
            return this;
        }
    };

    function searchCourse() {
        var search_str = $("input#search-value").val();
        if (search_str.length == 0) {
            ziggi.Error("אפשר לחפש קורס על פי שם או מספר.<br/>"
                + "הקלד את הטקסט בשורת החיפוש ולחץ על הכפתור שנית");
            return;
        }
        var results =
            "<h2>קורסים</h2><div id='res-courses' class='loading'></div>" +
                "<h2>אירועים ציבורים</h2><div id='res-events' class='loading'></div>";

        /*
         results = "שימו לב:<br/>" +
         "רשימת השעות לסמסטר הקרוב עוד לא פורסמה רשמית.<br/>" +
         "ייתכן שחלק מהקורסים שנמצאו לא פעילים בסמסטר הקרוב. כמו כן, מומלץ לבדוק את שעות הקורסים שנית לקראת ההרשמה הרשמית לסמסטר." + results;
         */
        var div = $("#results-dialog div").html(results);
        $("#results-dialog").dialog({
            minWidth: 720,
            resizable: false,
            height: 400,
            maxHeight: 400,
            title: "מחפש: " + search_str.escapeHTML(),
            buttons: [
                { "text": "סגור", click: function () {
                    $(this).dialog("close");
                } }
            ],
        });

        $.getJSON('/search/' + encodeURIComponent(search_str),
            function (data) {
                var div = $("#results-dialog div");
                var ul = $("<ul/>");
                var i;

                /* Specific course was found */
                if (data.name) {
                    $("#results-dialog").dialog('close');
                    ziggi.addCourse(data, 1);
                    return;
                }
                /* List of courses or empty result */
                for (i = 0; data.results && i < data.results.length; i++) {
                    var key = data.results[i].number;
                    var val = data.results[i].name;
                    var li = $("<li/>").html($("<a/>").text(key + " " + val).
                        attr("href", "#").data('key', key).data('name', val).
                        after((data.results[i].semester ? (" סמסטר " +
                            data.results[i].semester + " ") : "") +
                            (data.results[i].info || "")));
                    ul.append(li);
                }

                $("#res-courses", div).removeClass("loading");
                if (!i) {
                    $("#res-courses", div).html("לא נמצאו תוצאות לחיפוש");
                }
                else {
                    $("li a", ul).click(ziggi.addCourseFromSearch);
                    $("#res-courses", div).html(ul);
                }
            }).error(function () {
                str = 'אירעה שגיאה בחיפוש קורס: ' + search_str.escapeHTML() +
                    "<br/>" + "נסה שנית מאוחר יותר";
                $("#res-courses", div).removeClass("loading").html(str);
            });

        $.getJSON('/public/' + encodeURIComponent(search_str),
            function (data) {
                var i, ul = $("<ul/>");
                for (i = 0; i < data.length; i++) {
                    var key = data[i].id;
                    var val = data[i].title;
                    var li = $("<li/>").html($("<a/>").text(val).
                        attr("href", "#").data('id', key));
                    ul.append(li);
                }

                $("#res-events", div).removeClass("loading");
                if (!i) {
                    $("#res-events", div).html("לא נמצאו תוצאות לחיפוש");
                }
                else {
                    $("li a", ul).click(ziggi.addEventFromSearch);
                    $("#res-events", div).html(ul);
                }
            }).error(function () {
                $("#res-events", div).removeClass("loading");
                $("#res-events", div).html("לא נמצאו תוצאות לחיפוש");
                $("#res-events", div).html(ul);
            });
    }

    function searchFreeHour(date) {
        var results =
            "<h2>קורסים</h2><div id='res-courses' class='loading'></div>";

        var div = $("#results-dialog div").html(results);
        $("#results-dialog").dialog({
            minWidth: 720,
            resizable: false,
            height: 400,
            maxHeight: 400,
            title: "מחפש קורס ספורט: " + ziggi.timeRange(date, null, true),
            buttons: [
                { "text": "סגור", click: function () {
                    $(this).dialog("close");
                } }
            ],
        });
        $.getJSON('/sport/' + (date.getDay() + 1) + "/" + date.getUTCHours(),
            function (data) {
                var div = $("#results-dialog div");
                var ul = $("<ul/>");
                var i;

                for (i = 0; data.results && i < data.results.length; i++) {
                    var key = data.results[i].number;
                    var val = data.results[i].name;
                    var li = $("<li/>").html($("<a/>").text(key + " " + val).
                        attr("href", "#").data('key', key).data('name', val));
                    ul.append(li);
                }

                $("#res-courses", div).removeClass("loading");
                if (!i) {
                    $("#res-courses", div).html("לא נמצאו תוצאות לחיפוש");
                }
                else {
                    $("li a", ul).click(ziggi.addCourseFromSearch);
                    $("#res-courses", div).html(ul);
                }
            }).error(function () {
                str = 'אירעה שגיאה בחיפוש'.
                    $("#res-courses", div).removeClass("loading").html(str);
            });
    }

    function drawSchedule() {
        if (calendarInit != "week")
            weeklyCalInit();
        else
            $('#calendar').weekCalendar("refresh");
    }

    function drawAdvancedSchedule() {
        advancedCalInit(0);
        updateASBNavButtons();
        //modeAdvanced();
        //$('#calendar').weekCalendar("refresh");
    }

    function drawCourses() {
        $("#courses").html($("#courses-tabs-template").tmpl(ziggi.data()));
        $("#menu-tab").tabs();
        $("#courses-tab").tabs({
            collapsible: true,
            beforeActivate: function (event, ui) {
                $("#menu-tab").tabs("option", {active: 1});
                $("#menu-tab div#course-tab").scrollTop(0);
                if (ui.newTab.length > 0) {
                    var panel = $($(ui.newTab.context).attr("href").replace(/[.]/g, "\\."));
                    $("#menu-tab div#course-tab").scrollTop(panel.position().top - panel.parent().position().top);
                }
                return false;
            }
        });
        $("#courses-tab ul li").removeClass("ui-state-active");
        $(window).trigger('resize');

        attachHoursEvents();

        /* Update hours and points */
        calcPointsAndHours();

        /* Update Events on mini-cal */
        miniCalEvents();
    }

    function attachHoursEvents() {
        $("ul li.group-hour").unbind().hover(function () {
            eventHover($(this).data("group"), true);
        }, function () {
            eventHover($(this).data("group"), false);
        });
        $("ul li.group-hour, ul.exams li").click(function () {
            if (isReadOnly) return false;
            var id = $(this).data("group");
            if (id[0] == "E")
                eventSelect(findEvent(id));
            else if (id[0] == "G") {
                var group = findGroup(id.substr(1));
                groupSelect(group.group, !group.group.selected);
            }
            else if (id[0] == "X") {
                var d = $(this).data("date").split("T");
                d = d[0].split("-");
                $('#calendar').weekCalendar('gotoWeek', new Date(d[0], d[1] - 1, d[2]));
            }
            drawSchedule();
        });
        $(".groups ul li span.staff").click(function () {
            ziggi.loadStaffInfo($(this).attr('data'), 0);
            return false;
        });

    }

    function addMiniCalEvent(date, title, cls) {
	if (!date)
	    return;
        var element = $("#mc_" + date.getDate() + "_" + date.getMonth() + "_" + date.getFullYear());
        var n_title = element.attr("title");
        n_title = (n_title ? n_title + "<br/>" : "") + title;

        /* Look for exams collapse! */
        if (cls == "exam" && element.hasClass("exam"))
            cls = "collision";
        element.addClass(cls).attr("title", n_title);
    }

    function miniCalEvents() {
        var e;
        for (e = 0; e < all_events.length; e++) {
            var ev = all_events[e];
            if (ev.university_id == 0) {
                addMiniCalEvent(new Date(ev.date_start), ev.title, "holiday");
                continue;
            }
            if (!ev.selected) {
                continue;
        }


        if (ev.weekly) {
             var evDate = new Date(ev.date_start);
             while (new Date(evDate) <= new Date(semester.end)) {
                 addMiniCalEvent(evDate, ev.title, "event");
                 evDate.setTime(evDate.getTime() + 1000 * 60 * 60 * 24 * 1 * 7);
            }
         }
            else
                addMiniCalEvent(new Date(ev.date_start), ev.title, "event");
        }
        addMiniCalEvent(semester.start, 'פתיחת סמסטר ' + semester.name,
            "semester");
        addMiniCalEvent(semester.end,
            'סיום סמסטר ' + semester.name, "semester");
        addMiniCalEvent(semester.exams_start,
            'תחילת בחינות סמסטר ' + semester.name, "semester");
        addMiniCalEvent(semester.exams_end,
            'סיום בחינות סמסטר ' + semester.name, "semester");
        for (c = 0; c < all_courses.length; c++) {
            for (e = 0; all_courses[c].exams &&
                e < all_courses[c].exams.length; e++) {
                var exam = all_courses[c].exams[e];
                addMiniCalEvent(new Date(exam.date_start), 'מועד ' + exam.type +
                    " " + all_courses[c].name + "<br/>" + ziggi.timeRange(exam.date_start, exam.date_end, false), "exam");
            }
        }

        $("#mini-cal table tr td.day").click(function () {
            var d = $(this).attr("id").split("_");
            $("#edit-mode a").removeClass("selected");
            $("#edit-btn").addClass("selected");
            modeEdit(0);
            weeklyCalInit();
            $('#calendar').weekCalendar('gotoWeek', new Date(d[3], d[2], d[1]));
            window.history.pushState('schedule#', 'schedule#', 'schedule#');
        });
    }

    function staffReceptionHoursFind(id) {
        var e, ev = null;
        /* XXX - Should recieve course as well */
        iterCourses(function (course) {
            if (!course.reception_hours)
                return;
            for (e = 0; e < course.reception_hours.length; e++) {
                if (course.reception_hours[e].staff_id == id)
                    ev = course.reception_hours[e];
            }
        });
        return ev;
    }

    ziggi.newDateConstructor = function (str) {
        if (str == null)
            return new Date();
        if (str instanceof Date) {
            return new Date(str);
        }

        var arr = str.split("T");
        var d = arr[0].split("-");
        var t = arr[1].split("Z")[0].split(":");
        return new Date(Date.UTC(d[0], (d[1] - 1), d[2], t[0], t[1], t[2]));
    }

    ziggi.dateString = function(date_start) {
        var htmp = "{day}";
        var start = ziggi.newDateConstructor(date_start);
        return htmp.replace(/\{day\}/, start.date());
    }

    ziggi.hourString = function(date_start, date_end) {
        var htmp = "{hour}";

        var start = ziggi.newDateConstructor(date_start),
            end = ziggi.newDateConstructor(date_end);
        return htmp.replace(/\{hour\}/, start.hours() +
                (date_end ? " - " + end.hours() : ""));
    }

    ziggi.timeRange = function (date_start, date_end, is_weekly) {
        var htmp = "{day} {hour}";

        var start = ziggi.newDateConstructor(date_start),
            end = ziggi.newDateConstructor(date_end);
        return htmp.replace(
                /\{day\}/, is_weekly ? ("יום " + shortDays[start.getDay()]) :
                    start.date()).
            replace(/\{hour\}/, start.hours() +
                (date_end ? " - " + end.hours() : ""));
    }

    ziggi.loadStaffInfo = function (id, force_reload) {
        if (!force_reload &&
            $("#staff-dialog").data("staff_id") === id) {
            if ($("#staff-dialog").dialog("isOpen"))
                $("#staff-dialog").dialog("close");
            else
                $("#staff-dialog").dialog("open");
            return;
        }
        $("#staff-dialog").data("staff_id", id);
        $.getJSON("staff/" + id, ziggi.staffInfo);
        $.getJSON("rank/" + id, ziggi.staffRank);
    }

    ziggi.staffInfo = function (data) {
        var cls = data.name.match(/[^ .'"]+/);
        if (cls) cls = cls[0];

        $("#staff-dialog div#image").removeClass().addClass(cls);
        var options = {
            method: 'POST',
            loadtext: 'טוען..',
            placeholder: 'הקלק על מנת לערוך',
            submitdata: { 'id': data.id, 'editable': true },
        };

        $("#staff-dialog span#email").editable('destroy');
        $("#staff-dialog span#phone").editable('destroy');
        $("#staff-dialog span#room").editable('destroy');
        $("#staff-dialog span#reception").editable('destroy');
        options.name = 'email';
        $("#staff-dialog span#email").html(data.email).editable("/staff", options);
        options.name = 'phone';
        $("#staff-dialog span#phone").html(data.phone).editable("/staff", options);
        options.name = 'room';
        $("#staff-dialog span#room").html(data.room).editable("/staff", options);
        options.name = 'reception';
        $("#staff-dialog span#reception").html(data.reception).editable("/staff", options);

        var ev, rec = "";
        ev = staffReceptionHoursFind(data.id);
        if (ev)
            rec = ziggi.timeRange(ev.date_start, ev.date_end, true);
        else
            rec = "הקלק על מנת לערוך";

        $("span#updated_at").html($.datepicker.formatDate('d/mm/yy', new Date(data.updated)));
        if (!data.updated_by)
            data.updated_by = "זיגי";
        $("span#updated_by").html(data.updated_by);

        $("#staff-dialog").dialog({
            minWidth: 450,
            resizable: false,
            height: 450,
            buttons: [
                { "text": "סגור", click: function () {
                    $(this).dialog("close");
                } }
            ],
            title: data.name
        });
    };

    ziggi.staffRank = function (data) {
        var max = 0, r;
        data.sums = [];
        data.sums[0] = data.avg = 0;
        for (r = 1; r <= 5; r++) {
            data.sums[r] = data.rank[r] + data.sums[r - 1];
            data.avg += data.rank[r] * r;
        }
        data.avg = data.sums[5] ? (data.avg / data.sums[5]).toPrecision(2) : 0;

        $("#rank-wrap").html($("#rank-template").tmpl(data));

        $(".rateit").rateit();
        function rateit(val) {
            $.post('/rank', { "id": data.id, "rank": val },
                ziggi.staffRank, "json");
        }

        $(".rateit").unbind('rated').bind('rated', function () {
            rateit($(this).rateit('value'));
        });
        $(".rateit").unbind('reset').bind('reset', function () {
            rateit(0);
        });
    }

    ziggi.showMore = function (element) {
        $(element).parent().hide().next().show();
        return false;
    }

    ziggi.sendRank = function (staff_id) {
        $("#user-rank-comment").addClass("loading");
        $.post('/rank', { "id": staff_id,
                "comment": $("#user-rank-comment").val()},
            ziggi.staffRank, "json");
    }

    ziggi.saveGroups = function() {
	$("#save-button button").addClass("saving");
        $.post('/groups', to_save, function (data) {
            $("#save-button button").removeClass("saving").attr("disabled", "disabled");
        }, "json");
    }

    function saveGroupsDelayed() {
        /* Aggregate groups to save bandwidth */
	$("#save-button button").removeAttr("disabled");
        clearTimeout(save_timer);
        save_timer = setTimeout(function () {
            ziggi.saveGroups();
        }, 1500);
    }

    function calcPointsAndHours() {
        var hours = 0, points = 0;

        iterCourses(function (course) {
            var g;
            if (!course.groups)
                return;
            for (g = 0; g < course.groups.length; g++) {
                if (course.groups[g].selected) {
                    hours += course.hours || 0;
                    points += course.points || 0;
                    return;
                }
            }
        });

        $("#points").html("&nbsp;נקודות זכות : " + points);
        $("#hours").html("&nbsp;שעות שבועיות : " + hours);
    }


    function saveGroup2Sched(grp, selected) {
        var g;
        for (g = 0; g < to_save.groups.length; g++) {
            if (to_save.groups[g].id == grp.id) {
                to_save.groups[g].selected = selected;
                break;
            }
        }
        if (g == to_save.groups.length)
            to_save.groups.push({ 'id': grp.id, 's': selected});
        grp.selected = selected;
        if (selected) {
            $('li[data-group="G' + grp.id + '"]').addClass("selected");
        }
        else
            $('li[data-group="G' + grp.id + '"]').removeClass("selected");
    }

    function groupSelect(grp, selected) {
        saveGroup2Sched(grp, selected);

        calcPointsAndHours();
        saveGroupsDelayed();
    }

    function eventSelect(ev, selected) {
        var e;
        if (typeof(selected) === "undefined")
            selected = !ev.selected;
        for (e = 0; e < to_save.events.length; e++) {
            if (to_save.events[e].id == ev.id) {
                to_save.events[e].s = selected;
                break;
            }
        }
        if (e == to_save.events.length)
            to_save.events.push({ 'id': ev.id, 's': selected});
        ev.selected = selected;
        if (selected)
            $("#E" + ev.id).addClass("selected");
        else
            $("#E" + ev.id).removeClass("selected");
        saveGroupsDelayed();
    }

    function eventHover(id, hover) {
        if ($.bbq.getState("m") !== undefined && $.bbq.getState("m") != "edit")
            return;
        if (!hover)
            $('#calendar').weekCalendar('removeUnsavedEvents');

        var grp = $("." + id);
        if (grp.length) {
            if (hover)
                grp.addClass("hovering");
            else
                grp.removeClass("hovering");
            return;
        }
        if (!hover)
            return;
        var e, events = [];
        if (id[0] == "E") {
            var ev = findEvent(id);
            createPersonalEvent(events, ev, "placeholder" + (
                ev.staff_id ? " reception" : ""));
        }
        else if (id[0] == "G") {
            var group = findGroup(id.substr(1));
            createEvents(events, group.course, group.group, "placeholder");
        }
        for (e = 0; e < events.length; e++) {
            events[e].id = null;
            $('#calendar').weekCalendar('updateEvent', events[e]);
        }
    }

    ziggi.groupSelectAll = function (number, selected) {
        var c, g, course = null;

        for (c = 0; !course && c < all_courses.length; c++) {
            if (all_courses[c].number === number)
                course = all_courses[c];
        }
        if (!course) return;

        for (g in course.groups)
            groupSelect(course.groups[g], selected);
        drawSchedule();
    };

    function eventCreate(start, end, $calendar) {
        var ev = { "id": 0, "date_start": start.notz().toJSON(), "date_end": end.notz().toJSON(),
            "title": "אירוע חדש" };
        $("#info").addClass("loading");
        $.post("/event", ev, function (data) {
            $("#info").removeClass("loading");
            all_events.push(data);
            $calendar.weekCalendar("removeUnsavedEvents");
            ziggi.refreshPersonalEvents();
            ziggi.refreshMiniCal();
            miniCalEvents();
            drawSchedule();
            //drawAll();
        }, "json");
    }

    function saveEvent(ev, settings) {
        var ret = ev;
        if ($.isPlainObject(settings)) {
            ret = ev;
            ev = { "id": settings.submitdata.id };
            ev[settings.submitdata.data] = ret;
        }
        $.post("/event", ev, function (data) {
            var e;
            for (e = 0; e < all_events.length; e++) {
                if (all_events[e].id == ev.id) {
                    var selected = all_events[e].selected;
                    all_events[e] = data;
                    all_events[e].selected = selected;
                    break;
                }
            }
            iterCourses(function (course) {
                if (!course.reception_hours)
                    return;
                for (e = 0; e < course.reception_hours.length; e++) {
                    if (course.reception_hours[e].id == ev.id) {
                        var selected = course.reception_hours[e].selected;
                        course.reception_hours[e] = data;
                        course.reception_hours[e].selected = selected;
                        return;
                    }
                }
            });
            /* TODO: Update courses with this value only */
            //this fix refresh prblem when editing the event
            ziggi.refreshPersonalEvents();
            ziggi.refreshMiniCal();
            miniCalEvents();
            drawSchedule();
        }, "json");
        return ret;
    }

    ziggi.deleteEvent = function (id) {
        ziggi.Confirm("האם אתה בטוח שברצונך למחוק את האירוע?</br>",
            function () {
                $.restDelete("/event/" + id, function (data) {
                    var e;
                    $("#event-dialog").dialog("close");
                    $("#results-dialog").dialog("close");
                    for (e = 0; e < all_events.length; e++) {
                        if (all_events[e].id == id)
                            all_events.splice(e, 1);
                    }
                    iterCourses(function (course) {
                        if (!course.reception_hours)
                            return;
                        for (e = 0; e < course.reception_hours.length; e++) {
                            if (course.reception_hours[e].id == id)
                                course.reception_hours.splice(e, 1);
                        }
                    });
                    $('#calendar').weekCalendar('removeEvent', "E" + id);
                    $("#event" + id).remove();
                    //this 4 lines resolve the refresh problem
                    ziggi.refreshPersonalEvents();
                    ziggi.refreshMiniCal();
                    miniCalEvents();
                    $('#calendar').weekCalendar("refresh");
                }, "json");
            });
    }

    function drawCourseInfo(course, cdiv) {
        /* XXX */
        for (h = 0; h < course.reception_hours.length; h++)
            ul.append(getPersonalInfoLi(course.reception_hours[h], "reception"));
    }

    function getPersonalInfoLi(ev, cls) {
        var hours, li_str = "<li class=\"event{class}\" id=\"event{id}\"><div><span class=\"title\">{title}</span></div>{hours}</li>";
        var htmp = "<div class=\"ctime\" title=\"{room}\">{range}</div>";
        var start = new Date(ev.date_start), end = new Date(ev.date_end);

        hours = htmp.replace(/\{room\}/, ev.location || "").
            replace(/\{range\}/, ziggi.timeRange(ev.date_start, ev.date_end, ev.weekly));

        return $(li_str.replace(/\{id\}/, ev.id).
            replace(/\{title\}/, ev.title).
            replace(/\{class\}/, (ev.selected ? " selected" : "")
                + " " + (cls || "")).
            replace(/\{hours\}/, hours)).
            data("event", ev);
    }

    function drawOtherEvents(cdiv) {
        return;
        /* XXX Put empty back */
        if (empty) {
            groups.html("לחץ על כל מקום פנוי במערכת להוספת אירוע חדש");
            div.append(groups);
            return;
        }
    }

    function drawCalendar() {
        switch ($.bbq.getState("m")) {
            case "edit":
            case "super":
            case undefined:
                drawSchedule();
                break;
            case "calendar":
                modeCalendar();
                break;
            default:
                break;
        }
    }

    function drawAll() {
        drawCalendar();
        drawCourses();
    };

    ziggi.Message = function (title, msg) {
        $("#results-dialog div").html(msg).removeClass("loading");
        $("#results-dialog").dialog({
            minWidth: 350,
            resizable: false,
            height: 200,
            modal: true,
            title: title,
            buttons: [
                { "text": "סגור", click: function () {
                    $(this).dialog("close");
                } }
            ]
        });
    };

    ziggi.Error = function (err) {
        ziggi.Message("מצטערים, אבל אירעה שגיאה", err);
    }

    ziggi.Confirm = function (msg, ok_cb) {
        $("#results-dialog div").html(msg);
        $("#results-dialog").dialog({
            minWidth: 350,
            resizable: false,
            height: 200,
            modal: true,
            title: "אישור",
            buttons: [
                { "text": "אישור", click: ok_cb },
                { "text": "ביטול", click: function () {
                    $(this).dialog("close");
                } }
            ],
        });
    };

    ziggi.confirmView = function (msg) {
        $("#results-dialog div").html(msg);
        $("#results-dialog").dialog({
            minWidth: 350,
            resizable: false,
            height: 200,
            modal: true,
            title: "אישור",
            buttons: [
                { "text": "אישור", click: function () {
                    $(this).dialog("close");
                } },
            ]
        });
    };

    ziggi.dialogTwoOptions = function (title, msg, ok_cb, ok_cb_text) {
        $("#results-dialog div").html(msg);
        $("#results-dialog").dialog({
            minWidth: 500,
            height: 300,
            resizable: false,
            modal: true,
            title: title,
            buttons: [
                { "text": ok_cb_text, click: ok_cb },
                { "text": "ביטול", click: function () {
                    $(this).dialog("close");
                } }
            ]
        });
    }

    ziggi.dialogOneOption = function (title, msg, ok_cb_text, ok_cb, height) {
        $("#results-dialog div").html(msg);
        $("#results-dialog").dialog({
            minWidth: 500,
            height: (height ? height : 300),
            resizable: false,
            modal: true,
            title: title,
            buttons: [
                { id: "dialog-btn-save", "text": (ok_cb_text ? ok_cb_text : "סגור" ), click: (ok_cb ? ok_cb : function () {
                    $(this).dialog("close");
                }) }
            ]
        });
    }

    function courseByNumber(number) {
        var c;
        for (c = 0; c < all_courses.length; c++) {
            if (all_courses[c].number == number)
                return all_courses[c];
        }
        return null;
    }

    function contains(a, obj) {
        var i = a.length;
        while (i--) {
            if (a[i].id === obj.id) {
                return true;
            }
        }
        return false;
    }

    ziggi.addCourses = function (data) {
        var g, s, c;
        if (typeof data === "string")
            data = $.parseJSON(data);

        for (c = 0; c < all_courses.length && all_courses[c].number != data.number; c++);
        for (var i = 0; i < data.length; i++) {
            if (!contains(all_courses, data[i])) {
                all_courses[c] = data[i];
                c++;
            }
        }

        drawAll();
    };
    /* Add course to list of courses */
    ziggi.addCourse = function (data, is_search) {
        var g, s, c;
        if (typeof data === "string")
            data = $.parseJSON(data);

        /* Go over groups - if only single group - select it */
        if (is_search) {
            if (data.groups.length == 1)
                groupSelect(data.number, data.groups[0]);
            drawSchedule();
            /* TODO: Auto select Tirgul as well */
        }

        for (c = 0; c < all_courses.length && all_courses[c].number != data.number; c++);
        all_courses[c] = data;
        drawAll();
    }

    loadCourseByNumber = function (number, name) {
        ziggi.addCourse({ 'number': number, 'name': name}, 0);
        $.getJSON('/course/' + number, function (data) {
            if (data['name']) {
                ziggi.addCourse(data, 0);
                return;
            }
        });
    }

    function removeCourseByNumber(number) {
        var c;
        for (c = 0; c < all_courses.length &&
            all_courses[c].number != number
            ; c++);
        all_courses.splice(c, 1);
        drawAll();
    }

    ziggi.removeCourse = function (number) {
        ziggi.Confirm(
            "האם אתה בטוח שברצונך להסיר את הקורס " + number + " מהרשימה?",
            function () {
                $.getJSON("/remove/" + number, function (data) {
                    removeCourseByNumber(number);
                    $("#results-dialog").dialog('close');
                });
            });
    }

    ziggi.addCourseFromSearch = function () {
        $("#results-dialog").dialog('close');
        var number = $(this).data('key'), name = $(this).data('name');
        ziggi.addCourse({ 'number': number, 'name': name}, 0);
        $.getJSON('/course/' + number, function (data) {
            if (data['id']) {
                $.getJSON('/add/course/' + data['id'], function (stub) {
                    ziggi.addCourse(data, 1);
                });
                return;
            }
            removeCourseByNumber(number);
            ziggi.Error("לא נמצא קורס מספר " + number + " יתכן שהקורס לא פעיל בסמסטר שנבחר");
        });
    }

    ziggi.addEventFromSearch = function () {
        $("#results-dialog").dialog('close');
        var number = $(this).data('key'), name = $(this).data('name');
        $.getJSON('/add/event/' + $(this).data('id'), function (data) {
            if (!findEvent(data.id)) {
                all_events.push(data);
                drawAll();
            }
        });
    }

    function createEvent(id, name, start, end, title, content, cls) {
        var e = {}
        e['id'] = id;
        e['name'] = name;
        e['start'] = start;
        e['end'] = end;
        e['title'] = title;
        e['content'] = content;
        e['className'] = cls;
        e['readOnly'] = true;

        return e;
    }

    function getToday() {
        var date = new Date();

        /* Date is either today, or first week of semester */
        if (date < semester.start)
            date = semester.start;

        date.setUTCHours(0, 0);
        return date;
    }

    function getSundayMS() {
        var sunday = weekly_start.getTime();
        var monday = new Date();
        monday.setTime(sunday + 24 * HOUR);
        // Damn DST on saturday night
        if (weekly_start.getTimezoneOffset() != monday.getTimezoneOffset()) {
            sunday -= MINUTE * (weekly_start.getTimezoneOffset() - monday.getTimezoneOffset());
        }
        return sunday;
    }

    function createEvents(events, course, group, cls) {
        var h, sunday;
        var addIcon, minusIcon;

        addIcon = '<span class="ui-icon ui-icon-plus" title="בחר קבוצה"></span>';
        minusIcon = '<span class="ui-icon ui-icon-minus" title="הסר קבוצה"></span>';
        sunday = getSundayMS();
        for (h = 0; h < group.hours.length; h++) {
            var hour = group.hours[h], grp;
            var s, e;

            s = ziggi.newDateConstructor(hour.date_start);
            e = ziggi.newDateConstructor(hour.date_end);
            s.setTime(sunday + s.getUTCDay() * DAY + s.getUTCHours() * HOUR);
            e.setTime(sunday + e.getUTCDay() * DAY + e.getUTCHours() * HOUR);

            if (e - s == HOUR)
                cls = cls + " one-hour";

            grp = createEvent(course.number + "_" + group.number, course.number,
                s, e, "(" + group.number + ") " + course.name +
                    (isReadOnly ? '' : (group.selected ? minusIcon : addIcon)),
                (group.staff.name ? group.staff.name : "") + "<br/>" +
                    "<span><a class='' href='#m=map' onclick='ziggi.markRoom(\"" + getRoomFromString(hour.room) + "\")' role='button' aria-disabled='false'>" + hour.room + "</a></span>",
                course.number + " " + group.type + " " + "G" + group.id + " " + cls || "");

            grp['course'] = course;
            grp['group'] = group;
            events.push(grp);
        }
        return events;
    }

    function createPersonalEvent(events, ev, cls) {
        var sunday = getSundayMS();
        var s, e, tz;

        /* XXX: Can add only if in current week */
        s = ziggi.newDateConstructor(ev.date_start);
        e = ziggi.newDateConstructor(ev.date_end);
        if (ev.weekly) {
            var sun = $.weekCalendar.getSunday(s).getTime();
            s = new Date(sunday + s.getTime() - sun);
            sun = $.weekCalendar.getSunday(e).getTime();
            e = new Date(sunday + e.getTime() - sun);
        }
        else {
            tz = s.getTimezoneOffset() * MINUTE;
            s.setTime(s.getTime() + tz);
            e.setTime(e.getTime() + tz);
        }

        var tmpl = {};
        ev.isReadOnly = isReadOnly;
        var new_ev = createEvent("E" + ev.id, ev.title, s, e,
            $("#event-template").tmpl(ev),
            $("#event-location-template").tmpl(ev),
            "E" + ev.id + " event " + cls);
        new_ev['readOnly'] = false;
        new_ev['isManual'] = true;
        events.push(new_ev);
        return events;
    }

    function createFullDayEvent(events, ev) {
        var s, e, new_ev;
        s = new Date(ev.date_start);
        e = new Date(ev.date_end);
        s.setHours(0);
        e.setHours(0);
        s.setMinutes(1);
        e.setMinutes(1);
        new_ev = createEvent("fullday_" + ev.id, ev.title, s, e,
            ev.title, "", "full-day");
        events.push(new_ev);
        return events;
    }

    function findEvent(id) {
        var e, ev = null;
        if (id[0] == 'E') id = parseInt(id.substr(1));
        for (e = 0; e < all_events.length; e++) {
            if (all_events[e].id == id)
                return all_events[e];
        }
        iterCourses(function (course) {
            if (!course.reception_hours)
                return;
            for (e = 0; e < course.reception_hours.length; e++) {
                if (course.reception_hours[e].id == id)
                    ev = course.reception_hours[e];
            }
        });
        return ev;
    }

    function findGroup(id) {
        var ret = { "course": null, "group": null};
        iterGroups(function (course, group) {
            if (group.id == id) {
                ret.course = course;
                ret.group = group;
            }
        });
        return ret;
    }

    function updateEvent(event) {
        var ev = findEvent(event.id);
        if (!ev)
            return;
        /* For now - just update start and end time */
        var s = new Date(event.start), e = new Date(event.end);
        var j = { "id": ev.id, "date_start": s.notz().toJSON(),
            "date_end": e.notz().toJSON() };
        ev.date_start = s;
        ev.date_end = e;
        $(".groups li#event" + ev.id + " .ctime").html(
            ziggi.timeRange(ev.date_start, ev.date_end, ev.weekly));

        $("#info").addClass("loading");
        $.post("/event", j, function (data) {
            /* XXX Refresh page in case of error */
            $("#info").removeClass("loading");
        }, "json");
    }

    function createMessageEvent(events, date, stime, etime, id, name, title, content) {
        if (!date)
            return;
        if (typeof(date) === "string")
            date = new Date(date);
        var s = new Date(), e = new Date(), tz = date.getTimezoneOffset() * MINUTE;
        s.setTime(date.getTime() + stime * HOUR + tz);
        e.setTime(date.getTime() + etime * HOUR + tz);
        events.push(createEvent(id, name, s, e, content ? title : "", content ||
            title, "msg"));
    }

    function get_weekly_data(start, end) {
        var events = [];

        weekly_start = start;
        weekly_end = end;

        if (start < semester.end || isSuper) {
            iterGroups(function (course, group) {
                if (!group.selected && !isSuper)
                    return;
                createEvents(events, course, group,
                    (isSuper && !group.selected) ? "placeholder" : "");
            });
            if (isSuper)
                return events;

            /* Add Course events */
            iterCourses(function (course) {
                if (!course.events)
                    return;
                for (e = 0; e < course.events.length; e++) {
                    ev = course.events[e];
                    if (!ev.selected)
                        continue;
                    createPersonalEvent(events, ev, "event");
                }

                for (e = 0; e < course.reception_hours.length; e++) {
                    ev = course.reception_hours[e];
                    if (!ev.selected)
                        continue;
                    createPersonalEvent(events, ev, "reception");
                }
            });
        }
        else {
            /* XXX Not exactly - exams can be before end  (Bohan) */
            /* Add Exams */
            for (c = 0; c < all_courses.length; c++) {
                for (e = 0; all_courses[c].exams &&
                    e < all_courses[c].exams.length; e++) {
                    var exam = all_courses[c].exams[e];
                    createMessageEvent(events, exam.date_start, 0, 1, "e" + e,
                        "e" + e, 'מועד ' + exam.type, all_courses[c].name + "<br/>" + ziggi.timeRange(exam.date_start, exam.date_end, false));
                }
            }
        }

        /* Add personal events */
        for (e = 0; e < all_events.length; e++) {
            ev = all_events[e];
            /* Add holidays */
            if (!ev.university_id) {
                createFullDayEvent(events, ev);
                continue;
            }
            if (!ev.selected) {
                continue;
            }
            var evDate = new Date(ev.date_start);
            if ((ev.weekly == true) && (new Date(evDate) > new Date(start))) {
                if (new Date(evDate) < new Date(end))
            createPersonalEvent(events, ev, "event");
                continue;
        }
            createPersonalEvent(events, ev, "event");
        }
        /* Add Semester Events */
        createMessageEvent(events, semester.start, 8, 8.5, 'open',
            'open_semester', 'פתיחת סמסטר ' + semester.name);
        createMessageEvent(events, semester.end, 8, 8.5, 'close',
            'close_semester', 'סיום סמסטר ' + semester.name);
        createMessageEvent(events, semester.exams_start, 8, 8.5, 'open_exam',
            'open_exam', 'תחילת בחינות סמסטר ' + semester.name);
        createMessageEvent(events, semester.exams_end, 8, 8.5, 'close_exam',
            'close_exam', 'סיום בחינות סמסטר ' + semester.name);

        return events;
    }

    function get_advanced_data(start, end) {
        var events = [];

        weekly_start = start;
        weekly_end = end;

        if (true) { // always show groups. need to refactor!
            iterGroups2(function (course, group) {
                if (!group.selected)
                    return;

                createEvents(events, course, group,
                    (isSuper && !group.selected) ? "placeholder" : "");
            });
        }
        return events;
    }

    function get_monthly_data(start, end) {
        var sunday = $.weekCalendar.getSunday(semester.start);
        var e, c, events = [];
	var end = $.weekCalendar.getSaturday(semester.exams_end);
	var d = sunday.getTime();

	for (; d <= end; d += DAY)
	{
	    var day = new Date(d);
	    hourEvent(events, sunday, day, ziggi.dateString(day), "");
	}
        addToHourEvent(events, new Date(), "", "wc-today", "drawCurrentTimeLine");
        addToHourEvent(events, semester.start, 'פתיחת סמסטר ' + semester.name);
        addToHourEvent(events, semester.end, 'סיום סמסטר ' + semester.name,
		ziggi.dateString(semester.end));
        addToHourEvent(events, semester.exams_start, 'תחילת בחינות סמסטר ' +
            semester.name, ziggi.dateString(semester.exams_start));
        addToHourEvent(events, semester.exams_end, 'סיום בחינות סמסטר ' +
            semester.name, ziggi.dateString(semester.exams_end));

        for (c = 0; c < all_courses.length; c++) {
            var exams = all_courses[c].exams;
            if (!exams) continue;
            for (e = 0; e < exams.length; e++) {
                var exam = exams[e];
                addToHourEvent(events, exam.date_start,
			ziggi.hourString(exam.date_start, exam.date_end) +
			'מועד ' + exam.type  + all_courses[c].name);
            }
        }

        /* Holidays */
	if (0) /* FIXME */
	{
        for (e = 0; e < all_events.length; e++) {
            ev = all_events[e];
            //remove this if you don't want all events show in monthly view
            //if (ev.university_id)
            //continue;
            if (!ev.selected)
                continue;
            if (ev.weekly) {
                var evDate = new Date(ev.date_start);
                while (new Date(evDate) <= new Date(semester.end)) {
                    hourEvent(events, sunday, evDate, ev.title, "");
                    evDate.setTime(evDate.getTime() + 1000 * 60 * 60 * 24 * 1 * 7);
                }
            }
            else
            hourEvent(events, sunday, ev.date_start, ev.title, "");
        }
	}

        return events;
    }

    function calendarExtraElements() {
        $("button").button();
        $("#search-menu").buttonset();
        $("#cal-buttons, #zoom-buttons, #semester-buttons, #advancedMenu2").buttonset();
        $("#search-course, #recommended-btn").buttonset();
	$("#save-button").buttonset();

        if (isReadOnly)
            return;
        title = "לחץ לעבור בין מסך מלא למצב עריכת מערכת";

        $(".wc-scrollbar-shim").attr('title', title).html($("<span/>").
                addClass("ui-icon ui-icon-triangle-1-nw")).unbind('click').
            click(function () {
                $(".south,.east,.north,#info").toggle();
                $(".wc-scrollbar-shim span.ui-icon").toggleClass("ui-icon-triangle-1-nw").toggleClass("ui-icon-triangle-1-se");
                $(window).trigger('resize');
            });
        //Tooltip is problamistic. We disable it for now.
        /*$(document).tooltip({
            content: function () {
                return $(this).attr('title');
         } });*/
    }

    ziggi.zoom = function (zoom) {
        var h = $('#calendar').weekCalendar("timeslotHeight");
        if (zoom < 0 && h < 16) return;
        if (zoom > 0 && h > 30) return;
        weeklyCalInit(h + zoom * 2);
    }

    function manualEventClick(id, element, event) {
        var ev = findEvent(id);
        if (element.hasClass("ui-icon-minus")) {
            if (ev.isReadOnly == false)
                ziggi.deleteEvent(ev.id);
            else
            eventSelect(ev, false);
        }
        else if (element.hasClass("ui-icon-calculator"))
            saveEvent({ "id": ev.id, "weekly": true});
        else if (element.hasClass("ui-icon-arrowrefresh-1-s"))
            saveEvent({ "id": ev.id, "weekly": false});
        else if (element.hasClass("ui-icon-pencil")) {
            var options = {
                placeholder: '',
                submitdata: { 'id': ev.id, 'data': 'title' },
                callback: function (val) {
                    $(this).editable("destroy");
                    $(this).html(val);
                }
            };
            $("div.edit", element.parent()).editable(
                saveEvent, options).trigger('click');
            $("input", element.parent()).select();
        }
        else if (element.attr("disabled") != "disabled" &&
            (element.hasClass("ui-icon-locked") ||
                element.hasClass("ui-icon-unlocked"))) {
            $("#event-menu a").removeClass("selected");
            if (!ev.public)
                $("#event-menu-private").addClass("selected");
            else
                $("#event-menu-public").addClass("selected");
            $("#event-menu").show().position({
                my: "right top",
                of: event
            });
            $(document).one("click", function () {
                $("#event-menu").hide();
            });
            $("#event-menu a").click(function () {
                var save = { "id": ev.id };
                save['public'] = $(this).attr("id") != "event-menu-private";
                saveEvent(save);
                $(document).trigger("click");
                return false;
            });
        }
    }

    function weeklyCalInit(timeslotHeight) {
        var $calendar = $('#calendar');
        calendarInit = "week";

        $calendar.html("");
        $("body").removeClass("monthly").removeClass("summary").removeClass("map").removeClass("advanced");
        $calendar.weekCalendar($.extend({}, calOptions, {
            date: getToday(),
            dateFormat: "M d, Y",
            businessHours: {start: 8, end: 22, limitDisplay: true},
            drawCurrentTimeLine: true,
            buttons: !isSuper,
            buttonsContainer: '#cal-buttons',
            timeslotHeight: timeslotHeight ? timeslotHeight : 20,
            buttonText: {
                today: "היום",
                lastWeek: "&nbsp;&lt;&nbsp;",
                nextWeek: "&nbsp;&gt;&nbsp;"
            },
            buttonTitle: {
                today: "עבור להיום",
                lastWeek: "שבוע אחורה",
                nextWeek: "שבוע קדימה"
            },
            readonly: isReadOnly,
            minDate: semester.start,
            maxDate: semester.exams_end || semester.end,
            draggable: function (calEvent, element) {
                return !calEvent.readOnly && !isReadOnly;
            },
            resizable: function (calEvent, element) {
                return !calEvent.readOnly && !isReadOnly;
            },
            eventDrop: function (newCalEvent, calEvent, element) {
                if (isReadOnly) return false;
                updateEvent(newCalEvent);
                ziggi.refreshPersonalEvents();
                ziggi.refreshMiniCal();
                miniCalEvents();
            },
            eventResize: function (newCalEvent, calEvent, element) {
                if (isReadOnly) return false;
                updateEvent(newCalEvent);
                ziggi.refreshPersonalEvents();
                ziggi.refreshMiniCal();
                miniCalEvents();
            },
            eventNew: function (calEvent, element) {
                if (isReadOnly) return false;
                eventCreate(calEvent.start, calEvent.end, $calendar);
            },
            eventClick: function (calEvent, element, event) {
                if (isReadOnly) return false;
                if (!element.hasClass("ui-icon"))
                    return false;
                if (calEvent.isManual)
                    manualEventClick(calEvent.id, element, event);
                else {
                    groupSelect(calEvent.group,
                        element.hasClass("ui-icon-plus"));
                    drawSchedule();
                }
                return false;
            },
            weeklyClick: function (event) {
                if (isReadOnly) return false;
                var self_e = event;
                var day = $('#calendar').weekCalendar("getTimeFromEvent", event);
                day.notz();
                $("#week-menu #week-menu-day").html(ziggi.timeRange(day, null, true));
                // Add all courses in this hour
                $("#week-menu .group-hour").remove();
                iterHours(function (course, group, hour) {
                    if (group.selected)
                        return;
                    var start = ziggi.newDateConstructor(hour.date_start);
                    var end = ziggi.newDateConstructor(hour.date_end);

                    if (start.getDay() != day.getDay() ||
                        start.getUTCHours() > day.getUTCHours() ||
                        end.getUTCHours() < day.getUTCHours()) {
                        return;
                    }

                    $("#week-menu #week-menu-day").after(
                        "<li class=\"group-hour ui-menu-item "
                            + group.type + "\" data-group=\"G" + group.id + "\">" +
                            "<a href=\"#\">" +
                            course.name + " (" + group.number + ")" + "</a></li>");
                });
                attachHoursEvents();
                $("#week-menu").show().position({
                    my: "right top",
                    of: event
                });
                $(document).one("click", function () {
                    $("#week-menu").hide();
                });
                $("#add-event a").unbind("click").bind("click", function () {
                    var e = $.Event("mousedown", { pageX: self_e.pageX, pageY: self_e.pageY });
                    $(self_e.target).trigger(e, true).trigger("mouseup", true);
                });
                $("#search-free-hour a").unbind("click").bind("click", function () {
                    searchFreeHour(day);
                });
                return false;
            },
            eventMouseover: function (calEvent, $event) {
                if (!calEvent.course)
                    return;
                $("." + calEvent.course.number.crs() + "_" + calEvent.group.number).addClass("hovering");
            },
            eventMouseout: function (calEvent, $event) {
                if (!calEvent.course)
                    return;
                $("." + calEvent.course.number.crs() + "_" + calEvent.group.number).removeClass("hovering");
            },
            data: function (start, end, callback) {
                callback(get_weekly_data(start, end));
            },
            columnHeader: "סמסטר  " + semester.name +
                (isReadOnly ? "<br/>(קריאה בלבד)" : ""),
            hideDate: false
        }));
    }

    function loadCourses() {
        var i;
        for (i = 0; i < g_courses.length; i++) {
            if (g_courses[i].hours)
                ziggi.addCourse(g_courses[i], 0);
            else
                loadCourseByNumber(g_courses[i].number, g_courses[i].name);
        }
    }

    function setSelectButtons() {
        $('#select_semester').change(function () {
            window.location.replace('user/' + $(this).val());
        });
    }

    ziggi.staticDialog = function (title, url, cb) {
        $("#static-dialog div").load(url, function () {
            $("#static-dialog").dialog({
                minWidth: 800,
                resizable: false,
                height: 450,
                maxHeight: 450,
                title: title,
                buttons: [
                    { "text": "סגור", click: function () {
                        $(this).dialog("close");
                    } }
                ],
            });
            if (cb) cb();
        });
    }

    ziggi.changePassword = function () {
        ziggi.staticDialog("שינוי סיסמא", "/change_password", function () {
            var pm;

            function PassModel() {
                this.password = ko.observable("");
                this.isValid = ko.computed(function () {
                    return this.password().length > 2;
                }, this);
            }

            pm = new PassModel();
            $("#change-pass").unbind('click').click(function () {
                $.getJSON("/pass", { "password": $.sha1(pm.password()) },
                    function (res) {
                        $("#pass-answer").html("הסיסמא עודכנה בהצלחה");
                    });
            });
            ko.applyBindings(pm, document.getElementById("ko-pass"));
        });
    }

    ziggi.exportImage = function () {
        b = $("#calendar");
        html2canvas(b, {
            onrendered: function (canvas) {
        ziggi.staticDialog("שמור כתמונה", "/export_image", function () {
                    $("#canvas-container").html(canvas);
                });
                }
            });
    };

    ziggi.putImage = function () {
        html2canvas($("#calendar"), {
            onrendered: function (canvas) {
                canvas.toBlob(function (blob) {
                    saveAs(blob, "yourSchedule.jpg");
                });
            }
        });
    };

    function modeEdit(is_super) {
        isSuper = is_super;
        if (isSuper)
            $("body").addClass("super");
        else
            $("body").removeClass("super");

        weeklyCalInit();
        drawSchedule();
    }

    function get_summary_data() {
        var c, t, s, e, ms, me, events = [];
        var t = getToday();
        var tz = t.getTimezoneOffset() * MINUTE;
        var sunday = $.weekCalendar.getSunday(t).getTime();

        e = new Date(sunday);
        e.setTime(e.getTime() + 8 * HOUR + tz);

        for (c = 0; c < summaryData.length; c++) {
            var course = summaryData[c];
            s = new Date(e);
            s.setTime(e.getTime());
            e = new Date(sunday);
            e.setTime(s.getTime() + (course.staff.length || 1) * 0.5 * HOUR);

            events.push(createEvent("", "", s, e, "", course.name + "<br/>" + course.number, ""));

            for (t = 0; t < course.staff.length; t++) {
                var staff = course.staff[t];

                ms = new Date(s);
                ms.setTime(ms.getTime() + DAY + t * 0.5 * HOUR);

                me = new Date(ms);
                me.setTime(me.getTime() + 0.5 * HOUR);
                events.push(createEvent(staff.id, "", ms, me, "", staff.name, "staff_name"));

                ms = new Date(ms);
                ms.setTime(ms.getTime() + DAY);
                me = new Date(ms);
                me.setTime(me.getTime() + 0.5 * HOUR);
                events.push(createEvent("", staff.id, ms, me, "", staff.email, "staff_email"));

                ms = new Date(ms);
                ms.setTime(ms.getTime() + DAY);
                me = new Date(ms);
                me.setTime(me.getTime() + 0.5 * HOUR);
                events.push(createEvent("", staff.id, ms, me, "", staff.phone, "staff_phone"));

                ms = new Date(ms);
                ms.setTime(ms.getTime() + DAY);
                me = new Date(ms);
                me.setTime(me.getTime() + 0.5 * HOUR);
                events.push(createEvent("", staff.id, ms, me, "", staff.room, "staff_room"));

                var ev, rec = "...";
                ev = staffReceptionHoursFind(staff.id);
                if (ev)
                    rec = ziggi.timeRange(ev.date_start, ev.date_end, true);
                ms = new Date(ms);
                ms.setTime(ms.getTime() + DAY);
                me = new Date(ms);
                me.setTime(me.getTime() + 0.5 * HOUR);
                events.push(createEvent("", staff.id, ms, me, "", staff.reception, "staff_reception"));
            }
        }

        return events;
    }

    function summaryCalInit() {
        var $calendar = $('#calendar');
        calendarInit = "summary";

        $calendar.html("");
        $("body").removeClass("monthly").addClass("summary").removeClass("map");
        $calendar.weekCalendar($.extend({}, calOptions, {
            date: getToday(),
            dateFormat: "M d, Y",
            businessHours: {start: 8, end: 22, limitDisplay: true},
            drawCurrentTimeLine: false,
            data: function (start, end, callback) {
                callback(get_summary_data());
            },
            timeslotHeight: 20,
            calendarAfterLoad: function (calendar) {
                calendarExtraElements();
                var options = {
                    method: 'POST',
                    loadtext: 'טוען..',
                    placeholder: '...',
                    submitdata: function () {
                        return { 'id': $($(this).parent()).attr('sid'),
                            'editable': true };
                    }
                };
                options.name = 'email';
                $(".staff_email .wc-title").editable("/staff", options);
                options.name = 'phone';
                $(".staff_phone .wc-title").editable("/staff", options);
                options.name = 'room';
                $(".staff_room .wc-title").editable("/staff", options);
                options.name = 'reception';
                $(".staff_reception .wc-title").editable("/staff", options);
            },
            eventRender: function (calEvent, element) {
                element.attr('sid', calEvent.name);
                return element;
            },
            eventClick: function (calEvent, element, event) {
                if (calEvent.className == "staff_name")
                    ziggi.loadStaffInfo(calEvent.id);
            },
            daysToShow: 6,
            longDays: ['קורס', 'מרצה', 'אימייל', 'טלפון', 'חדר', 'שעות קבלה', '&nbsp;'],
            columnHeader: "סמסטר  " + semester.name,
            hideDate: true
        }));
    }

    function modeSummary() {
        $.getJSON("/summary", function (data) {
            summaryData = data;
            if (calendarInit != "summary")
                summaryCalInit();
            else
                $('#calendar').weekCalendar("refresh");
        });
    }

    ziggi.markRoom = function (id) {
        $("#calendar").data("roomname", id);
    }

    ziggi.modeMap = function () {
        if (typeof(google) === "undefined") {
            $("div#calendar").html("");
            $("body").addClass("map").removeClass("monthly").removeClass("summary").removeClass("advanced");
            $.getScript('http://maps.googleapis.com/maps/api/js?key=&sensor=false&language=he&callback=ziggi.map', function () {
            });
        }
        else
            loadMap();
    };

    ziggi.showRecommendedFill = function (recommended_call) {
        var divbody = $("<div/>");
        var results =
            "<h2>טוען נתונים, אנא המתן...</h2><div id='res-loading' class='loading'></div>";
        divbody.attr("id", "res-result").html(results);
        //var div = $("#results-dialog div").html(results);
        ziggi.dialogOneOption("עדכון נתונים"
            , divbody
            , (recommended_call ? "שמור והמשך" : "שמור")
            , function () {
                var degree = $("select#degree :selected").val();
                var department = $("select#department :selected").val();
                var year_in_degree = $("select#year_in_degree :selected").val();
                $("#rec-degree").css('color', 'black');
                $("#rec-department").css('color', 'black');
                if (!degree) {
                    $("#rec-degree").css('color', 'red');
                } else if (!department) {
                    $("#rec-department").css('color', 'red');
                } else {
                    $.post("/save_degree_data", {"degree": degree, "department": department, "year_in_degree": year_in_degree},
                        function (data) {
                            var jsondata = JSON.parse(data);
                            if (jsondata["success"] == true) {
                                if (recommended_call) {
                                    ziggi.showRecommended();
                                } else {
                                    ziggi.dialogOneOption("עדכון נתונים", "הנתונים נשמרו בהצלחה");
                                }
                            } else {
                                ziggi.dialogOneOption("שגיאה", "אירעה שגיאה בעת שמירת הנתונים");
                            }
                        });
                }
            }
            , 320);
        $("#dialog-btn-save").attr("disabled", true);
        $.getJSON("/recommended", function (data) {
            if (data["status"] == "failed") {
                ziggi.dialogOneOption("שגיאה", "אירעה שגיאה לא ידועה");
                return;
            }
            var degrees = data["degrees"];
            var departments = data["departments"];
            var curr_degree = data['degree'];
            var curr_department = data['department'];
            var curr_year = data['year_in_degree'];

            var degreeP = $("<p/>").append($("<span/>").attr("id", "rec-degree").html("*רמת תואר: "));
            var selectDegrees = $("<select/>").attr("id", "degree");
            for (var i = 0; i < degrees.length; i++) {
                var option = $("<option/>").attr("value", degrees[i]["value"]).html(degrees[i]["text"]);
                if (degrees[i]["value"] == curr_degree) {
                    option.attr("selected", true);
                }
                selectDegrees.append(option);

    }
            degreeP.append($("<br/>")).append(selectDegrees);

            var departmentP = $("<p/>").append($("<span/>").attr("id", "rec-department").html("*מחלקה: "));
            var selectDepartments = $("<select/>").attr("id", "department");
            for (var i = 0; i < departments.length; i++) {
                var option = $("<option/>").attr("value", departments[i]["value"]).html(departments[i]["value"] + " - " + departments[i]["text"]);
                if (departments[i]["value"] == curr_department) {
                    option.attr("selected", true);
                }
                selectDepartments.append(option);
            }
            departmentP.append($("<br/>")).append(selectDepartments);

            var yearP = $("<p/>").append($("<span/>").attr("id", "rec-currYear").html("שנה נוכחית בתואר: "));
            var selectYear = $("<select/>").attr("id", "year_in_degree");
            var years = ["א", "ב", "ג", "ד", "ה", "ו", "ז", "ט"];
            for (var i = 0; i < years.length; i++) {
                var option = $("<option/>").attr("value", (i + 1)).html(years[i]);
                if (curr_year == (i+1)) {
                    option.attr("selected", true);
                }
                selectYear.append(option);
            }
            yearP.append($("<br/>")).append(selectYear);

            $("#results-dialog div").html("").append(degreeP).append(departmentP).append(yearP);
            $("#dialog-btn-save").attr("disabled", false);
        });
    }
    function modeAdvanced() {
        advancedCalInit(0);
    }

    ziggi.resetSchedBuild = function () {
        worker.terminate();
        worker = null;
        updateSchedBuilderUI('init');
        asb_scheds_prev = [];
        asb_scheds_next = [];
        myCourses.data = [];
        myCourses.saved = false;
        //myCourses=null;
        updateASBNavButtons();
        drawAdvancedSchedule();
    };

    var asb_scheds_prev = [];
    var asb_scheds_next = [];

    ziggi.saveBuildSched = function () {
        $("#info").addClass("loading");
        all_courses = myCourses.data;
        var groups_to_save = { "groups": [], "events": [] };
        for (var i = 0; i < all_courses.length; i++) {
            var course = all_courses[i];
            for (var j = 0; j < course.groups.length; j++) {
                var grp = course.groups[j];
                groups_to_save.groups.push({ 'id': grp.id, 's': grp.selected});
                if (grp.selected) {
                    $('li[data-group="G' + grp.id + '"]').addClass("selected");
                }
                else
                    $('li[data-group="G' + grp.id + '"]').removeClass("selected");

            }
        }

        $.post('/groups', groups_to_save, function (data) {
            $("#info").removeClass("loading");
        }, "json");


        return;

    };

    ziggi.saveSchedBuild4Cmpr = function () {
        if (myCourses.data != null && myCourses.data.length > 0) {
            myCourses.saved = !myCourses.saved;
            updateASBNavButtons();
        }
    };

    ziggi.getPrevBuildSched = function () {
        if (asb_scheds_prev.length > 0) {
            if (myCourses.saved) {
                asb_scheds_next.push(myCourses);
            }

            myCourses = asb_scheds_prev.pop();
            drawAdvancedSchedule();
        }

        //updateASBNavButtons();
    };

    ziggi.nextBuildSched = function () {
        if (myCourses.saved) {
            asb_scheds_prev.push(myCourses);
        }

        if (asb_scheds_next.length > 0) {
            //restore saved sched
            myCourses = asb_scheds_next.pop();
            drawAdvancedSchedule();
        } else {
            //build new sched
            worker.postMessage({cmd: 'buildNext'});
        }

        //updateASBNavButtons();
    };

    function updateASBNavButtons() {
        if (asb_scheds_prev.length > 0) {
            //$("#asb_prev").attr('disabled','false');
            //$("#asb_prev").prop('disabled', false);
            $("#asb_prev").removeAttr('disabled').removeClass('ui-state-disabled');
        } else {
            //$("#asb_prev").attr('disabled', 'disabled');
            //$("#asb_prev").prop('disabled', true);
            $("#asb_prev").attr('disabled', true).addClass('ui-state-disabled');
        }

        if (myCourses.saved) {
            $("#saveSchedFuture").html("<span class='ui-button-text'>מחק מהשוואה</span>");
        } else {
            $("#saveSchedFuture").html("<span class='ui-button-text'>שמור להשוואה</span>");
        }
    }

    ziggi.buildSched = function () {
        //checks input parameters
        if (($('#advancedHafifot')[0].value == "") || ($('#advancedHafifot')[0].value > '5') || ($('#advancedHafifot')[0].value < '0')) {
            ziggi.confirmView("הכנס מס' חפיפות הרצוי(בין 0 ל5)</br>");
        }
        else if ($('#advanced-day1')[0].checked == false && $('#advanced-day2')[0].checked == false &&
            $('#advanced-day3')[0].checked == false && $('#advanced-day4')[0].checked == false &&
            $('#advanced-day5')[0].checked == false && $('#advanced-day6')[0].checked == false) {
            ziggi.confirmView("סמן את הימים שברצונך ללמוד בהם(לפחות אחד)</br>");
        } else {
            updateSchedBuilderUI('nav');
            worker.postMessage({cmd: 'build', json: JSON.stringify(ziggi.data().courses), intersects: $('#advancedHafifot')[0].value, days: getASBCheckbox()});
        }
    };

    function getASBCheckbox() {
        var res = [];
        $('input[name="asb_day"]').each(function () {
            if (!this.checked) {
                res.push(this.value);
            }
        });
        return res;
    }

    var asb_nav_view = false;
    var abs_days_arr = [];

    function updateSchedBuilderUI(view) {
        var nav = "";
        var init = "";
        var disabled;

        abs_days_arr = getASBCheckbox();
        switch (view) {
            case 'nav':
                init = "none";
                nav = "";
                asb_nav_view = true;
                disabled = true;
                break;
            default :
                nav = "none";
                init = "";
                asb_nav_view = false;
                disabled = false;
                break;
        }

        $("#asb_build").css("display", init);
        $("#advancedHafifot").css("display", init);
        $("#asb_txtInter").css("display", init);
        $("#asb_prev").css("display", nav);
        $("#asb_next").css("display", nav);
        $("#asb_cancel").css("display", nav);
        $("#saveSchedAlways").css("display", nav);
        $("#saveSchedFuture").css("display", nav);
        $("#asb_inters").css("display", nav);
        $("#asb_inters").html("מס' חפיפות: " + $('#advancedHafifot')[0].value);

        $('input[name="asb_day"]').attr("disabled", true);
    }

    function workerStart() {
        if (worker == null) {
            worker = new Worker('assets/schedBuild.js');
            worker.addEventListener('message', function (e) {
                //document.getElementById('result').textContent = 'data.grp.id'
                var data = e.data;
                switch (data.cmd) {
                    case 'result':
                        //document.getElementById('result').textContent = data.grp[0].groups[0].id;
                        //groupSelect(data.grp[i].groups[i], true);
                        myCourses = {data: [], saved: false};
                        myCourses.data = data.sched;
                        myCourses.saved = false;
                        drawAdvancedSchedule();
                        break;
                    case 'noResult':
                        ziggi.dialogOneOption("לא נמצאה תוצאה", "לא ניתן למצוא מערכת התואמת לאילוצים שהגדרת" +
                            "<br/>" +
                            "נא לנסות שנית עם מספר חפיפות גדול יותר.");
                        break;
                    default:
                        document.getElementById('result').textContent = 'data.grp.id';
                }
                ;
            }, false);
            //workerInit();
        }
    }

    function advancedCalInit(timeslotHeight) {
        workerStart();

        var $calendar = $('#calendar');
        calendarInit = "advanced";
        $calendar.html("");
        $("body").removeClass("monthly").addClass("advanced").removeClass("map").removeClass("summary");
        $calendar.weekCalendar($.extend({}, calOptions, {
            date: getToday(),
            dateFormat: "M d, Y",
            businessHours: {start: 8, end: 22, limitDisplay: true},
            drawCurrentTimeLine: false,
            buttons: !isSuper,
            buttonsContainer: '#cal-buttons',
            timeslotHeight: timeslotHeight ? timeslotHeight : 20,
            buttonText: {
                today: "היום",
                lastWeek: "&nbsp;&lt;&nbsp;",
                nextWeek: "&nbsp;&gt;&nbsp;"
            },
            buttonTitle: {
                today: "עבור להיום",
                lastWeek: "שבוע אחורה",
                nextWeek: "שבוע קדימה"
            },
            readonly: isReadOnly,
            minDate: semester.start,
            maxDate: semester.exams_end,
            draggable: function (calEvent, element) {
                return !calEvent.readOnly && !isReadOnly;
            },
            resizable: function (calEvent, element) {
                return !calEvent.readOnly && !isReadOnly;
            },
            eventDrop: function (newCalEvent, calEvent, element) {
                if (isReadOnly) return false;
                updateEvent(newCalEvent);
            },
            eventResize: function (newCalEvent, calEvent, element) {
                if (isReadOnly) return false;
                updateEvent(newCalEvent);
            },
            eventNew: function (calEvent, element) {
                if (isReadOnly) return false;
                eventCreate(calEvent.start, calEvent.end, $calendar);
            },
            eventClick: function (calEvent, element, event) {
                if (isReadOnly) return false;
                if (!element.hasClass("ui-icon"))
                    return false;
                if (calEvent.isManual)
                    manualEventClick(calEvent.id, element, event);
                else {
                    groupSelect(calEvent.group,
                        element.hasClass("ui-icon-plus"));
                    drawSchedule();
                }
                return false;
            },
            weeklyClick: function (event) {
                if (isReadOnly) return false;
                var self_e = event;
                var day = $('#calendar').weekCalendar("getTimeFromEvent", event);
                $("#week-menu #week-menu-day").html(ziggi.timeRange(day, null, true));
                // Add all courses in this hour
                $("#week-menu .group-hour").remove();
                iterHours(function (course, group, hour) {
                    if (group.selected)
                        return;
                    var start = ziggi.newDateConstructor(hour.date_start);
                    var end = ziggi.newDateConstructor(hour.date_end);

                    if (start.getDay() != day.getDay() ||
                        start.getUTCHours() > day.getUTCHours() ||
                        end.getUTCHours() < day.getUTCHours()) {
                        return;
                    }

                    $("#week-menu #week-menu-day").after(
                        "<li class=\"group-hour ui-menu-item "
                            + group.type + "\" data-group=\"G" + group.id + "\">" +
                            "<a href=\"#\">" +
                            course.name + " (" + group.number + ")" + "</a></li>");
                });
                attachHoursEvents();
                $("#week-menu").show().position({
                    my: "right top",
                    of: event
                });
                $(document).one("click", function () {
                    $("#week-menu").hide();
                });
                $("#add-event a").unbind("click").bind("click", function () {
                    var e = $.Event("mousedown", { pageX: self_e.pageX, pageY: self_e.pageY });
                    $(self_e.target).trigger(e, true).trigger("mouseup", true);
                });
                $("#search-free-hour a").unbind("click").bind("click", function () {
                    searchFreeHour(day);
                });
                return false;
            },
            eventMouseover: function (calEvent, $event) {
                if (!calEvent.course)
                    return;
                $("." + calEvent.course.number.crs() + "_" + calEvent.group.number).addClass("hovering");
            },
            eventMouseout: function (calEvent, $event) {
                if (!calEvent.course)
                    return;
                $("." + calEvent.course.number.crs() + "_" + calEvent.group.number).removeClass("hovering");
            },
            data: function (start, end, callback) {
                callback(get_advanced_data(start, end));
            },
            longDays: ['ראשון' + '&nbsp' + createasbDiv(isASBDayChecked(0), asbCreateCheckbox('advanced-day1', "asb_day", "0", isASBDayChecked(0), asb_nav_view), 'advanced-day1-div'),
                'שני' + '&nbsp' + createasbDiv(isASBDayChecked(1), asbCreateCheckbox('advanced-day2', "asb_day", "1", isASBDayChecked(1), asb_nav_view), 'advanced-day2-div'),
                'שלישי' + '&nbsp' + createasbDiv(isASBDayChecked(2), asbCreateCheckbox('advanced-day3', "asb_day", "2", isASBDayChecked(2), asb_nav_view), 'advanced-day3-div'),
                'רביעי' + '&nbsp' + createasbDiv(isASBDayChecked(3), asbCreateCheckbox('advanced-day4', "asb_day", "3", isASBDayChecked(3), asb_nav_view), 'advanced-day4-div'),
                'חמישי' + '&nbsp' + createasbDiv(isASBDayChecked(4), asbCreateCheckbox('advanced-day5', "asb_day", "4", isASBDayChecked(4), asb_nav_view), 'advanced-day5-div'),
                'שישי' + '&nbsp' + createasbDiv(isASBDayChecked(5), asbCreateCheckbox('advanced-day6', "asb_day", "5", isASBDayChecked(5), asb_nav_view), 'advanced-day6-div'),
                '&nbsp;'],
            hideDate: true
        }));
    }

    function isASBDayChecked(day) {
        for (var i = 0; i < abs_days_arr.length; i++) {
            if (abs_days_arr[i] == day)
                return false;
        }
        return true;
    }

    function createasbDiv(checked, body, id) {
        return "<div id='" + id + "' class='advanced-days-" + (checked ? "checked" : "unchecked") + "'>" + body + "</div>";
    }

    function asbCreateCheckbox(id, name, value, checked, disabled) {
        return "<input type='checkbox' title='תסמן את הימים שבהם תרצה ללמוד'"
            + " class='advanced-days' onchange='ziggi.changeDivBackground(\"" + id + "\");' "
            + " id='" + id + "' " + (checked ? "checked " : "") + (disabled ? "disabled " : "") + "name='" + name + "'" + "value='" + value + "'" + "/>";
    }

    ziggi.changeDivBackground = function (id) {
        if (!$("#" + id)[0].checked) {
            document.getElementById(id + "-div").className = "advanced-days-unchecked";
        } else {
            document.getElementById(id + "-div").className = "advanced-days-checked";
        }

    };


    ziggi.map = function () {
        loadMap();
    }

    function hourEvent(events, sunday, date, title, content, cls, id) {
        var s, e;
        if (!date)
            return null;
        if (typeof(date) === "string")
            date = new Date(date);
        s = date.to_weekly(sunday);
        e = new Date();
        e.setTime(s.getTime() + HOUR);
        var ev = {'start': s, 'end': e, 'title': title, 'content': content };
        if (cls !== undefined) ev.className = cls;
        if (id !== undefined) ev.id = id;
        events.push(ev);
    }

    function addToHourEvent(events, date, content, cls, id)
    {
        if (typeof(date) === "string")
            date = new Date(date);
	d = parseInt((date.getTime() - events[0].start.getTime()) / DAY);
	if (events[d] === undefined)
	    return;
	events[d].content += content + "<br/>";
	if (cls !== undefined)
	    events[d].className += " " + cls;
	if (id !== undefined)
	    events[d].id = id;
    }

    function monthlyCalInit() {
        var $calendar = $('#calendar');

        calendarInit = "month";
        $calendar.html("");
        $("body").addClass("monthly").removeClass("summary").removeClass("map");
        $calendar.weekCalendar($.extend({}, calOptions, {
            is_monthly: true,
            date: $.weekCalendar.getSunday(semester.start),
            dateFormat: "",
            daysToShow: 7,
            businessHours: {start: 0, end: ((semester.exams_end || semester.end) - semester.start) / WEEK, limitDisplay: true},
            data: function (start, end, callback) {
                callback(get_monthly_data(start, end));
            },
            columnHeader: "סמסטר  " + semester.name,
            hideDate: true
        }));
	$("#semester-name").text(semester.name);
    }

    function modeCalendar() {
        if (calendarInit != "month")
            monthlyCalInit();
        else
            $('#calendar').weekCalendar("refresh");
    }

    function iterCourses(cb) {
        var c;
        for (c = 0; c < all_courses.length; c++)
            cb(all_courses[c]);
    }

    function iterCourses2(cb) {
        var c;
        for (c = 0; c < myCourses.data.length; c++) {
            cb(myCourses.data[c]);

        }
    }

    function iterGroups(cb) {
        iterCourses(function (course) {
            if (!course.groups)
                return;
            for (g = 0; g < course.groups.length; g++) {
                group = course.groups[g];
                cb(course, group);
            }
        });
    }

    function iterGroups2(cb) {
        iterCourses2(function (course) {
            if (!course.groups)
                return;
            for (g = 0; g < course.groups.length; g++) {
                group = course.groups[g];
                cb(course, group);
            }
        });
    }

    function iterHours(cb) {
        iterGroups(function (course, group) {
            var h;
            for (h = 0; h < group.hours.length; h++) {
                var hour = group.hours[h];
                cb(course, group, hour);
            }
        });
    }

    function getCoursesByRoom(name) {
        var ret = [];
        iterHours(function (course, group, hour) {
            if (!group.selected)
                return;
            var room = /\[([0-9].)\]/.exec(hour.room);
            /* XXX BGU only */
            if (room && room[1] && room[1] == name)
                ret.push({ 'course': course, 'group': group, 'hour': hour });
        });
        return ret;
    }

    function getRoomFromString(roomstr) {
        var room = /\[([0-9].)\]/.exec(roomstr);
        if (room != null && room.length != 0) {
            return room[1];
        }
        return "";
    }

    function Legend(controlDiv, map) {
        // Set CSS styles for the DIV containing the control
        // Setting padding to 5 px will offset the control
        // from the edge of the map
        controlDiv.style.padding = '5px';

        // Set CSS for the control border
        var controlUI = document.createElement('DIV');
        controlUI.style.backgroundColor = 'white';
        controlUI.style.borderStyle = 'solid';
        controlUI.style.borderWidth = '1px';
        controlUI.title = 'Legend';
        controlDiv.appendChild(controlUI);

        // Set CSS for the control text
        var controlText = document.createElement('DIV');
        controlText.style.fontFamily = 'Arial,sans-serif';
        controlText.style.fontSize = '12px';
        controlText.style.paddingLeft = '4px';
        controlText.style.paddingRight = '4px';
        controlText.style.textAlign = 'right';

        // Add the text
        controlText.innerHTML = '<div style="text-align: center;"><b>מקרא</b></div><br />' +
            '<img src="http://maps.google.com/mapfiles/ms/micons/red-dot.png" /> בניין <br /> ' +
            '<img src="http://maps.google.com/mapfiles/ms/micons/green-dot.png" />בניין לימודים<br />' +
            '<img src="http://maps.google.com/mapfiles/ms/micons/blue-dot.png" />בניין מבוקש<br />';
        controlUI.appendChild(controlText);
    }

    function loadMap() {
        var mapOptions = {
            center: new google.maps.LatLng(university.lat, university.lng),
            zoom: 17,
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById("calendar"), mapOptions);
        //adding legend to map
        var legendDiv = document.createElement('DIV');
        var legend = new Legend(legendDiv, map);
        legendDiv.index = 1;
        map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(legendDiv);

        calendarInit = null;

        $.getJSON("/rooms", function (data) {
            var roomname = $("#calendar").data("roomname");
            $.each(data, function (name, room) {
                var Latlng = new google.maps.LatLng(room.lat, room.lng);
                var image, courses;
                var c, courses, color = 'ff776b';
                var title = room.name + (room.comment ? ": " + room.comment : "");

                courses = getCoursesByRoom(room.name);
                for (c = 0; c < courses.length; c++) {
                    var course = courses[c];

                    color = '4ae14a';
                    title += '\n' + course.course.name + ' [' +
                        course.group.number + ']' + ' ' + ziggi.timeRange(
                        course.hour.date_start, course.hour.date_end, true);
                }
                if (roomname && room.name == roomname) {
                    color = '6b6bf9';
                    $("#calendar").data("roomname", ""); // reset the data for next load
                }
                image = 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + room.name + '|' + color;
                var marker = new google.maps.Marker({
                    position: Latlng,
                    map: map,
                    icon: image,
                    title: title
                });
            });
        });
    }

    ziggi.share = function (share) {
        if (share)
            $.getJSON('/share', function () {
                ziggi.staticDialog("שתף מערכת-לינק/פייסבוק/גוגל+", "/share_info");
            });
        else
            $.restDelete('/share', function () {
                ziggi.staticDialog("שתף מערכת-לינק/פייסבוק/גוגל+", "/share_info");
            });
    }

    ziggi.selectSemester = function (semester_id) {
        $.post('/semester', { "id": semester_id },
            function () {
                location.reload();
            }, "json");
    }

    ziggi.beer = function() {
	ziggi.staticDialog("הזמן את זיגי לבירה", "/buy_beer");
    };

    ziggi.load = function () {
        $("li.ui-menu-item").css("list-style", "none"); //fixes IE10 menu problem
        $("button#search-course").click(searchCourse);
        $("input#search-value").keypress(function (e) {
            if (e.which != 13)
                return;
            searchCourse();
        });
        $("button#recommended-btn").click(ziggi.showRecommended);

        $("#saveSchedFuture").click(ziggi.saveSchedBuild4Cmpr);
        $("#saveSchedAlways").click(ziggi.saveBuildSched);

        if (isNaN(new Date(semester.start))) //Damn Safari
        {
            $.jGrowl("זיגי משתמש בטכנולוגיות אינטרנט מתקדמות שאינן נתמכות במלואן על ידי הדפדפן שלך. מומלץ להשתמש בדפדפני פיירפוקס או כרום לתמיכה מלאה של האתר.", { sticky: true });
            semester.start = $.weekCalendar.parseISO8601(semester.start, true);
            semester.end = $.weekCalendar.parseISO8601(semester.end, true);
	    if (semester.exams_start)
		semester.exams_start = $.weekCalendar.parseISO8601(semester.exams_start, true);
	    if (semester.exams_end)
		semester.exams_end = $.weekCalendar.parseISO8601(semester.exams_end, true);
        }
        else {
            semester.start = new Date(semester.start);
            semester.end = new Date(semester.end);
	    if (semester.exams_start)
		semester.exams_start = new Date(semester.exams_start);
	    if (semester.exams_end)
		semester.exams_end = new Date(semester.exams_end);
        }
        loadCourses();
        all_events = g_events;
        setSelectButtons();
        drawAll();

        var tooltip = function () {
            return new tooltip.fn.init();
        };
        tooltip.f = function () {
        $(document).tooltip({
                open: function (event, ui) {
                    tooltip.tmr = setTimeout(function () {
                        $(document).tooltip('destroy');
                        tooltip.f();
                    }, 1500)
                },
                close: function (event, ui) {
                    clearTimeout(tooltip.tmr);
                },
            content: function () {
                return $(this).attr('title');
            } });
        }
        tooltip.f();


        $(window).bind("hashchange", function (e) {
            $("#edit-mode a").removeClass("selected");
            switch ($.bbq.getState("m")) {
                case "super":
                    $("#super-btn").addClass("selected");
                    return modeEdit(1);
                case "summary":
                    $("#summary-btn").addClass("selected");
                    return modeSummary();
                case "calendar":
                    $("#exams-btn").addClass("selected");
                    return modeCalendar();
                case "map":
                    $("#map-btn").addClass("selected");
                    return ziggi.modeMap();
                case "recommended":
                    $("#recommended-btn").addClass("selected");
                    return modeRecommended();
                case "advanced":
                    $("#advanced-btn").addClass("selected");
                    return modeAdvanced();
                default:
                    $("#edit-btn").addClass("selected");
                    return modeEdit(0);
            }
        });
        $(window).trigger("hashchange");
    };

    window.ziggi = ziggi;


    /**
     * Recommended schedule view
     */
    ziggi.showRecommended = function () {
        var cb_add = function () {
            $("#dialog-btn-add").attr("disabled", true);
            var courses = [];
            $("input[name='recommended-course']").each(function (i, input) {
                input.disabled = true;
                if (input.checked) {
                    var json = {"number": input.value, "name": $(input).data("name")}
                    courses.push(json);
    }
            });
            $.post("/add/courses/get", JSON.stringify(courses), function (data) {
                ziggi.addCourses(data);
                $("#results-dialog").dialog('close');
            });
        }
        var results =
            "<h2>קורסים</h2><div id='res-courses' class='loading'></div>";
        var div = $("#results-dialog div").html(results);
        $("#results-dialog").dialog({
            minWidth: 720,
            resizable: false,
            height: 400,
            maxHeight: 400,
            title: "קורסים למחלקה",
            buttons: [
                { "id": "dialog-btn-add", "text": "הוסף", click: cb_add },
                { "text": "סגור", click: function () {
                    $(this).dialog("close");
                } }
            ],
            open: function () {
                $("#dialog-btn-add").hide();
            }
        });
        $.post("/recommended",
            function (data) {
                var div = $("#results-dialog div");
                var dataJSON = JSON.parse(data);
                if (dataJSON["error"]) {
                    var a = $("<a/>").text("נא ללחוץ כאן על מנת להשלים את הנתונים החסרים").
                        attr("href", "#").click((function () {
                            ziggi.showRecommendedFill(true);
                        }));
                    $("#res-courses", div).html("לא ניתן למצוא קורסים מומלצים עקב נתונים חסרים")
                        .append($("<br/>")).append(a);
                    $("#dialog-btn-add").hide();
                    $("#res-courses", div).removeClass("loading");
                    return;
                }
                $("#dialog-btn-add").show();
                var courses = dataJSON["courses"];
                var ul = $("<ul/>");
                for (var i = 0; courses && i < courses.length; i++) {

                    var key = courses[i]["number"];
                    var val = courses[i]["name"];
                    var li = $("<li/>").html($("<input/>")
                            .attr("type", "checkbox").attr("id", "recommended-course-option-" + i)
                            .attr("name", "recommended-course").attr("value", key)
                            .data("name", val))
                        .append($("<label/>").attr("for", "recommended-course-option-" + i).html(key + " - " + val));
                    ul.append(li);
                }
                $("#res-courses", div).removeClass("loading");
                $("#res-courses", div).html(ul);
            });
    }

})();

jQuery(function ($) {
    $.datepicker.regional['he'] = {
        closeText: 'סגור',
        prevText: '&#x3C;הקודם',
        nextText: 'הבא&#x3E;',
        currentText: 'היום',
        monthNames: ['ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
            'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'],
        monthNamesShort: ['ינו', 'פבר', 'מרץ', 'אפר', 'מאי', 'יוני',
            'יולי', 'אוג', 'ספט', 'אוק', 'נוב', 'דצמ'],
        dayNames: ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'],
        dayNamesShort: ['א\'', 'ב\'', 'ג\'', 'ד\'', 'ה\'', 'ו\'', 'שבת'],
        dayNamesMin: ['א\'', 'ב\'', 'ג\'', 'ד\'', 'ה\'', 'ו\'', 'שבת'],
        weekHeader: 'Wk',
        dateFormat: 'dd/mm/yy',
        firstDay: 0,
        isRTL: true,
        showMonthAfterYear: false,
        yearSuffix: ''};
    $.datepicker.setDefaults($.datepicker.regional['he']);

    $.extend(jQuery.tmpl.tag, {
        "for": {
            _default: {$2: "var i=1;i<=1;i++"},
            open: 'for ($2){',
            close: '};'
        }
    });

});

$(document).ready(function () {
    isReadOnly = $("body").hasClass("share");
    isReadOnly |= !semester.active
    $("body").addClass(university.code);
    function relayout() {
        $(".layout").layout({
            resize: false
        });
        if ($("div.east").length) {
            var h = parseInt($("div.east").css("height"));
            var h2 = parseInt($("#E").css("height"));
            $("div#calendar").css("height", h - 24);
            $("#courses").css("height", h);

            $("#menu-tab > div").css("height", h - 4 -
                parseInt($("#menu-tab.tabs > ul").css("height")));
            $("#E").css("height", h2 > h ? h2 : h);
        } else {
            $("div#calendar").css("height", "100%");
        }
    }

    relayout();

    $(window).resize(relayout);

    $("#edit-mode").buttonset();
    $(".profile-btn").button().click(function () {
        var menu = $(this).next().show().position({
            my: "right top",
            at: "right bottom",
            of: this
        });
        $(".main-profile-btn").mouseleave(function () {
            menu.hide();
        });
        $(document).one("click", function () {
            menu.hide();
        });
        return false;
    }).next().hide().menu();
    $("#week-menu").hide().menu();
    $("#event-menu").hide().menu();

    $("a").click(function () {
        var link = $(this).data('link');
        if (link === undefined)
            return;
        ziggi.staticDialog($(this).html(), link);
        return false;
    });

    ziggi.load();
    $.getJSON("/messages", function (messages) {
        var i;
        for (i = 0; i < messages.length; i++) {
            var m = messages[i];
            $.jGrowl(m.content, { header: m.title, sticky: true,
		position: m.position });
        }
    });


    $(document).ajaxSend(function (e, xhr, options) {
        var token = $("meta[name='csrf-token']").attr("content");
        xhr.setRequestHeader("X-CSRF-Token", token);
    });
});


ziggi.refreshPersonalEvents = function () {
    var tmp = "";
    for (var i = 0; i < ziggi.data().events.length; i++) {
        var e = ziggi.data().events[i];
        if ((e.public && e.course_id > 0) || !e.university_id) {
        } else {
            if (e.selected) {
                tmp += "<li class='event selected' data-group='E" + e.id + "'>";
            } else {
                tmp += "<li class='event' data-group='E" + e.id + "'>";
            }
            tmp += "<div class='menu2'><br />"
            tmp += "<a href='javascript:ziggi.deleteEvent(\"" + e.id + "\")' class='ui-accordion-header-icon ui-icon ui-icon-trashMe' title='הסר אירוע'></a>";
            tmp += "</div>";
            tmp += "<div><span class='title'>" + e.title + "</span></div>";

            if (e.room) {
                tmp += "<div class='ctime' title='" + e.room + "'>" + ziggi.timeRange(e.date_start, e.date_end, e.weekly) + "</div>";
            } else {
                tmp += "<div class='ctime'>" + ziggi.timeRange(e.date_start, e.date_end, e.weekly) + "</div>";
            }
            tmp += "</li>";
        }
    }
    document.getElementById("allEventsL").innerHTML = tmp;
};

//not working yet-need to be implemented-refresh bug
ziggi.refreshMiniCal = function () {
    var tmp = "";
    tmp += "<table width='100%' cellpadding='0' cellspacing='0'>";
    tmp += "<thead>";
    tmp += "<th>א</th>";
    tmp += "<th>ב</th>";
    tmp += "<th>ג</th>";
    tmp += "<th>ד</th>";
    tmp += "<th>ה</th>";
    tmp += "<th>ו</th>";
    tmp += "<th>ש</th>";
    tmp += "</thead>";
    tmp += "<tr>";
    var w;
    var e = ziggi.data().dates;
    tmp += "<td colspan='7' class='month'>" + longMonths[e[0].month] + "</td>";
    tmp += "</tr>";
    tmp += "<tr>";
    for (var i = 0; i < ziggi.data().dates.length; i++) {
        var v = ziggi.data().dates[i];
        if (v.day == 1) {
            tmp += "</tr>";
            tmp += "<tr>";
            tmp += "<td colspan='7' class='month'>" + longMonths[v.month] + "</td>";
            tmp += "</tr>";
            tmp += "<tr>";
            for (w = 0; w < i % 7; w++) {
                tmp += "<td></td>";
            }
        }
        tmp += "<td id='mc_" + v.day + "_" + v.month + "_" + v.year + "'";
        if (v.today) {
            tmp += " class='day today' title='היום'";
        }
        else {
            tmp += " class='day'";
        }
        tmp += ">" + v.day + "</td>";

        if (i % 7 == 6) {
            tmp += "</tr><tr>";
        }
    }
    tmp += "</tr>";
    tmp += "</table>";
    document.getElementById("mini-cal").innerHTML = tmp;
};

