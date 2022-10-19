package main

import (
	"bytes"
	"encoding/json"
	"net/http"
)

func Push(packageName string,
	version string,
	author string,
	updateContent string) {
	url := "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=" + config.WeWorkKey

	ll("开始推送:" + url)
	content := "Flutter私有库上新\n\n"

	content += " 名称: " + packageName + "\n"
	content += " 版本: " + version + "\n"
	content += " 更新内容: " + updateContent + "\n"
	if author != "" {
		content += " 作者: " + author + "\n"
	}
	content += " 地址: http://" + GetOutboundIP().String() + ":" + config.WebPort + "/#/package/" + packageName
	jsonMap := make(map[string]any, 2)

	jsonMap["msgtype"] = "text"

	jsonMap["text"] = map[string]string{"content": content}

	var jsonStr, _ = json.Marshal(jsonMap)

	req, _ := http.NewRequest("POST", url, bytes.NewBuffer(jsonStr))

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		ll("推送失败,请检查key")
	}
	defer resp.Body.Close()

}
