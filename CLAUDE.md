# xciter

Citation utility functions for R, used in dynamic reporting —
particularly within tables where normal Pandoc/Quarto citation rendering
does not work.

## Repository Context

**Repository:** NewGraphEnvironment/xciter **Primary Language:** R
(package) **License:** MIT

## Architecture

    R/                         # Exported functions (xct_* prefix)
      xciter-package.R         # Package-level docs
      xct_keys_extract.R       # Extract citation keys from text or data frame columns
      xct_keys_to_inline.R     # Convert @keys to inline citations via Pandoc
      xct_keys_to_inline_table_col.R  # Apply inline conversion to a data frame column
      xct_bib_clean.R          # Clean .bib files, find missing keys, guess matches
    inst/extdata/              # Bundled data
      NewGraphEnvironment.bib  # Zotero library export
      references.bib           # Example .bib for tests/examples
    inst/deactivated/          # Archived code (removed RefManageR dependency)
    tests/testthat/            # testthat v3 tests

## Key Patterns

- All exported functions use the `xct_` prefix
- External citation processing delegates to Pandoc via
  [`processx::run()`](http://processx.r-lib.org/reference/run.md)
- Input validation uses `chk` package; user messaging uses `cli`
- Fuzzy key matching uses `stringdist` for suggesting corrections to
  missing citation keys

## Dependencies

- **chk** — input validation
- **processx** — shell out to Pandoc
- **cli** — user-facing messages and warnings
- **fs** — file operations
- **stringr** — regex extraction of citation keys
- **stringdist** — fuzzy matching for missing keys
- **xml2** — (imported, used minimally)

## Development

- `devtools::test()` to run tests
- `devtools::document()` to regenerate NAMESPACE/man
- `devtools::check()` for full R CMD check

------------------------------------------------------------------------

# LLM Behavioral Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with
project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For
trivial tasks, use judgment.

## 1. Think Before Coding

**Don’t assume. Don’t hide confusion. Surface tradeoffs.**

Before implementing: - State your assumptions explicitly. If uncertain,
ask. - If multiple interpretations exist, present them - don’t pick
silently. - If a simpler approach exists, say so. Push back when
warranted. - If something is unclear, stop. Name what’s confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No “flexibility” or “configurability” that wasn’t requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: “Would a senior engineer say this is overcomplicated?” If
yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code: - Don’t “improve” adjacent code, comments,
or formatting. - Don’t refactor things that aren’t broken. - Match
existing style, even if you’d do it differently. - If you notice
unrelated dead code, mention it - don’t delete it.

When your changes create orphans: - Remove imports/variables/functions
that YOUR changes made unused. - Don’t remove pre-existing dead code
unless asked.

The test: Every changed line should trace directly to the user’s
request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals: - “Add validation” → “Write tests
for invalid inputs, then make them pass” - “Fix the bug” → “Write a test
that reproduces it, then make it pass” - “Refactor X” → “Ensure tests
pass before and after”

For multi-step tasks, state a brief plan:

    1. [Step] → verify: [check]
    2. [Step] → verify: [check]
    3. [Step] → verify: [check]

Strong success criteria let you loop independently. Weak criteria (“make
it work”) require constant clarification.

------------------------------------------------------------------------

**These guidelines are working if:** fewer unnecessary changes in diffs,
fewer rewrites due to overcomplication, and clarifying questions come
before implementation rather than after mistakes.

# New Graph Environment Conventions

Core patterns for professional, efficient workflows across New Graph
Environment repositories.

## Issue Creation Guidelines

### Professional Issue Writing

Write issues with clear technical focus:

- **Use normal technical language** in titles and descriptions
- **Focus on the problem and solution** approach
- **Avoid internal project codes or tracking references** in the main
  description
- **Add tracking links at the end** if needed (e.g.,
  `Relates to Owner/repo#N`)

**Why:** Issues are read by consultants, clients, and collaborators.
Keep them professional and focused on technical content.

**Example:**

``` markdown
## Problem
The DEM processing pipeline is slow for large datasets.

## Proposed Solution
Add structured logging and performance benchmarking to identify bottlenecks.
```

### GitHub Issue Creation - Always Use Files

The `gh issue create` command with heredoc syntax fails repeatedly with
EOF errors. ALWAYS use intermediate file approach:

``` bash
# Write issue body to scratchpad file first
cat > /path/to/scratchpad/issue_body.md << 'EOF'
## Problem
...

## Proposed Solution
...
EOF

# Then create issue from file
gh issue create --title "Brief technical title" --body-file /path/to/scratchpad/issue_body.md
```

**Why:** Reliable, works every time, no syntax errors. Saves time and
tokens.

## Commit Quality

Write clear, informative commit messages:

    Brief description (50 chars or less)

    Detailed explanation of changes and impact.
    - What changed
    - Why it changed
    - Relevant context

    Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>

**When to commit:** - Logical, atomic units of work - Working state
(tests pass) - Clear description of changes

**What to avoid:** - “WIP” or “temp” commits in main branch - Combining
unrelated changes - Vague messages like “fixes” or “updates”
