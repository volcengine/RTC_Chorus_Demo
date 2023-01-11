双人合唱是火山引擎实时音视频提供的一个开源示例项目。本文介绍如何快速跑通该示例项目，体验 RTC 双人合唱效果。

## 应用使用说明

使用该工程文件构建应用后，即可使用构建的应用进行双人合唱。
你和你的同事必须加入同一个房间，才能进行双人合唱。

## 前置条件

- [Xcode](https://developer.apple.com/download/all/?q=Xcode) 14.0+
	

- iOS 12.0+ 真机
	

- 有效的 [AppleID](http://appleid.apple.com/)
	

- 有效的 [火山引擎开发者账号](https://console.volcengine.com/auth/login)
	

- [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started) 1.10.0+
	

## 操作步骤

### **步骤 1：获取 AppID 和 AppKey**

在火山引擎控制台->[应用管理](https://console.volcengine.com/rtc/listRTC)页面创建应用或使用已创建应用获取 AppID 和 AppAppKey

### **步骤 2：获取 AccessKeyID 和 SecretAccessKey**

在火山引擎控制台-> [密钥管理](https://console.volcengine.com/iam/keymanage/)页面获取 **AccessKeyID 和 SecretAccessKey**

### **步骤 3：申请 HIFIVE 权限**

1. 获取 APPID 和 ServerCode
	

在 HIFIVE 控制台-> 授权中心 -> [产品授权管理](https://account.hifiveai.com/admin/auth/productList/edit/baseForm/2795/0/5)页面获取 APPID 和ServerCode

2. 获取音乐电台 KEY
	

在 HIFIVE 控制台 -> 歌单管理 -> [音乐电台](https://account.hifiveai.com/admin/song/operateList)页面获取。如没有音乐电台请新增。

### **步骤 4：构建工程**

1. 打开终端窗口，进入 `ChorusDemo/iOS/veRTC_Demo_iOS` 根目录<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_ba3267200605a6f587d67b42d67edb4e.png" width="500px" >	

2. 执行 `pod install` 命令构建工程<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_51fc3fdb260f27f14c1aa6765352bf79.png" width="500px" >	

3. 进入 `ChorusDemo/iOS/veRTC_Demo_iOS` 根目录，使用 Xcode 打开 `veRTC_Demo.xcworkspace`<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_111f9afcd030018f2666aba0778ea9d4.png" width="500px" >	

4. 在 Xcode 中打开 `Pods/Development Pods/Core/BuildConfig.h` 文件<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_0548899b170c606d3fe53adb7c670d4a.jpeg" width="500px" >	

5. 填写 **HeadUrl**<br>
    当前你可以使用 **https://common.rtc.volcvideo.com/rtc_demo_special** 作为测试服务器域名，仅提供跑通测试服务，无法保障正式需求。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_bfd188ba8820fd30621ba0b3d4ae57b2.jpeg" width="500px" >


6. **填写 APPID、APPKey、AccessKeyID 和 SecretAccessKey**<br>
	使用在控制台获取的 **APPID、APPKey、AccessKeyID 和 SecretAccessKey** 填写到 `BuildConfig.h`文件的对应位置。 <br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_560b76c0194a7c3b056964a3fefb69d4.png" width="500px" >


7. 填写 **HiFiveAppID**、**HiFiveServerCode** 和 **KEY** <br>
	使用在 HIFIVE 控制台获取的**HiFiveAppID**、**HiFiveServerCode** 和 **KEY** 填写到 `ChorusDemoConstants.h` 文件的对应位置。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_d5d704fc28ce159b02a12c05a17ad2a5.png" width="500px" >

### **步骤 5：配置开发者证书**

1. 将手机连接到电脑，在 `iOS Device` 选项中勾选您的 iOS 设备。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_9880f9167dd9cbf1d2acff56f9aa2e55.png" width="500px" >	
2. 登录 Apple ID。
    2.1 选择 Xcode 页面左上角 **Xcode** > **Preferences**，或通过快捷键 **Command** + **,**  打开 Preferences。
    2.2 选择 **Accounts**，点击左下部 **+**，选择 Apple ID 进行账号登录。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_9c95dc2adabc63e8075213e3d5a6b7dc.png" width="500px" >

3. 配置开发者证书。<br>
    3.1 单击 Xcode 左侧导航栏中的 `VeRTC_Demo` 项目，单击 `TARGETS` 下的 `VeRTC_Demo` 项目，选择 **Signing & Capabilities** > **Automatically manage signing** 自动生成证书<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_c9749d6d252a6b139f6323d555f78dee.png" width="500px" >

    3.2 在 **Team** 中选择 Personal Team。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_d951fe864f32b1d464c7bf15db827577.png" width="500px" >

    3.3 **修改 Bundle Identifier。** <br>
    默认的 `vertc.veRTCDemo.ios` 已被注册， 将其修改为其他 Bundle ID，格式为 `vertc.xxx`。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_7e46256bf1f7a3dfb4cc7e5c20606c66.png" width="500px" >


### **步骤 6 ：编译运行**

选择 **Product** > **Run**， 开始编译。编译成功后你的 iOS 设备上会出现新应用。若为免费苹果账号，需先在`设置->通用-> VPN与设备管理 -> 描述文件与设备管理`中信任开发者 APP。<br>
    <img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_e1ad6e8d6c264be08ad3a5b749bc6c93.png" width="500px" >

## 运行开始界面
<img src="https://portal.volccdn.com/obj/volcfe/cloud-universal-doc/upload_d113411372ba2333cc0622501d59a752.jpg" width="200px" >
