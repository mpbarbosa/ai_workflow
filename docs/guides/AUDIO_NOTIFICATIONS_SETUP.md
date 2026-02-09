# Audio Notifications Setup Guide

**Version**: 4.0.1  
**Feature Version**: v3.1.0  
**Last Updated**: 2026-02-09

> 🔔 **Purpose**: Configure audio notifications for workflow events

## Table of Contents

- [Overview](#overview)
- [Quick Setup](#quick-setup)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Platform-Specific Notes](#platform-specific-notes)

---

## Overview

Audio notifications provide audible alerts for important workflow events:

- **Continue Prompt**: Sound when workflow pauses for user input
- **Completion**: Sound when workflow finishes successfully

**Benefits**:
- Work on other tasks while workflow runs
- No need to constantly check terminal
- Immediate feedback when input needed
- Celebrate successful completions

**Integration**: Works seamlessly with `--auto` mode and interactive mode

---

## Quick Setup

### 1. Check Audio Support

```bash
# Test if your system has audio capabilities
./src/workflow/lib/health_check.sh --audio
```

**Expected Output**:
```
✓ Audio player detected: ffplay
✓ Audio notifications supported
✓ Sample sound files found
```

### 2. Enable Notifications

Notifications are **enabled by default** in v3.1.0+. To disable:

```bash
# Disable via environment variable
export AUDIO_NOTIFICATIONS_ENABLED=false
./src/workflow/execute_tests_docs_workflow.sh

# Or via configuration file
# In .workflow-config.yaml:
audio:
  enabled: false
```

### 3. Test Notifications

```bash
# Test continue prompt sound
./scripts/test_audio_notification.sh continue_prompt

# Test completion sound
./scripts/test_audio_notification.sh completion
```

---

## System Requirements

### Audio Players (Detected Automatically)

The workflow detects and uses the first available player:

| Player | Platform | Format Support | Quality | Priority |
|--------|----------|----------------|---------|----------|
| **ffplay** | Linux/macOS/Windows | MP3, WAV, OGG, FLAC | Excellent | 1st |
| **mpg123** | Linux/macOS | MP3 only | Excellent | 2nd |
| **paplay** | Linux (PulseAudio) | WAV, MP3* | Good | 3rd |
| **aplay** | Linux (ALSA) | WAV only | Good | 4th |

*Requires PulseAudio MP3 codec

### Operating Systems

- ✅ **Linux**: Full support (Ubuntu, Fedora, Arch, etc.)
- ✅ **macOS**: Full support (ffplay via Homebrew)
- ✅ **Windows**: Full support (WSL2 with PulseAudio)
- ⚠️ **WSL1**: Limited (requires X server audio forwarding)

---

## Installation

### Linux (Ubuntu/Debian)

```bash
# Install ffplay (recommended)
sudo apt update
sudo apt install ffmpeg

# Or install mpg123
sudo apt install mpg123

# Or use PulseAudio (often pre-installed)
sudo apt install pulseaudio-utils
```

### Linux (Fedora/RHEL)

```bash
# Install ffplay
sudo dnf install ffmpeg

# Or mpg123
sudo dnf install mpg123
```

### Linux (Arch)

```bash
# Install ffplay
sudo pacman -S ffmpeg

# Or mpg123
sudo pacman -S mpg123
```

### macOS

```bash
# Install ffplay via Homebrew
brew install ffmpeg

# Or mpg123
brew install mpg123
```

### Windows (WSL2)

```bash
# Inside WSL2 terminal
sudo apt update
sudo apt install ffmpeg pulseaudio

# Configure PulseAudio for WSL2
echo "export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}'):4713" >> ~/.bashrc
source ~/.bashrc
```

---

## Configuration

### Environment Variables

```bash
# Enable/disable notifications
export AUDIO_NOTIFICATIONS_ENABLED=true

# Custom sound file paths
export AUDIO_CONTINUE_PROMPT_SOUND="/path/to/prompt.mp3"
export AUDIO_COMPLETION_SOUND="/path/to/completion.mp3"

# Run workflow
./src/workflow/execute_tests_docs_workflow.sh
```

### Configuration File

Add to `.workflow-config.yaml`:

```yaml
audio:
  enabled: true
  sounds:
    continue_prompt: "/path/to/prompt.mp3"
    completion: "/path/to/completion.mp3"
  player: "ffplay"  # Optional: force specific player
```

### Per-Run Override

```bash
# Disable for single run
AUDIO_NOTIFICATIONS_ENABLED=false ./src/workflow/execute_tests_docs_workflow.sh

# Custom sounds for single run
AUDIO_CONTINUE_PROMPT_SOUND="/path/to/custom.mp3" \
  ./src/workflow/execute_tests_docs_workflow.sh
```

---

## Customization

### Using Custom Sound Files

1. **Download or create sound files** (MP3, WAV, OGG formats)

2. **Place in accessible location**:
   ```bash
   mkdir -p ~/.workflow_sounds
   cp my_sounds/*.mp3 ~/.workflow_sounds/
   ```

3. **Configure paths**:
   ```bash
   export AUDIO_CONTINUE_PROMPT_SOUND="$HOME/.workflow_sounds/prompt.mp3"
   export AUDIO_COMPLETION_SOUND="$HOME/.workflow_sounds/done.mp3"
   ```

### Recommended Sound Characteristics

**Continue Prompt**:
- Duration: 0.5-2 seconds
- Volume: Moderate
- Tone: Attention-grabbing but not jarring
- Examples: Single beep, chime, bell

**Completion**:
- Duration: 1-3 seconds
- Volume: Moderate to loud
- Tone: Celebratory or satisfying
- Examples: Success jingle, multiple beeps, fanfare

### Free Sound Resources

- [Freesound.org](https://freesound.org/) - Creative Commons sounds
- [Zapsplat.com](https://www.zapsplat.com/) - Free sound effects
- [Notification Sounds](https://notificationsounds.com/) - UI sounds
- Generate with: `ffmpeg -f lavfi -i "sine=frequency=1000:duration=1" beep.mp3`

---

## Troubleshooting

### No Sound Playing

**Problem**: Notifications enabled but no sound

**Solutions**:

1. **Check audio player installation**:
   ```bash
   command -v ffplay || echo "ffplay not found"
   command -v mpg123 || echo "mpg123 not found"
   ```

2. **Test system audio**:
   ```bash
   # Generate test tone
   ffplay -f lavfi -i "sine=frequency=1000:duration=2" -autoexit -nodisp
   ```

3. **Verify sound file paths**:
   ```bash
   ls -la "$AUDIO_CONTINUE_PROMPT_SOUND"
   ls -la "$AUDIO_COMPLETION_SOUND"
   ```

4. **Check file permissions**:
   ```bash
   chmod +r "$AUDIO_CONTINUE_PROMPT_SOUND"
   ```

### Audio Player Not Detected

**Problem**: "Audio player not found" warning

**Solutions**:

```bash
# Install ffplay (recommended)
sudo apt install ffmpeg  # Ubuntu/Debian
brew install ffmpeg      # macOS

# Or install alternative
sudo apt install mpg123
```

### Sound Files Not Found

**Problem**: "Sound file not found" error

**Solutions**:

1. **Download sample sounds**:
   ```bash
   mkdir -p ~/.workflow_sounds
   cd ~/.workflow_sounds
   
   # Download free sounds (example)
   wget https://freesound.org/data/previews/125/125033_2097942-lq.mp3 -O prompt.mp3
   wget https://freesound.org/data/previews/80/80262_877451-lq.mp3 -O completion.mp3
   ```

2. **Set environment variables**:
   ```bash
   export AUDIO_CONTINUE_PROMPT_SOUND="$HOME/.workflow_sounds/prompt.mp3"
   export AUDIO_COMPLETION_SOUND="$HOME/.workflow_sounds/completion.mp3"
   ```

3. **Add to shell profile** (`~/.bashrc` or `~/.zshrc`):
   ```bash
   echo 'export AUDIO_CONTINUE_PROMPT_SOUND="$HOME/.workflow_sounds/prompt.mp3"' >> ~/.bashrc
   echo 'export AUDIO_COMPLETION_SOUND="$HOME/.workflow_sounds/completion.mp3"' >> ~/.bashrc
   ```

### WSL Audio Issues

**Problem**: Audio not working in WSL

**Solutions**:

1. **WSL2 with PulseAudio** (recommended):
   ```bash
   # Install PulseAudio in WSL
   sudo apt install pulseaudio
   
   # Configure Windows PulseAudio server
   # Install: https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/
   
   # Set PULSE_SERVER in WSL
   export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}'):4713
   ```

2. **WSL1 with X Server**:
   ```bash
   # Install VcXsrv or X410
   # Enable audio in X server settings
   export DISPLAY=:0
   ```

3. **Alternative: Disable audio**:
   ```bash
   export AUDIO_NOTIFICATIONS_ENABLED=false
   ```

### Volume Too Loud/Quiet

**Problem**: Sound volume not ideal

**Solutions**:

1. **Adjust system volume** (easiest)

2. **Use ffmpeg to adjust file volume**:
   ```bash
   # Reduce volume by 50%
   ffmpeg -i original.mp3 -filter:a "volume=0.5" quieter.mp3
   
   # Increase volume by 50%
   ffmpeg -i original.mp3 -filter:a "volume=1.5" louder.mp3
   ```

3. **Use player-specific options**:
   ```bash
   # For ffplay (modify audio_notifications.sh)
   AUDIO_PLAYER_CMD="ffplay -nodisp -autoexit -loglevel quiet -volume 50"
   ```

---

## Platform-Specific Notes

### Ubuntu/Debian

**Default Setup**:
```bash
sudo apt install ffmpeg
export AUDIO_CONTINUE_PROMPT_SOUND="/path/to/prompt.mp3"
export AUDIO_COMPLETION_SOUND="/path/to/completion.mp3"
```

**Known Issues**: None

### Fedora/RHEL

**Default Setup**:
```bash
sudo dnf install ffmpeg
```

**Known Issues**: ffmpeg may require RPMFusion repository

### Arch Linux

**Default Setup**:
```bash
sudo pacman -S ffmpeg
```

**Known Issues**: None

### macOS

**Default Setup**:
```bash
brew install ffmpeg
```

**Known Issues**: 
- May require Homebrew installation
- System audio permissions prompt on first use

### Windows (WSL2)

**Recommended Setup**:
```bash
# In WSL2
sudo apt install ffmpeg pulseaudio

# Install Windows PulseAudio server
# https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/

# Configure
export PULSE_SERVER=tcp:$(grep nameserver /etc/resolv.conf | awk '{print $2}'):4713
```

**Known Issues**:
- Requires PulseAudio server on Windows host
- May have latency (200-500ms typical)

---

## Advanced Configuration

### Different Sounds Per Event Type

```yaml
# .workflow-config.yaml
audio:
  enabled: true
  sounds:
    continue_prompt: "/sounds/beep.mp3"
    completion: "/sounds/success.mp3"
    error: "/sounds/error.mp3"  # Future feature
    warning: "/sounds/warning.mp3"  # Future feature
```

### Conditional Notifications

```bash
# Enable only for long-running workflows
if [[ $ESTIMATED_DURATION -gt 300 ]]; then
  export AUDIO_NOTIFICATIONS_ENABLED=true
fi
```

### CI/CD Integration

```yaml
# GitHub Actions - disable audio in CI
- name: Run Workflow
  env:
    AUDIO_NOTIFICATIONS_ENABLED: false
  run: ./src/workflow/execute_tests_docs_workflow.sh --auto
```

---

## Testing

### Test Audio Setup

```bash
# Run comprehensive audio test
./scripts/test_audio.sh

# Output:
# ✓ Audio player: ffplay
# ✓ Continue prompt sound: /path/to/prompt.mp3
# ✓ Completion sound: /path/to/completion.mp3
# ✓ Playing test sounds...
# ✓ Audio notifications working
```

### Manual Test

```bash
# Source audio module
source src/workflow/lib/audio_notifications.sh

# Test each notification type
play_notification_sound "continue_prompt"
sleep 2
play_notification_sound "completion"
```

---

## Additional Resources

- **Module Source**: `src/workflow/lib/audio_notifications.sh`
- **Health Check**: `src/workflow/lib/health_check.sh --audio`
- **Configuration**: `.workflow-config.yaml` audio section
- **Troubleshooting**: [User Guide - Troubleshooting](../user-guide/TROUBLESHOOTING.md)

---

## FAQ

**Q: Can I use different sound formats?**  
A: Yes. MP3, WAV, OGG, FLAC are supported (depending on player).

**Q: Do notifications work in auto mode?**  
A: Yes. Completion sound plays, but continue prompt is skipped in `--auto` mode.

**Q: Can I disable notifications temporarily?**  
A: Yes. `AUDIO_NOTIFICATIONS_ENABLED=false ./execute_tests_docs_workflow.sh`

**Q: Do notifications work in CI/CD?**  
A: Technically yes, but recommended to disable: `export AUDIO_NOTIFICATIONS_ENABLED=false`

**Q: How do I create custom sounds?**  
A: Use ffmpeg: `ffmpeg -f lavfi -i "sine=frequency=1000:duration=1" beep.mp3`

**Q: Is there a volume control?**  
A: Use system volume or adjust files with ffmpeg volume filter.

---

**Last Updated**: 2026-02-09  
**Version**: 4.0.1  
**Feature**: Audio Notifications (v3.1.0)
