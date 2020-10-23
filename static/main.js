// JS here

// Skip podcast to the timestamps indicated in the chapter images
function chapterJump(timeCode) {
  const element = document.getElementById("episodeAudio");
  const times = timeCode.split(':');
  let seconds = 0;
  if (times.length > 2) {
    seconds = (parseInt(times[0]) * 60 * 60) + (parseInt(times[1]) * 60) + parseInt(times[2]);
  } else {
    seconds = (parseInt(times[0]) * 60) + parseInt(times[1]);
  }
  element.currentTime = seconds;
  // console.debug(`Jumping to ${seconds}`);
}

// Enhance the timestamps in transcripts to become audio links
let content = document.querySelector(".transcript-content");
if (content !== null) {
  let allTimeStamps = content.querySelectorAll("code")
  if (allTimeStamps.length > 0) {
    allTimeStamps.forEach(function(timeStamp) {
      var escapedTimeCode = timeStamp.textContent.replace("[", "").replace("]", "");
      timeStamp.onclick =  function() { chapterJump(escapedTimeCode) };
    })
  }
}

// Fix the header when scrolling so it can be navigated with chapter buttons
if ("IntersectionObserver" in window && "IntersectionObserverEntry" in window &&
    "intersectionRatio" in window.IntersectionObserverEntry.prototype &&
    document.getElementById("pixel-anchor-for-fixed-scroll") !== null) {
  let observer = new IntersectionObserver(entries => {
    if (entries[0].boundingClientRect.y < 0) {
      document.body.classList.add("header-not-at-top");
    } else {
      document.body.classList.remove("header-not-at-top");
    }
  });
  observer.observe(document.querySelector("#pixel-anchor-for-fixed-scroll"));
}
