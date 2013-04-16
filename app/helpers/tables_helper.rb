module TablesHelper

  STATE_PAIRS = 
    [
     ['-- Select here --', '-'],
     ["Alabama", "AL"],
     ["Alaska", "AK"],
     ["American Samoa", "AS"],
     ["Arizona", "AZ"],
     ["Arkansas", "AR"],
     ["California", "CA"],
     ["Colorado", "CO"],
     ["Connecticut", "CT"],
     ["Delaware", "DE"],
     ["District of Columbia", "DC"],
     ["Fed Sts of Micronesia", "FM"],
     ["Florida", "FL"],
     ["Georgia", "GA"],
     ["Guam", "GU"],
     ["Hawaii", "HI"],
     ["Idaho", "ID"],
     ["Illinois", "IL"],
     ["Indiana", "IN"],
     ["Iowa", "IA"],
     ["Kansas", "KS"],
     ["Kentucky", "KY"],
     ["Louisiana", "LA"],
     ["Maine", "ME"],
     ["Marshall Islands", "MH"],
     ["Maryland", "MD"],
     ["Massachusetts", "MA"],
     ["Michigan", "MI"],
     ["Minnesota", "MN"],
     ["Mississippi", "MS"],
     ["Missouri", "MO"],
     ["Montana", "MT"],
     ["Nebraska", "NE"],
     ["Nevada", "NV"],
     ["New Hampshire", "NH"],
     ["New Jersey", "NJ"],
     ["New Mexico", "NM"],
     ["New York", "NY"],
     ["North Carolina", "NC"],
     ["North Dakota", "ND"],
     ["Northern Mariana Is", "MP"],
     ["Ohio", "OH"],
     ["Oklahoma", "OK"],
     ["Oregon", "OR"],
     ["Palau", "PW"],
     ["Pennsylvania", "PA"],
     ["Puerto Rico", "PR"],
     ["Rhode Island", "RI"],
     ["South Carolina", "SC"],
     ["South Dakota", "SD"],
     ["Tennessee", "TN"],
     ["Texas", "TX"],
     ["Utah", "UT"],
     ["Vermont", "VT"],
     ["Virgin Islands", "VI"],
     ["Virginia", "VA"],
     ["Washington", "WA"],
     ["West Virginia", "WV"],
     ["Wisconsin", "WI"],
     ["Wyoming", "WY"],
    ]

  AGE_PAIRS =
    [
     ["-- Select here --", "-"],
     ["13", 13],
     ["14", 14],
     ["15", 15],
     ["16", 16],
     ["17", 17],
     ["18", 18],
     ["19", 19],
     ["20", 20],
     ["Other", 21],
    ]

  GRADE_PAIRS =
    [
     ["-- Select here --", "-"],
     [ "6",  6],
     [ "7",  7],
     [ "8",  8],
     [ "9",  9],
     ["10", 10],
     ["11", 11],
     ["12", 12],
    ]

  SEX_PAIRS =
    [
     ["-- Select here --", "-"],
     [ "Male", "M" ],
     [ "Female", "F" ],
    ]

  SEX_MAP = Hash[ SEX_PAIRS[1..-1].map{ |p| [p[1], p[0]] } ]

  HISPANIC_PAIRS =
    [
     ["-- Select here --", "-"],
     ["No. Not Spanish/Hispanic/Latino.", "N"],
     ["Yes. Mexican, Mexican Am., Chicano.", "M"],
     ["Yes. Puerto Rican.", "P"],
     ["Yes. Cuban.", "C"],
     ["Yes. Other.", "O"],
    ]

  HISPANIC_MAP = Hash[ HISPANIC_PAIRS[1..-1].map{ |p| [p[1], p[0]] } ]

  RACE_PAIRS =
    [
     ['-- Select here --', '-'],
     ["White", "W"],
     ["Black or African American", "B"],
     ["Native American or Alaska Native", "A"],
     ["Asian Indian", "D"],
     ["Chinese", "C"],
     ["Filipino", "F"],
     ["Other Asian", "N"],
     ["Japanese", "J"],
     ["Korean", "K"],
     ["Vietnamese", "V"],
     ["Hawaiian", "H"],
     ["Guamanian", "G"],
     ["Samoan", "S"],
     ["Other Pacific Islander", "P"],
     ["Other race", "O"],
    ]

  RACE_MAP = Hash[ RACE_PAIRS[1..-1].map{ |p| [p[1], p[0]] } ]

  CATEGORY_PAIRS =
    [
      ["Select Category", "-"],
      ["US/PR Students", "e"],
      ["Open Competition", "i"],
      ["Semifinalists", "2"],
    ]

  CATEGORY_MAP = Hash[ CATEGORY_PAIRS[1..-1].map{ |p| [p[1], p[0]] } ]

  STANDINGS_PAIRS =
    [
      ["Select Standings", "-"],
      ["All Categories", "a"],
      ["US/PR Students", "e"],
      ["Open Competition", "i"],
      ["Semifinalists", "2"],
    ]

  STANDINGS_OPTIONS_PAIRS =
    [
      ["Normal", "-"],
      ["Include scores", "s"],
      ["Not available", "x"],
    ]

  STANDINGS_CUTOFF_PAIRS =
    [
      ["50", "50"],
      ["75", "75"],
      ["100", "100"],
    ]

  TEAM_ATTRIBUTE_PAIRS =
    [
      ["Review status", "status"],
      ["Team name", "team_name"],
      ["Category", "category"],
      ["Captain name", "captain_name"],
      ["Captain category", "captain_category"],
      ["Captain age/grade", "captain_age_grade"],
      ["Captain contact", "captain_contact"],
      ["Captain school", "captain_school"],
      ["Captain demographics", "captain_demographics"],
      ["Member name", "member_name"],
      ["Member category", "member_category"],
      ["Member age/grade", "member_age_grade"],
      ["Member contact", "member_contact"],
      ["Member school", "member_school"],
      ["Member demographics", "member_demographics"],
      ["Email", "email"],
      ["Local contests", "local_contests"],
      ["Best score", "best_score"],
    ]

  TEAM_ATTRIBUTE_DEFAULTS =
    %w{team_name
    captain_name captain_category captain_age_grade captain_contact captain_school
    member_name member_age_grade member_contact member_school
    email local_contests best_score}
  TEAM_ATTRIBUTE_SELECTED = TEAM_ATTRIBUTE_PAIRS.map { |p| TEAM_ATTRIBUTE_DEFAULTS.include? p[1] }

  STATUS_PAIRS =
    [
      ["None", "-"],
      ["Accepted", "a"],
      ["Rejected", "r"],
      ["Hidden",   "h"],
    ]

  STATUS_PAIR_DEFAULTS = %w{accepted rejected}

  STATUS_MAP = Hash[ STATUS_PAIRS.map{ |p| [p[1], p[0]] } ]

  # For factories to generate randomized values
  def self.keyed_code_from_pairs(key, pairs)
    if pairs[0][1] == '-'
      pairs[1 + key % (pairs.length - 1)][1]
    else
      pairs[key % pairs.length][1]
    end
  end

  STATES            = Hash[ STATE_PAIRS.map{             |p| [p[1], true] } ]
  AGES              = Hash[ AGE_PAIRS.map{               |p| [p[1], true] } ]
  VALID_AGES        = Hash[ AGE_PAIRS[1..-1].map{        |p| [p[1], true] } ]
  GRADES            = Hash[ GRADE_PAIRS.map{             |p| [p[1], true] } ]
  VALID_GRADES      = Hash[ GRADE_PAIRS[1..-1].map {     |p| [p[1], true] } ]
  SEXES             = Hash[ SEX_PAIRS.map{               |p| [p[1], true] } ]
  HISPANICS         = Hash[ HISPANIC_PAIRS.map{          |p| [p[1], true] } ]
  RACES             = Hash[ RACE_PAIRS.map{              |p| [p[1], true] } ]
  CATEGORIES        = Hash[ CATEGORY_PAIRS.map{          |p| [p[1], true] } ]
  STANDINGS         = Hash[ STANDINGS_PAIRS.map{         |p| [p[1], true] } ]
  STANDINGS_OPTIONS = Hash[ STANDINGS_OPTIONS_PAIRS.map{ |p| [p[1], true] } ]
  STANDINGS_CUTOFFS = Hash[ STANDINGS_CUTOFF_PAIRS.map{  |p| [p[1], true] } ]
  TEAM_ATTRIBUTES   = Hash[ TEAM_ATTRIBUTE_PAIRS.map{    |p| [p[1], true] } ]
  STATUSES          = Hash[ STATUS_PAIRS.map{            |p| [p[1], true] } ]
  VALID_STATUSES    = Hash[ STATUS_PAIRS[1..-1].map{     |p| [p[1], true] } ]

  CANCEL = '<< Cancel and Go Back'
  ACCEPT = 'Accept and Continue >>'
end
