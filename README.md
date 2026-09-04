# DSA Assignment 1

Distributed Systems and Applications assignment implemented using Ballerina.

## Question 1: RESTful APIs - Library and Resource Management System

Implementation by Prince-Lee.

### Technology
- Ballerina
- REST/HTTP
- Ballerina Map/Table in-memory datastore

### Current Implementation
- Asset data models
- Component management model
- Schedule model
- Work order and task model
- Institution model
- `assetTag` as unique asset identifier
- RESTful CRUD API
- HTTP error handling

## Question 2: Remote Invocation - Rental Accommodation System

Implemented as sibling Ballerina packages in `question-2-rental-accommodation/server` and
`question-2-rental-accommodation/client`.

### Technology
- Ballerina
- gRPC
- Protocol Buffers
- Ballerina maps/tables

### Operations
- `AddProperty`: registers a property and returns a generated property ID.
- `CreateUsers`: client-streaming registration for multiple hosts and guests.
- `UpdateProperty`: updates a listing by property ID.
- `ListProperties`: server-streaming listing with optional location and property-type filters.

### Running Question 2
1. Start the server with `bal run` from `question-2-rental-accommodation/server`.
2. Run `bal run` from `question-2-rental-accommodation/client`.
