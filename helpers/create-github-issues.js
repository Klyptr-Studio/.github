#!/usr/bin/env node

/**
 * Klyptr Studio - GitHub Issues & Labels Creator (IDEMPOTENT)
 * 
 * This version:
 * 1. Checks if issues already exist (by title) before creating
 * 2. Creates labels with proper error handling
 * 3. Only creates new issues
 * 4. Safe to run multiple times
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// ============================================================================
// Logging & Colors
// ============================================================================

const COLORS = {
    RESET: '\x1b[0m',
    BRIGHT: '\x1b[1m',
    RED: '\x1b[31m',
    GREEN: '\x1b[32m',
    YELLOW: '\x1b[33m',
    BLUE: '\x1b[34m',
    CYAN: '\x1b[36m',
};

const log = {
    info: (msg) => console.log(`${COLORS.BLUE}[INFO]${COLORS.RESET} ${msg}`),
    success: (msg) => console.log(`${COLORS.GREEN}[SUCCESS]${COLORS.RESET} ${msg}`),
    error: (msg) => console.log(`${COLORS.RED}[ERROR]${COLORS.RESET} ${msg}`),
    warning: (msg) => console.log(`${COLORS.YELLOW}[WARNING]${COLORS.RESET} ${msg}`),
    skipped: (msg) => console.log(`${COLORS.CYAN}[SKIPPED]${COLORS.RESET} ${msg}`),
    section: (msg) => {
        console.log(`\n${COLORS.BLUE}${'═'.repeat(50)}${COLORS.RESET}`);
        console.log(`${COLORS.BLUE}${COLORS.BRIGHT}${msg}${COLORS.RESET}`);
        console.log(`${COLORS.BLUE}${'═'.repeat(50)}${COLORS.RESET}\n`);
    },
    debug: (msg) => {
        if (process.env.DEBUG === '1') {
            console.log(`${COLORS.CYAN}[DEBUG]${COLORS.RESET} ${msg}`);
        }
    },
};

// ============================================================================
// Statistics Tracker
// ============================================================================

class Stats {
    constructor() {
        this.labelsCreated = 0;
        this.labelsSkipped = 0;
        this.labelsFailed = 0;
        this.issuesCreated = 0;
        this.issuesSkipped = 0;
        this.issuesFailed = 0;
        this.servicesProcessed = 0;
        this.servicesFailed = 0;
        this.errors = [];
    }

    addError(service, issue, error) {
        this.errors.push({
            service,
            issue: issue || 'N/A',
            error: error.toString(),
        });
    }

    report() {
        log.section('FINAL SUMMARY REPORT');
        console.log(`Services Processed: ${this.servicesProcessed}`);
        console.log(`Services Failed: ${this.servicesFailed}`);
        console.log(`\nLabels:`);
        console.log(`  Created: ${this.labelsCreated}`);
        console.log(`  Skipped: ${this.labelsSkipped}`);
        console.log(`  Failed: ${this.labelsFailed}`);
        console.log(`\nIssues:`);
        console.log(`  Created: ${this.issuesCreated}`);
        console.log(`  Skipped: ${this.issuesSkipped}`);
        console.log(`  Failed: ${this.issuesFailed}`);

        if (this.errors.length > 0) {
            console.log(`\n${COLORS.RED}Errors Encountered:${COLORS.RESET}`);
            this.errors.forEach((err, idx) => {
                console.log(`  ${idx + 1}. [${err.service}] ${err.issue}`);
                console.log(`     → ${err.error}`);
            });
        }

        const totalFailed = this.labelsFailed + this.issuesFailed + this.servicesFailed;
        if (totalFailed === 0) {
            log.success('All operations completed successfully!');
            return true;
        } else {
            log.warning(`${totalFailed} operation(s) failed. See details above.`);
            return false;
        }
    }
}

// ============================================================================
// Configuration & Validation
// ============================================================================

function validateConfigFile(filePath) {
    log.info(`Validating configuration file: ${filePath}`);

    if (!fs.existsSync(filePath)) {
        throw new Error(`Configuration file not found: ${filePath}`);
    }

    try {
        const config = JSON.parse(fs.readFileSync(filePath, 'utf8'));

        if (!config.organization) {
            throw new Error('Missing "organization" field in configuration');
        }
        if (!Array.isArray(config.services) || config.services.length === 0) {
            throw new Error('Missing or empty "services" array in configuration');
        }
        if (!Array.isArray(config.labels) || config.labels.length === 0) {
            throw new Error('Missing or empty "labels" array in configuration');
        }

        log.success(`Configuration valid. Found ${config.services.length} services and ${config.labels.length} labels`);
        return config;
    } catch (err) {
        throw new Error(`Invalid configuration file: ${err.message}`);
    }
}

function validateGitHubAuth() {
    log.info('Validating GitHub authentication');

    try {
        execSync('gh auth status', { stdio: 'pipe' });
        log.success('GitHub CLI authenticated');
        return true;
    } catch (err) {
        throw new Error('GitHub CLI not authenticated. Run "gh auth login" first.');
    }
}

// ============================================================================
// GitHub Operations (IDEMPOTENT)
// ============================================================================

/**
 * Check if issue with same title already exists in repository
 */
function issueExists(org, repo, title) {
    try {
        const output = execSync(
            `gh issue list --repo "${org}/${repo}" --state all --json title`,
            { stdio: 'pipe' }
        ).toString();
        const issues = JSON.parse(output);
        return issues.some(issue => issue.title === title);
    } catch {
        return false;
    }
}

/**
 * Check if label exists in repository
 */
