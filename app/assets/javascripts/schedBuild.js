/**
 * Created by Liskov on 1/2/14.
 *
 */

var gotSol = true;
var courses, sched = [], interLimit = 0, maxIntersections;
var helper = [];
var backtrackArr = new Array(0);
function log(msg) {
    //console.log(msg);
}
function warn(msg) {
    //console.warn(msg);
}
//TODO need to refactor the whole code
//TODO need to clean code from debugging stuff
var all_combinations = [];
self.addEventListener('message', function (e) {
    var data = e.data;
    log('WEBWORKER: ' + data.cmd);
    switch (data.cmd) {
        case 'dbg':
            printDbg()
            break;
        case 'init':
            log('WEBWORKER: ' + data.cmd);

            log('WEBWORKER: finish parse of courses!');
            break;
        case 'build':
            courses = JSON.parse(data.json);
            filterDays(data.days);
            initData();
            makeAdvancedAlgo(data.intersects);
            /*var combination=[];
             for (var i = 0;i<sched.length; i++) {
             combination.push(sched[i].parent.number +"-"+sched[i].number);
             }*/
            if (gotSol) {
                self.postMessage({cmd: 'result', sched: courses});
            } else {
                self.postMessage({cmd: 'noResult'});
            }
            break;
        case 'buildNext':
            nextSched();
            /* var combination = [];
             if (gotSol) {
             for (var i = 0; i < sched.length; i++) {
             combination.push(sched[i].parent.number + "-" + sched[i].number);
             }
             for (var i = 0; i < all_combinations.length; i++) {
             var count = 0;
             var tempComb = all_combinations[i];
             for (var j = 0; j < tempComb.length; j++) {
             if (tempComb[j] == combination[j]) {
             count++;
             }
             }
             }
             if (count == combination.length) {
             self.postMessage({cmd: 'fuck'});
             return;
             }
             }
             all_combinations.push(combination);*/
            if (gotSol) {
                self.postMessage({cmd: 'result', sched: courses});
            } else {
                self.postMessage({cmd: 'noResult'});
            }
            break;
        default:
    }
    ;
}, false);

function getGoupFullID(grp) {
    return grp["parent"].number + "-" + grp.number;
}

function filterDays(days) {
    if (days == null) return;
    if (days.length <= 0) return;

    log("filtering days " + days);
    for (var i = 0; i < courses.length; i++) {
        var newGroups = [];

        for (var k = 0; k < courses[i].groups.length; k++) {
            var add = true;

            for (var j = 0; j < days.length; j++) {
                for (var t = 0; t < courses[i].groups[k].hours.length; t++) {
                    if (newDateConstructor2(courses[i].groups[k].hours[t].date_start).getDay() == days[j]) {
                        log("removing " + courses[i].number + "-" + courses[i].groups[k].number + " in day " + newDateConstructor2(courses[i].groups[k].hours[t].date_start).getDay());
                        //courses[i].groups.splice(k, 1);
                        add = false;
                    }
                }
            }

            if (add)
                newGroups.push(courses[i].groups[k]);
        }

        courses[i].groups = newGroups;
    }
}

function nextSched() {
    warn("--------------------------");

    backtrack();

    if (!gotSol) {
        return;
    }

    while (backtrackArr.length > 0) {
        findAlternatives(backtrackArr.pop());
    }

    printDebug2();
    printDebug4();
    printDbg();
    printDbg2();
}

function filterGroup(group, filter) {
    if (group["isFiltered"] == filter || (group["isFiltered"] && group["selected"])) {
        return;
    }
    group["isFiltered"] = filter;
    if (filter) {
        updateGroupSum(group, -1);
    } else {
        log(group["parent"].number + "-" + group.number + " unfiltered");
        updateGroupSum(group, 1);
    }
}

function printDbg() {
    for (var i = 0; i < helper.length; i++) {
        if (helper[i]["backtracked"])
            warn("! BT ! " + helper[i]["parent"].number + "-" + helper[i].number);
    }
}

function printDbg2() {
    for (var i = 0; i < helper.length; i++) {
        if (helper[i]["isFiltered"])
            warn("! F ! " + helper[i]["parent"].number + "-" + helper[i].number);
    }
}

function initFilterGroup(group, filter) {
    group["isFiltered"] = filter;
    if (filter) {
        updateGroupSum(group, -1);
    } else {
        updateGroupSum(group, 1);
    }
}

