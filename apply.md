# Codex + MCP 触发网关：用户场景到硬件链路（完整链条）

## 使用场景（按你描述）
- 你躺在床上，突然想起世界模型服务器还在跑。
- 拿出 iPhone，用 Termius 连接你的 Ubuntu 电脑。
- 进入 ENFP 女友目录，打开已经装好 Skills / MCP 的 Codex CLI。
- 对 Codex 说：
  > “帮我监控世界模型服务器，如果运行结束且正常帮我把那台机器关了节省费用。”

下面给出**完整链条**，从**用户操作视角**到**实际硬件调用视角**。

---

## 设计假设（可落地、最少组件）
- **VPS 上运行 Trigger/Heartbeat 网关（MCP Server）**：常驻、低成本、负责心跳/路由/状态。
- **世界模型服务器上运行轻量监控 Agent**（或 SSH/脚本探针）：用于检测任务状态和健康度。
- **IM 通知**通过一个 MCP 工具或网关自带通知模块（Telegram/Slack/Email）。
- **Codex CLI 本地只做“发令与配置”**，不承担常驻逻辑。

---

## Mermaid：完整链条（用户 → 设备 → 服务 → 机器）
```mermaid
sequenceDiagram
    autonumber
    participant U as User (iPhone)
    participant T as Termius
    participant L as Ubuntu Laptop
    participant C as Codex CLI
    participant S as Skill (local wrapper)
    participant G as Trigger Gateway (MCP on VPS)
    participant M as Monitor Agent (World Model Server)
    participant W as World Model Server
    participant P as Power API/SSH
    participant I as IM Service (Telegram/Slack)

    U->>T: Open Termius
    T->>L: SSH login
    L->>C: Start Codex CLI
    U->>C: "Monitor model server; if finished OK, shut it down"

    C->>S: Invoke local Skill (optional)
    S->>G: MCP call: create_watch(job_id, health_criteria, notify_to)

    %% Heartbeat loop
    loop Heartbeat (VPS)
        G->>M: check_status(job_id)
        M->>W: read process/log/metrics
        W-->>M: status + health
        M-->>G: status + health
    end

    alt job finished AND healthy
        G->>P: shutdown_instance(server_id)
        P->>W: poweroff / stop instance
        G->>I: send_message("Job finished, server shut down")
        I-->>U: IM notification
    else still running or unhealthy
        G-->>G: keep watching / retry / alert on failure
    end

    C-->>U: (Optional) status summary on demand
```

---

## 组件职责（最清晰版本）
**1) Codex CLI（本地）**
- 作用：你下指令、一次性设置规则。
- 不常驻，避免成本。

**2) Skill（本地可选）**
- 作用：把你的一句话翻译成 MCP 调用（例如 `create_watch`）。
- 好处：减少你每次手动拼参数。

**3) Trigger Gateway（VPS, MCP Server）**
- 作用：常驻心跳 + 路由 + 事件管理。
- 提供 MCP tools：`create_watch` / `check_status` / `shutdown` / `notify`。

**4) Monitor Agent（世界模型服务器）**
- 作用：检查进程是否结束、是否正常（exit code / logs / metrics）。

**5) Power Control**
- 作用：关机/停实例（SSH 或云厂商 API）。

**6) IM 通知**
- 作用：把结果送到你的手机。

---

## 实际使用链条（你要的“怎么用”）
1) **你：** iPhone → Termius → SSH 到 Ubuntu。
2) **你：** 进入 ENFP 女友目录，打开 Codex CLI。
3) **你：** 输入命令：
   > “Monitor world‑model server. When job finishes OK, shut it down and notify me.”
4) **Codex CLI：** 调用 Skill → MCP → VPS Gateway 建立 `watch`。
5) **VPS：** 持续 heartbeat 检查任务状态。
6) **完成：** VPS 关机 + 发 IM → 你收到通知。

---

## “是不是要 MCP 还是 Skill？”的回答
- **常驻 + 触发 + 心跳 = MCP（推荐）**
- **一次性/封装操作 = Skill**

简化公式：
- Skill = 本地“快捷按钮”
- MCP = 远端“长期能力”

---

## 你可以给可行性分析 Codex 的一句话
**“核心 API 服务常驻；MCP 只是薄适配；Skill 只是本地快捷入口。”**

如果你要，我可以补：
- MCP tools 的 schema 示例
- Rust 目录结构与最小可运行样例
