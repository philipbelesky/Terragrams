// JS here

function chapterJump(timeCode) {
  const element = document.getElementById("episodeAudio");
  const times = timeCode.split(':');
  let seconds = 0;
  console.log(times)
  if (times.length > 2) {
    seconds = (parseInt(times[0]) * 60 * 60) + (parseInt(times[1]) * 60) + parseInt(times[2]);
  } else {
    seconds = (parseInt(times[0]) * 60) + parseInt(times[1]);
  }
  element.currentTime = seconds
}
