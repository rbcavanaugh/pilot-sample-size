# Pilot Study Sample Size Precision Calculator

A Shiny app for calculating confidence intervals and margins of error for pilot study sample sizes. Helps researchers plan feasibility studies and generate grant text.

## Quick Start

```r
# Install dependencies
install.packages("shiny")

# Run the app
shiny::runApp("app.R")

# Run tests (optional)
source("run_tests.R")
```

## Usage

**Study Design Tab:**
- Enter participants to approach, enrollment rate, adherence rate, attrition rate
- Get expected sample sizes and margins of error
- Switch to "Grant Text" tab for ready-to-copy grant language

**Direct Calculator Tab:**
- Enter any sample size and rate
- Get immediate margin of error calculation

## Example

With 60 participants approached at 50% enrollment, 90% adherence, 10% attrition:
- Expected enrolled: 30 participants  
- Expected completed: 27 participants (81% completion rate)
- Margins of error: ±18.0% enrollment, ±15.1% completion

## Testing

```r
source("run_tests.R")  # Returns PASS/FAIL summary
```

## Files

- `app.R` - Main Shiny application
- `run_tests.R` - Test runner with pass/fail
- `tests/` - Comprehensive test suite
