# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Pop up a new window on the URL given by loc.
popup = (loc) -> 
  window.open(loc,'','width=640,height=500,scrollbars=yes,resizable=yes,status=no,location=no,menubar=no')

# Change the contents of the status bar.  Show('') erases it.
show = (msg) ->
  window.status = msg
  true

selector_names = [ "school_state", "res_state" ]

state_onchange = (doc, i) ->
  this.form['team[member][category]'][i].checked = 1
  doc.form['team[member][' + selector_names[1 - i] + ']'].selectedIndex = 0

category_onclick = (doc) ->
  for i in [0..1]
    if doc.form['team[member][category]'][i].checked
      doc.form['team[member][' + selector_names[i] + ']'].selectedIndex = 0