#!/bin/bash
set -euo pipefail

################################################################################
# Performance Benchmark Script
# Purpose: Measure and compare performance of optimized vs standard operations
# Part of: Tests & Documentation Workflow Automation v2.0.0
################################################################################

# Source modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/colors.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/performance.sh"

# Test data
TEST_DIR="/tmp/perf_benchmark_$$"
mkdir -p "$TEST_DIR"

# ==============================================================================
# BENCHMARK UTILITIES
# ==============================================================================

benchmark() {
    local name="$1"
    local command="$2"
    local iterations="${3:-10}"
    
    local total_time=0
    local start end duration
    
    for ((i=1; i<=iterations; i++)); do
        start=$(date +%s%N)
        eval "$command" > /dev/null 2>&1
        end=$(date +%s%N)
        duration=$(( (end - start) / 1000000 ))
        total_time=$((total_time + duration))
    done
    
    local avg_time=$((total_time / iterations))
    echo "$name,$avg_time"
}

# ==============================================================================
# BENCHMARKS
# ==============================================================================

benchmark_find_operations() {
    print_header "Find Operations Benchmark"
    
    # Create test files
    mkdir -p "$TEST_DIR/test_find"
    for i in {1..1000}; do
        touch "$TEST_DIR/test_find/file_$i.txt"
    done
    
    # Standard find
    local std_result
    std_result=$(benchmark "Standard find" \
        "find '$TEST_DIR/test_find' -type f -name '*.txt'" 5)
    
    # Optimized find
    local opt_result
    opt_result=$(benchmark "Optimized fast_find" \
        "fast_find '$TEST_DIR/test_find' '*.txt' 3" 5)
    
    # Parse results
    local std_time=$(echo "$std_result" | cut -d',' -f2)
    local opt_time=$(echo "$opt_result" | cut -d',' -f2)
    
    # Calculate improvement
    local improvement=$(echo "scale=2; ($std_time - $opt_time) / $std_time * 100" | bc)
    
    echo ""
    echo -e "${CYAN}Standard find:${NC} ${std_time}ms"
    echo -e "${CYAN}Optimized find:${NC} ${opt_time}ms"
    echo -e "${GREEN}Improvement:${NC} ${improvement}%"
    echo ""
    
    rm -rf "$TEST_DIR/test_find"
}

benchmark_grep_operations() {
    print_header "Grep Operations Benchmark"
    
    # Create test files with content
    mkdir -p "$TEST_DIR/test_grep"
    for i in {1..100}; do
        for j in {1..10}; do
            echo "test pattern $j in file $i" >> "$TEST_DIR/test_grep/file_$i.txt"
        done
    done
    
    # Standard grep
    local std_result
    std_result=$(benchmark "Standard grep" \
        "grep -r 'pattern' '$TEST_DIR/test_grep'" 5)
    
    # Optimized grep
    local opt_result
    opt_result=$(benchmark "Optimized fast_grep" \
        "fast_grep 'pattern' '$TEST_DIR/test_grep' '*.txt'" 5)
    
    # Parse and display
    local std_time=$(echo "$std_result" | cut -d',' -f2)
    local opt_time=$(echo "$opt_result" | cut -d',' -f2)
    local improvement=$(echo "scale=2; ($std_time - $opt_time) / $std_time * 100" | bc)
    
    echo ""
    echo -e "${CYAN}Standard grep:${NC} ${std_time}ms"
    echo -e "${CYAN}Optimized grep:${NC} ${opt_time}ms"
    echo -e "${GREEN}Improvement:${NC} ${improvement}%"
    echo ""
    
    rm -rf "$TEST_DIR/test_grep"
}

