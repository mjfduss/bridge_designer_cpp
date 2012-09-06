module TablesHelper

  STATE_PAIRS = 
    [
     ['-- Select here --', '--'],
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
     ["-- Select here --", "--"],
     ["13", "13"],
     ["14", "14"],
     ["15", "15"],
     ["16", "16"],
     ["17", "17"],
     ["18", "18"],
     ["19", "19"],
     ["20", "20"],
     ["Other", "21"],
    ]

  GRADE_PAIRS =
    [
     ["-- Select here --", "--"],
     [ "6",  "6"],
     [ "7",  "7"],
     [ "8",  "8"],
     [ "9",  "9"],
     ["10", "10"],
     ["11", "11"],
     ["12", "12"],
    ]

  SEX_PAIRS =
    [
     ["-- Select here --", "--"],
     [ "Male", "M" ],
     [ "Female", "F" ],
    ]

  HISPANIC_PAIRS = 
    [
     ["-- Select here --", "--"],
     ["No. Not Spanish/Hispanic/Latino.", "N"],
     ["Yes. Mexican, Mexican Am., Chicano.", "M"],
     ["Yes. Puerto Rican.", "P"],
     ["Yes. Cuban.", "C"],
     ["Yes. Other.", "O"],
    ]

  RACE_PAIRS = 
    [
     ['-- Select here --', '--'],
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

  STATES       = Hash[ STATE_PAIRS.map{         |p| [p[1], true] } ]
  AGES         = Hash[ AGE_PAIRS.map{           |p| [p[1], true] } ]
  VALID_AGES   = Hash[ AGE_PAIRS[1..-1].map{    |p| [p[1], true] } ]
  GRADES       = Hash[ GRADE_PAIRS.map{         |p| [p[1], true] } ]
  VALID_GRADES = Hash[ GRADE_PAIRS[1..-1].map { |p| [p[1], true] } ]
  SEXES        = Hash[ SEX_PAIRS.map{           |p| [p[1], true] } ]
  HISPANICS    = Hash[ HISPANIC_PAIRS.map{      |p| [p[1], true] } ]
  RACES        = Hash[ RACE_PAIRS.map{          |p| [p[1], true] } ]

end
