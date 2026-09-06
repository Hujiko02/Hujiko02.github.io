# GitHub 加速故障排查与修复指南

> 本文档记录 2026-08-28 排查并修复"Watt Toolkit 加速 GitHub 打不开"问题的全过程。
> 供后续排查问题时参考。**环境：Debian 13 (trixie) + KDE Plasma + ungoogled-chromium 150**

---

## 一、问题背景

用户使用 Watt Toolkit（原 Steam++，安装于 `/opt/Watt-Toolkit/`）加速 GitHub，但 GitHub 依然打不开。
排查发现是**多层配置问题叠加**，并非 Watt Toolkit 本身故障。

**Watt Toolkit 加速原理**：本地反向代理（默认端口 `26561`）+ hosts 解析，把 GitHub 域名指向测试出的最快 IP。
它不是 VPN，**不提供科学上网能力**，只是"选最快 IP 直连"。

---

## 二、根因总结（按排查顺序）

| # | 问题 | 现象 |
|---|---|---|
| 1 | KDE 代理配置指向**已关闭的 Clash**（`127.0.0.1:7897`） | 浏览器连死端口，GitHub 打不开 |
| 2 | Watt Toolkit 把代理写入 **GNOME gsettings**，但桌面是 **KDE**，KDE 应用不读 gsettings | 加速通道从未被使用 |
| 3 | **ungoogled-chromium 不读取系统代理配置** | 改系统代理对它无效，必须用启动参数 |
| 4 | **现代 Chromium 只信任内置根证书 + NSS 用户库**，不认系统 CA 库 | Watt 的 MITM 证书验证失败 → "隐私设置错误" |
| 5 | Chromium 出于安全限制**无法加载 `file://` PAC** | 本地 PAC 文件不生效，需用 `data:` URL 或 `http://` |

---

## 三、当前配置状态（2026-08-28 修复后）

### 1. Chromium 启动配置（核心）
文件：`~/.local/share/applications/ungoogled-chromium.desktop`

Exec 行包含：
- `--proxy-pac-url="data:application/x-ns-proxy-autoconfig;base64,..."` —— **PAC 分流**（关键）
- 保留了用户原有的反指纹参数（`--user-agent`、`--disable-features=CanvasFingerprintProtection,...`）

**注意**：`data:` URL 里的 base64 是 PAC 文件（见下）的编码，若 PAC 内容变更需重新生成。

### 2. PAC 分流文件
路径：`~/.config/steamtools-proxy.pac`

规则：**仅 GitHub 系域名走 Watt 代理（`127.0.0.1:26561`），其余全部直连**。
覆盖域名：`github.com`、`*.github.com`、`*.githubusercontent.com`、`*.githubassets.com`、`*.github.io`、`*.githubapp.com`、`*.githubcopilot.com`、`githubstatus.com`。

**效果**：
| 场景 | GitHub | 国内网站 |
|---|---|---|
| 开 Watt | ✅ 走加速代理 | ✅ 直连 |
| 关 Watt | ❌ 不可用 | ✅ 正常上网 |

### 3. 证书信任（关键）
Watt Toolkit 用自签 CA（`CN=SteamTools Certificate, O=BeyondDimension`）对 HTTPS 做 MITM。
现代 Chromium 只信任 **NSS 用户库**，已通过以下命令添加：

```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "SteamTools" -i ~/.local/share/Steam++/Plugins/Accelerator/SteamTools.Certificate.cer
```

验证：`certutil -d sql:$HOME/.pki/nssdb -L | grep -i steamtools`

另外证书也已复制到系统 CA 库（`/usr/local/share/ca-certificates/SteamTools.Certificate.crt` + `update-ca-certificates`），
这对 curl 等读系统库的工具有效，但对 Chromium 无效（Chromium 认 NSS 用户库）。

**证书有效期：2026-08-26 至 2027-06-23**。Watt Toolkit 更新证书后需重新执行上述 certutil 命令。

### 4. 系统代理（已恢复为无代理）
- KDE：`~/.config/kioslaverc` —— 仅保留 `NoProxyFor`，**无** httpProxy/httpsProxy
- GNOME：`gsettings set org.gnome.system.proxy mode 'none'`

> 历史遗留：修复前 Watt Toolkit 曾把 `0.0.0.0:26561` 写入 gsettings（`0.0.0.0` 不是合法代理地址，Chromium 不认）。

