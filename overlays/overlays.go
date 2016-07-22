package overlays

import (
	"fmt"
	"strings"
	"path/filepath"
	"errors"
	"os"
)

type OverlaySearchDirs []string

func (o *OverlaySearchDirs) String() string {
	return fmt.Sprint(*o)
}

func (o *OverlaySearchDirs) Set(v string) error {
	for _, pth := range strings.Split(v, ":") {
		*o = append(*o, pth)
	}
	return nil
}

func FindOverlay(workdir string, ovls OverlaySearchDirs, name string) (string, error) {
	for _, pth := range ovls {
		dockerfilePth := filepath.Join(workdir, pth, fmt.Sprintf("%s.Dockerfile", name))
		if _, err := os.Stat(dockerfilePth); err == nil {
			return dockerfilePth, nil
		}
	}
	return "", errors.New(fmt.Sprintf("Overlay %s.Dockerfile not found in %s", name, ovls))
}