function updateGroupSum(group, toAdd) {
    if (group.type == "שעור") {
        group["parent"]["lectSum"] = (+group["parent"]["lectSum"] + +toAdd);
    }
    else if (group.type == "תרגיל") {
        group["parent"]["tirgulSum"] = (+group["parent"]["tirgulSum"] + +toAdd);
    }
    else {
        group["parent"]["labSum"] = (+group["parent"]["labSum"] + +toAdd);
    }
}
function resetAuxiliary() {
//auxiliary data clear
    sched = [];
    backtrackArr = [];
    gotSol = true;
    helper = [];
}
function initData() {
    resetAuxiliary();

    //courses data
    var i, j;
    gotSol = true;
    //adding new fields to courses
    for (i = 0; i < courses.length; i++) {
        courses[i]["isSchedLecture"] = false;
        courses[i]["isSchedTutorial"] = false;
        courses[i]["isSchedLab"] = false;
        courses[i]["lectSum"] = 0;
        courses[i]["tirgulSum"] = 0;
        courses[i]["labSum"] = 0;
        for (j = 0; j < courses[i].groups.length; j++) {
            courses[i].groups[j]["numIntersection"] = 0;
            courses[i].groups[j]["groupsIntersection"] = [];
            courses[i].groups[j]["parent"] = courses[i];
            courses[i].groups[j]["isFiltered"] = false;
            courses[i].groups[j]["backtracked"] = false;
            initFilterGroup(courses[i].groups[j], false);
            courses[i].groups[j]["selected"] = false;
            helper.push(courses[i].groups[j]);
        }
    }
    weight();
    printDebug();
    printDebug2();
    printDebug3();
}

function makeAdvancedAlgo(intersects) {
    //printDebug();
    interLimit = intersects;
    maxIntersections = intersects;
    build();

    printDebug2();
};

function printDebug() {
    var i, j;
    for (i = 0; i < helper.length; i++) {
        log(helper[i]["parent"].number + "/" + helper[i].number + ":");
        for (j = 0; j < helper[i]["groupsIntersection"].length; j++) {
            log("\t" + helper[i]["groupsIntersection"][j]["parent"].number + "/" + helper[i]["groupsIntersection"][j].number);
        }
        log("---------------------------------------------------------");
    }
}

function printDebug2() {
    var i;
    for (i = 0; i < courses.length; i++) {
        log(courses[i].number + ": " + courses[i]["lectSum"] + "/" + courses[i]["tirgulSum"] + "/" + courses[i]["labSum"]);
    }
}


function printDebug3() {
    var i;
    log("helper print--------------");
    for (i = 0; i < helper.length; i++) {
        log(helper[i]["parent"].number + "-" + helper[i].number);
    }
    log("helper end----------------");
}

function printDebug4() {
    var i;
    log("sched print--------------");
    for (i = 0; i < sched.length; i++) {
        log(sched[i]["parent"].number + "-" + sched[i].number);
    }
    log("sched end----------------");
}

function getTime(date) {
    return date.getHours() + (date.getMinutes() / 100);
}

//update all the additional fields and check intersections
function weight() {
    var i, j, k, l;
    log("weighting...");
    for (i = 0; i < helper.length; i++) {
        var h1 = helper[i];
        for (j = 0; j < h1.hours.length; j++) {
            var ts1 = newDateConstructor2(h1.hours[j].date_start);
            var te1 = newDateConstructor2(h1.hours[j].date_end);
            for (k = 0; k < helper.length; k++) {
                var h2 = helper[k];
                if (h1.id == h2.id) {
                    continue;
                }
                if (h1.type == h2.type && h1["parent"].number == h2["parent"].number) {
                    continue;
                }
                for (l = 0; l < h2.hours.length; l++) {
                    var ts2 = newDateConstructor2(h2.hours[l].date_start);
                    var te2 = newDateConstructor2(h2.hours[l].date_end);

                    if (ts1.getDay() == ts2.getDay() && getTime(te1) > getTime(ts2) && getTime(ts1) < getTime(te2)) {
                        h1["numIntersection"]++;
                        h1["groupsIntersection"].push(h2);
                        log("intersect : " + h1["parent"].number + "-" + h1.number + "(" + getTime(ts1) + "-" + getTime(te1) +
                            ") & " + h2["parent"].number + "-" + h2.number + "(" + getTime(ts2) + "-" + getTime(te2) + ")");
                    } else {
                        log("no intersect : " + h1["parent"].number + "-" + h1.number + "(" + getTime(ts1) + "-"
                            + getTime(te1) + ") & " + h2["parent"].number + "-" + h2.number + "(" + getTime(ts2) + "-" + getTime(te2) + ")");
                    }
                }
            }
        }
    }

    //sort algorithm
    helper.sort(cmpr);

//    for (var x = 0; x < courses.length; x++) {
//        courses[x].groups.sort(cmpr);
//    }
}

function isCourseScheduled(h) {
    if (h.type == "שעור")
        return h["parent"]["isSchedLecture"];
    else if (h.type == "תרגיל")
        return h["parent"]["isSchedTutorial"];
    else
        return h["parent"]["isSchedLab"];
}

function hasEmptyDomain(h) {
    if (h.type == "שעור")
        return h["parent"]["lectSum"] <= 0
    else if (h.type == "תרגיל")
        return h["parent"]["tirgulSum"] <= 0
    else
        return h["parent"]["labSum"] <= 0
}

