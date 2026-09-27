---
title: 首页
# 隐藏左侧导航、右侧目录、页脚和反馈组件，让首页变成一张「着陆页」
hide:
  - navigation
  - toc
  - footer
  - feedback
---

<style>
/* ==========================================================================
   首页样式
   --------------------------------------------------------------------------
   写在 Markdown 里由 Zensical 原样输出 → 只在这一页生效，不动其他页面。
   颜色全部走主题变量，明暗模式自动跟随（当前 indigo + amber）。
   ========================================================================== */

/* 隐藏「编辑此页 / 查看源码」按钮和标题锚点 */
.md-content__button { display: none !important; }
.md-typeset .headerlink { display: none !important; pointer-events: none; }

.home-container {
    max-width: 920px;
    margin: 0 auto;
    padding: 0 1rem;
}
@media screen and (min-width: 2000px) {
    .home-container { max-width: 950px; }
}

/* --------------------------------------------------------------------------
   英雄区：左文右头像，背景是方格线（1px，比点阵安静）
   -------------------------------------------------------------------------- */
.hero-wrapper {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 2rem;
    padding: 2.4rem 2.6rem;
    margin: 0.5rem 0;
    background-image:
        linear-gradient(to right, var(--md-default-fg-color--lightest) 1px, transparent 1px),
        linear-gradient(to bottom, var(--md-default-fg-color--lightest) 1px, transparent 1px);
    background-size: 22px 22px;
    border-radius: 4px;
}
.hero-content { flex: 1; min-width: 0; }

.hero-name {
    font-size: 2.5rem;
    font-weight: 800;
    line-height: 1.15;
    letter-spacing: -0.01em;
    margin: 0;
    color: var(--md-default-fg-color);
}

/* 身份行：等宽字体，小字距 */
.hero-role {
    font-family: var(--md-code-font-family);
    font-size: 0.74rem;
    letter-spacing: 0.06em;
    color: var(--md-default-fg-color--light);
    margin-top: 0.75rem;
}

/* 加 .md-typeset 提权，压过主题的正文样式 */
.md-typeset .hero-intro {
    font-size: 1.02rem !important;
    line-height: 1.85;
    margin: 1.3rem 0 0 0 !important;
    color: var(--md-default-fg-color);
    max-width: 27rem;
    text-wrap: balance;      /* 换行更均匀，避免最后一行只剩两三个字 */
}
.md-typeset .hero-intro em {
    font-style: normal;
    color: var(--md-default-fg-color--light);
}

/* 技术栈行：这就是本站的目录 */
.stack {
    font-family: var(--md-code-font-family);
    font-size: 0.78rem;
    color: var(--md-default-fg-color--light);
    margin-top: 1.1rem;
    letter-spacing: 0.02em;
}
.stack b { font-weight: 400; color: var(--md-primary-fg-color); }

/* --------------------------------------------------------------------------
   头像：单色细描边，不用渐变光环
   -------------------------------------------------------------------------- */
.avatar-ring {
    width: 11rem;
    height: 11rem;
    border-radius: 50%;
    padding: 5px;
    border: 1px solid color-mix(in srgb, var(--md-primary-fg-color) 45%, transparent);
    flex-shrink: 0;
}
.avatar-ring img {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
    display: block;
}

/* --------------------------------------------------------------------------
   按钮：主按钮实心，次按钮描边（不再用灰底块）
   -------------------------------------------------------------------------- */
.hero-btns { display: flex; gap: 12px; margin-top: 1.7rem; }
.custom-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 0.34rem 0.9rem;
    border-radius: 4px;
    font-size: 0.86rem;
    font-weight: 500;
    line-height: 1.3;
    text-decoration: none !important;
    transition: border-color 0.2s, background-color 0.2s;
}
.btn-primary {
    background-color: var(--md-primary-fg-color);
    color: var(--md-primary-bg-color) !important;
}
.btn-primary:hover { background-color: var(--md-primary-fg-color--dark); }
.btn-secondary {
    border: 1px solid var(--md-default-fg-color--lightest);
    color: var(--md-default-fg-color) !important;
}
.btn-secondary:hover { border-color: var(--md-primary-fg-color); }
.custom-btn .twemoji { width: 1.05rem; height: 1.05rem; }

/* --------------------------------------------------------------------------
   四格：左侧竖线的说明块，无圆角无阴影
   -------------------------------------------------------------------------- */
.grid-container {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1.6rem 2.4rem;
    margin: 2.2rem 0 0.5rem;
}
.grid-card {
    border-left: 2px solid var(--md-default-fg-color--lightest);
    padding: 0.15rem 0 0.15rem 1rem;
    transition: border-color 0.25s ease;
}
.grid-card:hover { border-color: var(--md-primary-fg-color); }
.md-typeset .grid-card > h3 {
    margin: 0 !important;
    font-size: 1rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 7px;
    color: var(--md-default-fg-color);
}
.grid-card > p {
    margin: 0.5rem 0 0 0 !important;
    font-size: 0.84rem;
    line-height: 1.65;
    color: var(--md-default-fg-color--light);
}

