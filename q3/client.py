import sys
import grpc
import threading
import document_pb2
import document_pb2_grpc

def listen_for_updates(stub, document_name):
    request = document_pb2.UpdateRequest(name=document_name)
    status_printed = false
    try:
        for update in stub.SubscribeToUpdates(request):
            print(f"\n[Update] Document {update.name} modified.")
            print(update.content)
            print("> ", end="", flush=True)
    except grpc.RpcError:
        pass

def main():
    if len(sys.argv) != 2:
        print("Usage: python client.py <host:port>")
        sys.exit(1)
        
    channel = grpc.insecure_channel(sys.argv[1])
    stub = document_pb2_grpc.DocumentServiceStub(channel)
    
    while True:
        print("\n1. Create Document\n2. Open Document\n3. Edit Document\n4. Subscribe to Updates\n5. Exit")
        choice = input("> ")
        
        if choice == '1':
            cmd = input("<name> \"<content>\": ").split(' ', 1)
            if len(cmd) >= 2:
                content = cmd[1].strip('"')
                res = stub.CreateDocument(document_pb2.CreateDocumentRequest(name=cmd[0], initial_content=content))
                print(f"[Client] {res.message}")
                
        elif choice == '2':
            cmd = input("<name>: ").split(' ')
            if len(cmd) == 1:
                res = stub.GetDocument(document_pb2.GetDocumentRequest(name=cmd[0]))
                if res.success:
                    print(f"[Client] {res.content}")
                else:
                    print(f"[Client] {res.message}")
                    
        elif choice == '3':
            cmd = input("<name> <position> \"<text>\": ").split(' ', 2)
            if len(cmd) >= 3:
                text = cmd[2].strip('"')
                res = stub.EditDocument(document_pb2.EditDocumentRequest(name=cmd[0], position=int(cmd[1]), text=text))
                print(f"[Client] {res.message}")
                
        elif choice == '4':
            cmd = input("<name>: ").split(' ')
            if len(cmd) == 1:
                threading.Thread(target=listen_for_updates, args=(stub, cmd[0]), daemon=True).start()
                
        elif choice == '5':
            break

main()
