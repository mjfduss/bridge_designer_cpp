# Backward compatible doc.getElementById(id)
getElement = (id) ->
  document.getElementById(id)

# Ensure the page is loaded in the top window (not a frame)
window.unframe = () ->
  top.location.href = document.location.href unless top.location == document.location
  true

# Pop up a new window on the URL given by loc.
window.popup = (loc) ->
  window.open(loc, '', 'width=640,height=500,scrollbars=yes,resizable=yes,status=no,location=no,menubar=no')
  true

# Change the contents of the status bar.  Show('') erases it.
window.show = (msg) ->
  window.status = msg
  true

window.school_state_change = (doc) ->
  getElement('category_u').checked = 1
  getElement('res_state').selectedIndex = 0
  true

window.res_state_change = (doc) ->
  getElement('category_n').checked = 1
  getElement('school_state').selectedIndex = 0
  true

# Handler for changes to all three radio buttons.
window.category_onclick = (doc) ->
  getElement('school_state').selectedIndex = 0
  getElement('res_state').selectedIndex = 0
  true

# Handler for gain focus of local contest code text field.
window.local_contest_code_focus = (doc) ->
  getElement('national').checked = 0
  getElement('local').checked = 1
  true

window.national_onclick = (doc) ->
  getElement('local_contest_code').value = ''
  true

