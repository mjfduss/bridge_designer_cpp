# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

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

window.local_contest_code_focus = (doc) ->
  doc.form['team[contest]'][0].checked = 0
  doc.form['team[contest]'][1].checked = 1