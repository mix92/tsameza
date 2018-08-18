// Script pour gérer les pannels dans le dashboard:
// Lorsqu'on click sur le bouton adéquat, le dashboard approprié s'affiche

var tabButtons = document.querySelectorAll(".container .PanelsContainer .buttoncontainer button");
var tabPanels = document.querySelectorAll(".container .PanelsContainer .tabpanel")
var HR = document.querySelector(".container .PanelsContainer .buttoncontainer hr");

function displayPanel(panelIndex, colorCode){
  tabButtons.forEach(function(node){
    node.style.backgroundColor = "";
    node.style.color = "";
  });
  tabButtons[panelIndex].style.backgroundColor = colorCode;
  tabButtons[panelIndex].style.color = "white";
    HR.style.height = '1px';
    HR.style.background = colorCode;
    HR.style.fontSize ; 0;
    HR.style.border = 0;
    HR.style.color = colorCode;

  tabPanels.forEach(function(node){
    node.style.display = "none";
  });
  //tabPanels[panelIndex].style.backgroundColor = colorCode;
  tabPanels[panelIndex].style.display = "block";
}
