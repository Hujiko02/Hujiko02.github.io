---
title: 首页
hide:
  - navigation
  - toc
---

<!--
  首页改动指南
  ─────────────────────────────────────────────────────────────────────────
  ● 改文字、链接、头像  → 往下找「内容区」，只改那里
  ● 改主色              → 去 mkdocs.yml 里的 palette
  ● 改宽度 / 头像大小 / 方格大小 → 看下面样式区开头的「可调参数」
  ● 加第五张卡片        → 内容区里复制一整个 <div class="entry"> … </div>
  ● 卡片列数不用管：窄屏会自动变单列
  ● 其他 <style> 里的内容别动，那是这一页的样式
-->

<style>
/* ==========================================================================
   可调参数：只改这几个数
   ========================================================================== */
.home {
  --page-width: 920px;      /* 首页整体宽度 */
  --avatar-size: 12rem;     /* 头像大小 */
  --grid-gap: 22px;         /* 背景方格的大小 */

  max-width: var(--page-width);
  margin: 0 auto;
  padding: 0 1rem;
}

/* ==========================================================================
   上半部分：左文字，右头像
   ========================================================================== */
.hero {
  display: flex;
  align-items: center;
  gap: 2rem;
  padding: 2.4rem 2.6rem;
  margin: 0.5rem 0;
  border-radius: 4px;
  /* 背景方格：两条 1px 渐变线画出来的 */
  background-image:
    linear-gradient(to right, var(--md-default-fg-color--lightest) 1px, transparent 1px),
    linear-gradient(to bottom, var(--md-default-fg-color--lightest) 1px, transparent 1px);
  background-size: var(--grid-gap) var(--grid-gap);
}
.hero-text { flex: 1; min-width: 0; }

.md-typeset .hero h1 {                       /* 名字 */
  margin: 0;
  font-size: 2.5rem;
  font-weight: 800;
  line-height: 1.15;
  letter-spacing: -0.01em;
}
.md-typeset .hero .lead {                    /* 欢迎语 */
  margin: 1.3rem 0 0 0;
  font-size: 1.02rem;
  line-height: 1.85;
  max-width: 27rem;
}
.md-typeset .hero .sub {                     /* 身份说明，等宽小字 */
  margin: 1rem 0 0 0;
  font-family: var(--md-code-font-family);
  font-size: 0.76rem;
  letter-spacing: 0.04em;
  color: var(--md-default-fg-color--light);
}

.avatar {                                    /* 圆形头像 */
  width: var(--avatar-size);
  height: var(--avatar-size);
  flex-shrink: 0;
  object-fit: cover;
  border-radius: 50%;
  padding: 5px;
  border: 1px solid color-mix(in srgb, var(--md-primary-fg-color) 45%, transparent);
}

.btns {                                      /* 按钮区 */
  margin-top: 1.7rem;
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  --icon-github: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'%3E%3Cpath d='M216.5 362.5c-66-8-112.5-55.5-112.5-117 0-25 9-52 24-70-6.5-16.5-5.5-51.5 2-66 20-2.5 47 8 63 22.5 19-6 39-9 63.5-9s44.5 3 62.5 8.5c15.5-14 43-24.5 63-22 7 13.5 8 48.5 1.5 65.5 16 19 24.5 44.5 24.5 70.5 0 61.5-46.5 108-113.5 116.5 17 11 28.5 35 28.5 62.5v52c0 15 12.5 23.5 27.5 17.5C441 459.5 512 369 512 257 512 115.5 397 0 255.5 0S0 115.5 0 257c0 111 70.5 203 165.5 237.5 13.5 5 26.5-4 26.5-17.5v-40c-7 3-16 5-24 5-33 0-52.5-18-66.5-51.5-5.5-13.5-11.5-21.5-23-23-6-.5-8-3-8-6 0-6 10-10.5 20-10.5 14.5 0 27 9 40 27.5 10 14.5 20.5 21 33 21s20.5-4.5 32-16c8.5-8.5 15-16 21-21'/%3E%3C/svg%3E");
}
.md-typeset .btns a {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 0.34rem 0.9rem;
  font-size: 0.86rem;
  font-weight: 500;
  line-height: 1.3;
  border-radius: 4px;
  background-color: var(--md-primary-fg-color);
  color: var(--md-primary-bg-color);
  transition: background-color 0.2s;
}
.md-typeset .btns a:hover { background-color: var(--md-primary-fg-color--dark); }
/* 按钮里的 GitHub 图标（想换图标改上面的 --icon-github；不想要就删掉这两行 ::before） */
.md-typeset .btns a::before {
  content: "";
  width: 1.05rem;
  height: 1.05rem;
  background: currentColor;
  -webkit-mask: var(--icon-github) center / contain no-repeat;
  mask: var(--icon-github) center / contain no-repeat;
}

/* ==========================================================================
   四张卡片
   列宽和列距用的就是主题自带的 .grid 的值（minmax(16rem) + .4rem），
   这样竖线才能和下面「推荐阅读」的默认网格对开；只有行距是自定义的
   ========================================================================== */
.entries {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 16rem), 1fr));
  gap: 1.6rem 0.4rem;
  margin: 2.2rem 0 0.5rem;
}
.entry {
  border-left: 2px solid var(--md-default-fg-color--lightest);
  padding: 0.15rem 0 0.15rem 1rem;
  transition: border-color 0.25s ease;
}
.entry:hover { border-left-color: var(--md-primary-fg-color); }
.md-typeset .entry h3 {
  margin: 0;
  font-size: 1rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 7px;
}
.md-typeset .entry p {
  margin: 0.5rem 0 0 0;
  font-size: 0.84rem;
  line-height: 1.65;
  color: var(--md-default-fg-color--light);
}

