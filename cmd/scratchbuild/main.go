package main

import (
	"os"

	sbcli "github.com/paralin/scratchbuild/cli"
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli/v2"
)

func main() {
	log.SetLevel(log.DebugLevel)

	app := cli.NewApp()
	app.Name = "scratchbuild"
	app.Description = "Builds Docker images from scratch."
	app.Commands = sbcli.RootCommands
	app.Run(os.Args)
}
