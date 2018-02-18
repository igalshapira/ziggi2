# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

if University.count == 0
    University.create([
	  { :code => "bgu", :name => "אוניברסיטת בן גוריון שבנגב",
	      :homepage => "http://www.bgu.ac.il",
	      :lat => 31.262425, :lng => 34.801919, :status => 1 },
	  { :code => "bgu_eilat", :name => "אוניברסיטת בן גוריון (קמפוס אילת)",
	      :homepage => "http://www.bgu.ac.il/eilat",
	      :lat => 29.567213 , :lng => 34.951109, :status => 1 },
	  { :code => "haifa", :name => "אוניברסיטת חיפה",
	      :homepage => "http://www.haifa.ac.il",
	      :lat => 32.761632 , :lng => 35.019951, :status => 0 },
	  { :code => "biu", :name => "אוניברסיטת בר אילן",
	      :homepage => "http://www.biu.ac.il",
	      :lat => 32.068001, :lng => 34.843837, :status => 0 },
	  { :code => "huji", :name => "האוניברסיטה העברית",
	      :homepage => "http://www.huji.ac.il",
	      :lat => 31.792424, :lng => 35.245085, :status => 0 },
	  { :code => "tau", :name => "אוניברסיטת תל אביב",
	      :homepage => "http://www.tau.ac.il",
	      :lat => 32.114022, :lng => 34.804494, :status => 0 }
    ])
end

if Semester.count < 1
    Semester.create([
		    { :university_id => 1, :name => 'אביב תשע"ג', :year => 2013, :semester => 2,
			:start => DateTime.new(2013, 3, 10), :end => DateTime.new(2013, 6, 28),
			:exams_start => DateTime.new(2013, 6, 30), :exams_end => DateTime.new(2013, 8, 9) },
		    { :university_id => 2, :name => 'אביב תשע"ג', :year => 2013, :semester => 2,
			:start => DateTime.new(2013, 3, 10), :end => DateTime.new(2013, 6, 28),
			:exams_start => DateTime.new(2013, 6, 30), :exams_end => DateTime.new(2013, 8, 9) },
		    { :university_id => 3, :name => 'אביב תשע"ג', :year => 2013, :semester => 2,
			:start => DateTime.new(2013, 3, 5), :end => DateTime.new(2013, 6, 20),
			:exams_start => DateTime.new(2013, 6, 23), :exams_end => DateTime.new(2013, 7, 25) },
		    { :university_id => 4, :name => 'אביב תשע"ג', :year => 2013, :semester => 2,
			:start => DateTime.new(2013, 2, 26), :end => DateTime.new(2013, 6, 19) },
		    { :university_id => 5, :name => 'ב תשע"ג', :year => 2013, :semester => 2,
			:start => DateTime.new(2013, 2, 26), :end => DateTime.new(2013, 6, 21) },
		    { :university_id => 6, :name => 'ב תשע"ג', :year => 2013, :semester => 2,
			:start => DateTime.new(2013, 2, 26), :end => DateTime.new(2013, 6, 21) }
    ])
end

if Rooms.count == 0
    Rooms.create([
	  { :university_id => 1, :name => "30", :comment => "עמדות מחשבים, קפה, עמדה להטענת כרטיס, מכונות צילום, מדפסות", :lat => 31.262022, :lng => 34.803035},
    ])
