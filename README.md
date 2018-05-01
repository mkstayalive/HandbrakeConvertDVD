# Handbrake Convert DVD to MP4 in bulk

Convert DVDs having multiple titles into separate MP4 files. The script runs recursively for the input directory, searches for DVDs and converts them into output directory, with directory structure preserved. The script looks for number of titles for each DVD and creates separate MP4 file for each title under the DVD directory.

If the script gets interrupted after converting some DVDs, simply run the script again with the same arguments and it will skip the MP4 conversion for the files which are already converted. Delete the MP4s which got only partially converted before running the script again.

[Install HandBrakeCLI](https://handbrake.fr/downloads.php) and add `HandBrakeCLI` executable to system `PATH`

Install dependency
```
brew install coreutils
```

## Usage:
```
./convert.sh /path/to/input /path/to/output
```

The script takes an optional 3rd parameter `preset`. The values of official Handbrake presets can be found [here](https://handbrake.fr/docs/en/latest/technical/official-presets.html). The default value is "Normal".

To throttle the CPU to a certain limit while the conversion is running, run the throttle script in a separate window of your terminal

```
sudo ./throttle.sh 200
```

![alt text](https://raw.githubusercontent.com/mkstayalive/HandbrakeConvertDVD/master/img/screenshot.jpg)
