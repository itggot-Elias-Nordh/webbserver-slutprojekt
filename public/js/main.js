function friendsOpen() {
    document.querySelector(".friends").classList.add("animation");
    document.querySelector(".friends").classList.remove("animation2");
 }
 
 function friendsClose() {
    document.querySelector(".friends").classList.remove("animation");
    document.querySelector(".friends").classList.add("animation2");
 }

 function chatToggle(element) {
    friend = console.log(element.innerHTML)
    document.querySelector(".add").classList.toggle("none");
    document.querySelector(".chat").classList.toggle("none");
 }

 function getShit(){
    $.get('/test', function(data){
        console.log(data)
    })
 }

 setInterval(getShit, 1000)