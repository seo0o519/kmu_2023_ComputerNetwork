import sys
from socket import *

serverName = sys.argv[1]
serverPort = int(sys.argv[2])
clientSocket = socket(AF_INET, SOCK_STREAM)
clientSocket.connect((serverName,serverPort))
send_data = ""

while True:
    data = input().strip()
    data = data + '\r\n'
    send_data = send_data + data

    if data == '\r\n' or data =='\n' or data == "" or not data:
        break

clientSocket.send(send_data.encode())

while True:

    received_data = clientSocket.recv(10000)
    if not received_data:
        break
    print(received_data.decode(), end="")
clientSocket.close()