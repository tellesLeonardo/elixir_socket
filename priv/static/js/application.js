(() => {
    class myWebsocketHandler {
      setupSocket() {
        this.socket = new WebSocket("ws://10.0.0.15:4000/ws/999144813")
  
        this.socket.addEventListener("message", (event) => {
          const pTag = document.createElement("p")
          pTag.innerHTML = event.data
  
          document.getElementById("main").append(pTag)
        })
  
        this.socket.addEventListener("close", () => {
          this.setupSocket()
        })
      }
  
      submit(event) {
        event.preventDefault()
        const input = document.getElementById("message")
        const message = input.value
        input.value = ""
  
        this.socket.send(
          JSON.stringify({
            data: {message: message},
          })
        )
      }
    }
  
    const websocketClass = new myWebsocketHandler()
    websocketClass.setupSocket()
    
    document.getElementById("button")
      .addEventListener("click", (event) => websocketClass.submit(event))
  })()