/* --------------------------------------------------------------------------
   标签行 / 次级链接
   -------------------------------------------------------------------------- */
.tag-box {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    margin-top: 0.6rem;
}
.tag-box span {
    font-size: 0.72rem;
    color: var(--md-default-fg-color--light);
    opacity: 0.85;
    display: inline-flex;
    align-items: center;
}
.md-typeset .tag-link {
    display: inline-flex;
    align-items: center;
    gap: 2px;
    font-size: 0.76rem;
    font-weight: 700;
    color: var(--md-primary-fg-color) !important;
    text-decoration: none !important;
    transition: opacity 0.2s;
}
.md-typeset .tag-link:hover { opacity: 0.75; }
.jump-icon {
    width: 13px;
    height: 13px;
    fill: currentColor;
    transition: transform 0.25s ease;
}
.tag-link:hover .jump-icon { transform: translate(3px, -3px); }

/* --------------------------------------------------------------------------
   小节标题：左对齐 + 右侧真实计数，不用渐隐装饰线
   -------------------------------------------------------------------------- */
.sec-head {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 1rem;
    margin: 2.6rem 0 1.1rem;
    padding-bottom: 0.45rem;
    border-bottom: 1px solid var(--md-default-fg-color--lightest);
}
.md-typeset .sec-head > h2 {
    margin: 0 !important;
    font-size: 1rem;
    font-weight: 700;
    color: var(--md-default-fg-color);
}
.sec-head > span {
    font-family: var(--md-code-font-family);
    font-size: 0.7rem;
    color: var(--md-default-fg-color--light);
    white-space: nowrap;
}

/* 紧凑化主题自带的 grid cards */
hr { margin: 0.5rem 0 !important; }
.md-typeset .grid.cards { margin-top: 0 !important; margin-bottom: 0 !important; }
.md-typeset .grid.cards > ul > li { padding: 0.8rem !important; }

/* --------------------------------------------------------------------------
   移动端
   -------------------------------------------------------------------------- */
@media screen and (max-width: 768px) {
    .home-container { padding-left: 0; padding-right: 0; }
    .hero-wrapper {
        flex-direction: column-reverse;   /* 头像在上 */
        gap: 1.6rem;
        padding: 1.5rem 1.1rem;
        text-align: center;
    }
    .hero-content { width: 100%; }
    .hero-name { font-size: 1.9rem; }
    .md-typeset .hero-intro { font-size: 0.95rem !important; margin-left: auto !important; margin-right: auto !important; }
    /* 手机上去掉强制换行，让文字自然回流 */
    .md-typeset .hero-intro br { display: none; }
    .stack { font-size: 0.72rem; }
    .avatar-ring { width: 8rem; height: 8rem; margin: 0 auto; }
    .hero-btns { justify-content: center; flex-wrap: wrap; }
    .grid-container { grid-template-columns: 1fr; gap: 1.2rem; }
}
</style>

<div class="home-container" markdown="1">

<div class="hero-wrapper">
<div class="hero-content">

<h1 class="hero-name">Hi, I'm HuJi.</h1>

<p class="hero-intro">
Welcome to my Website! <br>
</p>

<div class="stack">An undergraduate student at HNU.</div>

<div class="hero-btns">
<a href="https://github.com/Hujiko02" class="custom-btn btn-primary" target="_blank" rel="noopener">
    <span class="twemoji"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M216.5 362.5c-66-8-112.5-55.5-112.5-117 0-25 9-52 24-70-6.5-16.5-5.5-51.5 2-66 20-2.5 47 8 63 22.5 19-6 39-9 63.5-9s44.5 3 62.5 8.5c15.5-14 43-24.5 63-22 7 13.5 8 48.5 1.5 65.5 16 19 24.5 44.5 24.5 70.5 0 61.5-46.5 108-113.5 116.5 17 11 28.5 35 28.5 62.5v52c0 15 12.5 23.5 27.5 17.5C441 459.5 512 369 512 257 512 115.5 397 0 255.5 0S0 115.5 0 257c0 111 70.5 203 165.5 237.5 13.5 5 26.5-4 26.5-17.5v-40c-7 3-16 5-24 5-33 0-52.5-18-66.5-51.5-5.5-13.5-11.5-21.5-23-23-6-.5-8-3-8-6 0-6 10-10.5 20-10.5 14.5 0 27 9 40 27.5 10 14.5 20.5 21 33 21s20.5-4.5 32-16c8.5-8.5 15-16 21-21"/></svg></span>
    GitHub
