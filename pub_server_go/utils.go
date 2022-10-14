package main

import (
	"archive/tar"
	"compress/gzip"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net"
	"os"
	"path/filepath"
	"sort"
	"time"

	"github.com/ghodss/yaml"
)

type FileName struct {
	Name string
	Path string
}

func ListDir(path string) []FileName {

	f, err := os.Open(path)
	if err != nil {
		return nil
	}
	files, err := f.Readdir(0)
	if err != nil {
		return nil
	}

	list := []FileName{}
	for _, v := range files {
		name := filepath.Join(path, v.Name())

		list = append(list, FileName{
			Name: v.Name(),
			Path: name,
		})
	}

	return list

}

func getLastedPackageVersion(path string) (string, string) {
	f, err := os.Open(path)
	if err != nil {
		return "", ""
	}

	files, err := f.Readdir(0)
	if err != nil {
		return "", ""
	}

	if len(files) == 0 {
		return "", ""
	}
	sort.Slice(files, func(i, j int) bool {
		return files[i].Name() > files[j].Name()
	})

	return filepath.Join(path, files[0].Name()), files[0].Name()
}

func readPackageVersion(path string) map[string]any {
	file, err := os.ReadFile(filepath.Join(path, "pubspec.yaml"))
	if err != nil {
		return nil
	}
	jsonByte, err := yaml.YAMLToJSON(file)
	if err != nil {
		return nil
	}
	x := map[string]any{}

	json.Unmarshal(jsonByte, &x)

	if err != nil {
		return nil
	}
	return x

}

func readFile(path string) string {

	file, err := os.ReadFile(path)
	if err != nil {
		return ""
	}
	return string(file)

}

func GetOutboundIP() net.IP {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)

	return localAddr.IP
}

func ReadYamlFromZipFile(path string) map[string]any {
	file, err := os.Open(path)
	if err != nil {
		return nil
	}
	defer file.Close()
	r, err := gzip.NewReader(file)

	if err != nil {
		return nil
	}

	defer r.Close()

	tr := tar.NewReader(r)

	for {

		h, err := tr.Next()
		if err != nil {
			return nil
		}

		if h.Name == "pubspec.yaml" {

			ll("压缩包中获取到上传文件中的yaml内容")
			tempYamlName := "./" + fmt.Sprint(rand.Intn(10000)) + h.Name
			tempYamlFile, err := os.Create(tempYamlName)
			if err != nil {
				return nil
			}
			defer os.Remove(tempYamlName)
			defer tempYamlFile.Close()

			if _, err := io.Copy(tempYamlFile, tr); err != nil {
				return nil
			}

			if err != nil {
				return nil
			}

			yamlFileContent, err := os.ReadFile(tempYamlName)
			if err != nil {
				return nil
			}
			jsonByte, err := yaml.YAMLToJSON(yamlFileContent)
			ll("压缩包中获取到上传文件中的yaml内容,内容为:" + string(jsonByte))
			if err != nil {
				return nil
			}
			x := map[string]any{}

			json.Unmarshal(jsonByte, &x)

			return x
		}
	}

}

func CheckExistVersion(name string, version string) bool {

	fullPath := filepath.Join(config.Path, name, version, "package.tar.gz")

	if _, err := os.Stat(fullPath); err == nil {
		return true
	} else if errors.Is(err, os.ErrNotExist) {
		return false

	} else {

		return true

	}

}

func WriteFile(content map[string]any, path string) error {

	bytes, err := json.Marshal(content)
	if err != nil {
		return err
	}

	err = os.WriteFile(path, bytes, 0666)
	if err != nil {
		return err
	}
	return nil
}

func ll(content any) {
	log.Println(content)
}

func GetFileModTime(path string) time.Time {

	fi, err := os.Stat(path)
	if err != nil {
		return time.Now()
	}
	return fi.ModTime()

}
