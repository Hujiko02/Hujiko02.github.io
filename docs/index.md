---
title: 欢迎来到我的网站！
# 隐藏左侧导航、右侧目录、页脚和反馈组件，让首页变成一张「着陆页」
hide:
  - navigation
  - toc
  - footer
  - feedback
---

<style>
/* ==========================================================================
   首页专用样式
   --------------------------------------------------------------------------
   整块写在 Markdown 里，Zensical 原样输出 → 只在这一页生效，不影响其他页面。
   颜色一律走主题 CSS 变量，明暗模式与配色自动跟随（当前 indigo + amber）。
   ========================================================================== */

/* 隐藏「编辑此页 / 查看源码」按钮和标题锚点链接 */
.md-content__button {
    display: none !important;
}
.md-typeset .headerlink {
    display: none !important;
    pointer-events: none;
}

/* 外层容器：比正文窄一点，视觉更聚拢 */
.home-container {
    max-width: 920px;
    margin: 0 auto;
    padding: 0 1rem;
}
@media screen and (min-width: 2000px) {
    .home-container { max-width: 950px; }
}

/* --------------------------------------------------------------------------
   英雄区：左侧文字 + 右侧头像，背景是点阵
   -------------------------------------------------------------------------- */
.hero-wrapper {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 2.3rem 2.7rem;
    margin: 0.5rem 0;
    position: relative;
    /* 点阵背景：1.2px 的圆点，间距 18px */
    background-image: radial-gradient(var(--md-default-fg-color--lightest) 1.2px, transparent 1.2px);
    background-size: 18px 18px;
    border-radius: 16px;
}

.hero-content {
    flex: 1;
    text-align: left;
    z-index: 2;
}

.hero-title {
    font-size: 2.1rem !important;
    font-weight: 800;
    margin: 0;
    color: var(--md-default-fg-color);
    line-height: 1.3;
}

/* 加 .md-typeset 提权，压过主题的正文样式 */
.md-typeset .hero-intro {
    font-size: 1.65rem !important;
    margin: 0.65rem 0 1.2rem 0 !important;
    color: var(--md-default-fg-color--light);
    font-weight: 500;
}

/* 马克笔涂抹：只给下半部分上色 */
.marker-highlight {
    background: linear-gradient(to bottom, transparent 60%, rgba(99, 102, 241, 0.28) 0%);
    padding: 0 6px;
    border-radius: 4px;
    color: var(--md-primary-fg-color);
}

/* --------------------------------------------------------------------------
   打字机
   -------------------------------------------------------------------------- */
.typewriter-container {
    height: 1.8rem;
    margin: 1rem 0;
    display: flex;
    align-items: center;
}
#typewriter-text {
    font-family: var(--md-code-font-family);
    font-size: 1.28rem;
    font-weight: 700;
    color: var(--md-default-fg-color--light);
}
.cursor {
    display: inline-block;
    width: 3px;
    height: 1.4rem;
    background-color: var(--md-primary-fg-color);
    margin-left: 5px;
    animation: blink 0.8s infinite;
}
@keyframes blink { 50% { opacity: 0; } }

/* --------------------------------------------------------------------------
   头像：渐变光环 + 彩色投影
   -------------------------------------------------------------------------- */
.avatar-glow {
    width: 11.9rem;
    height: 11.9rem;
    border-radius: 50%;
    padding: 4px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    box-shadow: 0 10px 30px rgba(118, 75, 162, 0.4);
    flex-shrink: 0;
    margin-right: 0.3rem;
    transform: translateY(4px);
}
.avatar-glow img {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
    background: var(--md-default-bg-color);
}

/* 按钮组
   -------------------------------------------------------------------------------
   注意：这两个按钮必须是手写 HTML —— .hero-content 是原始 HTML 块，
   嵌套在里面的 markdown="1" 不会被解析（md_in_html 只处理直接子元素），
   写 Markdown 链接语法会原样显示成文字。图标同理，直接内联 SVG。
   -------------------------------------------------------------------------- */
.hero-btns {
    display: flex;
    gap: 15px;
    margin-top: 1.5rem;
}
.md-typeset .custom-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 0.38rem 0.95rem;
    border-radius: 8px;
    font-size: 0.9rem;
    font-weight: 500;
    line-height: 1.2;
    text-decoration: none !important;
    transition: all 0.2s;
}
.md-typeset .btn-primary {
    background-color: var(--md-primary-fg-color);
    color: var(--md-primary-bg-color) !important;
}
.md-typeset .btn-secondary {
    background-color: var(--md-default-fg-color--lightest);
    color: var(--md-default-fg-color) !important;
}
.md-typeset .custom-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}
.custom-btn .twemoji {
    width: 1.1rem;
    height: 1.1rem;
}

