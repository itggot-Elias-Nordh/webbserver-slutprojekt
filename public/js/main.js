function friendsOpen() {
    document.querySelector(".friends").classList.add("animation");
    document.querySelector(".friends").classList.remove("animation2");
}
 
function friendsClose() {
    document.querySelector(".friends").classList.remove("animation");
    document.querySelector(".friends").classList.add("animation2");
}

function groupsOpen() {
    document.querySelector(".groups").classList.add("animation");
    document.querySelector(".groups").classList.remove("animation2");
}
 
function groupsClose() {
    document.querySelector(".groups").classList.remove("animation");
    document.querySelector(".groups").classList.add("animation2");
}

function chatToggle(element) {
    friend = console.log(element.innerHTML)
    document.querySelector(".add").classList.toggle("none");
    document.querySelector(".chat").classList.toggle("none");
}

 $(document).ready(function(){
    $('#window').scrollTop($('#window')[0].scrollHeight - $('#window')[0].clientHeight);
});
