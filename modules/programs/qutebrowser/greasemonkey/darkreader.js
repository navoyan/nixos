// ==UserScript==
// @name          Dark Reader (Unofficial)
// @namespace     DarkReader
// @version       4.9.133
// @run-at        document-start
// @grant         none
// @require       https://cdn.jsdelivr.net/npm/darkreader/darkreader.min.js
// @require       file:///home/narek/.config/qutebrowser/darkreader-excludes.js
// @noframes
// @include       http*
// ==/UserScript==

(function () {
    const OPTS = {
        brightness: 100,
        contrast: 110,
        sepia: 0,
    };

    if (window.__darkReaderExcluded.has(location.hostname)) {
        console.log("Hostname excluded from DarkReader");
        return;
    }
    let cover = null;

    function removeCover() {
        try {
            if (cover) cover.remove();
        } catch (e) {}
        cover = null;
    }

    function addCover() {
        try {
            cover = document.createElement("div");
            cover.style.cssText =
                "position:fixed;top:0;left:0;right:0;bottom:0;background:#181818;" +
                "z-index:2147483647;pointer-events:none";
            document.documentElement.appendChild(cover);
        } catch (e) {
            cover = null;
        }
    }

    // attach as soon as <html> exists
    if (document.documentElement) {
        addCover();
    } else {
        const mo = new MutationObserver(() => {
            if (document.documentElement) {
                mo.disconnect();
                addCover();
            }
        });
        mo.observe(document, { childList: true });
    }

    // failsafe, independent of everything else
    setTimeout(removeCover, 2000);

    function run() {
        try {
            DarkReader.enable(OPTS);
        } catch (e) {
            console.error("darkreader userscript:", e);
        } finally {
            setTimeout(removeCover, 100);
        }
    }

    if (document.readyState === "complete") {
        setTimeout(run, 100);
    } else {
        window.addEventListener("load", () => setTimeout(run, 100));
    }
})();