</a>
<a href="https://space.bilibili.com/2058282898" class="custom-btn btn-secondary" target="_blank" rel="noopener">
    <span class="twemoji"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="currentColor" d="M488.6 104.1c16.7 18.1 24.4 39.7 23.3 65.7v202.4c-.4 26.4-9.2 48.1-26.5 65.1-17.2 17-39.1 25.9-65.5 26.7H92c-26.4-.8-48.2-9.8-65.3-27.2S.7 396.5 0 368.2V169.8c.8-26 9.7-47.6 26.7-65.7C43.8 87.8 65.5 78.8 92 78h29.4L96 52.2c-5.7-5.7-8.6-13-8.6-21.8S90.3 14.3 96 8.6 109 0 117.9 0s16.1 2.9 21.9 8.6L213.1 78h88l74.5-69.4C381.7 2.9 389.2 0 398 0s16.1 2.9 21.9 8.6c5.7 5.7 8.6 13 8.6 21.8s-2.9 16.1-8.6 21.8L394.6 78h29.3c26.4.8 48 9.8 64.7 26.1m-38.8 69.7c-.4-9.6-3.7-17.4-10.7-23.5-5.2-6.1-14-9.4-22.7-9.8H96c-9.6.4-17.4 3.7-23.6 9.8-6.1 6.1-9.4 13.9-9.8 23.5v194.4c0 9.2 3.3 17 9.8 23.5s14.4 9.8 23.6 9.8h320.4c9.2 0 17-3.3 23.3-9.8s9.7-14.3 10.1-23.5zm-264.3 42.7c6.3 6.3 9.7 14.1 10.1 23.2V273c-.4 9.2-3.7 16.9-9.8 23.2-6.2 6.3-14 9.5-23.6 9.5s-17.5-3.2-23.6-9.5-9.4-14-9.8-23.2v-33.3c.4-9.1 3.8-16.9 10.1-23.2s13.2-9.6 23.3-10c9.2.4 17 3.7 23.3 10m191.5 0c6.3 6.3 9.7 14.1 10.1 23.2V273c-.4 9.2-3.7 16.9-9.8 23.2s-14 9.5-23.6 9.5-17.4-3.2-23.6-9.5c-7-6.3-9.4-14-9.7-23.2v-33.3c.3-9.1 3.7-16.9 10-23.2s14.1-9.6 23.3-10c9.2.4 17 3.7 23.3 10"/></svg></span>
    Bilibili
</a>
</div>
</div>

<div class="hero-avatar-area">
<div class="avatar-ring">
<img src="others/images/avatar.jpeg" alt="胡济">
</div>
</div>
</div>

<div class="grid-container" markdown="1">

<div class="grid-card" markdown="1">
### :octicons-mortar-board-24: 教程

教程为 Deepseek V4 Flash 模型生成或翻译。
<div class="tag-box">
    <a href="tutorial/" class="tag-link">
        进入教程
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <span>Verilog</span>
    <span>Pico</span>
    <span>LaTeX</span>
</div>
</div>

<div class="grid-card" markdown="1">
### :octicons-note-24: 日记

记录所思所想。
<div class="tag-box">
    <a href="diary/2026/" class="tag-link">
        2026 年
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <a href="diary/" class="tag-link">
        全部日记
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
</div>
</div>

<div class="grid-card" markdown="1">
### :octicons-person-24: 关于我

海南大学电子科学与技术专业本科生。爱好长跑、电影、小说。
<div class="tag-box">
    <a href="me/" class="tag-link">
        关于我
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <a href="me/story.md" class="tag-link">
        我的故事
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
</div>
</div>

<div class="grid-card" markdown="1">
### :octicons-star-24: 本站

用 Zensical 配合 Material 主题搭建，内容提交后由 GitHub Actions 自动构建发布。
<div class="tag-box">
    <a href="https://github.com/Hujiko02/Hujiko02.github.io" class="tag-link" target="_blank" rel="noopener">
        仓库地址
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <span>Zensical</span>
    <span>GitHub Pages</span>
</div>
</div>

</div>

<div class="sec-head">
<h2>推荐阅读</h2>
</div>

<div class="grid cards" markdown>

-   :octicons-mortar-board-16:{ .lg .middle } __教程__{.middle}

    ---

    -   [Verilog 入门教程](tutorial/verilog.md)
    -   [Raspberry Pi Pico 系列入门指南](tutorial/pico.md)
    -   [LaTeX 入门教程](tutorial/latex.md)
    -   [Markdown 入门教程](tutorial/markdown.md)
    -   [Matplotlib 入门教程](tutorial/matplotlib.md)

-   :octicons-note-16:{ .lg .middle } __日记__{.middle}

    ---

    -   [2026 年](diary/2026.md)
    -   [日记总览](diary/index.md)

-   :octicons-person-16:{ .lg .middle } __关于我__{.middle}

    ---

    -   [关于我](me/index.md)
    -   [无人问津的故事](me/story.md)

-   :octicons-link-16:{ .lg .middle } __更多__{.middle}

    ---

    -   [:octicons-repo-16: 本站源码](https://github.com/Hujiko02/Hujiko02.github.io)
    -   [:octicons-mark-github-16: GitHub 主页](https://github.com/Hujiko02)
    -   [:octicons-device-camera-video-16: Bilibili](https://space.bilibili.com/2058282898)

</div>

</div>
