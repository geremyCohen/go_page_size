```
package main

import (
	"fmt"
	"log"
	"runtime"

	"go.uber.org/automaxprocs/maxprocs"
)

func main() {
	undo, err := maxprocs.Set(maxprocs.Logger(log.Printf))
	defer undo()

	if err != nil {
		log.Fatalf("failed to set GOMAXPROCS: %v", err)
	}

	procs := runtime.GOMAXPROCS(0)
	fmt.Printf("GOMAXPROCS is set to %d\n", procs)
}
```

go mod init example.com/automaxprocs-demo
go get go.uber.org/automaxprocs
go run main.go

