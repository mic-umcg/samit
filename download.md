---
layout: page
title:
---
<script type="text/javascript" src="{{ site.baseurl }}/js/download.js"> </script>

<p id="downloadLabel">SAMIT software will start downloading automatically in 5 seconds...</p>
<script>
	var secondsBeforeDownloading = 5;
	var timerInterval = setInterval('setDownloadText()', 1000);
		var setDownloadText = function() {
			var label = document.getElementById('downloadLabel');

			if (secondsBeforeDownloading === 0){
                label.innerHTML = 'SAMIT software will start download: Done!!';
				downloadFile('{{ site.github.repo }}/archive/v{{ site.version }}.zip');
				clearInterval(timerInterval);
			} else {
				label.innerHTML = 'SAMIT software will start downloading automatically in ' + secondsBeforeDownloading + ' seconds...';
				secondsBeforeDownloading--;
			}
		}
</script>

Or you can download if from [here]({{ site.github.repo }}/archive/v{{ site.version }}.zip)

Currently v{{ site.version }}