/* KaTeX 初始化 —— 分隔符与 Zensical 站那套（docs/others/javascripts/katex.js）保持一致，
   两边写同样的 LaTeX 出来的效果就一样。

   行内：$...$  或  \(...\)
   行间：$$...$$ 或  \[...\]

   ignoredTags 用 auto-render 的默认值，里面含 pre 和 code ——
   所以教程里写成代码块的 $...$ 示例不会被当成公式渲染，可以直接举例。

   一个坑：auto-render 的默认 errorCallback 是抛出异常，某个公式写错会中断
   这一页后面所有公式的渲染，控制台里能看到报错。要改成「渲染成红色原文而不是
   抛错」，在下面那个对象里加一行：throwOnError: false */
document.addEventListener("DOMContentLoaded", function () {
    renderMathInElement(document.body, {
        delimiters: [
            { left: "$$", right: "$$", display: true },
            { left: "$", right: "$", display: false },
            { left: "\\(", right: "\\)", display: false },
            { left: "\\[", right: "\\]", display: true },
        ],
    });
});
