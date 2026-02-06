#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Audio Notifications Module Tests
# Version: 3.1.1
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source modules
source "${WORKFLOW_HOME}/src/workflow/lib/colors.sh"
source "${WORKFLOW_HOME}/src/workflow/lib/audio_notifications.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# TEST HELPERS
# ==============================================================================

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} $message"
        echo -e "  Expected: $expected"
        echo -e "  Actual: $actual"
        return 1
    fi
}

assert_success() {
    local message="$1"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} $message"
}

assert_failure() {
    local message="$1"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} $message"
}

# ==============================================================================
# TESTS
# ==============================================================================

test_detect_audio_player() {
    echo -e "\n${BLUE}Testing: detect_audio_player${NC}"
    
    # Reset player
    AUDIO_PLAYER_CMD=""
    
    if detect_audio_player; then
        assert_success "Should detect audio player"
        if [[ -n "$AUDIO_PLAYER_CMD" ]]; then
            assert_success "Should set AUDIO_PLAYER_CMD"
            echo "  Detected: $AUDIO_PLAYER_CMD"
        else
            assert_failure "Should set AUDIO_PLAYER_CMD variable"
        fi
    else
        echo -e "${YELLOW}⚠${NC} No audio player detected (expected on some systems)"
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
}

test_is_audio_available() {
    echo -e "\n${BLUE}Testing: is_audio_available${NC}"
    
    # Test with notifications enabled
    AUDIO_NOTIFICATIONS_ENABLED=true
    AUTO_MODE=false
    AUDIO_PLAYER_CMD=""
    
    if detect_audio_player; then
        if is_audio_available; then
            assert_success "Should be available when enabled and player found"
        else
            assert_failure "Should be available when enabled and player found"
        fi
    else
        if ! is_audio_available; then
            assert_success "Should be unavailable when no player found"
        else
            assert_failure "Should be unavailable when no player found"
        fi
    fi
    
    # Test with notifications disabled
    AUDIO_NOTIFICATIONS_ENABLED=false
    if ! is_audio_available; then
        assert_success "Should be unavailable when disabled"
    else
        assert_failure "Should be unavailable when disabled"
    fi
    
    # Test in AUTO_MODE
    AUDIO_NOTIFICATIONS_ENABLED=true
    AUTO_MODE=true
    if ! is_audio_available; then
        assert_success "Should be unavailable in AUTO_MODE"
    else
        assert_failure "Should be unavailable in AUTO_MODE"
    fi
}

test_play_notification_invalid_type() {
    echo -e "\n${BLUE}Testing: play_notification_sound with invalid type${NC}"
    
    AUDIO_NOTIFICATIONS_ENABLED=true
    AUTO_MODE=false
    
    if ! play_notification_sound "invalid_type" 2>/dev/null; then
        assert_success "Should reject invalid notification type"
    else
        assert_failure "Should reject invalid notification type"
    fi
}

test_play_notification_disabled() {
    echo -e "\n${BLUE}Testing: play_notification_sound when disabled${NC}"
    
    AUDIO_NOTIFICATIONS_ENABLED=false
    AUTO_MODE=false
    
    if play_notification_sound "continue_prompt" 2>/dev/null; then
        assert_success "Should skip when disabled (return success)"
    else
        assert_failure "Should skip when disabled (return success)"
    fi
}

test_play_notification_auto_mode() {
    echo -e "\n${BLUE}Testing: play_notification_sound in AUTO_MODE${NC}"
    
    AUDIO_NOTIFICATIONS_ENABLED=true
    AUTO_MODE=true
    
    if play_notification_sound "continue_prompt" 2>/dev/null; then
        assert_success "Should skip in AUTO_MODE (return success)"
    else
        assert_failure "Should skip in AUTO_MODE (return success)"
    fi
}

test_play_notification_missing_file() {
    echo -e "\n${BLUE}Testing: play_notification_sound with missing file${NC}"
    
    AUDIO_NOTIFICATIONS_ENABLED=true
    AUTO_MODE=false
    AUDIO_CONTINUE_PROMPT_SOUND="/nonexistent/file.mp3"
    
    # Reset to force redetection
    AUDIO_PLAYER_CMD=""
    
    if ! play_notification_sound "continue_prompt" 2>/dev/null; then
        assert_success "Should fail gracefully with missing file"
    else
        assert_failure "Should fail gracefully with missing file"
    fi
    
    # Restore default
    AUDIO_CONTINUE_PROMPT_SOUND="/home/mpb/Downloads/emircanalp-beep-125033.mp3"
}

test_show_audio_config() {
    echo -e "\n${BLUE}Testing: show_audio_config${NC}"
    
    local output
    output=$(show_audio_config 2>&1)
    
    if [[ -n "$output" ]]; then
        assert_success "Should display configuration"
        echo "  Output:"
        echo "$output" | sed 's/^/    /'
    else
        assert_failure "Should display configuration"
    fi
}

# ==============================================================================
# RUN ALL TESTS
# ==============================================================================

main() {
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Audio Notifications Module Tests${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    
    test_detect_audio_player
    test_is_audio_available
    test_play_notification_invalid_type
    test_play_notification_disabled
    test_play_notification_auto_mode
    test_play_notification_missing_file
    test_show_audio_config
    
    # Summary
    echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Test Results${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All tests passed!${NC}\n"
        return 0
    else
        echo -e "\n${RED}✗ Some tests failed${NC}\n"
        return 1
    fi
}

main "$@"
