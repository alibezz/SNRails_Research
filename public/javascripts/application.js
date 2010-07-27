// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function cutAlternative(alt, list) {
  var i = 0;
  var newList = [];
  for(; list[i] != alt; i++) {
    newList[i] = list[i];
  }
  //"j=i++" Guarantees that there will have no newList element undefined
  for(j = i++; list[i] != undefined; i++, j++) {
     newList[j] = list[i];
  }
  return newList;
}

function putAlternative(alt, list) {
  var i = 0;
  if (list[i] == undefined) list = []; //dealing with empty lists 
  for(; list[i] != undefined; i++);
  list[i] = alt;
  return list;
}

function accomp(alt, conds) {
//This function updates a list that every question has containing its dependencies (item_value ids).
// A question must be displayed IF AND ONLY IF this list is empty
  var i = 0;
  var previousList;

  for(; conds[i] != undefined; i = i + 2) {
    previousList = document.getElementById("deps_"+conds[i]).innerHTML;

    if (conds[i + 1] == 1) { //the conditional is an 'equals to' relation
      document.getElementById("deps_"+conds[i]).innerHTML = cutAlternative(alt, previousList); 
    } else { //the conditional is a 'different of' relation
      document.getElementById("deps_"+conds[i]).innerHTML = putAlternative(alt, previousList); 
    }  
  }
  
}
