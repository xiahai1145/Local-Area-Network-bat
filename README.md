# <span style="color:blue"> Local-Area-Network-bat</span>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![Batch](https://img.shields.io/badge/Language-Batch-4D4D4D?logo=windows-terminal)](https://en.wikipedia.org/wiki/Batch_file)


## <span style="color:blue">信息</span>

| 项目 | 详情 |
|:---|:---|
| 工具名称 | Local-Area-Network-bat |
| 版本 | v2.9 |
| 适用系统 | Windows7至11
| 文件大小 | 约 13 KB |
| 依赖组件 | PowerShell（系统自带）、curl（Windows 10/11 1903+ 内置） |

---

## <span style="color:blue"> 功能列表</span>

| 编号 | <span style="color:blue">**功能名称**</span> | 用途 |
|:---:|:---|:---|
| 1 | <span style="color:blue">**扫描局域网主机**</span> | 通过 Ping 和 ARP 缓存找出在线设备，依据 TTL 值识别操作系统类型（Windows、Linux/macOS/Android/iOS、网络设备等）。附带进度条。 |
| 2 | <span style="color:blue">**路由追踪 (tracert)**</span> | 追踪数据包到达目标 IP/域名所经过的路由节点，用于诊断网络延迟和路径问题。 |
| 3 | <span style="color:blue">**查询本机公网 IP**</span> | 通过外部服务 (cip.cc) 获取您的出口公网 IPv4 地址。 |
| 4 | <span style="color:blue">**Minecraft扫描**</span> | 针对 Java 版（TCP 25565）和基岩版（UDP 19132）的专用端口探测。按照官方 Unconnected Ping 协议构造探测包，准确识别基岩版服务器。支持自动扫描子网、自定义范围或单 IP 检测。 |
| 5 | <span style="color:blue">**局域网端口扫描 (通用 TCP)**</span> | 自定义 IP 范围和端口列表，检测哪些 TCP 端口处于开放状态，并自动显示常见端口对应的服务名。 |
| 6 | <span style="color:blue">**公网 IP 端口自检**</span> | 自动获取您的公网 IP，并扫描预设的常用端口（80/443/3389/8080/25565/19132），快速验证端口映射是否生效。 |
| 7 | <span style="color:blue">**退出**</span> | 关闭工具。 |

---

## <span style="color:blue">核心特性详解</span>

### <span style="color:blue">局域网扫描（设备识别）</span>

无需第三方工具，基于 `ping` + `ARP` 缓存快速发现在线设备。通过分析 **TTL（生存时间）** 值智能识别设备类型：

| TTL 值 | 系统猜测 |
|:---:|:---|
| 128 | Windows |
| 64 | Linux / macOS / Android / iOS |
| 255 | 网络设备（路由器/交换机） |
| 32 | 旧版 Windows 或嵌入式系统 |
| 无响应 | 未知（设备离线或禁 Ping） |

扫描过程附带**动态进度条**，实时显示扫描进度。

---

### <span style="color:blue">🎮 Minecraft 探测</span>

同时支持两种主流 Minecraft 服务端端口扫描：
- **Java 版**：TCP 25565（标准 TCP 连接检测）
- **基岩版**：UDP 19132（**完整 Unconnected Ping 协议**，准确识别）

支持三种扫描模式：
- 自动扫描当前子网（/24）
- 自定义 IP 范围
- 单个 IP 检测

---

### <span style="color:blue">🔍 通用 TCP 端口扫描</span>

自定义 IP 范围和端口列表（如 `80,443,3389`），快速检测开放端口。内置常用端口服务名称映射（如 `80→HTTP`、`3306→MySQL`）

**预设常用端口列表（输入 `common` 即可调用）**：
`21,22,23,25,80,443,3389,8080,25565`

---

### <span style="color:blue">公网 IP 自检</span>

自动获取你的公网出口 IP，并扫描预设关键端口，**快速验证端口映射是否生效**，排查路由器 NAT 环回问题。

- 扫描端口：`80, 443, 3389, 8080, 25565, 19132`
- 输出结果：`[开放]` 或 `[关闭/超时]`
- 若全部关闭，会提示检查路由器映射和防火墙设置。

---

### <span style="color:blue">网络诊断辅助</span>

- **路由追踪**（`tracert -d`）：排查网络延迟和路径节点，不解析主机名，速度更快。
- **一键查询公网 IP**：通过 `cip.cc` 快速获取出口地址。

---

## <span style="color:blue">📖 快速开始</span>

### 下载与运行
1. 下载本仓库中的 `Local-Area-Network-bat.bat` 文件。
2. 双击运行（普通用户权限即可，但建议右键“以管理员身份运行”以获得更完整的信息）。
3. 在菜单中输入数字选择功能，按 `Enter` 执行。

### 使用示例

| 场景 | 操作 |
|:---|:---|
| **查看家里有哪些设备在线** | 主菜单输入 `1`，自动扫描当前网段，显示所有在线设备的 IP、MAC 和系统类型。 |
| **找局域网内的 Minecraft 服务器** | 主菜单输入 `4` → 选择 `1`（自动扫描），工具会列出所有开放 25565 或 19132 端口的主机。 |
| **检查我的端口映射是否生效** | 主菜单输入 `6`，工具自动获取公网 IP 并扫描关键端口，判断映射是否成功。 |
| **检查某台设备是否开了特定服务** | 主菜单输入 `5`，输入目标 IP 范围和端口列表（如 `80,443`），查看开放端口。 |

---

## <span style="color:blue">自定义与扩展</span>

你可以轻松修改脚本以适应自己的需求：

### 添加端口备注
编辑脚本末尾的 `:get_service_name` 部分，按格式添加：
```batch
if "%1"=="27015" set "svc_name=Steam Game"

