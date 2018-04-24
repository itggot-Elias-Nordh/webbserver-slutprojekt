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

 $(document).ready(function(){
    $('#window').scrollTop($('#window')[0].scrollHeight - $('#window')[0].clientHeight);
});

 function getShit(){
    $.get('/test', function(data){
        console.log(data)
    })
 }

 setInterval(getShit, 1000)