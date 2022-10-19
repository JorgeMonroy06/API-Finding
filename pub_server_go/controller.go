package main

import (
	"fmt"
	"math/rand"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)

func GetAllPackagesController(c *gin.Context) {

	packages, err := GetAllPackagesService()
	if err != nil {
		FailBadRequest(c, map[string]any{"msg": err.Error()})
		return
	}
	Success(c, map[string]any{
		"packages": packages,
	})

}

func GetSpeaiclPackageController(ctx *gin.Context) {

	result, err := GetSpeaiclPackageService(ctx.Param("name"))
	if err != nil {
		FailBadRequest(ctx, map[string]any{"msg": err.Error()})
		return
	}

	Success(ctx, result)

}

func GetSpeaiclPackageVersionController(ctx *gin.Context) {
	ll("开始执行GetSpeaiclPackageVersionController")
	name := ctx.Param("name")
	version := ctx.Param("version")

	ll("请求参数:" + name + ":" + version)

	//获取所有的版本
	filePath := filepath.Join(config.Path, name, version)
	ll("获取请求需要的文件路径:" + filePath)
	tempPackageInfo := readPackageVersion(filePath)

	if tempPackageInfo == nil {
		FailBadRequest(ctx, map[string]any{
			"msg": "Not Found",
		})
		return
	}

	ll("获取文件内容成功")
	Success(ctx, packageInfoBean{
		Version:     version,
		Pubspec:     tempPackageInfo,
		Archive_url: "http://" + string(GetOutboundIP().String()) + ":" + config.Port + "/packages/" + name + "/versions/" + version + ".tar.gz",
	})

}

func DownloadSpeaiclPackageVersionController(ctx *gin.Context) {
	ll("开始执行DownloadSpeaiclPackageVersionController")
	name := ctx.Param("name")
	version := ctx.Param("version")
	versionRealName := version

	ll("请求参数:" + name + ":" + version)

	if strings.HasSuffix(version, ".tar.gz") {
		ll("当前请求想要下载文件")
		//代表要下载这个文件
		versionRealName = strings.ReplaceAll(version, ".tar.gz", "")
	}

	ll("要求版本 :" + name + ":" + versionRealName)
	//获取所有的版本
	filePath := filepath.Join(config.Path, name, versionRealName)
	ll("版本路径 :" + filePath)
	tempPackageInfo := readPackageVersion(filePath)
	if tempPackageInfo == nil {
		FailNotFound(ctx, map[string]any{
			"msg": "Not Found",
		})

		return
	}
	ll("版本内容获取成功,开始下载")
	ctx.File(filepath.Join(filePath, "package.tar.gz"))

}

func GetUploadUrlController(ctx *gin.Context) {
	ll("开始执行GetUploadUrlController")
	if config.CanUpload {
		ll("服务器运行上传文件")
		Success(ctx, map[string]any{
			"url":    "http://" + string(GetOutboundIP().String()) + ":" + config.Port + UploadPackage,
			"fields": nil,
		})

	} else {
		FailNotFound(ctx, map[string]any{
			"msg": "服务器已禁止上传",
		})
	}

}

func UploadPackageController(ctx *gin.Context) {

	ll("开始执行UploadPackageController")
	// 单文件
	file, _ := ctx.FormFile("file")

	fileName := "package.tar.gz"
	//先保存到本地临时文件,再处理
	tempDst := "./" + fmt.Sprint(rand.Intn(10000)) + fileName
	// 上传文件至指定的完整文件路径
	err := ctx.SaveUploadedFile(file, tempDst)
	ll("创建临时文件" + tempDst + "用来解压缩分析")
	if err != nil {
		FailInUploadFile(ctx, "can not save uploaded file in server")
		return
	}
	//开始处理文件

	yamlContent := ReadYamlFromZipFile(tempDst)
	readmeContent := ReadReadMeFromZipFile(tempDst)
	if readmeContent == "" {
		readmeContent = "请在项目根目录添加README.md文件"
	}

	os.Remove(tempDst)
	if yamlContent == nil {
		FailInUploadFile(ctx, "can not find pubspec.yaml")
		return
	}

	packageName := fmt.Sprintf("%v", yamlContent["name"])
	packageNameVersion := fmt.Sprintf("%v", yamlContent["version"])

	ll("拿到压缩包中的版本:" + packageName + ":" + packageNameVersion)
	if CheckExistVersion(packageName, packageNameVersion) {
		ll("发现版本已存在")
		FailInUploadFile(ctx, "version existed")
		return
	}
	ll("没有发现已经存在的版本")
	realDstPath := filepath.Join(config.Path, packageName, packageNameVersion)
	realDstFileName := filepath.Join(realDstPath, fileName)
	ll("开始准备创建文件:" + realDstPath + ":" + realDstFileName)
	if _, err := os.Stat(realDstPath); os.IsNotExist(err) {
		err = os.MkdirAll(realDstPath, os.ModePerm)
		if err != nil {
			FailInUploadFile(ctx, "can not create dir: "+realDstPath)
			return
		}
	}
	ll("开始准备写yaml文件:" + realDstFileName)
	err = WriteFile(yamlContent, filepath.Join(realDstPath, "pubspec.yaml"))
	if err != nil {
		os.RemoveAll(realDstPath)
		FailInUploadFile(ctx, "can not generate pubspec")
		return
	}

	err = WriteFileWithString(readmeContent, filepath.Join(realDstPath, "README.md"))
	if err != nil {
		os.RemoveAll(realDstPath)
		FailInUploadFile(ctx, "can not generate readme.md")
		return
	}
	ll("开始准备写压缩包文件:" + realDstFileName)
	err = ctx.SaveUploadedFile(file, realDstFileName)
	if err != nil {
		os.RemoveAll(realDstPath)
		FailInUploadFile(ctx, "can not save file to server,fileName:"+fileName)
		return
	}
	ll("完成.开始准备写压缩包文件:" + realDstFileName)

	author := ""
	if val, ok := yamlContent["author"]; ok {
		author = fmt.Sprintf("%v", val)
	}

	Push(packageName, packageNameVersion, author, fmt.Sprintf("%v", yamlContent["update_note"]))

	SuccessInUploadFile(ctx, fmt.Sprintf("'%s' uploaded!", fileName))
}

func FinishUploadPackageController(ctx *gin.Context) {
	ll("开始执行FinishUploadPackageController")
	errorMsg := ctx.Query("error")
	if errorMsg != "" {
		FailBadRequest(ctx, map[string]any{"error": map[string]any{"message": errorMsg}})
	} else {
		Success(ctx, map[string]any{
			"success": map[string]string{"message": "Successfully uploaded package."},
		})
	}

}
