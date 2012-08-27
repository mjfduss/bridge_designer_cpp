# Pop up a new window on the URL given by loc.
window.popup = (loc) -> 
  window.open(loc,'','width=640,height=500,scrollbars=yes,resizable=yes,status=no,location=no,menubar=no')

# Change the contents of the status bar.  Show('') erases it.
window.show = (msg) ->
  window.status = msg

# Names of the registration state selectors on the team page.
selector_names = [ "school_state", "res_state" ]

# Handler for changes to both state selectors.
window.state_onchange = (doc, i) ->
  doc.form['team[member][category]'][i].checked = 1
  doc.form["team[member][#{ selector_names[1 - i] }]"].selectedIndex = 0
  true

# Handler for changes to all three radio buttons.
window.category_onclick = (doc, i) ->
  for j in [0..1]
    doc.form["team[member][#{ selector_names[j] }]"].selectedIndex = 0
  true

# Handler for gain focus of local contest code text field.
window.local_contest_code_focus = (doc) ->
  checks = doc.form['team[contest]']
  checks[0].checked = 0
  checks[1].checked = 1

window.national_onclick = (doc) ->
  doc.form['team[local_contest_code]'].value=''