//TODO need to merge build and findAlternative implemntations
function build() {
    var i, k, count;

    for (i = 0; i < helper.length; i++) {
        var h = helper[i];

        if (!isCourseScheduled(h)) {
            if (hasEmptyDomain(h)) {
                log("A");
                if (maxIntersections > 0) {
                    if (h["backtracked"]) continue;

                    count = 0;
                    for (k = 0; k < h["groupsIntersection"].length; k++) {
                        if (h["groupsIntersection"][k]["selected"]) {
                            count++;
                        }
                    }
                    if (count <= maxIntersections) {
                        addGroup2Sched(h);
                        maxIntersections -= count;
                    }
                } else {
                    backtrack();

                    //reset loop
                    i = -1;
                }
            } else {
                if (!gotSol) {
                    return;
                }
                if (!h["isFiltered"]) {
                    addGroup2Sched(h);
                }
            }
        }
    }
}

function findAlternatives(lastBTGroup) {
    var i, k, count;

    for (i = 0; i < helper.length; i++) {
        var h = helper[i];

        if (!(lastBTGroup["parent"].number == h["parent"].number && lastBTGroup.type == h.type)) {
            continue;
        }
        log("skipped to: " + h["parent"].number + "-" + h.number);

        if (!isCourseScheduled(h)) {
            if (hasEmptyDomain(h)) {
                log("A");
                if (maxIntersections > 0) {
                    if (h["backtracked"]) continue;

                    count = 0;
                    for (k = 0; k < h["groupsIntersection"].length; k++) {
                        if (h["groupsIntersection"][k]["selected"]) {
                            count++;
                        }
                    }
                    if (count <= maxIntersections) {
                        addGroup2Sched(h);
                        maxIntersections -= count;
                        return;
                    }
                } else {
                    backtrack();
                    if (!gotSol) {
                        return;
                    }

                    //reset loop
                    i = -1;
                }
            } else {
                if (!h["isFiltered"]) {
                    addGroup2Sched(h);
                    return;
                }
            }
        }
    }
}

function scheduleCourse(group, isSched) {
    if (group.type == "שעור") {
        group["parent"]["isSchedLecture"] = isSched;
    }
    else if (group.type == "תרגיל") {
        group["parent"]["isSchedTutorial"] = isSched;
    } else {
        group["parent"]["isSchedLab"] = isSched;
    }
}
function addGroup2Sched(group) {
    warn("ADD " + group["parent"].number + "-" + group.number);
    var i;
    sched.push(group);
    group["selected"] = true;
    scheduleCourse(group, true);
    for (i = 0; i < group["groupsIntersection"].length; i++) {
        filterGroup(group["groupsIntersection"][i], true);
    }
    filterGroup(group, true);
}

function checkMultiIntersection(group) {
    var j;
    for (j = 0; j < group["groupsIntersection"].length; j++) {
        if (group["groupsIntersection"][j]["selected"]) {
            return true;
        }
    }
    return false;
}

function backtrack() {
    var lastGroup, i, j, inter = 0;

    if (sched.length <= 0) {
        gotSol = false;
        return;
    }

    lastGroup = sched.pop();
    warn("BACKTRACK " + lastGroup["parent"].number + "-" + lastGroup.number);
    lastGroup["selected"] = false;
    lastGroup["backtracked"] = true;
    scheduleCourse(lastGroup, false);

    for (j = 0; j < lastGroup["groupsIntersection"].length; j++) {
        log("is: " + lastGroup["groupsIntersection"][j]["parent"].number + lastGroup["groupsIntersection"][j].number);
        if (!checkMultiIntersection(lastGroup["groupsIntersection"][j])) {
            if (!lastGroup["groupsIntersection"][j]["backtracked"]) {
                log("BBB");
                filterGroup(lastGroup["groupsIntersection"][j], false);
                if (lastGroup["groupsIntersection"][j]["selected"]) {
                    inter++;
                }
            }
        }
    }
    maxIntersections = (+maxIntersections + +inter);
    backtrackArr.push(lastGroup);
    log("backtrackArr adding...");

    if (hasEmptyDomain(lastGroup) && noIntersectedSol(lastGroup)) {
        for (i = 0; i < lastGroup["parent"].groups.length; i++) {
            if (lastGroup.type == lastGroup["parent"].groups[i].type) {
                lastGroup["parent"].groups[i]["backtracked"] = false;
                if (!checkMultiIntersection(lastGroup["parent"].groups[i])) {
                    log("CCC");
                    filterGroup(lastGroup["parent"].groups[i], false);
                }
            }
        }

        backtrack();
    }
}

var intersectTemp;

function noIntersectedSol(g) {
    if (maxIntersections <= 0) {
        return true;
    }

    for (var i = 0; i < g["parent"].groups.length; i++) {
        var group = g["parent"].groups[i];
        if (g.type != group.type || group["backtracked"]) continue;

        var count = 0;
        for (var k = 0; k < group["groupsIntersection"].length; k++) {
            if (group["groupsIntersection"][k].selected) {
                count++;
            }
        }

        if (count <= maxIntersections) {
            warn("LOLOLOLOLO");
            return false;
        }
    }

    return true;
}

function cmpr(a, b) {
    return a["numIntersection"] - b["numIntersection"];
}

function newDateConstructor2(str) {
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
