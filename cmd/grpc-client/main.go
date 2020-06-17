// Package main implements a client for Greeter service.
package main

import (
	"context"
	"log"
	"time"

	pb "git.thinkproject.com/zipchecker/proto"
	empty "github.com/golang/protobuf/ptypes/empty"
	"google.golang.org/grpc"
)

const (
	address     = "localhost:50051"
)

func main() {
	// Set up a connection to the server.
	conn, err := grpc.Dial(address, grpc.WithInsecure(), grpc.WithBlock())
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewZipcheckerClient(conn)

	// Contact the server and print out its response.
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	var empty empty.Empty
	r, err := c.GetHash(ctx, &empty)
	if err != nil {
		log.Fatalf("could not get hash: %v", err)
	}
	log.Printf("Hash: %s", r.GetMessage())

	zip, errZip := c.CheckZip(ctx, &pb.CheckZipRequest{ZipCode: "12205", PlaceName: "Berlin"})
	if errZip != nil {
		log.Fatalf("could not get hash: %v", errZip)
	}
	log.Print(zip.String())
}
