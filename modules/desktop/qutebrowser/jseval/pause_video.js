(() => {
    let retries = 0;
    function pauseVideo() {
        const video = document.querySelector("video");
        if (video) {
            video.pause();
        } else if (retries < 10) {
            retries++;
            setTimeout(pauseVideo, 500);
        }
    }
    pauseVideo();
})();
