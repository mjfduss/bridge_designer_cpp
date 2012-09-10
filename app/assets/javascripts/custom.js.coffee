# Backward compatible doc.getElementById(id)
getElement = (id) ->
  document.getElementById(id)

# Pop up a new window on the URL given by loc.
window.popup = (loc) -> 
  window.open(loc,'','width=640,height=500,scrollbars=yes,resizable=yes,status=no,location=no,menubar=no')
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
  { n_unique : 26, regex : /[A-Z]+/ }
  { n_unique : 26, regex : /[a-z]+/ }
  { n_unique : 10, regex : /[0-9]+/ }
  { n_unique : 31, regex : /[!@#$%^&*()~`_\-+={}|;:'"<>,.\[\]?/]+/ }
] 

password_strengths = [
  { log : 5, msg : 'very weak' }
  { log : 10, msg : 'weak' }
  { log : 15, msg : 'marginal' }
  { log : 20, msg : 'good' }
  { log : 1e100, msg : 'very good' }
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
  blu = lerp(t, 0xff &  a,        0xff &  b)
  grn = lerp(t, 0xff & (a >> 8),  0xff & (b >> 8))
  red = lerp(t, 0xff & (a >> 16), 0xff & (b >> 16))
  (red << 16) | (grn << 8) | blu

window.update_password_strength = (pwd_field) ->
  log = password_strength(pwd_field.value)
  mid_log = 0.5 * password_max_log
  color = if log < mid_log 
    interpolate(log / mid_log, 0xff0000, 0xffff00)
  else
    interpolate((log - mid_log) / mid_log, 0xffff00, 0x00ff00)
  meter = getElement("strength_meter")
  meter.style.backgroundColor = "\##{color.toString(16)}"
  s = strength(log) 
  meter.innerHTML = s.msg
  meter.style.color = "\##{interpolate(0.7, 0, color).toString(16)}"
  true