# Notes

At the server side, all requests are dealt with by creating a new worker thread.\
In the case of subscribe, the server side thread is permanently created until the subscriber disconnects. This is the simplest solution, but could result in shortage of worker threads.

At the client side, calling subscribe creates a thread that waits for a stream from the server. All other operations are done sequentially.

All operations are done by first locking the entire list of documents.
This is not a huge slowdown since all operations are effectively instant.

# Running

1. Compile protobufs: `python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. document.proto`
2. Run server: `python server.py localhost:<port>`
3. Run client(s): `python client.py localhost:<port>` (server's port)
