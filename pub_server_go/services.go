package main

import (
	"context"
	"errors"
	"path/filepath"
	"sort"
	"sync"
	"time"
)

func GetAllPackagesService() ([]packageBean, error) {
	var wg sync.WaitGroup

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	list := ListDir(config.Path)

	packages := []packageBean{}
	for _, packagePath := range list {
		wg.Add(1)
		go func(path FileName) {
			defer wg.Done()
			lastedVersion, lastedVersionName := getLastedPackageVersion(path.Path)
			if lastedVersion != "" && lastedVersionName != "" {
				packageInfo := readPackageVersion(lastedVersion)
				packages = append(packages, packageBean{
					Title:         path.Name,
					LastedVersion: lastedVersionName,
					Yaml:          packageInfo,
				})
			}
		}(packagePath)

	}
	wg.Wait()
	sort.Slice(packages, func(i, j int) bool {

		first := GetFileModTime(filepath.Join(config.Path, packages[i].Title))
		second := GetFileModTime(filepath.Join(config.Path, packages[j].Title))

		return first.Before(second)
	})
	return packages, ctx.Err()

}

func GetSpeaiclPackageService(packageName string) (packageInfoParentBean, error) {

	var wg sync.WaitGroup

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	ll("开始请求GetSpeaiclPackageController")
	name := packageName
	ll("参数:" + name)
	//获取所有的版本
	dir := filepath.Join(config.Path, name)

	list := ListDir(dir)

	if list == nil {
		return packageInfoParentBean{
			Name:     "",
			Versions: nil,
			Time:     time.Now().UnixNano() / int64(time.Millisecond),
			Latest:   packageInfoBean{},
		}, errors.New("Not Found the Package: " + name)
	}

	infos := []packageInfoBean{}

	for _, path := range list {
		wg.Add(1)
		go func(p FileName) {
			defer wg.Done()
			tempPackageInfo := readPackageVersion(p.Path)
			if tempPackageInfo != nil {
				infos = append(infos, packageInfoBean{
					Version:     p.Name,
					Pubspec:     tempPackageInfo,
					Time:        GetFileModTime(p.Path).UnixMilli(),
					Readme:      readFile(filepath.Join(p.Path, "README.md")),
					Archive_url: "http://" + string(GetOutboundIP().String()) + ":" + config.Port + "/packages/" + name + "/versions/" + p.Name + ".tar.gz",
				})
			}
		}(path)
	}
	wg.Wait()
	sort.Slice(infos, func(i, j int) bool {

		first := GetFileModTime(filepath.Join(dir, infos[i].Version))
		second := GetFileModTime(filepath.Join(dir, infos[j].Version))

		return first.Before(second)
	})
	result := packageInfoParentBean{
		Name:     name,
		Versions: infos,
		Time:     time.Now().UnixNano() / int64(time.Millisecond),
		Latest:   infos[len(infos)-1],
	}

	return result, ctx.Err()
}
