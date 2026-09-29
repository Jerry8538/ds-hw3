import sys
import grpc
import threading
import queue
from concurrent import futures
import document_pb2
import document_pb2_grpc

class DocumentServiceServicer(document_pb2_grpc.DocumentServiceServicer):
    def __init__(self):
        self.documents = {} 
        self.subscribers = {} 
        self.lock = threading.Lock()

    def CreateDocument(self, request, context):
        with self.lock:
            if request.name in self.documents:
                return document_pb2.CreateDocumentResponse(success=False, message="Document already exists.")
            self.documents[request.name] = request.initial_content
            self.subscribers[request.name] = []
            return document_pb2.CreateDocumentResponse(success=True, message=f"Document {request.name} created.")

    def GetDocument(self, request, context):
        with self.lock:
            if request.name not in self.documents:
                return document_pb2.GetDocumentResponse(success=False, message="Document not found.")
            return document_pb2.GetDocumentResponse(success=True, content=self.documents[request.name])

    def EditDocument(self, request, context):
        with self.lock:
            if request.name not in self.documents:
                return document_pb2.EditDocumentResponse(success=False, message="Document not found.")
            
            content = self.documents[request.name]
            pos = min(max(0, request.position), len(content))
            new_content = content[:pos] + request.text + content[pos:]
            self.documents[request.name] = new_content
            
            # places the documentupdate message in each subscriber's queue
            # which is then seen by server thread handling the subscriber
            update = document_pb2.DocumentUpdate(name=request.name, content=new_content)
            for sub_queue in self.subscribers[request.name]:
                sub_queue.put(update)
                
            return document_pb2.EditDocumentResponse(success=True, message="Document updated.")

    def SubscribeToUpdates(self, request, context):
        if request.name not in self.documents:
            context.abort(grpc.StatusCode.NOT_FOUND, "Document not found.")
            
        # create the queue for our subscriber
        q = queue.Queue()
        with self.lock:
            self.subscribers[request.name].append(q)
            
        try:
            # while subscriber is connected
            while context.is_active():
                # get the next entry in the queue and send to subscriber
                update = q.get()
                yield update
        finally:
            with self.lock:
                self.subscribers[request.name].remove(q)

def serve():
    if len(sys.argv) != 2:
        print("Usage: python server.py <host:port>")
        sys.exit(1)
        
    server_address = sys.argv[1]
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    document_pb2_grpc.add_DocumentServiceServicer_to_server(DocumentServiceServicer(), server)
    server.add_insecure_port(server_address)
    server.start()
    print(f"Server started at {server_address}")
    server.wait_for_termination()

serve()
