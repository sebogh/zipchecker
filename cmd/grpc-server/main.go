/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// Package main implements a server for Greeter service.
package main

import (
	"context"
	"fmt"
	"git.thinkproject.com/zipchecker/internal"
	empty "github.com/golang/protobuf/ptypes/empty"
	"log"
	"net"

	pb "git.thinkproject.com/zipchecker/proto"
	"google.golang.org/grpc"

)

var buildGithash = "to be set by linker"

const (
	port = ":50051"
)

// server is used to implement zipchecker.ZipcheckerServer.
type server struct {
	pb.UnimplementedZipcheckerServer
}

// Hash implements zipchecker.ZipcheckerServer
func (s *server) GetHash(ctx context.Context, _ *empty.Empty) (*pb.HashReply, error) {
	log.Print("received request")
	return &pb.HashReply{Message: buildGithash}, nil
}

func (s *server) CheckZip(ctx context.Context, in *pb.CheckZipRequest) (*pb.CheckZipResponse, error) {
	log.Print("received zip request")
	match := places.Check(in.ZipCode, in.PlaceName)
	return &pb.CheckZipResponse{
		CountryCode:          match.Place.CountryCode,
		ZipCode:              match.Place.ZipCode,
		Place:                match.Place.Place,
		State:                match.Place.State,
		StateCode:            match.Place.StateCode,
		Province:             match.Place.Province,
		ProvinceCode:         match.Place.ProvinceCode,
		Community:            match.Place.Community,
		CommunityCode:        match.Place.CommunityCode,
		Latitude:             match.Place.Latitude,
		Longitude:            match.Place.Longitude,
		Distance:             int32(match.Distance),
		Percentage:           int32(match.Percentage),
	}, nil
}

var places *internal.Places

func main() {
	places = internal.NewPlaces()
	log.Printf("initialized list of %d places.", len(*places))
	lis, err := net.Listen("tcp", port)
	fmt.Printf("going to listen on port %s", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterZipcheckerServer(s, &server{})
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}