function labelExists(org, repo, labelName) {
    try {
        const output = execSync(
            `gh label list --repo "${org}/${repo}" --json name`,
            { stdio: 'pipe' }
        ).toString();
        const labels = JSON.parse(output);
        return labels.some(label => label.name === labelName);
    } catch {
        return false;
    }
}

/**
 * Create label in a specific repository (with deduplication)
 */
function createLabelInRepository(org, repo, labelName, description, color, stats) {
    log.debug(`Creating label in ${org}/${repo}: ${labelName}`);

    try {
        // Check if label already exists
        if (labelExists(org, repo, labelName)) {
            log.debug(`Label already exists: ${labelName}`);
            stats.labelsSkipped++;
            return true;
        }

        // Create label
        const cmd = `gh label create "${labelName}" --repo "${org}/${repo}" --description "${description}" --color "${color}"`;
        execSync(cmd, { stdio: 'pipe' });
        log.debug(`Label created: ${labelName}`);
        stats.labelsCreated++;
        return true;
    } catch (err) {
        log.warning(`Failed to create label ${labelName} in ${org}/${repo}: ${err.message}`);
        stats.labelsFailed++;
        return false;
    }
}

/**
 * Create issue in a repository (with deduplication)
 */
function createIssue(org, repo, title, body, labels) {
    log.debug(`Creating issue in ${org}/${repo}: ${title}`);

    try {
        // Check if issue already exists
        if (issueExists(org, repo, title)) {
            log.debug(`Issue already exists: ${title}`);
            return 'skipped';
        }

        // Build label arguments: --label "phase-1" --label "type:feature" --label "priority:high"
        const labelArgs = labels.map(label => `--label "${label}"`).join(' ');
        const cmd = `gh issue create --repo "${org}/${repo}" --title "${title}" --body "${body}" ${labelArgs}`;

        execSync(cmd, { stdio: 'pipe' });
        log.debug(`Issue created: ${title}`);
        return 'created';
    } catch (err) {
        log.warning(`Failed to create issue "${title}" in ${org}/${repo}`);
        throw err;
    }
}

// ============================================================================
// Main Processing
// ============================================================================

/**
 * Create labels for a repository
 */
function createLabelsForService(org, repo, labels, stats) {
    log.info(`Creating labels in ${org}/${repo}...`);

    labels.forEach((label) => {
        createLabelInRepository(org, repo, label.name, label.description, label.color, stats);
    });
}

function createIssuesForService(org, service, labels, stats) {
    const serviceTitle = `${service.repository}`;
    log.section(`PROCESSING SERVICE: ${serviceTitle}`);

    log.info(`Repository: ${org}/${service.repository}`);
    log.info(`Phase: ${service.phase}`);
    log.info(`Issues to create: ${service.issues.length}`);

    if (!service.issues || service.issues.length === 0) {
        log.warning(`No issues defined for ${service.name}`);
        return;
    }

    // STEP 1: Create labels for this repository
    log.info(`Creating labels for ${service.repository}...`);
    createLabelsForService(org, service.repository, labels, stats);

    // STEP 2: Create issues
    service.issues.forEach((issue, idx) => {
        const issueNum = idx + 1;
        log.info(`[${issueNum}/${service.issues.length}] Creating issue: ${issue.title}`);

        try {
            // Build labels array
            const issueLabels = [
                service.phase,
                issue.type,
                issue.priority,
            ].filter(Boolean);

            // Format body
            const body = `${issue.description}\n\n---\n*Auto-generated by Klyptr Studio issue creator*`;

            // Create issue (with deduplication)
            const result = createIssue(org, service.repository, issue.title, body, issueLabels);

            if (result === 'created') {
                stats.issuesCreated++;
                log.success(`Issue created: ${issue.title}`);
            } else if (result === 'skipped') {
                stats.issuesSkipped++;
                log.skipped(`Issue already exists: ${issue.title}`);
            }
        } catch (err) {
            stats.issuesFailed++;
            stats.addError(service.name, issue.title, err);
            log.error(`Failed to create issue: ${issue.title}`);
        }
    });
}

function processServices(org, services, labels, stats) {
    log.section(`CREATING ISSUES & LABELS IN REPOSITORIES`);
    log.info(`Total services to process: ${services.length}`);

    services.forEach((service, idx) => {
        log.info(`\n[${idx + 1}/${services.length}] Processing ${service.name}...`);

        try {
            createIssuesForService(org, service, labels, stats);
            stats.servicesProcessed++;
        } catch (err) {
            stats.servicesFailed++;
            stats.addError(service.name, 'Service Processing', err);
            log.error(`Failed to process ${service.name}: ${err.message}`);
        }
    });
}

// ============================================================================
// Main Execution
// ============================================================================

async function main() {
    const configFile = process.argv[2];

    if (!configFile) {
        log.error('Usage: node create-github-issues.js <config-file>');
        process.exit(1);
    }

    const stats = new Stats();

    try {
        log.section('GITHUB ISSUES & LABELS CREATOR (IDEMPOTENT)');
        log.info(`Start Time: ${new Date().toISOString()}`);

        // Step 1: Validation
        log.section('STEP 1: VALIDATION');
        const config = validateConfigFile(configFile);
        validateGitHubAuth();

        // Step 2: Create issues & labels
        log.section('STEP 2: CREATE ISSUES & LABELS (Idempotent)');
        processServices(config.organization, config.services, config.labels, stats);

        // Step 3: Report
        log.info(`End Time: ${new Date().toISOString()}`);
        const success = stats.report();

        process.exit(success ? 0 : 1);
    } catch (err) {
        log.error(`Fatal Error: ${err.message}`);
        log.error('Execution failed. Please check configuration and GitHub authentication.');
        process.exit(1);
    }
}

main().catch((err) => {
    log.error(`Unexpected error: ${err.message}`);
    process.exit(1);
});