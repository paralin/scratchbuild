Scratchbuild
============

This is a small bash script which can successfully compile **from scratch** MOST docker library images.

It recursively traverses the sources tree down to the base image and compiles up from there.

This is VERY useful for rebuilding docker images on non-intel architectures.