.links {                                     /* 卡片底部的链接 + 标签 */
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
  margin-top: 0.6rem;
}
.md-typeset .links a {
  display: inline-flex;
  align-items: center;
  font-size: 0.76rem;
  font-weight: 700;
  color: var(--md-primary-fg-color);
  transition: opacity 0.2s;
}
.md-typeset .links a:hover { opacity: 0.75; }
.links a::after { content: "↗"; font-size: 0.8em; margin-left: 2px; }   /* 链接后面的小箭头 */
.links .tag { font-size: 0.72rem; color: var(--md-default-fg-color--light); opacity: 0.85; }

/* ==========================================================================
   推荐阅读：直接用主题自带的 grid cards，一行样式都不写
   （和 docs/tutorial/index.md 里的用法一样）
   ========================================================================== */
.md-typeset .section-title {
  margin: 2.6rem 0 1.1rem;
  padding-bottom: 0.45rem;
  border-bottom: 1px solid var(--md-default-fg-color--lightest);
  font-size: 1rem;
  font-weight: 700;
}

/* ==========================================================================
   手机屏幕（宽度小于 768px 时生效）
   ========================================================================== */
@media screen and (max-width: 768px) {
  .home { padding: 0; }
  .hero {
    flex-direction: column-reverse;          /* 头像挪到文字上方 */
    gap: 1.6rem;
    padding: 1.5rem 1.1rem;
    text-align: center;
  }
  .hero-text { width: 100%; }
  .md-typeset .hero h1 { font-size: 1.9rem; }
  .md-typeset .hero .lead { font-size: 0.95rem; margin-left: auto; margin-right: auto; }
  .avatar { width: 8rem; height: 8rem; margin: 0 auto; }
  .btns { justify-content: center; }
}
</style>

<!-- ==========================================================================
     内容区：页面上能看到的文字都在下面
     ========================================================================== -->

<div class="home" markdown="1">

<!-- ① 上半部分：名字、欢迎语、身份、按钮、头像 -->
<div class="hero">
<div class="hero-text">

<h1>Hi, I'm Hu Ji.</h1>

<p class="lead">
Welcome to HuJi Notes!
</p>

<p class="sub">I'm an undergraduate at Hainan University, majoring in Electronic Science and Technology.</p>

<p class="btns">
<a href="https://github.com/Hujiko02" target="_blank" rel="noopener">GitHub</a>
</p>

</div>

<img class="avatar" src="others/images/avatar.jpeg" alt="胡济">
</div>

<!-- ② 四张卡片：加第五张就复制一整个 <div class="entry"> … </div>
       markdown="1" 不能删，删了里面的 ### 标题就不生效 -->
<div class="entries" markdown="1">

<div class="entry" markdown="1">
### :octicons-mortar-board-24: 教程

一些简单的入门教程。

<div class="links">
<a href="tutorial/">进入教程</a>
<span class="tag">Markdown</span>
<span class="tag">LaTeX</span>
<span class="tag">Pico2</span>
</div>
</div>

<div class="entry" markdown="1">
### :octicons-note-24: 日记

记录所思所想和无聊琐事。

<div class="links">
<a href="diary/2026/">2026 年</a>
</div>
</div>

<div class="entry" markdown="1">
### :octicons-person-24: 关于我

海南大学电子科学与技术专业本科生。爱好长跑与动漫。

<div class="links">
<a href="me/">关于我</a>
</div>
</div>

<div class="entry" markdown="1">
### :octicons-book-24: 本站

用 Zensical 配合 Material 主题搭建，内容提交后由 GitHub Actions 自动构建发布。

<div class="links">
<a href="https://github.com/Hujiko02/Hujiko02.github.io" target="_blank" rel="noopener">仓库地址</a>
<span class="tag">Zensical</span>
<span class="tag">GitHub Pages</span>
</div>
</div>

</div>

<!-- ③ 推荐阅读：主题自带的卡片组件，一行一条链接，直接增删 -->
<h2 class="section-title">推荐阅读</h2>

<div class="grid cards" markdown>

-   :octicons-mortar-board-16:{ .lg .middle } __教程__{.middle}

    ---

    -   [Markdown 入门教程](tutorial/markdown.md)
    -   [LaTeX 入门教程](tutorial/latex.md)
    -   [Matplotlib 入门教程](tutorial/matplotlib.md)
    -   [Verilog 入门教程](tutorial/verilog.md)
    -   [Raspberry Pi Pico 系列入门指南](tutorial/pico.md)

-   :octicons-note-16:{ .lg .middle } __日记__{.middle}

    ---

    -   [2026 年](diary/2026.md)
    -   [日记总览](diary/index.md)

-   :octicons-person-16:{ .lg .middle } __关于我__{.middle}

    ---

    -   [关于我](me/index.md)
    -   [我的邮箱](mailto:ji_hu@foxmail.com)

-   :octicons-link-16:{ .lg .middle } __更多__{.middle}

    ---

    -   [:octicons-repo-16: 本站源码](https://github.com/Hujiko02/Hujiko02.github.io)
    -   [:octicons-mark-github-16: GitHub 主页](https://github.com/Hujiko02)
    -   [:fontawesome-brands-bilibili: Bilibili 主页](https://space.bilibili.com/2058282898)

</div>

</div>
