---
title: 关于我
hide:
  - toc
---

<!--
================================================================================
  关于页改动指南
  ------------------------------------------------------------------------------
  ● 改文字、链接、头像   → 往下找「内容区」，只改那里
  ● 改颜色（主色）       → 不用改这里，去 mkdocs.yml 里的 palette
  ● 改宽度 / 头像大小 / 卡片列数 → 看下面样式区开头的「可调参数」
  ● 想加一张卡片         → 内容区里把一整个 <div class="card"> … </div> 复制一份
  ● 首页用「文字在左、头像在右」，这里故意反过来（头像在左），
    两页风格统一但不会一模一样
================================================================================
-->

<style>
/* ==========================================================================
   可调参数：只改下面这 4 个数
   ========================================================================== */
.about {
  --page-width: 920px;      /* 关于页整体宽度 */
  --avatar-size: 9rem;      /* 头像大小 */
  --grid-gap: 22px;         /* 背景方格的大小 */
  --card-columns: 3;        /* 卡片列数：改成 1 就变单列 */

  max-width: var(--page-width);
  margin: 0 auto;
  padding: 0 1rem;
}

/* 隐藏主题自带的「编辑此页 / 查看源码」按钮和标题锚点 */
.md-content__button { display: none !important; }
.md-typeset .headerlink { display: none !important; pointer-events: none; }

/* ==========================================================================
   上半部分：左边头像，右边文字（与首页镜像）
   ========================================================================== */
.intro {
  display: flex;
  align-items: center;
  gap: 2.4rem;
  padding: 2.4rem 2.6rem;
  margin: 0.5rem 0;
  border-radius: 4px;
  /* 背景方格线：和首页同款，用两条 1px 渐变画出来 */
  background-image:
    linear-gradient(to right, var(--md-default-fg-color--lightest) 1px, transparent 1px),
    linear-gradient(to bottom, var(--md-default-fg-color--lightest) 1px, transparent 1px);
  background-size: var(--grid-gap) var(--grid-gap);
}
.intro-text { flex: 1; min-width: 0; }

/* 大标题（名字） */
.md-typeset .intro h1 {
  margin: 0;
  font-size: 2.4rem;
  font-weight: 800;
  line-height: 1.15;
  letter-spacing: -0.01em;
  color: var(--md-default-fg-color);
}
/* 一行自我介绍 */
.md-typeset .intro .lead {
  margin: 1.2rem 0 0 0;
  font-size: 1rem;
  line-height: 1.85;
  color: var(--md-default-fg-color);
  max-width: 30rem;
}
/* 身份说明，等宽字体 */
.md-typeset .intro .sub {
  margin: 0.9rem 0 0 0;
  font-family: var(--md-code-font-family);
  font-size: 0.74rem;
  letter-spacing: 0.03em;
  color: var(--md-default-fg-color--light);
}

/* 圆形头像：一圈细描边 */
.portrait {
  width: var(--avatar-size);
  height: var(--avatar-size);
  flex-shrink: 0;
  border-radius: 50%;
  object-fit: cover;
  padding: 5px;
  border: 1px solid color-mix(in srgb, var(--md-primary-fg-color) 45%, transparent);
}

/* 按钮：一排，主色底 + 图标 */
.btns { margin-top: 1.6rem; display: flex; gap: 12px; flex-wrap: wrap; }
.md-typeset .btns a {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 0.34rem 0.9rem;
  border-radius: 4px;
  font-size: 0.86rem;
  font-weight: 500;
  line-height: 1.3;
  text-decoration: none !important;
  background-color: var(--md-primary-fg-color);
  color: var(--md-primary-bg-color) !important;
  transition: background-color 0.2s;
}
.md-typeset .btns a:hover { background-color: var(--md-primary-fg-color--dark); }
/* GitHub 按钮前面的图标（不想要就把 ::before 整段删掉） */
.md-typeset .btns a.gh::before {
  content: "";
  width: 1.05rem;
  height: 1.05rem;
  background: currentColor;
  -webkit-mask: var(--icon-github) center / contain no-repeat;
  mask: var(--icon-github) center / contain no-repeat;
}
.btns {
  --icon-github: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'%3E%3Cpath d='M216.5 362.5c-66-8-112.5-55.5-112.5-117 0-25 9-52 24-70-6.5-16.5-5.5-51.5 2-66 20-2.5 47 8 63 22.5 19-6 39-9 63.5-9s44.5 3 62.5 8.5c15.5-14 43-24.5 63-22 7 13.5 8 48.5 1.5 65.5 16 19 24.5 44.5 24.5 70.5 0 61.5-46.5 108-113.5 116.5 17 11 28.5 35 28.5 62.5v52c0 15 12.5 23.5 27.5 17.5C441 459.5 512 369 512 257 512 115.5 397 0 255.5 0S0 115.5 0 257c0 111 70.5 203 165.5 237.5 13.5 5 26.5-4 26.5-17.5v-40c-7 3-16 5-24 5-33 0-52.5-18-66.5-51.5-5.5-13.5-11.5-21.5-23-23-6-.5-8-3-8-6 0-6 10-10.5 20-10.5 14.5 0 27 9 40 27.5 10 14.5 20.5 21 33 21s20.5-4.5 32-16c8.5-8.5 15-16 21-21'/%3E%3C/svg%3E");
}

/* ==========================================================================
   正文段落：两边留白收窄
   ========================================================================== */
.md-typeset .about > p {
  font-size: 0.92rem;
  line-height: 1.95;
  color: var(--md-default-fg-color--light);
}

/* ==========================================================================
   三张卡片（与首页的 .entry 同款，但排成三列）
   ========================================================================== */
