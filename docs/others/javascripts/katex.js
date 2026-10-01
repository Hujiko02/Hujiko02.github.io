/* =============================================================================
   KaTeX 按需加载器（自托管，资源在 docs/others/katex/）
   -----------------------------------------------------------------------------
   背景：以前 KaTeX 走 cdnjs，而且 katex.min.js(~270KB) + auto-render.min.js 是写在
   extra_javascript 里的，等于**每个页面**都要下载并解析这两个文件——包括完全
   没有公式的首页和日记页。同时 cdnjs 在国内访问还经常慢。

   现在：
     - 文件自托管（同源、无第三方依赖、可被浏览器缓存），版本见 docs/others/katex/README
     - katex.min.css 仍在 <head> 里同步加载（24KB / gzip 3.6KB），避免公式页先闪一下
       未渲染的 $...$
     - 两个 JS 只在「当前页面正文里真的出现公式」时才注入；字体也只有渲染到公式时
       浏览器才去下（KaTeX 自带 font-display: block）

   路径处理：文件被放在 docs/others/javascripts/ 下，站点根相对路径是
   others/javascripts/katex.js，而 KaTeX 资源在 others/katex/。页面可能处于任意
   深度（如 /diary/2026/），所以不能写死相对路径；这里从自己 <script> 的 src 反推出
   基准 URL（等价于 | url 过滤器解析出的路径），保证子目录页面也正确。
   ============================================================================= */

(() => {
  const self =
    document.currentScript ||
    [...document.scripts].find((el) => /javascripts\/katex\.js/.test(el.src));
  if (!self) return;

  const BASE = new URL("../katex/", self.src);

  // 判定页面有没有公式：只扫「不在代码块里」的文本节点。
  // 不能直接拿 body.textContent 判断——教程里满是 $ 开头的 shell 命令、LaTeX 语法的
  // 示例代码，那些节点的公式本来也不会被 auto-render 处理（它默认忽略 pre/code），
  // 拿它们当依据白拉 280KB。
  const MATH = /(?:\$\$[\s\S]*?\$\$)|(?:\\\[[\s\S]*?\\\])|(?:\\\([\s\S]*?\\\))|(?:\$[^\s$\n][^$\n]*\$)/;

  function hasMath(root) {
    if (!root) return false;
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode(node) {
        const parent = node.parentElement;
        if (!parent || parent.closest("pre, code, script, style, textarea")) {
          return NodeFilter.FILTER_REJECT;
        }
        return NodeFilter.FILTER_ACCEPT;
      },
    });
    while (walker.nextNode()) {
      if (MATH.test(walker.currentNode.data)) return true;
    }
    return false;
  }

  const DELIMITERS = [
    { left: "$$", right: "$$", display: true },
    { left: "$", right: "$", display: false },
    { left: "\\(", right: "\\)", display: false },
    { left: "\\[", right: "\\]", display: true },
  ];

  let pending = null;

  function loadScript(name) {
    return new Promise((resolve, reject) => {
      const el = document.createElement("script");
      el.src = new URL(name, BASE).href;
      el.onload = resolve;
      el.onerror = () => reject(new Error(`KaTeX 资源加载失败：${el.src}`));
      document.head.appendChild(el);
    });
  }

  // 只加载一次：katex.min.js 必须在 auto-render.min.js 之前（后者要读全局 katex）
  function ensure() {
    if (!pending) {
      pending = loadScript("katex.min.js")
        .then(() => loadScript("auto-render.min.js"))
        .catch((error) => {
          pending = null; // 允许下次导航重试
          console.error(error);
        });
    }
    return pending;
  }

  async function render(body) {
    if (!hasMath(body)) return;
    await ensure();
    // 加载是异步的，回来时可能已经跳转到别的页面了
    if (!body.isConnected || typeof window.renderMathInElement !== "function") return;
    window.renderMathInElement(body, { delimiters: DELIMITERS });
  }

  // document$ 是主题提供的导航事件流：首次加载和每次即时跳转都会触发。
  // 万一主题脚本没跑起来（被拦截、CSP、老浏览器），退回一次性的 DOMContentLoaded。
  if (window.document$) {
    window.document$.subscribe(({ body }) => {
      void render(body);
    });
  } else {
    const start = () => void render(document.querySelector("article") || document.body);
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", start, { once: true });
    } else {
      start();
    }
  }
})();
