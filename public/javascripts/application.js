// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function cutAlternative(alt, list) {
  var newList = [];
  var i = 0;
  for(; i < list.length; i++) {
    if(list[i] != alt.value) {
      newList.push(list[i]);
    }    
  }
  return newList.join("");
}

function putAlternative(alt, list) {
  if (!list) list = [];
  list[list.length] = alt.value;
  return list.join("");
}

function getElementsByClass(searchedClass) {
  var els = document.getElementsByTagName('*');
  var classElements = [];
  var elsLen = els.length;
  var pattern = new RegExp('(^|\\\\s)'+searchedClass+'(\\\\s|$)');
  for (i = 0, j = 0; i < elsLen; i++) {
    if ( pattern.test(els[i].className) ) {
      classElements[j] = els[i];
      j++;
    }
  }
  return classElements;
}

function findRelation(alt, relations) {
  var i = 0;
  for(i = 0; i < relations.length; i++) {
    if (relations[i][0] == alt.value) {
      return relations[i][1];
    }
  }
  return -1; //the alternative is not a dependency
}

//#FIXME Refactoring is HIGHLY needed

function selectedAlts(alts) {
  var selAlts = [];
  var i = 0;
  for(; i < alts.length; i++) {
    if(alts[i].selected || alts[i].checked) {
      selAlts.push(alts[i]);
    }
  }
  return selAlts;
}

function getInputValues(question) {
  var i = 0;
  var children = question.childNodes, values = [];
  for(; i < children.length; i++) {
    if (children[i].type == "radio" || children[i].type == "text") {
        values.push(children[i]);
    } 
  }
  return values;
}

/*function solveDeps(isASelection) {
  if (isASelection) {
    var funcA = putAlternative;
    var funcB = cutAlternative;
  } else {
    var funcA = cutAlternative;
    var funcB = putAlternative;
  }
  return */ function selectQuests(alts) {
    var quests = getElementsByClass("item");
    var i = 0;
    for(; i < alts.length; i++) {
      var j = 0;
      for(; j < quests.length; j++) {
        var relation = findRelation(alts[i], eval(quests[j].getAttribute("data-relations")));
        if(relation == 0) { //different-of relation
            quests[j].setAttribute("data-deps", putAlternative(alts[i], eval(quests[j].getAttribute("data-deps"))));
        } else if (relation == 1) {
            quests[j].setAttribute("data-deps", cutAlternative(alts[i], eval(quests[j].getAttribute("data-deps"))));
        } 
      }
    }
  }
//}

    //se alts[i] foi selecionada, retire do data-needed de cada questão que depende dela em 'equals-to'
      // e coloque em toda questão que depende dela em 'different-of'
     // o data-deps começa com as 'equals to' apenas, que vão sendo retiradas. se uma 'different-of' for marcada
     // eh incluida no data-deps
     // uma questao soh eh exibida qdo o data-deps estiver vazio
     // as relações de different-of ou equals-to ficam em data-relations
  //    alert("**********" + quests[j].getAttribute("data-relations"));

/*function select_quests(alt, quest_rels) {
//This function updates a list that every question has containing its dependencies (item_value ids),
//when an alternative 'alt' is selected.
// A question must be displayed IF AND ONLY IF this list is empty
  var i = 0;
  var previousList;

  for(; quest_rels[i] != undefined; i = i + 2) {
    previousList = document.getElementById("deps_" + quest_rels[i]).innerHTML;

    if (quest_rels[i + 1] == 1) { //the conditional is an 'equals to' relation
      document.getElementById("deps_" + quest_rels[i]).innerHTML = cutAlternative(alt, previousList); 
    } else { //the conditional is a 'different of' relation
      document.getElementById("deps_" + quest_rels[i]).innerHTML = putAlternative(alt, previousList); 
    }  
  }
} */

/*function deselect_quests(alt, quest_rels) {
//This function updates a list that every question has containing its dependencies (item_value ids),
//when an alternative 'alt' is DEselected.
  
  var i = 0;
  var previousList;

  for(; quest_rels[i] != undefined; i = i + 2) {
    previousList = document.getElementById("deps_" + quest_rels[i]).innerHTML;

    if (quest_rels[i + 1] == 1) { //the conditional is an 'equals to' relation
      document.getElementById("deps_" + quest_rels[i]).innerHTML = putAlternative(alt, previousList); 
    } else { //the conditional is a 'different of' relation
      document.getElementById("deps_" + quest_rels[i]).innerHTML = cutAlternative(alt, previousList); 
    }  
  }
} */

/*function deselect_alts(other_alts, other_quests) {
  var i = 0;
  alert("alll: " + other_quests[0]);
  for(; other_alts[i] != undefined; i++) {
    alert("other_alts: " + other_alts[i]);
    alert("other_quests: " + other_quests[i]);
    deselect(other_alts[i], other_quests[i]);
  } 
}*/