password_tests = [
  { n_unique: 26, regex: /[A-Z]+/ }
  { n_unique: 26, regex: /[a-z]+/ }
  { n_unique: 10, regex: /[0-9]+/ }
  { n_unique: 31, regex: /[!@#$%^&*()~`_\-+={}|;:'"<>,.\[\]?\/\\]+/ }
]

password_strengths = [
  { log: 5, msg: 'very weak' }
  { log: 10, msg: 'weak' }
  { log: 15, msg: 'marginal' }
  { log: 20, msg: 'good' }
  { log: 1e100, msg: 'very good' }
]

password_max_log = 20

password_strength = (pwd) ->
  n = 1
  for test in password_tests
    n += test.n_unique if test.regex.exec(pwd)
  pwd.length * Math.log(n) * Math.LOG10E

strength = (log) ->
  for s in password_strengths
    return s if s.log >= log

lerp = (t, a, b) -> Math.floor((1 - t) * a + t * b)

interpolate = (t, a, b) ->
  t = 0 if t < 0
  t = 1 if t > 1
  blu = lerp(t, 0xff & a, 0xff & b)
  grn = lerp(t, 0xff & (a >> 8), 0xff & (b >> 8))
  red = lerp(t, 0xff & (a >> 16), 0xff & (b >> 16))
  (red << 16) | (grn << 8) | blu

color_string = (c) ->
  s = c.toString(16)
  s = '0' + s while s.length < 6
  "\##{s}"

window.update_indicators = () ->
  pwd_field = getElement('team_password')
  match_field = getElement('team_password_confirmation')
  log = password_strength(pwd_field.value)
  mid_log = 0.5 * password_max_log
  color = if log < mid_log
    interpolate(log / mid_log, 0xff0000, 0xffff00)
  else
    interpolate((log - mid_log) / mid_log, 0xffff00, 0x00ff00)
  meter = getElement("strength_meter")
  meter.style.backgroundColor = color_string(color)
  meter.innerHTML = strength(log).msg
  meter.style.color = color_string(interpolate(0.7, 0, color))
  indicator = getElement("match_indicator")
  if (pwd_field.value == match_field.value)
    indicator.innerHTML = 'match'
    color = 0x00ff00
  else
    indicator.innerHTML = 'no match'
    color = 0xff0000
  indicator.style.backgroundColor = color_string(color)
  indicator.style.color = color_string(interpolate(0.7, 0, color))
  undefined

set_field_value = (field, val) ->
  getElement(field).value = val

last_name = null

window.do_submit = (name) ->
  eval("document.forms[0].#{last_name}.value = null") if last_name
  last_name = name
  eval("document.forms[0].#{name}.value = 1")
  document.forms[0].submit()

tick_spacing = (axis_len, max_divisions) ->
  axis_len = -axis_len if axis_len < 0
  spacing = 1
  while true
    return spacing if axis_len / spacing <= max_divisions
    spacing *= 2
    return spacing if axis_len / spacing <= max_divisions
    spacing *= 2.5
    return spacing if axis_len / spacing <= max_divisions
    spacing *= 2
  undefined

zero_pad = (n, width) ->
  rtn = n + ''
  rtn = '0' + rtn while rtn.length < width
  rtn

window.set_all_in_list = (id, select = true) ->
  option.selected = select for option in getElement(id).options
  undefined

window.set_list = (id, selects) ->
  i = 0
  option.selected = selects[i++] for option in getElement(id).options
  undefined

# Not used since bridges are now part of review tables.
#window.select_all_reviewed_teams = (val) ->
#  cb.checked = val for cb in document.forms[0].elements when cb.name.slice(-4) == 'mark'

commafy = (n) ->
  rtn = ''
  while true
    return n + rtn if n <= 999
    rtn = ',' + zero_pad(n % 1000, 3) + rtn
    n = Math.floor(n / 1000)
  undefined

bar = (x, y, w, h, color) ->
  "<div style=\"position:absolute;left:#{x}px;top:#{y}px;width:#{w}px;height:#{h}px;background-color:#{color};\"></div>"

left_label = (x, y, w, text) ->
  "<div style=\"position:absolute;left:#{x-w-4}px;top:#{y}px;width:#{w}px;line-height:0px;text-align:right;\">#{text}</div>"

right_label = (x, y, w, text) ->
  "<div style=\"position:absolute;left:#{x+4}px;top:#{y}px;width:#{w}px;line-height:0px;text-align:left;\">#{text}</div>"

window.standings_graph = (place, n_entries) ->
  return "<div class=\"canvas\">Your team ranks #{place} of #{n_entries}!</div>" if n_entries < 2
  label_inc = 28
  label_width = 100
  tick_width = 8
  axis_color = 'blue'
  pole_size = 4
  marker_margin = 4
  marker_color = 'red'
  marker_width = 20
  place = n_entries if place > n_entries
  spacing = tick_spacing(n_entries, 5)
  y0 = 32
  dy = Math.floor(label_inc * (n_entries - 1) / spacing)
  y1 = y0 + dy
  y = y0
  html = "<div class=\"canvas\" style=\"height:#{y1 + 16}px;\">"
  last_lbl = 0
  x = label_width
  for lbl in [1..n_entries] by spacing
    # The #1 label is a special case so we don't have e.g. 1,11,21,...
    lbl -= 1 unless spacing == 1 or lbl == 1
    # If the second last tick is too close to the bottom, stop now.
    if y1 - y < label_inc / 2
      break
    html += bar(x, y, tick_width, 1, axis_color) + left_label(x, y, label_width, "\##{commafy(lbl)}")
    last_lbl = lbl
    # The second part of the #1 special case.  Argh this is ugly...
    y += if spacing == 1 or lbl > 1 then label_inc else label_inc * (spacing - 1) / spacing
  # Draw the bottom tick if necessary.
  if last_lbl != n_entries
    html += bar(x, y1, tick_width, 1, axis_color) + left_label(x, y1, label_width, "\##{commafy(n_entries)}")
  x += tick_width
  html += bar(x, y0, pole_size, dy + 1, axis_color)
  x += pole_size + marker_margin
  y = y0 + Math.floor(dy * (place - 1) / (n_entries - 1))
  html += bar(x, y - Math.floor(pole_size * 0.5), marker_width, pole_size, marker_color)
  html += right_label(x + marker_width, y, label_width, "Your team...")
  html + "</div><div class=\"caption\">Standing \##{commafy(place)} of #{commafy(n_entries)}!</div>"
