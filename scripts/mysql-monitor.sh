#!/bin/bash

# =============================================================================
# MySQL Performance Monitoring Script
# =============================================================================
# This script provides various MySQL monitoring capabilities including:
# - Slow query analysis
# - Performance statistics
# - Connection monitoring
# - Table statistics
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# MySQL connection details
MYSQL_CONTAINER="mysql"
MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASS="root_secret"
SLOW_LOG_PATH="storage/logs/mysql/mysql-slow.log"

# Function to print section headers
print_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} $1"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to execute MySQL query
mysql_exec() {
    docker compose -f compose.dev.yaml exec -T ${MYSQL_CONTAINER} \
        mysql -u ${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASS} -e "$1" 2>/dev/null
}

# Function to display slow query log
show_slow_queries() {
    print_header "Slow Query Log (Last 50 entries)"

    if [ ! -f "${SLOW_LOG_PATH}" ]; then
        echo -e "${YELLOW}⚠️  Slow query log file not found at: ${SLOW_LOG_PATH}${NC}"
        echo -e "${YELLOW}    The log will be created once the first slow query occurs.${NC}"
        return
    fi

    if [ ! -s "${SLOW_LOG_PATH}" ]; then
        echo -e "${GREEN}✅ No slow queries detected yet!${NC}"
        return
    fi

    echo -e "${YELLOW}Displaying last 50 lines of slow query log:${NC}"
    echo ""
    tail -n 50 "${SLOW_LOG_PATH}"
}

# Function to analyze slow queries with Performance Schema
analyze_performance() {
    print_header "Top 10 Slowest Queries (Performance Schema)"

    echo -e "${BLUE}Query Performance Analysis:${NC}"
    echo ""

    mysql_exec "
        SELECT
            LEFT(DIGEST_TEXT, 100) as query_sample,
            COUNT_STAR as exec_count,
            ROUND(AVG_TIMER_WAIT/1000000000000, 3) as avg_time_sec,
            ROUND(MAX_TIMER_WAIT/1000000000000, 3) as max_time_sec,
            ROUND(SUM_TIMER_WAIT/1000000000000, 3) as total_time_sec,
            ROUND(SUM_ROWS_EXAMINED/COUNT_STAR, 0) as avg_rows_examined
        FROM performance_schema.events_statements_summary_by_digest
        WHERE DIGEST_TEXT IS NOT NULL
          AND SCHEMA_NAME = 'laravel'
        ORDER BY SUM_TIMER_WAIT DESC
        LIMIT 10;
    "
}

# Function to show connection statistics
show_connections() {
    print_header "Connection Statistics"

    echo -e "${BLUE}Current Connections:${NC}"
    mysql_exec "
        SELECT
            SUBSTRING_INDEX(host, ':', 1) as host,
            db as database_name,
            user,
            command,
            time,
            state,
            LEFT(info, 50) as query_sample
        FROM information_schema.processlist
        WHERE user != 'event_scheduler'
        ORDER BY time DESC;
    "

    echo ""
    echo -e "${BLUE}Connection Summary:${NC}"
    mysql_exec "
        SELECT
            variable_name,
            variable_value
        FROM performance_schema.global_status
        WHERE variable_name IN (
            'Threads_connected',
            'Threads_running',
            'Max_used_connections',
            'Aborted_connects',
            'Connections'
        )
        ORDER BY variable_name;
    "
}

# Function to show table statistics
show_table_stats() {
    print_header "Table Statistics (Laravel Database)"

    echo -e "${BLUE}Table Sizes and Row Counts:${NC}"
    mysql_exec "
        SELECT
            table_name,
            table_rows as row_count,
            ROUND(data_length / 1024 / 1024, 2) as data_size_mb,
            ROUND(index_length / 1024 / 1024, 2) as index_size_mb,
            ROUND((data_length + index_length) / 1024 / 1024, 2) as total_size_mb,
            engine
        FROM information_schema.tables
        WHERE table_schema = 'laravel'
        ORDER BY (data_length + index_length) DESC;
    "
}

# Function to show InnoDB statistics
show_innodb_stats() {
    print_header "InnoDB Buffer Pool Statistics"

    echo -e "${BLUE}Buffer Pool Usage:${NC}"
    mysql_exec "
        SELECT
            variable_name,
            variable_value
        FROM performance_schema.global_status
        WHERE variable_name IN (
            'Innodb_buffer_pool_pages_total',
            'Innodb_buffer_pool_pages_free',
            'Innodb_buffer_pool_pages_data',
            'Innodb_buffer_pool_pages_dirty',
            'Innodb_buffer_pool_read_requests',
            'Innodb_buffer_pool_reads'
        )
        ORDER BY variable_name;
    "
}

# Function to show queries not using indexes
show_queries_no_index() {
    print_header "Queries Not Using Indexes"

    echo -e "${BLUE}Recent queries that performed full table scans:${NC}"
    echo ""

    mysql_exec "
        SELECT
            LEFT(DIGEST_TEXT, 100) as query_sample,
            COUNT_STAR as exec_count,
            SUM_NO_INDEX_USED as no_index_count,
            SUM_NO_GOOD_INDEX_USED as bad_index_count,
            ROUND(AVG_TIMER_WAIT/1000000000000, 3) as avg_time_sec
        FROM performance_schema.events_statements_summary_by_digest
        WHERE SUM_NO_INDEX_USED > 0
          OR SUM_NO_GOOD_INDEX_USED > 0
        ORDER BY SUM_NO_INDEX_USED DESC
        LIMIT 10;
    "
}

# Function to display help
show_help() {
    echo -e "${GREEN}MySQL Performance Monitoring Script${NC}"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  slow        - Show slow query log"
    echo "  perf        - Analyze query performance (Performance Schema)"
    echo "  conn        - Show connection statistics"
    echo "  tables      - Show table statistics"
    echo "  innodb      - Show InnoDB buffer pool statistics"
    echo "  noindex     - Show queries not using indexes"
    echo "  all         - Run all monitoring reports"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 slow           # View slow query log"
    echo "  $0 perf           # View performance statistics"
    echo "  $0 all            # Run all reports"
}

# Main script logic
case "${1:-all}" in
    slow)
        show_slow_queries
        ;;
    perf)
        analyze_performance
        ;;
    conn)
        show_connections
        ;;
    tables)
        show_table_stats
        ;;
    innodb)
        show_innodb_stats
        ;;
    noindex)
        show_queries_no_index
        ;;
    all)
        show_slow_queries
        echo ""
        analyze_performance
        echo ""
        show_queries_no_index
        echo ""
        show_connections
        echo ""
        show_table_stats
        echo ""
        show_innodb_stats
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown option '${1}'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Monitoring complete${NC}"
