package stack

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"path"
	"strings"

	log "github.com/Sirupsen/logrus"
	"github.com/docker/distribution/reference"
	dfparser "github.com/docker/docker/builder/dockerfile/parser"
	"github.com/paralin/scratchbuild/arch"
)

// ImageStack represents an image as a stack of layers.
type ImageStack struct {
	// The final reference of the last layer.
	Reference reference.Named
	// Layers, from top to bottom.
	Layers []*ImageLayer
}

// RebaseOnArch attempts to rebase the Stack on a compatible image for the target arch.
func (s *ImageStack) RebaseOnArch(target arch.KnownArch) error {
	for i := len(s.Layers) - 1; i >= 0; i-- {
		layer := s.Layers[i]
		refName := layer.Reference.Name()
		if refName == "scratch" {
			continue
		}
		compatImage, ok := arch.CompatibleBaseImage(target, refName)
		if !ok {
			continue
		}

		log.Debugf("Rebasing using %s -> %s", refName, compatImage)
		// base on this
		s.Layers = s.Layers[:i+1]
		layer.Dockerfile = nil
		layer.Path = ""
		if tagged, ok := layer.Reference.(reference.NamedTagged); ok {
			compatImage = fmt.Sprintf("%s:%s", compatImage, tagged.Tag())
		}
		img, _ := ParseImageName(compatImage)
		layer.Reference = img

		if i != 0 {
			previousLayer := s.Layers[i-1]
			previousLayer.RewriteFrom(img)
		}
	}
	return nil
}

// RewriteFrom rewrites the FROM definition in the dockerfile.
func (l *ImageLayer) RewriteFrom(img reference.Reference) {
	if l.Dockerfile == nil {
		return
	}

	ast := l.Dockerfile.AST
	for _, line := range ast.Children {
		if line.Value == "from" {
			line.Next = &dfparser.Node{Value: img.String()}
			line.Original = fmt.Sprintf("FROM %s", line.Next.Value)
			break
		}
	}
}

// String represents the stack as a string.
func (s *ImageStack) String() string {
	var results bytes.Buffer
	for _, layer := range s.Layers {
		results.WriteString(layer.Reference.String())
		if layer.Dockerfile == nil && layer.Reference.Name() != "scratch" {
			results.WriteString(" [pull]")
		}
		results.WriteString(" ")
	}
	return results.String()
}

// ToDockerfile produces a series of dockerfiles representing the stack.
func (s *ImageStack) ToDockerfile() string {
	var result bytes.Buffer
	for i, image := range s.Layers {
		result.WriteString(image.ToDockerfile())
		if i != len(s.Layers)-1 {
			result.WriteString("\n---\n")
		}
	}
	return result.String()
}

// ImageLayer is a layer in a stack.
type ImageLayer struct {
	// Reference is the name/tag/etc of this image.
	Reference reference.Named
	// Dockerfile is the dockerfile source for this image.
	Dockerfile *dfparser.Result
	// Path is the path to the dockerfile directory for this image layer.
	Path string
}

// ParseDockerfile applies a Dockerfile source to a layer.
func (l *ImageLayer) ParseDockerfile(source string) error {
	res, err := dfparser.Parse(strings.NewReader(source))
	if err != nil {
		return err
	}
	l.Dockerfile = res
	return nil
}

// ToDockerfile produces a Dockerfile equivilent to the original source.
func (l *ImageLayer) ToDockerfile() string {
	if l.Dockerfile == nil {
		return ""
	}
	var result bytes.Buffer
	// iterate over lines in the source, trim the ( and )
	scanner := bufio.NewScanner(strings.NewReader(l.Dockerfile.AST.Dump()))
	for scanner.Scan() {
		text := scanner.Text()
		if strings.HasPrefix(text, "(") && strings.HasSuffix(text, ")") {
			runes := ([]rune(text))[1:]
			runes[len(runes)-1] = '\n'
			result.WriteString(string(runes))
		} else {
			result.WriteString(text)
			result.WriteString("\n")
		}
	}
	return result.String()
}

// LibraryResolver resolves dockerfile sources for library images.
type LibraryResolver interface {
	// GetLibrarySource clones the source for the Dockerfile
	GetLibrarySource(ref reference.NamedTagged) (string, error)
}

// ImageStackFromDockerfile attempts to determine the full stack of the docker image.
func ImageStackFromPath(buildPath string, dockerfilePath string, targetTag string, resolver LibraryResolver) (*ImageStack, error) {
	imageRef, err := ParseImageName(targetTag)
	if err != nil {
		return nil, err
	}

	dockerfilePath = path.Clean(dockerfilePath)
	if !path.IsAbs(dockerfilePath) {
		dockerfilePath = path.Join(buildPath, dockerfilePath)
	}

	sourceBin, err := ioutil.ReadFile(dockerfilePath)
	if err != nil {
		return nil, err
	}
	source := string(sourceBin)

	stack := &ImageStack{Reference: imageRef}
	baseLayer := &ImageLayer{Reference: imageRef, Path: buildPath}
	if err := baseLayer.ParseDockerfile(source); err != nil {
		return nil, err
	}
	stack.Layers = []*ImageLayer{baseLayer}
	return stack, stack.processDockerfile(resolver)
}

// processDockerfile processes the next dockerfile in the stack.
func (s *ImageStack) processDockerfile(resolver LibraryResolver) error {
	layer := s.Layers[len(s.Layers)-1]
	if layer.Dockerfile == nil || layer.Reference.Name() == "scratch" {
		return nil
	}

	lines := layer.Dockerfile.AST.Children

	var nlayer *ImageLayer
	for _, line := range lines {
		if line.Value == "from" {
			if line.Next == nil || line.Next.Value == "" {
				return fmt.Errorf("Dockerfile FROM line is invalid: %s", line.Original)
			}
			ref, err := ParseImageName(line.Next.Value)
			if err != nil {
				return fmt.Errorf("Error parsing FROM line: %v", err)
			}
			nlayer = &ImageLayer{Reference: ref}
			break
		}
	}

	if nlayer == nil {
		return fmt.Errorf("Dockerfile did not have a FROM line.")
	}

	s.Layers = append(s.Layers, nlayer)

	if nlayer.Reference.Name() == "scratch" {
		return nil
	}

	// Attempt to find the source for this image.
	le := log.WithField("image", nlayer.Reference.Name())
	if !strings.HasPrefix(nlayer.Reference.Name(), "library/") {
		le.Debug("Not a library image, cannot determine Dockerfile source.")
		return nil
	}

	tagged, ok := nlayer.Reference.(reference.NamedTagged)
	if !ok {
		le.Debug("No tag given, assuming latest")
		t, err := reference.WithTag(nlayer.Reference, "latest")
		if err != nil {
			return err
		}
		tagged = t
	}

	srcPath, err := resolver.GetLibrarySource(tagged)
	if err != nil {
		le.WithError(err).Warn("Unable to resolve library source")
		return nil
	}
	nlayer.Path = srcPath

	dfPath := path.Join(srcPath, "Dockerfile")
	src, err := ioutil.ReadFile(dfPath)
	if err != nil {
		le.WithField("path", dfPath).WithError(err).Warn("Unable to find Dockerfile")
		return nil
	}

	if err := nlayer.ParseDockerfile(string(src)); err != nil {
		le.WithError(err).Warn("Unable to parse library dockerfile")
		return nil
	}

	return s.processDockerfile(resolver)
}