### 5. hosts 文件
`/etc/hosts` 中有一条手动条目：`185.199.108.133 raw.githubusercontent.com`
（注释 `#comments. put the address here`，可能是之前 GitHub520 留下的，走代理时不影响，暂未清理）

### 6. Watt Toolkit 加速器
- 进程：`/opt/Watt-Toolkit/Steam++` + `Steam++.Accelerator`
- 代理端口：`26561`（HTTP 代理，**不支持 SOCKS**）
- 配置目录：`~/.local/share/Steam++/`
- 证书文件：`~/.local/share/Steam++/Plugins/Accelerator/SteamTools.Certificate.cer`

---

## 四、故障排查清单（GitHub 又打不开时按此顺序）

### 1. 确认 Watt Toolkit 代理是否在运行
```bash
ss -tlnp | grep 26561
ps aux | grep Steam++.Accelerator
```
不在 → 打开 Watt Toolkit → 网络加速 → 一键加速。

### 2. 确认代理通道可用（curl 严格验证，不带 -k）
```bash
curl -sI -x http://127.0.0.1:26561 https://github.com
```
- 返回 `HTTP/2 200` → 代理正常，问题在浏览器端
- 报 SSL 错误 → 证书问题，见第 5 步
- 超时 → Watt Toolkit 的 DoH/DNS 可能失效，进 Watt Toolkit 加速设置切换 DoH/DNS 并重启加速

### 3. 确认 Chromium 启动参数包含 PAC
```bash
ps aux | grep ungoogled-chromium | grep proxy-pac-url
```
- 无 `--proxy-pac-url` → 浏览器是从旧方式启动的，**完全退出后重新从应用菜单启动**
  ```bash
  pkill -f ungoogled-chromium
  ```
- desktop 文件可能被系统更新覆盖 → 检查 `~/.local/share/applications/ungoogled-chromium.desktop` 的 Exec 行

### 4. 确认 PAC 文件逻辑正确
```bash
cat ~/.config/steamtools-proxy.pac
```
修改 PAC 后需重新生成 base64 并更新 desktop 文件的 `data:` URL：
```bash
base64 -w0 ~/.config/steamtools-proxy.pac
```

### 5. 确认证书信任（"隐私设置错误"时）
```bash
certutil -d sql:$HOME/.pki/nssdb -L | grep -i steamtools
```
无输出 → 重新添加：
```bash
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "SteamTools" -i ~/.local/share/Steam++/Plugins/Accelerator/SteamTools.Certificate.cer
```
添加后**完全重启 Chromium**。

### 6. 其他常见问题
- **浏览器报代理连接失败**：Watt Toolkit 停止加速时 `26561` 关闭，GitHub 会打不开（正常现象，其他网站不受影响）
- **curl 通但浏览器不通**：确认浏览器是否走了 PAC（见第 3 步），浏览器要完全退出重启才读新配置
- **Firefox 等 KDE 应用**：系统代理已设为无代理，它们走直连，GitHub 可能慢/不通（用户主要用 Chromium，可接受）

---

## 五、关键命令速查

```bash
# 测试代理通道（严格证书验证）
curl -sI -x http://127.0.0.1:26561 https://github.com

# 忽略证书验证测试（区分"代理不通"还是"证书不信任"）
curl -skI -x http://127.0.0.1:26561 https://github.com

# 查看 Chromium 进程参数
ps aux | grep ungoogled-chromium | grep -oE "\-\-proxy[^ ]*"

# 完全重启 Chromium
pkill -f ungoogled-chromium

# 查看/添加 NSS 证书
certutil -d sql:$HOME/.pki/nssdb -L | grep -i steamtools
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "SteamTools" -i ~/.local/share/Steam++/Plugins/Accelerator/SteamTools.Certificate.cer

# 重新生成 PAC 的 base64（改 PAC 后用）
base64 -w0 ~/.config/steamtools-proxy.pac
```

---

## 六、注意事项

1. **关 Watt Toolkit 前先保存工作**——关闭后 GitHub 暂时不可用（加速原理决定），国内网站不受影响
2. **证书 2027-06-23 过期**，Watt Toolkit 换证书后需重装 NSS 信任
3. **系统更新可能覆盖 desktop 文件**，导致 PAC 参数丢失，需重新添加
4. **不要安装/启动 Clash 等其他代理软件**，它们会改写系统代理配置，与 Watt 冲突（历史教训）
5. Watt Toolkit 代理只支持 HTTP，不支持 SOCKS
6. 本机直连 GitHub 的 IP（如 `20.205.243.166`）网络波动大，时通时断，不建议依赖直连
