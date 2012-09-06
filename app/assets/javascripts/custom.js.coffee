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