end
if Rooms.count == 1
    Rooms.create([
	  { :university_id => 1, :lat =>31.262031, :lng => 34.802220, :name => "26"},
	  { :university_id => 1, :lat =>31.261742, :lng => 34.802697, :name => "28"},
	  { :university_id => 1, :lat =>31.261751, :lng => 34.803352, :name => "32", :comment => "מכונות צילום, מסעדה"},
	  { :university_id => 1, :lat =>31.262054, :lng => 34.803668, :name => "34", :comment => "מדפסות, קפה"},
	  { :university_id => 1, :lat =>31.262347, :lng => 34.803384, :name => "33", :comment => "חוות מחשבים, מדפסות, מכונות צילום"},
	  { :university_id => 1, :lat =>31.262352, :lng => 34.802735, :name => "29"},
	  { :university_id => 1, :lat =>31.262356, :lng => 34.803931, :name => "37"},
	  { :university_id => 1, :lat =>31.26177,  :lng => 34.803939, :name => "35"},
	  { :university_id => 1, :lat =>31.262689, :lng => 34.803898, :name => "58"},
	  { :university_id => 1, :lat =>31.262689, :lng => 34.803248, :name => "62"},
	  { :university_id => 1, :lat =>31.262815, :lng => 34.80483,  :name => "54"},
	  { :university_id => 1, :lat =>31.262994, :lng => 34.805565, :name => "51"},
	  { :university_id => 1, :lat =>31.263233, :lng => 34.804712, :name => "55"},
	  { :university_id => 1, :lat =>31.263049, :lng => 34.804406, :name => "56", :comment => "קפה"},
	  { :university_id => 1, :lat =>31.263476, :lng => 34.804411, :name => "57"},
	  { :university_id => 1, :lat =>31.263008, :lng => 34.80395,  :name => "59"},
	  { :university_id => 1, :lat =>31.26348,  :lng => 34.804122, :name => "60"},
	  { :university_id => 1, :lat =>31.263618, :lng => 34.803757, :name => "61"},
	  { :university_id => 1, :lat =>31.263031, :lng => 34.803338, :name => "63"},
	  { :university_id => 1, :lat =>31.263246, :lng => 34.803397, :name => "64"},
	  { :university_id => 1, :lat =>31.263508, :lng => 34.803483, :name => "65"},
	  { :university_id => 1, :lat =>31.263645, :lng => 34.802823, :name => "66"},
	  { :university_id => 1, :lat =>31.263122, :lng => 34.802845, :name => "67"},
	  { :university_id => 1, :lat =>31.261476, :lng => 34.804529, :name => "40"},
	  { :university_id => 1, :lat =>31.261256, :lng => 34.804535, :name => "39"},
	  { :university_id => 1, :lat =>31.261316, :lng => 34.804036, :name => "38"},
	  { :university_id => 1, :lat =>31.259002, :lng => 34.800588, :name => "M4"},
	  { :university_id => 1, :lat =>31.260105, :lng => 34.803778, :name => "M5"},
	  { :university_id => 1, :lat =>31.260463, :lng => 34.803725, :name => "M6"},
	  { :university_id => 1, :lat =>31.260509, :lng => 34.80424,  :name => "M7"},
	  { :university_id => 1, :lat =>31.260655, :lng => 34.803671, :name => "M8"},
	  { :university_id => 1, :lat =>31.260224, :lng => 34.803472, :name => "M9"},
	  { :university_id => 1, :lat =>31.260013, :lng => 34.804293, :name => "M10"},
	  { :university_id => 1, :lat =>31.26309,  :lng => 34.801852, :name => "70", :comment =>  "בית סטודנט: מדפסות + צבעוני + כריכה, קופת חולים , השאלת ספרים, חוות מחשבים, עמדות מחשבים, מסעדה, קפה, אקדמון, מכונות צילום, עמדה להטענת כרטיס, השאלת ספרים"},
	  { :university_id => 1, :lat =>31.26287,  :lng => 34.801364, :name => "71"},
	  { :university_id => 1, :lat =>31.263122, :lng => 34.80108,  :name => "71A"},
	  { :university_id => 1, :lat =>31.262742, :lng => 34.80035,  :name => "72", :comment => "עמדות מחשבים, קפה, מסעדה"},
	  { :university_id => 1, :lat =>31.262439, :lng => 34.800484, :name => "73"},
	  { :university_id => 1, :lat =>31.262659, :lng => 34.79939,  :name => "74", :comment => "חוות מחשבים, מדפסות"},
	  { :university_id => 1, :lat =>31.261967, :lng => 34.800602, :name => "22", :comment => "ספריית ארן: עמדה להטענת כרטיס צילום, עמדות מחשבים, חוות מחשבים, מדפסות + ציבעוני, מכונות צילום, השאלת ספרים"},
	  { :university_id => 1, :lat =>31.262228, :lng => 34.799669, :name => "18"},
	  { :university_id => 1, :lat =>31.262042, :lng => 34.799689, :name => "17"},
	  { :university_id => 1, :lat =>31.261563, :lng => 34.799573, :name => "16", :comment => "חוות מחשבים"},
	  { :university_id => 1, :lat =>31.261367, :lng => 34.799495, :name => "15", :comment => "קפה"},
	  { :university_id => 1, :lat =>31.259885, :lng => 34.806793, :name => "גימל", :comment => "מעונות ג: חוות מחשבים, מדפסות, מכונות צילום, מועדון, סופר" },
	  { :university_id => 1, :lat =>31.263183, :lng => 34.797215, :name => "דלת", :comment => "מעונות ד: חוות מחשבים, מדפסות, מכונות צילום, מועדון"},
	  { :university_id => 1, :lat =>31.264654, :lng => 34.803092, :name => "90",  :comment => "עמדה להטענת כרטיס, מכונות צילום, מדפסות, קפה, עמדות מחשבים, חוות מחשבים"},
	  { :university_id => 1, :lat =>31.264296, :lng => 34.802936, :name => "91"},
	  { :university_id => 1, :lat =>31.26437,  :lng => 34.80336,  :name => "92", :comment => "חוות מחשבים"},
	  { :university_id => 1, :lat =>31.264801, :lng => 34.803403, :name => "93",:comment => "מדפסות, חוות מחשבים"},
	  { :university_id => 1, :lat =>31.264925, :lng => 34.803628, :name => "94"},
	  { :university_id => 1, :lat =>31.264324, :lng => 34.80218,  :name => "95"},
	  { :university_id => 1, :lat =>31.264727, :lng => 34.801455, :name => "97"},
	  { :university_id => 1, :lat =>31.264237, :lng => 34.801101, :name => "98"}
    ])
end

if Rooms.count == 55
    Rooms.create([
	  { :university_id => 1, :name => "M2", :comment => "בניין פתולוגיה", :lat => 31.257991, :lng => 34.802692},
    ])
end
