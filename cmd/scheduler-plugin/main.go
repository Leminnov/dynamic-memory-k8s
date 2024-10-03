package main

import (
	"os"

	"github.com/sscargal/dynamic-memory-k8s/pkg/scheduler"
	"k8s.io/component-base/cli"
	"k8s.io/kubernetes/cmd/kube-scheduler/app"
)

func main() {
	command := app.NewSchedulerCommand(
		app.WithPlugin("DynamicMemoryScheduler", scheduler.New),
	)
	code := cli.Run(command)
	os.Exit(code)
}
