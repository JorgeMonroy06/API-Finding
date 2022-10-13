package main

import (
	"github.com/gin-gonic/gin"
)

const (
	GetAllPackages      = "/api/getAllPackages"
	GetPackage          = "/api/packages/:name"
	GetPackageVersion   = "/api/packages/:name/versions/:version"
	DownloadPackage     = "/packages/:name/versions/:version"
	GetUploadUrl        = "/api/packages/versions/new"
	UploadPackage       = "/api/packages/versions/newUpload"
	FinishUploadPackage = "/api/packages/versions/newUploadFinish"
)

func RegisterRoutes(r *gin.Engine) {

	r.GET("/ping", func(c *gin.Context) {
		SuccessString(c, "It's OK!")
	})

	r.GET(GetAllPackages, GetAllPackagesController)
	r.GET(GetPackage, GetSpeaiclPackageController)
	r.GET(GetPackageVersion, GetSpeaiclPackageVersionController)
	r.GET(GetUploadUrl, GetUploadUrlController)
	r.GET(FinishUploadPackage, FinishUploadPackageController)
	r.GET(DownloadPackage, DownloadSpeaiclPackageVersionController)

	r.MaxMultipartMemory = 80 << 20 // 8 MiB
	r.POST(UploadPackage, UploadPackageController)

}
