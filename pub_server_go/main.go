package main

import (
	"encoding/json"
	"github.com/gin-contrib/timeout"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

var config Config

func init() {

	now := time.Now()
	logFilePath := ""
	if dir, err := os.Getwd(); err == nil {
		logFilePath = dir + "/logs/"
	}
	if err := os.MkdirAll(logFilePath, 0777); err != nil {
		return
	}
	logFileName := now.Format("2006-01-02") + "-operate.log"
	//日志文件
	fileName := filepath.Join(logFilePath, logFileName)
	if _, err := os.Stat(fileName); err != nil {
		if _, err := os.Create(fileName); err != nil {
			return
		}
	}
	logFile, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		return
	}
	log.SetOutput(logFile)
	log.SetFlags(log.Llongfile | log.Lmicroseconds | log.Ldate)
	log.Println("开始记录服务器日志")

}

func timeoutMiddleware() gin.HandlerFunc {

	ll("开始设置超时时间，接口默认1min")
	return timeout.New(
		timeout.WithTimeout(1*time.Minute),
		timeout.WithHandler(func(c *gin.Context) {
			c.Next()
		}),
		timeout.WithResponse(timeoutResponse),
	)
}
func timeoutResponse(c *gin.Context) {
	ll("该接口超时，自动关闭")
	c.String(http.StatusRequestTimeout, "timeout")
}

func main() {

	bytes, err := os.ReadFile("./config.json")

	if err != nil {
		log.Printf("获取配置文件失败,无法启动")
		return
	}

	json.Unmarshal(bytes, &config)

	r := gin.Default()
	r.Use(LoggerToFile())
	r.Use(Cors())
	r.Use(timeoutMiddleware())

	RegisterRoutes(r)
	s := &http.Server{
		Addr:         ":" + config.Port,
		Handler:      r,
		ReadTimeout:  1000 * time.Second,
		WriteTimeout: 1000 * time.Second,
	}
	s.ListenAndServe()
}
