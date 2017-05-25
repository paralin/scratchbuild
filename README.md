# Scratch Build

[![GoDoc Widget]][GoDoc] [![Go Report Card Widget]][Go Report Card]

[GoDoc]: https://godoc.org/github.com/paralin/scratchbuild
[GoDoc Widget]: https://godoc.org/github.com/paralin/scratchbuild?status.svg
[Go Report Card Widget]: https://goreportcard.com/badge/github.com/paralin/scratchbuild
[Go Report Card]: https://goreportcard.com/report/github.com/paralin/scratchbuild

## Introduction

Scratch Build is a small CLI tool that can successfully compile **from scratch** the majority of the Docker library images.

Images are built by traversing the Dockerfile stack down to either scratch or a known working alternative for the target architecture, and then working up to the target.

This is VERY useful for rebuilding docker images on non-intel architectures.
