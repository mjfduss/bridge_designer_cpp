# Backward compatible doc.getElementById(id)
getElement = (id) ->
  document.getElementById(id)

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
  { n_unique: 31, regex: /[!@#$%^&*()~`_\-+={}|;:'"<>,.\[\]?/]+/ }
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

bar = (wd, ht, color, align = 'bottom') ->
  if color == null
    "<span style=\"display: inline-block;vertical-align: #{align};width: #{wd};height: #{ht};\" />"
  else
    "<span style=\"display: inline-block;vertical-align: #{align};width: #{wd};height: #{ht};background-color: #{color};\" />"

zero_pad = (n, width) ->
  rtn = '0' + rtn while rtn.length < width
  rtn + ''

commafy = (n) ->
  rtn = ''
  while true
    return n + rtn if n <= 999
    rtn = ',' + zero_pad(n % 1000, 3) + rtn
    n = Math.floor(n / 1000)
  undefined

label_inc = 32
tick_width = 32
marker_margin = 3

window.standings_graph = (place, n_entries, msg) ->
  return "Your team ranks #{place} of #{n_entries} entries in your category!" if n_entries < 2
  place = n_entries if place > n_entries
  spacing = tick_spacing(n_entries, 4)
  html = "<table><tr><td colspan=\"4\"><b>Your Team's National Contest Standing</b><br>&nbsp;</td></tr> +
      <tr><td nowrap align=\"right\" valign=\"top\">#{bar(1, marker_margin, space, 'top')}<br>
      #{bar(tick_width, 1, blue)}<br>\#1&nbsp;"
  total_height = 0
  lbl = Math.max(spacing, 2)
  while lbl <= n_entries
    inc = label_inc
    if lbl + spacing > n_entries
      inc += Math.round(label_inc * (n_entries - lbl) / spacing)
      lbl = n_entries
    html += "#{bar(1, inc - 1, null, 'top')}<br>#{bar(tick_width, 1, 'blue')}<br>#{commafy(lbl)}"
    total_height += inc
    lbl += spacing
  html += "</td><td nowrap valign=\"top\">#{bar(1, marker_margin, null, 'top')}<br>
    #{bar(8, total_height + 1, 'blue')}</td><td nowrap align=\"left\" valign=\"top\">"
  spacer_ht = Math.round(total_height * (place - 1) / (n_entries - 1))
  html += "#{bar(1, spacer_ht, space, 'top')}<br>" if spacer_ht > 0
  html + "&nbsp;<b>#{commafy(place)}</b> of <b>#{commafy(n_entries)}</b> teams!
    </td></tr></table>"

window.do_submit = (name) ->
  eval("document.forms[0].#{name}.value = 1")
  document.forms[0].submit()