.cards {
  display: grid;
  grid-template-columns: repeat(var(--card-columns), 1fr);
  gap: 1.6rem 2.2rem;
  margin: 2rem 0 0.5rem;
}
.card {
  border-left: 2px solid var(--md-default-fg-color--lightest);
  padding: 0.15rem 0 0.15rem 1rem;
  transition: border-color 0.25s ease;
}
.card:hover { border-left-color: var(--md-primary-fg-color); }
.md-typeset .card h3 {
  margin: 0;
  font-size: 0.98rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 7px;
  color: var(--md-default-fg-color);
}
.md-typeset .card p {
  margin: 0.5rem 0 0 0;
  font-size: 0.84rem;
  line-height: 1.75;
  color: var(--md-default-fg-color--light);
}

/* ==========================================================================
   引用（首页没有的块，用来摘录《无人问津的故事》）
   ========================================================================== */
.md-typeset .about blockquote {
  margin: 2rem 0 0;
  padding: 0.2rem 0 0.2rem 1.1rem;
  border-left: 2px solid color-mix(in srgb, var(--md-primary-fg-color) 45%, transparent);
  color: var(--md-default-fg-color--light);
  font-size: 0.9rem;
  line-height: 1.9;
}
.md-typeset .about blockquote p { margin: 0; }
.md-typeset .about blockquote p + p { margin-top: 0.35rem; font-size: 0.8rem; opacity: 0.85; }

/* ==========================================================================
   小标题（复用首页的 .section-title）
   ========================================================================== */
.md-typeset .section-title {
  margin: 2.6rem 0 1.1rem;
  padding-bottom: 0.45rem;
  border-bottom: 1px solid var(--md-default-fg-color--lightest);
  font-size: 1rem;
  font-weight: 700;
}
hr { margin: 0.5rem 0 !important; }
.md-typeset .grid.cards { margin-top: 0 !important; margin-bottom: 0 !important; }
.md-typeset .grid.cards > ul > li { padding: 0.8rem !important; }

/* ==========================================================================
   手机屏幕（宽度小于 768px 时生效）
   ========================================================================== */
@media screen and (max-width: 768px) {
  .about { padding: 0; }
  .intro {
    flex-direction: column;          /* 头像挪到文字上方 */
    gap: 1.6rem;
    padding: 1.5rem 1.1rem;
    text-align: center;
  }
  .intro-text { width: 100%; }
  .md-typeset .intro h1 { font-size: 1.9rem; }
  .md-typeset .intro .lead { font-size: 0.94rem; margin-left: auto; margin-right: auto; }
  .portrait { width: 7.5rem; height: 7.5rem; margin: 0 auto; }
  .btns { justify-content: center; }
  .cards { grid-template-columns: 1fr; gap: 1.2rem; }
}
</style>

<!-- ==========================================================================
     内容区：下面才是页面上能看到的文字，改这里就行
     ========================================================================== -->

<div class="about" markdown="1">

<!-- ① 上半部分：头像在左、文字在右（与首页镜像） -->
<div class="intro">
<img class="portrait" src="../others/images/avatar.jpeg" alt="胡济">
<div class="intro-text">

<h1>我是胡济。</h1>

<p class="lead">
海南大学电子科学与技术专业本科生，爱好长跑、电影和小说。
</p>

<p class="sub">Hainan University · Electronic Science and Technology · 2024.12 –</p>

<p class="btns">
<a class="gh" href="https://github.com/Hujiko02" target="_blank" rel="noopener">GitHub</a>
<a href="https://space.bilibili.com/2058282898" target="_blank" rel="noopener">Bilibili</a>
</p>

</div>
</div>

<!-- ② 三张卡片：想加第四张，就把下面任意一整个 <div class="card"> … </div> 复制一份
       里面的 markdown="1" 不能删，删了 ### 标题就不生效了 -->
<div class="cards" markdown="1">

<div class="card" markdown="1">
### :octicons-mortar-board-24: 学业

海南大学电子科学与技术专业，2024 年 12 月至今。
</div>

<div class="card" markdown="1">
### :octicons-heart-24: 爱好

长跑、电影、小说。
</div>

<div class="card" markdown="1">
### :octicons-code-24: 工具

Python、Verilog、LaTeX、Markdown
</div>

</div>

<!-- ③ 摘录：首页没有的块，链接到《无人问津的故事》 -->
> 多年以后，面对起跑线，我会回想起那个被呵斥后最后一次歇斯底里奔跑的遥远的下午。
>
> —— [《无人问津的故事》](story.md)

<!-- ④ 快捷入口：主题自带的卡片组件，一行一条链接，直接增删行就行 -->
<h2 class="section-title">接着逛</h2>

<div class="grid cards" markdown>

-   :octicons-book-16:{ .lg .middle } __无人问津的故事__{.middle}

    ---

    一篇还没写完的、关于自己的故事。

    [:octicons-arrow-right-16: 读一读](story.md)

-   :octicons-note-16:{ .lg .middle } __日记__{.middle}

    ---

    记录所思所想和无聊琐事。

    [:octicons-arrow-right-16: 翻一翻](../diary/index.md)

-   :octicons-mortar-board-16:{ .lg .middle } __教程__{.middle}

    ---

    Markdown、LaTeX、Matplotlib、Verilog、Pico。

    [:octicons-arrow-right-16: 看一看](../tutorial/index.md)

-   :octicons-repo-16:{ .lg .middle } __本站源码__{.middle}

    ---

    Zensical + Material 主题，GitHub Actions 自动构建。

    [:octicons-arrow-right-16: 去仓库](https://github.com/Hujiko02/Hujiko02.github.io)

</div>

</div>
