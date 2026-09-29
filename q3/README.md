at the server side, all requests are dealt with by creating a new worker thread

at the client side, calling subscribe creates a thread that waits for a stream from the server

all operations are done by first locking the entire list of documents
this is not a huge slowdown since all operations are effectively instant

# Running

1. Compile protobufs: `python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. document.proto`
2. Run server: `python server.py localhost:<port>`
3. Run client(s): `python client.py localhost:<port>` (server's port)
