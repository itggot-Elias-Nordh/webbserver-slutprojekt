function getShit(){
    $('#window').load('/messages', function(data){
        console.log("recieved data")
    })
 }

 getShit()
  setInterval(getShit, 10000)