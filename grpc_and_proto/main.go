//go:generate bash scripts/gen.sh
package main

import (
   "context"
   "fmt"
   "log"
   "net"
   "time"

   "google.golang.org/grpc"
   "google.golang.org/grpc/credentials/insecure"
   pb "example.com/helloworld/grpc_and_proto/proto"
)

type pingServer struct {
   pb.UnimplementedPingServiceServer
}

func (s *pingServer) Ping(ctx context.Context, req *pb.PingRequest) (*pb.PongReply, error) {
   log.Printf("Received ping: %s", req.Message)
   return &pb.PongReply{Message: "PONG"}, nil
}

func main() {
   lis, err := net.Listen("tcp", ":50051")
   if err != nil {
       log.Fatalf("failed to listen: %v", err)
   }
   grpcServer := grpc.NewServer()
   pb.RegisterPingServiceServer(grpcServer, &pingServer{})
   go func() {
       log.Println("Server listening at", lis.Addr())
       if err := grpcServer.Serve(lis); err != nil {
           log.Fatalf("failed to serve: %v", err)
       }
   }()

   // Give the server a moment to start
   time.Sleep(500 * time.Millisecond)

   ctx, cancel := context.WithTimeout(context.Background(), time.Second)
   defer cancel()
   conn, err := grpc.DialContext(ctx, lis.Addr().String(),
       grpc.WithTransportCredentials(insecure.NewCredentials()),
       grpc.WithBlock(),
   )
   if err != nil {
       log.Fatalf("did not connect: %v", err)
   }
   defer conn.Close()

   client := pb.NewPingServiceClient(conn)
   resp, err := client.Ping(context.Background(), &pb.PingRequest{Message: "PING"})
   if err != nil {
       log.Fatalf("could not ping: %v", err)
   }
   fmt.Printf("Response from server: %s\n", resp.Message)

   grpcServer.GracefulStop()
}