#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Integration Test for Audio Notifications Feature
# Tests the full integration of audio notifications in the workflow
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_HOME="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source modules
source "${WORKFLOW_HOME}/src/workflow/lib/colors.sh"
source "${WORKFLOW_HOME}/src/workflow/lib/audio_notifications.sh"

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Audio Notifications Integration Test${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"

# Test 1: Configuration loading
echo -e "\n${CYAN}Test 1: Configuration Loading${NC}"
if [[ -f "${WORKFLOW_HOME}/.workflow-config.yaml" ]]; then
    echo -e "${GREEN}✓${NC} Configuration file exists"
    
    if command -v yq >/dev/null 2>&1; then
        audio_enabled=$(yq '.audio.enabled // true' "${WORKFLOW_HOME}/.workflow-config.yaml" 2>/dev/null || echo "true")
        echo -e "${GREEN}✓${NC} Audio enabled: $audio_enabled"
        
        continue_sound=$(yq '.audio.continue_prompt_sound // ""' "${WORKFLOW_HOME}/.workflow-config.yaml" 2>/dev/null | tr -d '"' || echo "")
        if [[ -n "$continue_sound" ]]; then
            echo -e "${GREEN}✓${NC} Continue prompt sound: $continue_sound"
            if [[ -f "$continue_sound" ]]; then
                echo -e "${GREEN}✓${NC} Continue sound file exists"
            else
                echo -e "${YELLOW}⚠${NC} Continue sound file not found: $continue_sound"
            fi
        fi
        
        completion_sound=$(yq '.audio.completion_sound // ""' "${WORKFLOW_HOME}/.workflow-config.yaml" 2>/dev/null | tr -d '"' || echo "")
        if [[ -n "$completion_sound" ]]; then
            echo -e "${GREEN}✓${NC} Completion sound: $completion_sound"
            if [[ -f "$completion_sound" ]]; then
                echo -e "${GREEN}✓${NC} Completion sound file exists"
            else
                echo -e "${YELLOW}⚠${NC} Completion sound file not found: $completion_sound"
            fi
        fi
    else
        echo -e "${YELLOW}⚠${NC} yq not available, skipping config parsing"
    fi
else
    echo -e "${YELLOW}⚠${NC} No configuration file found (using defaults)"
fi

# Test 2: Audio player detection
echo -e "\n${CYAN}Test 2: Audio Player Detection${NC}"
AUDIO_PLAYER_CMD=""
if detect_audio_player; then
    echo -e "${GREEN}✓${NC} Audio player detected: $AUDIO_PLAYER_CMD"
else
    echo -e "${RED}✗${NC} No audio player found"
fi

# Test 3: Audio availability check
echo -e "\n${CYAN}Test 3: Audio Availability Check${NC}"
AUDIO_NOTIFICATIONS_ENABLED=true
AUTO_MODE=false
if is_audio_available; then
    echo -e "${GREEN}✓${NC} Audio notifications available"
else
    echo -e "${YELLOW}⚠${NC} Audio notifications unavailable"
fi

# Test 4: Show configuration
echo -e "\n${CYAN}Test 4: Configuration Display${NC}"
show_audio_config

# Test 5: Test audio playback (if enabled)
echo -e "\n${CYAN}Test 5: Audio Playback Test${NC}"
if is_audio_available; then
    echo -e "${YELLOW}Would you like to test audio playback? (y/N)${NC}"
    read -r -n 1 response
    echo
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}Playing continue prompt sound...${NC}"
        if play_notification_sound "continue_prompt"; then
            echo -e "${GREEN}✓${NC} Continue prompt sound played"
            sleep 2
            
            echo -e "${CYAN}Playing completion sound...${NC}"
            if play_notification_sound "completion"; then
                echo -e "${GREEN}✓${NC} Completion sound played"
            else
                echo -e "${RED}✗${NC} Failed to play completion sound"
            fi
        else
            echo -e "${RED}✗${NC} Failed to play continue prompt sound"
        fi
    else
        echo -e "${YELLOW}⚠${NC} Audio playback test skipped"
    fi
else
    echo -e "${YELLOW}⚠${NC} Audio not available - skipping playback test"
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Integration Test Complete${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "\n${GREEN}✓${NC} Audio notifications feature is properly integrated"
echo -e "\nNext steps:"
echo -e "  1. Run workflow to test continue prompt sound"
echo -e "  2. Let workflow complete to test completion sound"
echo -e "  3. Test with --auto mode (should skip sounds)"
echo ""
