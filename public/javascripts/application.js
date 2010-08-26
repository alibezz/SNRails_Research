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
  return newList;
}

function putAlternative(alt, list) {
  if (!list) list = [];
  list[list.length] = alt.value;
  return list;
}

function getElementsByClass(node, searchedClass) {
  var els = node.getElementsByTagName('*');
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


function selectedAlts(alts, isASelection) {
  var selAlts = [];
  var i = 0, chosen;
  for(; i < alts.length; i++) {
    chosen = alts[i].selected || alts[i].checked;
    if((isASelection && chosen) || (!isASelection && !chosen)) {
      selAlts.push(alts[i]);
    }
  }
  return selAlts;
}

function deselectAlts(alts) {
  var i = 0;
  for(; i < alts.length; i++) {
    if(alts[i].selected) {
      alts[i].selected = false;
    } else if(alts[i].checked) {
      alts[i].checked = false;
      alts[i].onchange();
    }
  }
  return alts;
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

function selectQuests(alts, isSelection) {
  var funcA, funcB;    
  if(isSelection) {
   funcA = putAlternative;
   funcB = cutAlternative;
  } else {
   funcA = cutAlternative;
   funcB = putAlternative;
  }
  var quests = getElementsByClass(document, "item");
  var i = 0;
  for(; i < alts.length; i++) {
    var j = 0;
    for(; j < quests.length; j++) {
      var relation = findRelation(alts[i], eval(quests[j].getAttribute("data-relations")));
      if(relation == 0) { //different-of relation
        quests[j].setAttribute("data-deps","[" +funcA(alts[i], eval(quests[j].getAttribute("data-deps")))+ "]");
      } else if (relation == 1) {
          quests[j].setAttribute("data-deps", "[" +funcB(alts[i], eval(quests[j].getAttribute("data-deps")))+"]");
      }
    } 
  }
}
  
function deselectAltsFromInvisibleQuestions() {
  jQuery(".item").each( function() {
    if (this.getAttribute("data-deps") != "[]") {
      //FIXME Change the way you get ivalues and select tag
      var ivalue = jQuery(this).children()[1];
      var selectTag = jQuery(ivalue).children()[0];
      if (!selectTag.options) {
        deselectAlts(getInputValues(ivalue));
      } else {
        deselectAlts(selectTag.options);
        //FIXME The line below has a very bad performance.
        // selectTag.onchange(); 
      }
    } 
  });
}
