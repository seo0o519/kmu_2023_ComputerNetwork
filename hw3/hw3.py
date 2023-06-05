import sys
import os
import socket

serverPort = int(sys.argv[1])
serverSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serverSocket.bind(('', serverPort))

serverSocket.listen(1)
print("Student :20210132", flush=True)

CONTENT_BODY =\
"""HTTP/1.0 200 OK
Connection: close
Content-Length: {length}
Content-Type: {type}

"""
ERROR_BODY =\
"""HTTP/1.0 404 NOT FOUND
Connection: close
Content-Length: 0
Content-Type: text/html

"""

def FileConverter(type, data):
    print(f"File Transfer Done: Sent {len(data)}, File Size {len(data)}", flush=True)
    return CONTENT_BODY.replace("{type}", type).replace("{length}", str(len(data))).encode('ascii')+data

while True:
    clientSocket, addr = serverSocket.accept()

    print(f"New Client : Host IP {addr[0]}, Port {addr[1]}", flush=True)

    request = clientSocket.recv(1024).strip()
    print("\n".join([x for x in request.decode().split("\n") if "Host:" not in x]), flush=True)
    if request.startswith(b'GET '):
        filename = '.'+request.split()[1].decode()
        if os.path.exists(filename) and os.path.isfile(filename):
            with open(filename, 'rb') as f:
                file_data = f.read()
            if filename.split('.')[2] == "html":
                clientSocket.sendall(FileConverter('text/html', file_data))
            elif filename.split('.')[2] == "jpg":
                clientSocket.sendall(FileConverter('image/jpeg', file_data))
            else:
                clientSocket.sendall(FileConverter('text/plain', file_data))
        else:
            print(f"SERVER Error : No such file {filename}!", flush=True)
            clientSocket.sendall(ERROR_BODY.encode('ascii'))

    clientSocket.close()