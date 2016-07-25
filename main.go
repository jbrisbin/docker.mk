package main

import (
	"flag"
	"log"
	"github.com/jbrisbin/dockermk/overlays"
	"strings"
	"os"
	"fmt"
	"io"
	"text/template"
	"path/filepath"
	"bytes"
	"io/ioutil"
)

var (
	overlaySearchDirs overlays.OverlaySearchDirs
	out io.Writer
)

type OsEnv interface {
	Name() string
	Family() string
	Version() string
}

func main() {
	// Setup flags
	dockerfileName := flag.String("f", "", "Name of the Dockerfile to create")
	workdir := flag.String("w", ".", "Work directory")

	// Dockerfile directives
	fromStr := flag.String("from", "ubuntu", "Value to use in the FROM line")
	maintainerStr := flag.String("maintainer", "", "Value to use in the MAINTAINER line")
	cmdStr := flag.String("cmd", "bash", "Value to use in the CMD line")
	entryStr := flag.String("entrypoint", "", "Value to use in the ENTRYPOINT line")

	flag.Var(&overlaySearchDirs, "d", "Search directory for overlay files")

	// Parse args
	flag.Parse()

	// If no overlay dirs specified, use default set
	if len(overlaySearchDirs) == 0 {
		overlaySearchDirs.Set(".:overlays")
	}

	// Decide whether to output to stdout or a file
	if len(strings.TrimSpace(*dockerfileName)) == 0 {
		// dump to stdout
		out = os.Stdout
	} else {
		// write to a Dockerfile
		df, err := os.Create(filepath.Join(*workdir, *dockerfileName))
		if nil != err {
			log.Fatal(err)
		}
		defer df.Close()
		out = df
	}

	var tmplVars = make(map[string]interface{})

	// Transfer ENV vars to template variables
	var envVars = make(map[string]string)
	for _, envvar := range os.Environ() {
		pair := strings.Split(envvar, "=")
		envVars[pair[0]] = pair[1]
	}
	tmplVars["Env"] = envVars

	// Always write FROM
	fmt.Fprintf(out, "FROM %s\n", *fromStr)
	if len(*maintainerStr) > 0 {
		// Create MAINTAINER line, if set
		fmt.Fprintf(out, "MAINTAINER %s\n\n", *maintainerStr)
	}

	// Generate Dockerfile
	var tmpl = template.New("dockerfile")
	var buf bytes.Buffer
	for _, ovl := range flag.Args() {
		o, err := overlays.FindOverlay(*workdir, overlaySearchDirs, ovl)
		if nil != err {
			log.Fatal(err)
		}
		relpath, err := filepath.Rel(*workdir, o)
		if nil != err {
			log.Fatal(err)
		}
		// Set the current pwd
		pwd, err := filepath.Rel(*workdir, filepath.Dir(o))
		if nil != err {
			log.Fatal(err)
		}
		buf.WriteString(fmt.Sprintf("# overlay: %s {{$dir := \"%s\"}}\n", relpath, pwd))
		bytes, err := ioutil.ReadFile(o)
		if nil != err {
			log.Fatal(err)
		}
		buf.Write(bytes)
	}
	// Execute template
	tmpl.Parse(buf.String())
	err := tmpl.Execute(out, tmplVars)
	if nil != err {
		log.Fatal(err)
	}

	// Create CMD line, if set
	if len(*cmdStr) > 0 {
		fmt.Fprintf(out, "\nCMD %s\n", *cmdStr)
	}
	// Create ENTRYPOINT line, if set
	if len(*entryStr) > 0 {
		fmt.Fprintf(out, "ENTRYPOINT %s\n", *entryStr)
	}
}
