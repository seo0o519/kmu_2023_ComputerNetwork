import sys
import os
import socket

PORT = int(sys.argv[1])
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('', PORT))

# 클라이언트의 연결 요청 대기
server_socket.listen(1)
print("Student ID : 20210132")

while True:
    # 클라이언트가 tcp 연결 요청하면 받아들인다.
    client_socket, addr = server_socket.accept()

    command = client_socket.recv(1024).strip()

    if command.startswith(b'GET '):
        filename = command.split()[1]  # 명령어에서 파일 이름 추출
        if os.path.exists(filename) and os.path.isfile(filename):
            # 파일이 존재하는 경우, 파일 내용 전송
            with open(filename, 'rb') as f:
                file_data = f.read()
            client_socket.sendall(file_data)
        else:
            client_socket.sendall(b'FILE NOT FOUND\r\n')

    elif command.startswith(b'PUT '):
        # 파일 이름과 데이터 분리
        parts = command.split(b'\n', maxsplit=1)
        filename = parts[0].split()[1].decode()
        data = parts[1]

        # 파일 생성 및 데이터 쓰기
        with open(filename, 'wb') as f:
            f.write(data)
            while True:
                data = client_socket.recv(1024)
                if not data:
                    break
                f.write(data)

    elif command.startswith(b'LS '):
        ext = command.split()[1].decode()  # 명령어에서 확장자 추출
        files = [f for f in os.listdir() if f.endswith('.' + ext)]
        if files:
            # 파일 목록을 전송
            response = '\r\n'.join(files) + '\r\n'
            client_socket.sendall(response.encode())
    client_socket.close()
