package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type packageBean struct {
	Title         string         `json:"title"`
	LastedVersion string         `json:"lastedVersion"`
	Yaml          map[string]any `json:"yaml"`
}

type packageInfoBean struct {
	Archive_url string         `json:"archive_url"`
	Pubspec     map[string]any `json:"pubspec"`
	Readme      string         `json:"readme"`
	Time        int64          `json:"time"`
	Version     string         `json:"version"`
}

type packageInfoParentBean struct {
	Name     string            `json:"name"`
	Time     int64             `json:"time"`
	Versions []packageInfoBean `json:"versions"`
	Latest   packageInfoBean   `json:"latest"`
}

type Config struct {
	Port      string `json:"port"`
	Path      string `json:"path"`
	WeWorkKey string `json:"weWorkKey"`
	CanUpload bool   `json:"canUpload"`
}

func SuccessString(ctx *gin.Context, content string) {
	ctx.String(http.StatusOK, content)
}

func SuccessInUploadFile(ctx *gin.Context, content string) {
	ctx.Header("location", "http://"+string(GetOutboundIP().String())+":"+config.Port+FinishUploadPackage)
	ctx.String(http.StatusOK, content)
}

func Success(ctx *gin.Context, obj any) {
	ctx.JSON(http.StatusOK, obj)
}

func FailBadRequest(ctx *gin.Context, content map[string]any) {
	ctx.JSON(http.StatusBadRequest, gin.H(content))
}
func FailNotFound(ctx *gin.Context, content map[string]any) {
	ctx.JSON(http.StatusBadRequest, gin.H(content))
}

func FailInUploadFile(ctx *gin.Context, content string) {
	result := "http://" + string(GetOutboundIP().String()) + ":" + config.Port + FinishUploadPackage + "?error=" + content
	ctx.Header("location", result)

	ll("FailInUploadFile:" + result)
	ctx.String(http.StatusOK, content)
}
