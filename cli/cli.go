package cli

import (
	"github.com/urfave/cli/v2"
)

// RootCommands are the root level commands.
var RootCommands cli.Commands = []*cli.Command{
	BuildCommand,
}
