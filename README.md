# Handbrake Convert DVD

Convert DVDs having multiple titles into separate MP4 files. The script runs recursively for the input directory, searches for DVDs and converts them into output folder, with directory structure preserved

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