benchmark_parallel_execution() {
    print_header "Parallel Execution Benchmark"
    
    # Sequential execution
    local start=$(date +%s%N)
    for i in {1..10}; do
        sleep 0.1
    done
    local end=$(date +%s%N)
    local sequential_time=$(( (end - start) / 1000000 ))
    
    # Parallel execution
    start=$(date +%s%N)
    local commands=()
    for i in {1..10}; do
        commands+=("sleep 0.1")
    done
    parallel_execute 4 "${commands[@]}"
    end=$(date +%s%N)
    local parallel_time=$(( (end - start) / 1000000 ))
    
    local improvement=$(echo "scale=2; ($sequential_time - $parallel_time) / $sequential_time * 100" | bc)
    
    echo ""
    echo -e "${CYAN}Sequential (10 × 100ms):${NC} ${sequential_time}ms"
    echo -e "${CYAN}Parallel (4 jobs):${NC} ${parallel_time}ms"
    echo -e "${GREEN}Improvement:${NC} ${improvement}%"
    echo ""
}

benchmark_caching() {
    print_header "Caching Mechanism Benchmark"
    
    # Expensive operation
    expensive_op() {
        sleep 0.05
        echo "expensive result"
    }
    
    # Without cache
    local start=$(date +%s%N)
    for i in {1..10}; do
        expensive_op > /dev/null
    done
    local end=$(date +%s%N)
    local no_cache_time=$(( (end - start) / 1000000 ))
    
    # With cache
    cache_clear
    start=$(date +%s%N)
    for i in {1..10}; do
        memoize expensive_op > /dev/null
    done
    end=$(date +%s%N)
    local with_cache_time=$(( (end - start) / 1000000 ))
    
    local improvement=$(echo "scale=2; ($no_cache_time - $with_cache_time) / $no_cache_time * 100" | bc)
    
    echo ""
    echo -e "${CYAN}Without cache (10 calls):${NC} ${no_cache_time}ms"
    echo -e "${CYAN}With cache (10 calls):${NC} ${with_cache_time}ms"
    echo -e "${GREEN}Improvement:${NC} ${improvement}%"
    echo ""
}

benchmark_file_counting() {
    print_header "File Counting Benchmark"
    
    # Create test files
    mkdir -p "$TEST_DIR/test_count"
    for i in {1..500}; do
        touch "$TEST_DIR/test_count/file_$i.txt"
    done
    
    # Standard count
    local std_result
    std_result=$(benchmark "Standard count" \
        "find '$TEST_DIR/test_count' -type f | wc -l" 10)
    
    # Optimized count
    local opt_result
    opt_result=$(benchmark "Optimized count" \
        "fast_file_count '$TEST_DIR/test_count'" 10)
    
    local std_time=$(echo "$std_result" | cut -d',' -f2)
    local opt_time=$(echo "$opt_result" | cut -d',' -f2)
    local improvement=$(echo "scale=2; ($std_time - $opt_time) / $std_time * 100" | bc)
    
    echo ""
    echo -e "${CYAN}Standard count:${NC} ${std_time}ms"
    echo -e "${CYAN}Optimized count:${NC} ${opt_time}ms"
    echo -e "${GREEN}Improvement:${NC} ${improvement}%"
    echo ""
    
    rm -rf "$TEST_DIR/test_count"
}

# ==============================================================================
# MAIN BENCHMARK SUITE
# ==============================================================================

main() {
    print_header "Performance Benchmark Suite"
    echo -e "${CYAN}Testing optimizations vs standard operations${NC}\n"
    
    benchmark_find_operations
    benchmark_grep_operations
    benchmark_parallel_execution
    benchmark_caching
    benchmark_file_counting
    
    # Cleanup
    rm -rf "$TEST_DIR"
    cache_clear
    
    print_header "Benchmark Complete"
    print_success "All benchmarks completed"
    
    echo ""
    echo -e "${YELLOW}Note:${NC} Actual performance gains vary by system and workload"
    echo -e "${YELLOW}Tip:${NC} Use 'profile_section' in workflows to identify bottlenecks"
    echo ""
}

main "$@"
