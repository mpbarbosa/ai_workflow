#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Audio Notifications Module
# Version: 3.1.1
# Purpose: Provide audio notification support for workflow events
#
# Features:
#   - Configurable audio notifications
#   - Multiple audio player support (ffplay, aplay, mpg123, paplay)
#   - Graceful degradation if audio unavailable
#   - Non-blocking async playback
#   - Integration with AUTO_MODE
#
# Usage:
#   source audio_notifications.sh
#   play_notification_sound "continue_prompt"
#   play_notification_sound "completion"
################################################################################

# Set defaults
WORKFLOW_HOME=${WORKFLOW_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

# Source required modules
source "${WORKFLOW_HOME}/src/workflow/lib/colors.sh" 2>/dev/null || true

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Audio notifications enabled/disabled
AUDIO_NOTIFICATIONS_ENABLED=${AUDIO_NOTIFICATIONS_ENABLED:-true}

# Default sound file paths
AUDIO_CONTINUE_PROMPT_SOUND=${AUDIO_CONTINUE_PROMPT_SOUND:-"/home/mpb/Downloads/emircanalp-beep-125033.mp3"}
AUDIO_COMPLETION_SOUND=${AUDIO_COMPLETION_SOUND:-"/home/mpb/Downloads/freesound_community-beep-beep-beep-beep-80262.mp3"}

# Detected audio player command
AUDIO_PLAYER_CMD=""

# ==============================================================================
# AUDIO PLAYER DETECTION
# ==============================================================================

# Detect available audio playback tools
# Returns: 0 if audio player found, 1 otherwise
# Sets: AUDIO_PLAYER_CMD to the command to use
detect_audio_player() {
    # Skip detection if already done
    if [[ -n "$AUDIO_PLAYER_CMD" ]]; then
        return 0
    fi
    
    # Try ffplay first (best MP3 support, cross-platform)
    if command -v ffplay >/dev/null 2>&1; then
        AUDIO_PLAYER_CMD="ffplay -nodisp -autoexit -loglevel quiet"
        return 0
    fi
    
    # Try mpg123 (MP3-specific, good support)
    if command -v mpg123 >/dev/null 2>&1; then
        AUDIO_PLAYER_CMD="mpg123 -q"
        return 0
    fi
    
    # Try paplay (PulseAudio, may need format conversion)
    if command -v paplay >/dev/null 2>&1; then
        AUDIO_PLAYER_CMD="paplay"
        return 0
    fi
    
    # Try aplay (ALSA, requires WAV or manual conversion)
    if command -v aplay >/dev/null 2>&1; then
        AUDIO_PLAYER_CMD="aplay -q"
        return 0
    fi
    
    # No audio player found
    return 1
}

# ==============================================================================
# AUDIO PLAYBACK
# ==============================================================================

# Play audio notification sound
# Args:
#   $1 - notification type: "continue_prompt" or "completion"
# Returns: 0 on success, 1 on error (non-fatal)
play_notification_sound() {
    local notification_type="${1:-}"
    
    # Validate notification type
    if [[ "$notification_type" != "continue_prompt" && "$notification_type" != "completion" ]]; then
        print_warning "Invalid notification type: $notification_type" 2>/dev/null || echo "Warning: Invalid notification type" >&2
        return 1
    fi
    
    # Skip if notifications disabled
    if [[ "$AUDIO_NOTIFICATIONS_ENABLED" != "true" ]]; then
        return 0
    fi
    
    # Skip in AUTO_MODE
    if [[ "${AUTO_MODE:-false}" == "true" ]]; then
        return 0
    fi
    
    # Detect audio player if not already done
    if ! detect_audio_player; then
        print_warning "No audio player found (tried: ffplay, mpg123, paplay, aplay). Skipping sound notification." 2>/dev/null || \
            echo "Warning: No audio player found. Skipping sound notification." >&2
        return 1
    fi
    
    # Select sound file based on notification type
    local sound_file=""
    case "$notification_type" in
        continue_prompt)
            sound_file="$AUDIO_CONTINUE_PROMPT_SOUND"
            ;;
        completion)
            sound_file="$AUDIO_COMPLETION_SOUND"
            ;;
    esac
    
    # Verify sound file exists
    if [[ ! -f "$sound_file" ]]; then
        print_warning "Sound file not found: $sound_file. Skipping notification." 2>/dev/null || \
            echo "Warning: Sound file not found: $sound_file" >&2
        return 1
    fi
    
    # Play sound in background (non-blocking)
    # Redirect output to /dev/null to avoid cluttering terminal
    # Use nohup to prevent termination signals
    (nohup $AUDIO_PLAYER_CMD "$sound_file" >/dev/null 2>&1 &)
    
    return 0
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Check if audio notifications are available
# Returns: 0 if available, 1 otherwise
is_audio_available() {
    if [[ "$AUDIO_NOTIFICATIONS_ENABLED" != "true" ]]; then
        return 1
    fi
    
    if [[ "${AUTO_MODE:-false}" == "true" ]]; then
        return 1
    fi
    
    if ! detect_audio_player; then
        return 1
    fi
    
    return 0
}

# Get current audio configuration status
# Prints configuration details to stdout
show_audio_config() {
    echo "Audio Notifications Configuration:"
    echo "  Enabled: $AUDIO_NOTIFICATIONS_ENABLED"
    echo "  AUTO_MODE: ${AUTO_MODE:-false}"
    echo "  Continue Prompt Sound: $AUDIO_CONTINUE_PROMPT_SOUND"
    echo "  Completion Sound: $AUDIO_COMPLETION_SOUND"
    
    if detect_audio_player; then
        echo "  Audio Player: $AUDIO_PLAYER_CMD"
    else
        echo "  Audio Player: None detected"
    fi
}

# ==============================================================================
# EXPORTS
# ==============================================================================

export -f detect_audio_player
export -f play_notification_sound
export -f is_audio_available
export -f show_audio_config