/* --------------------------------------------------------------------------
   四格磁贴（2×2）
   -------------------------------------------------------------------------- */
.grid-container {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
    margin: 1.2rem 0 1.35rem;
}
.grid-card {
    background: var(--md-default-bg-color);
    border: 1px solid var(--md-default-fg-color--lightest);
    border-radius: 12px;
    padding: 0.9rem 1rem;
    position: relative;
    transition: border-color 0.25s ease, box-shadow 0.25s ease, transform 0.25s ease;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    gap: 0.35rem;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.04);
}
.grid-card:hover {
    border-color: var(--md-primary-fg-color);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    transform: translateY(-2px);
}
.grid-card h3 {
    margin: 0 0 0.1rem 0 !important;
    font-size: 1rem !important;
    display: flex;
    align-items: center;
    gap: 6px;
    color: var(--md-default-fg-color);
}
.grid-card p {
    margin: 0 !important;
    font-size: 0.82rem;
    line-height: 1.5;
    color: var(--md-default-fg-color--light);
}

/* --------------------------------------------------------------------------
   标签行：# 号标签 + 带箭头的链接
   -------------------------------------------------------------------------- */
.tag-box {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 0.4rem;
    align-items: center;
}
.tag-box span {
    font-size: 0.72rem;
    color: var(--md-default-fg-color--light);
    display: inline-flex;
    align-items: center;
    font-weight: 400;
    opacity: 0.8;
}
/* 用伪元素加 # 号，不用写进 Markdown */
.tag-box span::before {
    content: "#";
    margin-right: 1px;
    color: var(--md-default-fg-color--light);
    font-family: var(--md-code-font-family);
    opacity: 0.6;
}
.md-typeset .tag-link {
    display: inline-flex;
    align-items: center;
    gap: 2px;
    font-size: 0.72rem;
    color: var(--md-primary-fg-color) !important;
    text-decoration: none !important;
    font-weight: 700;
    transition: opacity 0.2s;
}
.md-typeset .tag-link:hover { opacity: 0.8; }
.jump-icon {
    width: 13px;
    height: 13px;
    fill: currentColor;
    transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.tag-link:hover .jump-icon {
    transform: translate(3px, -3px);
}

/* --------------------------------------------------------------------------
   推荐阅读标题：居中 + 两侧渐隐横线
   -------------------------------------------------------------------------- */
.md-typeset .rec-title {
    margin: 2rem 0 1.5rem !important;
    font-weight: 700;
    color: var(--md-default-fg-color) !important;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 15px;
    text-align: center;
}
.rec-title .twemoji {
    color: var(--md-primary-fg-color);
    width: 1.2rem;
    height: 1.2rem;
}
.rec-title::before,
.rec-title::after {
    content: "";
    display: block;
    height: 1px;
    flex: 1;
    max-width: 200px;
    background: linear-gradient(90deg, transparent, var(--md-default-fg-color--light));
    opacity: 0.6;
}
.rec-title::after {
    background: linear-gradient(90deg, var(--md-default-fg-color--light), transparent);
}

/* 紧凑化主题自带的 grid cards */
hr { margin: 0.5rem 0 !important; }
.md-typeset .grid.cards { margin-top: 0 !important; margin-bottom: 0 !important; }
.md-typeset .grid.cards > ul > li { padding: 0.8rem !important; }

/* --------------------------------------------------------------------------
   移动端：头像移到上方，整体居中
   -------------------------------------------------------------------------- */
@media screen and (max-width: 768px) {
    .home-container { padding-left: 0; padding-right: 0; }

    .hero-wrapper {
        flex-direction: column-reverse;   /* 头像在上，文字在下 */
        padding: 1.25rem 0.85rem;
        background-position: center -3px;
        gap: 1.5rem;
        text-align: center;
    }
    .hero-content { text-align: center !important; width: 100%; }
    .hero-avatar-area {
        width: 100%;
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .avatar-glow {
        width: 8rem;
        height: 8rem;
        margin: 0 auto !important;
    }
    .hero-title { font-size: 1.7rem !important; text-align: center; display: block; }
    .md-typeset .hero-intro {
        font-size: 1.35rem !important;
        margin: 0.5rem 0 1rem 0 !important;
        line-height: 1.3;
        text-align: center;
    }
    #typewriter-text { font-size: 1.1rem; }
    .typewriter-container { justify-content: center; }
    .hero-btns { justify-content: center; gap: 10px; flex-wrap: wrap; margin-top: 1rem; }
    .md-typeset .custom-btn { font-size: 0.75rem; }
    .grid-container { grid-template-columns: 1fr; gap: 0.6rem; }
    .grid-card { padding: 0.85rem 0.95rem; }
    .tag-box { gap: 8px; }
}
</style>

<div class="home-container" markdown="1">

<div class="hero-wrapper">
<div class="hero-content">

<div class="hero-title">
Hi, I'm <span class="marker-highlight">胡济</span>.
</div>
<h1 class="hero-intro">
欢迎来到我的网站！👋
</h1>

<div class="typewriter-container">
<span id="typewriter-text"></span><span class="cursor"></span>
</div>

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
<div class="avatar-glow">
<img src="others/images/avatar.jpeg" alt="头像">
</div>
</div>
</div>

<div class="grid-container" markdown="1">

<div class="grid-card" markdown="1">
### :octicons-mortar-board-24: 教程

把踩过的坑、好不容易弄懂的东西写下来，省掉别人摸索的那段时间。

<div class="tag-box">
    <a href="tutorial/" class="tag-link">
        进入专栏
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <span>Verilog</span>
    <span>LaTeX</span>
    <span>Markdown</span>
    <span>Pico</span>
</div>
</div>

<div class="grid-card" markdown="1">
### :octicons-note-24: 日记

记录所思所想。把日子过成以后还能翻回来看看的文字。

<div class="tag-box">
    <a href="diary/2026/" class="tag-link">
        2026 年
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <a href="diary/" class="tag-link">
        全部日记
        <svg class="jump-icon" viewBox="0 0 24 24"><path d="M5 17.59L15.59 7H9V5h10v10h-2V8.41L6.41 19 5 17.59z"/></svg>
    </a>
    <span>随笔</span>
</div>
</div>

<div class="grid-card" markdown="1">
### :octicons-person-24: 关于我

海南大学电子科学与技术专业。写代码，也写点故事。

<div class="tag-box">
    <a href="me/" class="tag-link">
        认识一下
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

用 Zensical 配合 Material 主题搭建，源码公开在 GitHub，欢迎来交流。

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

### :octicons-book-16: 推荐阅读 {.rec-title}

<div class="grid cards" markdown>

-   :octicons-mortar-board-16:{ .lg .middle } __教程__{.middle}

    ---

    -   [Verilog 入门教程](tutorial/verilog.md)
    -   [LaTeX 入门教程](tutorial/latex.md)
    -   [Markdown 入门教程](tutorial/markdown.md)
    -   [Matplotlib 入门教程](tutorial/matplotlib.md)
    -   [Raspberry Pi Pico 系列入门指南](tutorial/pico.md)

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

<script>
  (() => {
    // 想改打字内容就改这个数组
    const phrases = [
      "海南大学 · 电子科学与技术",
      "A Tech Enthusiast!",
      "记录所思所想。",
      "谁又能毫不茫然地抓住良机呢。",
      "生如逆旅，一苇以航。"
    ];
    let typeTimeout = null;

    function runTypewriter() {
      const textElement = document.getElementById('typewriter-text');

      // 不在首页（没有这个容器）就直接退出
      if (!textElement) return;

      let phraseIndex = 0;
      let charIndex = 0;
      let isDeleting = false;
      let typeSpeed = 100;

      if (typeTimeout) clearTimeout(typeTimeout);

      function type() {
        // 元素已被移除（用户快速切页）就停手
        if (!document.body.contains(textElement)) return;

        const currentPhrase = phrases[phraseIndex];

        if (isDeleting) {
          textElement.textContent = currentPhrase.substring(0, charIndex - 1);
          charIndex--;
          typeSpeed = 50;
        } else {
          textElement.textContent = currentPhrase.substring(0, charIndex + 1);
          charIndex++;
          typeSpeed = 150;
        }

        if (!isDeleting && charIndex === currentPhrase.length) {
          isDeleting = true;
          typeSpeed = 2000;          // 整句写完停 2 秒
        } else if (isDeleting && charIndex === 0) {
          isDeleting = false;
          phraseIndex = (phraseIndex + 1) % phrases.length;
          typeSpeed = 500;
        }

        typeTimeout = setTimeout(type, typeSpeed);
      }

      type();
    }

    // document$ 是主题提供的页面加载流：开了 instant navigation 时切页不会触发
    // 原生加载事件，只有它可靠。没有它就降级回 DOMContentLoaded。
    if (typeof document$ !== 'undefined') {
      document$.subscribe(runTypewriter);
    } else {
      document.addEventListener('DOMContentLoaded', runTypewriter);
    }
  })();
</script>
