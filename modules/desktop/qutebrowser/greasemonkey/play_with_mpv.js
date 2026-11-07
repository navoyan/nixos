// ==UserScript==
// @name                Play with MPV
// @description         Play videos and songs on the website via mpv-handler
// @namespace           play-with-mpv-handler
// @version             2025.12.31.1
// @author              Akatsuki Rui
// @license             MIT License
// @run-at              document-idle
// @noframes
// @match               *://*.youtube.com/*
// @downloadURL         https://update.greasyfork.org/scripts/416271/Play%20with%20MPV.user.js
// @updateURL           https://update.greasyfork.org/scripts/416271/Play%20with%20MPV.meta.js
// ==/UserScript==

const SITE_YOUTUBE = {
    allow: true,
    list: ["/watch", "/playlist"],
};

const MATCHERS = {
    "www.youtube.com": SITE_YOUTUBE,
    "m.youtube.com": SITE_YOUTUBE,
};

const css = String.raw;

const MPV_CSS = css`
    .play-with-mpv {
        z-index: 99999;
        position: fixed;
        left: 8px;
        bottom: 8px;
    }
    .pwm-play {
        width: 48px;
        height: 48px;
        border: 0;
        border-radius: 50%;
        background-size: 48px;
        background-image: url("https://github.com/mpv-player/mpv/raw/refs/heads/master/etc/mpv-icon.ico");
        background-repeat: no-repeat;
    }
    .pwm-play:hover {
        opacity: 1;
        visibility: visible;
        transition: all 0.2s ease-in-out;
    }
`;

// Generate protocol
function generateProto(url) {
    const btoaUrl = btoa(url)
        .replace(/\//g, "_")
        .replace(/\+/g, "-")
        .replace(/=/g, "");

    return `mpv-handler://play/${btoaUrl}`;
}

// Check the URL is matched or not
function matchUrl() {
    if (MATCHERS[location.hostname]) {
        const site = MATCHERS[location.hostname];
        const path = location.pathname;

        for (const item of site.list) {
            if (path.startsWith(item)) {
                if (
                    path.charAt(item.length) === "/" ||
                    path.charAt(item.length) === ""
                ) {
                    return site.allow;
                }
            }
        }

        if (path !== "/") {
            return !site.allow;
        }

        return false;
    }
}

// Update button display status and URL
function updateButton() {
    const isMatch = matchUrl();
    const button = document.getElementsByClassName("pwm-play")[0];

    if (button) {
        button.style =
            isMatch && !document.fullscreenElement
                ? "display: block"
                : "display: none";
        button.href = isMatch ? generateProto(location.href) : "";
    }
}

// Add play buttons to page
function createButton() {
    const head = document.getElementsByTagName("head")[0];
    const style = document.createElement("style");

    if (head) {
        style.textContent = MPV_CSS.trim();
        head.appendChild(style);
    }

    const body = document.body;
    const buttonDiv = document.createElement("div");
    const buttonPlay = document.createElement("a");

    let retries = 0;
    const pauseVideo = (e) => {
        const videoElement = document.getElementsByTagName("video")[0];
        if (videoElement) {
            videoElement.pause();
        } else {
            if (retries < 15) {
                setTimeout(pauseVideo, 500, e);
                retries += 1;
            }
        }
        if (e.stopPropagation) e.stopPropagation();
    };

    if (body) {
        buttonPlay.className = "pwm-play";
        buttonPlay.style = "display: none";
        buttonPlay.addEventListener("click", pauseVideo);

        buttonDiv.className = "play-with-mpv";
        buttonDiv.appendChild(buttonPlay);

        body.appendChild(buttonDiv);

        document.addEventListener("fullscreenchange", () => {
            const button = document.getElementsByClassName("pwm-play")[0];

            button.style = document.fullscreenElement
                ? "display: none"
                : "display: block";
        });
    }
}

// Detect PJAX changes
function detectPJAX() {
    let previousUrl = null;
    let currentUrl = null;

    setInterval(() => {
        currentUrl = location.href;

        if (previousUrl !== currentUrl) {
            updateButton();
            previousUrl = currentUrl;
        }
    }, 500);
}

// Fix TrustedHTML
if (window.trustedTypes && !trustedTypes.defaultPolicy) {
    const passThroughFn = (x) => x;
    trustedTypes.createPolicy("default", {
        createHTML: passThroughFn,
        createScriptURL: passThroughFn,
        createScript: passThroughFn,
    });
}

createButton();
detectPJAX();
