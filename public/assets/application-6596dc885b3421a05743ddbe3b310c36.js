// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
(function(){var bar,color_string,commafy,getElement,interpolate,label_inc,lerp,marker_margin,password_max_log,password_strength,password_strengths,password_tests,set_field_value,strength,tick_spacing,tick_width,zero_pad;getElement=function(e){return document.getElementById(e)},window.popup=function(e){return window.open(e,"","width=640,height=500,scrollbars=yes,resizable=yes,status=no,location=no,menubar=no"),!0},window.show=function(e){return window.status=e,!0},window.school_state_change=function(e){return getElement("category_u").checked=1,getElement("res_state").selectedIndex=0,!0},window.res_state_change=function(e){return getElement("category_n").checked=1,getElement("school_state").selectedIndex=0,!0},window.category_onclick=function(e){return getElement("school_state").selectedIndex=0,getElement("res_state").selectedIndex=0,!0},window.local_contest_code_focus=function(e){return getElement("national").checked=0,getElement("local").checked=1,!0},window.national_onclick=function(e){return getElement("local_contest_code").value="",!0},password_tests=[{n_unique:26,regex:/[A-Z]+/},{n_unique:26,regex:/[a-z]+/},{n_unique:10,regex:/[0-9]+/},{n_unique:31,regex:/[!@#$%^&*()~`_\-+={}|;:'"<>,.\[\]?/]+/}],password_strengths=[{log:5,msg:"very weak"},{log:10,msg:"weak"},{log:15,msg:"marginal"},{log:20,msg:"good"},{log:1e100,msg:"very good"}],password_max_log=20,password_strength=function(e){var t,n,r,i;t=1;for(r=0,i=password_tests.length;r<i;r++)n=password_tests[r],n.regex.exec(e)&&(t+=n.n_unique);return e.length*Math.log(t)*Math.LOG10E},strength=function(e){var t,n,r;for(n=0,r=password_strengths.length;n<r;n++){t=password_strengths[n];if(t.log>=e)return t}},lerp=function(e,t,n){return Math.floor((1-e)*t+e*n)},interpolate=function(e,t,n){var r,i,s;return e<0&&(e=0),e>1&&(e=1),r=lerp(e,255&t,255&n),i=lerp(e,255&t>>8,255&n>>8),s=lerp(e,255&t>>16,255&n>>16),s<<16|i<<8|r},color_string=function(e){var t;t=e.toString(16);while(t.length<6)t="0"+t;return"#"+t},window.update_indicators=function(){var e,t,n,r,i,s,o;return o=getElement("team_password"),r=getElement("team_password_confirmation"),n=password_strength(o.value),s=.5*password_max_log,e=n<s?interpolate(n/s,16711680,16776960):interpolate((n-s)/s,16776960,65280),i=getElement("strength_meter"),i.style.backgroundColor=color_string(e),i.innerHTML=strength(n).msg,i.style.color=color_string(interpolate(.7,0,e)),t=getElement("match_indicator"),o.value===r.value?(t.innerHTML="match",e=65280):(t.innerHTML="no match",e=16711680),t.style.backgroundColor=color_string(e),t.style.color=color_string(interpolate(.7,0,e)),void 0},set_field_value=function(e,t){return getElement(e).value=t},tick_spacing=function(e,t){var n;e<0&&(e=-e),n=1;for(;;){if(e/n<=t)return n;n*=2;if(e/n<=t)return n;n*=2.5;if(e/n<=t)return n;n*=2}return void 0},bar=function(e,t,n,r){return r==null&&(r="bottom"),n===null?'<span style="display: inline-block;vertical-align: '+r+";width: "+e+";height: "+t+';" />':'<span style="display: inline-block;vertical-align: '+r+";width: "+e+";height: "+t+";background-color: "+n+';" />'},zero_pad=function(e,t){var n;while(n.length<t)n="0"+n;return n+""},commafy=function(e){var t;t="";for(;;){if(e<=999)return e+t;t=","+zero_pad(e%1e3,3)+t,e=Math.floor(e/1e3)}return void 0},label_inc=32,tick_width=32,marker_margin=3,window.standings_graph=function(e,t,n){var r,i,s,o,u,a;if(t<2)return"Your team ranks "+e+" of "+t+" entries in your category!";e>t&&(e=t),u=tick_spacing(t,4),r='<table><tr><td colspan="4"><b>Your Team\'s National Contest Standing</b><br>&nbsp;</td></tr> +      <tr><td nowrap align="right" valign="top">'+bar(1,marker_margin,space,"top")+"<br>      "+bar(tick_width,1,blue)+"<br>#1&nbsp;",a=0,s=Math.max(u,2);while(s<=t)i=label_inc,s+u>t&&(i+=Math.round(label_inc*(t-s)/u),s=t),r+=""+bar(1,i-1,null,"top")+"<br>"+bar(tick_width,1,"blue")+"<br>"+commafy(s),a+=i,s+=u;return r+='</td><td nowrap valign="top">'+bar(1,marker_margin,null,"top")+"<br>    "+bar(8,a+1,"blue")+'</td><td nowrap align="left" valign="top">',o=Math.round(a*(e-1)/(t-1)),o>0&&(r+=""+bar(1,o,space,"top")+"<br>"),r+("&nbsp;<b>"+commafy(e)+"</b> of <b>"+commafy(t)+"</b> teams!    </td></tr></table>")},window.do_submit=function(name){return eval("document.forms[0]."+name+".value = 1"),document.forms[0].submit()}}).call(this);